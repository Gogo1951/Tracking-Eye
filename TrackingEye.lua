local ADDON_NAME = "TrackingEye"
local addonTable = ...

local DEFAULT_MINIMAP_ICON = "Interface\\Icons\\inv_misc_map_01"
local MINIMAP_RADIUS = 80
local DRUID_CAT_FORM_SPELL_ID = 768

local function InitializeSavedVariables()
    if not _G[ADDON_NAME .. "DB"] or type(_G[ADDON_NAME .. "DB"]) ~= "table" then
        _G[ADDON_NAME .. "DB"] = {}
    end
    local db = _G[ADDON_NAME .. "DB"]

    if not db.minimapPos or type(db.minimapPos) ~= "number" then
        db.minimapPos = 159.03
    end
    if db.selectedSpellId and type(db.selectedSpellId) ~= "number" then
        db.selectedSpellId = nil
    end
end

if not IsAddOnLoaded("Blizzard_UIDropDownMenu") then
    LoadAddOn("Blizzard_UIDropDownMenu")
end

local dropdown = CreateFrame("Frame", ADDON_NAME .. "Dropdown", UIParent, "UIDropDownMenuTemplate")

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
    [5502] = "Sense Undead",
}

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

local function ReapplyTracking()
    local db = _G[ADDON_NAME .. "DB"]
    local spellId = db.selectedSpellId
    if spellId and IsPlayerSpell(spellId) then
        if spellId == 5225 and not IsDruidInCatForm() then
            return
        end
        CastSpellByID(spellId)
    end
end

local function ClearTrackingSelection()
    local db = _G[ADDON_NAME .. "DB"]
    CancelTrackingBuff()
    db.selectedSpellId = nil
end

local function GetMinimapOffset(angle, radius)
    local rad = math.rad(angle)
    return math.cos(rad) * radius, math.sin(rad) * radius
end

local function BuildMenu(self, level)
    if level ~= 1 then
        return
    end

    local db = _G[ADDON_NAME .. "DB"]
    local info = UIDropDownMenu_CreateInfo()

    info.text = "Select Tracking Ability"
    info.isTitle = true
    info.notCheckable = true
    UIDropDownMenu_AddButton(info, level)

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

    local hasAnyAvailableTracking = false

    for _, spellData in ipairs(spellList) do
        local spellId = spellData.id
        local spellName = spellData.name

        local isAvailable = IsPlayerSpell(spellId) and (spellId ~= 5225 or IsDruidInCatForm())

        if isAvailable then
            hasAnyAvailableTracking = true
            local icon = GetSpellTexture(spellId)

            info = UIDropDownMenu_CreateInfo()
            info.text = spellName
            if icon then
                info.text = "|T" .. icon .. ":16:16:0:0:64:64:5:59:5:59|t " .. spellName
            end
            info.value = {spellId = spellId}
            info.checked = (db.selectedSpellId == spellId)
            info.func = function(self)
                local idToCast = self.value.spellId
                local current_db = _G[ADDON_NAME .. "DB"]
                current_db.selectedSpellId = idToCast
                CastSpellByID(idToCast)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end

    if not hasAnyAvailableTracking then
        info = UIDropDownMenu_CreateInfo()
        info.text = "No Tracking Skills Available"
        info.disabled = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)
    end
end

local button = CreateFrame("Button", ADDON_NAME .. "MinimapButton", Minimap)
button:SetSize(32, 32)
button:SetFrameStrata("MEDIUM")
button:SetMovable(true)
button:EnableMouse(true)
button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
button:RegisterForDrag("LeftButton")
button:SetClampedToScreen(true)
button:Hide()

button.icon = button:CreateTexture(nil, "ARTWORK")
button.icon:SetTexture(DEFAULT_MINIMAP_ICON)
button.icon:SetAllPoints()

local function ShowTooltip(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
    GameTooltip:AddLine(ADDON_NAME)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Left-click : Select Tracking", 1, 1, 1)
    GameTooltip:AddLine("Right-click : Clear Tracking", 1, 1, 1)
    GameTooltip:Show()
end

button:SetScript("OnEnter", ShowTooltip)
button:SetScript("OnLeave", GameTooltip_Hide)

button:SetScript(
    "OnClick",
    function(self, buttonPressed)
        if buttonPressed == "RightButton" then
            ClearTrackingSelection()
        else
            UIDropDownMenu_Initialize(dropdown, BuildMenu, "MENU")
            ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
        end
    end
)

local function OnDragUpdate(self)
    local db = _G[ADDON_NAME .. "DB"]
    local mx, my = Minimap:GetCenter()
    local px, py = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    px, py = px / scale, py / scale
    local angle = math.deg(math.atan2(py - my, px - mx))
    if angle < 0 then
        angle = angle + 360
    end
    db.minimapPos = angle
    local x, y = GetMinimapOffset(angle, MINIMAP_RADIUS)
    self:ClearAllPoints()
    self:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

button:SetScript(
    "OnDragStart",
    function(self)
        self:SetScript("OnUpdate", OnDragUpdate)
    end
)

button:SetScript(
    "OnDragStop",
    function(self)
        self:SetScript("OnUpdate", nil)
        OnDragUpdate(self)
    end
)

local function PositionButton()
    local db = _G[ADDON_NAME .. "DB"]
    local angle = db.minimapPos
    local x, y = GetMinimapOffset(angle, MINIMAP_RADIUS)
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function UpdateButtonIcon()
    local currentTrackingTexture = GetTrackingTexture()
    if currentTrackingTexture then
        button.icon:SetTexture(currentTrackingTexture)
    else
        button.icon:SetTexture(DEFAULT_MINIMAP_ICON)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("PLAYER_UNGHOST")
eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
eventFrame:RegisterEvent("MINIMAP_UPDATE_TRACKING")

eventFrame:SetScript(
    "OnEvent",
    function(self, event, ...)
        local arg1 = ...
        local db = _G[ADDON_NAME .. "DB"]

        if event == "ADDON_LOADED" and arg1 == ADDON_NAME then
            InitializeSavedVariables()
            PositionButton()
            button:Show()
        elseif event == "PLAYER_LOGIN" then
            C_Timer.After(2, ReapplyTracking)
            UpdateButtonIcon()
        elseif event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
            C_Timer.After(0.5, ReapplyTracking)
        elseif event == "UPDATE_SHAPESHIFT_FORM" then
            if db.selectedSpellId == 5225 and IsDruidInCatForm() then
                if not GetTrackingTexture() then
                    ReapplyTracking()
                end
            end

            UpdateButtonIcon()
        elseif event == "MINIMAP_UPDATE_TRACKING" then
            UpdateButtonIcon()
        end
    end
)
