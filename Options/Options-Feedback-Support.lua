local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Feedback & Support Panel
--------------------------------------------------------------------------------

local PARAGRAPHS = {
	"OPTIONS_LEVEL_UP_INTRO",
	"OPTIONS_LEVEL_UP_WAYS",
	"OPTIONS_LEVEL_UP_FEEDBACK",
	"OPTIONS_LEVEL_UP_FRIEND",
	"OPTIONS_LEVEL_UP_CURSEFORGE",
	"OPTIONS_LEVEL_UP_GITHUB",
	"OPTIONS_LEVEL_UP_THANKS",
}

-- { captionKey, linkKey }, in display order
local LINKS = {
	{ "OPTIONS_DISCORD", "DISCORD" },
	{ "OPTIONS_CURSEFORGE", "CURSEFORGE" },
	{ "OPTIONS_WAGO", "WAGO" },
	{ "OPTIONS_GITHUB", "GITHUB" },
}

-- The caption is one short word and the box holds a full URL, so the label takes less than the default width.
local LINK_LABEL_WIDTH = 0.6

function ns.BuildFeedbackSupportOptions()
	local args = {}
	local order = 1

	for index, key in ipairs(PARAGRAPHS) do
		if index > 1 then
			args["spaceParagraph" .. index] = ns.OptionsSpacer(order)
			order = order + 1
		end
		args["descParagraph" .. index] = ns.OptionsDesc(L[key], order)
		order = order + 1
	end

	args.spaceLinks0 = ns.OptionsSpacer(order)
	args.headerLinks = ns.OptionsHeader(L["OPTIONS_FEEDBACK_LINKS_HEADER"], order + 1)
	args.spaceLinks1 = ns.OptionsSpacer(order + 2)
	order = order + 3

	for index, link in ipairs(LINKS) do
		local captionKey, linkKey = link[1], link[2]
		if index > 1 then
			args["spaceLink" .. index] = ns.OptionsSpacer(order)
			order = order + 1
		end
		args["label" .. linkKey] =
			ns.OptionsRowLabel(GetColor("TITLE") .. L[captionKey] .. "|r", order, LINK_LABEL_WIDTH)
		args["url" .. linkKey] = {
			type = "input",
			name = "",
			order = order + 1,
			width = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH,
			get = function()
				return ns.LINKS[linkKey]
			end,
			set = function() end,
		}
		order = order + 2
	end

	args.spaceCopyLink = ns.OptionsSpacer(order)
	args.descCopyLink = ns.OptionsDesc(GetColor("HELP") .. L["OPTIONS_COPY_LINK"] .. "|r", order + 1)

	args.spaceVersion = {
		type = "description",
		name = " ",
		width = "full",
		order = 998,
	}
	args.versionLine = ns.OptionsDesc(GetColor("INFO") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r", 999)

	return {
		name = L["OPTIONS_LEVEL_UP_TITLE"],
		type = "group",
		args = args,
	}
end
