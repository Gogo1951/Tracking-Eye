local _, ns = ...
local L = ns.L

local format = string.format

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

--[[
    Both globals here are demanded by WoW's binding system and exist nowhere else
    in the add-on: Bindings.xml can only call a global function, and a binding's
    display name must be a BINDING_NAME_<name> global matching the element's
    `name` attribute.

    The section players see in the Key Bindings list comes from the `category`
    attribute in Bindings.xml, not from a header global. Bindings.xml itself is
    auto-discovered from the add-on root and must never be listed in the TOC.
]]

BINDING_NAME_TRACKINGEYE_CYCLE_FARM_ABILITY = L["BINDING_CYCLE_FARM_ABILITY"]

-- ns.GetEmptyCycleKind -> the chat line that explains an empty cycle.
local EMPTY_CYCLE_MESSAGES = {
	none = "BINDING_NOTHING_TO_CYCLE",
	unlearned = "FARM_PAUSED_NOT_LEARNED",
	catForm = "FARM_PAUSED_CAT_FORM_NAMED",
}

function TrackingEye_CycleFarmAbility()
	if not ns.db then
		return
	end

	-- Deliberately not gated on farmMode: this is a manual control, usable with Farm Mode switched off.
	if ns.GetFarmCycleCount() == 0 then
		local kind = ns.GetEmptyCycleKind()
		local message = L[EMPTY_CYCLE_MESSAGES[kind]]
		if kind == "catForm" then
			message = message:format(ns.GetCatFormNames())
		end
		ns:PrintMessage(message)
		return
	end

	ns.AdvanceFarmCycle()
end

--------------------------------------------------------------------------------
-- Opening Key Bindings
--------------------------------------------------------------------------------

--[[
    The General panel's Set Key button. The clients disagree on how the game's
    Key Bindings list is reached, so the routes are tried in order, at click time
    rather than at load, since a Settings category can register after login:

      1. Settings.KEYBINDINGS_CATEGORY_ID, where the client names it outright.
      2. The Settings panel's own category list, searched for the category
         carrying the game's Key Bindings title (KEY_BINDINGS, or
         SETTINGS_KEYBINDINGS_LABEL where that's the one in use).
      3. The older standalone KeyBindingFrame, loaded on demand.

    The lookup is protected, because it walks Blizzard's own objects and a
    client that reshapes them should cost the player a chat line, not an error.
    When nothing works, the line says where to find the list by hand.
]]
local function FindKeyBindingsCategoryID()
	if Settings and Settings.KEYBINDINGS_CATEGORY_ID then
		return Settings.KEYBINDINGS_CATEGORY_ID
	end

	if not (SettingsPanel and SettingsPanel.GetCategoryList) then
		return nil
	end

	local ok, categoryId = pcall(function()
		local list = SettingsPanel:GetCategoryList()
		local categories = list and list.GetAllCategories and list:GetAllCategories()
		for _, category in ipairs(categories or {}) do
			local name = category.GetName and category:GetName()
			if name and (name == KEY_BINDINGS or name == SETTINGS_KEYBINDINGS_LABEL) and category.GetID then
				return category:GetID()
			end
		end
		return nil
	end)

	return ok and categoryId or nil
end

-- The fallback line names the menus by the client's own labels, so it matches what the player sees in every locale.
local KEY_BINDINGS_LABEL = SETTINGS_KEYBINDINGS_LABEL ~= nil and SETTINGS_KEYBINDINGS_LABEL or KEY_BINDINGS

function ns:OpenKeyBindings()
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_KEY_BINDINGS_IN_COMBAT"])
		return
	end

	local categoryId = FindKeyBindingsCategoryID()
	if categoryId and Settings and Settings.OpenToCategory then
		Settings.OpenToCategory(categoryId)
		return
	end

	if not KeyBindingFrame and type(KeyBindingFrame_LoadUI) == "function" then
		KeyBindingFrame_LoadUI()
	end
	if type(KeyBindingFrame) == "table" and type(ShowUIPanel) == "function" then
		ShowUIPanel(KeyBindingFrame)
		return
	end

	ns:PrintMessage(format(L["KEY_BINDINGS_LOCATION"], GAMEMENU_OPTIONS, KEY_BINDINGS_LABEL))
end
