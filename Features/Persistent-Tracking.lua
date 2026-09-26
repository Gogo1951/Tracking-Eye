local _, ns = ...

--------------------------------------------------------------------------------
-- Persistent Tracking Recast Helper
--------------------------------------------------------------------------------

--[[
    Mid-play recasts. Post-resurrection recasts go through
    RecastAfterResurrection instead.

    GetTrackingTexture cannot be trusted as a live "is tracking up?" source:
    during the login/reload storm it returns nil for 10+ seconds, and on Era
    (1.15.x) nil is also the normal "nothing tracked" value while the whole
    mirror lags real state by up to minutes. So the login case is solved by
    TIME (LOGIN_GRACE_SECONDS), never by interpreting nil, and the mirror is a
    positive signal only ("provably active — skip"); everything else recasts (a
    harmless refresh), debounced by RECAST_DEBOUNCE_SECONDS so our own cast's
    MINIMAP_UPDATE_TRACKING echo cannot loop.
]]
-- 10s covers the login/reload event storm. Erring short only risks one harmless redundant recast.
local LOGIN_GRACE_SECONDS = 10
local RECAST_DEBOUNCE_SECONDS = 5

local function IsInPvPInstance()
	local _, instanceType = IsInInstance()
	return instanceType == "pvp" or instanceType == "arena"
end

--[[
    The ability Persistent Tracking keeps up right now, first match wins: Track
    Humanoids inside a battleground or an arena, then Druid Track Humanoids in Cat
    Form, then Find Fish with a fishing pole in the main hand, when each option is
    on; then the running Automatic Target Tracking hunt; then the player's own
    pick. A hunt only counts while the player is out in the world, as a backstop
    against a missed event that should already have ended it, so it never meets
    the battleground override.
]]
function ns.GetPersistentSpell()
	local db = ns.db and ns.db.profile

	local humanoids = ns.SPELLS.HUMANOIDS
	if db and db.battlegroundHumanoids and humanoids and IsPlayerSpell(humanoids) and IsInPvPInstance() then
		return humanoids
	end

	local druidHumanoids = ns.SPELLS.DRUID_HUMANOIDS
	if db and db.catFormHumanoids and druidHumanoids and IsPlayerSpell(druidHumanoids) and (ns.GetPlayerStates()) then
		return druidHumanoids
	end

	local findFish = ns.SPELLS.FISH
	if db and db.fishingPoleFish and findFish and IsPlayerSpell(findFish) and ns.IsFishingPoleEquipped() then
		return findFish
	end

	local huntSpellId = ns.state.huntSpellId
	if huntSpellId and ns.IsOutInTheWorld() then
		return huntSpellId
	end
	return db and db.selectedSpellId
end

--[[
    Every recast here waits until the player is moving, parked with no timer
    until PLAYER_STARTED_MOVING wakes it: standing still is when a player eats,
    drinks, gathers, or reads, and a cast then stands them up or costs a global
    cooldown for nothing. The wake-up runs a short beat after the player sets
    off, and every parked recast re-checks movement itself, so a tap that stops
    at once still counts as standing still.
]]
local MOVEMENT_SETTLE_SECONDS = 0.2

local waitingForMovement = {}
local movementResumePending = false

local function WaitForMovement(recast)
	waitingForMovement[recast] = true
end

local function RunWaitingForMovement()
	movementResumePending = false
	-- Swapped out before the calls: a recast that finds the player standing again parks itself anew.
	local waiting = waitingForMovement
	waitingForMovement = {}
	for recast in pairs(waiting) do
		recast()
	end
end

function ns.OnPlayerStartedMoving()
	if movementResumePending or next(waitingForMovement) == nil then
		return
	end
	movementResumePending = true
	C_Timer.After(MOVEMENT_SETTLE_SECONDS, RunWaitingForMovement)
end

