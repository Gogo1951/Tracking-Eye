local _, ns = ...

local L = ns.L
local GetColor = ns.GetColor
local Header, Desc, Spacer = ns.OptionsHeader, ns.OptionsDesc, ns.OptionsSpacer
local RowLabel = ns.OptionsRowLabel
local SubRow, SubLabel = ns.OptionsSubRow, ns.OptionsSubLabel

-- Sized to its caption with slack; never the full row width. See ns.OptionsSubRow.
local SUB_TOGGLE_WIDTH = 3.2

--[[
    The Feedback & Support rows override the default half-and-half label/control
    split. Their labels are one short word each, so the standard
    ns.OPTIONS_LABEL_WIDTH leaves a wide gap after "Wago" and spends half the row
    on nothing, while the URL beside it — the part the player is there to copy —
    truncates mid-address. Giving the label only what a word needs and the rest to
    the input fits every URL but the longest, and the two still total
    ns.OPTIONS_ROW_WIDTH, so the rows end where every other row ends.
]]
local LINK_LABEL_WIDTH = 0.6
local LINK_URL_WIDTH = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH

local function NoBlizzardTrackingButton()
	return not (ns.HasBlizzardTrackingButton and ns.HasBlizzardTrackingButton())
end

local function PersistentOff()
	return not (ns.db and ns.db.profile.persistentTracking)
end

-- Find Fish is missing from some flavors' data (Classic Era), so its row never shows there.
local function FishingPoleRowHidden()
	return PersistentOff() or not ns.SPELLS.FISH
end

--[[
    A Persistent Tracking sub-option: an override for the ability Persistent
    Tracking keeps up, bound to one profile field and hidden with Persistent
    Tracking unless the row passes its own condition. A change applies at once,
    even mid-battleground, since the recast and the farm cycle's persistent entry
    both read the resolver.
]]
local function PersistentOverrideRow(order, field, name, desc, hidden)
	return SubRow(order, hidden or PersistentOff, {
		{
			type = "toggle",
			name = SubLabel(name),
			desc = desc,
			width = SUB_TOGGLE_WIDTH,
			get = function()
				return ns.db and ns.db.profile[field]
			end,
			set = function(_, value)
				if ns.db then
					ns.db.profile[field] = value
					ns.InvalidateFarmCache()
					ns.TryRecastPersistent()
				end
			end,
		},
	})
end

--[[
    A binding cannot be set from an AceConfig panel, so each row shows the key
    the player bound, or a muted Not Bound, and a Set Key button that opens the
    game's Key Bindings list through ns:OpenKeyBindings (Features/Key-Bindings.lua).
    The binding names come from Bindings.xml's name attributes; the captions are
    the same BINDING_* strings the Key Bindings list prints. Core repaints this
    panel on UPDATE_BINDINGS, when the player changes a key.
]]
local KEY_BINDINGS = {
	-- { bindingName, captionKey, descKey }
	{ "TRACKINGEYE_CYCLE_FARM_ABILITY", "BINDING_CYCLE_FARM_ABILITY", "OPTIONS_KEYBINDS_DESCRIPTION" },
}

local KEY_LABEL_WIDTH = 1.9
local KEY_STATUS_WIDTH = 0.85
local KEY_BUTTON_WIDTH = 0.55

local function GetBindingStatus(bindingName)
	local key = GetBindingKey(bindingName)
	if not key then
		return GetColor("MUTED") .. NOT_BOUND .. "|r"
	end
	local text = (GetBindingText and GetBindingText(key)) or key
	return GetColor("TEXT") .. text .. "|r"
end

