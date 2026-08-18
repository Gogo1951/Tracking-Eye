local ADDON_NAME, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Free Frame Position
--------------------------------------------------------------------------------

--[[
    Position is stored in *absolute screen pixels* — `freePos.x` and
    `freePos.y` are the frame's center expressed at scale 1.0. Restore
    divides by the frame's current effective scale to convert back into
    the frame's own coordinate space (which is what SetPoint offsets are
    measured in). This makes the saved position survive UI-scale changes
    and Free Placement icon-scale changes without drifting.
]]
local function SaveFreePosition(frame)
	if not ns.db or not frame then
		return
	end
	local x, y = frame:GetCenter()
	if not x or not y then
		return
	end
	local scale = frame:GetEffectiveScale()
	ns.db.global.freePos = { x = x * scale, y = y * scale }
end

local function ApplyFreePosition(frame)
	if not frame then
		return
	end
	local pos = ns.db and ns.db.global.freePos

	frame:ClearAllPoints()
	if type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number" then
		local scale = frame:GetEffectiveScale()
		frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x / scale, pos.y / scale)
	else
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
	--[[
        Clear user-placed even on plain restore. WoW silently flags any
        frame that has been moved with StartMoving/StopMovingOrSizing as
        user-placed for the rest of the session, and a stale flag can
        cause the client to write a layout-local entry on logout that
        out-races our SavedVariables on next login.
    ]]
	frame:SetUserPlaced(false)
end

--[[
    Backstop only — OnDragStop already saves after every drag. Bail unless the
    frame is shown, because a hidden frame is never re-anchored: UpdatePlacement
    returns early for characters with no tracking ability, skipping the
    ApplyFreePosition that reconciles the frame with UIParent's settled effective
    scale. Saving one then re-encodes stale offsets against the live scale and
    writes a drifted freePos — which is account-wide, so it moves the icon for
    every character. A never-dragged frame is likewise hidden, so this also stops
    logout from materializing a freePos the player never set.
]]
ns.SaveFreeFramePosition = function()
	if not ns.freeFrame or not ns.freeFrame:IsShown() then
		return
	end
	SaveFreePosition(ns.freeFrame)
end

--------------------------------------------------------------------------------
-- Visuals & Placement
--------------------------------------------------------------------------------
function ns.UpdateFreeFrameScale()
	if ns.freeFrame then
		local scale = (ns.db and ns.db.global.freeIconScale) or ns.DATABASE_DEFAULTS.global.freeIconScale
		ns.freeFrame:SetScale(scale)
		--[[
            SetPoint offsets are interpreted in the frame's *own* scale.
            After a scale change those offsets resolve to a different
            screen position, so the frame visually drifts. Re-applying
            the position immediately after SetScale converts our stored
            absolute-pixel coords back into the new scale and pins the
            frame to its true location.
        ]]
		ApplyFreePosition(ns.freeFrame)
	end
end

function ns.UpdateFreeFrameShape()
	if not ns.freeFrame then
		return
	end
	local shape = (ns.db and ns.db.global.freeIconShape) or ns.DATABASE_DEFAULTS.global.freeIconShape
	local isSquare = (shape == ns.SHAPES.SQUARE)

	ns.freeFrame.circleBg:SetShown(not isSquare)
	ns.freeFrame.circleBorder:SetShown(not isSquare)
	ns.freeFrame.squareBg:SetShown(isSquare)
	ns.freeFrame.squareBorder:SetShown(isSquare)
end

function ns.UpdatePlacement()
	if not ns.db then
		return
	end

	if not ns.HasTrackingAbility() then
		if ns.freeFrame then
			ns.freeFrame:Hide()
		end
		LDBIcon:Hide(ADDON_NAME)
		return
	end

	if not ns.db.global.minimap then
		ns.db.global.minimap = {}
	end

	if ns.db.global.freePlacement then
		--[[
            Free frame replaces the minimap button. Hide the button without
            touching the saved Enable Mini-map Button preference
            (ns.db.global.minimap.hide), so the preference survives a Free
            Placement round-trip.
        ]]
		LDBIcon:Hide(ADDON_NAME)
		if ns.freeFrame then
			--[[
                Re-apply position on every show. Defends against any
                other code path (LibDBIcon callbacks, addon-on-addon
                conflicts, layout-local replay) that might have
                silently re-anchored the frame while it was hidden.
            ]]
			ApplyFreePosition(ns.freeFrame)
			ns.freeFrame:Show()
		end
	else
		if ns.freeFrame then
			ns.freeFrame:Hide()
		end
		-- Honor the Enable Mini-map Button preference (minimap.hide, inverted).
		if ns.db.global.minimap.hide then
			LDBIcon:Hide(ADDON_NAME)
		else
			LDBIcon:Show(ADDON_NAME)
		end
	end

	ns.UpdateFreeFrameScale()
	ns.UpdateFreeFrameShape()
