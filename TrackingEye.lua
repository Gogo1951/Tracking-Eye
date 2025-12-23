local addonName, addonTable = ...
local addonTitle = C_AddOns.GetAddOnMetadata(addonName, "Title")

--------------------------------------------------------------------------------
-- 1. Libraries & Constants
--------------------------------------------------------------------------------
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local ICON_DEFAULT   = "Interface\\Icons\\inv_misc_map_01"
local ICON_SIZE      = 24
local FRAME_SIZE     = 37
local FARM_INTERVAL  = 3.0

-- Spell Data
local SPELL_FIND_FISH     = 43308
local SPELL_FIND_HERBS    = 2383
local SPELL_FIND_MINERALS = 2580
local SPELL_FIND_TREASURE = 2481
local SPELL_TRACK_HUMAN   = 5225 -- Druid only

local TRACKING_SPELLS = {
    [SPELL_FIND_FISH]     = "Find Fish",
    [SPELL_FIND_HERBS]    = "Find Herbs",
    [SPELL_FIND_MINERALS] = "Find Minerals",
    [SPELL_FIND_TREASURE] = "Find Treasure",
    [1494]  = "Track Beasts",
    [19878] = "Track Demons",
    [19879] = "Track Dragonkin",
    [19880] = "Track Elementals",
    [19882] = "Track Giants",
    [19885] = "Track Hidden",
    [19883] = "Track Humanoids",
    [SPELL_TRACK_HUMAN]   = "Track Humanoids",
    [19884] = "Track Undead",
    [5500]  = "Sense Demons",
    [5502]  = "Sense Undead"
}

-- Spells to cycle through in Farming Mode
local FARM_CYCLE = { 
    SPELL_FIND_HERBS, 
    SPELL_FIND_MINERALS, 
    SPELL_FIND_TREASURE 
}

-- Forms considered "Travel/Farming" (Cat, Travel, Flight, Mount)
local FARM_FORMS = {
    [3] = true, [27] = true, [29] = true, [16] = true
}

-- Branding & Tooltip Colors (Restored)
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

--------------------------------------------------------------------------------
-- 2. Variables & State
--------------------------------------------------------------------------------
local DB
local freeFrame
local ldbLauncher
local dropdown = CreateFrame("Frame", addonName.."Dropdown", UIParent, "UIDropDownMenuTemplate")
local eventFrame = CreateFrame("Frame")

local state = {
    currentIcon = ICON_DEFAULT,
    retryPending = false,
    retryCount = 0,
    farmIndex = 0,
    wasFarming = false,
    cycleCache = {}
}

--------------------------------------------------------------------------------
-- 3. Utility & Helpers
--------------------------------------------------------------------------------
local function IsCatForm()
    return GetShapeshiftFormID() == 3
end

local function IsFarmingForm()
    if UnitOnTaxi("player") then return false end
    if IsMounted() then return true end
    return FARM_FORMS[GetShapeshiftFormID() or 0] == true
end

local function CanCast()
    return not (UnitIsDeadOrGhost("player") or IsStealthed() or UnitCastingInfo("player") or UnitAffectingCombat("player"))
end

local function GetTrackingInfo(index)
    if C_Minimap and C_Minimap.GetTrackingInfo then
        return C_Minimap.GetTrackingInfo(index)
    end
    return GetTrackingInfo(index)
end

--------------------------------------------------------------------------------
-- 4. Visual Updates
--------------------------------------------------------------------------------
local function UpdateIcon()
    local tex = state.currentIcon
    
    -- Try to get live data from Minimap API
    if GetTrackingTexture then
        local active = GetTrackingTexture()
        if active then tex = active end
    end

    -- Fallback to DB selection if API fails (common on reload)
    if tex == ICON_DEFAULT and DB and DB.selectedSpellId then
        tex = GetSpellTexture(DB.selectedSpellId) or ICON_DEFAULT
    end

    -- Update LDB
    if ldbLauncher then ldbLauncher.icon = tex end

    -- Update Free Frame
    if freeFrame and freeFrame.icon then
        freeFrame.icon:SetTexture(tex)
    end
