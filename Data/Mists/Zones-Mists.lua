local _, ns = ...

-- [instanceMapId] = true
ns.RESTRICTED_MAP_IDS = {
	[369] = true, -- Deeprun Tram
}

--[[
How We Got the Data

Last Validated
	2026-11-13, MoP Classic 5.5.4.70631

Notes
	- RESTRICTED_MAP_IDS lists maps that count as an instance for Farm Mode and Target Tracking even though IsInInstance says otherwise (ns.GetRestrictedKind in Features/Utilities.lua): the Deeprun Tram, the enclosed tram between Stormwind and Ironforge.
	- It's keyed by instance map ID, the eighth return of GetInstanceInfo. No client API looks a map ID up, so Validate Data confirms only the row count.
	- The other enclosed maps that aren't instances are left out: the unused Stormwind Prison, and the Alliance and Horde PvP Barracks, which no player enters, since the halls players visit stand inside Stormwind City and Orgrimmar.
	- The row started as a copy of Data/TBC/.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Map?build=5.5.4.70631

QuestieDB
	None.
]]
