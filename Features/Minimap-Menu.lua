local ADDON_NAME, ns = ...
local L = ns.L
local Kit = ns.MenuKit

--------------------------------------------------------------------------------
-- Mini-map Menu
--------------------------------------------------------------------------------

--[[
    The mini-map button's menu, built on Menu-Kit v2 (Features/Menu-Kit.lua):
    the add-on's name, then for each feature a gold title with where it stands
    on the right, a line saying what it does, and a blue Toggle row, then More
    Features and the Options row. Persistent Tracking's block also lists the
    abilities to pick from, between its description and its Toggle row, so
    picking one is a single click in the menu itself, and Clear Tracking under
    its Toggle row while something is picked or tracked. A title with settings
    to show carries the kit's arrow and opens its flyout beside the menu.

    The kit opens, places, closes and redraws it, and takes the button's
    clicks: Left-Click opens and holds the menu, Right-Click is Clear Tracking.

    The rules every add-on's menu follows (Style Guide → MINIMAP MENU):
      - Each block feature (Persistent Tracking, Farm Mode, Automatic Target
        Tracking) gets a block here: its title, its description, and a Toggle
        row for its Enable switch. Its flyout holds its settings, hidden while
        the feature is off, as the options hide them. Persistent Tracking's
        pick is the exception: it lives in the block.
      - A row for one class's spell shows only to a character who knows that
        spell; the options page lists every row, for profiles shared across
        classes. Hiding a row never changes its setting.
      - A switch's tooltip is its option's tooltip, and a Toggle row's is its
        Enable option's.
      - A pick from a set (an ability) closes the menu; a switch leaves it open.
      - Free Placement Mode and Come & Get It aren't changed mid-session, so each
        is one On/Off row in the More Features flyout rather than a block. Free
        Placement Mode's row opens its options panel instead of switching.
]]

Kit.SetText({
	on = L["MENU_ON"],
	off = L["MENU_OFF"],
	toggle = L["MENU_TOGGLE"],
	more = L["MENU_MORE"],
	moreFeatures = L["MENU_MORE_FEATURES"],
	featuresOn = L["MENU_FEATURE_COUNT_ON"],
	featuresOff = L["MENU_FEATURE_COUNT_OFF"],
	shortcut = L["MENU_SHORTCUT"],
})

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

-- True when this client has the spell and this character knows it.
local function IsKnown(spellId)
	return spellId ~= nil and IsPlayerSpell(spellId)
end

local function SpellText(spellId, name)
	return string.format("|T%s:0|t %s", C_Spell.GetSpellTexture(spellId) or ns.ICON_DEFAULT, name)
end

--------------------------------------------------------------------------------
-- Jobs
--------------------------------------------------------------------------------

--[[
    The jobs a row and a key binding share (Key-Bindings.lua). The button's
    clicks go to the kit (ns.HandleMenuClick, below): Left-Click opens and holds
    the menu, and Right-Click runs Clear Tracking while its row shows, which
    names "Right-Click" on its right, since a click the button does is named.
]]
local JOBS = {
	clear = function()
		ns.ClearTracking()
	end,
	farm = function()
		ns.db.profile.farmMode = not ns.db.profile.farmMode
	end,
	target = function()
		ns.SetTargetTracking(not ns.db.profile.targetTracking)
	end,
}

-- Runs one job by its key and redraws the menu and any open options page.
function ns.RunMenuJob(key)
	if not ns.db or not JOBS[key] then
		return
	end
	JOBS[key]()
	ns.RefreshSettings()
end

