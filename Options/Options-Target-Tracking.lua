local _, ns = ...

local L = ns.L
local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Automatic Target Tracking (composed into the General panel)
--------------------------------------------------------------------------------

--[[
    Shown on every character, whatever it can track: the setting lives in the
    profile, which characters of any class can share, and a character with no
    creature type to switch to simply never starts a hunt. It doesn't depend on
    Persistent Tracking: with that off, a hunt still starts and switches, but is
    never recast.
]]
function ns.BuildTargetTrackingOptions()
	return {
		spaceTargetTracking0 = Spacer(20),
		headerTargetTracking = Header(L["TARGET_TRACKING"], 21),
		spaceTargetTrackingHeader = Spacer(21.5),
		descTargetTracking = Desc(L["OPTIONS_TARGET_TRACKING_DESCRIPTION"], 22),
		spaceTargetTracking1 = Spacer(23),
		enableTargetTracking = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_TARGET_TRACKING"],
			desc = L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"],
			order = 24,
			width = "full",
			get = function()
				return ns.db and ns.db.profile.targetTracking
			end,
			set = function(_, value)
				if ns.db then
					ns.SetTargetTracking(value)
				end
			end,
		},
	}
end
