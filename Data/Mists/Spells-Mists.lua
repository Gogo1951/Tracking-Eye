-- Data/Mists/Spells-Mists.lua
local _, ns = ...

--[[
    Copied from Data/TBC/, less Sense Demons and Sense Undead, which the MoP
    Classic 5.5.4.69934 tables on wago.tools lack, and Find Treasure, which those
    tables teach to no one. Track Pets comes from those same tables. Until
    Validate Data passes on this client, every other row below stands as copied.
]]

--------------------------------------------------------------------------------
-- Tracking Spells
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
-- { spellId, key, source }
ns.TRACKING_SPELLS = {
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
	-- Profession
	{ 2383, "HERBS", "Herbalism" }, -- Find Herbs
	{ 2580, "MINERALS", "Mining" }, -- Find Minerals
	{ 43308, "FISH", "Fishing" }, -- Find Fish
	-- Battle Pets
	{ 122026, "PETS", "Battle Pets" }, -- Track Pets
}

--------------------------------------------------------------------------------
-- Creature Types
--------------------------------------------------------------------------------

--[[
    Target Tracking's candidates for each creature type, in preference order and
    resolved per character. The druid's Cat Form tracking is left out on purpose:
    a hunt can't cast it outside Cat Form.
]]
-- TODO: Add SQL Query
-- { creatureTypeId, ns.SPELLS keys in preference order }
ns.CREATURE_TYPE_DATA = {
	{ 1, { "BEASTS" } }, -- Beast
	{ 2, { "DRAGONKIN" } }, -- Dragonkin
	{ 3, { "DEMONS" } }, -- Demon
	{ 4, { "ELEMENTALS" } }, -- Elemental
	{ 5, { "GIANTS" } }, -- Giant
	{ 6, { "UNDEAD" } }, -- Undead
	{ 7, { "HUMANOIDS" } }, -- Humanoid
}

--------------------------------------------------------------------------------
-- Movement Buffs
--------------------------------------------------------------------------------

--[[
    Non-druid persistent movement states that activate Farm Mode, detected by
    buff: Hunter Aspect of the Cheetah and Aspect of the Pack, and Shaman Ghost
    Wolf. Druid travel and flight forms are the form rows above.
]]
-- TODO: Add SQL Query
-- { spellId, movementState }
ns.MOVEMENT_BUFF_SPELLS = {
	{ 2645, "ghostWolf" }, -- Ghost Wolf
	{ 5118, "cheetah" }, -- Aspect of the Cheetah
	{ 13159, "pack" }, -- Aspect of the Pack
}

--------------------------------------------------------------------------------
-- Farm Cycle Defaults
--------------------------------------------------------------------------------

--[[
    Find Herbs and Find Minerals are on by default; every other tracking
    ability is off. Find Fish stays off: the fishing-pole option under
    Persistent Tracking brings it up whenever a pole is in hand.
]]
-- [spellId] = true
ns.FARM_CYCLE_DEFAULTS = {
	[2383] = true, -- Find Herbs
	[2580] = true, -- Find Minerals
}
