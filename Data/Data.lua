local ADDON_NAME, ns = ...
ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

--------------------------------------------------------------------------------
-- Constants & Config
--------------------------------------------------------------------------------
ns.ICON_DEFAULT = "Interface\\Icons\\inv_misc_map_01"
-- Vertex tint applied to the tracking icon while Farm Mode is paused (1 is untinted).
ns.ICON_PAUSED_TINT = 0.45
ns.CURSEFORGE_URL = "https://www.curseforge.com/wow/addons/tracking-eye-classic"
ns.DISCORD_URL = "https://discord.gg/eh8hKq992Q"
ns.GITHUB_URL = "https://github.com/Gogo1951/Tracking-Eye"
ns.WAGO_URL = "https://addons.wago.io/addons/tracking-eye"

--[[
    AceConfig registry names, derived from ADDON_NAME. Stable identifiers
    referenced by NotifyChange across modules — never build them inline.
]]
ns.OPTIONS_REGISTRY = {
	General = ADDON_NAME,
	FarmMode = ADDON_NAME .. "_FarmMode",
	Profiles = ADDON_NAME .. "_Profiles",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

--------------------------------------------------------------------------------
-- Options Grid
--------------------------------------------------------------------------------

-- Label plus control always total OPTIONS_ROW_WIDTH, so every row ends where every other row ends.
ns.OPTIONS_ROW_WIDTH = 2.6
ns.OPTIONS_LABEL_WIDTH = 1.3
ns.OPTIONS_CONTROL_WIDTH = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_LABEL_WIDTH
ns.OPTIONS_REMOVE_ICON_WIDTH = 0.25 -- the item lists' remove column, sized to its icon
ns.OPTIONS_SUB_INDENT_WIDTH = 0.115 -- the blank cell a sub-option row leads with

ns.SHAPES = {
	CIRCLE = "circle",
	SQUARE = "square",
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
	{ 768, "CAT", "Druid" }, -- Cat Form
	{ 783, "TRAVEL", "Druid" }, -- Travel Form
	{ 1066, "AQUATIC", "Druid" }, -- Aquatic Form
	{ 33943, "FLIGHT", "Druid" }, -- Flight Form
	{ 40120, "SWIFT_FLIGHT", "Druid" }, -- Swift Flight Form
	-- Druid Tracking
	{ 5225, "DRUID_HUMANOIDS", "Druid" }, -- Track Humanoids (Cat Form only)
	-- Hunter Tracking
	{ 1494, "BEASTS", "Hunter" }, -- Track Beasts
	{ 19878, "DEMONS", "Hunter" }, -- Track Demons
	{ 19879, "DRAGONKIN", "Hunter" }, -- Track Dragonkin
	{ 19880, "ELEMENTALS", "Hunter" }, -- Track Elementals
	{ 19882, "GIANTS", "Hunter" }, -- Track Giants
	{ 19883, "HUMANOIDS", "Hunter" }, -- Track Humanoids
	{ 19884, "UNDEAD", "Hunter" }, -- Track Undead
	{ 19885, "HIDDEN", "Hunter" }, -- Track Hidden
	-- Warlock Tracking
	{ 5500, "SENSE_DEMONS", "Warlock" }, -- Sense Demons
	-- Paladin Tracking
	{ 5502, "SENSE_UNDEAD", "Paladin" }, -- Sense Undead
	-- Profession & Racial
	{ 2383, "HERBS", "Herbalism" }, -- Find Herbs
	{ 2580, "MINERALS", "Mining" }, -- Find Minerals
	{ 43308, "FISH", "Fishing" }, -- Find Fish
	{ 2481, "TREASURE", "Dwarf" }, -- Find Treasure
}

ns.SPELLS = {}
for _, row in ipairs(SPELL_DATA) do
	ns.SPELLS[row[2]] = row[1]
end

ns.FARM_FORMS = {
	[ns.SPELLS.TRAVEL] = true,
	[ns.SPELLS.AQUATIC] = true,
	[ns.SPELLS.FLIGHT] = true,
	[ns.SPELLS.SWIFT_FLIGHT] = true,
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
	[ns.ASPECT_PACK] = true,
}

--[[
    Movement state -> the profile toggle that decides whether Farm Mode runs in
    it, and -> the class that owns it (nil means every class). One table so the
    detection, the per-state toggles, and the paused-reason messages can never
    disagree about which states exist.
]]
ns.MOVEMENT_STATE_TOGGLES = {
	mounted = "farmMounted",
	travelForms = "farmTravelForms",
	cheetah = "farmCheetah",
	ghostWolf = "farmGhostWolf",
	foot = "farmNotMounted",
	-- No taxi entry: a flight path bails out before this table is ever read.
}

ns.MOVEMENT_STATE_CLASS = {
	travelForms = "DRUID",
	cheetah = "HUNTER",
	ghostWolf = "SHAMAN",
}

local FORM_KEYS = { CAT = true, TRAVEL = true, AQUATIC = true, FLIGHT = true, SWIFT_FLIGHT = true }
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

--------------------------------------------------------------------------------
-- Creature Types
--------------------------------------------------------------------------------

--[[
    Creature type -> tracking spell, used by Target Tracking. UnitCreatureType
    returns a LOCALIZED string, so the map is keyed by the client's own localized
    creature-type globals rather than by English literals — that is what keeps
    the feature working in every locale with no locale file entries of its own.
    A global the client does not define is skipped rather than creating a nil
    key. Spell IDs come from ns.SPELLS so they are never written down twice.
]]
--[[
    A creature type can be covered by more than one spell across classes: Undead
    by the Hunter's Track Undead or the Paladin's Sense Undead, Demons by Track
    Demons or Sense Demons. Candidates are listed in preference order and resolved
    per character by ns.GetCreatureTypeSpell, so every class gets whatever it can
    actually track.

    Druid Track Humanoids is deliberately absent: it requires Cat Form, so setting
    it as the persistent ability would leave a spell that mostly cannot be cast.
]]
local CREATURE_TYPE_DATA = {
	-- { global string name, English fallback, ns.SPELLS keys in preference order }
	{ "BEAST", "Beast", { "BEASTS" } },
	{ "DEMON", "Demon", { "DEMONS", "SENSE_DEMONS" } },
	{ "DRAGONKIN", "Dragonkin", { "DRAGONKIN" } },
	{ "ELEMENTAL", "Elemental", { "ELEMENTALS" } },
	{ "GIANT", "Giant", { "GIANTS" } },
	{ "HUMANOID", "Humanoid", { "HUMANOIDS" } },
	{ "UNDEAD", "Undead", { "UNDEAD", "SENSE_UNDEAD" } },
}

--[[
    Both the client's localized global AND the English literal are registered as
    keys. The globals are what make this work in every locale, but they cannot be
    relied on to exist: a missing one used to drop its whole entry at build time,
    and the feature then failed silently for that creature type. The English
    fallback means an enUS client works no matter what, and a localized client
    still resolves through its global.
]]
ns.CREATURE_TYPE_SPELLS = {}
for _, row in ipairs(CREATURE_TYPE_DATA) do
	local ids = {}
	for _, key in ipairs(row[3]) do
		local spellId = ns.SPELLS[key]
		if spellId then
			table.insert(ids, spellId)
		end
	end
	if ids[1] then
		local localizedType = _G[row[1]]
		if type(localizedType) == "string" and localizedType ~= "" then
			ns.CREATURE_TYPE_SPELLS[localizedType] = ids
		end
		ns.CREATURE_TYPE_SPELLS[row[2]] = ids
	end
end

--[[
    Backstop for the cycle sound mute. A tracking spell's audio is played when the
    SERVER confirms the cast, not inside CastSpellByID, so the mute has to span the
    round trip. UNIT_SPELLCAST_SUCCEEDED normally lifts it far sooner; this is the
    ceiling for a cast the server never confirms.
]]
ns.CYCLE_MUTE_SECONDS = 0.6

-- How long after a confirmed cast the mute is held, covering the audio trigger.
ns.CYCLE_MUTE_TAIL_SECONDS = 0.1

--[[
    How long a confirmed cast is trusted over the laggy Blizzard tracking icon.
    Two windows: the farm cycle uses the generous value to avoid redundant
    recasts; the icon display uses a shorter one so an external cancel clears the
    stale icon sooner (UpdateIcon also drops it the instant mirrorConfirmedCast
    latches — see Core.lua).
]]
ns.CAST_IN_FLIGHT_SECONDS = 10
ns.ICON_IN_FLIGHT_SECONDS = 4

--------------------------------------------------------------------------------
-- Restricted Zones
--------------------------------------------------------------------------------

ns.RESTRICTED_MAP_IDS = {
	[369] = true, -- Deeprun Tram
}

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

--[[
    Raw hex palette. The derived COLORS table, the |cff prefix, and the GetColor
    accessor live in Features/Utilities.lua (Data files hold no logic).
]]
ns.PALETTE = {
	TITLE = "FFD100", -- Gold: Titles, Headers, Section Names
	INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
	BODY = "FFFFFF", -- White: Descriptions, Options Body Text
	HELP = "CCCCCC", -- Silver: Pro Tips, Helper Text
	TEXT = "FFFFFF", -- White: Messages, Values, Spell Names
	ON = "33CC33", -- Green: On
	OFF = "CC3333", -- Red: Off
	SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
	MUTED = "808080", -- Dark Gray: Meta-data, Version Numbers
}
