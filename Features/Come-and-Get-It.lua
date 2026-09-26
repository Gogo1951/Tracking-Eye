local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Come & Get It
--------------------------------------------------------------------------------

--[[
    Right-click an herb you can't pick, a vein you can't mine, or a locked chest,
    and the error it raises becomes a chat draft naming the node and where it is.
    Nothing is ever sent: the draft opens in the chat box for the player to send
    or delete. Ported from the standalone Come & Get It add-on with its pipeline
    unchanged — gate, detect, compose, write — behind its own master toggle.
]]

local ANNOUNCE_COOLDOWN = ns.ANNOUNCE_COOLDOWN

--------------------------------------------------------------------------------
-- Performance Aliases
--------------------------------------------------------------------------------

-- Hot-path globals only; ChatFrameUtil.OpenChat runs once per cooldown window, so it stays unaliased.
local GetTime = GetTime
local IsInInstance = IsInInstance
local InCombatLockdown = InCombatLockdown
local format = string.format

local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetPlayerMapPosition = C_Map.GetPlayerMapPosition
local GetMapInfo = C_Map.GetMapInfo

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local lastAnnounceTime = 0

--------------------------------------------------------------------------------
-- Error Mapping
--------------------------------------------------------------------------------

--[[
    Two tables so the key kinds can never collide. Locked chests key on the
    error's GlobalStrings name. Herb and mine share one error with a
    "Requires <Skill>" body, so only the localized skill name separates them.
]]
local ERROR_STRING_MAPPING = {
	[ns.ERROR_STRING_LOCKED_CHEST] = { formatKey = "MSG_FORMAT_LOCKED" },
}

local SKILL_MAPPING = {
	[L["MATCH_HERB"]] = { formatKey = "MSG_FORMAT_HERB" },
	[L["MATCH_MINE"]] = { formatKey = "MSG_FORMAT_MINE" },
}

--[[
    Lowercased skill names, built once so the slow path never re-lowers
    constants. One MATCH_* string can hold several names, separated by
    semicolons, for a language whose clients don't all name the skill the
    same way.
]]
local LOWER_MATCH = {}
for names, mapping in pairs(SKILL_MAPPING) do
	for name in names:gmatch("[^;]+") do
		LOWER_MATCH[string.lower(name)] = mapping
	end
end

--------------------------------------------------------------------------------
-- Output Channels
--------------------------------------------------------------------------------

-- key -> slash command, derived once from the OUTPUT_CHANNELS manifest (Data.lua).
local OUTPUT_COMMAND = {}
for _, channel in ipairs(ns.OUTPUT_CHANNELS) do
	OUTPUT_COMMAND[channel.key] = channel.command
end

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

local function GetNodeName()
	if not GameTooltip:IsShown() then
		return nil
	end
	return GameTooltipTextLeft1:GetText()
end

--[[
    Bag lockboxes fire the same locked error as world chests. World nodes are
    never items, so an item on the tooltip means the trigger came from the bags.
    GameTooltip:GetItem ships on every supported client; TooltipUtil does not.
]]
local function TooltipShowsItem()
	local name, link = GameTooltip:GetItem()
	return name ~= nil or link ~= nil
end

--[[
    Shared with Diagnostics' noise filter (ns:SuppressUncorrelatedMessage), which
    must classify with this exact lookup; making it file-local silently breaks that.
]]
function ns.MatchError(messageID, message)
	-- Fast path: locked chests resolve to a known error string id.
	local stringId = messageID and GetGameMessageInfo(messageID)
	if stringId and ERROR_STRING_MAPPING[stringId] then
		return ERROR_STRING_MAPPING[stringId]
	end

	if not message then
		return nil
	end

	--[[
        ACCEPTED TRADEOFF: substring-scanning can fire on unrelated error text
        containing the skill word. Herb and mine share one error, so the error
        cannot pick between them and the skill name has to. Kept because
        word-boundary patterns break CJK locales and the risk is bounded --
        AnnounceNode never auto-sends.
    ]]
	local lowerMessage = string.lower(message)
	for lowerKey, mapping in pairs(LOWER_MATCH) do
		if string.find(lowerMessage, lowerKey, 1, true) then
			return mapping
		end
	end

	return nil
end

-- Runs before MatchError, so a suppressed error costs no string work.
local function CanAnnounce()
	if not (ns.db and ns.db.profile.comeAndGetIt) then
		return false
	end

	if IsInInstance() then
		return false
	end

	--[[
        INTENTIONAL, not a bug: ChatFrameUtil.OpenChat steals keyboard focus and
        breaks movement mid-fight. Drop the announcement rather than queue it --
        a stale callout after combat is noise, and the node re-fires its error on
        the next interaction. Do not replace this with a deferred-replay queue.
    ]]
	if InCombatLockdown() then
		return false
	end

	return GetTime() - lastAnnounceTime >= ANNOUNCE_COOLDOWN
end

--------------------------------------------------------------------------------
-- Announcement Logic
--------------------------------------------------------------------------------

local function AnnounceNode(mapping)
	local mapID = GetBestMapForUnit("player")
	if not mapID then
		return
	end

	local position = GetPlayerMapPosition(mapID, "player")
	if not position then
		return
	end

	-- An area the map can't resolve reports 0,0 rather than nil.
	if position.x == 0 and position.y == 0 then
		return
	end

	local mapInfo = GetMapInfo(mapID)
	if not mapInfo or not mapInfo.name then
		return
	end

	-- No fallback name: stay silent rather than announce a generic node. The miss is logged.
	local nodeName = GetNodeName()
	if not nodeName or nodeName == "" then
		return
	end

	if TooltipShowsItem() then
		return
	end

	-- The MSG_FORMAT_* strings are sent as-is: no raid marker, no add-on name prefix.
	local announcement = ns:BuildAnnounceMessage(
		mapping.formatKey,
		nodeName,
		format("%.0f", position.x * 100),
		format("%.0f", position.y * 100),
		mapInfo.name
	)
	if not announcement then
		return
	end

	-- Don't clobber a draft the user is already typing in any chat editbox.
	if ChatFrameUtil.GetActiveWindow() then
		return
	end

	-- User-configurable; falls back to the manifest default if the saved key is stale.
	local channelKey = ns.db and ns.db.profile.comeAndGetItOutput
	local command = OUTPUT_COMMAND[channelKey] or OUTPUT_COMMAND[ns.DEFAULT_OUTPUT_CHANNEL]

	local messageLength = #announcement
	if messageLength > ns.CHAT_MESSAGE_MAX_LENGTH then
		ns:PrintMessage(format(L["CHAT_TOO_LONG"], messageLength, ns.CHAT_MESSAGE_MAX_LENGTH))
	end

	ChatFrameUtil.OpenChat(command .. " " .. announcement, ChatFrame1)
	lastAnnounceTime = GetTime()
end

--------------------------------------------------------------------------------
-- Event Entry Point
--------------------------------------------------------------------------------

-- Called from Core's UI_ERROR_MESSAGE branch with the event's arguments.
function ns.OnUIErrorMessage(messageID, message)
	if not CanAnnounce() then
		return
	end

	local mapping = ns.MatchError(messageID, message)
	if mapping then
		-- Capture the tooltip read at match time; a nil entry is the read-missed signal.
		if ns.diagnostics and ns.diagnostics.logging then
			ns:LogEvent("GetNodeName", GetNodeName())
		end
		AnnounceNode(mapping)
	end
end
