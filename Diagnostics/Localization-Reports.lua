local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys
local D = ns.DiagnosticsStrings

--------------------------------------------------------------------------------
-- Locale Context
--------------------------------------------------------------------------------

function ns:BuildLocaleContextReport()
	local lines = { GetClientHeader(), "" }
	lines[#lines + 1] = string.format("GetLocale: %s", tostring(GetLocale()))
	lines[#lines + 1] = string.format("textLocale CVar: %s", tostring(GetCVar("textLocale")))
	lines[#lines + 1] = string.format("audioLocale CVar: %s", tostring(GetCVar("audioLocale")))
	lines[#lines + 1] = string.format("Locale keys (ns.L): %d", CountKeys(ns.L))
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

--[[
    One line per ns.DIAGNOSTIC_NAME_LOOKUPS row: the name this client returns
    through the row's own lookup, or NIL. A row with a request function names
    something that loads late, so the report asks for it and polls with
    Validate Data's cadence before settling it as NIL. Every timer carries the
    run's generation, so Stop retires the chain.
]]
local NAME_POLL_SECONDS = 0.5
local NAME_REASK_POLLS = 3
local NAME_MAX_IDLE_POLLS = 12

local nameRun = { generation = 0 }

-- The row's name, or nil and the message when its lookup throws.
local function ReadName(row)
	local ok, name = pcall(row.lookup)
	if not ok then
		return nil, tostring(name)
	end
	if name == nil or tostring(name) == "" then
		return nil, nil
	end
	return tostring(name), nil
end

-- Line breaks shown as a literal \n, and pipes escaped so links paste as text.
local function ShownText(text)
	local shown = text:gsub("\r?\n", "\\n")
	shown = shown:gsub("|", "||")
	return shown
end

local function PendingRows()
	local pending = {}
	for _, row in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS) do
		if row.request and not ReadName(row) then
			pending[#pending + 1] = row
		end
	end
	return pending
end

local function RequestRows(rows)
	for _, row in ipairs(rows) do
		pcall(row.request)
	end
end

local function FinishNames(run)
	local lines = { GetClientHeader(), "" }
	local missing = 0
	for _, row in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS) do
		local name, problem = ReadName(row)
		if not name then
			missing = missing + 1
		end
		lines[#lines + 1] = string.format(
			"[%s] %s (%s %s): %s",
			name and "OK" or "NIL",
			row.constant,
			row.kind,
			tostring(row.id),
			ShownText(name or problem or "")
		)
	end
	local onFinish = run.onFinish
	run.onFinish = nil
	if onFinish then
		onFinish(
			table.concat(lines, "\n"),
			missing == 0 and D.NAMES_ALL_FOUND or string.format(D.NAMES_SOME_NIL, missing)
		)
	end
end

local function ScheduleNames(run, delay, step)
	local generation = run.generation
	C_Timer.After(delay, function()
		if run.generation ~= generation then
			return
		end
		local ok, problem = pcall(step, run)
		if not ok then
			local onFinish = run.onFinish
			run.onFinish = nil
			run.generation = run.generation + 1
			if onFinish then
				onFinish(nil, nil, tostring(problem))
			end
		end
	end)
end

local function PollNames(run)
	local pending = PendingRows()
	if #pending == 0 then
		FinishNames(run)
		return
	end
	if #pending < run.pendingCount then
		run.pendingCount = #pending
		run.idlePolls = 0
	else
		run.idlePolls = run.idlePolls + 1
	end
	if run.idlePolls >= NAME_MAX_IDLE_POLLS then
		FinishNames(run)
		return
	end
	if run.idlePolls > 0 and run.idlePolls % NAME_REASK_POLLS == 0 then
		RequestRows(pending)
	end
	ScheduleNames(run, NAME_POLL_SECONDS, PollNames)
end

--[[
    onFinish(text, note) receives the finished report and its status note, or
    onFinish(nil, nil, problem) when a step threw. A stopped run never calls it.
]]
function ns:StartNameLookupReport(onFinish)
	nameRun.generation = nameRun.generation + 1
	nameRun.onFinish = onFinish
	nameRun.idlePolls = 0
	local pending = PendingRows()
	nameRun.pendingCount = #pending
	if #pending == 0 then
		ScheduleNames(nameRun, 0, FinishNames)
		return
	end
	RequestRows(pending)
	ScheduleNames(nameRun, NAME_POLL_SECONDS, PollNames)
end

function ns:StopNameLookupReport()
	nameRun.generation = nameRun.generation + 1
	nameRun.onFinish = nil
end

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

-- The callouts Come & Get It drafts (Come-and-Get-It.lua), by locale key.
local CALLOUT_KEYS = {
	"MSG_FORMAT_HERB",
	"MSG_FORMAT_MINE",
	"MSG_FORMAT_LOCKED",
}

-- Past every map id any supported client ships; an id with no map answers nil.
local MAP_ID_SCAN_LIMIT = 5000

-- The widest coordinate the callout can print, as Come & Get It formats it.
local WIDEST_COORDINATE = "100"

--[[
    The longest name any map on this client carries, in bytes, and its id. The
    callout names whichever map C_Map.GetBestMapForUnit picks, so any of them
    can be the one.
]]
local function LongestMapName()
	local longest, longestID = "", nil
	for mapID = 1, MAP_ID_SCAN_LIMIT do
		local ok, info = pcall(C_Map.GetMapInfo, mapID)
		local name = ok and type(info) == "table" and info.name
		if type(name) == "string" and #name > #longest then
			longest, longestID = name, mapID
		end
	end
	return longestID, longest
end

--[[
    Each callout built through ns:BuildAnnounceMessage with the longest map name
    and the widest coordinates, and an empty node name, since the node's name
    comes off the game's tooltip rather than the add-on's data. Prints its byte
    length against the chat limit and the bytes left for the node's name; OVER
    when the callout is past the limit before any node is named. Builds strings
    only: nothing is sent and no chat box opens.
]]
function ns:BuildMessageLengthReport()
	local lines = { GetClientHeader(), "" }
	local mapID, mapName = LongestMapName()
	if not mapID then
		lines[#lines + 1] = "No map names on this client: C_Map.GetMapInfo answered nothing."
		return table.concat(lines, "\n")
	end
	lines[#lines + 1] = string.format("Longest map name: %s (map %d, %d bytes)", mapName, mapID, #mapName)
	lines[#lines + 1] = string.format("Chat limit: %d bytes", ns.CHAT_MESSAGE_MAX_LENGTH)
	lines[#lines + 1] = ""
	for _, key in ipairs(CALLOUT_KEYS) do
		local message = ns:BuildAnnounceMessage(key, "", WIDEST_COORDINATE, WIDEST_COORDINATE, mapName)
		if not message then
			lines[#lines + 1] = string.format("[NIL] %s: no such locale string", key)
		else
			local room = ns.CHAT_MESSAGE_MAX_LENGTH - #message
			lines[#lines + 1] = string.format(
				"[%s] %s: %d bytes before the node's name, %d left for it",
				room < 0 and "OVER" or "OK",
				key,
				#message,
				math.max(room, 0)
			)
			lines[#lines + 1] = "    " .. ShownText(message)
		end
	end
	return table.concat(lines, "\n")
end
