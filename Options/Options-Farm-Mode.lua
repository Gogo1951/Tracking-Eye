local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--[[
    Enable Farm Mode and the cycle-interval dropdown share one row, so the two
    widths total ns.OPTIONS_ROW_WIDTH and the row ends where every other row ends.
    The split favors the dropdown: a narrow checkbox wraps its label onto a second
    line, while a narrow dropdown truncates the selected text and the player can no
    longer read their own setting.
]]
local FARM_TOGGLE_WIDTH = 1.1
local CYCLE_SELECT_WIDTH = ns.OPTIONS_ROW_WIDTH - FARM_TOGGLE_WIDTH

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

local function HiddenNoTracking()
	return not ns.HasTrackingAbility()
end

--[[
    Enable Farm Mode is the panel's master switch: everything below it hides
    outright when Farm Mode is off, so the page is the toggle and nothing else.
]]
local function FarmOff()
	return HiddenNoTracking() or not (ns.db and ns.db.profile.farmMode)
end

local function FarmOffOrNotDruid()
	return FarmOff() or not ns.IsPlayerClass("DRUID")
end

local function FarmOffOrNotHunter()
	return FarmOff() or not ns.IsPlayerClass("HUNTER")
end

local function FarmOffOrNotShaman()
	return FarmOff() or not ns.IsPlayerClass("SHAMAN")
end

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
	--[[
		Leads the list rather than sitting among the spells: it is a rule about the
		rotation, not a spell of its own, so it carries no icon. Always shown and
		never greyed — with no ability selected it simply has nothing to add.
	]]
	local args = {
		persistentAbility = {
			type = "toggle",
			name = L["PERSISTENT_ABILITY"],
			desc = L["OPTIONS_FARM_PERSISTENT_DESC"],
			order = 0,
			width = "full",
			get = function()
				return ns.db and ns.db.profile.farmIncludePersistent
			end,
			set = function(_, value)
				if ns.db then
					ns.db.profile.farmIncludePersistent = value
					ns.InvalidateFarmCache()
				end
			end,
		},
		spacePersistentAbility = {
			type = "description",
			name = " ",
			order = 0.5,
		},
	}
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
-- Farm Mode Panel
--------------------------------------------------------------------------------

--[[
    Its own child panel rather than a section merged into General: Farm Mode
    carries more controls than every other feature combined, and the General page
    had grown long enough that Cycle Speed sat below the fold.
]]
function ns.BuildFarmModeOptions()
	return {
		type = "group",
		name = L["TAB_FARM_MODE"],
		args = {
			descFarm = {
				type = "description",
				name = L["FARM_MODE_DESC"],
				fontSize = "medium",
				order = 1,
				hidden = HiddenNoTracking,
			},
			spaceFM1 = {
				type = "description",
				name = " ",
				order = 2,
				hidden = HiddenNoTracking,
			},
			enableFarm = {
				type = "toggle",
				name = L["OPTIONS_ENABLE_FARM"],
				order = 3,
				width = FARM_TOGGLE_WIDTH,
				hidden = HiddenNoTracking,
				get = function()
					return ns.db and ns.db.profile.farmMode
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.farmMode = value
					end
				end,
			},
			-- Shares the row with the toggle above, so it carries no caption of its own.
			cycleSpeed = {
				type = "select",
				name = "",
				desc = L["OPTIONS_CYCLE_EVERY_DESC"],
				order = 3.05,
				width = CYCLE_SELECT_WIDTH,
				style = "dropdown",
				values = CYCLE_VALUES,
				sorting = CYCLE_SORTING,
				hidden = FarmOff,
				get = function()
					local interval = (ns.db and ns.db.profile.farmInterval) or ns.DATABASE_DEFAULTS.profile.farmInterval
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
			spaceFarmToggles = {
				type = "description",
				name = " ",
				order = 3.07,
				hidden = FarmOff,
			},
			muteCycleSound = {
				type = "toggle",
				name = L["SILENCE_TRACKING_SOUNDS"],
				desc = L["SILENCE_TRACKING_SOUNDS_DESC"],
				order = 3.1,
				width = "full",
				hidden = FarmOff,
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
			-- Note (directly under the toggles, ahead of the conditions section)
			descFarmNote = {
				type = "description",
				name = GetColor("HELP") .. L["OPTIONS_FARM_NOTE"] .. "|r",
				fontSize = "medium",
				order = 3.2,
				hidden = FarmOff,
			},

			spaceFMEnable = {
				type = "description",
				name = " ",
				order = 3.5,
				hidden = FarmOff,
			},

			headerFarmActivate = ns.OptionsHeader(L["OPTIONS_FARM_CONDITIONS"], 4, FarmOff),
			spaceFarmActivate = {
				type = "description",
				name = " ",
				order = 4.5,
				hidden = FarmOff,
			},
			farmMounted = {
				type = "toggle",
				name = L["OPTIONS_FARM_MOUNTED"],
				order = 5,
				width = "full",
				hidden = FarmOff,
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
				order = 6,
				width = "full",
				hidden = FarmOffOrNotDruid,
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
				order = 7,
				width = "full",
				hidden = FarmOffOrNotHunter,
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
				order = 8,
				width = "full",
				hidden = FarmOffOrNotShaman,
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
				order = 9,
				width = "full",
				hidden = FarmOff,
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
				order = 10,
				hidden = FarmOff,
			},

			headerFarmAbilities = ns.OptionsHeader(L["OPTIONS_FARM_ABILITIES"], 10.5, FarmOff),
			spaceFarmAbilities = {
				type = "description",
				name = " ",
				order = 10.6,
				hidden = FarmOff,
			},
			--[[
				The section title is the header above, not the group's own name: a
				colored group caption is not a section header. The group stays for
				the multi-select toggle list, unnamed so the title is drawn once.
			]]
			farmAbilities = {
				type = "group",
				name = "",
				order = 11,
				inline = true,
				hidden = FarmOff,
				args = BuildFarmAbilityArgs(),
			},
		},
	}
end
