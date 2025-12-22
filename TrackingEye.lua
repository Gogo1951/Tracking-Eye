local ADDON_NAME = "TrackingEye"
local ADDON_TITLE = "Tracking Eye"

--[[ =========================================================================
     1. LIBRARIES & EXTERNAL REFERENCES
   ========================================================================= ]]
local LibStub = LibStub
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

--[[ =========================================================================
     2. CONSTANTS & CONFIGURATION
   ========================================================================= ]]
-- Identifiers & Intervals
local DEFAULT_MINIMAP_ICON = "Interface\\Icons\\inv_misc_map_01"
local DRUID_CAT_FORM_SPELL_ID = 768
local FARM_INTERVAL = 3.0

-- Frame Dimensions
local FREE_FRAME_SIZE = 37
local FREE_ICON_SIZE = 24
local FREE_BORDER_SIZE = 62

-- Branding & Tooltip Colors
local COLOR_PREFIX = "|cff"
local C_TITLE      = "FFD100" -- Gold: Titles
local C_INFO       = "00BBFF" -- Blue: Interactions
local C_BODY       = "CCCCCC" -- Silver: Descriptions
local C_TEXT       = "FFFFFF" -- White: Messages
local C_SUCCESS    = "33CC33" -- Green: On
local C_DISABLED   = "CC3333" -- Red: Off
local C_SEP        = "AAAAAA" -- Gray: Separators
local C_MUTED      = "808080" -- Dark Gray: Meta-data

local COLORS = {
    TITLE    = COLOR_PREFIX .. C_TITLE,
    INFO     = COLOR_PREFIX .. C_INFO,
    DESC     = COLOR_PREFIX .. C_BODY,
    TEXT     = COLOR_PREFIX .. C_TEXT,
    SUCCESS  = COLOR_PREFIX .. C_SUCCESS,
    DISABLED = COLOR_PREFIX .. C_DISABLED,
    SEP      = COLOR_PREFIX .. C_SEP,
    MUTED    = COLOR_PREFIX .. C_MUTED
}

--[[ =========================================================================
     3. DATA TABLES
   ========================================================================= ]]
local trackingSpells = {
    [43308] = "Find Fish",
    [2383]  = "Find Herbs",
    [2580]  = "Find Minerals",
    [2481]  = "Find Treasure",
    [1494]  = "Track Beasts",
    [19878] = "Track Demons",
    [19879] = "Track Dragonkin",
    [19880] = "Track Elementals",
    [19882] = "Track Giants",
    [19885] = "Track Hidden",
    [19883] = "Track Humanoids",
    [5225]  = "Track Humanoids",
    [19884] = "Track Undead",
    [5500]  = "Sense Demons",
    [5502]  = "Sense Undead"
}

local farmSpellIds = {
    2383,
    2580,
    2481
}

--[[ =========================================================================
     4. VARIABLES & FRAME REFERENCES
   ========================================================================= ]]
-- State Variables
local currentVisualTexture = nil
local TrackingEyeDB
local isRetryPending = false
local retryCount = 0
local currentFarmIndex = 0
local wasFarmingLastTick = false
local farmCycleCache = {}

-- Frame & Object References
local trackingLauncher
local freeFrame
local dropdown = CreateFrame("Frame", ADDON_NAME .. "Dropdown", UIParent, "UIDropDownMenuTemplate")
local eventFrame = CreateFrame("Frame")

--[[ =========================================================================
     5. API COMPATIBILITY SHIMS
   ========================================================================= ]]
-- 1. Metadata Handling (Handles strict 10.x+ vs older clients)
local GetAddOnMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata

-- 2. Tracking API Handling (Handles C_Minimap vs global _G functions)
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
    -- Fallback for very old clients or restricted environments
    GetNumTrackingTypes_Fn = function() return 0 end
    GetTrackingInfo_Fn = function() return end
end

--[[ =========================================================================
     6. UTILITY HELPER FUNCTIONS
   ========================================================================= ]]
local function ClearTable(t)
    if table.wipe then
        table.wipe(t)
    else
        for k in pairs(t) do t[k] = nil end
    end
end

--[[ =========================================================================
     7. PLAYER STATE HELPERS
   ========================================================================= ]]
local function HasAnyTrackingSpell()
    for id in pairs(trackingSpells) do
        if IsPlayerSpell(id) then return true end
    end
    return false
end

local function IsDruidInCatForm()
    local _, classFilename = UnitClass("player")
    if classFilename ~= "DRUID" then return false end
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        if not spellId then break end
        if spellId == DRUID_CAT_FORM_SPELL_ID then return true end
    end
    return false
end

local function IsFarmingForm()
    if IsMounted() then return true end
    local form = GetShapeshiftFormID()
    if form == 3 or form == 27 or form == 29 or form == 16 then return true end
    return false
end

local function IsPlayerStealthed()
    if IsStealthed then return IsStealthed() end
    return false
end

