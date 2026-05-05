local _, te = ...
te.L = LibStub("AceLocale-3.0"):GetLocale("TrackingEye")

--------------------------------------------------------------------------------
-- Constants & Config
--------------------------------------------------------------------------------
te.ICON_DEFAULT = "Interface\\Icons\\inv_misc_map_01"
te.CURSEFORGE_URL = "https://www.curseforge.com/wow/addons/tracking-eye-classic"
te.DISCORD_URL = "https://discord.gg/eh8hKq992Q"
te.GITHUB_URL = "https://github.com/Gogo1951/Tracking-Eye"

te.SHAPES = {
    CIRCLE = "circle",
    SQUARE = "square"
}

--------------------------------------------------------------------------------
-- Default Values
--------------------------------------------------------------------------------

-- TrackingEyeCharDB (per-character) scalar defaults.
-- selectedSpellId, lastIcon, and farmCycleSpells are intentionally
-- absent: nil cannot be stored in a Lua table, and farmCycleSpells
-- is a nested table that must be deep-copied on each init/reset
-- (see te.FARM_CYCLE_DEFAULTS below).
te.CHAR_DEFAULTS = {
    autoTracking = true,
    farmingMode = true,
    farmInterval = 3.5,
    showWelcome = true
}

-- TrackingEyeGlobalDB (account-wide) scalar defaults.
-- minimap is intentionally absent — LibDBIcon writes into it, and
-- it must be initialized as an empty table separately.
te.GLOBAL_DEFAULTS = {
    freePlacement = false,
    freeIconScale = 1.1,
    freeIconShape = te.SHAPES.CIRCLE
}

--------------------------------------------------------------------------------
-- Spells
--------------------------------------------------------------------------------
te.SPELLS = {
    -- Farming & Travel Forms
    CAT = 768,
    TRAVEL = 783,
    AQUATIC = 1066,
    FLIGHT = 33943,
    SWIFT_FLIGHT = 40120,
    -- Tracking Spells
    FISH = 43308,
    HERBS = 2383,
    MINERALS = 2580,
    TREASURE = 2481,
    -- Hunter Tracking
    BEASTS = 1494,
    DEMONS = 19878,
    DRAGONKIN = 19879,
    ELEMENTALS = 19880,
    GIANTS = 19882,
    HIDDEN = 19885,
    HUMANOIDS = 19883, -- Hunter version
    UNDEAD = 19884,
    -- Druid Tracking
    DRUID_HUMANOIDS = 5225, -- Druid version (Cat Form only)
    -- Warlock / Paladin
    SENSE_DEMONS = 5500,
    SENSE_UNDEAD = 5502
}

te.FARM_FORMS = {
    [te.SPELLS.TRAVEL] = true,
    [te.SPELLS.AQUATIC] = true,
    [te.SPELLS.FLIGHT] = true,
    [te.SPELLS.SWIFT_FLIGHT] = true
}

te.TRACKING_IDS = {
    te.SPELLS.FISH,
    te.SPELLS.HERBS,
    te.SPELLS.MINERALS,
    te.SPELLS.TREASURE,
    te.SPELLS.BEASTS,
    te.SPELLS.DEMONS,
    te.SPELLS.DRAGONKIN,
    te.SPELLS.ELEMENTALS,
    te.SPELLS.GIANTS,
    te.SPELLS.HIDDEN,
    te.SPELLS.HUMANOIDS,
    te.SPELLS.DRUID_HUMANOIDS,
    te.SPELLS.UNDEAD,
    te.SPELLS.SENSE_DEMONS,
    te.SPELLS.SENSE_UNDEAD
}

-- Hash set built from TRACKING_IDS for O(1) lookups in UNIT_SPELLCAST_SUCCEEDED
te.TRACKING_SET = {}
for _, id in ipairs(te.TRACKING_IDS) do
    te.TRACKING_SET[id] = true
end

--------------------------------------------------------------------------------
-- Farm Cycle Defaults
--------------------------------------------------------------------------------

-- Only Herbs and Minerals enabled by default; all others off
te.FARM_CYCLE_DEFAULTS = {
    [te.SPELLS.HERBS] = true,
    [te.SPELLS.MINERALS] = true
}

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------
te.COLORS = {
    TITLE = "FFD100",
    INFO = "00BBFF",
    DESC = "CCCCCC",
    TEXT = "FFFFFF",
    SUCCESS = "33CC33",
    DISABLED = "CC3333",
    SEP = "AAAAAA",
    MUTED = "808080"
}
