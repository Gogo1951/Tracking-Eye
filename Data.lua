local _, te = ...

--------------------------------------------------------------------------------
-- Constants & Config
--------------------------------------------------------------------------------
te.ICON_DEFAULT = "Interface\\Icons\\inv_misc_map_01"
te.FARM_INTERVAL = 2.0

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
    HUMANOIDS = 19883, -- Hunter Version
    UNDEAD = 19884,
    -- Druid Tracking
    DRUID_HUMANOIDS = 5225, -- Druid Version (Cat Form)
    -- Warlock/Paladin/Other
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

te.FARM_CYCLE = {
    te.SPELLS.HERBS,
    te.SPELLS.MINERALS,
    te.SPELLS.TREASURE
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

function te.GetColor(key)
    return "|cff" .. (te.COLORS[key] or "FFFFFF")
end

function te.GetSpellName(spellID)
    local name = GetSpellInfo(spellID)
    return name

end
