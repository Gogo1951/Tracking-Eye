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
	EVENT_LOG_HINT = "Captures the events the add-on registered for, with arguments, in the order they fired. Repeated errors Come & Get It doesn't act on are collapsed into a counted summary at the end. Output can include UI error text. Review it before sharing.",
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
	CGI_TITLE = "Come & Get It Context",
	CGI_BUTTON = "Check Come & Get It Detection",
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
	VALIDATE_TITLE = "Validate Data: %s",
	VALIDATE_BUTTON = "Validate %s",
	VALIDATE_HINT = "Each report is tab-separated and pastes straight into a spreadsheet. A NOT ON CLIENT row is an ID this client does not have: a row in the wrong flavor folder.",
}

--------------------------------------------------------------------------------
-- Enable Gate
--------------------------------------------------------------------------------

function ns:SetDiagnosticsEnabled(value)
	ns.diagnostics.enabled = value and true or false
	if not ns.diagnostics.enabled then
		ns.diagnostics.logging = false
		ns.diagnostics.log = nil
		ns.diagnostics.suppressed = nil
		ns:StopDataValidation()
	end
end

--------------------------------------------------------------------------------
-- Report Header
--------------------------------------------------------------------------------

local function GetClientHeader()
	local version, build, _, tocVersion = GetBuildInfo()
	return string.format(
		"%s %s // Client %s // Build %s // TOC %s // Locale %s // Flavor %s // Data %s",
		L["ADDON_TITLE"],
		ns.Version,
		version,
		build,
		tocVersion,
		GetLocale(),
		tostring(ns.FLAVOR),
		tostring(ns.DATA_FOLDER)
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
    Two noise mechanisms, split by kind. ns.DIAGNOSTIC_EVENT_EXCLUDE drops a
    registered event entirely and is only for events that are never signal; it
    stays empty because every registered event carries signal. Generic offenders
    (COMBAT_LOG_EVENT_UNFILTERED, UNIT_AURA, ...) do not belong here unless
    registered — the log never sees an event the add-on didn't register.

    A firehose that is only SOMETIMES signal gets the per-message-id filter
    instead: ns.MESSAGE_ID_FILTERED_EVENTS names the events carrying a message id
    and the argument position it arrives in, and ns:SuppressUncorrelatedMessage
    folds uncorrelated firings into a counted summary so they cannot evict real
    entries from the bounded buffer. UI_ERROR_MESSAGE is exactly that case —
    every red combat error fires it, but only the firings ns.MatchError
    correlates are Come & Get It's signal.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {}

-- Event name -> argument position of the message id; the message body rides in the next position.
ns.MESSAGE_ID_FILTERED_EVENTS = {
	UI_ERROR_MESSAGE = 1,
}

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.suppressed = {}
	ns.diagnostics.logging = true
end

-- Keeps the captured buffer so Show can still print it; Start replaces it.
function ns:StopEventLog()
	ns.diagnostics.logging = false
end

--[[
    Capture-time filter for the events in ns.MESSAGE_ID_FILTERED_EVENTS.
    Classifies with ns.MatchError — the exact lookup Come & Get It acts on — so
    the filter can never drift from what the feature responds to. Correlated
    firings log in full; a firing with no id logs verbatim (unclassifiable is
    signal); everything else folds into a per-id counter rendered as a summary
    at the end of the report. Returns true when the firing was folded.
]]
function ns:SuppressUncorrelatedMessage(event, ...)
	local position = ns.MESSAGE_ID_FILTERED_EVENTS[event]
	local messageID = select(position, ...)
	if messageID == nil or not ns.MatchError then
		return false
	end
	local message = select(position + 1, ...)
	if ns.MatchError(messageID, message) then
		return false
	end
	local entry = ns.diagnostics.suppressed[messageID]
	if not entry then
		local raw = string.sub(tostring(message), 1, EVENT_LOG_MAX_ARG_LENGTH)
		entry = { event = event, text = (raw:gsub("|", "||")), count = 0 }
		ns.diagnostics.suppressed[messageID] = entry
	end
	entry.count = entry.count + 1
	return true
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
	if ns.MESSAGE_ID_FILTERED_EVENTS[event] and ns:SuppressUncorrelatedMessage(event, ...) then
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
	local suppressed = ns.diagnostics.suppressed
	if suppressed and next(suppressed) then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "Suppressed uncorrelated traffic, biggest first"
		local ids = {}
		for id in pairs(suppressed) do
			ids[#ids + 1] = id
		end
		table.sort(ids, function(a, b)
			return suppressed[a].count > suppressed[b].count
		end)
		for _, id in ipairs(ids) do
			local entry = suppressed[id]
			lines[#lines + 1] = string.format("%s(%s, %s) x%d", entry.event, tostring(id), entry.text, entry.count)
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
    calls. Kept aligned with every API the add-on calls through a guard or an
    ns accessor.
]]
ns.DIAGNOSTIC_API_CHECKS = {
	-- { label, testFunction, optional }
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
		ns.FLAVOR ~= "Vanilla",
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
	-- Validate Data's readers; the last three are optional reads there.
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
		"C_Spell.GetSpellInfo",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellInfo) == "function"
		end,
	},
	{
		"C_Spell.GetSpellDescription",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellDescription) == "function"
		end,
	},
	{
		"C_Spell.GetSpellSubtext",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellSubtext) == "function"
		end,
		true,
	},
	{
		"IsSpellKnown",
		function()
			return type(IsSpellKnown) == "function"
		end,
		true,
	},
	{
		"C_TooltipInfo.GetSpellByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetSpellByID) == "function"
		end,
		true,
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
		true,
	},
	{
		"CancelTrackingBuff (legacy)",
		function()
			return type(CancelTrackingBuff) == "function"
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
		true,
	},
	-- The icon ns.ApplyBlizzardTrackingHook takes over.
	{
		"MiniMapTracking (frame)",
		function()
			return type(MiniMapTracking) == "table"
		end,
		true,
	},
}

