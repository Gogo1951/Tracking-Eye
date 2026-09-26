local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

--[[
    Both globals here are demanded by WoW's binding system and exist nowhere else
    in the add-on: Bindings.xml can only call a global function, and a binding's
    display name must be a BINDING_NAME_<name> global matching the element's
    `name` attribute.

    The section players see in the Key Bindings list comes from the `category`
    attribute in Bindings.xml, not from a header global. Bindings.xml itself is
    auto-discovered from the add-on root and must never be listed in the TOC.
]]

BINDING_NAME_TRACKINGEYE_CYCLE_FARM_ABILITY = L["BINDING_CYCLE_FARM_ABILITY"]

-- ns.GetEmptyCycleKind -> the chat line that explains an empty cycle.
local EMPTY_CYCLE_MESSAGES = {
	none = "BINDING_NOTHING_TO_CYCLE",
	unlearned = "BINDING_NOTHING_LEARNED",
	catForm = "BINDING_NEEDS_CAT_FORM",
}

function TrackingEye_CycleFarmAbility()
	if not ns.db then
		return
	end

	-- Deliberately not gated on farmMode: this is a manual control, usable with Farm Mode switched off.
	if ns.GetFarmCycleCount() == 0 then
		ns:PrintMessage(L[EMPTY_CYCLE_MESSAGES[ns.GetEmptyCycleKind()]])
		return
	end

	ns.AdvanceFarmCycle()
end
