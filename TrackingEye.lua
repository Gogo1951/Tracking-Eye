local ADDON_NAME = "TrackingEye"

-----------------------------------------------------------------------
-- LIBRARIES & CONSTANTS
-----------------------------------------------------------------------
local LibStub = LibStub
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local DEFAULT_MINIMAP_ICON = "Interface\\Icons\\inv_misc_map_01"
local DRUID_CAT_FORM_SPELL_ID = 768
local FARM_INTERVAL = 3.0

local FREE_FRAME_SIZE = 37
local FREE_ICON_SIZE = 24
local FREE_BORDER_SIZE = 62

-----------------------------------------------------------------------
-- DATA TABLES
-----------------------------------------------------------------------
local trackingSpells = {
    [2383] = "Find Herbs",
    [2580] = "Find Minerals",
    [2481] = "Find Treasure",
    [1494] = "Track Beasts",
    [19878] = "Track Demons",
    [19879] = "Track Dragonkin",
    [19880] = "Track Elementals",
    [19882] = "Track Giants",
    [19885] = "Track Hidden",
    [19883] = "Track Humanoids",
    [5225] = "Track Humanoids",
    [19884] = "Track Undead",
    [5500] = "Sense Demons",
    [5502] = "Sense Undead"
}

local farmSpellIds = {
    2383,
    2580,
    2481
}

-----------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------
local currentVisualTexture = nil
local TrackingEyeDB
local trackingLauncher
local freeFrame
local isRetryPending = false
local retryCount = 0
local currentFarmIndex = 0
local wasFarmingLastTick = false
local farmCycleCache = {}

-----------------------------------------------------------------------
-- API COMPATIBILITY
-----------------------------------------------------------------------
local GetNumTrackingTypes_Fn
local GetTrackingInfo_Fn
local IsModernTrackingAPI = false

if C_Minimap and C_Minimap.GetNumTrackingTypes then
    GetNumTrackingTypes_Fn = C_Minimap.GetNumTrackingTypes
    GetTrackingInfo_Fn = C_Minimap.GetTrackingInfo
    IsModernTrackingAPI = true
elseif _G.GetNumTrackingTypes then
    GetNumTrackingTypes_Fn = _G.GetNumTrackingTypes
    GetTrackingInfo_Fn = _G.GetTrackingInfo
else
    GetNumTrackingTypes_Fn = function()
        return 0
    end
    GetTrackingInfo_Fn = function()
        return
    end
end

-----------------------------------------------------------------------
-- UTILITY FUNCTIONS
-----------------------------------------------------------------------
local function ClearTable(t)
    if table.wipe then
        table.wipe(t)
    else
        for k in pairs(t) do
            t[k] = nil
        end
    end
end

-----------------------------------------------------------------------
-- STATE HELPERS
-----------------------------------------------------------------------
local function HasAnyTrackingSpell()
    for id in pairs(trackingSpells) do
        if IsPlayerSpell(id) then
            return true
        end
    end
    return false
end

local function IsDruidInCatForm()
    local _, classFilename = UnitClass("player")
    if classFilename ~= "DRUID" then
        return false
    end
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        if not spellId then
            break
        end
        if spellId == DRUID_CAT_FORM_SPELL_ID then
            return true
        end
    end
    return false
end

local function IsFarmingForm()
    if IsMounted() then
        return true
    end
    local form = GetShapeshiftFormID()
    if form == 3 or form == 27 or form == 29 or form == 16 then
        return true
    end
    return false
end

local function IsPlayerStealthed()
    if IsStealthed then
        return IsStealthed()
    end
    return false
end

local function IsPlayerCasting()
    return UnitCastingInfo("player") ~= nil or UnitChannelInfo("player") ~= nil
end

-----------------------------------------------------------------------
-- VISUAL UPDATES
-----------------------------------------------------------------------
local function GetCurrentStateIcon()
    if currentVisualTexture then
        return currentVisualTexture
    end
    if GetTrackingTexture then
        local active = GetTrackingTexture()
        if active then
            return active
        end
    end
    if TrackingEyeDB and TrackingEyeDB.selectedSpellId then
        local icon = GetSpellTexture(TrackingEyeDB.selectedSpellId)
        if icon then
            return icon
        end
    end
    return DEFAULT_MINIMAP_ICON
