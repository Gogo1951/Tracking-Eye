local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- [instanceMapId] = true
ns.RESTRICTED_MAP_IDS = {
	[369] = true, -- Deeprun Tram
}

--[[
How We Got the Data

Last Validated
	2026-10-04, Classic Era 1.15.9.70003

Notes
	- RESTRICTED_MAP_IDS lists maps that count as an instance for Farm Mode and Target Tracking even though IsInInstance says otherwise (ns.GetRestrictedKind in Features/Utilities.lua): the Deeprun Tram, the enclosed tram between Stormwind and Ironforge.
	- It's keyed by instance map ID, the eighth return of GetInstanceInfo. No client API looks a map ID up, so Validate Data confirms only the row count.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	None.
]]
