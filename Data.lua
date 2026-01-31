local _, ns = ...

--------------------------------------------------------------------------------
-- Constants & Config
--------------------------------------------------------------------------------
ns.ICON_DEFAULT = "Interface\\Icons\\inv_misc_map_01"
ns.FARM_INTERVAL = 4.0
ns.COLOR_PREFIX = "|cff"

ns.SPELLS = {
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
    HUMANOIDS = 19883, -- Hunter Version
    UNDEAD = 19884,

    -- Druid Tracking
    DRUID_HUMANOIDS = 5225, -- Druid Version (Cat Form)

    -- Warlock/Paladin/Other
    SENSE_DEMONS = 5500,
    SENSE_UNDEAD = 5502
}

ns.FARM_FORMS = {
    [ns.SPELLS.TRAVEL] = true,
    [ns.SPELLS.AQUATIC] = true,
    [ns.SPELLS.FLIGHT] = true,
    [ns.SPELLS.SWIFT_FLIGHT] = true
}

ns.TRACKING_IDS = {
    ns.SPELLS.FISH,
    ns.SPELLS.HERBS,
    ns.SPELLS.MINERALS,
    ns.SPELLS.TREASURE,
    ns.SPELLS.BEASTS,
    ns.SPELLS.DEMONS,
    ns.SPELLS.DRAGONKIN,
    ns.SPELLS.ELEMENTALS,
    ns.SPELLS.GIANTS,
    ns.SPELLS.HIDDEN,
    ns.SPELLS.HUMANOIDS,
    ns.SPELLS.DRUID_HUMANOIDS,
    ns.SPELLS.UNDEAD,
    ns.SPELLS.SENSE_DEMONS,
    ns.SPELLS.SENSE_UNDEAD
}

ns.FARM_CYCLE = {
    ns.SPELLS.FISH, 
    ns.SPELLS.HERBS, 
    ns.SPELLS.MINERALS, 
    ns.SPELLS.TREASURE
}

ns.COLORS = {
    TITLE = "FFD100",
    INFO = "00BBFF",
    DESC = "CCCCCC",
    TEXT = "FFFFFF",
    SUCCESS = "33CC33",
    DISABLED = "CC3333",
    SEP = "AAAAAA",
    MUTED = "808080"
}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------
function ns.GetSpellName(spellID)
    if not spellID then return nil end
    local spellInfo = C_Spell and C_Spell.GetSpellInfo(spellID)
    if spellInfo then return spellInfo.name end
    return GetSpellInfo(spellID)
end

function ns.GetColor(key)
    return ns.COLOR_PREFIX .. (ns.COLORS[key] or "FFFFFF")
end
