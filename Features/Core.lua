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
	local version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version")
	if not version or version:find("@") then
		return "Dev"
	end
	return version
end

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- Welcome Message
--------------------------------------------------------------------------------

local function PrintWelcome()
	if not ns.db or not ns.db.global.showWelcome then
		return
	end
	ns:PrintMessage(L["CHAT_LOADED"]:format(ns.Version))
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
    scale and shape, the ticker interval, and the Blizzard button hook, none of
    which re-read themselves — and a running Target Tracking hunt ends, bringing
    the new profile's Persistent Tracking Ability back. It ends in NotifyChange for
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
	if ns.EndHunt then
		ns.EndHunt(true)
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
		ns.PollUntilTrackingReady()
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
                even if something (e.g., another add-on nudging the
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
		ns.RecastAfterResurrection()
	elseif event == "PLAYER_STARTED_MOVING" then
		if ns.OnPlayerStartedMoving then
			ns.OnPlayerStartedMoving()
		end
	elseif event == "PLAYER_EQUIPMENT_CHANGED" then
		-- Only the main hand matters: a fishing pole there changes what Persistent Tracking keeps up.
		if arg1 == INVSLOT_MAINHAND then
			if ns.InvalidateFarmCache then
				ns.InvalidateFarmCache()
			end
			ns.UpdateIcon()
			ns.ScheduleEventRecast(1.5)
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		if ns.OnPlayerTargetChanged then
			ns.OnPlayerTargetChanged()
		end
	elseif event == "LOOT_OPENED" then
		ns.state.lootWindowOpen = true
	elseif event == "LOOT_CLOSED" then
		ns.state.lootWindowOpen = false
	elseif event == "UI_ERROR_MESSAGE" then
		-- Every red error fires this; Come & Get It gates before it matches, so a miss costs no string work.
		if ns.OnUIErrorMessage then
			ns.OnUIErrorMessage(arg1, ...)
		end
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
		-- A hunt never outlives entering a town or an inn.
		if IsResting() and ns.EndHunt then
			ns.EndHunt(true)
		end
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
			ns.StartLoginGrace()
		end

		--[[
                A hunt never outlives a move into an instance or a resting area.
                Checked after enteredWorldAt is anchored, so the recast that
                brings the Persistent Tracking Ability back honors the grace window.
            ]]
		if
			(event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA")
			and ns.EndHunt
			and ns.IsRestrictedZone()
		then
			ns.EndHunt(true)
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
			ns.ScheduleEventRecast(1.5)
		end

		if event == "MINIMAP_UPDATE_TRACKING" then
			--[[
                    Catch the mirror the instant it flushes so an external
                    cancel updates the icon without waiting for the next
                    unrelated event. The UpdateIcon() at the top of this branch
                    handles the case where the mirror was already fresh.
                ]]
			ns.FlushIconAfterTrackingChange()

			--[[
                    Tracking state changed outside the add-on — including
                    the user cancelling it. This is the "excuse" the
                    persistent recast needs. Delayed so the event burst
                    settles; the function's own grace window and debounce
                    make it safe to call from here (our own successful
                    cast also fires this event).
                ]]
			ns.ScheduleEventRecast(2)
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
	"PLAYER_STARTED_MOVING",
	"PLAYER_EQUIPMENT_CHANGED",
	"PLAYER_UPDATE_RESTING",
	"PLAYER_LOGOUT",
	"LOOT_OPENED",
	"LOOT_CLOSED",
	"PLAYER_TARGET_CHANGED",
	"UI_ERROR_MESSAGE",
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
