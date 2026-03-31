local addonName, te = ...
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Visuals & Placement
--------------------------------------------------------------------------------
function te.UpdateFreeFrameScale()
    if te.freeFrame then
        local scale = (TrackingEyeGlobalDB and TrackingEyeGlobalDB.freeIconScale) or te.FREE_ICON_SCALE_DEFAULT
        te.freeFrame:SetScale(scale)
    end
end

function te.UpdateFreeFrameShape()
    if not te.freeFrame then
        return
    end
    local shape = (TrackingEyeGlobalDB and TrackingEyeGlobalDB.freeIconShape) or te.FREE_ICON_SHAPE_DEFAULT
    local isSquare = (shape == te.SHAPES.SQUARE)

    te.freeFrame.circleBg:SetShown(not isSquare)
    te.freeFrame.circleBorder:SetShown(not isSquare)
    te.freeFrame.squareBg:SetShown(isSquare)
    te.freeFrame.squareBorder:SetShown(isSquare)
end

function te.UpdatePlacement()
    if not TrackingEyeGlobalDB then
        return
    end

    if not te.HasTrackingAbility() then
        if te.freeFrame then
            te.freeFrame:Hide()
        end
        LDBIcon:Hide(addonName)
        return
    end

    if TrackingEyeGlobalDB.freePlacement then
        TrackingEyeGlobalDB.minimap.hide = true
        LDBIcon:Hide(addonName)
        if te.freeFrame then
            te.freeFrame:Show()
        end
    else
        TrackingEyeGlobalDB.minimap.hide = false
        LDBIcon:Show(addonName)
        if te.freeFrame then
            te.freeFrame:Hide()
        end
    end

    te.UpdateFreeFrameScale()
    te.UpdateFreeFrameShape()
end