--[[
    Every entry is an API the add-on genuinely calls. A row flagged optional is one
    half of a compatibility guard or an optional read, absent on some clients by
    design: it renders [n/a] and never counts as a failure. Any other miss is a
    real problem.
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
	lines[#lines + 1] = string.format(
		"minimap zoom: %d of %d // farmZoomOut: %s",
		Minimap:GetZoom(),
		Minimap:GetZoomLevels() - 1,
		tostring(global and global.farmZoomOut)
	)
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
-- Other Add-ons
--------------------------------------------------------------------------------

function ns:BuildAddOnReport()
	local lines = { GetClientHeader(), "" }
	for index = 1, C_AddOns.GetNumAddOns() do
		local name, _, _, loadable = C_AddOns.GetAddOnInfo(index)
		local version = C_AddOns.GetAddOnMetadata(index, "Version") or "?"
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
-- Validate Data
--------------------------------------------------------------------------------

--[[
    One entry per data file in the flavor folders, and one gated Validate Data
    section per entry in Options/Options-Diagnostics.lua. Every folder declares
    the same tables, so one manifest serves every flavor and the section reads
    the folder from ns.DATA_FOLDER. Each table is named by its key on ns, so a
    table this folder never built still reports; its kind is "spell", or "other"
    for IDs no client API looks up, which print a row count instead of rows.
]]
local function RowFirstId(_, row)
	return row[1]
end

local function KeyId(key)
	return key
end

ns.DIAGNOSTIC_DATA_SOURCES = {
	-- { label, tables = { { name, kind, rowId(key, value) } } }
	{
		label = "Spells",
		tables = {
			{ name = "TRACKING_SPELLS", kind = "spell", rowId = RowFirstId },
			{ name = "MOVEMENT_BUFF_SPELLS", kind = "spell", rowId = RowFirstId },
			{ name = "FARM_CYCLE_DEFAULTS", kind = "spell", rowId = KeyId },
			{ name = "CREATURE_TYPE_DATA", kind = "other", rowId = RowFirstId },
		},
	},
	{
		label = "Zones",
		tables = {
			{ name = "RESTRICTED_MAP_IDS", kind = "other", rowId = KeyId },
		},
	},
}

function ns.DataValidationFile(entry)
	local folder = tostring(ns.DATA_FOLDER)
	return string.format("%s/%s-%s.lua", folder, entry.label, folder)
end

function ns.DataValidationField(index)
	return "validateReport" .. index
end

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--[[
    Spell data loads asynchronously, so a run requests one batch at a time and
    polls until every row in it settles, asking again for stragglers after a few
    idle polls. After a bounded run of polls with no progress a straggler settles
    as a flagged row, so a run never waits forever or stalls a frame.
]]
local VALIDATE_BATCH_SIZE = 100
local VALIDATE_POLL_SECONDS = 0.2
local VALIDATE_REQUEST_AGAIN_POLLS = 5
local VALIDATE_MAX_IDLE_POLLS = 25

local STATUS_OK = "OK"
local STATUS_NOT_ON_CLIENT = "NOT ON CLIENT"
local STATUS_INCOMPLETE = "INCOMPLETE"
local STATUS_ERROR = "ERROR"
local STATUS_TABLE_MISSING = "TABLE MISSING"
local STATUSES = { STATUS_OK, STATUS_NOT_ON_CLIENT, STATUS_INCOMPLETE, STATUS_ERROR }

local SPELL_COLUMNS = {
	"STATUS",
	"SOURCE",
	"SPELL_ID",
	"NAME",
	"SUBTEXT",
	"ICON",
	"ORIGINAL_ICON",
	"CAST_TIME",
	"MIN_RANGE",
	"MAX_RANGE",
	"SPELL_NAME",
	"SPELL_TEXTURE",
	"IS_PLAYER_SPELL",
	"IS_SPELL_KNOWN",
	"DESCRIPTION",
	"TOOLTIP",
}

-- Optional reads, picked once by existence; a missing one leaves blank cells.
local GetSpellSubtext = C_Spell.GetSpellSubtext
local IsSpellKnownFn = IsSpellKnown

local function CellText(value)
	if value == nil then
		return ""
	end
	local text = tostring(value):gsub("[\t\r\n]", " ")
	return (text:gsub("|", "||"))
end

local function OptionalCell(fn, ...)
	if type(fn) ~= "function" then
		return ""
	end
	return CellText(fn(...))
end

local function SpellCells(status, row)
	local spellId = row.id
	local info = C_Spell.GetSpellInfo(spellId) or {}
	return {
		status,
		row.source,
		tostring(spellId),
		CellText(info.name),
		OptionalCell(GetSpellSubtext, spellId),
		CellText(info.iconID),
		CellText(info.originalIconID),
		CellText(info.castTime),
		CellText(info.minRange),
		CellText(info.maxRange),
		CellText(C_Spell.GetSpellName(spellId)),
		CellText(C_Spell.GetSpellTexture(spellId)),
		CellText(IsPlayerSpell(spellId)),
		OptionalCell(IsSpellKnownFn, spellId),
		CellText(C_Spell.GetSpellDescription(spellId)),
		CellText(ns.GetSpellTooltipText(spellId)),
	}
end

-- A reader that throws settles its row as ERROR, with the message in the Name cell.
local function ResolveRow(run, row, status)
	local ok, cells = pcall(SpellCells, status, row)
	if not ok then
		status = STATUS_ERROR
		cells = { status, row.source, tostring(row.id), CellText(cells) }
	end
	row.cells = cells
	run.counts[status] = run.counts[status] + 1
	run.resolved = run.resolved + 1
end

-- Settled once the ID, its text, and its tooltip have all loaded.
local function IsSpellSettled(spellId)
	local description = C_Spell.GetSpellName(spellId) and C_Spell.GetSpellDescription(spellId)
	return description ~= nil and description ~= "" and ns.GetSpellTooltipText(spellId) ~= ""
end

local validations = {}

local function Publish(index, text)
	ns.diagnostics[ns.DataValidationField(index)] = text
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Diagnostics)
end

local function ProgressText(run)
	return table.concat({
		GetClientHeader(),
		"",
		string.format(
			"Validated %d / %d IDs (batch %d of %d)...",
			run.resolved,
			#run.rows,
			run.batch,
			math.max(1, math.ceil(#run.rows / VALIDATE_BATCH_SIZE))
		),
	}, "\n")
end

-- Each timer carries its run's generation, so a newer run or a disabled panel retires it.
local function Schedule(index, run, step)
	local generation = run.generation
	C_Timer.After(VALIDATE_POLL_SECONDS, function()
		if run.generation == generation then
			step(index, run)
		end
	end)
end

--[[
    The standard client header, a one-line tally, a blank line, then a spell
    block (a header row naming every column, then one row per ID in ID order)
    and an "other" block of row counts. A table this folder never built prints
    one TABLE MISSING row in its kind's block.
]]
local function FinishValidation(index, run)
	local hasSpells = #run.rows > 0 or #run.missing.spell > 0
	local tally = { run.file }
	if #run.rows > 0 then
		for _, status in ipairs(STATUSES) do
			tally[#tally + 1] = string.format("%d %s", run.counts[status], status)
		end
	end
	local lines = { GetClientHeader(), table.concat(tally, " // "), "" }

	if hasSpells then
		lines[#lines + 1] = table.concat(SPELL_COLUMNS, "\t")
		for _, row in ipairs(run.rows) do
			lines[#lines + 1] = table.concat(row.cells, "\t")
		end
		for _, name in ipairs(run.missing.spell) do
			lines[#lines + 1] = STATUS_TABLE_MISSING .. "\t" .. name
		end
	end

	if #run.others > 0 or #run.missing.other > 0 then
		if hasSpells then
			lines[#lines + 1] = ""
		end
		lines[#lines + 1] = "STATUS\tSOURCE\tROWS"
		for _, other in ipairs(run.others) do
			lines[#lines + 1] = STATUS_OK .. "\t" .. other.name .. "\t" .. other.count
		end
		for _, name in ipairs(run.missing.other) do
			lines[#lines + 1] = STATUS_TABLE_MISSING .. "\t" .. name
		end
	end

	run.finished = true
	run.rows, run.pending = {}, {}
	Publish(index, table.concat(lines, "\n"))
end

local StartBatch

local function PollBatch(index, run)
	local stillPending = {}
	for _, row in ipairs(run.pending) do
		if IsSpellSettled(row.id) then
			ResolveRow(run, row, STATUS_OK)
		else
			stillPending[#stillPending + 1] = row
		end
	end

	if #stillPending == #run.pending then
		run.idlePolls = run.idlePolls + 1
	else
		run.idlePolls = 0
	end
	run.pending = stillPending

	if #run.pending > 0 and run.idlePolls >= VALIDATE_MAX_IDLE_POLLS then
		for _, row in ipairs(run.pending) do
			ResolveRow(run, row, C_Spell.GetSpellName(row.id) and STATUS_INCOMPLETE or STATUS_NOT_ON_CLIENT)
		end
		run.pending = {}
	elseif #run.pending > 0 and run.idlePolls > 0 and run.idlePolls % VALIDATE_REQUEST_AGAIN_POLLS == 0 then
		for _, row in ipairs(run.pending) do
			C_Spell.RequestLoadSpellData(row.id)
		end
	end

	if #run.pending > 0 then
		Publish(index, ProgressText(run))
		Schedule(index, run, PollBatch)
	elseif run.cursor < #run.rows then
		StartBatch(index, run)
	else
		FinishValidation(index, run)
	end
end

function StartBatch(index, run)
	run.batch = run.batch + 1
	run.idlePolls = 0
	local last = math.min(run.cursor + VALIDATE_BATCH_SIZE, #run.rows)
	for position = run.cursor + 1, last do
		local row = run.rows[position]
		if not C_Spell.DoesSpellExist(row.id) then
			ResolveRow(run, row, STATUS_NOT_ON_CLIENT)
		else
			C_Spell.RequestLoadSpellData(row.id)
			run.pending[#run.pending + 1] = row
		end
	end
	run.cursor = last
	Publish(index, ProgressText(run))
	Schedule(index, run, PollBatch)
end

function ns:StartDataValidation(index)
	local entry = ns.DIAGNOSTIC_DATA_SOURCES[index]
	if not entry then
		return
	end

	local run = validations[index] or { generation = 0 }
	validations[index] = run
	run.generation = run.generation + 1
	run.file = ns.DataValidationFile(entry)
	run.rows, run.pending, run.others = {}, {}, {}
	run.missing = { spell = {}, other = {} }
	run.counts = {}
	for _, status in ipairs(STATUSES) do
		run.counts[status] = 0
	end
	run.cursor, run.resolved, run.batch, run.finished = 0, 0, 0, false

	for _, source in ipairs(entry.tables) do
		local data = ns[source.name]
		if type(data) ~= "table" then
			table.insert(run.missing[source.kind], source.name)
		elseif source.kind == "other" then
			local count = 0
			for _ in pairs(data) do
				count = count + 1
			end
			run.others[#run.others + 1] = { name = source.name, count = count }
		else
			for key, value in pairs(data) do
				local id = source.rowId(key, value)
				if type(id) == "number" then
					run.rows[#run.rows + 1] = { id = id, source = source.name }
				end
			end
		end
	end
	table.sort(run.rows, function(a, b)
		if a.id == b.id then
			return a.source < b.source
		end
		return a.id < b.id
	end)

	if #run.rows == 0 then
		FinishValidation(index, run)
	else
		StartBatch(index, run)
	end
end

-- Switching the panel off retires every pending timer and clears unfinished reports.
function ns:StopDataValidation()
	for index, run in pairs(validations) do
		run.generation = run.generation + 1
		if not run.finished then
			run.rows, run.pending = {}, {}
			ns.diagnostics[ns.DataValidationField(index)] = nil
		end
	end
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
