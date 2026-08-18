local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

--[[
    Both globals here are demanded by WoW's binding system and exist nowhere else
    in the add-on: Bindings.xml can only call a global function, and a binding's
    display name must be a BINDING_NAME_<name> global matching the element's
    `name` attribute. The house rule limiting globals to SavedVariables tables,
    slash registrations, and named frames does not cover these two.

    The section players see in the Key Bindings list comes from the `category`
    attribute in Bindings.xml, not from a header global. Bindings.xml itself is
    auto-discovered from the add-on root and must never be listed in the TOC.
]]

BINDING_NAME_TRACKINGEYE_CYCLE_FARM_ABILITY = L["BINDING_CYCLE_FARM_ABILITY"]

function TrackingEye_CycleFarmAbility()
	if not ns.db then
		return
	end

	-- Deliberately not gated on farmMode: this is a manual control, usable with Farm Mode switched off.
	if ns.GetFarmCycleCount() == 0 then
		ns:PrintMessage(L["BINDING_NOTHING_TO_CYCLE"])
		return
	end

	ns.AdvanceFarmCycle()
end
