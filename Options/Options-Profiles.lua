local _, ns = ...

--------------------------------------------------------------------------------
-- Profiles Panel
--------------------------------------------------------------------------------

--[[
    The stock AceDBOptions-3.0 profiles table, returned as-is: profile picker,
    Copy From, Delete a Profile, and Reset Profile (active profile only), already
    translated in every locale. Nothing is added, removed, or relabeled.
]]
function ns.BuildProfilesOptions()
	return LibStub("AceDBOptions-3.0"):GetOptionsTable(ns.db)
end
