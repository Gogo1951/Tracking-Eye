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
    Validate Data appends a row per reader it calls.
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
		"C_Spell.DoesSpellExist",
		function()
			return type(C_Spell) == "table" and type(C_Spell.DoesSpellExist) == "function"
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
		"IsSpellKnown",
		function()
			return type(IsSpellKnown) == "function"
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
	-- The icon ns.ApplyBlizzardTrackingHook takes over.
	{
		"MiniMapTracking (frame)",
		function()
			return type(MiniMapTracking) == "table"
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
	-- The Fishing Pole name in the Persistent Tracking option (ns.GetFishingPoleName).
	{
		"C_Item.GetItemSubClassInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSubClassInfo) == "function"
		end,
	},
}

-- The add-on's own example reports, appended to the shared Event Log intro.
ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES =
	"Best for 'Farm Mode doesn't cycle', 'my tracking didn't come back' or 'Come & Get It did nothing' reports."

--------------------------------------------------------------------------------
-- Player & Spell Context
--------------------------------------------------------------------------------

--[[
    Most "nothing shows up" reports are "the player doesn't know the spell" or
    "the API returned nil." This lists class, level, and IsPlayerSpell /
    spell name over every tracking spell the add-on gates on. Read-only.
]]
ns.DIAGNOSTIC_SPELLS = ns.TRACKING_IDS

