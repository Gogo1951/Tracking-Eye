local _, ns = ...

local L = ns.L
local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. One row per API Tracking Eye actually calls or guards, wherever it
    lives -- nothing incidental, and nothing the add-on does not use.

    Every modern/legacy pair the add-on still picks between is listed as both
    halves: the tracking reads README-Notes keeps (GetTrackingTexture,
    CancelTrackingBuff and Blizzard's tracking icon, or the C_Minimap tracking
    list), the tooltip-text read (C_TooltipInfo, or the hidden scan tooltip),
    the mini-map zoom buttons, and the Set Key routes. A FAIL on one half is the
    report working rather than a defect: the pair is what tells a bug report
    which branch that client actually took. Never drop the half that fails on
    the client in front of you -- that is the half carrying the answer.
    Validate Data appends a row per reader it calls, and its spell-name and
    spell-known reads.
]]
ns.DIAGNOSTIC_API_CHECKS = {
	-- { label, testFunction }
	{
		"C_AddOns.GetAddOnMetadata",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function"
		end,
	},
	-- Data/Flavor.lua asks it on Vanilla only.
	{
		"C_Seasons.GetActiveSeason",
		function()
			return type(C_Seasons) == "table" and type(C_Seasons.GetActiveSeason) == "function"
		end,
	},
	{
		"Enum.SeasonID.SeasonOfDiscovery",
		function()
			return type(Enum) == "table" and type(Enum.SeasonID) == "table" and Enum.SeasonID.SeasonOfDiscovery ~= nil
		end,
	},
	{
		"C_Minimap.GetNumTrackingTypes",
		function()
			return type(C_Minimap) == "table" and type(C_Minimap.GetNumTrackingTypes) == "function"
		end,
	},
	{
		"C_Minimap.GetTrackingInfo",
		function()
			return type(C_Minimap) == "table" and type(C_Minimap.GetTrackingInfo) == "function"
		end,
	},
	{
		"C_Minimap.SetTracking",
		function()
			return type(C_Minimap) == "table" and type(C_Minimap.SetTracking) == "function"
		end,
	},
	{
		"CastSpellByID",
		function()
			return type(CastSpellByID) == "function"
		end,
	},
	{
		"IsPlayerSpell",
		function()
			return type(IsPlayerSpell) == "function"
		end,
	},
	{
		"C_Spell.GetSpellName",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellName) == "function"
		end,
	},
	{
		"C_Spell.GetSpellTexture",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellTexture) == "function"
		end,
	},
	{
		"C_Spell.GetSpellCooldown",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellCooldown) == "function"
		end,
	},
	-- Validate Data's own reads, then the tooltip-text pair ns.GetTooltipLines needs, or the hidden scan tooltip where either is missing.
	{
		"C_Spell.IsSpellDataCached",
		function()
			return type(C_Spell) == "table" and type(C_Spell.IsSpellDataCached) == "function"
		end,
	},
	{
		"C_Spell.RequestLoadSpellData",
		function()
			return type(C_Spell) == "table" and type(C_Spell.RequestLoadSpellData) == "function"
		end,
	},
	{
		"C_Spell.GetSpellDescription",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellDescription) == "function"
		end,
	},
	{
		"C_TooltipInfo.GetSpellByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetSpellByID) == "function"
		end,
	},
	{
		"C_TooltipInfo.GetItemByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetItemByID) == "function"
		end,
	},
	-- Probed through the GameTooltip methods the scan tooltip inherits, so the check creates nothing.
	{
		"Hidden scan tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetHyperlink) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
	{
		"C_UnitAuras.GetBuffDataByIndex",
		function()
			return type(C_UnitAuras) == "table" and type(C_UnitAuras.GetBuffDataByIndex) == "function"
		end,
	},
	{
		"C_Secrets.ShouldAurasBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldAurasBeSecret) == "function"
		end,
	},
	{
		"C_Secrets.ShouldCooldownsBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldCooldownsBeSecret) == "function"
		end,
	},
	{
		"C_Secrets.ShouldUnitSpellCastingBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldUnitSpellCastingBeSecret) == "function"
		end,
	},
	{
		"C_Secrets.ShouldUnitIdentityBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldUnitIdentityBeSecret) == "function"
		end,
	},
	{
		"C_Secrets.ShouldUnitStatsBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldUnitStatsBeSecret) == "function"
		end,
	},
	{
		"UnitCastingInfo",
		function()
			return type(UnitCastingInfo) == "function"
		end,
	},
	{
		"UnitChannelInfo",
		function()
			return type(UnitChannelInfo) == "function"
		end,
	},
	{
		"IsStealthed",
		function()
			return type(IsStealthed) == "function"
		end,
	},
	{
		"IsMounted",
		function()
			return type(IsMounted) == "function"
		end,
	},
	{
		"GetUnitSpeed",
		function()
			return type(GetUnitSpeed) == "function"
		end,
	},
	{
		"GetInventoryItemID",
		function()
			return type(GetInventoryItemID) == "function"
		end,
	},
	{
		"C_Item.GetItemInfoInstant",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function"
		end,
	},
	-- ns.IsFishingPoleEquipped compares the main hand's class and subclass against these.
	{
		"Enum.ItemWeaponSubclass.Fishingpole",
		function()
			return type(Enum) == "table"
				and type(Enum.ItemClass) == "table"
				and Enum.ItemClass.Weapon ~= nil
				and type(Enum.ItemWeaponSubclass) == "table"
				and Enum.ItemWeaponSubclass.Fishingpole ~= nil
		end,
	},
	{
		"UnitOnTaxi",
		function()
			return type(UnitOnTaxi) == "function"
		end,
	},
	{
		"UnitAffectingCombat",
		function()
			return type(UnitAffectingCombat) == "function"
		end,
	},
	{
		"UnitIsDeadOrGhost",
		function()
			return type(UnitIsDeadOrGhost) == "function"
		end,
	},
	-- ns.HasAttackableTarget's reads.
	{
		"UnitExists",
		function()
			return type(UnitExists) == "function"
		end,
	},
	{
		"UnitCanAttack",
		function()
			return type(UnitCanAttack) == "function"
		end,
	},
	{
		"UnitIsDead",
		function()
			return type(UnitIsDead) == "function"
		end,
	},
	-- Target Tracking never hunts from an enemy player.
	{
		"UnitIsPlayer",
		function()
			return type(UnitIsPlayer) == "function"
		end,
	},
	{
		"IsInInstance",
		function()
			return type(IsInInstance) == "function"
		end,
	},
	{
		"GetInstanceInfo",
		function()
			return type(GetInstanceInfo) == "function"
		end,
	},
	{
		"IsResting",
		function()
			return type(IsResting) == "function"
		end,
	},
	{
		"InCombatLockdown",
		function()
			return type(InCombatLockdown) == "function"
		end,
	},
	{
		"UnitCreatureType",
		function()
			return type(UnitCreatureType) == "function"
		end,
	},
	{
		"GetCursorInfo",
		function()
			return type(GetCursorInfo) == "function"
		end,
	},
	{
		"IsShiftKeyDown",
		function()
			return type(IsShiftKeyDown) == "function"
		end,
	},
	{
		"GetCVar",
		function()
			return type(GetCVar) == "function"
		end,
	},
	{
		"SetCVar",
		function()
			return type(SetCVar) == "function"
		end,
	},
	{
		"C_Timer.After",
		function()
			return type(C_Timer) == "table" and type(C_Timer.After) == "function"
		end,
	},
	{
		"C_Timer.NewTicker",
		function()
			return type(C_Timer) == "table" and type(C_Timer.NewTicker) == "function"
		end,
	},
	{
		"C_AddOns.GetAddOnInfo",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnInfo) == "function"
		end,
	},
	{
		"C_AddOns.GetNumAddOns",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetNumAddOns) == "function"
		end,
	},
	-- Farm Mode's window sweep and mini-map zoom.
	{
		"UIPanelWindows",
		function()
			return type(UIPanelWindows) == "table"
		end,
	},
	{
		"Minimap.GetZoom",
		function()
			return type(Minimap) == "table" and type(Minimap.GetZoom) == "function"
		end,
	},
	{
		"Minimap.SetZoom",
		function()
			return type(Minimap) == "table" and type(Minimap.SetZoom) == "function"
		end,
	},
	{
		"Minimap.ZoomIn or MinimapZoomIn",
		function()
			return type(Minimap) == "table" and type(Minimap.ZoomIn or MinimapZoomIn) == "table"
		end,
	},
	{
		"Minimap.ZoomOut or MinimapZoomOut",
		function()
			return type(Minimap) == "table" and type(Minimap.ZoomOut or MinimapZoomOut) == "table"
		end,
	},
	-- Come & Get It's detect, compose, and write steps.
	{
		"GetGameMessageInfo",
		function()
			return type(GetGameMessageInfo) == "function"
		end,
	},
	{
		"C_Map.GetBestMapForUnit",
		function()
			return type(C_Map) == "table" and type(C_Map.GetBestMapForUnit) == "function"
		end,
	},
	{
		"C_Map.GetPlayerMapPosition",
		function()
			return type(C_Map) == "table" and type(C_Map.GetPlayerMapPosition) == "function"
		end,
	},
	{
		"C_Map.GetMapInfo",
		function()
			return type(C_Map) == "table" and type(C_Map.GetMapInfo) == "function"
		end,
	},
	{
		"GameTooltip.GetItem",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.GetItem) == "function"
		end,
	},
	{
		"GameTooltip.IsShown",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.IsShown) == "function"
		end,
	},
	-- Farm Mode's tooltip hold tells our own tooltip from everyone else's by its owner.
	{
		"GameTooltip.GetOwner",
		function()
			return type(GameTooltip) == "table" and type(GameTooltip.GetOwner) == "function"
		end,
	},
	{
		"GameTooltipTextLeft1",
		function()
			return type(GameTooltipTextLeft1) == "table"
		end,
	},
	{
		"ChatFrameUtil.OpenChat",
		function()
			return type(ChatFrameUtil) == "table" and type(ChatFrameUtil.OpenChat) == "function"
		end,
	},
	{
		"ChatFrameUtil.GetActiveWindow",
		function()
			return type(ChatFrameUtil) == "table" and type(ChatFrameUtil.GetActiveWindow) == "function"
		end,
	},
	{
		"GetTrackingTexture (legacy)",
		function()
			return type(GetTrackingTexture) == "function"
		end,
	},
	{
		"CancelTrackingBuff (legacy)",
		function()
			return type(CancelTrackingBuff) == "function"
		end,
	},
	{
		"Settings.OpenToCategory",
		function()
			return type(Settings) == "table" and type(Settings.OpenToCategory) == "function"
		end,
	},
	{
		"C_EventUtils.IsEventValid",
		function()
			return type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
		end,
	},
	{
		"MiniMapTrackingIcon (frame)",
		function()
			return type(MiniMapTrackingIcon) == "table"
		end,
	},
	--[[
	    The icon ns.ApplyBlizzardTrackingHook takes over, and the dropdown button
	    whose presence (TBC Anniversary, MoP Classic) means it leaves the icon alone.
	]]
	{
		"MiniMapTracking (frame)",
		function()
			return type(MiniMapTracking) == "table"
		end,
	},
	{
		"MiniMapTrackingButton (frame)",
		function()
			return type(MiniMapTrackingButton) == "table"
		end,
	},
	--[[
	    The three routes ns:OpenKeyBindings tries for the Set Key button, in its
	    order, each with what it needs: the category id; the Settings panel's
	    category list and its GetAllCategories; the legacy KeyBindingFrame and
	    ShowUIPanel. One route passing whole is enough; the report says which one
	    this client has.
	]]
	{
		"Settings.KEYBINDINGS_CATEGORY_ID",
		function()
			return type(Settings) == "table" and Settings.KEYBINDINGS_CATEGORY_ID ~= nil
		end,
	},
	{
		"SettingsPanel.GetCategoryList",
		function()
			return type(SettingsPanel) == "table" and type(SettingsPanel.GetCategoryList) == "function"
		end,
	},
	{
		"SettingsPanel category list GetAllCategories",
		function()
			if not (type(SettingsPanel) == "table" and type(SettingsPanel.GetCategoryList) == "function") then
				return false
			end
			local ok, list = pcall(SettingsPanel.GetCategoryList, SettingsPanel)
			return ok and type(list) == "table" and type(list.GetAllCategories) == "function"
		end,
	},
	{
		"KeyBindingFrame_LoadUI (legacy)",
		function()
			return type(KeyBindingFrame_LoadUI) == "function" or type(KeyBindingFrame) == "table"
		end,
	},
	{
		"ShowUIPanel (legacy)",
		function()
			return type(ShowUIPanel) == "function"
		end,
	},
	{
		"GetBindingKey",
		function()
			return type(GetBindingKey) == "function"
		end,
	},
	{
		"GetBindingText (guarded)",
		function()
			return type(GetBindingText) == "function"
		end,
	},
	-- The Fishing Pole name in the Persistent Tracking option (ns.GetFishingPoleName).
	{
		"C_Item.GetItemSubClassInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSubClassInfo) == "function"
		end,
	},
}

