local ADDON_NAME, ns = ...
local L = ns.L

local eventFrame = CreateFrame("Frame")

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------
local function GetVersion()
	local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
	local version = GetAddOnMetadata(ADDON_NAME, "Version")
	if not version or version:find("@") then
		return "Dev"
	end
	return version
end

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------
ns.state = {
	currentIcon = ns.ICON_DEFAULT,
	wasFarming = false,
	lastCastSpell = nil,
	--[[
        enteredWorldAt anchors the login/reload grace window used by
        TryRecastPersistent (initialized at file load so triggers that
        arrive before the first PLAYER_ENTERING_WORLD are still covered).
        lastTrackingCastAt debounces recasts against the
        MINIMAP_UPDATE_TRACKING echo of our own cast.
    ]]
	enteredWorldAt = GetTime(),
	lastTrackingCastAt = 0,
	--[[
        Flipped true by UpdateIcon once the tracking mirror positively reports
        our own lastCastSpell — i.e. the mirror has caught up. After that, a nil
        mirror reading is a genuine external cancel (not lag), so the icon's
        in-flight fallback stops overriding it. Reset to false on every new cast.
    ]]
	mirrorConfirmedCast = false,
}

ns.optionsOpen = false

--[[
    Single write-site for the runtime-only lastCastSpell bookkeeping,
    written from UNIT_SPELLCAST_SUCCEEDED (and cleared on demand). Never
    persisted: last session's value treated as live bookkeeping makes the
    farm cycle and persistent recast believe tracking is already up at
    login and skip every real cast.
]]
function ns.SetLastCast(spellId)
	ns.state.lastCastSpell = spellId
	-- A freshly recorded cast is not yet mirror-confirmed; UpdateIcon flips this.
	ns.state.mirrorConfirmedCast = false
