local _, ns = ...

-- [instanceMapId] = true
ns.RESTRICTED_MAP_IDS = {
	[369] = true, -- Deeprun Tram
}

--[[
How We Got the Data

Last Validated
	2026-11-13, TBC Anniversary 2.5.6.70577

Notes
	- RESTRICTED_MAP_IDS lists maps that count as an instance for Farm Mode and Target Tracking even though IsInInstance says otherwise (ns.GetRestrictedKind in Features/Utilities.lua): the Deeprun Tram, the enclosed tram between Stormwind and Ironforge.
	- It's keyed by instance map ID, the eighth return of GetInstanceInfo. No client API looks a map ID up, so Validate Data confirms only the row count.
	- The other enclosed maps that aren't instances are left out: two test maps, the unused Stormwind Prison, and the Alliance and Horde PvP Barracks, which no player enters, since the halls players visit stand inside Stormwind City and Orgrimmar.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Map?build=2.5.6.70577

QuestieDB
	None.
]]
