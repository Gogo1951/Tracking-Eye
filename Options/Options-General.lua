local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer

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

		spaceCommands0 = Spacer(4),
		headerCommands = Header("/Commands", 5),
		spaceCommands1 = Spacer(6),
		descCommandsIntro = Desc(L["OPTIONS_COMMANDS_INTRO"], 7),
		spaceCommands2 = Spacer(7.1),
		descCommandTE = Desc(GetColor("INFO") .. "/te|r" .. "  " .. L["OPTIONS_COMMAND_TE"], 7.2),

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
		discordLabel = Desc(GetColor("TITLE") .. L["OPTIONS_DISCORD"] .. "|r", 72),
		discordURL = {
			type = "input",
			name = "",
			order = 73,
			width = "double",
			get = function()
				return ns.DISCORD_URL
			end,
			set = function() end,
		},
		spaceLinks2 = Spacer(74),
		githubLabel = Desc(GetColor("TITLE") .. L["OPTIONS_GITHUB"] .. "|r", 75),
		githubURL = {
			type = "input",
			name = "",
			order = 76,
			width = "double",
			get = function()
				return ns.GITHUB_URL
			end,
			set = function() end,
		},
		spaceLinks3 = Spacer(77),
		curseforgeLabel = Desc(GetColor("TITLE") .. L["OPTIONS_CURSEFORGE"] .. "|r", 78),
		curseforgeURL = {
			type = "input",
			name = "",
			order = 79,
			width = "double",
			get = function()
				return ns.CURSEFORGE_URL
			end,
			set = function() end,
		},
		spaceLinks4 = Spacer(80),
		wagoLabel = Desc(GetColor("TITLE") .. L["OPTIONS_WAGO"] .. "|r", 81),
		wagoURL = {
			type = "input",
			name = "",
			order = 82,
			width = "double",
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
		Farm Mode and Free Placement each own their widgets in their own file and
		return an args fragment; merge them into the General page so the layout is
		a single scrolling panel. Order values are unique across fragments, so the
		page renders in the same order regardless of merge sequence.
	]]
	for key, entry in pairs(ns.BuildFarmModeOptions()) do
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
