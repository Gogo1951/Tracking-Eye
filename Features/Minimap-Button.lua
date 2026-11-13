local ADDON_NAME, ns = ...
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Placement
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

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------

--[[
    Shared by the mini-map button and the free-placement frame (Free-Placement.lua).
    Hovering opens the menu (Minimap-Menu.lua); a left-click opens it with the
    Persistent Tracking flyout out, so picking an ability stays one click. No other
    button and no modifier does anything: every action lives in the menu, where a
    controller's cursor can reach it.
]]
function ns.HandleLauncherClick(self, button)
	if button == "LeftButton" then
		ns.ShowMenu(self, "persistent", "click")
	end
end

function ns.HandleLauncherEnter(self)
	ns.ShowMenu(self, nil, "hover")
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.InitMinimap()
	ns.ldb = LibDataBroker:NewDataObject(ADDON_NAME, {
		type = "launcher",
		icon = ns.state.currentIcon or ns.ICON_DEFAULT,
		OnClick = ns.HandleLauncherClick,
		--[[
			OnEnter rather than OnTooltipShow: LibDBIcon and every LDB display call
			it on hover, and the menu closes itself once the cursor leaves, so
			OnLeave has nothing to do.
		]]
		OnEnter = ns.HandleLauncherEnter,
		OnLeave = function() end,
	})

	if ns.db and ns.db.global.minimap then
		LibDBIcon:Register(ADDON_NAME, ns.ldb, ns.db.global.minimap)

		-- Fitted by hand, not SetButtonIcon: its ResetButtonIcon calls icon:UpdateCoord(),
		-- which errors when another add-on has replaced the button's icon.
		local fitButton = LibDBIcon:GetMinimapButton(ADDON_NAME)
		if (ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline") and fitButton and fitButton.icon then
			fitButton.icon:SetSize(20, 20)
			fitButton.icon:ClearAllPoints()
			fitButton.icon:SetPoint("CENTER", 1, -0.35)
			local mask = fitButton:CreateMaskTexture()
			mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
			mask:SetAllPoints(fitButton.icon)
			fitButton.icon:AddMaskTexture(mask)
		end
	end

	ns.UpdatePlacement()
	ns.ApplyBlizzardTrackingHook()
end