--[[
    Every tracking ability this character knows, by name. Cat Form tracking is
    left out of the Persistent Tracking pick in every form, since the menu never
    changes with what the character is doing; the Cat Form override covers it.
]]
local function KnownAbilities(includeCatFormOnly)
	local list = {}
	for _, id in ipairs(ns.TRACKING_IDS) do
		local name = C_Spell.GetSpellName(id)
		if name and IsPlayerSpell(id) and (includeCatFormOnly or not ns.CAT_FORM_ONLY[id]) then
			list[#list + 1] = { id = id, name = name }
		end
	end
	table.sort(list, function(a, b)
		return a.name < b.name
	end)
	return list
end

local function SpellTooltip(spellId)
	return function(tooltip)
		tooltip:SetSpellByID(spellId)
		if ns.CAT_FORM_ONLY[spellId] then
			tooltip:AddLine(
				L["OPTIONS_FARM_CAT_FORM_NOTE_NAMED"]:format(ns.GetSpellNameText(ns.SPELLS.CAT)),
				0.8,
				0.8,
				0.8,
				true
			)
		end
	end
end

--------------------------------------------------------------------------------
-- Actions
--------------------------------------------------------------------------------

-- The player's own pick ends any hunt and becomes the Persistent Tracking Ability.
local function PickPersistent(spellId)
	ns.EndHunt(false)
	ns.db.profile.selectedSpellId = spellId
	-- The cycle can include this ability, so the cache is now stale.
	ns.InvalidateFarmCache()
	ns.state.wasFarming = false
	ns.CastTracking(spellId)
end

-- A Persistent Tracking override changes the resolver's answer, so it recasts at once.
local function OnPersistentOverride()
	ns.InvalidateFarmCache()
	ns.TryRecastPersistent()
end

--------------------------------------------------------------------------------
-- Flyouts
--------------------------------------------------------------------------------

local FLYOUTS = {}

--[[
    The abilities to pick from, drawn inside Persistent Tracking's block in the
    main menu, the pick with a check. A pick closes the menu. The pick is chosen
    even with Persistent Tracking off, so the list never hides.
]]
local function PersistentPickRows()
	local profile = ns.db.profile
	local rows = {}
	for _, data in ipairs(KnownAbilities(false)) do
		rows[#rows + 1] = {
			kind = "choice",
			left = SpellText(data.id, data.name),
			selected = profile.selectedSpellId == data.id,
			tooltip = SpellTooltip(data.id),
			closes = true,
			onClick = function()
				PickPersistent(data.id)
			end,
		}
	end
	return rows
end

--[[
    Clear Tracking, under Persistent Tracking's Toggle row whenever something is
    picked or tracked: it clears either, so it shows for both. Right-Click on
    the button runs it only while it shows, and the row names that click.
]]
local function PersistentClearRows()
	if not ns.db.profile.selectedSpellId and not ns.GetActiveTrackingSpell() then
		return nil
	end
	return {
		{
			kind = "action",
			left = L["CLEAR_TRACKING"],
			click = "RightButton",
			right = L["MENU_CLICK_RIGHT"],
			rightColor = "MUTED",
			onClick = JOBS.clear,
		},
	}
end

--[[
    Only the three overrides, which mean anything only while Persistent Tracking
    is on, as on the options page. Each shows only to a character who knows its
    spell, so on most characters the flyout is empty and the title has no arrow.
]]
function FLYOUTS.persistent()
	local profile = ns.db.profile
	local entries = {}
	if not profile.persistentTracking then
		return entries
	end

	-- Each override shows only to a character who knows its spell; the options page lists all three.
	if IsKnown(ns.SPELLS.FISH) then
		entries[#entries + 1] = Kit.Toggle(
			profile,
			"fishingPoleFish",
			L["OPTIONS_FISHING_POLE_FISH_NAMED"]:format(ns.GetSpellNameText(ns.SPELLS.FISH), ns.GetFishingPoleName()),
			L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"],
			OnPersistentOverride
		)
	end
	if IsKnown(ns.SPELLS.DRUID_HUMANOIDS) then
		entries[#entries + 1] = Kit.Toggle(
			profile,
			"catFormHumanoids",
			L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"]:format(
				ns.GetClassNameText("DRUID"),
				ns.GetSpellNameText(ns.SPELLS.DRUID_HUMANOIDS),
				ns.GetSpellNameText(ns.SPELLS.CAT)
			),
			L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"],
			OnPersistentOverride
		)
	end
	if IsKnown(ns.SPELLS.HUMANOIDS) then
		entries[#entries + 1] = Kit.Toggle(
			profile,
			"battlegroundHumanoids",
			L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"]:format(
				ns.GetClassNameText("HUNTER"),
				ns.GetSpellNameText(ns.SPELLS.HUMANOIDS)
			),
			L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"],
			OnPersistentOverride
		)
	end
	return entries