-- Each binding is its row (caption, key, Set Key), its description under it, and a blank line before the next.
local function AddKeyBindingRows(args, startOrder)
	local order = startOrder

	for index, entry in ipairs(KEY_BINDINGS) do
		local bindingName, captionKey, descKey = entry[1], entry[2], entry[3]

		if index > 1 then
			args["spaceKeyBinding" .. index] = Spacer(order)
			order = order + 0.01
		end

		args["rowKeyBinding" .. index] = {
			type = "group",
			name = "",
			inline = true,
			order = order,
			args = {
				caption = RowLabel(GetColor("INFO") .. L[captionKey] .. "|r", 1, KEY_LABEL_WIDTH),
				status = {
					type = "description",
					name = function()
						return GetBindingStatus(bindingName)
					end,
					fontSize = "medium",
					width = KEY_STATUS_WIDTH,
					order = 2,
				},
				setKey = {
					type = "execute",
					name = L["OPTIONS_KEY_SET"],
					desc = L["OPTIONS_KEY_SET_DESCRIPTION"],
					width = KEY_BUTTON_WIDTH,
					order = 3,
					func = function()
						ns:OpenKeyBindings()
					end,
				},
			},
		}
		order = order + 0.01

		args["descKeyBinding" .. index] = Desc(GetColor("HELP") .. L[descKey] .. "|r", order)
		order = order + 0.01
	end
end

--------------------------------------------------------------------------------
-- General Options Panel
--------------------------------------------------------------------------------

