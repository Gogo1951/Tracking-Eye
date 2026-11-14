local _, ns = ...

local L = ns.L
local Desc, Spacer = ns.OptionsDesc, ns.OptionsSpacer
local SubRow, SubLabel = ns.OptionsSubRow, ns.OptionsSubLabel

-- Sized to its caption with slack; never the full row width. See ns.OptionsSubRow.
local SUB_TOGGLE_WIDTH = 3.2

local function PersistentOff()
	return not (ns.db and ns.db.profile.persistentTracking)
end

-- Find Fish is missing from some flavors' data (Classic Era), so its row never shows there.
local function FishingPoleRowHidden()
	return PersistentOff() or not ns.SPELLS.FISH
end

--[[
    A Persistent Tracking sub-option: an override for the ability Persistent
    Tracking keeps up, bound to one profile field and hidden with Persistent
    Tracking unless the row passes its own condition. A change applies at once,
    even mid-battleground, since the recast and the farm cycle's persistent entry
    both read the resolver.
]]
local function PersistentOverrideRow(order, field, name, desc, hidden)
	return SubRow(order, hidden or PersistentOff, {
		{
			type = "toggle",
			name = SubLabel(name),
			desc = desc,
			width = SUB_TOGGLE_WIDTH,
			get = function()
				return ns.db and ns.db.profile[field]
			end,
			set = function(_, value)
				if ns.db then
					ns.db.profile[field] = value
					ns.InvalidateFarmCache()
					ns.TryRecastPersistent()
				end
				ns.RefreshSettings()
			end,
		},
	})
end

--------------------------------------------------------------------------------
-- Persistent Tracking Panel
--------------------------------------------------------------------------------

-- Page order: the description, the switch, then its overrides, which hide while it is off.
function ns.BuildPersistentTrackingOptions()
	return {
		type = "group",
		name = L["PERSISTENT_TRACKING"],
		args = {
			descPersistent = Desc(L["OPTIONS_PERSISTENT_DESCRIPTION"], 1),
			spacePersistent = Spacer(2),
			enablePersistent = ns.OptionsFeatureSwitch("persistentTracking", 3),
			fishingPoleFishRow = PersistentOverrideRow(
				3.1,
				"fishingPoleFish",
				L["OPTIONS_FISHING_POLE_FISH_NAMED"]:format(
					ns.GetSpellNameText(ns.SPELLS.FISH),
					ns.GetFishingPoleName()
				),
				L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"],
				FishingPoleRowHidden
			),
			catFormHumanoidsRow = PersistentOverrideRow(
				3.2,
				"catFormHumanoids",
				L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"]:format(
					ns.GetClassNameText("DRUID"),
					ns.GetSpellNameText(ns.SPELLS.DRUID_HUMANOIDS),
					ns.GetSpellNameText(ns.SPELLS.CAT)
				),
				L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"]
			),
			battlegroundHumanoidsRow = PersistentOverrideRow(
				3.3,
				"battlegroundHumanoids",
				L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"]:format(
					ns.GetClassNameText("HUNTER"),
					ns.GetSpellNameText(ns.SPELLS.HUMANOIDS)
				),
				L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"]
			),
		},
	}
end
