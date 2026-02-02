local addonName, te = ...
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

TrackingEyeDB = TrackingEyeDB or {}
TrackingEyeGlobalDB = TrackingEyeGlobalDB or {}
TrackingEyeGlobalDB.minimap = TrackingEyeGlobalDB.minimap or {}

--------------------------------------------------------------------------------
-- Visuals & Placement
--------------------------------------------------------------------------------
function te.UpdatePlacement()
    if not TrackingEyeGlobalDB then return end
    
    -- If player knows no tracking spells, hide everything
    if not te.HasTrackingAbility() then
        if te.freeFrame then te.freeFrame:Hide() end
        LDBIcon:Hide(addonName)
        return
    end
    
    if TrackingEyeGlobalDB.freePlacement then
        TrackingEyeGlobalDB.minimap.hide = true
        LDBIcon:Hide(addonName)
        if te.freeFrame then te.freeFrame:Show() end
    else
        TrackingEyeGlobalDB.minimap.hide = false
        LDBIcon:Show(addonName)
        if te.freeFrame then te.freeFrame:Hide() end
    end
end

function te.BuildTooltip(tooltip)
    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Dev"
    
    -- Header
    tooltip:AddDoubleLine(te.GetColor("TITLE") .. te.L["ADDON_TITLE"] .. "|r", te.GetColor("MUTED") .. version .. "|r")
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")

    -- Tracking Menu
    tooltip:AddLine(te.GetColor("TITLE") .. te.L["TRACKING_MENU"] .. "|r")
    tooltip:AddLine(te.GetColor("DESC") .. te.L["TRACKING_MENU_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddLine(te.GetColor("INFO") .. te.L["LEFT_CLICK"] .. "|r")
    tooltip:AddLine(" ")

    -- Persistent Tracking Ability
    tooltip:AddLine(te.GetColor("TITLE") .. te.L["PERSISTENT_ABILITY"] .. "|r")
    local displayID = TrackingEyeDB.selectedSpellId
    if displayID then
        local name = te.GetSpellName(displayID) or "Unknown"
        tooltip:AddLine("|T" .. (GetSpellTexture(displayID) or "") .. ":16|t " .. te.GetColor("TEXT") .. name .. "|r")
    else
        tooltip:AddLine("|TInterface\\Icons\\inv_misc_map_01:16|t " .. te.GetColor("DESC") .. te.L["NONE_SET"] .. "|r")
    end
    
    tooltip:AddDoubleLine(te.GetColor("INFO") .. te.L["RIGHT_CLICK"] .. "|r", te.GetColor("INFO") .. te.L["CLEAR_TRACKING"] .. "|r")
    tooltip:AddLine(" ")

    -- Persistent Tracking Toggle
    local pState = TrackingEyeDB.autoTracking and (te.GetColor("SUCCESS") .. te.L["ENABLED"] .. "|r") or (te.GetColor("DISABLED") .. te.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(te.GetColor("TITLE") .. te.L["PERSISTENT_TRACKING"] .. "|r", pState)
    tooltip:AddLine(te.GetColor("DESC") .. te.L["PERSISTENT_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(te.GetColor("INFO") .. te.L["SHIFT_LEFT"] .. "|r", te.GetColor("INFO") .. te.L["TOGGLE"] .. "|r")
    tooltip:AddLine(" ")

    -- Farming Mode Toggle
    local fState = TrackingEyeDB.farmingMode and (te.GetColor("SUCCESS") .. te.L["ENABLED"] .. "|r") or (te.GetColor("DISABLED") .. te.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(te.GetColor("TITLE") .. te.L["FARMING_MODE"] .. "|r", fState)
    tooltip:AddLine(te.GetColor("DESC") .. te.L["FARMING_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(te.GetColor("INFO") .. te.L["SHIFT_RIGHT"] .. "|r", te.GetColor("INFO") .. te.L["TOGGLE"] .. "|r")
    tooltip:AddLine(" ")

    -- Free Placement Mode
    local fpState = TrackingEyeGlobalDB.freePlacement and (te.GetColor("SUCCESS") .. te.L["ENABLED"] .. "|r") or (te.GetColor("DISABLED") .. te.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(te.GetColor("TITLE") .. te.L["PLACEMENT_MODE"] .. "|r", fpState)
    tooltip:AddLine(te.GetColor("DESC") .. te.L["PLACEMENT_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(te.GetColor("INFO") .. te.L["SHIFT_MIDDLE"] .. "|r", te.GetColor("INFO") .. te.L["TOGGLE"] .. "|r")
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

    if te.freeFrame then TryRefresh(te.freeFrame) end
    
    local minimapBtn = LDBIcon:GetMinimapButton(addonName)
    if minimapBtn then TryRefresh(minimapBtn) end
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------
local function OnClick(self, button)
    local updateNeeded = false
    
    if IsShiftKeyDown() then
        if button == "MiddleButton" then
            TrackingEyeGlobalDB.freePlacement = not TrackingEyeGlobalDB.freePlacement
            te.UpdatePlacement()
            updateNeeded = true
        elseif button == "LeftButton" then
            TrackingEyeDB.autoTracking = not TrackingEyeDB.autoTracking
            updateNeeded = true
        elseif button == "RightButton" then
            TrackingEyeDB.farmingMode = not TrackingEyeDB.farmingMode
            updateNeeded = true
        end
    else
        -- Non-Shift Clicks
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
    local f = CreateFrame("Button", addonName .. "FreeFrame", UIParent)
    f:SetSize(37, 37)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:RegisterForClicks("AnyUp")
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    f.bg:SetSize(24, 24)
    f.bg:SetPoint("CENTER")
    f.bg:SetVertexColor(0, 0, 0, 0.6)
    
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(24, 24)
    f.icon:SetPoint("CENTER")
    
    f.border = f:CreateTexture(nil, "OVERLAY")
    f.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    f.border:SetSize(62, 62)
    f.border:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local p, _, rp, x, y = self:GetPoint()
        TrackingEyeGlobalDB.freePos = {p, rp, x, y}
    end)
    f:SetScript("OnClick", OnClick)
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        te.BuildTooltip(GameTooltip)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    if TrackingEyeGlobalDB.freePos then
        local p = TrackingEyeGlobalDB.freePos
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        f:SetPoint("CENTER")
    end
    te.freeFrame = f
    te.UpdatePlacement()
end

function te.InitMinimap()
    te.ldb = LDB:NewDataObject(addonName, {
        type = "launcher",
        icon = te.state.currentIcon or te.ICON_DEFAULT,
        OnClick = OnClick,
        OnTooltipShow = function(tt) te.BuildTooltip(tt) end
    })
    
    LDBIcon:Register(addonName, te.ldb, TrackingEyeGlobalDB.minimap)
    
    -- Custom anchor logic for the minimap button
    local btn = LDBIcon:GetMinimapButton(addonName)
    if btn then
        btn:SetScript("OnEnter", function(self)
            -- Anchor Top-Right of Tooltip to Bottom-Left of Button
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT")
            te.BuildTooltip(GameTooltip)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    te.UpdatePlacement()
end