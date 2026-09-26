local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local RowLabel = ns.OptionsRowLabel
local SubRow, SubLabel = ns.OptionsSubRow, ns.OptionsSubLabel

-- Sized to its caption with slack; never the full row width. See ns.OptionsSubRow.
local SUB_TOGGLE_WIDTH = 2.4

-- The interval dropdown is sized to its longest caption with slack; its label takes the rest of the row.
local CYCLE_SELECT_WIDTH = 1.6
local CYCLE_LABEL_WIDTH = ns.OPTIONS_ROW_WIDTH - CYCLE_SELECT_WIDTH

--[[
    Cycle interval choices, 2 to 10 seconds in half-second steps, built once at
    load. Half-second multiples are exact in binary, so the keys always match what
    the ticker stores. CYCLE_SORTING is not optional: AceConfigDialog hands it
    straight to the Dropdown widget, and without it the numeric keys fall back to
    string sorting, which puts "10" ahead of "2".
]]
local CYCLE_VALUES = {}
local CYCLE_SORTING = {}
for halfSeconds = 4, 20 do
	local seconds = halfSeconds * 0.5
	-- One decimal throughout, except a bare "10" at the top of the range.
	local shown = seconds == 10 and "10" or string.format("%.1f", seconds)
	CYCLE_VALUES[seconds] = L["OPTIONS_CYCLE_EVERY"]:format(shown)
	CYCLE_SORTING[#CYCLE_SORTING + 1] = seconds
end

--[[
    Enable Farm Mode is the panel's master switch: everything below it hides
    outright when Farm Mode is off, so the page is the toggle and nothing else.
    Every gated widget shares that one condition, so the builders below bake it in.
]]
local function FarmOff()
	return not (ns.db and ns.db.profile.farmMode)
end

local function FarmSpacer(order)
	return { type = "description", name = " ", order = order, hidden = FarmOff }
end

local function FarmDesc(text, order)
	return { type = "description", name = text, fontSize = "medium", order = order, hidden = FarmOff }
end

-- A Farm Mode Conditions toggle bound to one profile field, hidden where this flavor can't detect its state.
local function ConditionToggle(field, name, desc, order, state)
	return {
		type = "toggle",
		name = name,
		desc = desc,
		order = order,
		width = "full",
		hidden = function()
			return FarmOff() or (state ~= nil and not ns.IsMovementStateDetectable(state))
		end,
		get = function()
			return ns.db and ns.db.profile[field]
		end,
		set = function(_, value)
			if ns.db then
				ns.db.profile[field] = value
			end
		end,
	}
end

local function SpellLabel(spellId, name, suffix)
	local texture = C_Spell.GetSpellTexture(spellId) or ns.ICON_DEFAULT
	local label = string.format("|T%s:16|t %s", texture, name)
	if suffix then
		label = label .. "  " .. GetColor("MUTED") .. suffix .. "|r"
	end
	return label
end

--------------------------------------------------------------------------------
-- Farm Ability Groups
--------------------------------------------------------------------------------

-- The first group: every source ns.FARM_ABILITY_CLASSES doesn't name (professions, racials).
local GENERAL_GROUP = "GENERAL"

local SOURCE_CLASS = {}
local GROUP_ORDER = { GENERAL_GROUP }
for _, entry in ipairs(ns.FARM_ABILITY_CLASSES) do
	SOURCE_CLASS[entry.source] = entry.class
	GROUP_ORDER[#GROUP_ORDER + 1] = entry.class
end

-- A class heading takes the class's color and the client's own name for it, so it localizes for free.
local function GroupLabel(group)
	if group == GENERAL_GROUP then
		return GetColor("TITLE") .. L["OPTIONS_FARM_GROUP_GENERAL"] .. "|r"
	end
	local name = LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[group] or group
	local hex = ns.CLASS_COLORS[group]
	return hex and ("|cff" .. hex .. name .. "|r") or name
end

local function AbilityToggle(id, name, order)
	return {
		type = "toggle",
		--[[
			The hover shows the ability's own in-game tooltip, so the one catch worth
			a note (the druid's tracking cycles only in Cat Form) sits on the panel,
			muted beside the name.
		]]
		name = SpellLabel(id, name, ns.CAT_FORM_ONLY[id] and L["OPTIONS_FARM_CAT_FORM_NOTE"] or nil),
		tooltipHyperlink = "spell:" .. id,
		order = order,
		width = "full",
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
end

--[[
    Include Persistent Tracking Ability, then one bordered group per source in
    GROUP_ORDER, the way Control Freak groups its abilities. Each group is its
    own named inline group, so its caption is the class heading; a group with
    nothing to list is left out.
]]
local function AddFarmAbilityGroups(args, order)
	--[[
		Leads the list rather than sitting among the spells: it is a rule about the
		rotation, not a spell of its own, so it carries no icon. Always shown and
		never greyed — with no ability selected it simply has nothing to add.
	]]
	args.persistentAbility = {
		type = "toggle",
		name = L["OPTIONS_FARM_PERSISTENT"],
		desc = L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"],
		order = order,
		width = "full",
		hidden = FarmOff,
		get = function()
			return ns.db and ns.db.profile.farmIncludePersistent
		end,
		set = function(_, value)
			if ns.db then
				ns.db.profile.farmIncludePersistent = value
				ns.InvalidateFarmCache()
			end
		end,
	}
	args.spacePersistentAbility = FarmSpacer(order + 0.5)

	--[[
		Every tracking spell this client has is listed, learned or not: the list
		saves to the profile, which characters of any class can share, and the
		cycle leaves out whatever this character hasn't learned.
	]]
	local groups = {}
	for _, id in ipairs(ns.TRACKING_IDS) do
		local name = C_Spell.GetSpellName(id)
		if name then
			local group = SOURCE_CLASS[ns.TRACKING_SOURCE[id]] or GENERAL_GROUP
			groups[group] = groups[group] or {}
			table.insert(groups[group], { id = id, name = name })
		end
	end

	local groupOrder = order + 1
	for _, group in ipairs(GROUP_ORDER) do
		local spells = groups[group]
		if spells then
			table.sort(spells, function(a, b)
				return a.name < b.name
			end)
			local groupArgs = {}
			for index, data in ipairs(spells) do
				groupArgs["spell_" .. data.id] = AbilityToggle(data.id, data.name, index)
			end
			args["abilities" .. group] = {
				type = "group",
				name = GroupLabel(group),
				inline = true,
				order = groupOrder,
				hidden = FarmOff,
				args = groupArgs,
			}
			groupOrder = groupOrder + 1
		end
	end
end

--------------------------------------------------------------------------------
-- Farm Mode Panel
--------------------------------------------------------------------------------

--[[
    Its own child panel rather than a section merged into General: Farm Mode
    carries more controls than every other feature combined, and the General page
    had grown long enough that Cycle Speed sat below the fold.
]]
function ns.BuildFarmModeOptions()
	local args = {
		descFarm = ns.OptionsDesc(L["OPTIONS_FARM_MODE_DESCRIPTION"], 1),
		spaceFarmMode1 = ns.OptionsSpacer(2),
		enableFarm = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_FARM"],
			desc = L["OPTIONS_ENABLE_FARM_DESCRIPTION"],
			order = 3,
			width = "full",
			get = function()
				return ns.db and ns.db.profile.farmMode
			end,
			set = function(_, value)
				if ns.db then
					ns.db.profile.farmMode = value
				end
			end,
		},
		muteCycleSoundRow = SubRow(3.1, FarmOff, {
			{
				type = "toggle",
				name = SubLabel(L["OPTIONS_SILENCE_TRACKING_SOUNDS"]),
				desc = L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"],
				width = SUB_TOGGLE_WIDTH,
				get = function()
					return ns.db and ns.db.profile.muteCycleSound
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.muteCycleSound = value
					end
					-- Switching it off restores sound now, not at the end of the current window.
					if not value and ns.RestoreCycleSoundNow then
						ns.RestoreCycleSoundNow()
					end
				end,
			},
		}),
		zoomOutRow = SubRow(3.2, FarmOff, {
			{
				type = "toggle",
				name = SubLabel(L["OPTIONS_ZOOM_MINIMAP_OUT"]),
				desc = L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"],
				width = SUB_TOGGLE_WIDTH,
				get = function()
					return ns.db and ns.db.global.farmZoomOut
				end,
				set = function(_, value)
					if ns.db then
						ns.db.global.farmZoomOut = value
					end
				end,
			},
		}),
		spaceFarmModeEnable = FarmSpacer(3.5),

		headerFarmActivate = ns.OptionsHeader(L["OPTIONS_FARM_CONDITIONS"], 4, FarmOff),
		spaceFarmActivate = FarmSpacer(4.5),
		descFarmActivate = FarmDesc(L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"], 4.6),
		spaceFarmActivateDesc = FarmSpacer(4.7),
		farmMounted = ConditionToggle(
			"farmMounted",
			L["OPTIONS_FARM_MOUNTED"],
			L["OPTIONS_FARM_MOUNTED_DESCRIPTION"],
			5
		),
		farmNotMounted = ConditionToggle(
			"farmNotMounted",
			L["OPTIONS_FARM_NOT_MOUNTED"],
			L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"],
			6
		),
		--[[
				The class forms sit apart, each labeled with its class. They are
				offered to every class, not only the one that owns the state: these
				save to the profile, which characters of any class can share, and a
				state this character never enters simply never starts the cycle.
				Only a state this flavor's data can't detect is hidden.
			]]
		spaceFarmClassForms = FarmSpacer(6.5),
		farmTravelForms = ConditionToggle(
			"farmTravelForms",
			L["OPTIONS_FARM_TRAVEL_FORMS"],
			L["OPTIONS_FARM_TRAVEL_FORMS_DESCRIPTION"],
			7,
			"travelForms"
		),
		farmCheetah = ConditionToggle(
			"farmCheetah",
			L["OPTIONS_FARM_CHEETAH"],
			L["OPTIONS_FARM_CHEETAH_DESCRIPTION"],
			8,
			"cheetah"
		),
		farmPack = ConditionToggle("farmPack", L["OPTIONS_FARM_PACK"], L["OPTIONS_FARM_PACK_DESCRIPTION"], 8.1, "pack"),
		farmGhostWolf = ConditionToggle(
			"farmGhostWolf",
			L["OPTIONS_FARM_GHOST_WOLF"],
			L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"],
			9,
			"ghostWolf"
		),
		spaceCycleSpeed = FarmSpacer(9.5),
		-- An unnamed inline group, so the label and its dropdown hide as one row.
		cycleSpeedRow = {
			type = "group",
			name = "",
			inline = true,
			order = 9.6,
			hidden = FarmOff,
			args = {
				label = RowLabel(L["OPTIONS_CYCLE_SPEED"], 1, CYCLE_LABEL_WIDTH),
				interval = {
					type = "select",
					name = "",
					desc = L["OPTIONS_CYCLE_SPEED_DESCRIPTION"],
					width = CYCLE_SELECT_WIDTH,
					order = 2,
					style = "dropdown",
					values = CYCLE_VALUES,
					sorting = CYCLE_SORTING,
					get = function()
						local interval = ns.db and ns.db.profile.farmInterval
						--[[
								A stored value that is not one of the choices renders the
								dropdown blank, so fall back to the default for display. The
								ticker keeps using whatever is stored until the player picks.
							]]
						return CYCLE_VALUES[interval] and interval or ns.DATABASE_DEFAULTS.profile.farmInterval
					end,
					set = function(_, value)
						if ns.db then
							ns.db.profile.farmInterval = value
						end
						ns.RestartFarmTicker()
					end,
				},
			},
		},

		spaceFarmMode2 = FarmSpacer(10),

		headerFarmAbilities = ns.OptionsHeader(L["OPTIONS_FARM_ABILITIES"], 10.5, FarmOff),
		spaceFarmAbilities = FarmSpacer(10.6),
		descFarmAbilities = FarmDesc(L["OPTIONS_FARM_ABILITIES_DESCRIPTION"], 10.7),
		spaceFarmAbilitiesDesc = FarmSpacer(10.8),
	}
	AddFarmAbilityGroups(args, 11)

	return {
		type = "group",
		name = L["TAB_FARM_MODE"],
		args = args,
	}
end
