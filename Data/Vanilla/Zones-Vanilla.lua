-- Data/Vanilla/Zones-Vanilla.lua
local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- TODO: Add SQL Query
-- [instanceMapId] = true
ns.RESTRICTED_MAP_IDS = {
	[369] = true, -- Deeprun Tram
}