end

local function UpdatePlacement()
    if not DB then return end
    
    if DB.freePlacement then
        if LDBIcon then LDBIcon:Hide(addonName) end
        if freeFrame then freeFrame:Show(); UpdateIcon() end
    else
        if LDBIcon then LDBIcon:Show(addonName) end
        if freeFrame then freeFrame:Hide() end
    end
end

--------------------------------------------------------------------------------
-- 5. Tracking Logic
--------------------------------------------------------------------------------
local function IsTrackingActive(spellId)
    if not spellId then return false end
    
    -- Modern/C_Minimap Check
    local num = C_Minimap.GetNumTrackingTypes()
    for i = 1, num do
        local info = GetTrackingInfo(i)
        if info and info.active then
            -- Prefer Spell ID match
            if info.spellID and info.spellID == spellId then return true end
            -- Fallback to Texture match
            local icon = GetSpellTexture(spellId)
            if icon and info.texture and tostring(info.texture) == tostring(icon) then return true end
        end
    end
    return false
end

local function CastTracking(spellId)
    if not IsPlayerSpell(spellId) then return end
    if spellId == SPELL_TRACK_HUMAN and not IsCatForm() then return end
    pcall(CastSpellByID, spellId)
end

local function ReapplyTracking(isAuto)
    if not DB then return end
    if DB.farmingMode and IsFarmingForm() then return end
    if isAuto and not DB.autoTracking then return end
    
    local spellId = DB.selectedSpellId
    if not spellId or not CanCast() or IsTrackingActive(spellId) then return end

    -- Cooldown Check
    local start, duration = GetSpellCooldown(spellId)
    if start > 0 and duration > 0 then
        if not state.retryPending and state.retryCount < 5 then
            state.retryPending = true
            state.retryCount = state.retryCount + 1
            C_Timer.After((start + duration - GetTime()) + 0.1, function()
                state.retryPending = false
                ReapplyTracking(isAuto)
            end)
        end
        return
    end

    state.retryCount = 0
    CastTracking(spellId)
end

--------------------------------------------------------------------------------
-- 6. Farming Mode
--------------------------------------------------------------------------------
local function RunFarmLogic()
    if not DB then return end
    
    local inForm = IsFarmingForm()

    -- Exiting form: restore original tracking
    if not inForm and state.wasFarming then
        state.wasFarming = false
        ReapplyTracking(true)
        return
    end

    if not DB.farmingMode or not inForm or not CanCast() then return end

    -- Build cycle cache only when needed
    table.wipe(state.cycleCache)
    
    -- Add user selected spell first (if valid)
    if DB.selectedSpellId and DB.selectedSpellId ~= SPELL_TRACK_HUMAN then
        table.insert(state.cycleCache, DB.selectedSpellId)
    end

    -- Add remaining farm spells
    for _, id in ipairs(FARM_CYCLE) do
        if IsPlayerSpell(id) and id ~= DB.selectedSpellId then
            table.insert(state.cycleCache, id)
        end
    end

    if #state.cycleCache == 0 then return end

    -- Cycle
    state.farmIndex = state.farmIndex + 1
    if state.farmIndex > #state.cycleCache then state.farmIndex = 1 end
    
    local spellToCast = state.cycleCache[state.farmIndex]
    
    if not IsTrackingActive(spellToCast) then
        CastTracking(spellToCast)
    end
    
    state.wasFarming = true
end

--------------------------------------------------------------------------------
-- 7. Interaction & Menus
--------------------------------------------------------------------------------
local function OnClick(self, button)
    if not DB then return end

    if button == "MiddleButton" then
        DB.freePlacement = not DB.freePlacement
        UpdatePlacement()
        GameTooltip:Hide()
    elseif IsShiftKeyDown() then
        if button == "LeftButton" then DB.autoTracking = not DB.autoTracking
        elseif button == "RightButton" then DB.farmingMode = not DB.farmingMode end
        self:GetScript("OnEnter")(self) -- Refresh Tooltip
    elseif button == "RightButton" then
        CancelTrackingBuff()
        DB.selectedSpellId = nil
        state.currentIcon = ICON_DEFAULT
        UpdateIcon()
    elseif button == "LeftButton" then
        ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
    end