end

local function SetIconTexture(texture)
    if not texture then
        return
    end
    if trackingLauncher and trackingLauncher.icon ~= texture then
        trackingLauncher.icon = texture
    end
    if freeFrame and freeFrame.icon then
        if freeFrame.icon:GetTexture() ~= texture then
            freeFrame.icon:SetTexture(texture)
        end
    end
end

local function UpdateVisuals()
    SetIconTexture(GetCurrentStateIcon())
end

local function ClearTrackingSelection()
    CancelTrackingBuff()
    if TrackingEyeDB then
        TrackingEyeDB.selectedSpellId = nil
    end
    currentVisualTexture = DEFAULT_MINIMAP_ICON
    UpdateVisuals()
end

local function UpdatePlacementMode()
    if not TrackingEyeDB then
        return
    end
    if TrackingEyeDB.freePlacement then
        if LDBIcon then
            LDBIcon:Hide(ADDON_NAME)
        end
        if freeFrame then
            freeFrame:Show()
            UpdateVisuals()
        end
    else
        if LDBIcon then
            LDBIcon:Show(ADDON_NAME)
        end
        if freeFrame then
            freeFrame:Hide()
        end
    end
end

-----------------------------------------------------------------------
-- TRACKING LOGIC
-----------------------------------------------------------------------
local function IsTrackingActive(spellId)
    if not spellId then
        return false
    end
    local spellName = GetSpellInfo(spellId)
    local spellIcon = GetSpellTexture(spellId)
    if GetTrackingTexture and spellIcon then
        local currentTexture = GetTrackingTexture()
        if currentTexture and tostring(currentTexture) == tostring(spellIcon) then
            return true
        end
    end
    if not GetNumTrackingTypes_Fn then
        return IsCurrentSpell(spellId)
    end
    local numTracking = GetNumTrackingTypes_Fn() or 0
    for i = 1, numTracking do
        local name, texture, active
        local info = GetTrackingInfo_Fn(i)
        if IsModernTrackingAPI and type(info) == "table" then
            name = info.name
            texture = info.texture
            active = info.active
            if info.spellID and info.spellID == spellId and active then
                return true
            end
        else
            name, texture, active = GetTrackingInfo_Fn(i)
        end
        if active then
            if spellName and name == spellName then
                return true
            end
            if spellIcon and texture and tostring(texture) == tostring(spellIcon) then
                return true
            end
        end
    end
    return false
end

-----------------------------------------------------------------------
-- AUTO-REAPPLICATION LOGIC
-----------------------------------------------------------------------
local function ReapplyTracking(isAutoTrigger)
    if not TrackingEyeDB then
        return
    end
    if TrackingEyeDB.farmingMode and IsFarmingForm() then
        return
    end
    if isAutoTrigger and not TrackingEyeDB.autoTracking then
        return
    end
    local spellId = TrackingEyeDB.selectedSpellId
    if not spellId then
        return
    end
    if UnitIsDeadOrGhost("player") or IsPlayerStealthed() or IsPlayerCasting() or UnitAffectingCombat("player") then
        return
    end
    if IsTrackingActive(spellId) then
        return
    end
    local start, duration = GetSpellCooldown(spellId)
    if start > 0 and duration > 0 then
        if not isRetryPending and retryCount < 5 then
            isRetryPending = true
            retryCount = retryCount + 1
            local remaining = (start + duration) - GetTime()
            C_Timer.After(
                remaining + 0.1, function()
                isRetryPending = false
                ReapplyTracking(isAutoTrigger)
            end)
        end
        return
    end
    retryCount = 0
    if IsPlayerSpell(spellId) then
        if spellId == 5225 and not IsDruidInCatForm() then
            return
        end
        pcall(CastSpellByID, spellId)
    end
end

