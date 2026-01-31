local addonName, ns = ...
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

TrackingEyeDB = TrackingEyeDB or {}
TrackingEyeGlobalDB = TrackingEyeGlobalDB or {}
TrackingEyeGlobalDB.minimap = TrackingEyeGlobalDB.minimap or {}

--------------------------------------------------------------------------------
-- Visuals & Placement
--------------------------------------------------------------------------------
function ns.UpdatePlacement()
    if not TrackingEyeGlobalDB then return end
    
    if TrackingEyeGlobalDB.freePlacement then
        TrackingEyeGlobalDB.minimap.hide = true
        LDBIcon:Hide(addonName)
        if ns.freeFrame then ns.freeFrame:Show() end
    else
        TrackingEyeGlobalDB.minimap.hide = false
        LDBIcon:Show(addonName)
        if ns.freeFrame then ns.freeFrame:Hide() end
    end
end

function ns.BuildTooltip(tooltip)
    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Dev"
    tooltip:AddDoubleLine(ns.GetColor("TITLE") .. ns.L["ADDON_TITLE"] .. "|r", ns.GetColor("MUTED") .. version .. "|r")
    tooltip:AddLine(" ")
    
    local displayID = TrackingEyeDB.selectedSpellId
    if displayID then
        local name = ns.GetSpellName(displayID) or "Unknown"
        tooltip:AddLine("|T" .. (GetSpellTexture(displayID) or "") .. ":16|t " .. ns.GetColor("TEXT") .. name .. "|r")
    else
        tooltip:AddLine("|TInterface\\Icons\\inv_misc_map_01:16|t " .. ns.GetColor("DESC") .. ns.L["NO_TRACKING"] .. "|r")
    end
    
    tooltip:AddLine(" ")
    local function AddOption(title, val, desc, cmd)
        local color = val and (ns.GetColor("SUCCESS") .. ns.L["ENABLED"] .. "|r") or (ns.GetColor("DISABLED") .. ns.L["DISABLED"] .. "|r")
        tooltip:AddDoubleLine(ns.GetColor("TITLE") .. ns.L[title] .. "|r", color)
        tooltip:AddLine(ns.GetColor("DESC") .. ns.L[desc] .. "|r", 1, 1, 1, true)
        tooltip:AddDoubleLine(ns.GetColor("INFO") .. ns.L[cmd] .. "|r", ns.GetColor("INFO") .. ns.L["TOGGLE"] .. "|r")
        tooltip:AddLine(" ")
    end

    AddOption("PERSISTENT_TRACKING", TrackingEyeDB.autoTracking, "PERSISTENT_DESC", "MOD_SHIFT_LEFT")
    AddOption("FARMING_MODE", TrackingEyeDB.farmingMode, "FARMING_DESC", "MOD_SHIFT_RIGHT")
    AddOption("PLACEMENT_MODE", TrackingEyeGlobalDB.freePlacement, "PLACEMENT_DESC", "MOD_MIDDLE")
    
    tooltip:AddDoubleLine(ns.GetColor("INFO") .. ns.L["MOD_LEFT"] .. "|r", ns.GetColor("INFO") .. ns.L["TRACKING_MENU"] .. "|r")
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(ns.GetColor("INFO") .. ns.L["MOD_RIGHT"] .. "|r", ns.GetColor("INFO") .. ns.L["CLEAR_TRACKING"] .. "|r")
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

    if ns.freeFrame then TryRefresh(ns.freeFrame) end
    
    local minimapBtn = LDBIcon:GetMinimapButton(addonName)
    if minimapBtn then TryRefresh(minimapBtn) end
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------
local function OnClick(self, button)
    local updateNeeded = false
    
    if button == "MiddleButton" then
        TrackingEyeGlobalDB.freePlacement = not TrackingEyeGlobalDB.freePlacement
        ns.UpdatePlacement()
        updateNeeded = true
    elseif IsShiftKeyDown() then
        if button == "LeftButton" then
            TrackingEyeDB.autoTracking = not TrackingEyeDB.autoTracking
            updateNeeded = true
        elseif button == "RightButton" then
            TrackingEyeDB.farmingMode = not TrackingEyeDB.farmingMode
            updateNeeded = true
        end
    elseif button == "RightButton" then
        ns.ClearTracking()
    elseif button == "LeftButton" then
        ns.ToggleMenu(self)
    end
    
    if updateNeeded then
        ns.RefreshTooltip()
    end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function ns.CreateFreeFrame()
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
        ns.BuildTooltip(GameTooltip)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    if TrackingEyeGlobalDB.freePos then
        local p = TrackingEyeGlobalDB.freePos
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        f:SetPoint("CENTER")
    end
    ns.freeFrame = f
    ns.UpdatePlacement()
end

function ns.InitMinimap()
    ns.ldb = LDB:NewDataObject(addonName, {
        type = "launcher",
        icon = ns.state.currentIcon or ns.ICON_DEFAULT,
        OnClick = OnClick,
        OnTooltipShow = function(tt) ns.BuildTooltip(tt) end
    })
    
    LDBIcon:Register(addonName, ns.ldb, TrackingEyeGlobalDB.minimap)
    ns.UpdatePlacement()
end