end

local function InitMenu(self, level)
    if level ~= 1 then return end
    
    local list = {}
    for id, name in pairs(TRACKING_SPELLS) do
        table.insert(list, { id = id, name = name })
    end
    table.sort(list, function(a,b) return a.name < b.name end)

    for _, data in ipairs(list) do
        local known = IsPlayerSpell(data.id)
        local druidCheck = (data.id ~= SPELL_TRACK_HUMAN or IsCatForm())

        if known and druidCheck then
            local info = UIDropDownMenu_CreateInfo()
            local icon = GetSpellTexture(data.id)
            info.text = string.format("|T%s:16|t %s", icon or "", data.name)
            info.value = data.id
            info.checked = (DB.selectedSpellId == data.id)
            info.func = function(btn)
                DB.selectedSpellId = btn.value
                state.wasFarming = false
                ReapplyTracking(false)
                UpdateIcon()
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

UIDropDownMenu_Initialize(dropdown, InitMenu, "MENU")

local function BuildTooltip(tooltip)
    -- Dynamic Version Check
    local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Dev"
    if version:find("@") then
        version = "Dev"
    end
    
    -- Header
    tooltip:AddDoubleLine(COLORS.TITLE .. addonTitle .. "|r", COLORS.MUTED .. version .. "|r")
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")
    
    -- Current State
    if DB and DB.selectedSpellId then
        local name = TRACKING_SPELLS[DB.selectedSpellId] or "Unknown"
        local icon = GetSpellTexture(DB.selectedSpellId)
        tooltip:AddLine("|T" .. icon .. ":16|t " .. COLORS.TEXT .. name .. "|r")
    else
        tooltip:AddLine("|TInterface\\Icons\\inv_misc_map_01:16|t " .. COLORS.DESC .. "No Tracking Selected|r")
    end
    tooltip:AddLine(" ")

    -- Setting: Persistent Tracking
    local auto = (DB and DB.autoTracking)
    local autoColor = auto and (COLORS.SUCCESS .. "Enabled|r") or (COLORS.DISABLED .. "Disabled|r")
    tooltip:AddDoubleLine(COLORS.TITLE .. "Persistent Tracking|r", autoColor)
    tooltip:AddLine(COLORS.DESC .. "Automatically recasts your tracking spell after resurrection.|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(COLORS.INFO .. "Shift + Left-Click|r", COLORS.INFO .. "Toggle|r")
    tooltip:AddLine(" ")

    -- Setting: Farming Mode
    local farm = (DB and DB.farmingMode)
    local farmColor = farm and (COLORS.SUCCESS .. "Enabled|r") or (COLORS.DISABLED .. "Disabled|r")
    tooltip:AddDoubleLine(COLORS.TITLE .. "Farming Mode|r", farmColor)
    tooltip:AddLine(COLORS.DESC .. "Cycles between Herbs, Minerals, and Treasure while mounted or in travel form.|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(COLORS.INFO .. "Shift + Right-Click|r", COLORS.INFO .. "Toggle|r")
    tooltip:AddLine(" ")

    -- Setting: Free Placement Mode
    local free = (DB and DB.freePlacement)
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

--------------------------------------------------------------------------------
-- 8. Initialization
--------------------------------------------------------------------------------
local function CreateFreeFrame()
    if freeFrame then return end
    local f = CreateFrame("Button", addonName.."FreeFrame", UIParent)
    f:SetSize(FRAME_SIZE, FRAME_SIZE)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:RegisterForClicks("AnyUp")
    f:SetClampedToScreen(true)
    
    f.bg = f:CreateTexture(nil, "BACKGROUND")
    f.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    f.bg:SetSize(ICON_SIZE, ICON_SIZE)
    f.bg:SetPoint("CENTER")
    f.bg:SetVertexColor(0,0,0,0.6)

    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(ICON_SIZE, ICON_SIZE)
    f.icon:SetPoint("CENTER")
    f.icon:SetTexture(ICON_DEFAULT)
    
    local mask = f:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
    mask:SetAllPoints(f.icon)
    f.icon:AddMaskTexture(mask)
    
    f.border = f:CreateTexture(nil, "OVERLAY")
    f.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    f.border:SetSize(62, 62)
    f.border:SetPoint("TOPLEFT", 0, 0)
    
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local a, _, b, x, y = self:GetPoint()
        DB.freePos = {a, b, x, y}
    end)
    f:SetScript("OnClick", OnClick)
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        BuildTooltip(GameTooltip)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", GameTooltip.Hide)

    if DB and DB.freePos then
        f:SetPoint(DB.freePos[1], UIParent, DB.freePos[2], DB.freePos[3], DB.freePos[4])
    else
        f:SetPoint("CENTER")
    end
    freeFrame = f
end

local function InitLDB()
    ldbLauncher = LDB:NewDataObject(addonName, {
        type = "launcher",
        text = addonTitle,
        icon = state.currentIcon,
        OnTooltipShow = function(tt)
            local b = LDBIcon:GetMinimapButton(addonName)
            if b then tt:SetOwner(b, "ANCHOR_NONE"); tt:SetPoint("TOPRIGHT", b, "BOTTOMLEFT") end
            BuildTooltip(tt)
        end,
        OnClick = OnClick
    })
    LDBIcon:Register(addonName, ldbLauncher, DB.minimap)
end

--------------------------------------------------------------------------------
-- 9. Events
--------------------------------------------------------------------------------
local events = {}

function events.ADDON_LOADED(name)
    if name ~= addonName then return end
    
    _G[addonName.."DB"] = _G[addonName.."DB"] or {}
    DB = _G[addonName.."DB"]
    
    DB.minimap = DB.minimap or {}
    if DB.autoTracking == nil then DB.autoTracking = true end
    if DB.farmingMode == nil then DB.farmingMode = true end
    
    if DB.selectedSpellId then
        state.currentIcon = GetSpellTexture(DB.selectedSpellId)
    end
    
    -- Initialize UI elements here, now that DB is guaranteed to exist
    InitLDB()
    CreateFreeFrame()
    
    C_Timer.NewTicker(0.5, UpdateIcon)
    C_Timer.NewTicker(FARM_INTERVAL, RunFarmLogic)
end

function events.PLAYER_LOGIN()
    -- Visual updates only. DB is already init from ADDON_LOADED.
    UpdateIcon()
    UpdatePlacement()
end

function events.UNIT_SPELLCAST_SUCCEEDED(unit, _, spellId)
    if unit == "player" and TRACKING_SPELLS[spellId] then
        state.currentIcon = GetSpellTexture(spellId)
        UpdateIcon()
        
        -- Don't update "Selected" preference if we are just cycling farm spells
        local isFarmSpell = (spellId == SPELL_FIND_HERBS or spellId == SPELL_FIND_MINERALS or spellId == SPELL_FIND_TREASURE)
        if not (DB.farmingMode and IsFarmingForm() and isFarmSpell) then
            DB.selectedSpellId = spellId
        end
    end
end

function events.PLAYER_ENTERING_WORLD()
    C_Timer.After(5, function() UpdateIcon(); ReapplyTracking(true) end)
end

local function ReapplyDelay() 
    C_Timer.After(0.5, function() ReapplyTracking(true) end) 
end

events.PLAYER_REGEN_ENABLED = ReapplyDelay
events.UPDATE_STEALTH = ReapplyDelay
events.PLAYER_UNGHOST = ReapplyDelay
events.PLAYER_ALIVE = ReapplyDelay
events.UPDATE_SHAPESHIFT_FORM = ReapplyDelay
events.MINIMAP_UPDATE_TRACKING = UpdateIcon

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if events[event] then events[event](...) end
end)

for event in pairs(events) do
    eventFrame:RegisterEvent(event)
end