function ns.BuildGeneralOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_DESCRIPTION"], 1),

		spaceWelcome0 = Spacer(2),
		enableWelcome = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_WELCOME"],
			desc = L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"],
			order = 3,
			width = "full",
			get = function()
				return ns.db and ns.db.global.showWelcome
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.showWelcome = value
				end
			end,
		},

		enableMinimap = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_MINIMAP"],
			desc = L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"],
			order = 3.5,
			width = "full",
			disabled = function()
				return ns.db and ns.db.global.freePlacement
			end,
			get = function()
				return not (ns.db and ns.db.global.minimap and ns.db.global.minimap.hide)
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.minimap.hide = not value
					ns.UpdatePlacement()
				end
			end,
		},

		-- Present only where the client has a Blizzard tracking button to take over.
		spaceTrackingMenu0 = Spacer(8.1, NoBlizzardTrackingButton),
		headerTrackingMenu = Header(L["TRACKING_MENU"], 8.2, NoBlizzardTrackingButton),
		spaceTrackingMenuHeader = Spacer(8.3, NoBlizzardTrackingButton),
		descTrackingMenu = {
			type = "description",
			name = L["OPTIONS_TRACKING_MENU_DESCRIPTION"],
			fontSize = "medium",
			order = 8.4,
			hidden = NoBlizzardTrackingButton,
		},
		spaceTrackingMenu1 = Spacer(8.5, NoBlizzardTrackingButton),
		hookBlizzardTracking = {
			type = "toggle",
			name = L["OPTIONS_HOOK_BLIZZARD"],
			desc = L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"],
			order = 8.6,
			width = "full",
			hidden = NoBlizzardTrackingButton,
			get = function()
				return ns.db and ns.db.global.hookBlizzardTracking
			end,
			set = function(_, value)
				if ns.db then
					ns.db.global.hookBlizzardTracking = value
					ns.ApplyBlizzardTrackingHook()
				end
			end,
		},

		spacePersistent0 = Spacer(9),
		headerPersistent = Header(L["PERSISTENT_TRACKING"], 10),
		spacePersistentHeader = Spacer(10.5),
		descPersistent = Desc(L["OPTIONS_PERSISTENT_DESCRIPTION"], 11),
		spacePersistent1 = Spacer(12),
		enablePersistent = {
			type = "toggle",
			name = L["OPTIONS_ENABLE_PERSISTENT"],
			desc = L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"],
			order = 13,
			width = "full",
			get = function()
				return ns.db and ns.db.profile.persistentTracking
			end,
			set = function(_, value)
				if ns.db then
					ns.db.profile.persistentTracking = value
				end
			end,
		},
		fishingPoleFishRow = PersistentOverrideRow(
			13.1,
			"fishingPoleFish",
			L["OPTIONS_FISHING_POLE_FISH_NAMED"]:format(ns.GetSpellNameText(ns.SPELLS.FISH), ns.GetFishingPoleName()),
			L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"],
			FishingPoleRowHidden
		),
		catFormHumanoidsRow = PersistentOverrideRow(
			13.2,
			"catFormHumanoids",
			L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"]:format(
				ns.GetClassNameText("DRUID"),
				ns.GetSpellNameText(ns.SPELLS.DRUID_HUMANOIDS),
				ns.GetSpellNameText(ns.SPELLS.CAT)
			),
			L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"]
		),
		battlegroundHumanoidsRow = PersistentOverrideRow(
			13.3,
			"battlegroundHumanoids",
			L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"]:format(
				ns.GetClassNameText("HUNTER"),
				ns.GetSpellNameText(ns.SPELLS.HUMANOIDS)
			),
			L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"]
		),

		spaceKeyBinds0 = Spacer(50),
		headerKeyBinds = Header(L["OPTIONS_KEYBINDS"], 51),
		spaceKeyBinds1 = Spacer(52),

		spaceCommands0 = Spacer(60),
		headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 61),
		spaceCommands1 = Spacer(62),
		descCommands = Desc(
			GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
			63
		),

		-- Feedback & Support (Discord, GitHub, CurseForge, Wago)
		spaceLinks0 = Spacer(69),
		headerLinks = Header(L["OPTIONS_LINKS"], 70),
		spaceLinks1 = Spacer(71),
		discordLabel = RowLabel(GetColor("TITLE") .. L["OPTIONS_DISCORD"] .. "|r", 72, LINK_LABEL_WIDTH),
		discordURL = {
			type = "input",
			name = "",
			order = 73,
			width = LINK_URL_WIDTH,
			get = function()
				return ns.DISCORD_URL
			end,
			set = function() end,
		},
		spaceLinks2 = Spacer(74),
		githubLabel = RowLabel(GetColor("TITLE") .. L["OPTIONS_GITHUB"] .. "|r", 75, LINK_LABEL_WIDTH),
		githubURL = {
			type = "input",
			name = "",
			order = 76,
			width = LINK_URL_WIDTH,
			get = function()
				return ns.GITHUB_URL
			end,
			set = function() end,
		},
		spaceLinks3 = Spacer(77),
		curseforgeLabel = RowLabel(GetColor("TITLE") .. L["OPTIONS_CURSEFORGE"] .. "|r", 78, LINK_LABEL_WIDTH),
		curseforgeURL = {
			type = "input",
			name = "",
			order = 79,
			width = LINK_URL_WIDTH,
			get = function()
				return ns.CURSEFORGE_URL
			end,
			set = function() end,
		},
		spaceLinks4 = Spacer(80),
		wagoLabel = RowLabel(GetColor("TITLE") .. L["OPTIONS_WAGO"] .. "|r", 81, LINK_LABEL_WIDTH),
		wagoURL = {
			type = "input",
			name = "",
			order = 82,
			width = LINK_URL_WIDTH,
			get = function()
				return ns.WAGO_URL
			end,
			set = function() end,
		},
		spaceVersion0 = {
			type = "description",
			name = " ",
			width = "full",
			order = 998,
		},
		versionLine = {
			type = "description",
			name = GetColor("MUTED") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r",
			fontSize = "medium",
			order = 999,
		},
	}

	--[[
		Target Tracking and Free Placement are small enough to live on this page:
		each owns its widgets in its own file and returns an args fragment, merged
		in here. Order values are unique across fragments, so the page renders the
		same regardless of merge sequence. Farm Mode is not among them — it carries
		enough controls to have earned its own child panel.
	]]
	AddKeyBindingRows(args, 53)

	for key, entry in pairs(ns.BuildTargetTrackingOptions()) do
		args[key] = entry
	end
	for key, entry in pairs(ns.BuildFreePlacementOptions()) do
		args[key] = entry
	end

	return {
		name = L["ADDON_TITLE"],
		type = "group",
		args = args,
	}
end