-----------------------------------------------------------------------
-- FARMING MODE LOGIC
-----------------------------------------------------------------------
local function DoFarmingSwap()
    if not TrackingEyeDB then
        return
    end
    local inForm = IsFarmingForm()
    if not inForm and wasFarmingLastTick then
        wasFarmingLastTick = false
        ReapplyTracking(true)
        return
    end
    if not TrackingEyeDB.farmingMode or not inForm then
        return
    end
    if UnitAffectingCombat("player") or IsPlayerCasting() or IsPlayerStealthed() then
        return
    end
    ClearTable(farmCycleCache)
    if TrackingEyeDB.selectedSpellId then
        if TrackingEyeDB.selectedSpellId ~= 5225 then
            table.insert(farmCycleCache, TrackingEyeDB.selectedSpellId)
        end
    end
    for _, id in ipairs(farmSpellIds) do
        if IsPlayerSpell(id) and id ~= TrackingEyeDB.selectedSpellId then
            table.insert(farmCycleCache, id)
        end
    end
    local count = # farmCycleCache
    if count == 0 then
        return
    end
    if count == 1 then
        local soloSpell = farmCycleCache[1]
        if IsTrackingActive(soloSpell) then
            wasFarmingLastTick = true
            return
        end
        pcall(CastSpellByID, soloSpell)
        wasFarmingLastTick = true
        return
    end
    currentFarmIndex = currentFarmIndex + 1
    if currentFarmIndex > count then
        currentFarmIndex = 1
    end
    local nextSpell = farmCycleCache[currentFarmIndex]
    if IsTrackingActive(nextSpell) then
        wasFarmingLastTick = true
        return
    end
    pcall(CastSpellByID, nextSpell)
    wasFarmingLastTick = true
end

-----------------------------------------------------------------------
-- DROPDOWN MENU
-----------------------------------------------------------------------
if not C_AddOns.IsAddOnLoaded("Blizzard_UIDropDownMenu") then
    C_AddOns.LoadAddOn("Blizzard_UIDropDownMenu")
end

local dropdown = CreateFrame("Frame", ADDON_NAME .. "Dropdown", UIParent, "UIDropDownMenuTemplate")

local function BuildMenu(self, level)
    if level ~= 1 then
        return
    end
    local info
    local spellList = {}
    for id, name in pairs(trackingSpells) do
        table.insert(spellList, {
            id = id,
            name = name
        })
    end
    table.sort(
        spellList, function(a, b)
        return a.name < b.name
    end)
    for _, spellData in ipairs(spellList) do
        local spellId = spellData.id
        local spellName = spellData.name
        local known = IsPlayerSpell(spellId)
        local isDruidReqMet = (spellId ~= 5225 or IsDruidInCatForm())
        if known and isDruidReqMet then
            local icon = GetSpellTexture(spellId)
            info = UIDropDownMenu_CreateInfo()
            info.text = spellName
            if icon then
                info.text = "|T" .. icon .. ":16:16:0:0:64:64:5:59:5:59|t " .. spellName
            end
            info.value = {
                spellId = spellId
            }
            info.checked = (TrackingEyeDB.selectedSpellId == spellId)
            info.func = function(self)
                local idToCast = self.value.spellId
                TrackingEyeDB.selectedSpellId = idToCast
                wasFarmingLastTick = false
                ReapplyTracking(false)
                UpdateVisuals()
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

UIDropDownMenu_Initialize(dropdown, BuildMenu, "MENU")

