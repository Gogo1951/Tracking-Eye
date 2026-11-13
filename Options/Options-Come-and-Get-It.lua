local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local RowLabel = ns.OptionsRowLabel
local format = string.format
local floor = math.floor

--------------------------------------------------------------------------------
-- Output Channel Dropdown
--------------------------------------------------------------------------------

-- Derived from the OUTPUT_CHANNELS manifest (Data.lua); labels resolved once at load.
local OUTPUT_VALUES = {}
local OUTPUT_SORTING = {}
for index, channel in ipairs(ns.OUTPUT_CHANNELS) do
	OUTPUT_VALUES[channel.key] = channel.labelGlobal and _G[channel.labelGlobal] or L[channel.labelKey]
	OUTPUT_SORTING[index] = channel.key
end

--[[
    Enable Come & Get It is the panel's master switch, as Enable Farm Mode is on
    its page: everything below it hides outright while it is off.
]]
local function ComeAndGetItOff()
	return not (ns.db and ns.db.global.comeAndGetIt)
end

local function ComeAndGetItSpacer(order)
	return { type = "description", name = " ", order = order, hidden = ComeAndGetItOff }
end

--------------------------------------------------------------------------------
-- Example Line
--------------------------------------------------------------------------------

local CHANNEL_BY_KEY = {}
for _, channel in ipairs(ns.OUTPUT_CHANNELS) do
	CHANNEL_BY_KEY[channel.key] = channel
end

local function ChatColor(channel)
	local info = ChatTypeInfo and ChatTypeInfo[channel.chatType]
	if info and info.r then
		return format(
			"|cff%02x%02x%02x",
			floor(info.r * 255 + 0.5),
			floor(info.g * 255 + 0.5),
			floor(info.b * 255 + 0.5)
		)
	end
	return "|cff" .. channel.hex
end

-- Listens only while the sample herb is loading, then redraws the panel with its name.
local itemLoadFrame = CreateFrame("Frame")
itemLoadFrame:SetScript("OnEvent", function(self, _, itemID)
	if itemID == ns.SAMPLE_HERB_ITEM_ID then
		self:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
		LibStub("AceConfigRegistry-3.0"):NotifyChange(ns.OPTIONS_REGISTRY.ComeAndGetIt)
	end
end)

--[[
    Draws the herb draft as it would land in the picked channel: the player's
    class-colored name, the channel's own prefix and chat color, and a body
    built by the same BuildAnnounceMessage the live draft uses. The herb and
    zone names come from the client by ID; an uncached herb shows its ID until
    the item loads and the panel redraws.
]]
local function RenderExample()
	local channelKey = ns.db and ns.db.global.comeAndGetItOutput
	local channel = CHANNEL_BY_KEY[channelKey] or CHANNEL_BY_KEY[ns.DEFAULT_OUTPUT_CHANNEL]

	local herbName = C_Item.GetItemNameByID(ns.SAMPLE_HERB_ITEM_ID)
	if not herbName then
		itemLoadFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
		C_Item.RequestLoadItemDataByID(ns.SAMPLE_HERB_ITEM_ID)
		herbName = L["SAMPLE_LOADING_ITEM"]:format(ns.SAMPLE_HERB_ITEM_ID)
	end
	local mapID = C_Map.GetBestMapForUnit("player")
	local mapInfo = mapID and C_Map.GetMapInfo(mapID)
	local zoneName = (mapInfo and mapInfo.name) or GetZoneText()
	local body = ns:BuildAnnounceMessage("MSG_FORMAT_HERB", herbName, "45", "62", zoneName) or ""

	local _, classToken = UnitClass("player")
	local classHex = ns.CLASS_COLORS[classToken]
	local name = GetUnitName("player") or ""
	local sender = "[" .. (classHex and ("|cff" .. classHex .. name .. "|r") or name) .. "]"

	local color = ChatColor(channel)
	local prefix
	local prefixFormat = channel.prefixGlobal and _G[channel.prefixGlobal]
	if prefixFormat then
		prefix = prefixFormat:format(sender .. color)
	else
		local _, channelName = GetChannelName(1)
		prefix = "[1. " .. (channelName or L["OPTIONS_OUTPUT_CHANNEL1"]) .. "] " .. sender .. color .. ": "
	end

	local line = color .. prefix .. body .. "|r"
	return GetColor("HELP") .. L["SAMPLE_EXAMPLE"]:format(line .. GetColor("HELP")) .. "|r"
end

--------------------------------------------------------------------------------
-- Come & Get It Panel
--------------------------------------------------------------------------------

--[[
    No /command section, welcome toggle, or Feedback & Support links here:
    Tracking Eye shows those once for the whole add-on.
]]
function ns.BuildComeAndGetItOptions()
	return {
		type = "group",
		name = L["TAB_COME_AND_GET_IT"],
		args = {
			descComeAndGetIt = ns.OptionsDesc(L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"], 1),
			spaceComeAndGetIt = ns.OptionsSpacer(2),
			enableComeAndGetIt = {
				type = "toggle",
				name = L["OPTIONS_ENABLE_COME_AND_GET_IT"],
				desc = L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"],
				order = 3,
				width = "full",
				get = function()
					return ns.db and ns.db.global.comeAndGetIt
				end,
				set = function(_, value)
					if ns.db then
						ns.db.global.comeAndGetIt = value
					end
				end,
			},

			spaceOutput = ComeAndGetItSpacer(4),
			-- An unnamed inline group, so the label and its dropdown hide as one row, laid out like Cycle Speed.
			outputRow = {
				type = "group",
				name = "",
				inline = true,
				order = 5,
				hidden = ComeAndGetItOff,
				args = {
					label = RowLabel(L["OPTIONS_OUTPUT_NAME"], 1),
					outputChannel = {
						type = "select",
						name = "",
						desc = L["OPTIONS_OUTPUT_DESCRIPTION"],
						style = "dropdown",
						width = ns.OPTIONS_CONTROL_WIDTH,
						order = 2,
						values = OUTPUT_VALUES,
						sorting = OUTPUT_SORTING,
						get = function()
							local channelKey = ns.db and ns.db.global.comeAndGetItOutput
							-- A stale saved key renders the dropdown blank, so show the default the draft falls back to.
							return OUTPUT_VALUES[channelKey] and channelKey or ns.DEFAULT_OUTPUT_CHANNEL
						end,
						set = function(_, value)
							if ns.db then
								ns.db.global.comeAndGetItOutput = value
							end
						end,
					},
				},
			},
			--[[
				On the panel rather than in the tooltip, by exception (README-Notes →
				Exceptions): the layer limit decides whether a callout reaches anyone,
				so it has to be seen before the channel is picked. The tooltip carries
				a different tip, so the two never say the same thing.
			]]
			noteOutput = {
				type = "description",
				name = GetColor("HELP") .. L["OPTIONS_OUTPUT_NOTE"]:format(L["OPTIONS_OUTPUT_CHANNEL1"]) .. "|r",
				fontSize = "medium",
				order = 6,
				hidden = ComeAndGetItOff,
			},
			exampleOutput = {
				type = "description",
				name = RenderExample,
				fontSize = "medium",
				order = 7,
				hidden = ComeAndGetItOff,
			},
		},
	}
end
