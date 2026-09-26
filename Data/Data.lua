local ADDON_NAME, ns = ...
ns.L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

--------------------------------------------------------------------------------
-- Constants & Config
--------------------------------------------------------------------------------

ns.ICON_DEFAULT = "Interface\\Icons\\inv_misc_map_01"
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
	ComeAndGetIt = ADDON_NAME .. "_ComeAndGetIt",
	Profiles = ADDON_NAME .. "_Profiles",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

--------------------------------------------------------------------------------
-- Options Grid
--------------------------------------------------------------------------------

-- Label plus control always total OPTIONS_ROW_WIDTH, so every row ends where every other row ends.
ns.OPTIONS_ROW_WIDTH = 3.4
ns.OPTIONS_LABEL_WIDTH = 2.1
ns.OPTIONS_CONTROL_WIDTH = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_LABEL_WIDTH
ns.OPTIONS_REMOVE_ICON_WIDTH = 0.25 -- the item lists' remove column, sized to its icon
ns.OPTIONS_SUB_INDENT_WIDTH = 0.115 -- the blank cell a sub-option row leads with

ns.SHAPES = {
	CIRCLE = "circle",
	SQUARE = "square",
}

--------------------------------------------------------------------------------
-- Movement States
--------------------------------------------------------------------------------

--[[
    Movement state -> the profile toggle that decides whether Farm Mode runs in
    it, and -> the class that owns it (nil means every class). These tables are
    the one place the set of states is written down, so the detection, the
    per-state toggles, and the paused-reason messages can never disagree about
    which states exist.
]]
ns.MOVEMENT_STATE_TOGGLES = {
	mounted = "farmMounted",
	travelForms = "farmTravelForms",
	cheetah = "farmCheetah",
	pack = "farmPack",
	ghostWolf = "farmGhostWolf",
	foot = "farmNotMounted",
	-- No taxi entry: a flight path bails out before this table is ever read.
}

ns.MOVEMENT_STATE_CLASS = {
	travelForms = "DRUID",
	cheetah = "HUNTER",
	pack = "HUNTER",
	ghostWolf = "SHAMAN",
}

--[[
    Every state in MOVEMENT_STATE_CLASS, in the order the on-foot pause reason
    considers them. A class that owns several (a hunter's two) is told about the
    first one switched on, so each sentence stays one precomposed key per pair
    rather than one per combination.
]]
ns.CLASS_STATE_ORDER = { "cheetah", "pack", "travelForms", "ghostWolf" }

--------------------------------------------------------------------------------
-- Farm Mode Ability Groups
--------------------------------------------------------------------------------

--[[
    The Farm Mode Abilities list is split into bordered groups, the way Control
    Freak splits its abilities: professions and racials first, then one group per
    class in this order. A spell's group comes from the source field of its
    ns.TRACKING_SPELLS row; any source not named here (a profession, a racial,
    battle pets) lands in the first group. Grouping by class is what lets the
    druid's and the hunter's Track Humanoids both appear without being confused.
]]
ns.FARM_ABILITY_CLASSES = {
	{ source = "Druid", class = "DRUID" },
	{ source = "Hunter", class = "HUNTER" },
	{ source = "Warlock", class = "WARLOCK" },
	{ source = "Paladin", class = "PALADIN" },
}

-- Class colors as hex, like the palette: every class through Wrath, the same table in every add-on.
ns.CLASS_COLORS = {
	DEATHKNIGHT = "C41E3A",
	DRUID = "FF7C0A",
	HUNTER = "AAD372",
	MAGE = "3FC7EB",
	PALADIN = "F48CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF468",
	SHAMAN = "0070DD",
	WARLOCK = "8788EE",
	WARRIOR = "C69B6D",
}

--------------------------------------------------------------------------------
-- Timing
--------------------------------------------------------------------------------

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
    latches — see Features/Tracking-State.lua).
]]
ns.CAST_IN_FLIGHT_SECONDS = 10
ns.ICON_IN_FLIGHT_SECONDS = 4

--------------------------------------------------------------------------------
-- Come & Get It
--------------------------------------------------------------------------------

--[[
    UI_ERROR_MESSAGE indexes shift between patches and clients, so the locked
    error is matched by its GlobalStrings name via GetGameMessageInfo. Herb and
    mine share one error and are matched by localized skill name instead.
]]
ns.ERROR_STRING_LOCKED_CHEST = "ERR_ITEM_LOCKED"

ns.ANNOUNCE_COOLDOWN = 5

-- The client measures a sent chat body in bytes, not characters.
ns.CHAT_MESSAGE_MAX_LENGTH = 255

--[[
    Single source of truth for output channels: the feature derives its key ->
    command lookup and Options derives the dropdown from this one table, so the
    list, its order, and the command mapping can't drift. Array order is dropdown
    order; keys are saved to the DB and never localized. Adding a channel is one
    row here plus its OPTIONS_OUTPUT_* locale string.
]]
ns.OUTPUT_CHANNELS = {
	{ key = "channel1", command = "/1", labelKey = "OPTIONS_OUTPUT_CHANNEL1" },
	{ key = "say", command = "/say", labelKey = "OPTIONS_OUTPUT_SAY" },
	{ key = "yell", command = "/yell", labelKey = "OPTIONS_OUTPUT_YELL" },
	{ key = "party", command = "/party", labelKey = "OPTIONS_OUTPUT_PARTY" },
	{ key = "guild", command = "/guild", labelKey = "OPTIONS_OUTPUT_GUILD" },
}

-- Fallback when ns.db.profile.comeAndGetItOutput is unset or holds a stale key.
ns.DEFAULT_OUTPUT_CHANNEL = "channel1"

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
