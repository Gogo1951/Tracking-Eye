-- Data/Mainline/Zones-Mainline.lua
local _, ns = ...

--[[
    Copied from Data/Mists/. The Retail 12.1.0.69933 tables on wago.tools still
    list Deeprun Tram as a map outside any instance. Until Validate Data passes
    on this client, every table below stands as copied.
]]

-- TODO: Add SQL Query
-- [instanceMapId] = true
ns.RESTRICTED_MAP_IDS = {
	[369] = true, -- Deeprun Tram
}