-----------------------------------------------------------------------
-- TOOLTIP & CLICK HANDLING
-----------------------------------------------------------------------
local function PopulateTooltip(tooltip)
    local version = C_AddOns and C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "2025.12.20.IV"
    tooltip:AddDoubleLine(ADDON_NAME, "|cFFAAAAAA" .. version .. "|r", 1, 0.82, 0, 1, 1, 1)
    tooltip:AddLine(" ")
    if TrackingEyeDB and TrackingEyeDB.selectedSpellId then
        local name = trackingSpells[TrackingEyeDB.selectedSpellId] or "Unknown"
        local icon = GetSpellTexture(TrackingEyeDB.selectedSpellId)
        tooltip:AddLine("|T" .. icon .. ":16|t |cFFFFFFFF" .. name .. "|r")
    else
        tooltip:AddLine("|cFFAAAAAANo Tracking Selected|r")
    end
    tooltip:AddLine(" ")
    local auto = (TrackingEyeDB and TrackingEyeDB.autoTracking)
    local autoColor = auto and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
    tooltip:AddDoubleLine("Persistent Tracking", autoColor)
    tooltip:AddLine("|cFFAAAAAAWhen enabled, your chosen tracking spell will be automatically recast after you resurrect.|r", 1, 1, 1, true)
    tooltip:AddDoubleLine("|cFF00BBFFShift + Left-Click|r", "|cFFFFFFFFToggle Persistent Tracking|r")
    tooltip:AddLine(" ")
    local farm = (TrackingEyeDB and TrackingEyeDB.farmingMode)
    local farmColor = farm and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
    tooltip:AddDoubleLine("Farming Mode", farmColor)
    tooltip:AddLine("|cFFAAAAAAWhen enabled, your tracking will cycle between Find Herbs, Find Minerals, and Find Treasure while mounted or in travel forms.|r", 1, 1, 1, true)
    tooltip:AddDoubleLine("|cFF00BBFFShift + Right-Click|r", "|cFFFFFFFFToggle Farming Mode|r")
    tooltip:AddLine(" ")
    local free = (TrackingEyeDB and TrackingEyeDB.freePlacement)
    local freeColor = free and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
    tooltip:AddDoubleLine("Free Placement Mode", freeColor)
    tooltip:AddLine("|cFFAAAAAAWhen enabled, the minimap button is replaced by a larger, movable icon that you can place anywhere on your screen.|r", 1, 1, 1, true)
    tooltip:AddDoubleLine("|cFF00BBFFMiddle-Click|r", "|cFFFFFFFFToggle Free Placement Mode|r")
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine("|cFF00BBFFLeft-Click|r", "|cFFFFFFFFTracking Menu|r")
    tooltip:AddDoubleLine("|cFF00BBFFRight-Click|r", "|cFFFFFFFFClear Tracking|r")
end

local function HandleClick(self, button)
    if not TrackingEyeDB then
        return
    end
    if button == "MiddleButton" then
        TrackingEyeDB.freePlacement = not TrackingEyeDB.freePlacement
        UpdatePlacementMode()
        GameTooltip:Hide()
        return
    end
    if IsShiftKeyDown() then
        if button == "LeftButton" then
            TrackingEyeDB.autoTracking = not TrackingEyeDB.autoTracking
        elseif button == "RightButton" then
            TrackingEyeDB.farmingMode = not TrackingEyeDB.farmingMode
        end
        local onEnter = self:GetScript("OnEnter")
        if onEnter then
            onEnter(self)
        end
    else
        if button == "RightButton" then
            ClearTrackingSelection()
            local onEnter = self:GetScript("OnEnter")
            if onEnter then
                onEnter(self)
            end
        elseif button == "LeftButton" then
            local dropDown = _G[ADDON_NAME .. "Dropdown"]
            ToggleDropDownMenu(1, nil, dropDown, self, 0, 0)
        end
    end
end

-----------------------------------------------------------------------
-- FREE PLACEMENT FRAME
-----------------------------------------------------------------------
local function CreateFreeFrame()
    if freeFrame then
        return
    end
    local f = CreateFrame("Button", ADDON_NAME .. "FreeFrame", UIParent)
    f:SetSize(FREE_FRAME_SIZE, FREE_FRAME_SIZE)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:RegisterForClicks("AnyUp")
    f:SetClampedToScreen(true)
    f:SetFrameStrata("HIGH")
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    f.bg:SetSize(FREE_ICON_SIZE, FREE_ICON_SIZE)
    f.bg:SetPoint("CENTER")
    f.bg:SetVertexColor(0, 0, 0, 0.6)
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(FREE_ICON_SIZE, FREE_ICON_SIZE)
    f.icon:SetPoint("CENTER")
    f.icon:SetTexture(GetCurrentStateIcon())
    local mask = f:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    mask:SetAllPoints(f.icon)
    f.icon:AddMaskTexture(mask)
    f.border = f:CreateTexture(nil, "OVERLAY")
    f.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    f.border:SetSize(FREE_BORDER_SIZE, FREE_BORDER_SIZE)
    f.border:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    f:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-RoundedButton-Highlight")
    f:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint()
        if TrackingEyeDB then
            TrackingEyeDB.freePos = {
                point,
                relPoint,
                x,
                y
            }
        end
    end)
    f:SetScript("OnClick", HandleClick)
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        PopulateTooltip(GameTooltip)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    if TrackingEyeDB and TrackingEyeDB.freePos then
        local p = TrackingEyeDB.freePos
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        f:SetPoint("CENTER")
    end
    freeFrame = f