end

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------
--[[
    Display resolution uses the SAME single source of truth as the cast
    logic — ns.GetActiveTrackingSpell() (Blizzard minimap icon while
    visible, GetTrackingTexture as fallback; see Utilities.lua). Never
    read MiniMapTrackingIcon or GetTrackingTexture directly here: a
    hidden frame retains its last texture, and a raw read resurrects a
    cleared tracking icon (and, worse, re-poisons lastCastSpell through
    the adoption branch). Every past icon bug on Era came from a second
    reader of the mirror with slightly different rules.
]]
function ns.UpdateIcon()
	local isCat = ns.GetPlayerStates()

	if not isCat and ns.state.lastCastSpell == ns.SPELLS.DRUID_HUMANOIDS then
		ns.SetLastCast(nil)
	end

	local activeSpell = ns.GetActiveTrackingSpell()
	if activeSpell and not ns.state.lastCastSpell then
		--[[
            Adopt tracking that predates this session (set up before the
            addon loaded) — but ONLY while the session has no confirmed
            cast. In-session casts already update lastCastSpell via
            UNIT_SPELLCAST_SUCCEEDED, and the mirror lags that event on
            Era: adopting over fresh bookkeeping would corrupt the farm
            cycle's comparisons.
        ]]
		ns.SetLastCast(activeSpell)
	end

	--[[
        Once the mirror positively reports our own cast it has caught up, so a
        later nil reading is a genuine external cancel rather than lag. Latch
        that here so the in-flight fallback below stops re-showing the stale
        icon — this is what makes an external cancel resolve promptly instead of
        hanging on the old spell for the rest of the window.
    ]]
	if activeSpell and activeSpell == ns.state.lastCastSpell then
		ns.state.mirrorConfirmedCast = true
	end

	--[[
        THE ICON SHOWS WHAT THE GAME IS TRACKING — nothing tracked means
        the default icon. No fallback to saved or selected spells: every
        such fallback has produced a stale icon (e.g. showing last
        session's spell at login with nothing up). Single exception: for
        a few seconds after our own CONFIRMED cast — and only until the mirror
        confirms it — show that spell while the laggy Blizzard icon catches up.
        The cast succeeded, so that is still the game's real state.
    ]]
	local iconSpell = activeSpell
	if
		not iconSpell
		and ns.state.lastCastSpell
		and not ns.state.mirrorConfirmedCast
		and (GetTime() - (ns.state.lastTrackingCastAt or 0)) < ns.ICON_IN_FLIGHT_SECONDS
	then
		iconSpell = ns.state.lastCastSpell
	end

	ns.state.currentIcon = iconSpell and GetSpellTexture(iconSpell) or ns.ICON_DEFAULT

	if ns.ldb then
		ns.ldb.icon = ns.state.currentIcon
	end
	if ns.freeFrame and ns.freeFrame.icon then
		ns.freeFrame.icon:SetTexture(ns.state.currentIcon)
	end

	if ns.RefreshTooltip then
		ns.RefreshTooltip()
	end
end

function ns.ClearTracking()
	ns.SetLastCast(nil)
	if ns.db then
		ns.db.profile.selectedSpellId = nil
	end
	CancelTrackingBuff()

	-- Force the default icon now: CancelTrackingBuff is async, so the mirror still reads the old texture for a frame.
	ns.state.currentIcon = ns.ICON_DEFAULT
	if ns.ldb then
		ns.ldb.icon = ns.ICON_DEFAULT
	end
	if ns.freeFrame and ns.freeFrame.icon then
		ns.freeFrame.icon:SetTexture(ns.ICON_DEFAULT)
	end
	if ns.RefreshTooltip then
		ns.RefreshTooltip()
	end
end

--------------------------------------------------------------------------------
-- Casting
--------------------------------------------------------------------------------
function ns.CastTracking(spellId)
	if not spellId or not IsPlayerSpell(spellId) then
		return
	end

	if spellId == ns.SPELLS.DRUID_HUMANOIDS then
		local isCat = ns.GetPlayerStates()
		if not isCat then
			return
		end
	end

	--[[
        Treating "on GCD" as "on cooldown" is acceptable here (no real-cooldown
        vs GCD split): tracking casts are cheap refreshes, and every caller
        either retries (TryRecastPersistent) or re-fires on its next tick (the
        farm ticker), so a GCD-blocked attempt is never lost.
    ]]
	local start, duration = GetSpellCooldown(spellId)
	if start and duration and start > 0 and duration > 0 then
		return
	end

	--[[
        Do not write lastCastSpell or refresh the icon here — the cast
        can still fail silently (LOS, range, server reject). Let
        UNIT_SPELLCAST_SUCCEEDED be the single source of truth for a
        successful cast; otherwise the farm cycle and persistent recast
        would see a matching lastCastSpell and skip a real recast.
        lastTrackingCastAt is set on the attempt (not the success) so a
        burst of triggers can't hammer casts while one is in flight.
    ]]
	ns.state.lastTrackingCastAt = GetTime()
	pcall(CastSpellByID, spellId)
end

--------------------------------------------------------------------------------
-- Persistent Tracking Recast Helper
--------------------------------------------------------------------------------

--[[
    TryRecastPersistent handles mid-play recasts, triggered by
    UPDATE_SHAPESHIFT_FORM (e.g. druid leaving cat form) and by
    MINIMAP_UPDATE_TRACKING (tracking changed or cancelled outside the
    addon). Post-resurrection recasts are handled separately by
    RecastAfterResurrection (PLAYER_UNGHOST / PLAYER_ALIVE), which bypasses this
    function entirely.

    GetTrackingTexture CANNOT be trusted as a live "is my tracking up?"
    source across clients:

    - During the Classic login/reload event storm it returns nil for
      10+ seconds. Casting blindly in that window causes the
      long-standing login-recast bug.
    - On the Vanilla-based client (Classic Era 1.15.x) nil is ALSO the
      normal steady-state value for "no tracking active", and since
      1.15.1 the whole tracking mirror (GetTrackingTexture and
      MINIMAP_UPDATE_TRACKING) lags the real state, sometimes by
      minutes — it only flushes when an unrelated buff update happens.
      A nil bail therefore permanently blocks recasts on Era.

    So the login problem is solved by TIME (LOGIN_GRACE_SECONDS after
    PLAYER_ENTERING_WORLD), not by interpreting nil, and the mirror is
    consulted only as a positive signal ("the selected spell is
    provably active — skip"). Everything else recasts, debounced by
    RECAST_DEBOUNCE_SECONDS so the MINIMAP_UPDATE_TRACKING echo of our
    own successful cast cannot re-trigger a cast loop. Recasting an
    already-active tracking spell is a harmless refresh, so erring on
    the side of casting is safe.
]]
-- 10s covers the login/reload event storm. Erring short only risks one harmless redundant recast.
local LOGIN_GRACE_SECONDS = 10
local RECAST_DEBOUNCE_SECONDS = 5

--[[
    Temporary bails (in combat, inside the debounce) must RETRY, never
    swallow the trigger: on Era the client may fire no further tracking
    event, ever — a swallowed trigger means the user cancels tracking a
    second time within the debounce and persistent tracking simply stops
    until the next login. ScheduleRecast coalesces retries so bursts
    can't stack timers.
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
	if not ns.db or not ns.db.profile.persistentTracking or not ns.db.profile.selectedSpellId then
		return
	end

	local _, isFarming = ns.GetPlayerStates()
	if isFarming then
		return
	end

	local spellId = ns.db.profile.selectedSpellId
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
        If the selected spell is provably active (Blizzard minimap icon
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
        Our own cast of this spell is still "in flight": UNIT_SPELLCAST_SUCCEEDED
        confirmed it (lastCastSpell == spellId) but the laggy Era mirror hasn't
        caught up, so the positive check above can't see it yet. Trust our own
        confirmed cast and re-check after the window instead of recasting.

        Without this, the constant UPDATE_SHAPESHIFT_FORM stream (a hunter's
        aspects fire it every few seconds) drives a recast of the same spell
        every ~5s until the mirror finally flushes — the "casting it 3 times"
        symptom. This ALWAYS reschedules (never swallows), so a genuine
        re-cancel still recasts once the window passes; it can never stop
        persistent tracking permanently.
    ]]
	if ns.state.lastCastSpell == spellId then
		local sinceCast = GetTime() - (ns.state.lastTrackingCastAt or 0)
		if sinceCast < ns.CAST_IN_FLIGHT_SECONDS then
			ScheduleRecast(ns.CAST_IN_FLIGHT_SECONDS - sinceCast + 0.5)
			return
		end
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
	local start, duration = GetSpellCooldown(spellId)
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

--------------------------------------------------------------------------------
-- Welcome Message
--------------------------------------------------------------------------------
local function PrintWelcome()
	if not ns.db or not ns.db.profile.showWelcome then
		return
	end
	ns:PrintMessage(L["CHAT_LOADED"]:format(ns.Version))
end

--[[
    Poll until the Blizzard minimap tracking icon has a texture, then
    refresh the icon once. During the Classic login event storm
    MiniMapTrackingIcon may not have its texture set yet, so every
    UpdateIcon call falls through to the default icon, and
    MINIMAP_UPDATE_TRACKING does not fire because tracking state
    hasn't changed — without this poll the icon stays stuck on
    default until the user toggles something.
]]
local function PollUntilTrackingReady(attempts)
	attempts = attempts or 0
	if MiniMapTrackingIcon and MiniMapTrackingIcon:GetTexture() then
		ns.UpdateIcon()
		return
	end
	if attempts >= 15 then
		return
	end
	C_Timer.After(1, function()
		PollUntilTrackingReady(attempts + 1)
	end)
end

--[[
    Brief flush-poll after a tracking change. The Era tracking mirror can settle
    a beat or two after MINIMAP_UPDATE_TRACKING fires — sometimes without firing
    a second event — so re-run UpdateIcon a few times over ~2s to catch the
    flush the moment it happens instead of waiting for an unrelated buff tick.
    This cannot make the mirror fresher; it only shaves tail latency. Coalesced
    so a burst of tracking events can't stack overlapping polls.
]]
local iconFlushActive = false
local function FlushIconAfterTrackingChange()
	if iconFlushActive then
		return
	end
	iconFlushActive = true
	local attempts = 0
	local function tick()
		ns.UpdateIcon()
		attempts = attempts + 1
		if attempts >= 8 then
			iconFlushActive = false
			return
		end
		C_Timer.After(0.25, tick)
	end
	C_Timer.After(0.25, tick)
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
]]
local resurrectRecastPending = false
local function RecastAfterResurrection()
	if resurrectRecastPending then
		return
	end
	resurrectRecastPending = true
	C_Timer.After(1.5, function()
		resurrectRecastPending = false

		-- Still dead/ghost: PLAYER_ALIVE fired for releasing spirit, not a real rez.
		if UnitIsDeadOrGhost("player") then
			ns.UpdateIcon()
			return
		end

		if not ns.db or not ns.db.profile.persistentTracking or not ns.db.profile.selectedSpellId then
			ns.UpdateIcon()
			return
		end

		local _, isFarming = ns.GetPlayerStates()
		if isFarming then
			ns.UpdateIcon()
			return
		end

		local spellId = ns.db.profile.selectedSpellId
		if IsPlayerSpell(spellId) then
			ns.CastTracking(spellId)
		end
		ns.UpdateIcon()
	end)
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
eventFrame:SetScript("OnEvent", function(_, event, arg1, ...)
	if ns.diagnostics and ns.diagnostics.logging then
		ns:LogEvent(event, arg1, ...)
	end

	if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
		ns.db = LibStub("AceDB-3.0"):New("TrackingEyeDB", ns.DATABASE_DEFAULTS, true)

		--[[
                MIGRATION (remove after 2026-10-07): fold the pre-AceDB layout into
                the AceDB profile/global. Older versions stored account-wide settings
                at the root of TrackingEyeDB and per-character settings in the separate
                TrackingEyeCharDB table; AceDB now owns TrackingEyeDB, so the legacy
                root keys and the whole TrackingEyeCharDB are read once, copied into
                the profile (or global, for placement), and cleared. The legacy field
                renames (autoTracking -> persistentTracking, farmingMode -> farmMode),
                the dropped runtime-only lastCastSpell, and the retired cross-character
                resetGeneration marker are all handled here. ns.db.sv is the raw saved
                table, so the pre-AceDB root keys are still readable off it.
            ]]
		local root = ns.db.sv
		local rootProfileKeys = { "showWelcome", "freePlacement", "freeIconScale", "freeIconShape" }
		for _, key in ipairs(rootProfileKeys) do
			if root[key] ~= nil then
				ns.db.profile[key] = root[key]
				root[key] = nil
			end
		end
		if type(root.minimap) == "table" then
			ns.db.global.minimap = root.minimap
			root.minimap = nil
		end
		if root.freePos ~= nil then
			ns.db.global.freePos = root.freePos
			root.freePos = nil
		end
		root.resetGeneration = nil

		local char = TrackingEyeCharDB
		if char then
			if char.autoTracking ~= nil and char.persistentTracking == nil then
				char.persistentTracking = char.autoTracking
			end
			if char.farmingMode ~= nil and char.farmMode == nil then
				char.farmMode = char.farmingMode
			end
			local charKeys = {
				"persistentTracking",
				"farmMode",
				"farmInterval",
				"farmMounted",
				"farmTravelForms",
				"farmCheetah",
				"farmGhostWolf",
				"farmNotMounted",
				"selectedSpellId",
			}
			for _, key in ipairs(charKeys) do
				if char[key] ~= nil then
					ns.db.profile[key] = char[key]
				end
			end
			if type(char.farmCycleSpells) == "table" then
				local moved = {}
				for id, enabled in pairs(char.farmCycleSpells) do
					moved[id] = enabled and true or false
				end
				--[[
                        The old model stored a disabled cycle spell as an absent key.
                        AceDB re-adds default-true for any absent default key on every
                        login, so pin the user's off state to an explicit false or the
                        default Herbs/Minerals would resurrect after migration.
                    ]]
				for id in pairs(ns.FARM_CYCLE_DEFAULTS) do
					if moved[id] == nil then
						moved[id] = false
					end
				end
				ns.db.profile.farmCycleSpells = moved
			end
			wipe(char)
		end

		--[[
                AceDB owns every setting under ns.db.profile and the minimap / free
                position under ns.db.global; refresh the runtime views whenever the
                active profile changes, is copied over, or is reset.
            ]]
		local function OnProfileChange()
			if ns.InvalidateFarmCache then
				ns.InvalidateFarmCache()
			end
			if ns.RestartFarmTicker then
				ns.RestartFarmTicker()
			end
			if ns.UpdatePlacement then
				ns.UpdatePlacement()
			end
			if ns.UpdateFreeFrameScale then
				ns.UpdateFreeFrameScale()
			end
			if ns.UpdateFreeFrameShape then
				ns.UpdateFreeFrameShape()
			end
			ns.UpdateIcon()
		end
		ns.db.RegisterCallback(ns, "OnProfileChanged", OnProfileChange)
		ns.db.RegisterCallback(ns, "OnProfileCopied", OnProfileChange)
		ns.db.RegisterCallback(ns, "OnProfileReset", OnProfileChange)

		-- Deliberately no lastCastSpell seed here: it is runtime-only (see ns.SetLastCast).

		if ns.CreateFreeFrame then
			ns.CreateFreeFrame()
		end
		ns.UpdateIcon()
	elseif event == "PLAYER_LOGIN" then
		if ns.InitMinimap then
			ns.InitMinimap()
		end
		if ns.InitFarmMode then
			ns.InitFarmMode()
		end
		if ns.InitOptions then
			ns.InitOptions()
		end
		ns.UpdateIcon()
		PollUntilTrackingReady()
		PrintWelcome()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
		local spellId = select(2, ...)
		if ns.TRACKING_SET[spellId] then
			ns.SetLastCast(spellId)
			ns.UpdateIcon()
		end
	elseif event == "PLAYER_LOGOUT" then
		--[[
                Final position save before WoW serializes SavedVariables.
                OnDragStop already writes freePos after every drag, but
                logging out here guarantees we capture the live position
                even if something (e.g., another addon nudging the
                frame, a SetClampedToScreen rebound) shifted it after
                the last drag.
            ]]
		if ns.SaveFreeFramePosition then
			ns.SaveFreeFramePosition()
		end
	elseif event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE" then
		RecastAfterResurrection()
	elseif event == "PLAYER_UPDATE_RESTING" then
		--[[
                Resting flipped (entered/left a city or inn). Re-run the farm
                evaluation immediately instead of waiting up to a full ticker
                interval: on entering it stops right away, on leaving it resumes
                right away. Note this reacts the instant the CLIENT reports
                resting — that flag can itself lag zone entry by several seconds,
                and that latency is the game's, not the ticker's. Killing it
                outright would need map-ID city detection, which the current
                design deliberately avoids (see README-Technical → Restricted
                Zones).
            ]]
		if ns.RunFarmLogic then
			ns.RunFarmLogic()
		end
	elseif
		event == "MINIMAP_UPDATE_TRACKING"
		or event == "PLAYER_ENTERING_WORLD"
		or event == "ZONE_CHANGED_NEW_AREA"
		or event == "UPDATE_SHAPESHIFT_FORM"
		or event == "SPELLS_CHANGED"
	then
		ns.UpdateIcon()

		if event == "PLAYER_ENTERING_WORLD" then
			-- Anchor the recast grace window (login, reload, and zoning).
			ns.state.enteredWorldAt = GetTime()
			--[[
                    Guaranteed catch-up recast once the grace window ends.
                    Without this, a player who logs in with tracking down
                    stays that way indefinitely: on Era the tracking events
                    that would otherwise provide a trigger may simply never
                    fire. If tracking is already up (mirror confirms it),
                    TryRecastPersistent skips — so this cannot reintroduce
                    the login-recast bug on clients with a working mirror.
                ]]
			C_Timer.After(LOGIN_GRACE_SECONDS + 1, function()
				TryRecastPersistent()
			end)
		end

		if event == "SPELLS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
			if ns.UpdatePlacement then
				ns.UpdatePlacement()
			end
			if ns.InvalidateFarmCache then
				ns.InvalidateFarmCache()
			end
		end

		if event == "UPDATE_SHAPESHIFT_FORM" then
			-- Delay so the shapeshift GCD expires before we attempt to cast.
			C_Timer.After(1.5, function()
				TryRecastPersistent()
			end)
		end

		if event == "MINIMAP_UPDATE_TRACKING" then
			--[[
                    Catch the mirror the instant it flushes so an external
                    cancel updates the icon without waiting for the next
                    unrelated event. The UpdateIcon() at the top of this branch
                    handles the case where the mirror was already fresh.
                ]]
			FlushIconAfterTrackingChange()

			--[[
                    Tracking state changed outside the addon — including
                    the user cancelling it. This is the "excuse" the
                    persistent recast needs. Delayed so the event burst
                    settles; the function's own grace window and debounce
                    make it safe to call from here (our own successful
                    cast also fires this event).
                ]]
			C_Timer.After(2, function()
				TryRecastPersistent()
			end)
		end
	end
end)

--[[
    Single source of truth for the events the dispatcher registers. The
    Diagnostics panel's Event Registration check reads this same list
    (ns.EVENT_NAMES) so it can never drift from what the add-on actually uses.
]]
ns.EVENT_NAMES = {
	"ADDON_LOADED",
	"PLAYER_LOGIN",
	"UNIT_SPELLCAST_SUCCEEDED",
	"MINIMAP_UPDATE_TRACKING",
	"PLAYER_ENTERING_WORLD",
	"ZONE_CHANGED_NEW_AREA",
	"UPDATE_SHAPESHIFT_FORM",
	"SPELLS_CHANGED",
	"PLAYER_UNGHOST",
	"PLAYER_ALIVE",
	"PLAYER_UPDATE_RESTING",
	"PLAYER_LOGOUT",
}

-- Unit-filtered events: register scoped to the player so the dispatcher isn't woken for other units' casts.
local UNIT_FILTERED_EVENTS = {
	UNIT_SPELLCAST_SUCCEEDED = "player",
}

for _, eventName in ipairs(ns.EVENT_NAMES) do
	local unit = UNIT_FILTERED_EVENTS[eventName]
	if unit then
		eventFrame:RegisterUnitEvent(eventName, unit)
	else
		eventFrame:RegisterEvent(eventName)
	end
end
