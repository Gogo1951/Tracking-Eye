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
ns.diagnostics = ns.diagnostics or {enabled = false, logging = false, log = nil}

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
    TOOLS_ETRACE = "Live event tracing: use %s."
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
        L["ADDON_TITLE"], ns.Version, version, build, tocVersion,
        GetLocale(), tostring(WOW_PROJECT_ID)
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
    Firehose events flood the log in milliseconds and bury the signal, so the
    logger skips them. Tracking Eye registers none of these today, but the set is
    kept as a defensive default; tailor it if a high-frequency event is ever
    added to Core's event list. The log only ever sees events routed through
    Core's central dispatcher.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {
    COMBAT_LOG_EVENT_UNFILTERED = true,
    UNIT_AURA = true
}

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
    local lines = {GetClientHeader(), ""}
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
    local lines = {GetClientHeader(), ""}
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
    -- { label, testFunction }
    {"C_AddOns.GetAddOnMetadata", function() return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function" end},
    {"GetAddOnMetadata (legacy)", function() return type(GetAddOnMetadata) == "function" end},
    {"GetTrackingTexture", function() return type(GetTrackingTexture) == "function" end},
    {"CancelTrackingBuff", function() return type(CancelTrackingBuff) == "function" end},
    {"CastSpellByID", function() return type(CastSpellByID) == "function" end},
    {"IsPlayerSpell", function() return type(IsPlayerSpell) == "function" end},
    {"GetSpellInfo", function() return type(GetSpellInfo) == "function" end},
    {"GetSpellTexture", function() return type(GetSpellTexture) == "function" end},
    {"GetSpellCooldown", function() return type(GetSpellCooldown) == "function" end},
    {"UnitBuff", function() return type(UnitBuff) == "function" end},
    {"UnitCastingInfo", function() return type(UnitCastingInfo) == "function" end},
    {"IsStealthed", function() return type(IsStealthed) == "function" end},
    {"IsMounted", function() return type(IsMounted) == "function" end},
    {"UnitOnTaxi", function() return type(UnitOnTaxi) == "function" end},
    {"UnitAffectingCombat", function() return type(UnitAffectingCombat) == "function" end},
    {"UnitIsDeadOrGhost", function() return type(UnitIsDeadOrGhost) == "function" end},
    {"UnitClass", function() return type(UnitClass) == "function" end},
    {"IsInInstance", function() return type(IsInInstance) == "function" end},
    {"IsResting", function() return type(IsResting) == "function" end},
    {"IsShiftKeyDown", function() return type(IsShiftKeyDown) == "function" end},
    {"C_Timer.After", function() return type(C_Timer) == "table" and type(C_Timer.After) == "function" end},
    {"C_Timer.NewTicker", function() return type(C_Timer) == "table" and type(C_Timer.NewTicker) == "function" end},
    {"Settings.OpenToCategory", function() return type(Settings) == "table" and type(Settings.OpenToCategory) == "function" end},
    {"Settings.GetCategory", function() return type(Settings) == "table" and type(Settings.GetCategory) == "function" end},
    {"InterfaceOptionsFrame_OpenToCategory (legacy)", function() return type(InterfaceOptionsFrame_OpenToCategory) == "function" end},
    {"C_EventUtils.IsEventValid", function() return type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function" end},
    {"MiniMapTrackingIcon (frame)", function() return type(MiniMapTrackingIcon) == "table" end}
}

function ns:RunApiChecks()
    local lines = {GetClientHeader(), ""}
    for _, check in ipairs(ns.DIAGNOSTIC_API_CHECKS) do
        local ok, result = pcall(check[2])
        lines[#lines + 1] = ((ok and result) and "[PASS] " or "[FAIL] ") .. check[1]
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
    local lines = {GetClientHeader(), ""}
    local _, class = UnitClass("player")
    lines[#lines + 1] = string.format("Class: %s // Level: %d", tostring(class), UnitLevel("player"))
    lines[#lines + 1] = ""
    for _, spellId in ipairs(ns.DIAGNOSTIC_SPELLS or {}) do
        local name = GetSpellInfo(spellId) or "?"
        lines[#lines + 1] = string.format("%d %s [%s]", spellId, name, IsPlayerSpell(spellId) and "known" or "not known")
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
    local lines = {GetClientHeader(), ""}
    local width, height = GetPhysicalScreenSize()
    lines[#lines + 1] = string.format("PhysicalScreenSize: %s x %s", tostring(width), tostring(height))
    lines[#lines + 1] = string.format("UIParent scale: %s", tostring(UIParent:GetScale()))
    lines[#lines + 1] = string.format("uiScale CVar: %s", tostring(GetCVar("uiScale")))
    lines[#lines + 1] = ""
    lines[#lines + 1] = string.format("freePlacement: %s", tostring(TrackingEyeDB and TrackingEyeDB.freePlacement))
    if TrackingEyeDB and type(TrackingEyeDB.freePos) == "table" then
        lines[#lines + 1] = string.format("freePos: x=%s y=%s", tostring(TrackingEyeDB.freePos.x), tostring(TrackingEyeDB.freePos.y))
    else
        lines[#lines + 1] = "freePos: (none)"
    end
    if ns.freeFrame then
        lines[#lines + 1] = string.format("freeFrame shown: %s // scale: %s", tostring(ns.freeFrame:IsShown()), tostring(ns.freeFrame:GetScale()))
    else
        lines[#lines + 1] = "freeFrame: (not created)"
    end
    if TrackingEyeDB and type(TrackingEyeDB.minimap) == "table" then
        lines[#lines + 1] = string.format("minimap.hide: %s // minimapPos: %s", tostring(TrackingEyeDB.minimap.hide), tostring(TrackingEyeDB.minimap.minimapPos))
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
    local lines = {GetClientHeader(), ""}
    local db = TrackingEyeCharDB or {}

    lines[#lines + 1] = string.format("farmMode (master): %s // interval: %s", tostring(db.farmMode), tostring(db.farmInterval))
    lines[#lines + 1] = string.format(
        "state toggles: mounted=%s travelForms=%s cheetah=%s ghostWolf=%s notMounted=%s",
        tostring(db.farmMounted), tostring(db.farmTravelForms), tostring(db.farmCheetah),
        tostring(db.farmGhostWolf), tostring(db.farmNotMounted)
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
        tostring(IsMounted()), tostring(UnitOnTaxi("player")),
        tostring(hasTravelForm), tostring(hasCheetah), tostring(hasGhostWolf)
    )

    local isCat, isFarming = ns.GetPlayerStates()
    lines[#lines + 1] = string.format("GetPlayerStates -> isCat=%s isFarming=%s", tostring(isCat), tostring(isFarming))
    lines[#lines + 1] = string.format("CanCast=%s IsRestrictedZone=%s", tostring(ns.CanCast()), tostring(ns.IsRestrictedZone()))
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
    local lines = {GetClientHeader(), ""}
    local getInfo = (C_AddOns and C_AddOns.GetAddOnInfo) or GetAddOnInfo
    local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    local count = (C_AddOns and C_AddOns.GetNumAddOns and C_AddOns.GetNumAddOns()) or GetNumAddOns()
    for index = 1, count do
        local name, _, _, loadable = getInfo(index)
        local version = getMeta(index, "Version") or "?"
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
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
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
    local lines = {GetClientHeader(), "", "TrackingEyeDB = {"}
    DumpTable(TrackingEyeDB or {}, "    ", 1, lines)
    lines[#lines + 1] = "}"
    lines[#lines + 1] = ""
    lines[#lines + 1] = "TrackingEyeCharDB = {"
    DumpTable(TrackingEyeCharDB or {}, "    ", 1, lines)
    lines[#lines + 1] = "}"
    return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Library Versions
--------------------------------------------------------------------------------

function ns:BuildLibraryReport()
    local lines = {GetClientHeader(), ""}
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
