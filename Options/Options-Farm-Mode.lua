local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

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
-- Farm Mode Options (composed into the General panel)
--------------------------------------------------------------------------------
function ns.BuildFarmModeOptions()
	return {
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
		subFarmActivate = ns.OptionsSubHeader(L["OPTIONS_FARM_ACTIVATE"], 23.1, function()
			return not ns.HasTrackingAbility()
		end),
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
			name = GetColor("HELP") .. L["OPTIONS_FARM_NOTE"] .. "|r",
			fontSize = "medium",
			order = 29.6,
			hidden = function()
				return not ns.HasTrackingAbility()
			end,
		},
	}
end