local function IsPlayerCasting()
    return UnitCastingInfo("player") ~= nil or UnitChannelInfo("player") ~= nil
end

--[[ =========================================================================
     8. VISUAL UPDATES
   ========================================================================= ]]
local function GetCurrentStateIcon()
    if currentVisualTexture then return currentVisualTexture end
    
    if GetTrackingTexture then
        local active = GetTrackingTexture()
        if active then return active end
    end
    
    if TrackingEyeDB and TrackingEyeDB.selectedSpellId then
        local icon = GetSpellTexture(TrackingEyeDB.selectedSpellId)
        if icon then return icon end
    end
    
    return DEFAULT_MINIMAP_ICON
end

local function SetIconTexture(texture)
    if not texture then return end
    
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
    if not TrackingEyeDB then return end
    
    if TrackingEyeDB.freePlacement then
        if LDBIcon then LDBIcon:Hide(ADDON_NAME) end
        if freeFrame then
            freeFrame:Show()
            UpdateVisuals()
        end
    else
        if LDBIcon then LDBIcon:Show(ADDON_NAME) end
        if freeFrame then freeFrame:Hide() end
    end
end

--[[ =========================================================================
     9. CORE TRACKING LOGIC
   ========================================================================= ]]
local function IsTrackingActive(spellId)
    if not spellId then return false end
    
    local spellName = GetSpellInfo(spellId)
    local spellIcon = GetSpellTexture(spellId)
    
    -- Check 1: Texture Match (Legacy/Simple check)
    if GetTrackingTexture and spellIcon then
        local currentTexture = GetTrackingTexture()
        if currentTexture and tostring(currentTexture) == tostring(spellIcon) then
            return true
        end
    end
    
    -- Check 2: API Iteration (Robust check)
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
            if spellName and name == spellName then return true end
            if spellIcon and texture and tostring(texture) == tostring(spellIcon) then return true end
        end
    end
    
    return false
end

local function ReapplyTracking(isAutoTrigger)
    if not TrackingEyeDB then return end
    
    if TrackingEyeDB.farmingMode and IsFarmingForm() then return end
    if isAutoTrigger and not TrackingEyeDB.autoTracking then return end
    
    local spellId = TrackingEyeDB.selectedSpellId
    if not spellId then return end
    
    if UnitIsDeadOrGhost("player") or IsPlayerStealthed() or IsPlayerCasting() or UnitAffectingCombat("player") then
        return
    end
    
    if IsTrackingActive(spellId) then return end
    
    local start, duration = GetSpellCooldown(spellId)
    if start > 0 and duration > 0 then
        if not isRetryPending and retryCount < 5 then
            isRetryPending = true
            retryCount = retryCount + 1
            local remaining = (start + duration) - GetTime()
            C_Timer.After(remaining + 0.1, function()
                isRetryPending = false
                ReapplyTracking(isAutoTrigger)
            end)
        end
        return
    end
    
    retryCount = 0
    if IsPlayerSpell(spellId) then
        if spellId == 5225 and not IsDruidInCatForm() then return end
        pcall(CastSpellByID, spellId)
    end
end

--[[ =========================================================================
     10. FARMING MODE LOGIC
   ========================================================================= ]]
local function DoFarmingSwap()
    if not TrackingEyeDB then return end
    
    local inForm = IsFarmingForm()
    
    -- Transitioning OUT of farming form
    if not inForm and wasFarmingLastTick then
        wasFarmingLastTick = false
        ReapplyTracking(true)
        return
    end
    
    -- Checks to allow cycling
    if not TrackingEyeDB.farmingMode or not inForm then return end
    if UnitAffectingCombat("player") or IsPlayerCasting() or IsPlayerStealthed() then return end
    
    -- Build Cycle Table
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
    
    local count = #farmCycleCache
    if count == 0 then return end
    
    -- Single Spell Logic
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
    
    -- Cycle Logic
    currentFarmIndex = currentFarmIndex + 1
    if currentFarmIndex > count then currentFarmIndex = 1 end
    
    local nextSpell = farmCycleCache[currentFarmIndex]
    if IsTrackingActive(nextSpell) then
        wasFarmingLastTick = true
        return
    end
    
    pcall(CastSpellByID, nextSpell)
    wasFarmingLastTick = true
end

--[[ =========================================================================
     11. TOOLTIP & CLICK HANDLING
   ========================================================================= ]]
