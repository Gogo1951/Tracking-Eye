local ADDON_NAME, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Placement & Tooltip
--------------------------------------------------------------------------------

function ns.UpdatePlacement()
	if not ns.db then
		return
	end

	if not ns.HasTrackingAbility() then
		if ns.freeFrame then
			ns.freeFrame:Hide()
		end
		LibDBIcon:Hide(ADDON_NAME)
		return
	end

	if ns.db.global.freePlacement then
		--[[
            Free frame replaces the minimap button. Hide the button without
            touching the saved Enable Mini-map Button preference
            (ns.db.global.minimap.hide), so the preference survives a Free
            Placement round-trip.
        ]]
		LibDBIcon:Hide(ADDON_NAME)
		if ns.freeFrame then
			--[[
                Re-apply position on every show. Defends against any
                other code path (LibDBIcon callbacks, conflicts with other
                add-ons, layout-local replay) that might have silently
                re-anchored the frame while it was hidden.
            ]]
			ns.ApplyFreePosition(ns.freeFrame)
			ns.freeFrame:Show()
		end
	else
		if ns.freeFrame then
			ns.freeFrame:Hide()
		end
		-- Honor the Enable Mini-map Button preference (minimap.hide, inverted).
		LibDBIcon:Refresh(ADDON_NAME, ns.db.global.minimap)
	end

	ns.UpdateFreeFrameScale()
	ns.UpdateFreeFrameShape()
end

