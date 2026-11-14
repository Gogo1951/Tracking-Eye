local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer
local RowLabel = ns.OptionsRowLabel

local function NoBlizzardTrackingButton()
	return not (ns.HasBlizzardTrackingButton and ns.HasBlizzardTrackingButton())
end

--[[
    A binding cannot be set from an AceConfig panel, so each row shows the key
    the player bound, or a muted Not Bound, and a Set Key button that opens the
    game's Key Bindings list through ns:OpenKeyBindings (Features/Key-Bindings.lua).
    The binding names come from Bindings.xml's name attributes; the captions are
    the same BINDING_* strings the Key Bindings list prints. Core repaints this
    panel on UPDATE_BINDINGS, when the player changes a key.
]]
local KEY_BINDINGS = {
	-- { bindingName, captionKey, descKey }
	{ "TRACKINGEYE_CYCLE_FARM_ABILITY", "BINDING_CYCLE_FARM_ABILITY", "OPTIONS_KEYBINDS_DESCRIPTION" },
}

local KEY_LABEL_WIDTH = 1.9
local KEY_STATUS_WIDTH = 0.85
local KEY_BUTTON_WIDTH = 0.55

local function GetBindingStatus(bindingName)
	local key = GetBindingKey(bindingName)
	if not key then
		return GetColor("MUTED") .. NOT_BOUND .. "|r"
	end
	local text = (GetBindingText and GetBindingText(key)) or key
	return GetColor("TEXT") .. text .. "|r"
end

-- Each binding is its row (caption, key, Set Key), its description under it, and a blank line before the next.
local function AddKeyBindingRows(args, startOrder)
	local order = startOrder

	for index, entry in ipairs(KEY_BINDINGS) do
		local bindingName, captionKey, descKey = entry[1], entry[2], entry[3]

		if index > 1 then
			args["spaceKeyBinding" .. index] = Spacer(order)
			order = order + 0.01
		end

		args["rowKeyBinding" .. index] = {
			type = "group",
			name = "",
			inline = true,
			order = order,
			args = {
				caption = RowLabel(GetColor("INFO") .. L[captionKey] .. "|r", 1, KEY_LABEL_WIDTH),
				status = {
					type = "description",
					name = function()
						return GetBindingStatus(bindingName)
					end,
					fontSize = "medium",
					width = KEY_STATUS_WIDTH,
					order = 2,
				},
				setKey = {
					type = "execute",
					name = L["OPTIONS_KEY_SET"],
					desc = L["OPTIONS_KEY_SET_DESCRIPTION"],
					width = KEY_BUTTON_WIDTH,
					order = 3,
					func = function()
						ns:OpenKeyBindings()
					end,
				},
			},
		}
		order = order + 0.01

		args["descKeyBinding" .. index] = Desc(GetColor("HELP") .. L[descKey] .. "|r", order)
		order = order + 0.01
	end
end

--------------------------------------------------------------------------------
-- General Options Panel
--------------------------------------------------------------------------------

--[[
    The root page, in the Style Guide's Main Page Layout order: intro, Welcome
    Message, Mini-map Button, Features (every feature's on/off switch, two to a
    line), Key Bindings and /Commands. Each Features switch is the same toggle
    that heads its feature's own panel (ns.OptionsFeatureSwitch).

    Use the Default Tracking Button sits with Mini-map Button: it decides which
    mini-map button opens the menu, and shows only where the client has a
    Blizzard tracking button to take over.

    Order values are grouped in spaced blocks so sections can be reordered or
    extended without renumbering their neighbors.
]]
function ns.BuildGeneralOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_DESCRIPTION"], 1),

		-- Welcome Message
		spaceWelcome0 = Spacer(10),
		enableWelcome = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_WELCOME"],
			desc = L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"],
			order = 11,
			width = "full",
			get = function()
				return ns.db and ns.db.global.showWelcome
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.showWelcome = value
				end
				ns.RefreshSettings()
			end,
		},

		-- Mini-map Button
		enableMinimap = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_MINIMAP"],
			desc = L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"],
			order = 13,
			width = "full",
			disabled = function()
				return ns.db and ns.db.global.freePlacement
			end,
			get = function()
				return not (ns.db and ns.db.global.minimap and ns.db.global.minimap.hide)
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.minimap.hide = not value
					ns:ApplyMinimapButton()
				end
				ns.RefreshSettings()
			end,
		},
		hookBlizzardTracking = {
			type = "toggle",
			name = L["OPTIONS_HOOK_BLIZZARD"],
			desc = L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"],
			order = 14,
			width = "full",
			hidden = NoBlizzardTrackingButton,
			get = function()
				return ns.db and ns.db.global.hookBlizzardTracking
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.hookBlizzardTracking = value
					ns.ApplyBlizzardTrackingHook()
				end
				ns.RefreshSettings()
			end,
		},

		-- Features: the rows fill 23 onward.
		spaceFeatures0 = Spacer(20),
		headerFeatures = Header(L["OPTIONS_FEATURES_HEADER"], 21),
		spaceFeatures1 = Spacer(22),

		-- Key Bindings: the rows fill 63 onward.
		spaceKeyBinds0 = Spacer(60),
		headerKeyBinds = Header(L["OPTIONS_KEYBINDS"], 61),
		spaceKeyBinds1 = Spacer(62),

		-- /Commands
		spaceCommands0 = Spacer(90),
		headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 91),
		spaceCommands1 = Spacer(92),
		descCommands = Desc(
			GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
			93
		),
	}

	ns.OptionsFeatureSwitchRows(args, "rowFeatures", 23)
	AddKeyBindingRows(args, 63)

	return {
		name = L["ADDON_TITLE"],
		type = "group",
		args = args,
	}
end
