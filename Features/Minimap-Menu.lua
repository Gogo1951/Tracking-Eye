local ADDON_NAME, ns = ...
local L = ns.L
local Kit = ns.MenuKit

--------------------------------------------------------------------------------
-- Mini-map Menu
--------------------------------------------------------------------------------

--[[
    The mini-map button's menu, laid out as Pretty Wide Quest Log's Quest Arrow
    menu is: the add-on's name, a gold label for each feature with where it stands
    on the right and Blizzard's submenu arrow, then the Options row. A label opens
    its flyout beside the menu, under the cursor or on a click, and the flyout
    holds the feature's switch first, then its settings.

    Hovering the launcher opens it, the way the old tooltip did, and moving into
    it keeps it open; it closes a moment after the cursor leaves the launcher, the
    menu, and the flyout. A left-click opens it with the Persistent Tracking flyout
    already out, so picking a tracking ability stays one click. Everything is a
    plain click, so a controller's cursor reaches all of it: no modifier keys, no
    right or middle button.

    The rules every add-on's menu follows (README-Technical → Mini-map Menu):
      - Every feature on the options' main page gets a label here, and its flyout
        starts with the feature's Enable switch. Its settings follow, hidden while
        the feature is off, as the options hide them.
      - A switch's tooltip is its option's tooltip, so the menu adds nothing new
        to translate.
      - A pick from a set (an ability) closes the menu; a switch leaves it open.
      - Free Placement Mode and Come & Get It stay on the options page only, to
        keep the menu to what's changed mid-session.
]]

local HOVER_CLOSE_DELAY = 0.4
local CLICK_CLOSE_DELAY = 1.0
local MENU_GAP = 2 -- From the launcher's corner to the menu's

local menu = Kit.CreatePanel(ADDON_NAME .. "Menu", UIParent)
local flyout = Kit.CreatePanel(nil, menu)
flyout:SetFrameLevel(menu:GetFrameLevel() + 20)

-- Escape closes it, as it does any game menu.
table.insert(UISpecialFrames, menu:GetName())

Kit.SetToggleText(L["MENU_ON"], L["MENU_OFF"])

local state = {
	anchor = nil,
	flyoutKey = nil,
	closeDelay = HOVER_CLOSE_DELAY,
	idle = 0,
	openLeft = true,
	openDown = true,
}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function SpellText(spellId, name)
	return string.format("|T%s:0|t %s", C_Spell.GetSpellTexture(spellId) or ns.ICON_DEFAULT, name)
end

-- An option's caption and tooltip, drawn the way the options panel draws them.
local function OptionTooltip(name, desc)
	return function(tooltip)
		tooltip:SetText(name, 1, 0.82, 0, 1, true)
		if desc and desc ~= "" then
			tooltip:AddLine(desc, 1, 1, 1, true)
		end
	end
end

-- An open options page redraws with the new value, and so does the menu.
local function AfterChange()
	if ns.RefreshOptionsPanels then
		ns.RefreshOptionsPanels()
	end
	ns.RefreshMenu()
end

-- A pick from a set closes the menu, and an open options page redraws.
local function AfterPick()
	ns.HideMenu()
	if ns.RefreshOptionsPanels then
		ns.RefreshOptionsPanels()
	end
end

-- Every tracking ability this character knows, by name. Cat Form tracking only in Cat Form unless asked.
local function KnownAbilities(includeCatFormOnly)
	local isCat = ns.GetPlayerStates()
	local list = {}
	for _, id in ipairs(ns.TRACKING_IDS) do
		local name = C_Spell.GetSpellName(id)
		if name and IsPlayerSpell(id) and (includeCatFormOnly or not ns.CAT_FORM_ONLY[id] or isCat) then
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

-- A switch bound to one saved field.
local function Toggle(store, field, name, desc, onChange)
	return {
		kind = "toggle",
		left = name,
		on = store[field] and true or false,
		tooltip = OptionTooltip(name, desc),
		onClick = function()
			store[field] = not store[field]
			if onChange then
				onChange(store[field])
			end
			AfterChange()
		end,
	}
