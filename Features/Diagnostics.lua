local _, ns = ...

--------------------------------------------------------------------------------
-- Diagnostic Tools
--------------------------------------------------------------------------------

--[[
    Environment probing and state capture for bug reports, not unit tests. WoW's
    sandboxed Lua has no assertion runner, so everything here is read-only and
    side-effect free. The one exception is the explicit Taint Log button, which
    sets the taintLog CVar. Reports build only on a button press, never on load
    or panel open.
]]

local L = ns.L

--------------------------------------------------------------------------------
-- Runtime State
--------------------------------------------------------------------------------

--[[
    Runtime-only state. NOT a SavedVariable. File-scope init is correct here —
    the "initialize on PLAYER_LOGIN" rule applies only to SavedVariables, which
    don't exist until the client loads them. This is a plain namespace table.
]]
ns.diagnostics = ns.diagnostics or { enabled = false, logging = false, log = nil }

--------------------------------------------------------------------------------
-- Strings
--------------------------------------------------------------------------------

--[[
    Diagnostics strings are intentionally NOT localized. They are
    developer-facing troubleshooting text; translating them is wasted effort for
    zero player value. Every diagnostics string lives here as plain English, in
    the diagnostics files only — never in Locales/. The one exception is the
    add-on's own display name, read from ns.L["ADDON_TITLE"], which is the
    add-on's identity, not a diagnostics string.
]]
ns.DiagnosticsStrings = {
	TAB = "Diagnostic Tools",
	WARNING = "These tools help diagnose problems and are meant for developers. They won't change how the add-on works, but their output includes technical details about your client and installed add-ons. Leave this off unless you're troubleshooting with someone.",
	ENABLE = "Enable Diagnostic Tools",
	EVENT_LOG_TITLE = "Event Log",
	EVENT_LOG_START = "Start Event Log",
	EVENT_LOG_STOP = "Stop Event Log",
	EVENT_LOG_SHOW = "Show Captured Events",
	EVENT_LOG_HINT = "Captures the events the add-on registered for, with arguments, in the order they fired. Review the output before sharing it.",
	EVENTS_TITLE = "Event Registration",
	EVENTS_BUTTON = "Test Event Registration",
	API_TITLE = "API Endpoints",
	API_BUTTON = "Test WoW API Endpoints",
	PLAYER_TITLE = "Player & Spell Context",
	PLAYER_BUTTON = "Check Player & Tracking Spells",
	DISPLAY_TITLE = "Display Context",
	DISPLAY_BUTTON = "Check Display & Icon Placement",
	FARM_TITLE = "Farm Mode Context",
	FARM_BUTTON = "Check Farm Mode State",
	ADDONS_TITLE = "Other Add-ons",
	ADDONS_BUTTON = "List Installed Add-ons",
	SAVED_TITLE = "Saved Variables",
	SAVED_BUTTON = "Dump Saved Variables",
	LIBS_TITLE = "Library Versions",
	LIBS_BUTTON = "List Library Versions",
	TAINT_TITLE = "Taint Log",
	TAINT_STATE = "Taint logging is currently set to level %d (0 = off, 2 = verbose).",
	TAINT_ON = "Turn On Taint Log",
	TAINT_OFF = "Turn Off Taint Log",
	TAINT_HINT = "Writes to Logs\\taint.log. The setting persists until turned off; reload your UI to capture taint from login onward.",
	TOOLS_TITLE = "External Tools",
	TOOLS_ERRORS = "Lua errors: install BugSack and !BugGrabber, or enable %s to surface them.",
	TOOLS_ETRACE = "Live event tracing: use %s.",
}

--------------------------------------------------------------------------------
-- Enable Gate
--------------------------------------------------------------------------------

function ns:SetDiagnosticsEnabled(value)
	ns.diagnostics.enabled = value and true or false
	if not ns.diagnostics.enabled then
		ns:StopEventLog()
	end
end

--------------------------------------------------------------------------------
-- Report Header
--------------------------------------------------------------------------------