end

--[[
    While Farm Mode is on: Farm Mode Status and, while paused, why; Tracking
    Now; Cycle Speed, whose own flyout picks it; the abilities to cycle; the
    conditions; and the extras. Farm Mode Abilities lists what this character
    knows; the options page lists every ability for shared profiles.
]]
function FLYOUTS.farm()
	local profile = ns.db.profile
	local global = ns.db.global
	local entries = {}
	if not profile.farmMode then
		return entries
	end

	local reason, reasonState = ns.GetFarmPauseReason()
	if reason then
		entries[#entries + 1] = Kit.Section(L["FARM_STATUS"], L["FARM_STATUS_PAUSED"], "MUTED")
		entries[#entries + 1] = { kind = "note", left = ns.FormatFarmPauseReason(reason, reasonState) }
	else
		entries[#entries + 1] = Kit.Section(L["FARM_STATUS"], L["FARM_STATUS_ACTIVE"], "ON")
	end

	--[[
		What the icon shows right now. There is no Next Switch line: the cycle holds
		while this menu is open (ns.IsOwnMenuShowing), so a countdown read here
		would never come true.
	]]
	local activeId = ns.GetActiveTrackingSpell()
	local activeName = activeId and C_Spell.GetSpellName(activeId)
	entries[#entries + 1] = {
		kind = "value",
		left = L["MENU_TRACKING_NOW"],
		right = activeName and SpellText(activeId, activeName) or L["MENU_TRACKING_NONE"],
		rightColor = not activeName and "MUTED" or nil,
	}
	entries[#entries + 1] = {
		kind = "value",
		left = L["OPTIONS_CYCLE_SPEED"],
		right = L["MENU_CYCLE_EVERY"]:format(ns.FormatFarmInterval(profile.farmInterval)),
		submenu = "speed",
		tooltip = Kit.OptionTooltip(L["OPTIONS_CYCLE_SPEED"], L["OPTIONS_CYCLE_SPEED_DESCRIPTION"]),
	}

	local cycleSpells = profile.farmCycleSpells or {}
	entries[#entries + 1] = Kit.Section(L["OPTIONS_FARM_ABILITIES"])
	entries[#entries + 1] = Kit.Toggle(
		profile,
		"farmIncludePersistent",
		L["OPTIONS_FARM_PERSISTENT"],
		L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"],
		ns.InvalidateFarmCache
	)
	for _, data in ipairs(KnownAbilities(true)) do
		entries[#entries + 1] = {
			kind = "toggle",
			left = SpellText(data.id, data.name),
			on = cycleSpells[data.id] and true or false,
			tooltip = SpellTooltip(data.id),
			onClick = function()
				if profile.farmCycleSpells then
					-- An explicit boolean, never nil: AceDB re-adds an absent default-true entry at login.
					profile.farmCycleSpells[data.id] = not profile.farmCycleSpells[data.id]
					ns.InvalidateFarmCache()
				end
			end,
		}
	end

	-- A class's travel state shows only to a character who knows a spell for it; the options page lists them all.
	entries[#entries + 1] = Kit.Section(L["OPTIONS_FARM_CONDITIONS"])
	local function Condition(field, name, desc, movementState)
		if movementState == nil or ns.KnowsMovementState(movementState) then
			entries[#entries + 1] = Kit.Toggle(profile, field, name, desc, ns.InvalidatePlayerStates)
		end
	end
	Condition("farmMounted", L["OPTIONS_FARM_MOUNTED"], L["OPTIONS_FARM_MOUNTED_DESCRIPTION"])
	Condition("farmNotMounted", L["OPTIONS_FARM_NOT_MOUNTED"], L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"])
	Condition(
		"farmTravelForms",
		L["OPTIONS_FARM_TRAVEL_FORMS_NAMED"]:format(ns.GetClassNameText("DRUID")),
		ns.GetFarmTravelFormsDescription and ns.GetFarmTravelFormsDescription(),
		"travelForms"
	)
	Condition("farmCheetah", ns.GetFarmClassStateLabel("cheetah"), L["OPTIONS_FARM_CHEETAH_DESCRIPTION"], "cheetah")
	Condition("farmPack", ns.GetFarmClassStateLabel("pack"), L["OPTIONS_FARM_PACK_GROUP_DESCRIPTION"], "pack")
	Condition(
		"farmGhostWolf",
		ns.GetFarmClassStateLabel("ghostWolf"),
		L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"],
		"ghostWolf"
	)

	entries[#entries + 1] = Kit.Separator()
	entries[#entries + 1] = Kit.Toggle(
		profile,
		"muteCycleSound",
		L["OPTIONS_SILENCE_TRACKING_SOUNDS"],
		L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"],
		function(value)
			-- Switching it off restores sound now, not at the end of the current window.
			if not value and ns.RestoreCycleSoundNow then
				ns.RestoreCycleSoundNow()
			end
		end
	)
	entries[#entries + 1] =
		Kit.Toggle(global, "farmZoomOut", L["OPTIONS_ZOOM_MINIMAP_OUT"], L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"])
	entries[#entries + 1] = Kit.Toggle(
		profile,
		"farmPauseForWindows",
		L["OPTIONS_FARM_PAUSE_WINDOWS"],
		L["OPTIONS_FARM_PAUSE_WINDOWS_DESCRIPTION"]
	)
	return entries
end

-- Cycle Speed's choices, off Farm Mode's flyout: the options dropdown's range, 2 to 10 seconds in half-second steps.
function FLYOUTS.speed()
	local profile = ns.db.profile
	local entries = {}
	if not profile.farmMode then
		return entries
	end
	for halfSeconds = ns.FARM_INTERVAL_MIN * 2, ns.FARM_INTERVAL_MAX * 2 do
		local seconds = halfSeconds * ns.FARM_INTERVAL_STEP
		entries[#entries + 1] = {
			kind = "choice",
			left = L["MENU_CYCLE_EVERY"]:format(ns.FormatFarmInterval(seconds)),
			selected = profile.farmInterval == seconds,
			onClick = function()
				ns.SetFarmInterval(seconds)
			end,
		}
	end
	return entries
end

--------------------------------------------------------------------------------
-- Main Menu
--------------------------------------------------------------------------------

local function BuildMainEntries()
	local profile = ns.db.profile
	local entries = {
		{ kind = "header", left = L["ADDON_TITLE"], right = ns.Version or "" },
		Kit.Spacer(),
	}

	-- Persistent Tracking reads On or Off like the others; its pick carries the check in the list below.
	local state, stateColor = Kit.OnOff(profile.persistentTracking)
	Kit.FeatureBlock(entries, {
		key = "persistent",
		title = L["PERSISTENT_TRACKING"],
		state = state,
		stateColor = stateColor,
		description = L["MENU_PERSISTENT_DESCRIPTION"],
		rows = PersistentPickRows(),
		after = PersistentClearRows(),
		toggle = {
			name = L["OPTIONS_ENABLE_PERSISTENT"],
			desc = L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"],
			flip = function()
				ns.SetPersistentTracking(not profile.persistentTracking)
			end,
		},
	})

	-- Farm Mode: Active in green, Paused or Off in gray. While paused, a labelled gray note under the description says why.
	state, stateColor = Kit.OnOff(false)
	local farmNote
	if profile.farmMode then
		local reason, reasonState = ns.GetFarmPauseReason()
		if reason then
			state, stateColor = L["FARM_STATUS_PAUSED"], "MUTED"
			farmNote = L["MENU_FARM_PAUSED_REASON"]:format(ns.FormatFarmPauseReason(reason, reasonState))
		else
			state, stateColor = L["FARM_STATUS_ACTIVE"], "ON"
		end
	end
	Kit.FeatureBlock(entries, {
		key = "farm",
		title = L["TAB_FARM_MODE"],
		state = state,
		stateColor = stateColor,
		description = L["MENU_FARM_DESCRIPTION"],
		note = farmNote,
		toggle = {
			name = L["OPTIONS_ENABLE_FARM"],
			desc = L["OPTIONS_ENABLE_FARM_DESCRIPTION"],
			flip = function()
				ns.RunMenuJob("farm")
			end,
		},
	})

	--[[
		Only for a character with an ability a hunt can cast: a druid's Cat Form
		Track Humanoids never counts. Switching it off ends any hunt, through
		SetTargetTracking.
	]]
	if ns.KnowsHuntAbility() then
		state, stateColor = Kit.OnOff(profile.targetTracking)
		Kit.FeatureBlock(entries, {
			key = "targetTracking",
			title = L["TARGET_TRACKING"],
			state = state,
			stateColor = stateColor,
			description = L["MENU_TARGET_DESCRIPTION"],
			toggle = {
				name = L["OPTIONS_ENABLE_TARGET_TRACKING"],
				desc = L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"],
				flip = function()
					ns.RunMenuJob("target")
				end,
			},
		})
	end

	-- Come & Get It and Free Placement Mode, from ns.FEATURES, in the More Features flyout with their count.
	Kit.MoreFeatures(entries)
	Kit.OptionsRow(entries, L["MENU_OPTIONS"])
	return entries
end

--------------------------------------------------------------------------------
-- The Menu
--------------------------------------------------------------------------------

--[[
    The kit's menu: named, so Escape closes it, and it publishes ns.ShowMenu,
    ns.HideMenu, ns.RefreshMenu, ns.IsMenuShown, ns.IsMenuFrame and
    ns.OpenFlyout for the rest of the add-on.
    Every row click ends in ns.RefreshSettings, so an open options page follows.
]]
local menu = Kit.CreateMenu({
	name = ADDON_NAME .. "Menu",
	build = BuildMainEntries,
	flyouts = FLYOUTS,
	afterChange = function()
		ns.RefreshSettings()
	end,
})

-- Both launchers hand every click here (Minimap-Button.lua, Free-Placement.lua).
function ns.HandleMenuClick(anchor, button)
	return menu:HandleClick(anchor, button)
end

--------------------------------------------------------------------------------
-- Blizzard Tracking Button Hook
--------------------------------------------------------------------------------

--[[
    Optional take-over of Classic Era's mini-map tracking icon, which has no menu
    of its own: a right-click there cancels tracking, and the take-over replaces
    that with this menu, where the Persistent Tracking abilities are one click. On TBC Anniversary
    and MoP Classic the icon is a Blizzard dropdown button that opens Blizzard's
    tracking menu on mouse-down, which no script swap can stop, so it is left
    alone and the option doesn't show. Off by default: it reaches into a frame
    the add-on does not own, and some UIs already bind it.

    Take-over rather than HookScript, because a hook would leave Blizzard's handler
    running. The original is saved so turning the option off puts the frame back
    exactly as found. The frame is neither secure nor protected, so replacing its
    script raises no taint.
]]
local blizzardHooked = false
local blizzardSavedHandler = nil

local function GetBlizzardTrackingButton()
	if MiniMapTrackingButton then
		return nil
	end
	return MiniMapTracking
end

function ns.HasBlizzardTrackingButton()
	return GetBlizzardTrackingButton() ~= nil
end

function ns.ApplyBlizzardTrackingHook()
	local button = GetBlizzardTrackingButton()
	if not button or not button.SetScript then
		return
	end

	local enabled = ns.db and ns.db.global.hookBlizzardTracking or false

	if enabled and not blizzardHooked then
		blizzardHooked = true
		blizzardSavedHandler = button:GetScript("OnMouseUp")
		button:SetScript("OnMouseUp", function()
			ns.ShowMenu(button, nil, "click")
		end)
	elseif not enabled and blizzardHooked then
		button:SetScript("OnMouseUp", blizzardSavedHandler)
		blizzardHooked = false
		blizzardSavedHandler = nil
	end
end
