local ADDON_NAME = "TrackingEye"

--------------------------------------------------------------------------------
-- Dependencies
--------------------------------------------------------------------------------
local LibStub = LibStub
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Constants & Data
--------------------------------------------------------------------------------
local DEFAULT_MINIMAP_ICON = "Interface\\Icons\\inv_misc_map_01"
local DRUID_CAT_FORM_SPELL_ID = 768

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
    [5225] = "Track Humanoids", -- Druid
    [19884] = "Track Undead",
    [5500] = "Sense Demons",
    [5502] = "Sense Undead"
}

local TrackingEyeDB
local trackingLauncher
local isRetryPending = false
local retryCount = 0

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

local function HasAnyTrackingSpell()
    for spellId, _ in pairs(trackingSpells) do
        if IsPlayerSpell(spellId) then
            return true
        end
    end
    return false
end

local function IsDruidInCatForm()
    if select(2, UnitClass("player")) ~= "DRUID" then
        return false
    end
    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, spellId = UnitBuff("player", i)
        if spellId == DRUID_CAT_FORM_SPELL_ID then
            return true
        end
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

local function GetTrackingIconTexture()
    local selectedId = TrackingEyeDB.selectedSpellId
    if selectedId then
        local icon = GetSpellTexture(selectedId)
        if icon then
            return icon
        end
    end
    return DEFAULT_MINIMAP_ICON
end

local function UpdateButtonIcon()
    if trackingLauncher then
        trackingLauncher.icon = GetTrackingIconTexture()
    end
end

local function ClearTrackingSelection()
    CancelTrackingBuff()
    TrackingEyeDB.selectedSpellId = nil
    UpdateButtonIcon()
end

local function ToggleAutoTracking()
    TrackingEyeDB.autoTracking = not TrackingEyeDB.autoTracking
end

--------------------------------------------------------------------------------
-- Core Logic: Reapply Tracking
--------------------------------------------------------------------------------

local function ReapplyTracking(isAutoTrigger)
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

    local start, duration = GetSpellCooldown(spellId)
    if start > 0 and duration > 0 then
        if not isRetryPending and retryCount < 5 then
            isRetryPending = true
            retryCount = retryCount + 1
            local remaining = (start + duration) - GetTime()
            C_Timer.After(
                remaining + 0.1,
                function()
                    isRetryPending = false
                    ReapplyTracking(isAutoTrigger)
                end
            )
        end
        return
    end

    retryCount = 0

    local currentTracking = GetTrackingTexture()
    local selectedIcon = GetSpellTexture(spellId)

    if currentTracking and selectedIcon and currentTracking == selectedIcon then
        return
    end

    if IsPlayerSpell(spellId) then
        if spellId == 5225 and not IsDruidInCatForm() then
            return
        end

        pcall(CastSpellByID, spellId)
    end
end

--------------------------------------------------------------------------------
-- Dropdown Menu
--------------------------------------------------------------------------------

if not IsAddOnLoaded("Blizzard_UIDropDownMenu") then
    LoadAddOn("Blizzard_UIDropDownMenu")
end

local dropdown = CreateFrame("Frame", ADDON_NAME .. "Dropdown", UIParent, "UIDropDownMenuTemplate")

local function BuildMenu(self, level)
    if level ~= 1 then
        return
    end

    local info
    local spellList = {}

    for id, name in pairs(trackingSpells) do
        table.insert(spellList, {id = id, name = name})
    end

    table.sort(
        spellList,
        function(a, b)
            return a.name < b.name
        end
    )

    for _, spellData in ipairs(spellList) do
        local spellId = spellData.id
        local spellName = spellData.name
        local isAvailable = IsPlayerSpell(spellId) and (spellId ~= 5225 or IsDruidInCatForm())

        if isAvailable then
            local icon = GetSpellTexture(spellId)

            info = UIDropDownMenu_CreateInfo()
            info.text = spellName
            if icon then
                info.text = "|T" .. icon .. ":16:16:0:0:64:64:5:59:5:59|t " .. spellName
            end
            info.value = {spellId = spellId}
            info.checked = (TrackingEyeDB.selectedSpellId == spellId)
            info.func = function(self)
                local idToCast = self.value.spellId
                TrackingEyeDB.selectedSpellId = idToCast
                UpdateButtonIcon()
                ReapplyTracking(false)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

UIDropDownMenu_Initialize(dropdown, BuildMenu, "MENU")