local function PopulateTooltip(tooltip)
    -- Dynamic Version Check
    local version = GetAddOnMetadata(ADDON_NAME, "Version") or "Dev"
    if version:find("@") then
        version = "Dev"
    end
    
    -- Header
    tooltip:AddDoubleLine(COLORS.TITLE .. ADDON_TITLE .. "|r", COLORS.MUTED .. version .. "|r")
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")
    
    -- Current State
    if TrackingEyeDB and TrackingEyeDB.selectedSpellId then
        local name = trackingSpells[TrackingEyeDB.selectedSpellId] or "Unknown"
        local icon = GetSpellTexture(TrackingEyeDB.selectedSpellId)
        tooltip:AddLine("|T" .. icon .. ":16|t " .. COLORS.TEXT .. name .. "|r")
    else
        tooltip:AddLine("|TInterface\\Icons\\inv_misc_map_01:16|t " .. COLORS.DESC .. "No Tracking Selected|r")
    end
    tooltip:AddLine(" ")

    -- Setting: Persistent Tracking
    local auto = (TrackingEyeDB and TrackingEyeDB.autoTracking)
    local autoColor = auto and (COLORS.SUCCESS .. "Enabled|r") or (COLORS.DISABLED .. "Disabled|r")
    tooltip:AddDoubleLine(COLORS.TITLE .. "Persistent Tracking|r", autoColor)
    tooltip:AddLine(COLORS.DESC .. "Automatically recasts your tracking spell after resurrection.|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(COLORS.INFO .. "Shift + Left-Click|r", COLORS.INFO .. "Toggle|r")
    tooltip:AddLine(" ")

    -- Setting: Farming Mode
    local farm = (TrackingEyeDB and TrackingEyeDB.farmingMode)
    local farmColor = farm and (COLORS.SUCCESS .. "Enabled|r") or (COLORS.DISABLED .. "Disabled|r")
    tooltip:AddDoubleLine(COLORS.TITLE .. "Farming Mode|r", farmColor)
    tooltip:AddLine(COLORS.DESC .. "Cycles between Herbs, Minerals, and Treasure while mounted or in travel form.|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(COLORS.INFO .. "Shift + Right-Click|r", COLORS.INFO .. "Toggle|r")
    tooltip:AddLine(" ")

    -- Setting: Free Placement Mode
    local free = (TrackingEyeDB and TrackingEyeDB.freePlacement)
    local freeColor = free and (COLORS.SUCCESS .. "Enabled|r") or (COLORS.DISABLED .. "Disabled|r")
    tooltip:AddDoubleLine(COLORS.TITLE .. "Free Placement Mode|r", freeColor)
    tooltip:AddLine(COLORS.DESC .. "Replaces the minimap button with a standalone icon you can move anywhere.|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(COLORS.INFO .. "Middle-Click|r", COLORS.INFO .. "Toggle|r")
    tooltip:AddLine(" ")

    -- Menu Controls
    tooltip:AddDoubleLine(COLORS.INFO .. "Left-Click|r", COLORS.INFO .. "Tracking Menu|r")
    tooltip:AddLine(" ")
    tooltip:AddDoubleLine(COLORS.INFO .. "Right-Click|r", COLORS.INFO .. "Clear Persistent Tracking|r")
end

local function HandleClick(self, button)
    if not TrackingEyeDB then return end
    
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
        if onEnter then onEnter(self) end
    else
        if button == "RightButton" then
            ClearTrackingSelection()
            local onEnter = self:GetScript("OnEnter")
            if onEnter then onEnter(self) end
        elseif button == "LeftButton" then
            local dropDown = _G[ADDON_NAME .. "Dropdown"]
            ToggleDropDownMenu(1, nil, dropDown, self, 0, 0)
        end
    end
end

--[[ =========================================================================
     12. UI ELEMENTS (DROPDOWN, FREE FRAME, LDB)
   ========================================================================= ]]

-- Dropdown Menu Construction
if not C_AddOns.IsAddOnLoaded("Blizzard_UIDropDownMenu") then
    C_AddOns.LoadAddOn("Blizzard_UIDropDownMenu")
end

local function BuildMenu(self, level)
    if level ~= 1 then return end
    
    local info
    local spellList = {}
    for id, name in pairs(trackingSpells) do
        table.insert(spellList, { id = id, name = name })
    end
    table.sort(spellList, function(a, b) return a.name < b.name end)
    
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
            info.value = { spellId = spellId }
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

-- Free Frame Construction
local function CreateFreeFrame()
    if freeFrame then return end
    
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
    
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relPoint, x, y = self:GetPoint()
        if TrackingEyeDB then
            TrackingEyeDB.freePos = { point, relPoint, x, y }
        end
    end)
    
    f:SetScript("OnClick", HandleClick)
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        PopulateTooltip(GameTooltip)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    if TrackingEyeDB and TrackingEyeDB.freePos then
        local p = TrackingEyeDB.freePos
        f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else
        f:SetPoint("CENTER")
    end
    
    freeFrame = f
end

-- LDB Initialization
local function InitLDB()
    if not HasAnyTrackingSpell() then return end
    
    trackingLauncher = LDB:NewDataObject(ADDON_NAME, {
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

--[[ =========================================================================
     13. EVENT HANDLING
   ========================================================================= ]]
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
        if TrackingEyeDB.autoTracking == nil then TrackingEyeDB.autoTracking = true end
        if TrackingEyeDB.farmingMode == nil then TrackingEyeDB.farmingMode = true end
        if TrackingEyeDB.freePlacement == nil then TrackingEyeDB.freePlacement = false end
        
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
