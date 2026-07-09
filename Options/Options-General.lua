local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer

local function SpellLabel(spellId, name, suffix)
	local texture = GetSpellTexture(spellId) or ns.ICON_DEFAULT
	local label = string.format("|T%s:16|t %s", texture, name)
	if suffix then
		label = label .. "  " .. GetColor("MUTED") .. suffix .. "|r"
	end
	return label
end

--------------------------------------------------------------------------------
-- Build Farm Ability Args
--------------------------------------------------------------------------------
local function BuildFarmAbilityArgs()
	local args = {}
	local order = 1

	local allSpells = {}
	for _, id in ipairs(ns.TRACKING_IDS) do
		if id ~= ns.SPELLS.DRUID_HUMANOIDS then
			local name = GetSpellInfo(id)
			if name then
				table.insert(allSpells, { id = id, name = name })
			end
		end
	end
	table.sort(allSpells, function(a, b)
		return a.name < b.name
	end)

	for _, data in ipairs(allSpells) do
		local id = data.id
		local key = "spell_" .. id

		args[key] = {
			type = "toggle",
			name = SpellLabel(id, data.name),
			order = order,
			width = "full",
			hidden = function()
				return not IsPlayerSpell(id)
			end,
			get = function()
				return ns.db and ns.db.profile.farmCycleSpells and ns.db.profile.farmCycleSpells[id] or false
			end,
			set = function(_, value)
				if ns.db and ns.db.profile.farmCycleSpells then
					--[[
                        Store an explicit boolean, never nil. AceDB re-adds a
                        default-true entry for any absent default key on the next
                        login, so a disabled Herbs/Minerals must be recorded as
                        false to survive.
                    ]]
					ns.db.profile.farmCycleSpells[id] = value and true or false
					ns.InvalidateFarmCache()
				end
			end,
		}
		order = order + 1
	end

	return args
end

