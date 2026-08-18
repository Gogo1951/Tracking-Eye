local ADDON_NAME, ns = ...
local L = ns.L

local eventFrame = CreateFrame("Frame")

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------
--[[
    The nil branch is load-bearing: an unpackaged working copy reads the metadata
    back as nil, and testing for "@" first would error on exactly the local-dev
    path this exists for.
]]
local function GetVersion()
	local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
	if not getMetadata then
		return "Dev"
	end
	local version = getMetadata(ADDON_NAME, "Version")
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
        Tracked from LOOT_OPENED / LOOT_CLOSED rather than by reading LootFrame:
        Speedy-Loot-style add-ons hide that frame while looting is still open, so
        the events are the only reliable source. Read by ns.CanCast.
    ]]
	lootWindowOpen = false,
	--[[
        Flipped true by UpdateIcon once the tracking mirror positively reports
        our own lastCastSpell — i.e. the mirror has caught up. After that, a nil
        mirror reading is a genuine external cancel (not lag), so the icon's
        in-flight fallback stops overriding it. Reset to false on every new cast.
    ]]
	mirrorConfirmedCast = false,
	-- Locale key for why Farm Mode is idle, or nil. Written only by UpdateIcon.
	farmPauseReason = nil,
}

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
    Single source of truth for the displayed icon: ns.GetActiveTrackingSpell()
    (see Utilities.lua). Never read MiniMapTrackingIcon or GetTrackingTexture
    directly here — a hidden frame keeps its last texture, and a raw read
    resurrects a cleared icon and re-poisons lastCastSpell via the adopt branch.
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
        The icon shows what the game is tracking; nothing tracked means the
        default icon. No fallback to saved or selected spells — those show a
        stale icon (e.g. last session's spell at login with nothing up). Only
        exception: for a few seconds after our own confirmed cast, and only
        until the mirror confirms it, show that spell while the icon catches up.
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

	--[[
        Dim the icon while Farm Mode is idle for a settled reason (a town, an
        instance, a taxi, an empty cycle, a movement state that isn't switched
        on). Transient reasons — combat, casting, looting — are reported in the
        tooltip but never dim, or the icon strobes through every fight. Tint
        values are written as numbers, never nil: LibDBIcon feeds iconR/G/B
        straight into SetVertexColor, which errors on a nil component.
    ]]
	local pauseReason, isTransient
	if ns.GetFarmPauseReason then
		pauseReason, isTransient = ns.GetFarmPauseReason()
	end
	ns.state.farmPauseReason = pauseReason
	local tint = (pauseReason and not isTransient) and ns.ICON_PAUSED_TINT or 1

	if ns.ldb then
		ns.ldb.icon = ns.state.currentIcon
		ns.ldb.iconR, ns.ldb.iconG, ns.ldb.iconB = tint, tint, tint
	end
	if ns.freeFrame and ns.freeFrame.icon then
		ns.freeFrame.icon:SetTexture(ns.state.currentIcon)
		ns.freeFrame.icon:SetDesaturated(tint ~= 1)
		ns.freeFrame.icon:SetVertexColor(tint, tint, tint)
	end

	if ns.RefreshTooltip then
		ns.RefreshTooltip()
	end
end

function ns.ClearTracking()
	ns.SetLastCast(nil)
	if ns.db then
		ns.db.profile.selectedSpellId = nil
		-- The cycle can include this ability, so the cache is now stale.
		ns.InvalidateFarmCache()
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
-- Returns true when a cast was actually attempted, false on every early bail.
function ns.CastTracking(spellId)
	if not spellId or not IsPlayerSpell(spellId) then
		return false
	end

	if spellId == ns.SPELLS.DRUID_HUMANOIDS then
		local isCat = ns.GetPlayerStates()
		if not isCat then
			return false
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
		return false
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
	return true
end

--------------------------------------------------------------------------------
-- Persistent Tracking Recast Helper
--------------------------------------------------------------------------------

--[[
    Mid-play recasts, triggered by UPDATE_SHAPESHIFT_FORM and
    MINIMAP_UPDATE_TRACKING. Post-resurrection recasts go through
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
	if not ns.db or not ns.db.global.showWelcome then
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
-- Profile Apply
--------------------------------------------------------------------------------

--[[
    Re-applies everything that is not read live from the database, whenever the
    active profile changes, is copied over, or is reset. Registered by name
    against the three AceDB callbacks, so it is invoked as a method with the
    callback's own arguments, which it ignores.

    Anything applied imperatively has to be repeated here — the placement, the
    scale and shape, the ticker interval, the Blizzard button hook, and the Target
    Tracking hold, none of which re-read themselves. It ends in NotifyChange for
    every registered panel: without that, an options panel already on screen keeps
    rendering the previous profile's values until the player clicks away and back.
]]
function ns:ApplyProfile()
	-- The new profile's per-state toggles change what isFarming resolves to.
	if ns.InvalidatePlayerStates then
		ns.InvalidatePlayerStates()
	end
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
	if ns.ApplyBlizzardTrackingHook then
		ns.ApplyBlizzardTrackingHook()
	end
	ns.UpdateIcon()

	if ns.RefreshOptionsPanels then
		ns.RefreshOptionsPanels()
	end
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
eventFrame:SetScript("OnEvent", function(_, event, arg1, ...)
	if ns.diagnostics and ns.diagnostics.logging then
		ns:LogEvent(event, arg1, ...)
	end

	if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
		--[[
                The third AceDB:New argument is omitted, so there is no shared
                "Default" profile: each character lands on its own profile keyed by
                name-realm. Per-character tracking state (the selected ability, the
                farm cycle) lives in ns.db.profile; account-wide layout and
                presentation live in ns.db.global, which is profile-independent.
            ]]
		ns.db = LibStub("AceDB-3.0"):New("TrackingEyeDB", ns.DATABASE_DEFAULTS)

		-- MIGRATION (remove after 2026-09-17): clear the retired per-character split marker
		ns.db.global.perCharSplitDone = nil

		for _, message in ipairs({ "OnProfileChanged", "OnProfileCopied", "OnProfileReset" }) do
			ns.db.RegisterCallback(ns, message, "ApplyProfile")
		end

		--[[
                Registered here rather than at PLAYER_LOGIN: the Profiles builder
                reads ns.db, so registration has to follow AceDB:New, and file-scope
                registration would crash on load.
            ]]
		if ns.RegisterOptionsPanels then
			ns.RegisterOptionsPanels()
		end

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
		ns.UpdateIcon()
		PollUntilTrackingReady()
		PrintWelcome()
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
		local spellId = select(2, ...)
		if ns.TRACKING_SET[spellId] then
			ns.SetLastCast(spellId)
			--[[
                The server has confirmed the cast, which is when its audio fires.
                Lets the cycle sound mute lift as soon as the sound has been
                swallowed rather than waiting out its full backstop window.
            ]]
			if ns.NotifyTrackingCastSucceeded then
				ns.NotifyTrackingCastSucceeded()
			end
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
		--[[
                Sound_EnableSFX survives the session, but the timer that would
                restore it does not — /reload and logout both land here, so an
                in-flight cycle mute has to be put back now or the player keeps
                sound effects switched off with nothing to connect it to.
            ]]
		if ns.RestoreCycleSoundNow then
			ns.RestoreCycleSoundNow()
		end
	elseif event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE" then
		RecastAfterResurrection()
	elseif event == "PLAYER_TARGET_CHANGED" then
		if ns.HandleTargetChanged then
			ns.HandleTargetChanged()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		if ns.HandleRegenEnabled then
			ns.HandleRegenEnabled()
		end
	elseif event == "LOOT_OPENED" then
		ns.state.lootWindowOpen = true
	elseif event == "LOOT_CLOSED" then
		ns.state.lootWindowOpen = false
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
			-- New spell data may have arrived; let the texture lookup rebuild once.
			if ns.InvalidateTextureCache then
				ns.InvalidateTextureCache()
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
	"LOOT_OPENED",
	"LOOT_CLOSED",
	"PLAYER_TARGET_CHANGED",
	"PLAYER_REGEN_ENABLED",
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
