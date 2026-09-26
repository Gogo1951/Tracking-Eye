local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local RowLabel = ns.OptionsRowLabel

--------------------------------------------------------------------------------
-- Output Channel Dropdown
--------------------------------------------------------------------------------

-- Derived from the OUTPUT_CHANNELS manifest (Data.lua); labels resolved once at load.
local OUTPUT_VALUES = {}
local OUTPUT_SORTING = {}
for index, channel in ipairs(ns.OUTPUT_CHANNELS) do
	OUTPUT_VALUES[channel.key] = L[channel.labelKey]
	OUTPUT_SORTING[index] = channel.key
end

--[[
    Enable Come & Get It is the panel's master switch, as Enable Farm Mode is on
    its page: everything below it hides outright while it is off.
]]
local function ComeAndGetItOff()
	return not (ns.db and ns.db.profile.comeAndGetIt)
end

local function ComeAndGetItSpacer(order)
	return { type = "description", name = " ", order = order, hidden = ComeAndGetItOff }
end

--------------------------------------------------------------------------------
-- Come & Get It Panel
--------------------------------------------------------------------------------

--[[
    The standalone add-on's options, less what Tracking Eye already carries for
    the whole add-on: the /command section, the welcome message, and the
    Feedback & Support links.
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
					return ns.db and ns.db.profile.comeAndGetIt
				end,
				set = function(_, value)
					if ns.db then
						ns.db.profile.comeAndGetIt = value
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
							local channelKey = ns.db and ns.db.profile.comeAndGetItOutput
							-- A stale saved key renders the dropdown blank, so show the default the draft falls back to.
							return OUTPUT_VALUES[channelKey] and channelKey or ns.DEFAULT_OUTPUT_CHANNEL
						end,
						set = function(_, value)
							if ns.db then
								ns.db.profile.comeAndGetItOutput = value
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
				name = GetColor("HELP") .. L["OPTIONS_OUTPUT_NOTE"] .. "|r",
				fontSize = "medium",
				order = 6,
				hidden = ComeAndGetItOff,
			},
		},
	}
end