--------------------------------------------------------------------------------
-- Context Probes
--------------------------------------------------------------------------------

--[[
    The probes read feature state through the accessors the features themselves
    call (ns.GetPersistentSpell, ns.GetPlayerStates, ns.GetFarmPauseReason and
    the like), so a report shows the exact values the features act on rather
    than a copy of their logic. Every read that can go secret on WoW Forever
    goes through the feature's own C_Secrets-guarded accessor, never raw.
]]

-- The add-on's own example reports, appended to the shared Event Log intro.
ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES =
	"Best for 'Farm Mode doesn't cycle', 'my tracking didn't come back' or 'Come & Get It did nothing' reports."

local function OnOff(value)
	return value and "on" or "off"
end

--[[
    A spell id as id, name and whether this character knows it. A nil name
    means the spell is not in THIS client's database at all, which is a
    different thing from the player not having learned it.
]]
local function SpellLabel(spellId)
	if not spellId then
		return "none"
	end
	local name = C_Spell.GetSpellName(spellId)
	if not name then
		return string.format("%s (not on this client)", tostring(spellId))
	end
	return string.format("%d %s [%s]", spellId, name, IsPlayerSpell(spellId) and "known" or "not known")
end

-- Every check ns.CanCast makes, each with its live value, so a refused automatic cast names its cause.
local function AddCanCastLine(lines, indent)
	lines[#lines + 1] = string.format(
		indent .. "CanCast: %s // deadOrGhost=%s stealthed=%s casting=%s combat=%s lootWindowOpen=%s cursor=%s",
		tostring(ns.CanCast()),
		tostring(UnitIsDeadOrGhost("player")),
		tostring(IsStealthed()),
		tostring(ns.IsPlayerCasting()),
		tostring(UnitAffectingCombat("player")),
		tostring(ns.state.lootWindowOpen),
		tostring((GetCursorInfo()))
	)
