local ADDON_NAME, ns = ...
ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

--------------------------------------------------------------------------------
-- Constants & Config
--------------------------------------------------------------------------------
ns.ICON_DEFAULT = "Interface\\Icons\\inv_misc_map_01"
ns.CURSEFORGE_URL = "https://www.curseforge.com/wow/addons/tracking-eye-classic"
ns.DISCORD_URL = "https://discord.gg/eh8hKq992Q"
ns.GITHUB_URL = "https://github.com/Gogo1951/Tracking-Eye"

--[[
    AceConfig registry names, derived from ADDON_NAME. Stable identifiers
    referenced by NotifyChange across modules — never build them inline.
]]
ns.OPTIONS_REGISTRY = {
    General = ADDON_NAME,
    Diagnostics = ADDON_NAME .. "_Diagnostics"
}

ns.SHAPES = {
    CIRCLE = "circle",
    SQUARE = "square"
}

--------------------------------------------------------------------------------
-- Spells
--------------------------------------------------------------------------------

--[[

SELECT
    Id        AS spell_id,
    SpellName AS spell_name,
    CASE
        WHEN Id IN (768, 783, 1066, 33943, 40120, 5225)         THEN 'Druid'
        WHEN Id IN (1494, 19878, 19879, 19880, 19882, 19883,
                    19884, 19885)                                THEN 'Hunter'
        WHEN Id = 5500                                           THEN 'Warlock'
        WHEN Id = 5502                                           THEN 'Paladin'
        WHEN Id = 2383                                           THEN 'Herbalism'
        WHEN Id = 2580                                           THEN 'Mining'
        WHEN Id = 43308                                          THEN 'Fishing'
        WHEN Id = 2481                                           THEN 'Dwarf'
    END AS source
FROM spell_template
WHERE Id IN (
    768, 783, 1066, 33943, 40120, 43308, 2383, 2580, 2481, 1494, 19878, 19879, 19880, 19882, 19885, 19883, 19884, 5225, 5500, 5502
)
ORDER BY FIELD(source,'Druid','Hunter','Warlock','Paladin','Herbalism','Mining','Fishing','Dwarf'), Id;

]]

-- Names and icons are resolved at runtime (GetSpellInfo/GetSpellTexture) so they localize automatically; only the stable IDs are stored here.
-- { spellId, key, source }
local SPELL_DATA = {
    -- Druid Forms
    {768, "CAT", "Druid"}, -- Cat Form
    {783, "TRAVEL", "Druid"}, -- Travel Form
    {1066, "AQUATIC", "Druid"}, -- Aquatic Form
    {33943, "FLIGHT", "Druid"}, -- Flight Form
    {40120, "SWIFT_FLIGHT", "Druid"}, -- Swift Flight Form
    -- Druid Tracking
    {5225, "DRUID_HUMANOIDS", "Druid"}, -- Track Humanoids (Cat Form only)
    -- Hunter Tracking
    {1494, "BEASTS", "Hunter"}, -- Track Beasts
    {19878, "DEMONS", "Hunter"}, -- Track Demons
    {19879, "DRAGONKIN", "Hunter"}, -- Track Dragonkin
    {19880, "ELEMENTALS", "Hunter"}, -- Track Elementals
    {19882, "GIANTS", "Hunter"}, -- Track Giants
    {19883, "HUMANOIDS", "Hunter"}, -- Track Humanoids
    {19884, "UNDEAD", "Hunter"}, -- Track Undead
    {19885, "HIDDEN", "Hunter"}, -- Track Hidden
    -- Warlock Tracking
    {5500, "SENSE_DEMONS", "Warlock"}, -- Sense Demons
    -- Paladin Tracking
    {5502, "SENSE_UNDEAD", "Paladin"}, -- Sense Undead
    -- Profession & Racial
    {2383, "HERBS", "Herbalism"}, -- Find Herbs
    {2580, "MINERALS", "Mining"}, -- Find Minerals
    {43308, "FISH", "Fishing"}, -- Find Fish
    {2481, "TREASURE", "Dwarf"} -- Find Treasure
}

ns.SPELLS = {}
for _, row in ipairs(SPELL_DATA) do
    ns.SPELLS[row[2]] = row[1]
end

ns.FARM_FORMS = {
    [ns.SPELLS.TRAVEL] = true,
    [ns.SPELLS.AQUATIC] = true,
    [ns.SPELLS.FLIGHT] = true,
    [ns.SPELLS.SWIFT_FLIGHT] = true
}

--[[
    Non-druid persistent movement states that activate Farm Mode, detected by
    buff: Hunter Aspect of the Cheetah / Pack and Shaman Ghost Wolf. Druid travel
    and flight forms are in ns.FARM_FORMS above.
]]
ns.GHOST_WOLF = 2645
ns.ASPECT_CHEETAH = 5118
ns.ASPECT_PACK = 13159
ns.CHEETAH_BUFFS = {
    [ns.ASPECT_CHEETAH] = true,
    [ns.ASPECT_PACK] = true
}

local FORM_KEYS = {CAT = true, TRAVEL = true, AQUATIC = true, FLIGHT = true, SWIFT_FLIGHT = true}
ns.TRACKING_IDS = {}
for _, row in ipairs(SPELL_DATA) do
    if not FORM_KEYS[row[2]] then
        table.insert(ns.TRACKING_IDS, row[1])
    end
end

-- Hash set built from TRACKING_IDS for O(1) lookups in UNIT_SPELLCAST_SUCCEEDED
ns.TRACKING_SET = {}
for _, id in ipairs(ns.TRACKING_IDS) do
    ns.TRACKING_SET[id] = true
end

-- Restricted Zones

ns.RESTRICTED_MAP_IDS = {
    [369] = true,  -- Deeprun Tram
}

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

--[[
    Raw hex palette. The derived COLORS table, the |cff prefix, and the GetColor
    accessor live in Features/Utilities.lua (Data files hold no logic).
]]
ns.HEX = {
    TITLE = "FFD100", -- Gold: Titles, Headers, Section Names
    INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
    BODY = "CCCCCC", -- Silver: Descriptions, Help Text
    TEXT = "FFFFFF", -- White: Messages, Values, Spell Names
    ON = "33CC33", -- Green: On
    OFF = "CC3333", -- Red: Off
    SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
    MUTED = "808080" -- Dark Gray: Meta-data, Version Numbers
}
