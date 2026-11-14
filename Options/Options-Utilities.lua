local _, ns = ...

local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Features
--------------------------------------------------------------------------------

--[[
    Every feature, in the order the root panel's Features section and the
    mini-map menu draw them: the three blocks, then the More Features rows. Each
    names its setting (in ns.db.profile or ns.db.global), its menu name, its
    Enable switch's caption and description (also the menu row's tooltip), and
    `apply`, which turns it on or off. Each has its own options panel, in this
    order. A More Features row with opensOptions (the panel's ns.OPTIONS_REGISTRY
    key) shows On or Off but opens that panel on a click, so its settings are set
    up there (README-Notes → Free Placement Mode opens options).
]]
ns.FEATURES = {
	{
		store = "profile",
		setting = "persistentTracking",
		name = "PERSISTENT_TRACKING",
		caption = "OPTIONS_ENABLE_PERSISTENT",
		desc = "OPTIONS_ENABLE_PERSISTENT_DESCRIPTION",
		block = true,
		apply = function(value)
			ns.SetPersistentTracking(value)
		end,
	},
	{
		store = "profile",
		setting = "farmMode",
		name = "TAB_FARM_MODE",
		caption = "OPTIONS_ENABLE_FARM",
		desc = "OPTIONS_ENABLE_FARM_DESCRIPTION",
		block = true,
		apply = function(value)
			ns.db.profile.farmMode = value
		end,
	},
	{
		store = "profile",
		setting = "targetTracking",
		name = "TARGET_TRACKING",
		caption = "OPTIONS_ENABLE_TARGET_TRACKING",
		desc = "OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION",
		block = true,
		apply = function(value)
			ns.SetTargetTracking(value)
		end,
	},
	{
		store = "global",
		setting = "comeAndGetIt",
		name = "TAB_COME_AND_GET_IT",
		caption = "OPTIONS_ENABLE_COME_AND_GET_IT",
		desc = "OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION",
		apply = function(value)
			ns.db.global.comeAndGetIt = value
		end,
	},
	{
		store = "global",
		setting = "freePlacement",
		name = "PLACEMENT_MODE",
		caption = "OPTIONS_ENABLE_FREE",
		desc = "OPTIONS_ENABLE_FREE_DESCRIPTION",
		opensOptions = "FreePlacement",
		apply = function(value)
			ns.db.global.freePlacement = value
			ns:ApplyMinimapButton()
		end,
	},
}

local FEATURE_BY_SETTING = {}
for _, feature in ipairs(ns.FEATURES) do
	FEATURE_BY_SETTING[feature.setting] = feature
end

--[[
    A feature's on/off switch, drawn twice: in the root panel's Features section,
    two to a line, and atop the feature's own section or page. Both copies come
    from here, so they share one caption, one tooltip and one setter, and a change
    repaints every panel so neither copy shows a stale box.
]]
function ns.OptionsFeatureSwitch(setting, order, width)
	local feature = FEATURE_BY_SETTING[setting]
	return {
		type = "toggle",
		name = ns.L[feature.caption],
		desc = ns.L[feature.desc],
		order = order,
		width = width or "full",
		get = function()
			return ns.db and ns.db[feature.store][feature.setting]
		end,
		set = function(_, value)
			if ns.db then
				feature.apply(value)
			end
			ns.RefreshSettings()
		end,
	}
end

--[[
    The root panel's Features section: every switch in ns.FEATURES order, two to
    a line, each pair in its own unnamed inline group so every pair pins its own
    row. The widths leave slack under ns.OPTIONS_ROW_WIDTH: a row summing exactly
    to the pane sits on the wrap boundary and can drop its second toggle onto a
    line of its own. Rows take startOrder + 0.01 per pair, so the section fits
    between whole-number neighbors.
]]
local SWITCH_PAIR_WIDTH = (ns.OPTIONS_ROW_WIDTH - 0.2) / 2

function ns.OptionsFeatureSwitchRows(args, keyPrefix, startOrder)
	local row = 0
	for index = 1, #ns.FEATURES, 2 do
		row = row + 1
		local pair = {}
		for offset = 0, 1 do
			local feature = ns.FEATURES[index + offset]
			if feature then
				pair["toggle" .. (offset + 1)] = ns.OptionsFeatureSwitch(feature.setting, offset + 1, SWITCH_PAIR_WIDTH)
			end
		end
		args[keyPrefix .. row] = {
			type = "group",
			name = "",
			inline = true,
			order = startOrder + row * 0.01,
			args = pair,
		}
	end
end

--------------------------------------------------------------------------------
-- Shared Options Helpers
--------------------------------------------------------------------------------

--[[
    The title drawn at the top of a sub-panel: "Farm Mode > Abilities", so it is
    always clear where you are. Only the title carries the parent; the settings
    tree already shows it by nesting, and the tree label is the plain name
    passed to AddToBlizOptions.
]]
function ns.SubPanelTitle(parentName, name)
	return parentName .. " > " .. name
end

function ns.OptionsHeader(text, order, hidden)
	return {
		type = "header",
		name = GetColor("TITLE") .. text .. "|r",
		order = order,
		hidden = hidden,
	}
end

function ns.OptionsDesc(text, order)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		order = order,
	}
end

function ns.OptionsSpacer(order, hidden)
	return {
		type = "description",
		name = " ",
		order = order,
		hidden = hidden,
	}
end

--[[
    A sub-option: a control that only means anything while the toggle above it is
    on. Marked twice over, an indented checkbox and a silver caption, so the
    dependency reads whether the player is scanning shape or color.

    Three constraints inside SubRow are load-bearing: one unnamed inline group per
    sub-option, or the next control packs onto the leftover space and the indent
    stops indenting anything; controls sized with slack rather than to the full
    row width, or a control on the wrap boundary tips onto its own line and
    strands the indent above it; and `hidden` on the group rather than the
    members, or the indent is left behind when the section collapses.
]]
function ns.OptionsSubLabel(text)
	return GetColor("HELP") .. text .. "|r"
end

function ns.OptionsSubRow(order, hidden, controls)
	local args = {
		indent = {
			type = "description",
			name = " ",
			width = ns.OPTIONS_SUB_INDENT_WIDTH,
			order = 1,
		},
	}
	for index, control in ipairs(controls) do
		control.order = index + 1
		args["control" .. index] = control
	end
	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = args,
	}
end

--[[
    The label half of a label-beside-control row. The control that follows carries
    name = "" and the remaining width, ordered immediately after, so the two total
    ns.OPTIONS_ROW_WIDTH and land on one line. A caption left on the control puts
    the label back above the widget and breaks the row.
]]
function ns.OptionsRowLabel(text, order, width)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
	}
end