local function GetClientHeader()
	local version, build, _, tocVersion = GetBuildInfo()
	return string.format(
		"%s %s // Client %s // Build %s // TOC %s // Locale %s // Project %s",
		L["ADDON_TITLE"],
		ns.Version,
		version,
		build,
		tocVersion,
		GetLocale(),
		tostring(WOW_PROJECT_ID)
	)
end

--------------------------------------------------------------------------------
-- Event Log
--------------------------------------------------------------------------------

local EVENT_LOG_SIZE = 500
local EVENT_LOG_MAX_ARGS = 8

--[[
    Per-argument byte cap. 255 holds a full chat or loot line with an item link
    while still bounding a runaway argument. A smaller cap (64) would cut an item
    link mid-name and collapse the entry to a sliver like "[Sc".
]]
local EVENT_LOG_MAX_ARG_LENGTH = 255

--[[
    Events ns:LogEvent drops before recording — deliberately empty. The
    dispatcher only ever hands LogEvent the events Tracking Eye registers (Core's
    ns.EVENT_NAMES), and none of those is a sustained firehose worth dropping.
    The lookup in LogEvent stays so a genuine no-signal firehose can be excluded
    here if one is ever registered. Generic offenders
    (COMBAT_LOG_EVENT_UNFILTERED, UNIT_AURA, ...) do not belong here unless
    registered — the log never sees an event the add-on didn't register.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {}

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.logging = true
end

function ns:StopEventLog()
	ns.diagnostics.logging = false
	ns.diagnostics.log = nil
end

--[[
    Called by Core's dispatcher for every event while logging is active.
    Snapshots arguments to strings immediately — never retain references, since
    some events carry frames or tables that would leak memory or go stale. Caps
    the arg count and string length so a single entry can't run away.

    Pipes are escaped (| -> ||) AFTER the length cut so each argument shows
    verbatim in the report editbox rather than rendering as a clickable swatch,
    and so the cut can never leave a dangling pipe that eats the ", " separator.
]]
function ns:LogEvent(event, ...)
	if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
		return
	end
	local parts = {}
	for index = 1, select("#", ...) do
		if index > EVENT_LOG_MAX_ARGS then
			break
		end
		local raw = string.sub(tostring((select(index, ...))), 1, EVENT_LOG_MAX_ARG_LENGTH)
		parts[index] = (raw:gsub("|", "||"))
	end
	local log = ns.diagnostics.log
	log[#log + 1] = string.format("%.3f %s(%s)", GetTime(), event, table.concat(parts, ", "))
	if #log > EVENT_LOG_SIZE then
		table.remove(log, 1)
	end
end

function ns:BuildEventLogReport()
	local lines = { GetClientHeader(), "" }
	local log = ns.diagnostics.log
	if not log or #log == 0 then
		lines[#lines + 1] = "(no events captured)"
	else
		for _, entry in ipairs(log) do
			lines[#lines + 1] = entry
		end
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Event Registration
--------------------------------------------------------------------------------

--[[
    For every event Tracking Eye registers (ns.EVENT_NAMES, exported by
    Core.lua), report whether it is valid on this client
    (C_EventUtils.IsEventValid) and whether RegisterEvent succeeds. The probe
    frame registers then immediately unregisters each event with no handler
    attached, so nothing is ever processed. The list is sourced from Core so it
    can never drift from the events the add-on actually uses.
]]

local probeFrame

local function GetProbeFrame()
	if not probeFrame then
		probeFrame = CreateFrame("Frame")
	end
	return probeFrame
end

function ns:RunEventChecks()
	local lines = { GetClientHeader(), "" }
	local hasIsEventValid = type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
	local probe = GetProbeFrame()
	local failures = 0
	for _, event in ipairs(ns.EVENT_NAMES or {}) do
		local valid = "n/a"
		if hasIsEventValid then
			valid = C_EventUtils.IsEventValid(event) and "valid" or "INVALID"
		end
		local ok = pcall(probe.RegisterEvent, probe, event)
		if ok then
			probe:UnregisterEvent(event)
		else
			failures = failures + 1
		end
		lines[#lines + 1] = string.format("[%s] %s (IsEventValid: %s)", ok and "PASS" or "FAIL", event, valid)
	end
	lines[#lines + 1] = ""
	if failures == 0 then
		lines[#lines + 1] = "All events register on this client."
	else
		lines[#lines + 1] = string.format("%d event(s) failed to register.", failures)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. Kept aligned with the API guards in Core.lua, Farm-Mode.lua,
    Tracking-Menu.lua, Minimap-Button.lua, and Options.lua.
]]
ns.DIAGNOSTIC_API_CHECKS = {
	-- { label, testFunction, optional }
	{
		"C_AddOns.GetAddOnMetadata",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function"
		end,
	},
	{
		"GetTrackingTexture",
		function()
			return type(GetTrackingTexture) == "function"
		end,
	},
	{
		"CancelTrackingBuff",
		function()
			return type(CancelTrackingBuff) == "function"
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
		"GetSpellInfo",
		function()
			return type(GetSpellInfo) == "function"
		end,
	},
	{
		"GetSpellTexture",
		function()
			return type(GetSpellTexture) == "function"
		end,
	},
	{
		"GetSpellCooldown",
		function()
			return type(GetSpellCooldown) == "function"
		end,
	},
	{
		"UnitBuff",
		function()
			return type(UnitBuff) == "function"
		end,
	},
	{
		"UnitCastingInfo",
		function()
			return type(UnitCastingInfo) == "function"
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
	{
		"UnitClass",
		function()
			return type(UnitClass) == "function"
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
		"MouseIsOver",
		function()
			return type(MouseIsOver) == "function"
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
	{
		"GetAddOnMetadata (legacy)",
		function()
			return type(GetAddOnMetadata) == "function"
		end,
		true,
	},
	{
		"GetAddOnInfo (legacy)",
		function()
			return type(GetAddOnInfo) == "function"
		end,
		true,
	},
	{
		"GetNumAddOns (legacy)",
		function()
			return type(GetNumAddOns) == "function"
		end,
		true,
	},
	{
		"Settings.OpenToCategory",
		function()
			return type(Settings) == "table" and type(Settings.OpenToCategory) == "function"
		end,
	},
	{
		"InterfaceOptionsFrame_OpenToCategory",
		function()
			return type(InterfaceOptionsFrame_OpenToCategory) == "function"
		end,
		true,
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
}

--[[
    Every entry is an API the add-on genuinely calls. A row flagged optional is the
    legacy half of a compatibility guard, absent on a modern client by design: it
    renders [n/a] and never counts as a failure. Any other miss is a real problem.
]]
function ns:RunApiChecks()
	local lines = { GetClientHeader(), "" }
	local failures = 0
	for _, check in ipairs(ns.DIAGNOSTIC_API_CHECKS) do
		local ok, result = pcall(check[2])
		if ok and result then
			lines[#lines + 1] = "[PASS] " .. check[1]
		elseif check[3] then
			lines[#lines + 1] = "[n/a] " .. check[1]
		else
			lines[#lines + 1] = "[FAIL] " .. check[1]
			failures = failures + 1
		end
	end
	lines[#lines + 1] = ""
	if failures == 0 then
		lines[#lines + 1] = "Every required API is present on this client."
	else
		lines[#lines + 1] = string.format("%d required API(s) missing.", failures)
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Player & Spell Context
--------------------------------------------------------------------------------

--[[
    Most "nothing shows up" reports are "the player doesn't know the spell" or
    "the API returned nil." This lists class, level, and IsPlayerSpell /
    GetSpellInfo over every tracking spell the add-on gates on. Read-only.
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
            Find Fish (43308) is TBC-only and reads that way on Era.
        ]]
		local name = GetSpellInfo(spellId)
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
-- Display Context
--------------------------------------------------------------------------------

--[[
    Solves off-screen and wrong-position reports for the free-placement frame and
    the minimap button. Reads screen size, UI scale, and the live placement
    state. Read-only.
]]
function ns:BuildDisplayContextReport()
	local lines = { GetClientHeader(), "" }
	local width, height = GetPhysicalScreenSize()
	lines[#lines + 1] = string.format("PhysicalScreenSize: %s x %s", tostring(width), tostring(height))
	lines[#lines + 1] = string.format("UIParent scale: %s", tostring(UIParent:GetScale()))
	lines[#lines + 1] = string.format("uiScale CVar: %s", tostring(GetCVar("uiScale")))
	lines[#lines + 1] = ""
	local profile = ns.db and ns.db.profile
	local global = ns.db and ns.db.global
	lines[#lines + 1] = string.format("freePlacement: %s", tostring(global and global.freePlacement))
	if global and type(global.freePos) == "table" then
		lines[#lines + 1] = string.format("freePos: x=%s y=%s", tostring(global.freePos.x), tostring(global.freePos.y))
	else
		lines[#lines + 1] = "freePos: (none)"
	end
	if ns.freeFrame then
		lines[#lines + 1] = string.format(
			"freeFrame shown: %s // scale: %s",
			tostring(ns.freeFrame:IsShown()),
			tostring(ns.freeFrame:GetScale())
		)
	else
		lines[#lines + 1] = "freeFrame: (not created)"
	end
	if global and type(global.minimap) == "table" then
		lines[#lines + 1] = string.format(
			"minimap.hide: %s // minimapPos: %s",
			tostring(global.minimap.hide),
			tostring(global.minimap.minimapPos)
		)
	else
		lines[#lines + 1] = "minimap: (not initialized)"
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
		"state toggles: mounted=%s travelForms=%s cheetah=%s ghostWolf=%s notMounted=%s",
		tostring(db.farmMounted),
		tostring(db.farmTravelForms),
		tostring(db.farmCheetah),
		tostring(db.farmGhostWolf),
		tostring(db.farmNotMounted)
	)
	local global = (ns.db and ns.db.global) or {}
	lines[#lines + 1] = string.format(
		"targetTracking=%s muteCycleSound=%s hookBlizzardTracking=%s Sound_EnableSFX=%s",
		tostring(db.targetTracking),
		tostring(db.muteCycleSound),
		tostring(global.hookBlizzardTracking),
		tostring(GetCVar("Sound_EnableSFX"))
	)
	lines[#lines + 1] = ""

	local hasTravelForm, hasCheetah, hasGhostWolf = false, false, false
	for i = 1, 40 do
		local name, _, _, _, _, _, _, _, _, id = UnitBuff("player", i)
		if not name then
			break
		end
		if id then
			if ns.FARM_FORMS[id] then
				hasTravelForm = true
			elseif ns.CHEETAH_BUFFS[id] then
				hasCheetah = true
			elseif id == ns.GHOST_WOLF then
				hasGhostWolf = true
			end
		end
	end
	lines[#lines + 1] = string.format(
		"live: mounted=%s onTaxi=%s travelForm=%s cheetah=%s ghostWolf=%s",
		tostring(IsMounted()),
		tostring(UnitOnTaxi("player")),
		tostring(hasTravelForm),
		tostring(hasCheetah),
		tostring(hasGhostWolf)
	)

	local isCat, isFarming = ns.GetPlayerStates()
	lines[#lines + 1] = string.format("GetPlayerStates -> isCat=%s isFarming=%s", tostring(isCat), tostring(isFarming))
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
		tostring(GetTrackingTexture()),
		tostring(ns.GetActiveTrackingSpell()),
		tostring(ns.state.lastCastSpell),
		GetTime() - (ns.state.enteredWorldAt or 0),
		GetTime() - (ns.state.lastTrackingCastAt or 0)
	)
	--[[
        The pause reason is printed as its raw locale key, never the translated
        string: a report pasted from a zhTW client has to be readable here.
    ]]
	lines[#lines + 1] = string.format(
		"pause reason (live): %s // cached: %s",
		tostring(ns.GetFarmPauseReason()),
		tostring(ns.state.farmPauseReason)
	)
	lines[#lines + 1] =
		string.format("lootWindowOpen=%s cursor=%s", tostring(ns.state.lootWindowOpen), tostring((GetCursorInfo())))
	lines[#lines + 1] = ""

	--[[
        Answers "Target Tracking does nothing" and "the setting isn't there": the
        known-tracker count is the exact condition the options section hides on.
    ]]
	local creatureType = UnitExists("target") and UnitCreatureType("target") or nil
	local knownCreatureTrackers = 0
	for candidateType in pairs(ns.CREATURE_TYPE_SPELLS) do
		if ns.GetCreatureTypeSpell(candidateType) then
			knownCreatureTrackers = knownCreatureTrackers + 1
		end
	end

	lines[#lines + 1] = string.format(
		"target creature type: %s // resolves to: %s // creature types covered: %d",
		creatureType or "(no target)",
		tostring(ns.GetCreatureTypeSpell(creatureType)),
		knownCreatureTrackers
	)
	lines[#lines + 1] = ""

	lines[#lines + 1] = "Farm cycle (enabled, known, excluding Druid Track Humanoids):"
	local cycle = db.farmCycleSpells or {}
	local count = 0
	for id, enabled in pairs(cycle) do
		if enabled and id ~= ns.SPELLS.DRUID_HUMANOIDS and IsPlayerSpell(id) then
			count = count + 1
			lines[#lines + 1] = string.format("  %d %s", id, GetSpellInfo(id) or "?")
		end
	end
	if count == 0 then
		lines[#lines + 1] = "  (none — cycle is empty)"
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	local getNum = (C_AddOns and C_AddOns.GetNumAddOns) or GetNumAddOns
	local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or GetAddOnInfo
	local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
	if not getNum or not getInfo then
		lines[#lines + 1] = "Add-on list API unavailable on this client."
		return table.concat(lines, "\n")
	end
	for index = 1, getNum() do
		local name, _, _, loadable = getInfo(index)
		local version = (getMetadata and getMetadata(index, "Version")) or "?"
		lines[#lines + 1] = string.format("%s v%s [%s]", name, version, loadable and "loadable" or "disabled")
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Saved Variables
--------------------------------------------------------------------------------

local function DumpTable(value, indent, depth, lines)
	if depth > 8 then
		lines[#lines + 1] = indent .. "<max depth>"
		return
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	for _, key in ipairs(keys) do
		local entry = value[key]
		if type(entry) == "table" then
			lines[#lines + 1] = indent .. tostring(key) .. " = {"
			DumpTable(entry, indent .. "    ", depth + 1, lines)
			lines[#lines + 1] = indent .. "}"
		else
			lines[#lines + 1] = indent .. tostring(key) .. " = " .. tostring(entry)
		end
	end
end

function ns:BuildSavedVariablesReport()
	local lines = { GetClientHeader(), "", "TrackingEyeDB = {" }
	DumpTable(TrackingEyeDB or {}, "    ", 1, lines)
	lines[#lines + 1] = "}"
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Library Versions
--------------------------------------------------------------------------------

function ns:BuildLibraryReport()
	local lines = { GetClientHeader(), "" }
	local names = {}
	for name in LibStub:IterateLibraries() do
		names[#names + 1] = name
	end
	table.sort(names)
	for _, name in ipairs(names) do
		lines[#lines + 1] = string.format("%s (minor %s)", name, tostring(LibStub.minors[name]))
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Taint Log
--------------------------------------------------------------------------------

--[[
    The taintLog CVar controls UI taint logging to Logs\taint.log. Level 2 logs
    both blocked actions and accesses to tainted globals; 0 is off. This is the
    only state the diagnostics panel ever writes.
]]

function ns:GetTaintLogState()
	return tonumber(GetCVar("taintLog")) or 0
end

function ns:SetTaintLog(enabled)
	SetCVar("taintLog", enabled and 2 or 0)
end
