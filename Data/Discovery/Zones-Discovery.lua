-- Data/Discovery/Zones-Discovery.lua
local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

--[[
    Copied from Data/Vanilla/. Until Validate Data passes on this client, every
    table below holds Vanilla's rows.
]]

-- TODO: Add SQL Query
-- [instanceMapId] = true
ns.RESTRICTED_MAP_IDS = {
	[369] = true, -- Deeprun Tram
}