function ns.BuildTooltip(tooltip)
	tooltip:AddDoubleLine(GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r", GetColor("MUTED") .. ns.Version .. "|r")
	tooltip:AddLine(" ")
	tooltip:AddLine(" ")

	tooltip:AddLine(GetColor("TITLE") .. L["TRACKING_MENU"] .. "|r")
	tooltip:AddLine(GetColor("BODY") .. L["TRACKING_MENU_DESCRIPTION"] .. "|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(GetColor("INFO") .. L["LEFT_CLICK"] .. "|r", GetColor("INFO") .. L["OPEN"] .. "|r")
	tooltip:AddLine(" ")

	--[[
        The label takes its own row and the ability sits right-aligned beneath it,
        the house layout for a current-item value. States such as the Farm Mode
        Status stay on their label's row. The icon travels with the name so the
        pair never splits.
    ]]
	local selectedSpellId = ns.db and ns.db.profile.selectedSpellId
	local abilityText
	if selectedSpellId then
		local name = C_Spell.GetSpellName(selectedSpellId) or L["NONE_SET"]
		abilityText = "|T"
			.. (C_Spell.GetSpellTexture(selectedSpellId) or ns.ICON_DEFAULT)
			.. ":16|t "
			.. GetColor("TEXT")
			.. name
			.. "|r"
	else
		abilityText = "|T" .. ns.ICON_DEFAULT .. ":16|t " .. GetColor("BODY") .. L["NONE_SET"] .. "|r"
	end
	tooltip:AddLine(GetColor("TITLE") .. L["PERSISTENT_ABILITY"] .. "|r")
	tooltip:AddDoubleLine(" ", abilityText)
	tooltip:AddDoubleLine(GetColor("INFO") .. L["RIGHT_CLICK"] .. "|r", GetColor("INFO") .. L["CLEAR_TRACKING"] .. "|r")
	tooltip:AddLine(" ")

	local farmState = (ns.db and ns.db.profile.farmMode) and (GetColor("ON") .. L["ENABLED"] .. "|r")
		or (GetColor("OFF") .. L["DISABLED"] .. "|r")
	tooltip:AddDoubleLine(GetColor("TITLE") .. L["FARM_MODE"] .. "|r", farmState)
	tooltip:AddLine(GetColor("BODY") .. L["FARM_MODE_DESCRIPTION"] .. "|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(GetColor("INFO") .. L["SHIFT_LEFT"] .. "|r", GetColor("INFO") .. L["TOGGLE"] .. "|r")
	tooltip:AddLine(" ")

	--[[
        Only while Farm Mode is enabled: with it off there is nothing to report,
        and the Farm Mode block above already shows Disabled.
    ]]
	if ns.db and ns.db.profile.farmMode then
		-- Drawn before it shows, so the live own-tooltip check can't see this tooltip yet: pass it in.
		local pauseReason, pauseState
		if ns.GetFarmPauseReason then
			pauseReason, pauseState = ns.GetFarmPauseReason(true)
		end
		-- Gray for paused, matching the house three-way: OFF red, paused gray, ON green.
		local statusText = pauseReason and (GetColor("SEPARATOR") .. L["FARM_STATUS_PAUSED"] .. "|r")
			or (GetColor("ON") .. L["FARM_STATUS_ACTIVE"] .. "|r")
		tooltip:AddDoubleLine(GetColor("TITLE") .. L["FARM_STATUS"] .. "|r", statusText)
		if pauseReason then
			tooltip:AddLine(
				GetColor("BODY") .. ns.FormatFarmPauseReason(pauseReason, pauseState) .. "|r",
				1,
				1,
				1,
				true
			)
		end
		tooltip:AddLine(" ")
	end

	-- Draws on every character, as its options section does. A running hunt isn't named: the icon already shows it.
	local targetState = (ns.db and ns.db.profile.targetTracking) and (GetColor("ON") .. L["ENABLED"] .. "|r")
		or (GetColor("OFF") .. L["DISABLED"] .. "|r")
	tooltip:AddDoubleLine(GetColor("TITLE") .. L["TARGET_TRACKING"] .. "|r", targetState)
	tooltip:AddLine(GetColor("BODY") .. L["TARGET_TRACKING_DESCRIPTION"] .. "|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(GetColor("INFO") .. L["SHIFT_RIGHT"] .. "|r", GetColor("INFO") .. L["TOGGLE"] .. "|r")
	tooltip:AddLine(" ")

	tooltip:AddLine(GetColor("TITLE") .. L["TOOLTIP_OPTIONS"] .. "|r")
	tooltip:AddLine(GetColor("INFO") .. L["SHIFT_MIDDLE"] .. "|r")
end

function ns.RefreshTooltip()
	local function TryRefresh(frame)
		if frame and frame:IsVisible() then
			if frame:IsMouseOver() or GameTooltip:GetOwner() == frame then
				local onEnter = frame:GetScript("OnEnter")
				if onEnter then
					GameTooltip:Hide()
					onEnter(frame)
				end
			end
		end
	end

	if ns.freeFrame then
		TryRefresh(ns.freeFrame)
	end

	local minimapButton = LibDBIcon:GetMinimapButton(ADDON_NAME)
	if minimapButton then
		TryRefresh(minimapButton)
	end
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------

-- Shared by the mini-map button and the free-placement frame (Free-Placement.lua).
function ns.HandleLauncherClick(self, button)
	--[[
        Shift + Middle-Click always opens the options panel. This runs first,
        before the ns.db guard, so it works regardless of saved-variable state
        (the same behavior in every add-on). Free Placement Mode is toggled from
        the options panel, not here.
    ]]
	if IsShiftKeyDown() and button == "MiddleButton" then
		ns:OpenOptionsPanel()
		return
	end

	if not ns.db then
		return
	end

	local updateNeeded = false

	if IsShiftKeyDown() then
		if button == "LeftButton" then
			ns.db.profile.farmMode = not ns.db.profile.farmMode
			updateNeeded = true
		elseif button == "RightButton" then
			ns.SetTargetTracking(not ns.db.profile.targetTracking)
			updateNeeded = true
		end
		-- Both toggles are settings, so an options panel already on screen redraws with the new value.
		if updateNeeded and ns.RefreshOptionsPanels then
			ns.RefreshOptionsPanels()
		end
	else
		if button == "LeftButton" then
			ns.ToggleMenu(self)
		elseif button == "RightButton" then
			ns.ClearTracking()
			updateNeeded = true
		end
	end

	if updateNeeded then
		ns.RefreshTooltip()
	end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitMinimap()
	ns.ldb = LibDataBroker:NewDataObject(ADDON_NAME, {
		type = "launcher",
		icon = ns.state.currentIcon or ns.ICON_DEFAULT,
		OnClick = ns.HandleLauncherClick,
		OnTooltipShow = function(tooltip)
			ns.BuildTooltip(tooltip)
		end,
	})

	if ns.db and ns.db.global.minimap then
		LibDBIcon:Register(ADDON_NAME, ns.ldb, ns.db.global.minimap)

		if ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline" then
			LibDBIcon:SetButtonIcon(ADDON_NAME, nil, 20, "CENTER", 1, -0.35)
			local fitButton = LibDBIcon:GetMinimapButton(ADDON_NAME)
			local mask = fitButton:CreateMaskTexture()
			mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
			mask:SetAllPoints(fitButton.icon)
			fitButton.icon:AddMaskTexture(mask)
		end
	end

	local button = LibDBIcon:GetMinimapButton(ADDON_NAME)
	-- Kept so ns.IsOwnTooltipShowing can tell our own tooltip from everyone else's.
	ns.minimapButton = button
	if button then
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT")
			ns.BuildTooltip(GameTooltip)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end

	ns.UpdatePlacement()
	ns.ApplyBlizzardTrackingHook()
end
