local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer
local RowLabel = ns.OptionsRowLabel

--------------------------------------------------------------------------------
-- General Options Panel
--------------------------------------------------------------------------------
function ns.BuildGeneralOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_DESC"], 1),

		spaceWelcome0 = Spacer(2),
		enableWelcome = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_WELCOME"],
			desc = L["OPTIONS_WELCOME_DESC"],
			order = 3,
			width = "full",
			get = function()
				return ns.db and ns.db.global.showWelcome
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.showWelcome = value
				end
			end,
		},

		enableMinimap = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_MINIMAP"],
			desc = L["OPTIONS_ENABLE_MINIMAP_DESC"],
			order = 3.5,
			width = "full",
			disabled = function()
				return ns.db and ns.db.global.freePlacement
			end,
			get = function()
				return not (ns.db and ns.db.global.minimap and ns.db.global.minimap.hide)
			end,
			set = function(_, value)
				if ns.db then
					if not ns.db.global.minimap then
						ns.db.global.minimap = {}
					end
					ns.db.global.minimap.hide = not value
					ns.UpdatePlacement()
				end
			end,
		},

		--[[
			Sits with the other two mini-map controls rather than down among the
			feature settings: it is a third toggle for the same button, and the
			player reads the three as one group.
		]]
		spaceHookBlizzard0 = Spacer(3.55),
		hookBlizzardTracking = {
			type = "toggle",
			name = L["OPTIONS_HOOK_BLIZZARD"],
			desc = L["OPTIONS_HOOK_BLIZZARD_DESC"],
			order = 3.6,
			width = "full",
			hidden = function()
				return not (ns.HasBlizzardTrackingButton and ns.HasBlizzardTrackingButton())
			end,
			get = function()
				return ns.db and ns.db.global.hookBlizzardTracking
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.hookBlizzardTracking = value
					ns.ApplyBlizzardTrackingHook()
				end
			end,
		},
		descHookBlizzardNote = {
			type = "description",
			name = GetColor("HELP") .. L["OPTIONS_HOOK_BLIZZARD_NOTE"] .. "|r",
			fontSize = "medium",
			order = 3.65,
			hidden = function()
				return not (ns.HasBlizzardTrackingButton and ns.HasBlizzardTrackingButton())
			end,
		},

		spaceCommands0 = Spacer(4),
		headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 5),
		spaceCommands1 = Spacer(6),
		descCommandsIntro = Desc(L["OPTIONS_COMMANDS_INTRO"], 7),
		spaceCommands2 = Spacer(7.1),
		descCommands = Desc(
			GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
			7.2
		),

		--[[
			A binding cannot be set from an AceConfig panel, so this section is a
			pointer: without it the binding exists but nothing in the add-on ever
			mentions it. The name matches the Key Bindings entry exactly.
		]]
		spaceKeyBinds0 = Spacer(7.5),
		headerKeyBinds = Header(L["OPTIONS_KEYBINDS"], 7.6),
		spaceKeyBinds1 = Spacer(7.7),
		descKeyBinds = Desc(
			GetColor("INFO") .. L["BINDING_CYCLE_FARM_ABILITY"] .. "|r" .. "  " .. L["OPTIONS_KEYBINDS_DESC"],
			7.8
		),

		spacePT0 = Spacer(9),
		headerPersistent = Header(L["PERSISTENT_TRACKING"], 10),
		spacePTHeader = Spacer(10.5),
		descPersistent = Desc(L["PERSISTENT_DESC"], 11),
		spacePT1 = Spacer(12),
		enablePersistent = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_PERSISTENT"],
			order = 13,
			width = "full",
			get = function()
				return ns.db and ns.db.profile.persistentTracking
			end,
			set = function(_, value)
				if ns.db then
					ns.db.profile.persistentTracking = value
				end
			end,
		},

		-- Feedback & Support (Discord, GitHub, CurseForge, Wago)
		spaceLinks0 = Spacer(69),
		headerLinks = Header(L["OPTIONS_LINKS"], 70),
		spaceLinks1 = Spacer(71),
		discordLabel = RowLabel(GetColor("TITLE") .. L["OPTIONS_DISCORD"] .. "|r", 72),
		discordURL = {
			type = "input",
			name = "",
			order = 73,
			width = ns.OPTIONS_CONTROL_WIDTH,
			get = function()
				return ns.DISCORD_URL
			end,
			set = function() end,
		},
		spaceLinks2 = Spacer(74),
		githubLabel = RowLabel(GetColor("TITLE") .. L["OPTIONS_GITHUB"] .. "|r", 75),
		githubURL = {
			type = "input",
			name = "",
			order = 76,
			width = ns.OPTIONS_CONTROL_WIDTH,
			get = function()
				return ns.GITHUB_URL
			end,
			set = function() end,
		},
		spaceLinks3 = Spacer(77),
		curseforgeLabel = RowLabel(GetColor("TITLE") .. L["OPTIONS_CURSEFORGE"] .. "|r", 78),
		curseforgeURL = {
			type = "input",
			name = "",
			order = 79,
			width = ns.OPTIONS_CONTROL_WIDTH,
			get = function()
				return ns.CURSEFORGE_URL
			end,
			set = function() end,
		},
		spaceLinks4 = Spacer(80),
		wagoLabel = RowLabel(GetColor("TITLE") .. L["OPTIONS_WAGO"] .. "|r", 81),
		wagoURL = {
			type = "input",
			name = "",
			order = 82,
			width = ns.OPTIONS_CONTROL_WIDTH,
			get = function()
				return ns.WAGO_URL
			end,
			set = function() end,
		},
		spaceVersion0 = {
			type = "description",
			name = " ",
			width = "full",
			order = 998,
		},
		versionLine = {
			type = "description",
			name = GetColor("MUTED") .. "Version " .. ns.Version .. "|r",
			fontSize = "medium",
			order = 999,
		},
	}

	--[[
		Target Tracking and Free Placement are small enough to live on this page:
		each owns its widgets in its own file and returns an args fragment, merged
		in here. Order values are unique across fragments, so the page renders the
		same regardless of merge sequence. Farm Mode is not among them — it carries
		enough controls to have earned its own child panel.
	]]
	for key, entry in pairs(ns.BuildTargetTrackingOptions()) do
		args[key] = entry
	end
	for key, entry in pairs(ns.BuildFreePlacementOptions()) do
		args[key] = entry
	end

	return {
		name = L["ADDON_TITLE"],
		type = "group",
		args = args,
	}
end