--[[
    Temporary bails (in combat, inside the debounce, standing still) must
    RETRY, never swallow the trigger: on Era the client may fire no further
    tracking event, ever — a swallowed trigger means the user cancels tracking
    a second time within the debounce and persistent tracking simply stops
    until the next login. ScheduleRecast coalesces the timed retries so bursts
    can't stack timers; standing still parks the recast until the player moves.
]]
local TryRecastPersistent
local recastRetryPending = false
local function ScheduleRecast(delay)
	if recastRetryPending then
		return
	end
	recastRetryPending = true
	C_Timer.After(delay, function()
		recastRetryPending = false
		TryRecastPersistent()
	end)
end

TryRecastPersistent = function()
	local spellId = ns.GetPersistentSpell()
	if not ns.db or not ns.db.profile.persistentTracking or not spellId then
		return
	end

	local _, isFarming = ns.GetPlayerStates()
	if isFarming then
		return
	end

	if not IsPlayerSpell(spellId) then
		return
	end

	--[[
        Login/reload grace window: the tracking API may not be ready, so
        we cannot tell whether the spell is already active. Wait it out;
        the PLAYER_ENTERING_WORLD catch-up covers the gap afterwards.
    ]]
	if GetTime() - (ns.state.enteredWorldAt or 0) < LOGIN_GRACE_SECONDS then
		return
	end

	--[[
        If the spell is provably active (Blizzard minimap icon
        first, mirror as fallback — see ns.GetActiveTrackingSpell), sync
        lastCastSpell and stop. This is also what terminates the retry
        chain after a successful recast.
    ]]
	if ns.GetActiveTrackingSpell() == spellId then
		ns.SetLastCast(spellId)
		--[[
            The mirror is positively reporting this spell right now, so it has
            already caught up — re-latch the confirmation SetLastCast just
            cleared, instead of leaving it false until the next UpdateIcon.
        ]]
		ns.state.mirrorConfirmedCast = true
		return
	end

	--[[
        Our own cast is still in flight: UNIT_SPELLCAST_SUCCEEDED confirmed it but
        the laggy Era mirror hasn't caught up, so the positive check above can't
        see it yet. Reschedule and re-check instead of recasting — otherwise the
        constant UPDATE_SHAPESHIFT_FORM stream (a hunter's aspects) drives a
        redundant recast every ~5s until the mirror flushes. Always reschedules,
        never swallows, so a genuine re-cancel still recasts once the window passes.
    ]]
	if ns.state.lastCastSpell == spellId then
		local sinceCast = GetTime() - (ns.state.lastTrackingCastAt or 0)
		if sinceCast < ns.CAST_IN_FLIGHT_SECONDS then
			ScheduleRecast(ns.CAST_IN_FLIGHT_SECONDS - sinceCast + 0.5)
			return
		end
	end

	if not ns.IsPlayerMoving() then
		WaitForMovement(TryRecastPersistent)
		return
	end

	--[[
        Same cast hygiene as the farm ticker: never burn a GCD while
        dead, stealthed, mid-cast, or in combat (a druid powershifting
        in combat fires UPDATE_SHAPESHIFT_FORM constantly). Temporary
        state, so retry.
    ]]
	if not ns.CanCast() then
		ScheduleRecast(RECAST_DEBOUNCE_SECONDS)
		return
	end

	-- On cooldown or GCD: temporary state, so retry rather than let CastTracking swallow it.
	local start, duration = ns.GetSpellCooldown(spellId)
	if start and duration and start > 0 and duration > 0 then
		ScheduleRecast(RECAST_DEBOUNCE_SECONDS)
		return
	end

	--[[
        Debounce the MINIMAP_UPDATE_TRACKING echo of our own cast — but
        retry after it expires rather than dropping the trigger.
    ]]
	local sinceCast = GetTime() - (ns.state.lastTrackingCastAt or 0)
	if sinceCast < RECAST_DEBOUNCE_SECONDS then
		ScheduleRecast(RECAST_DEBOUNCE_SECONDS - sinceCast + 0.5)
		return
	end

	ns.CastTracking(spellId)
end

-- Target Tracking brings the Persistent Tracking Ability back through this when a hunt ends.
ns.TryRecastPersistent = TryRecastPersistent

--[[
    Shapeshift and tracking-change events arrive in bursts (a hunter's aspects
    fire UPDATE_SHAPESHIFT_FORM constantly), so a burst schedules one delayed
    recast and TryRecastPersistent re-reads everything when it runs. The flag is
    separate from recastRetryPending, so the retry chain is untouched.
]]
local eventRecastPending = false

local function RunEventRecast()
	eventRecastPending = false
	TryRecastPersistent()
end

function ns.ScheduleEventRecast(delay)
	if eventRecastPending then
		return
	end
	eventRecastPending = true
	C_Timer.After(delay, RunEventRecast)
end

--[[
    Anchors the recast grace window on every PLAYER_ENTERING_WORLD (login,
    reload, and zoning) and schedules the guaranteed catch-up recast once it
    ends. Without the catch-up, a player who logs in with tracking down stays
    that way indefinitely: on Era the tracking events that would otherwise
    provide a trigger may simply never fire. If tracking is already up (the
    mirror confirms it), TryRecastPersistent skips, so this cannot recast into
    the login blackout on clients with a working mirror.
]]
function ns.StartLoginGrace()
	ns.state.enteredWorldAt = GetTime()
	C_Timer.After(LOGIN_GRACE_SECONDS + 1, TryRecastPersistent)
end

--------------------------------------------------------------------------------
-- Post-Resurrection Recast
--------------------------------------------------------------------------------

--[[
    Both PLAYER_UNGHOST (returning to a corpse after a spirit run) and
    PLAYER_ALIVE (an in-place resurrection — healer rez, soulstone, or being
    ported to a graveyard) genuinely clear tracking on the server, so a recast is
    always needed and the laggy tracking mirror is never consulted here. A
    corpse-run return fires BOTH events, so resurrectRecastPending coalesces them
    into a single scheduled recast (same pattern as ScheduleRecast).

    PLAYER_ALIVE also fires the instant the player releases spirit and becomes a
    ghost, so the delayed callback bails while still dead or ghost — we never cast
    into a corpse, and the real resurrection later fires the event again.

    The recast waits for the same all-clear as every automatic cast. A battle rez
    or soulstone lands mid-fight, so a refusal from ns.CanCast(), or a cooldown or
    GCD refusal from ns.CastTracking, schedules another attempt instead of casting
    into the fight or dropping the recast. It also parks until the player moves,
    like every recast here, so sitting down to eat right after a rez keeps the
    meal; resurrectRecastPending stays set while it waits, so another PLAYER_ALIVE
    can't start a second chain. Every other bail is lasting and ends the chain.
]]
local resurrectRecastPending = false

local function EndResurrectionRecast()
	resurrectRecastPending = false
	ns.UpdateIcon()
end

local function AttemptResurrectionRecast()
	-- Still dead/ghost: PLAYER_ALIVE fired for releasing spirit, not a real rez.
	if UnitIsDeadOrGhost("player") then
		EndResurrectionRecast()
		return
	end

	local spellId = ns.GetPersistentSpell()
	if not ns.db or not ns.db.profile.persistentTracking or not spellId then
		EndResurrectionRecast()
		return
	end

	local isCat, isFarming = ns.GetPlayerStates()
	if isFarming or not IsPlayerSpell(spellId) or (ns.CAT_FORM_ONLY[spellId] and not isCat) then
		EndResurrectionRecast()
		return
	end

	if not ns.IsPlayerMoving() then
		WaitForMovement(AttemptResurrectionRecast)
		return
	end

	if not ns.CanCast() or not ns.CastTracking(spellId) then
		C_Timer.After(RECAST_DEBOUNCE_SECONDS, AttemptResurrectionRecast)
		return
	end
	EndResurrectionRecast()
end

function ns.RecastAfterResurrection()
	if resurrectRecastPending then
		return
	end
	resurrectRecastPending = true
	C_Timer.After(1.5, AttemptResurrectionRecast)
end