function te.BuildTooltip(tooltip)
    -- Header
    tooltip:AddDoubleLine(te.GetColor("TITLE") .. te.L["ADDON_TITLE"] .. "|r", te.GetColor("MUTED") .. te.Version .. "|r")
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")

    -- Tracking Menu
    tooltip:AddLine(te.GetColor("TITLE") .. te.L["TRACKING_MENU"] .. "|r")
    tooltip:AddLine(te.GetColor("DESC") .. te.L["TRACKING_MENU_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddLine(te.GetColor("INFO") .. te.L["LEFT_CLICK"] .. "|r")
    tooltip:AddLine(" ")

    -- Persistent Tracking Ability
    tooltip:AddLine(te.GetColor("TITLE") .. te.L["PERSISTENT_ABILITY"] .. "|r")
    local selectedSpellId = TrackingEyeDB and TrackingEyeDB.selectedSpellId
    if selectedSpellId then
        local name = te.GetSpellName(selectedSpellId) or "Unknown"
        tooltip:AddLine("|T" .. (GetSpellTexture(selectedSpellId) or "") .. ":16|t " .. te.GetColor("TEXT") .. name .. "|r")
    else
        tooltip:AddLine("|TInterface\\Icons\\inv_misc_map_01:16|t " .. te.GetColor("DESC") .. te.L["NONE_SET"] .. "|r")
    end
    tooltip:AddDoubleLine(
        te.GetColor("INFO") .. te.L["RIGHT_CLICK"] .. "|r",
        te.GetColor("INFO") .. te.L["CLEAR_TRACKING"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Persistent Tracking Toggle
    local persistentState =
        (TrackingEyeDB and TrackingEyeDB.autoTracking) and (te.GetColor("SUCCESS") .. te.L["ENABLED"] .. "|r") or
        (te.GetColor("DISABLED") .. te.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(te.GetColor("TITLE") .. te.L["PERSISTENT_TRACKING"] .. "|r", persistentState)
    tooltip:AddLine(te.GetColor("DESC") .. te.L["PERSISTENT_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(
        te.GetColor("INFO") .. te.L["SHIFT_LEFT"] .. "|r",
        te.GetColor("INFO") .. te.L["TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Farm Mode Toggle
    local farmState =
        (TrackingEyeDB and TrackingEyeDB.farmingMode) and (te.GetColor("SUCCESS") .. te.L["ENABLED"] .. "|r") or
        (te.GetColor("DISABLED") .. te.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(te.GetColor("TITLE") .. te.L["FARM_MODE"] .. "|r", farmState)
    tooltip:AddLine(te.GetColor("DESC") .. te.L["FARMING_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(
        te.GetColor("INFO") .. te.L["SHIFT_RIGHT"] .. "|r",
        te.GetColor("INFO") .. te.L["TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Free Placement Mode
    local freePlacementState =
        (TrackingEyeGlobalDB and TrackingEyeGlobalDB.freePlacement) and
        (te.GetColor("SUCCESS") .. te.L["ENABLED"] .. "|r") or
        (te.GetColor("DISABLED") .. te.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(te.GetColor("TITLE") .. te.L["PLACEMENT_MODE"] .. "|r", freePlacementState)
    tooltip:AddLine(te.GetColor("DESC") .. te.L["PLACEMENT_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(
        te.GetColor("INFO") .. te.L["SHIFT_MIDDLE"] .. "|r",
        te.GetColor("INFO") .. te.L["TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")
    tooltip:AddLine(te.GetColor("DESC") .. te.L["TOOLTIP_OPTIONS_HINT"] .. "|r", 1, 1, 1, true)
end

function te.RefreshTooltip()
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

    if te.freeFrame then
        TryRefresh(te.freeFrame)
    end

    local minimapButton = LDBIcon:GetMinimapButton(addonName)
    if minimapButton then
        TryRefresh(minimapButton)
    end
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------
local function OnClick(self, button)
    if not TrackingEyeDB then
        return
    end

    local updateNeeded = false

    if IsShiftKeyDown() then
        if button == "MiddleButton" then
            if TrackingEyeGlobalDB then
                TrackingEyeGlobalDB.freePlacement = not TrackingEyeGlobalDB.freePlacement
                te.UpdatePlacement()
                updateNeeded = true
            end
        elseif button == "LeftButton" then
            TrackingEyeDB.autoTracking = not TrackingEyeDB.autoTracking
            updateNeeded = true
        elseif button == "RightButton" then
            TrackingEyeDB.farmingMode = not TrackingEyeDB.farmingMode
            updateNeeded = true
        end
    else
        if button == "LeftButton" then
            te.ToggleMenu(self)
        elseif button == "RightButton" then
            te.ClearTracking()
            updateNeeded = true
        end
    end

    if updateNeeded then
        te.RefreshTooltip()
    end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function te.CreateFreeFrame()
    local frame = CreateFrame("Button", addonName .. "FreeFrame", UIParent)
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
    frame:SetScript(
        "OnDragStop",
        function(self)
            self:StopMovingOrSizing()
            local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
            if TrackingEyeGlobalDB then
                TrackingEyeGlobalDB.freePos = {point, relativePoint, xOffset, yOffset}
            end
        end
    )
    frame:SetScript("OnClick", OnClick)
    frame:SetScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            te.BuildTooltip(GameTooltip)
            GameTooltip:Show()
        end
    )
    frame:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )

    if TrackingEyeGlobalDB and TrackingEyeGlobalDB.freePos then
        local position = TrackingEyeGlobalDB.freePos
        frame:SetPoint(position[1], UIParent, position[2], position[3], position[4])
    else
        frame:SetPoint("CENTER")
    end

    te.freeFrame = frame
    te.UpdatePlacement()
end

function te.InitMinimap()
    te.ldb =
        LDB:NewDataObject(
        addonName,
        {
            type = "launcher",
            icon = te.state.currentIcon or te.ICON_DEFAULT,
            OnClick = OnClick,
            OnTooltipShow = function(tooltip)
                te.BuildTooltip(tooltip)
            end
        }
    )

    if TrackingEyeGlobalDB and TrackingEyeGlobalDB.minimap then
        LDBIcon:Register(addonName, te.ldb, TrackingEyeGlobalDB.minimap)
    end

    local button = LDBIcon:GetMinimapButton(addonName)
    if button then
        button:SetScript(
            "OnEnter",
            function(self)
                GameTooltip:SetOwner(self, "ANCHOR_NONE")
                GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT")
                te.BuildTooltip(GameTooltip)
                GameTooltip:Show()
            end
        )
        button:SetScript(
            "OnLeave",
            function()
                GameTooltip:Hide()
            end
        )
    end

    te.UpdatePlacement()
end