function ns:BuildPlayerContextReport()
	local lines = { GetClientHeader(), "" }
	local _, class = UnitClass("player")
	lines[#lines + 1] = string.format("Class: %s // Level: %d", tostring(class), UnitLevel("player"))
	lines[#lines + 1] = ""
	for _, spellId in ipairs(ns.DIAGNOSTIC_SPELLS or {}) do
		--[[
            A nil name means the spell is not in THIS client's database at all,
            which is a different thing from the player not having learned it.
        ]]
		local name = C_Spell.GetSpellName(spellId)
		if not name then
			lines[#lines + 1] = string.format("%d (not on this client)", spellId)
		else
			lines[#lines + 1] =
				string.format("%d %s [%s]", spellId, name, IsPlayerSpell(spellId) and "known" or "not known")
		end
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Farm Mode Context
--------------------------------------------------------------------------------

--[[
    Answers the most common "Farm Mode doesn't cycle" report: the master and
    per-state toggles, the live movement inputs (mount, taxi, detected buffs), the
    resulting ns.GetPlayerStates() classification, the cast/zone gates, and the
    effective farm cycle. Read-only.
]]
function ns:BuildFarmContextReport()
	local lines = { GetClientHeader(), "" }
	local db = (ns.db and ns.db.profile) or {}

	lines[#lines + 1] =
		string.format("farmMode (master): %s // interval: %s", tostring(db.farmMode), tostring(db.farmInterval))
	lines[#lines + 1] = string.format(
		"state toggles: mounted=%s travelForms=%s cheetah=%s pack=%s ghostWolf=%s notMounted=%s",
		tostring(db.farmMounted),
		tostring(db.farmTravelForms),
		tostring(db.farmCheetah),
		tostring(db.farmPack),
		tostring(db.farmGhostWolf),
		tostring(db.farmNotMounted)
	)
	local global = (ns.db and ns.db.global) or {}
	lines[#lines + 1] = string.format(
		"targetTracking=%s battlegroundHumanoids=%s catFormHumanoids=%s fishingPoleFish=%s muteCycleSound=%s hookBlizzardTracking=%s Sound_EnableSFX=%s",
		tostring(db.targetTracking),
		tostring(db.battlegroundHumanoids),
		tostring(db.catFormHumanoids),
		tostring(db.fishingPoleFish),
		tostring(db.muteCycleSound),
		tostring(global.hookBlizzardTracking),
		tostring(GetCVar("Sound_EnableSFX"))
	)
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
		"live: mounted=%s onTaxi=%s travelForm=%s cheetah=%s pack=%s ghostWolf=%s fishingPole=%s",
		tostring(IsMounted()),
		tostring(UnitOnTaxi("player")),
		tostring(hasTravelForm),
		tostring(hasCheetah),
		tostring(hasPack),
		tostring(hasGhostWolf),
		tostring(ns.IsFishingPoleEquipped())
	)

	local isCat, isFarming, movementState = ns.GetPlayerStates()
	lines[#lines + 1] = string.format(
		"GetPlayerStates -> isCat=%s isFarming=%s movementState=%s",
		tostring(isCat),
		tostring(isFarming),
		tostring(movementState)
	)
	lines[#lines + 1] =
		string.format("CanCast=%s IsRestrictedZone=%s", tostring(ns.CanCast()), tostring(ns.IsRestrictedZone()))
	--[[
        Raw tracking-mirror vs bookkeeping values. On Classic Era 1.15.x
        the mirror (GetTrackingTexture) can lag the real tracking state
        by minutes; a mismatch against lastCastSpell here is how that
        shows up in reports.
    ]]
	lines[#lines + 1] = string.format(
		"GetTrackingTexture: %s // GetActiveTrackingSpell: %s // lastCastSpell: %s // secs since enteredWorld: %d // secs since last cast attempt: %d",
		GetTrackingTexture and tostring(GetTrackingTexture()) or "n/a",
		tostring(ns.GetActiveTrackingSpell()),
		tostring(ns.state.lastCastSpell),
		GetTime() - (ns.state.enteredWorldAt or 0),
		GetTime() - (ns.state.lastTrackingCastAt or 0)
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
	--[[
        The pause reason is printed as its raw locale key, never the translated
        string: a report pasted from a zhTW client has to be readable here.
    ]]
	lines[#lines + 1] = string.format(
		"pause reason (live): %s // cached: %s",
		tostring(ns.GetFarmPauseReason()),
		tostring(ns.state.farmPauseReason)
	)
	-- moving is the boolean, never the raw speed, which can be secret on WoW Forever.
	lines[#lines + 1] = string.format(
		"lootWindowOpen=%s cursor=%s moving=%s target=%s attackableTarget=%s ownTooltip=%s",
		tostring(ns.state.lootWindowOpen),
		tostring((GetCursorInfo())),
		tostring(ns.IsPlayerMoving()),
		tostring(UnitExists("target")),
		tostring(ns.HasAttackableTarget()),
		tostring(ns.IsOwnTooltipShowing())
	)
	lines[#lines + 1] = ""

	-- Answers "Target Tracking does nothing": the type the client reports for the target, and how many types this character covers.
	local targetType = "(no target)"
	local creatureTypeId
	if UnitExists("target") then
		local creatureTypeName
		creatureTypeName, creatureTypeId = ns.GetUnitCreatureType("target")
		targetType = string.format("%s (ID %s)", tostring(creatureTypeName), tostring(creatureTypeId))
	end
	local knownCreatureTrackers = 0
	for candidateTypeId in pairs(ns.CREATURE_TYPE_SPELLS) do
		if ns.GetCreatureTypeSpell(candidateTypeId) then
			knownCreatureTrackers = knownCreatureTrackers + 1
		end
	end

	lines[#lines + 1] = string.format(
		"target creature type: %s // resolves to: %s // creature types covered: %d",
		targetType,
		tostring(ns.GetCreatureTypeSpell(creatureTypeId)),
		knownCreatureTrackers
	)
	lines[#lines + 1] = string.format(
		"hunt: %s // Persistent Tracking resolves to: %s",
		ns.state.huntSpellId and tostring(ns.state.huntSpellId) or "none",
		tostring(ns.GetPersistentSpell())
	)
	lines[#lines + 1] = ""

	lines[#lines + 1] = "Farm cycle (as Farm Mode casts it):"
	local cycle = ns.GetFarmCycle()
	local persistentId = db.farmIncludePersistent and ns.GetPersistentSpell() or nil
	for _, id in ipairs(cycle) do
		local suffix = id == persistentId and " (Persistent Tracking Ability)" or ""
		lines[#lines + 1] = string.format("  %d %s%s", id, C_Spell.GetSpellName(id) or "?", suffix)
	end
	if #cycle == 0 then
		lines[#lines + 1] = "  (empty)"
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Come & Get It Context
--------------------------------------------------------------------------------

--[[
    Live read of the state Come & Get It's UI_ERROR_MESSAGE handler depends on:
    its toggle and channel, the detection config it matches against, the gates
    that most often explain "nothing happened," and the exact C_Map chain
    AnnounceNode walks. An existence check can't prove the map calls return a
    usable mapID and position, so this prints the actual values. Read-only.
]]
function ns:BuildComeAndGetItContextReport()
	local lines = { GetClientHeader(), "" }
	local db = (ns.db and ns.db.profile) or {}

	lines[#lines + 1] = string.format(
		"comeAndGetIt=%s // comeAndGetItOutput=%s",
		tostring(db.comeAndGetIt),
		tostring(db.comeAndGetItOutput)
	)
	lines[#lines + 1] = string.format("Locked-chest error string = %s", ns.ERROR_STRING_LOCKED_CHEST)
	lines[#lines + 1] = string.format("Herb match string = %q", tostring(L["MATCH_HERB"]))
	lines[#lines + 1] = string.format("Mine match string = %q", tostring(L["MATCH_MINE"]))

	lines[#lines + 1] = ""
	lines[#lines + 1] =
		string.format("IsInInstance() = %s (announcements suppressed in instances)", tostring((IsInInstance())))
	lines[#lines + 1] =
		string.format("InCombatLockdown() = %s (announcements suppressed in combat)", tostring(InCombatLockdown()))

	lines[#lines + 1] = ""
	local mapID = C_Map.GetBestMapForUnit("player")
	lines[#lines + 1] = string.format("C_Map.GetBestMapForUnit('player') = %s", tostring(mapID))
	if mapID then
		local position = C_Map.GetPlayerMapPosition(mapID, "player")
		if position then
			lines[#lines + 1] = string.format("  position = %.1f, %.1f", position.x * 100, position.y * 100)
		else
			lines[#lines + 1] = "  position = nil"
		end
		local info = C_Map.GetMapInfo(mapID)
		lines[#lines + 1] = string.format("  zone = %s", info and info.name or "nil")
	end

	return table.concat(lines, "\n")
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