--------------------------------------------------------------------------------
-- General Options Panel
--------------------------------------------------------------------------------
function ns.BuildGeneralOptions()
	return {
		name = L["ADDON_TITLE"],
		type = "group",
		args = {

			descIntro = Desc(L["OPTIONS_DESC"], 1),

			spaceWelcome0 = Spacer(2),
			enableWelcome = {
				type = "toggle",
				name = L["OPTIONS_ENABLE_WELCOME"],
				desc = L["OPTIONS_WELCOME_DESC"],
				order = 3,
				width = "full",
				get = function()
					return ns.db and ns.db.profile.showWelcome
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.showWelcome = value
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
					return ns.db and ns.db.profile.freePlacement
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
			spaceCommands3 = Spacer(7.3),
			descCommandTrackingEye = Desc(GetColor("INFO") .. "/trackingeye|r" .. "  " .. L["OPTIONS_COMMAND_TE"], 7.4),

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

			-- Farm Mode (entire section hidden when no tracking abilities are known)
			spaceFM0 = {
				type = "description",
				name = " ",
				order = 19,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},
			headerFarm = {
				type = "header",
				name = GetColor("TITLE") .. L["FARM_MODE"] .. "|r",
				order = 20,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},
			spaceFMHeader = {
				type = "description",
				name = " ",
				order = 20.5,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},
			descFarm = {
				type = "description",
				name = L["FARM_MODE_DESC"],
				fontSize = "medium",
				order = 21,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},
			spaceFM1 = {
				type = "description",
				name = " ",
				order = 22,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},
			enableFarm = {
				type = "toggle",
				name = L["OPTIONS_ENABLE_FARM"],
				order = 23,
				width = "full",
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
				get = function()
					return ns.db and ns.db.profile.farmMode
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.farmMode = value
					end
				end,
			},

			-- Activate Farm Mode While: (movement-state toggles; class ones hidden per class)
			subFarmActivate = {
				type = "description",
				name = "\n" .. GetColor("TITLE") .. L["OPTIONS_FARM_ACTIVATE"] .. "|r",
				fontSize = "medium",
				order = 23.1,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},
			farmMounted = {
				type = "toggle",
				name = L["OPTIONS_FARM_MOUNTED"],
				order = 23.2,
				width = "full",
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
				get = function()
					return ns.db and ns.db.profile.farmMounted
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.farmMounted = value
					end
				end,
			},
			farmTravelForms = {
				type = "toggle",
				name = L["OPTIONS_FARM_TRAVEL_FORMS"],
				order = 23.3,
				width = "full",
				hidden = function()
					return not ns.HasTrackingAbility() or not ns.IsPlayerClass("DRUID")
				end,
				get = function()
					return ns.db and ns.db.profile.farmTravelForms
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.farmTravelForms = value
					end
				end,
			},
			farmCheetah = {
				type = "toggle",
				name = L["OPTIONS_FARM_CHEETAH"],
				order = 23.4,
				width = "full",
				hidden = function()
					return not ns.HasTrackingAbility() or not ns.IsPlayerClass("HUNTER")
				end,
				get = function()
					return ns.db and ns.db.profile.farmCheetah
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.farmCheetah = value
					end
				end,
			},
			farmGhostWolf = {
				type = "toggle",
				name = L["OPTIONS_FARM_GHOST_WOLF"],
				order = 23.5,
				width = "full",
				hidden = function()
					return not ns.HasTrackingAbility() or not ns.IsPlayerClass("SHAMAN")
				end,
				get = function()
					return ns.db and ns.db.profile.farmGhostWolf
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.farmGhostWolf = value
					end
				end,
			},
			farmNotMounted = {
				type = "toggle",
				name = L["OPTIONS_FARM_NOT_MOUNTED"],
				desc = L["OPTIONS_FARM_NOT_MOUNTED_DESC"],
				order = 23.6,
				width = "full",
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
				get = function()
					return ns.db and ns.db.profile.farmNotMounted
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.farmNotMounted = value
					end
				end,
			},
			spaceFM2 = {
				type = "description",
				name = " ",
				order = 24,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},

			-- Farm Mode Abilities (inline group)
			farmAbilities = {
				type = "group",
				name = GetColor("TITLE") .. L["OPTIONS_FARM_ABILITIES"] .. "|r",
				order = 25,
				inline = true,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
				args = BuildFarmAbilityArgs(),
			},
			spaceFM3 = {
				type = "description",
				name = " ",
				order = 26,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},

			cycleSpeed = {
				type = "range",
				name = L["OPTIONS_CYCLE_SPEED"],
				desc = L["OPTIONS_CYCLE_SPEED_DESC"],
				order = 29,
				width = "double",
				min = 2,
				max = 10,
				step = 0.5,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
				get = function()
					return ns.db and ns.db.profile.farmInterval or ns.DATABASE_DEFAULTS.profile.farmInterval
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.farmInterval = value
					end
					ns.RestartFarmTicker()
				end,
			},

			-- Note (below Cycle Speed, with a leading spacer)
			spaceFarmNote = {
				type = "description",
				name = " ",
				order = 29.5,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},
			descFarmNote = {
				type = "description",
				name = GetColor("BODY") .. L["OPTIONS_FARM_NOTE"] .. "|r",
				fontSize = "medium",
				order = 29.6,
				hidden = function()
					return not ns.HasTrackingAbility()
				end,
			},

			spaceFP0 = Spacer(39),
			headerFree = Header(L["PLACEMENT_MODE"], 40),
			spaceFPHeader = Spacer(40.5),
			descFree = Desc(L["PLACEMENT_DESC"], 41),
			spaceFP1 = Spacer(42),
			enableFree = {
				type = "toggle",
				name = L["OPTIONS_ENABLE_FREE"],
				order = 43,
				width = "full",
				get = function()
					return ns.db and ns.db.profile.freePlacement
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.freePlacement = value
						ns.UpdatePlacement()
					end
				end,
			},
			spaceFP2 = Spacer(44),

			iconShape = {
				type = "select",
				name = L["OPTIONS_ICON_SHAPE"],
				desc = L["OPTIONS_ICON_SHAPE_DESC"],
				order = 45,
				style = "dropdown",
				values = {
					[ns.SHAPES.CIRCLE] = L["OPTIONS_SHAPE_CIRCLE"],
					[ns.SHAPES.SQUARE] = L["OPTIONS_SHAPE_SQUARE"],
				},
				get = function()
					return ns.db and ns.db.profile.freeIconShape or ns.DATABASE_DEFAULTS.profile.freeIconShape
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.freeIconShape = value
					end
					ns.UpdateFreeFrameShape()
				end,
			},
			spaceFP3 = Spacer(46),

			iconScale = {
				type = "range",
				name = L["OPTIONS_ICON_SCALE"],
				desc = L["OPTIONS_ICON_SCALE_DESC"],
				order = 47,
				width = "double",
				min = 0.25,
				max = 3.0,
				step = 0.05,
				isPercent = true,
				get = function()
					return ns.db and ns.db.profile.freeIconScale or ns.DATABASE_DEFAULTS.profile.freeIconScale
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.freeIconScale = value
					end
					ns.UpdateFreeFrameScale()
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
		},
	}
end
