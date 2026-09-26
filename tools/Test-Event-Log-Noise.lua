--[[
    Offline tests for the Diagnostics event log's noise filter (Build Reference →
    Event Log Noise). Dev-only: never listed in a TOC, and kept out of the release
    by .pkgmeta. Run from the add-on root: lua tools/Test-Event-Log-Noise.lua
]]

local LOCKED_ID = 1
local UNCORRELATED_ID = 2
local HERB_ID = 3

local MESSAGE_NAMES = {
	[LOCKED_ID] = "ERR_ITEM_LOCKED",
	[UNCORRELATED_ID] = "ERR_ABILITY_COOLDOWN",
	[HERB_ID] = "ERR_USE_LOCKED_WITH_SPELL_S",
}

local ns = {
	L = { MATCH_HERB = "Herbalism", MATCH_MINE = "Mining" },
	OUTPUT_CHANNELS = {},
	ANNOUNCE_COOLDOWN = 5,
	ERROR_STRING_LOCKED_CHEST = "ERR_ITEM_LOCKED",
	TRACKING_IDS = {},
}

-- Stubs for the WoW globals these tests reach; everything else falls through to Lua's own globals.
local sandbox = setmetatable({
	LibStub = function()
		return {
			NotifyChange = function() end,
		}
	end,
	C_Map = {},
	C_Spell = {},
	GetTime = function()
		return 0
	end,
	GetGameMessageInfo = function(messageID)
		return MESSAGE_NAMES[messageID]
	end,
}, { __index = _G })

for _, path in ipairs({ "Features/Come-and-Get-It.lua", "Features/Diagnostics.lua" }) do
	local chunk = assert(loadfile(path, "t", sandbox))
	chunk("TrackingEye", ns)
end

local failures = 0

local function Check(name, passed)
	print((passed and "PASS " or "FAIL ") .. name)
	if not passed then
		failures = failures + 1
	end
end

local function LogHas(text)
	for _, entry in ipairs(ns.diagnostics.log) do
		if entry:find(text, 1, true) then
			return true
		end
	end
	return false
end

ns:StartEventLog()
for _ = 1, 50 do
	ns:LogEvent("UI_ERROR_MESSAGE", UNCORRELATED_ID, "Ability is not ready yet.")
end
local rows, counted = 0, 0
for _, entry in pairs(ns.diagnostics.suppressed) do
	rows = rows + 1
	counted = counted + entry.count
end
Check("spam collapses to one counted row", #ns.diagnostics.log == 0 and rows == 1 and counted == 50)

ns:StartEventLog()
ns:LogEvent("UI_ERROR_MESSAGE", LOCKED_ID, "Item is locked.")
ns:LogEvent("UI_ERROR_MESSAGE", HERB_ID, "Requires Herbalism")
Check(
	"a correlated id still logs a full line",
	#ns.diagnostics.log == 2
		and LogHas("Item is locked.")
		and LogHas("Requires Herbalism")
		and next(ns.diagnostics.suppressed) == nil
)

ns:StartEventLog()
ns:LogEvent("UI_ERROR_MESSAGE", nil, "No id at all")
Check("an event with no id logs verbatim", #ns.diagnostics.log == 1 and LogHas("No id at all"))

if failures > 0 then
	os.exit(1)
end