end

function ns.BuildTooltip(tooltip)
	tooltip:AddDoubleLine(GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r", GetColor("MUTED") .. ns.Version .. "|r")
	tooltip:AddLine(" ")
	tooltip:AddLine(" ")

	--[[
        Farm Mode status leads the tooltip because it is the only block that
        answers "why is nothing happening?". It appears only while Farm Mode is
        enabled — with the feature off the section has nothing to report, and the
        Farm Mode block further down already shows Disabled.
    ]]
	if ns.db and ns.db.profile.farmMode then
		local pauseReason = ns.GetFarmPauseReason and ns.GetFarmPauseReason()
		-- Gray for paused, matching the house three-way: OFF red, paused gray, ON green.
		local statusText = pauseReason and (GetColor("SEPARATOR") .. L["FARM_STATUS_PAUSED"] .. "|r")
			or (GetColor("ON") .. L["FARM_STATUS_ACTIVE"] .. "|r")
		tooltip:AddDoubleLine(GetColor("TITLE") .. L["FARM_STATUS"] .. "|r", statusText)
		if pauseReason then
			tooltip:AddLine(GetColor("BODY") .. L[pauseReason] .. "|r", 1, 1, 1, true)
		end
		tooltip:AddLine(" ")
	end

	tooltip:AddLine(GetColor("TITLE") .. L["TRACKING_MENU"] .. "|r")
	tooltip:AddLine(GetColor("BODY") .. L["TRACKING_MENU_DESC"] .. "|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(GetColor("INFO") .. L["LEFT_CLICK"] .. "|r", GetColor("INFO") .. L["OPEN"] .. "|r")
	tooltip:AddLine(" ")

	--[[
        Label and ability share one row, matching the Farm Mode Status block and
        the house pattern of feature name on the left, its current value on the
        right. The icon travels with the name so the pair never splits.
    ]]
	local selectedSpellId = ns.db and ns.db.profile.selectedSpellId
	local abilityText
	if selectedSpellId then
		local name = GetSpellInfo(selectedSpellId) or L["NONE_SET"]
		abilityText = "|T"
			.. (GetSpellTexture(selectedSpellId) or ns.ICON_DEFAULT)
			.. ":16|t "
			.. GetColor("TEXT")
			.. name
			.. "|r"
	else
		abilityText = "|T" .. ns.ICON_DEFAULT .. ":16|t " .. GetColor("BODY") .. L["NONE_SET"] .. "|r"
	end
	tooltip:AddDoubleLine(GetColor("TITLE") .. L["PERSISTENT_ABILITY"] .. "|r", abilityText)
	tooltip:AddDoubleLine(GetColor("INFO") .. L["RIGHT_CLICK"] .. "|r", GetColor("INFO") .. L["CLEAR_TRACKING"] .. "|r")
	tooltip:AddLine(" ")

	local persistentState = (ns.db and ns.db.profile.persistentTracking) and (GetColor("ON") .. L["ENABLED"] .. "|r")
		or (GetColor("OFF") .. L["DISABLED"] .. "|r")
	tooltip:AddDoubleLine(GetColor("TITLE") .. L["PERSISTENT_TRACKING"] .. "|r", persistentState)
	tooltip:AddLine(GetColor("BODY") .. L["PERSISTENT_DESC"] .. "|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(GetColor("INFO") .. L["SHIFT_LEFT"] .. "|r", GetColor("INFO") .. L["TOGGLE"] .. "|r")
	tooltip:AddLine(" ")

	--[[
        Status-only teaser: name and state, no description and no click hint. These
        rows surface settings that live in the options panel rather than offering to
        operate them from here, and each follows the feature it belongs to. Each one
        draws only while its setting is actually reachable, so the tooltip never
        advertises something the player cannot act on — this one needs Persistent
        Tracking on and a character that can track at least one creature type,
        exactly what the options section hides on.
    ]]
	if ns.db and ns.db.profile.persistentTracking and ns.HasCreatureTypeTracking and ns.HasCreatureTypeTracking() then
		local targetState = ns.db.profile.targetTracking and (GetColor("ON") .. L["ENABLED"] .. "|r")
			or (GetColor("OFF") .. L["DISABLED"] .. "|r")
		tooltip:AddDoubleLine(GetColor("TITLE") .. L["OPTIONS_TARGET_TRACKING"] .. "|r", targetState)
		tooltip:AddLine(GetColor("BODY") .. L["OPTIONS_TARGET_TRACKING_DESC"] .. "|r", 1, 1, 1, true)
		tooltip:AddLine(" ")
	end

	local farmState = (ns.db and ns.db.profile.farmMode) and (GetColor("ON") .. L["ENABLED"] .. "|r")
		or (GetColor("OFF") .. L["DISABLED"] .. "|r")
	tooltip:AddDoubleLine(GetColor("TITLE") .. L["FARM_MODE"] .. "|r", farmState)
	tooltip:AddLine(GetColor("BODY") .. L["FARM_MODE_DESC"] .. "|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(GetColor("INFO") .. L["SHIFT_RIGHT"] .. "|r", GetColor("INFO") .. L["TOGGLE"] .. "|r")
	tooltip:AddLine(" ")

	-- Second status-only teaser; hides with Farm Mode, matching its options row.
	if ns.db and ns.db.profile.farmMode then
		local muteState = ns.db.profile.muteCycleSound and (GetColor("ON") .. L["ENABLED"] .. "|r")
			or (GetColor("OFF") .. L["DISABLED"] .. "|r")
		tooltip:AddDoubleLine(GetColor("TITLE") .. L["SILENCE_TRACKING_SOUNDS"] .. "|r", muteState)
		tooltip:AddLine(GetColor("BODY") .. L["SILENCE_TRACKING_SOUNDS_DESC"] .. "|r", 1, 1, 1, true)
		tooltip:AddLine(" ")
	end

	-- Options (Shift + Middle-Click opens the options panel)
	tooltip:AddLine(GetColor("TITLE") .. L["TOOLTIP_OPTIONS"] .. "|r")
	tooltip:AddLine(GetColor("INFO") .. L["SHIFT_MIDDLE"] .. "|r")
end

function ns.RefreshTooltip()
	local function TryRefresh(frame)
		if frame and frame:IsVisible() then
			if MouseIsOver(frame) or GameTooltip:GetOwner() == frame then
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

	local minimapButton = LDBIcon:GetMinimapButton(ADDON_NAME)
	if minimapButton then
		TryRefresh(minimapButton)
	end
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------
local function OnClick(self, button)
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
			ns.db.profile.persistentTracking = not ns.db.profile.persistentTracking
			updateNeeded = true
		elseif button == "RightButton" then
			ns.db.profile.farmMode = not ns.db.profile.farmMode
			updateNeeded = true
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
-- Blizzard Tracking Button Hook
--------------------------------------------------------------------------------

--[[
    Optional take-over of Blizzard's own mini-map tracking icon, which is inert on
    these clients. Off by default: it reaches into a frame the add-on does not own,
    and some UIs already bind that button.

    Take-over rather than HookScript, because a hook would leave Blizzard's handler
    running and open two menus at once. Exactly ONE script is replaced — OnClick
    where the widget supports it, OnMouseUp otherwise — since replacing both fires
    the handler twice on a single click, which opens the menu and immediately
    closes it again. The original is saved so turning the option off puts the frame
    back exactly as found. Neither frame is secure or protected on Classic Era or
    TBC Anniversary, so replacing their scripts raises no taint.
]]
local blizzardHookedScript = nil
local blizzardSavedHandler = nil

local function GetBlizzardTrackingButton()
	return MiniMapTrackingButton or MiniMapTracking
end

function ns.HasBlizzardTrackingButton()
	return GetBlizzardTrackingButton() ~= nil
end

function ns.ApplyBlizzardTrackingHook()
	local button = GetBlizzardTrackingButton()
	if not button or not button.SetScript or not button.HasScript then
		return
	end

	local enabled = ns.db and ns.db.global.hookBlizzardTracking or false

	if enabled and not blizzardHookedScript then
		local scriptName = (button:HasScript("OnClick") and "OnClick")
			or (button:HasScript("OnMouseUp") and "OnMouseUp")
			or nil
		if not scriptName then
			return
		end
		blizzardHookedScript = scriptName
		blizzardSavedHandler = button:GetScript(scriptName)
		button:SetScript(scriptName, function()
			ns.ToggleMenu(button)
		end)
	elseif not enabled and blizzardHookedScript then
		button:SetScript(blizzardHookedScript, blizzardSavedHandler)
		blizzardHookedScript = nil
		blizzardSavedHandler = nil
	end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function ns.CreateFreeFrame()
	--[[
        Anonymous frame (nil name) on purpose: WoW's per-character layout-local
        cache keys on frame name and would apply a cached position over our
        account-wide freePos (SetUserPlaced(false) doesn't prevent the lookup).
        No name removes the frame from that system, so freePos owns placement.
    ]]
	local frame = CreateFrame("Button", nil, UIParent)
	frame:SetSize(37, 37)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:RegisterForClicks("AnyUp")
	frame:SetClampedToScreen(true)
	frame:SetFrameStrata("HIGH")

	-- Circle elements
	frame.circleBg = frame:CreateTexture(nil, "BACKGROUND")
	frame.circleBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	frame.circleBg:SetSize(24, 24)
	frame.circleBg:SetPoint("CENTER")
	frame.circleBg:SetVertexColor(0, 0, 0, 0.6)

	frame.circleBorder = frame:CreateTexture(nil, "OVERLAY")
	frame.circleBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	frame.circleBorder:SetSize(62, 62)
	frame.circleBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

	-- Square elements
	frame.squareBorder = frame:CreateTexture(nil, "BACKGROUND")
	frame.squareBorder:SetColorTexture(0, 0, 0, 0.8)
	frame.squareBorder:SetSize(27, 27)
	frame.squareBorder:SetPoint("CENTER")

	frame.squareBg = frame:CreateTexture(nil, "BACKGROUND")
	frame.squareBg:SetColorTexture(0, 0, 0, 0)
	frame.squareBg:SetSize(1, 1)
	frame.squareBg:SetPoint("CENTER")

	-- Shared icon
	frame.icon = frame:CreateTexture(nil, "ARTWORK")
	frame.icon:SetSize(24, 24)
	frame.icon:SetPoint("CENTER")

	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		--[[
                StartMoving / StopMovingOrSizing implicitly flag the
                frame as user-placed. Clear the flag so WoW does not
                write a layout-local entry that out-races our
                SavedVariables on next login.
            ]]
		self:SetUserPlaced(false)
		SaveFreePosition(self)
		--[[
                Re-anchor immediately. After a drag the live anchor is
                whatever WoW chose during the move, which is not the
                stable CENTER -> UIParent BOTTOMLEFT anchor we
                serialize. Normalizing now means a Show/Hide cycle or a
                scale change does not shift the icon.
            ]]
		ApplyFreePosition(self)
	end)
	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		ns.BuildTooltip(GameTooltip)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	ns.freeFrame = frame
	--[[
        ApplyFreePosition does its own ClearAllPoints and pins the frame
        to its saved screen-pixel coordinates via the stable
        CENTER -> UIParent BOTTOMLEFT anchor.
    ]]
	ApplyFreePosition(frame)
	ns.UpdatePlacement()
end

function ns.InitMinimap()
	ns.ldb = LDB:NewDataObject(ADDON_NAME, {
		type = "launcher",
		icon = ns.state.currentIcon or ns.ICON_DEFAULT,
		OnClick = OnClick,
		OnTooltipShow = function(tooltip)
			ns.BuildTooltip(tooltip)
		end,
	})

	if ns.db and ns.db.global.minimap then
		LDBIcon:Register(ADDON_NAME, ns.ldb, ns.db.global.minimap)
	end

	local button = LDBIcon:GetMinimapButton(ADDON_NAME)
	-- Kept so ns.IsTooltipShowing can tell our own tooltip from everyone else's.
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
