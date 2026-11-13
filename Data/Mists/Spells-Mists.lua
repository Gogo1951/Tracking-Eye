local _, ns = ...

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

-- { creatureTypeId, ns.SPELLS keys in preference order }
ns.CREATURE_TYPE_DATA = {
	{ 1, { "BEASTS" } }, -- Beast
	{ 2, { "DRAGONKIN" } }, -- Dragonkin
	{ 3, { "DEMONS" } }, -- Demon
	{ 4, { "ELEMENTALS" } }, -- Elemental
	{ 5, { "GIANTS" } }, -- Giant
	{ 6, { "UNDEAD" } }, -- Undead
	{ 7, { "HUMANOIDS" } }, -- Humanoid
	{ 14, { "PETS" } }, -- Wild Pet
}

-- { spellId, movementState }
ns.MOVEMENT_BUFF_SPELLS = {
	{ 2645, "ghostWolf" }, -- Ghost Wolf
	{ 5118, "cheetah" }, -- Aspect of the Cheetah
	{ 13159, "pack" }, -- Aspect of the Pack
}

-- [spellId] = true
ns.FARM_CYCLE_DEFAULTS = {
	[2383] = true, -- Find Herbs
	[2580] = true, -- Find Minerals
}

--[[
How We Got the Data

Last Validated
	2026-11-13, MoP Classic 5.5.4.70631

Notes
	- TRACKING_SPELLS holds every tracking ability a player can learn on this client: the hunter's eight Track spells, the druid's Track Humanoids, Find Herbs and Find Minerals from the gathering professions, Find Fish from Fishing, and Track Pets for wild battle pets.
	- It also holds the druid forms that decide what Tracking Eye does: Cat Form, Travel Form, Aquatic Form, Flight Form and Swift Flight Form. They're never cast: Cat Form gates the druid's Track Humanoids, and the travel forms tell Farm Mode the druid is travelling. The other druid forms decide nothing, so they're left out.
	- The druid's Track Humanoids works only in Cat Form.
	- key is the name code looks a spell up by (ns.SPELLS in Features/Utilities.lua); the form keys stay out of the list of tracking abilities.
	- source decides where a spell sits in the Farm Mode Abilities list: a class name puts it in that class's block (ns.FARM_ABILITY_CLASSES in Data/Data.lua), and any other source, a profession or Battle Pets, puts it under Professions & Racial Abilities.
	- Left out: 5500 Sense Demons and 5502 Sense Undead, which this client doesn't have; 2481 Find Treasure, which no skill line teaches here; 8387 Find Herbs and 8388 Find Minerals, which track the same things as 2383 and 2580 but aren't granted by the profession; and 74268 Track Archaeology Chests, a passive that comes with Archaeology and can't be cast or cycled. The rest of the game's tracking effects come from quest items, quest buffs, food, engineering goggles or a glyph, or from nothing a player can get, so none of them is a tracking ability to learn.
	- CREATURE_TYPE_DATA lists Target Tracking's candidates for each creature type, in preference order, and each character hunts with the first one it knows (ns.CREATURE_TYPE_SPELLS in Features/Utilities.lua). It's keyed by creature type ID, which is the same in every locale and on every client. With no Sense Demons or Sense Undead here, each type has only the hunter's Track spell, and Wild Pet has Track Pets. The druid's Track Humanoids is left out on purpose: a hunt can't cast it outside Cat Form. Creature types with no tracking ability, such as Critter, Mechanical and Totem, have no row.
	- MOVEMENT_BUFF_SPELLS holds the movement buffs, other than druid forms, that last until cancelled and count as travelling for Farm Mode: the hunter's Aspect of the Cheetah and Aspect of the Pack, and the shaman's Ghost Wolf, each detected by its buff. Timed speed boosts such as Sprint and Dash end on their own, so they're left out, and so are the death knight's Unholy Presence and the priest's Inner Will, which also last until cancelled but are kept up in combat, so they don't mean the player is travelling.
	- movementState is the Farm Mode condition the buff counts as (ns.MOVEMENT_STATE_TOGGLES in Data/Data.lua). The druid's travel forms come from the form rows in TRACKING_SPELLS instead.
	- FARM_CYCLE_DEFAULTS is Farm Mode's starting rotation, read into the profile's farmCycleSpells in Data/Default-Settings.lua: Find Herbs and Find Minerals are on, and every other ability is off. A key added here switches on for existing characters who never saved one.
	- Find Fish stays off in the rotation: the fishing-pole option under Persistent Tracking brings it up whenever a pole is in hand.
	- The rows started as a copy of Data/TBC/, less the spells this client lacks, plus Track Pets from the MoP Classic 5.5.4.69934 tables.
	- The SQL ran against wotlk-db, another flavor's database, so it's a lead rather than this client's truth: it lists every flavor's IDs, and TRACKING_SPELLS keeps only the ones this client's Validate Data report confirms.

SQL (CMaNGOS)
	TRACKING_SPELLS, run against wotlk-db:

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

	CREATURE_TYPE_DATA, MOVEMENT_BUFF_SPELLS:
	TODO: Add SQL Query

	FARM_CYCLE_DEFAULTS is hand-picked, so no query applies.

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=5.5.4.70631
	https://wago.tools/db2/SpellEffect?build=5.5.4.70631
	https://wago.tools/db2/SkillLine?build=5.5.4.70631
	https://wago.tools/db2/SkillLineAbility?build=5.5.4.70631
	https://wago.tools/db2/SpellLevels?build=5.5.4.70631
	https://wago.tools/db2/SpellMisc?build=5.5.4.70631
	https://wago.tools/db2/SpellDuration?build=5.5.4.70631
	https://wago.tools/db2/CreatureType?build=5.5.4.70631
	https://wago.tools/db2/ItemEffect?build=5.5.4.70631

QuestieDB
	None.
]]