end

-----------------------------------------------------------------------
-- LDB INITIALIZATION
-----------------------------------------------------------------------
local function InitLDB()
    if not HasAnyTrackingSpell() then
        return
    end
    trackingLauncher = LDB:NewDataObject(
        ADDON_NAME, {
        type = "launcher",
        text = "Tracking Eye",
        icon = GetCurrentStateIcon(),
        OnTooltipShow = function(tooltip)
            local button = LibStub("LibDBIcon-1.0"):GetMinimapButton(ADDON_NAME)
            if button then
                tooltip:SetOwner(button, "ANCHOR_NONE")
                tooltip:SetPoint("TOPRIGHT", button, "BOTTOMLEFT", 0, 0)
            end
            PopulateTooltip(tooltip)
        end,
        OnClick = HandleClick
    })
    if LDBIcon then
        LDBIcon:Register(ADDON_NAME, trackingLauncher, TrackingEyeDB.minimap)
    end
end

-----------------------------------------------------------------------
-- EVENT HANDLING
-----------------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
eventFrame:RegisterEvent("MINIMAP_UPDATE_TRACKING")
eventFrame:RegisterEvent("PLAYER_UNGHOST")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("UPDATE_STEALTH")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local arg1, arg2, arg3 = ...
    if event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellId = arg1, arg2, arg3
        if unit == "player" and spellId and trackingSpells[spellId] then
            local icon = GetSpellTexture(spellId)
            currentVisualTexture = icon
            SetIconTexture(icon)
            if TrackingEyeDB then
                local isFarmSpell = (spellId == 2383 or spellId == 2580 or spellId == 2481)
                local isFarmingActive = TrackingEyeDB.farmingMode and IsFarmingForm()
                if not (isFarmingActive and isFarmSpell) then
                    TrackingEyeDB.selectedSpellId = spellId
                end
            end
        end
    elseif event == "ADDON_LOADED" and arg1 == ADDON_NAME then
        TrackingEyeDB = _G[ADDON_NAME .. "DB"]
        if not TrackingEyeDB or type(TrackingEyeDB) ~= "table" then
            TrackingEyeDB = {}
            _G[ADDON_NAME .. "DB"] = TrackingEyeDB
        end
        TrackingEyeDB.minimap = TrackingEyeDB.minimap or {}
        if TrackingEyeDB.autoTracking == nil then
            TrackingEyeDB.autoTracking = true
        end
        if TrackingEyeDB.farmingMode == nil then
            TrackingEyeDB.farmingMode = true
        end
        if TrackingEyeDB.freePlacement == nil then
            TrackingEyeDB.freePlacement = false
        end
        if TrackingEyeDB.selectedSpellId then
            currentVisualTexture = GetSpellTexture(TrackingEyeDB.selectedSpellId)
        end
        C_Timer.NewTicker(0.5, UpdateVisuals)
        C_Timer.NewTicker(FARM_INTERVAL, DoFarmingSwap)
    elseif event == "PLAYER_LOGIN" then
        InitLDB()
        CreateFreeFrame()
        UpdateVisuals()
        UpdatePlacementMode()
    elseif event == "MINIMAP_UPDATE_TRACKING" then
        UpdateVisuals()
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(5.0, function()
            UpdateVisuals()
            ReapplyTracking(true)
        end)
    elseif event == "PLAYER_REGEN_ENABLED" or event == "UPDATE_STEALTH" or event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE" then
        C_Timer.After(0.5, function()
            ReapplyTracking(true)
        end)
    elseif event == "UPDATE_SHAPESHIFT_FORM" then
        C_Timer.After(0.2, function()
            ReapplyTracking(true)
        end)
    end
end)