--------------------------------------------------------------------------------
-- LDB Initialization
--------------------------------------------------------------------------------

local function InitLDB()
    if not HasAnyTrackingSpell() then
        return
    end

    trackingLauncher =
        LDB:NewDataObject(
        ADDON_NAME,
        {
            type = "launcher",
            text = "Tracking Eye",
            icon = GetTrackingIconTexture(),
            OnTooltipShow = function(tooltip)
                local version = C_AddOns and C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "Dev"
                if version:find("@") then
                    version = "Dev"
                end

                tooltip:AddDoubleLine(ADDON_NAME, "|cFFAAAAAA" .. version .. "|r", 1, 0.82, 0, 1, 1, 1)
                tooltip:AddLine(" ")

                if TrackingEyeDB.selectedSpellId then
                    local name = trackingSpells[TrackingEyeDB.selectedSpellId] or "Unknown"
                    local icon = GetSpellTexture(TrackingEyeDB.selectedSpellId)
                    tooltip:AddLine("|T" .. icon .. ":16|t |cFFFFFFFF" .. name .. "|r")
                else
                    tooltip:AddLine("|cFFAAAAAANo Tracking Selected|r")
                end

                tooltip:AddLine(" ")
                local autoColor = TrackingEyeDB.autoTracking and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
                tooltip:AddDoubleLine("Persistent Tracking", autoColor)
                tooltip:AddLine(" ")
                tooltip:AddDoubleLine("|cFF00BBFFLeft-Click|r", "|cFFFFFFFFTracking Menu|r")
                tooltip:AddDoubleLine("|cFF00BBFFRight-Click|r", "|cFFFFFFFFClear Tracking|r")
                tooltip:AddDoubleLine("|cFF00BBFFMiddle-Click|r", "|cFFFFFFFFToggle Persistent Tracking|r")
            end,
            OnClick = function(self, button)
                if button == "RightButton" then
                    ClearTrackingSelection()
                elseif button == "MiddleButton" then
                    ToggleAutoTracking()
                    local onEnter = self:GetScript("OnEnter")
                    if onEnter then
                        onEnter(self)
                    end
                else
                    local dropDown = _G[ADDON_NAME .. "Dropdown"]
                    ToggleDropDownMenu(1, nil, dropDown, self, 0, 0)
                end
            end
        }
    )

    if LDBIcon then
        LDBIcon:Register(ADDON_NAME, trackingLauncher, TrackingEyeDB.minimap)
    end
end

--------------------------------------------------------------------------------
-- Event Handling & Synchronization
--------------------------------------------------------------------------------

local function SyncFromGameStatus()
    local currentTexture = GetTrackingTexture()
    if not currentTexture then
        return
    end

    local found = false
    for spellId, _ in pairs(trackingSpells) do
        if GetSpellTexture(spellId) == currentTexture and IsPlayerSpell(spellId) then
            TrackingEyeDB.selectedSpellId = spellId
            UpdateButtonIcon()
            found = true
            break
        end
    end
end

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

eventFrame:SetScript(
    "OnEvent",
    function(self, event, ...)
        local arg1 = ...

        if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
            TrackingEyeDB = _G[ADDON_NAME .. "DB"]

            if not TrackingEyeDB or type(TrackingEyeDB) ~= "table" then
                TrackingEyeDB = {}
                _G[ADDON_NAME .. "DB"] = TrackingEyeDB
            end

            TrackingEyeDB.minimap = TrackingEyeDB.minimap or {}

            if TrackingEyeDB.autoTracking == nil then
                TrackingEyeDB.autoTracking = true
            end
        elseif event == "PLAYER_LOGIN" then
            InitLDB()
            SyncFromGameStatus()
        elseif event == "MINIMAP_UPDATE_TRACKING" then
            SyncFromGameStatus()
        elseif event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(
                1.0,
                function()
                    SyncFromGameStatus()
                    ReapplyTracking(true)
                end
            )
        elseif
            event == "PLAYER_REGEN_ENABLED" or 
                event == "UPDATE_STEALTH" or 
                event == "PLAYER_UNGHOST" or
                event == "PLAYER_ALIVE"
         then
            C_Timer.After(
                0.5,
                function()
                    ReapplyTracking(true)
                end
            )
        elseif event == "UPDATE_SHAPESHIFT_FORM" then
            if TrackingEyeDB.selectedSpellId == 5225 and IsDruidInCatForm() then
                ReapplyTracking(true)
            end
        end
    end
)