end

-- Which of WoW Forever's restrictions are in force; a secret read is answered by its guard, not the game.
local function AddSecretsLine(lines, indent)
	lines[#lines + 1] = string.format(
		indent .. "Secret now: auras=%s cooldowns=%s casting=%s targetIdentity=%s stats=%s",
		tostring(C_Secrets.ShouldAurasBeSecret()),
		tostring(C_Secrets.ShouldCooldownsBeSecret()),
		tostring(C_Secrets.ShouldUnitSpellCastingBeSecret("player")),
		tostring(C_Secrets.ShouldUnitIdentityBeSecret("target")),
		tostring(C_Secrets.ShouldUnitStatsBeSecret())
	)
end

local function SecondsSince(time)
	return string.format("%.1fs", GetTime() - (time or 0))
end

--------------------------------------------------------------------------------
-- Player & Spell Context
--------------------------------------------------------------------------------

-- Every tracking spell the add-on gates on with IsPlayerSpell.
ns.DIAGNOSTIC_SPELLS = ns.TRACKING_IDS

--[[
    Most "nothing shows up" reports are "the player doesn't know the spell" or
    "the API returned nil." This prints the character and profile, every
    tracking spell this client's data holds with whether it's known (a
    character that knows none gets no mini-map button or free-placement icon at
    all), and every surface the add-on reads to learn what's tracked: Blizzard's
    tracking icon, the legacy mirror, and the C_Minimap list, beside the
    add-on's own bookkeeping. On Classic Era 1.15.x the mirror can lag the real
    tracking state by minutes; a mismatch against lastCastSpell is how that
    shows up. Read-only.
]]
function ns:BuildPlayerContextReport()
	local lines = { GetClientHeader(), "" }
	local _, class = UnitClass("player")
	lines[#lines + 1] = string.format("Player: %s level %d", tostring(class), UnitLevel("player") or 0)
	lines[#lines + 1] = "Profile: " .. tostring(ns.db and ns.db:GetCurrentProfile())
	lines[#lines + 1] = string.format("Knows a tracking ability: %s", tostring(ns.HasTrackingAbility()))
	lines[#lines + 1] = ""

	lines[#lines + 1] = "Tracking spells:"
	for _, spellId in ipairs(ns.DIAGNOSTIC_SPELLS or {}) do
		local suffix = ns.CAT_FORM_ONLY[spellId] and " (Cat Form only)" or ""
		lines[#lines + 1] = "  " .. SpellLabel(spellId) .. suffix
	end
	lines[#lines + 1] = ""

	lines[#lines + 1] =
		string.format("Active tracking spell (as the add-on reads it): %s", SpellLabel(ns.GetActiveTrackingSpell()))
	if MiniMapTrackingIcon then
		lines[#lines + 1] = string.format(
			"MiniMapTrackingIcon: visible=%s texture=%s",
			tostring(MiniMapTrackingIcon:IsVisible()),
			tostring(MiniMapTrackingIcon:GetTexture())
		)
	else
		lines[#lines + 1] = "MiniMapTrackingIcon: (none on this client)"
	end
	lines[#lines + 1] =
		string.format("GetTrackingTexture: %s", GetTrackingTexture and tostring(GetTrackingTexture()) or "n/a")
	lines[#lines + 1] = string.format(
		"lastCastSpell: %s // mirrorConfirmedCast: %s // last cast attempt: %s ago // icon: %s",
		tostring(ns.state.lastCastSpell),
		tostring(ns.state.mirrorConfirmedCast),
		SecondsSince(ns.state.lastTrackingCastAt),
		tostring(ns.state.currentIcon)
	)

	--[[
	    Every C_Minimap tracking entry, active or not. On WoW Forever this list is
	    the only tracking surface, and the raw rows show which entries are spells,
	    which are town services, and how many can be active at once.
	]]
	lines[#lines + 1] = "C_Minimap tracking entries:"
	local trackingRows = 0
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local info = C_Minimap.GetTrackingInfo(index)
		if info then
			trackingRows = trackingRows + 1
			lines[#lines + 1] = string.format(
				"  %d %s [%s] type=%s subType=%s spellID=%s",
				index,
				tostring(info.name),
				info.active and "active" or "off",
				tostring(info.type),
				tostring(info.subType),
				tostring(info.spellID)
			)
		end
	end
	if trackingRows == 0 then
		lines[#lines + 1] = "  (none)"
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Persistent Tracking Context
--------------------------------------------------------------------------------

--[[
    Answers "my tracking didn't come back" and "Target Tracking does nothing":
    the ability ns.GetPersistentSpell resolves to and each override it tried
    first, then every check TryRecastPersistent and the post-resurrection recast
    make before casting, in their order, then Target Tracking's gates on the
    current target. Read-only.
]]
function ns:BuildPersistentContextReport()
	local lines = { GetClientHeader(), "" }
	local db = (ns.db and ns.db.profile) or {}
	local isCat, isFarming, movementState = ns.GetPlayerStates()
	local _, instanceType = IsInInstance()

	lines[#lines + 1] = string.format(
		"persistentTracking: %s // picked: %s",
		OnOff(db.persistentTracking),
		SpellLabel(db.selectedSpellId)
	)
	lines[#lines + 1] = "Overrides, first match wins:"
	lines[#lines + 1] = string.format(
		"  battlegroundHumanoids=%s // Track Humanoids: %s // instance type: %s",
		OnOff(db.battlegroundHumanoids),
		SpellLabel(ns.SPELLS.HUMANOIDS),
		tostring(instanceType)
	)
	lines[#lines + 1] = string.format(
		"  catFormHumanoids=%s // Druid Track Humanoids: %s // in Cat Form: %s",
		OnOff(db.catFormHumanoids),
		SpellLabel(ns.SPELLS.DRUID_HUMANOIDS),
		tostring(isCat)
	)
	lines[#lines + 1] = string.format(
		"  fishingPoleFish=%s // Find Fish: %s // fishing pole in the main hand: %s",
		OnOff(db.fishingPoleFish),
		SpellLabel(ns.SPELLS.FISH),
		tostring(ns.IsFishingPoleEquipped())
	)
	lines[#lines + 1] = string.format(
		"  Target Tracking hunt: %s // out in the world: %s",
		SpellLabel(ns.state.huntSpellId),
		tostring(ns.IsOutInTheWorld())
	)
	local spellId = ns.GetPersistentSpell()
	lines[#lines + 1] = "Resolves to: " .. SpellLabel(spellId)
	lines[#lines + 1] = ""

	lines[#lines + 1] = "Recast checks, in the order the recast makes them:"
	lines[#lines + 1] = string.format(
		"  Farm Mode cycling instead: %s (movement state: %s)",
		tostring(isFarming),
		tostring(movementState)
	)
	lines[#lines + 1] = string.format(
		"  Cat Form only, outside Cat Form: %s",
		tostring(spellId ~= nil and ns.CAT_FORM_ONLY[spellId] == true and not isCat)
	)
	lines[#lines + 1] = string.format(
		"  since entering the world: %s (the recast waits out a short login grace first)",
		SecondsSince(ns.state.enteredWorldAt)
	)
	lines[#lines + 1] =
		string.format("  already active: %s", tostring(spellId ~= nil and ns.GetActiveTrackingSpell() == spellId))
	lines[#lines + 1] = string.format(
		"  last cast: %s, attempted %s ago (in flight for %ds)",
		tostring(ns.state.lastCastSpell),
		SecondsSince(ns.state.lastTrackingCastAt),
		ns.CAST_IN_FLIGHT_SECONDS
	)
	lines[#lines + 1] = string.format("  moving: %s (a recast waits until you move)", tostring(ns.IsPlayerMoving()))
	AddCanCastLine(lines, "  ")
	if spellId then
		local start, duration = ns.GetSpellCooldown(spellId)
		lines[#lines + 1] = string.format(
			"  cooldown: start=%s duration=%s (nil while cooldowns are secret)",
			tostring(start),
			tostring(duration)
		)
	end
	AddSecretsLine(lines, "  ")
	lines[#lines + 1] = ""

	-- Target Tracking: what ns.OnPlayerTargetChanged reads, in its order.
	lines[#lines + 1] = string.format(
		"targetTracking: %s // out in the world: %s // in combat: %s",
		OnOff(db.targetTracking),
		tostring(ns.IsOutInTheWorld()),
		tostring(UnitAffectingCombat("player"))
	)
	local targetType = "(no target)"
	local creatureTypeId
	if UnitExists("target") then
		local creatureTypeName
		creatureTypeName, creatureTypeId = ns.GetUnitCreatureType("target")
		targetType = string.format("%s (ID %s)", tostring(creatureTypeName), tostring(creatureTypeId))
	end
	lines[#lines + 1] = string.format(
		"target: attackable=%s player=%s // creature type: %s // resolves to: %s",
		tostring(ns.HasAttackableTarget()),
		tostring(UnitIsPlayer("target")),
		targetType,
		SpellLabel(ns.GetCreatureTypeSpell(creatureTypeId))
	)
	local knownCreatureTrackers, creatureTypes = 0, 0
	for candidateTypeId in pairs(ns.CREATURE_TYPE_SPELLS) do
		creatureTypes = creatureTypes + 1
		if ns.GetCreatureTypeSpell(candidateTypeId) then
			knownCreatureTrackers = knownCreatureTrackers + 1
		end
	end
	lines[#lines + 1] =
		string.format("creature types this character can track: %d of %d", knownCreatureTrackers, creatureTypes)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Farm Mode Context
--------------------------------------------------------------------------------

-- The UIPanelWindows on screen right now, by frame name: the windows ns.IsBlockingWindowOpen holds for.
local function OpenPanelWindows()
	local open = {}
	for name in pairs(UIPanelWindows or {}) do
		local frame = _G[name]
		if type(frame) == "table" and frame.IsShown and frame:IsShown() then
			open[#open + 1] = name
		end
	end
	table.sort(open)
	return #open > 0 and table.concat(open, ", ") or "none"
end

--[[
    Answers "Farm Mode doesn't cycle" and "the key does nothing": the master and
    per-state toggles with whether this class owns each state and this flavor
    can detect it, the live movement inputs and the state ns.GetPlayerStates
    makes of them, the pause reason, every hold RunFarmLogic checks in its
    order, each ticked ability and why it is or isn't in the cycle, and the
    cycle as Farm Mode casts it. Opening the options panel is itself a hold, so
    a report run from here always shows it. The pause reason is printed as its
    raw locale key, never the translated string: a report pasted from a zhTW
    client has to be readable here. Read-only.
]]
function ns:BuildFarmContextReport()
	local lines = { GetClientHeader(), "" }
	local db = (ns.db and ns.db.profile) or {}
	local global = (ns.db and ns.db.global) or {}

	lines[#lines + 1] = string.format(
		"farmMode: %s // interval: %ss // farmIncludePersistent: %s // muteCycleSound: %s (Sound_EnableSFX=%s)",
		OnOff(db.farmMode),
		tostring(db.farmInterval),
		OnOff(db.farmIncludePersistent),
		OnOff(db.muteCycleSound),
		tostring(GetCVar("Sound_EnableSFX"))
	)
	lines[#lines + 1] = "Movement states (toggle // your class // detectable here):"
	for _, state in ipairs({ "mounted", "travelForms", "cheetah", "pack", "ghostWolf", "foot" }) do
		local owner = ns.MOVEMENT_STATE_CLASS[state]
		lines[#lines + 1] = string.format(
			"  %s: %s // %s // %s",
			state,
			OnOff(db[ns.MOVEMENT_STATE_TOGGLES[state]]),
			owner and tostring(ns.IsPlayerClass(owner)) or "any class",
			tostring(ns.IsMovementStateDetectable(state))
		)
	end
	lines[#lines + 1] = ""

	-- Auras are locked for add-on code while secret (WoW Forever, in combat), so the buff columns say so instead of throwing.
	local hasTravelForm, hasCheetah, hasPack, hasGhostWolf = "secret", "secret", "secret", "secret"
	if not C_Secrets.ShouldAurasBeSecret() then
		hasTravelForm, hasCheetah, hasPack, hasGhostWolf = false, false, false, false
		for i = 1, 40 do
			local aura = C_UnitAuras.GetBuffDataByIndex("player", i)
			if not aura then
				break
			end
			local id = aura.spellId
			if id then
				if ns.FARM_FORMS[id] then
					hasTravelForm = true
				elseif ns.CHEETAH_BUFFS[id] then
					hasCheetah = true
				elseif ns.PACK_BUFFS[id] then
					hasPack = true
				elseif ns.GHOST_WOLF_BUFFS[id] then
					hasGhostWolf = true
				end
			end
		end
	end
	lines[#lines + 1] = string.format(
		"live: mounted=%s onTaxi=%s travelForm=%s cheetah=%s pack=%s ghostWolf=%s",
		tostring(IsMounted()),
		tostring(UnitOnTaxi("player")),
		tostring(hasTravelForm),
		tostring(hasCheetah),
		tostring(hasPack),
		tostring(hasGhostWolf)
	)
	local isCat, isFarming, movementState = ns.GetPlayerStates()
	lines[#lines + 1] = string.format(
		"GetPlayerStates -> isCat=%s isFarming=%s movementState=%s",
		tostring(isCat),
		tostring(isFarming),
		tostring(movementState)
	)
	lines[#lines + 1] = string.format(
		"pause reason (live): %s // cached: %s // state it names: %s",
		tostring(ns.GetFarmPauseReason()),
		tostring(ns.state.farmPauseReason),
		tostring(ns.state.farmPauseState)
	)
	lines[#lines + 1] = ""

	-- RunFarmLogic's holds, in its order.
	lines[#lines + 1] = "Holds, in the order the cycle checks them:"
	lines[#lines + 1] = string.format(
		"  options panel open: %s // window open: %s (%s)",
		tostring(ns.IsOptionsPanelOpen and ns.IsOptionsPanelOpen()),
		tostring(ns.IsBlockingWindowOpen()),
		OpenPanelWindows()
	)
	-- moving is the boolean, never the raw speed, which can be secret on WoW Forever.
	lines[#lines + 1] = string.format(
		"  attackable target: %s // other tooltip: %s // own tooltip: %s // moving: %s",
		tostring(ns.HasAttackableTarget()),
		tostring(ns.IsTooltipShowing()),
		tostring(ns.IsOwnTooltipShowing()),
		tostring(ns.IsPlayerMoving())
	)
	local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
	lines[#lines + 1] = string.format(
		"  form-leave restore pending: %s // restricted zone: %s (IsInInstance=%s instanceMapID=%s listed=%s IsResting=%s)",
		tostring(ns.state.wasFarming),
		tostring(ns.GetRestrictedKind()),
		tostring((IsInInstance())),
		tostring(instanceMapID),
		tostring(instanceMapID ~= nil and ns.RESTRICTED_MAP_IDS[instanceMapID] == true),
		tostring(IsResting())
	)
	AddCanCastLine(lines, "  ")
	AddSecretsLine(lines, "  ")
	lines[#lines + 1] = ""

	-- Each ticked ability, and why the cycle leaves out any it does.
	lines[#lines + 1] = "Ticked abilities:"
	local ticked = {}
	for id, enabled in pairs(db.farmCycleSpells or {}) do
		if enabled then
			ticked[#ticked + 1] = id
		end
	end
	table.sort(ticked)
	for _, id in ipairs(ticked) do
		local suffix = ""
		if ns.CAT_FORM_ONLY[id] then
			suffix = isCat and " (Cat Form only, in Cat Form)" or " (Cat Form only, LEFT OUT outside Cat Form)"
		end
		lines[#lines + 1] = "  " .. SpellLabel(id) .. suffix
	end
	if #ticked == 0 then
		lines[#lines + 1] = "  (none)"
	end

	lines[#lines + 1] = "Farm cycle (as Farm Mode casts it):"
	local cycle = ns.GetFarmCycle()
	local persistentId = db.farmIncludePersistent and ns.GetPersistentSpell() or nil
	for _, id in ipairs(cycle) do
		local suffix = id == persistentId and " (Persistent Tracking Ability)" or ""
		lines[#lines + 1] = string.format("  %d %s%s", id, C_Spell.GetSpellName(id) or "?", suffix)
	end
	if #cycle == 0 then
		lines[#lines + 1] = string.format("  (empty: %s)", tostring(ns.GetEmptyCycleKind()))
	end
	lines[#lines + 1] = ""

	lines[#lines + 1] = string.format(
		"Cycle Farm Mode Ability key: %s // farmZoomOut: %s",
		tostring(GetBindingKey("TRACKINGEYE_CYCLE_FARM_ABILITY") or "not bound"),
		OnOff(global.farmZoomOut)
	)

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Come & Get It Context
--------------------------------------------------------------------------------

--[[
    Live read of the state Come & Get It's UI_ERROR_MESSAGE handler depends on:
    its toggle and channel, the detection config it matches against, every
    check that can stop a callout before or after the match, and the exact
    C_Map chain AnnounceNode walks. An existence check can't prove the map
    calls return a usable mapID and position, so this prints the actual values.
    The five-second cooldown between callouts isn't readable from here. Text is
    pipe-escaped so it pastes as plain words. Read-only.
]]
function ns:BuildComeAndGetItContextReport()
	local lines = { GetClientHeader(), "" }
	local db = (ns.db and ns.db.profile) or {}

	local command
	for _, channel in ipairs(ns.OUTPUT_CHANNELS) do
		if channel.key == db.comeAndGetItOutput then
			command = channel.command
		end
	end
	lines[#lines + 1] = string.format(
		"comeAndGetIt: %s // comeAndGetItOutput: %s -> %s",
		OnOff(db.comeAndGetIt),
		tostring(db.comeAndGetItOutput),
		command or string.format("unknown key, falls back to %s", ns.DEFAULT_OUTPUT_CHANNEL)
	)
	lines[#lines + 1] = string.format(
		"Locked-chest error: %s = %q",
		ns.ERROR_STRING_LOCKED_CHEST,
		tostring(_G[ns.ERROR_STRING_LOCKED_CHEST])
	)
	lines[#lines + 1] = string.format("Herb match string = %q", tostring(L["MATCH_HERB"]))
	lines[#lines + 1] = string.format("Mine match string = %q", tostring(L["MATCH_MINE"]))
	lines[#lines + 1] = ""

	lines[#lines + 1] = string.format("in an instance: %s (callouts suppressed)", tostring((IsInInstance())))
	lines[#lines + 1] = string.format("in combat: %s (callouts suppressed)", tostring(InCombatLockdown()))
	lines[#lines + 1] = string.format(
		"chat box already open: %s (a callout never replaces your draft)",
		tostring(ChatFrameUtil.GetActiveWindow() ~= nil)
	)
	local nodeName = GameTooltip:IsShown() and GameTooltipTextLeft1:GetText() or nil
	local itemName, itemLink = GameTooltip:GetItem()
	lines[#lines + 1] = string.format(
		"tooltip shown: %s // first line: %s // shows an item: %s (a bag lockbox, never called out)",
		tostring(GameTooltip:IsShown()),
		nodeName and (nodeName:gsub("|", "||")) or "nil",
		tostring(itemName ~= nil or itemLink ~= nil)
	)
	lines[#lines + 1] = ""

	local mapID = C_Map.GetBestMapForUnit("player")
	lines[#lines + 1] = string.format("C_Map.GetBestMapForUnit('player') = %s", tostring(mapID))
	if mapID then
		local position = C_Map.GetPlayerMapPosition(mapID, "player")
		if position then
			lines[#lines + 1] = string.format(
				"  position = %.1f, %.1f%s",
				position.x * 100,
				position.y * 100,
				(position.x == 0 and position.y == 0) and " (unresolved, no callout)" or ""
			)
		else
			lines[#lines + 1] = "  position = nil"
		end
		local info = C_Map.GetMapInfo(mapID)
		lines[#lines + 1] = string.format("  zone = %s", info and info.name or "nil")
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

--[[
    Every record Tracking Eye shows or matches by the name this client gives
    it, for the Localization tab's Game Names report. Each row reads the name
    exactly as the features do. The client strings are Blizzard UI labels, so
    each one's id is its own constant name. A spell row exists only where this
    flavor's data has that spell, and a movement state's only where this
    flavor can detect it, so no row reports a spell the flavor never names. A
    row whose name loads late (a spell) adds request, which the report calls
    and polls.
]]
local function UiLabel(constant)
	return {
		constant = constant,
		kind = "uiLabel",
		id = constant,
		lookup = function()
			return _G[constant]
		end,
	}
end

local function RequestSpell(spellId)
	return function()
		C_Spell.RequestLoadSpellData(spellId)
	end
end

ns.DIAGNOSTIC_NAME_LOOKUPS = {
	-- { constant, kind, id, lookup, request }
	UiLabel("KEY_BINDINGS"),
	UiLabel("SETTINGS_KEYBINDINGS_LABEL"),
	UiLabel("GAMEMENU_OPTIONS"),
	UiLabel("NOT_BOUND"),
	UiLabel(ns.ERROR_STRING_LOCKED_CHEST),
	{
		constant = "FISHING_POLE",
		kind = "itemSubclass",
		id = "Weapon/Fishingpole",
		lookup = function()
			return ns.GetFishingPoleName()
		end,
	},
}

-- Come & Get It's output channels the client labels itself.
for _, channel in ipairs(ns.OUTPUT_CHANNELS) do
	if channel.labelGlobal then
		table.insert(ns.DIAGNOSTIC_NAME_LOOKUPS, UiLabel(channel.labelGlobal))
	end
end

-- Every class the options and pause reasons name: the Farm Mode Abilities groups and each movement state's owner.
do
	local seen = {}
	local classes = {}
	for _, entry in ipairs(ns.FARM_ABILITY_CLASSES) do
		classes[#classes + 1] = entry.class
	end
	for _, state in ipairs(ns.CLASS_STATE_ORDER) do
		classes[#classes + 1] = ns.MOVEMENT_STATE_CLASS[state]
	end
	for _, token in ipairs(classes) do
		if not seen[token] then
			seen[token] = true
			table.insert(ns.DIAGNOSTIC_NAME_LOOKUPS, {
				constant = "CLASS_" .. token,
				kind = "className",
				id = token,
				lookup = function()
					return ns.GetClassNameText(token)
				end,
			})
		end
	end
end

-- The spells the options and messages name in their own sentences, by their ns.SPELLS key.
for _, key in ipairs({ "CAT", "TRAVEL", "AQUATIC", "FLIGHT", "FISH", "HUMANOIDS", "DRUID_HUMANOIDS" }) do
	local spellId = ns.SPELLS[key]
	if spellId then
		table.insert(ns.DIAGNOSTIC_NAME_LOOKUPS, {
			constant = "SPELL_" .. key,
			kind = "spell",
			id = spellId,
			lookup = function()
				return ns.GetSpellNameText(spellId)
			end,
			request = RequestSpell(spellId),
		})
	end
end

-- Each movement state's buff, named through ns.GetMovementStateName, which reads its last data row.
for _, state in ipairs(ns.CLASS_STATE_ORDER) do
	local spellId
	for _, row in ipairs(ns.MOVEMENT_BUFF_SPELLS) do
		if row[2] == state then
			spellId = row[1]
		end
	end
	if spellId then
		table.insert(ns.DIAGNOSTIC_NAME_LOOKUPS, {
			constant = "STATE_" .. state,
			kind = "spell",
			id = spellId,
			lookup = function()
				return ns.GetMovementStateName(state)
			end,
			request = RequestSpell(spellId),
		})
	end
end

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
    One entry per data file, and one report row per entry on the Data tab
    (Diagnostics/Options-Diagnostics.lua). Each entry's label is the table-name
    part of its file name, so ns.DataSourceFileName can name the file this
    client's folder built. Each source names the static table on ns and its kind:
    "spell", or "other" for ids no client API looks up, which print a row count
    instead of rows. Ids are reached through rowId(key, row) over the table's
    pairs. dataColumns carries the shipped row's own values as { header,
    getter(key, row) }, so the export sets what the file says beside what the
    client says. Adding a data file adds an entry here, and the panel and the
    validator pick it up with no second list.
]]
local function KeyIsId(key)
	return key
end

local function RowField(position)
	return function(_, row)
		return type(row) == "table" and row[position] or nil
	end
end

local function RowValue(_, row)
	return row
end

ns.DIAGNOSTIC_DATA_SOURCES = {
	-- { label, sources = { { table, kind, rowId, dataColumns } } }
	{
		label = "Spells",
		sources = {
			{
				table = "TRACKING_SPELLS",
				kind = "spell",
				rowId = RowField(1),
				dataColumns = {
					{ "DATA_KEY", RowField(2) },
					{ "DATA_SOURCE", RowField(3) },
				},
			},
			{
				table = "MOVEMENT_BUFF_SPELLS",
				kind = "spell",
				rowId = RowField(1),
				dataColumns = { { "DATA_STATE", RowField(2) } },
			},
			{
				table = "FARM_CYCLE_DEFAULTS",
				kind = "spell",
				rowId = KeyIsId,
				dataColumns = { { "DATA_DEFAULT", RowValue } },
			},
			{ table = "CREATURE_TYPE_DATA", kind = "other" },
		},
	},
	{
		label = "Zones",
		sources = {
			{ table = "RESTRICTED_MAP_IDS", kind = "other" },
		},
	},
}
