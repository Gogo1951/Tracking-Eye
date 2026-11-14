local _, ns = ...

local L = ns.L
local Desc, Spacer = ns.OptionsDesc, ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Target Tracking Panel
--------------------------------------------------------------------------------

--[[
    Shown on every character, whatever it can track: the setting lives in the
    profile, which characters of any class can share, and a character with no
    creature type to switch to simply never starts a hunt. It doesn't depend on
    Persistent Tracking: with that off, a hunt still starts and switches, but is
    never recast.

    Page order: the description, then the switch.
]]
function ns.BuildTargetTrackingOptions()
	return {
		type = "group",
		name = L["TARGET_TRACKING"],
		args = {
			descTargetTracking = Desc(L["OPTIONS_TARGET_TRACKING_DESCRIPTION"], 1),
			spaceTargetTracking = Spacer(2),
			enableTargetTracking = ns.OptionsFeatureSwitch("targetTracking", 3),
		},
	}
end