end

local function Section(text)
	return { kind = "section", left = text }
end

local function Separator()
	return { kind = "separator" }
end

-- The right side of a feature's label: On in green, Off in gray.
local function OnOff(enabled)
	if enabled then
		return L["MENU_ON"], "ON"
	end
	return L["MENU_OFF"], "MUTED"
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
	AfterPick()
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
    The switch, then the abilities to pick from, the pick white with a check and
    the rest gray. The pick is chosen even with Persistent Tracking off, so the
    list never hides; the three overrides only mean anything while it's on, as on
    the options page.
]]
function FLYOUTS.persistent()
	local profile = ns.db.profile
	local entries = {
		Toggle(profile, "persistentTracking", L["PERSISTENT_TRACKING"], L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"]),
	}

	local abilities = KnownAbilities(false)
	if #abilities > 0 then
		entries[#entries + 1] = Section(L["PERSISTENT_ABILITY"])
		for _, data in ipairs(abilities) do
			entries[#entries + 1] = {
				kind = "choice",
				left = SpellText(data.id, data.name),
				selected = profile.selectedSpellId == data.id,
				tooltip = SpellTooltip(data.id),
				onClick = function()
					PickPersistent(data.id)
				end,
			}
		end
	end
	if profile.selectedSpellId then
		entries[#entries + 1] = {
			kind = "action",
			left = L["CLEAR_TRACKING"],
			leftColor = "INFO",
			onClick = function()
				ns.ClearTracking()
				AfterChange()
			end,
		}
	end

	if profile.persistentTracking then
		entries[#entries + 1] = Separator()
		if ns.SPELLS.FISH then
			entries[#entries + 1] = Toggle(
				profile,
				"fishingPoleFish",
				L["OPTIONS_FISHING_POLE_FISH_NAMED"]:format(
					ns.GetSpellNameText(ns.SPELLS.FISH),
					ns.GetFishingPoleName()
				),
				L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"],
				OnPersistentOverride
			)
		end
		entries[#entries + 1] = Toggle(
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
		entries[#entries + 1] = Toggle(
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
    The switch, then while Farm Mode is on: where it stands and why, the abilities
    to cycle, the conditions, and the two extras. Farm Mode Abilities lists what
    this character knows, as the old Tracking Menu did; the options page lists
    every ability for shared profiles. Cycle Speed stays on the options page:
    seventeen choices are a dropdown, not a menu.
]]
function FLYOUTS.farm()
	local profile = ns.db.profile
	local global = ns.db.global
	local entries = {
		Toggle(profile, "farmMode", L["FARM_MODE"], L["OPTIONS_ENABLE_FARM_DESCRIPTION"]),
	}
	if not profile.farmMode then
		return entries
	end

	-- Gray for paused, the house three-way: Off gray, paused gray, Active green.
	local reason, reasonState = ns.GetFarmPauseReason(true)
	entries[#entries + 1] = {
		kind = "status",
		left = L["FARM_STATUS"],
		right = reason and L["FARM_STATUS_PAUSED"] or L["FARM_STATUS_ACTIVE"],
		rightColor = reason and "MUTED" or "ON",
	}
	if reason then
		entries[#entries + 1] = { kind = "note", left = ns.FormatFarmPauseReason(reason, reasonState) }
	end

	local cycleSpells = profile.farmCycleSpells or {}
	entries[#entries + 1] = Section(L["OPTIONS_FARM_ABILITIES"])
	entries[#entries + 1] = Toggle(
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
				AfterChange()
			end,
		}
	end

	entries[#entries + 1] = Section(L["OPTIONS_FARM_CONDITIONS"])
	local function Condition(field, name, desc, movementState)
		if movementState == nil or ns.IsMovementStateDetectable(movementState) then
			entries[#entries + 1] = Toggle(profile, field, name, desc, ns.InvalidatePlayerStates)
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

	entries[#entries + 1] = Separator()
	entries[#entries + 1] = Toggle(
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
		Toggle(global, "farmZoomOut", L["OPTIONS_ZOOM_MINIMAP_OUT"], L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"])
	return entries
end

-- Just the switch: switching it off ends any hunt.
function FLYOUTS.targetTracking()
	local profile = ns.db.profile
	local entry =
		Toggle(profile, "targetTracking", L["TARGET_TRACKING"], L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"])
	entry.onClick = function()
		ns.SetTargetTracking(not profile.targetTracking)
		AfterChange()
	end
	return { entry }
end

--------------------------------------------------------------------------------
-- Main Menu
--------------------------------------------------------------------------------

-- A feature's label: where it stands on the right, its flyout under the cursor or a click.
local function Feature(key, title, right, rightColor)
	return {
		kind = "submenu",
		submenu = key,
		left = title,
		right = right,
		rightColor = rightColor,
		onClick = function()
			ns.OpenFlyout(key)
		end,
	}
end

local function BuildMainEntries()
	local profile = ns.db.profile
	local entries = {
		{ kind = "header", left = L["ADDON_TITLE"], right = ns.Version or "" },
		{ kind = "spacer" },
	}

	-- Persistent Tracking shows its pick while it's on, or None Set.
	local right, rightColor = OnOff(false)
	if profile.persistentTracking then
		local spellId = profile.selectedSpellId
		if spellId then
			right, rightColor = SpellText(spellId, ns.GetSpellNameText(spellId)), "TEXT"
		else
			right, rightColor = L["NONE_SET"], "MUTED"
		end
	end
	entries[#entries + 1] = Feature("persistent", L["PERSISTENT_TRACKING"], right, rightColor)

	-- Farm Mode: Active in green, Paused or Off in gray.
	right, rightColor = OnOff(false)
	if profile.farmMode then
		if ns.GetFarmPauseReason(true) then
			right, rightColor = L["FARM_STATUS_PAUSED"], "MUTED"
		else
			right, rightColor = L["FARM_STATUS_ACTIVE"], "ON"
		end
	end
	entries[#entries + 1] = Feature("farm", L["FARM_MODE"], right, rightColor)

	entries[#entries + 1] = Feature("targetTracking", L["TARGET_TRACKING"], OnOff(profile.targetTracking))

	entries[#entries + 1] = Separator()
	entries[#entries + 1] = {
		kind = "hint",
		left = L["TOOLTIP_OPTIONS"],
		right = L["OPEN"],
		onClick = function()
			ns.HideMenu()
			ns:OpenOptionsPanel()
		end,
	}
	return entries
end

--------------------------------------------------------------------------------
-- Drawing & Placement
--------------------------------------------------------------------------------

--[[
    The flyout beside its label, its first row level with the label, on the side
    the menu opened toward. The label keeps its highlight while it's open.
]]
local function PositionFlyout(row)
	flyout:ClearAllPoints()
	if state.openLeft then
		flyout:SetPoint("TOPRIGHT", row, "TOPLEFT", -Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	else
		flyout:SetPoint("TOPLEFT", row, "TOPRIGHT", Kit.FLYOUT_GAP, Kit.FLYOUT_RISE)
	end
end

local function RenderFlyout()
	local key = state.flyoutKey
	local row = key and menu:SubmenuRow(key)
	local builder = key and FLYOUTS[key]
	if not (row and builder) then
		state.flyoutKey = nil
		flyout:Hide()
		return
	end
	flyout.tooltipAnchor = menu.tooltipAnchor
	flyout:Render(builder())
	PositionFlyout(row)
	flyout:Show()
	row:LockHighlight()
end

local function Render()
	if not menu:IsShown() or not ns.db then
		return
	end
	menu:Render(BuildMainEntries())
	RenderFlyout()
end

function ns.OpenFlyout(key)
	if key ~= state.flyoutKey then
		state.flyoutKey = key
		Render()
	end
end

-- Entering a label opens its flyout, and any other row closes it, the way any game submenu behaves.
menu.onEnterRow = function(_, entry)
	ns.OpenFlyout(entry and entry.submenu or nil)
end

-- Opens away from the screen edges: left of the launcher on the right half of the screen, below it on the top half.
local function PositionMenu(anchor)
	local x, y = anchor:GetCenter()
	local scale = anchor:GetEffectiveScale() / UIParent:GetEffectiveScale()
	state.openLeft = (x or 0) * scale > UIParent:GetWidth() / 2
	state.openDown = (y or 0) * scale > UIParent:GetHeight() / 2

	local point = (state.openDown and "TOP" or "BOTTOM") .. (state.openLeft and "RIGHT" or "LEFT")
	local relative = (state.openDown and "BOTTOM" or "TOP") .. (state.openLeft and "LEFT" or "RIGHT")
	menu:ClearAllPoints()
	menu:SetPoint(
		point,
		anchor,
		relative,
		state.openLeft and -MENU_GAP or MENU_GAP,
		state.openDown and -MENU_GAP or MENU_GAP
	)
	menu.tooltipAnchor = state.openLeft and "ANCHOR_LEFT" or "ANCHOR_RIGHT"
end

-- Closes a moment after the cursor has left the launcher, the menu, and the flyout.
menu:SetScript("OnUpdate", function(self, elapsed)
	local anchor = state.anchor
	if not anchor or not anchor:IsVisible() then
		self:Hide()
		return
	end
	if Kit.IsCursorOver(anchor) or Kit.IsCursorOver(self) or Kit.IsCursorOver(flyout) then
		state.idle = 0
		return
	end
	state.idle = state.idle + elapsed
	if state.idle >= state.closeDelay then
		self:Hide()
	end
end)

menu:SetScript("OnHide", function(self)
	state.flyoutKey = nil
	state.anchor = nil
	flyout:Hide()
	if ns.IsMenuFrame(GameTooltip:GetOwner()) then
		GameTooltip:Hide()
	end
end)

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

--[[
    Opens the menu from a launcher. how is "hover" or "click"; a click keeps it
    open a little longer once the cursor leaves. flyoutKey opens that label's
    flyout at once. A launcher already showing the menu keeps its place and its
    open flyout.
]]
function ns.ShowMenu(anchor, flyoutKey, how)
	if not ns.db or not anchor then
		return
	end
	local reopen = menu:IsShown() and state.anchor == anchor
	if not reopen then
		state.closeDelay = HOVER_CLOSE_DELAY
		state.flyoutKey = nil
	end
	state.anchor = anchor
	state.idle = 0
	if how == "click" then
		state.closeDelay = CLICK_CLOSE_DELAY
	end
	if flyoutKey then
		state.flyoutKey = flyoutKey
	end
	if not reopen then
		PositionMenu(anchor)
	end
	menu:Show()
	Render()
end

function ns.HideMenu()
	menu:Hide()
end

-- Redraws the menu in place while it is open; a no-op otherwise.
function ns.RefreshMenu()
	Render()
end

function ns.IsMenuShown()
	return menu:IsShown()
end

-- True for the menu, its flyout, and anything inside them; the pause check uses it to recognize our own tooltips.
function ns.IsMenuFrame(frame)
	return frame ~= nil and Kit.IsInside(frame, menu)
end

--------------------------------------------------------------------------------
-- Blizzard Tracking Button Hook
--------------------------------------------------------------------------------

--[[
    Optional take-over of Classic Era's mini-map tracking icon, which has no menu
    of its own: a right-click there cancels tracking, and the take-over replaces
    that with this menu, its Persistent Tracking flyout out. On TBC Anniversary
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
			ns.ShowMenu(button, "persistent", "click")
		end)
	elseif not enabled and blizzardHooked then
		button:SetScript("OnMouseUp", blizzardSavedHandler)
		blizzardHooked = false
		blizzardSavedHandler = nil
	end
end
