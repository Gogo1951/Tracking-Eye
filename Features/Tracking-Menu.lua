local ADDON_NAME, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local LibDD = LibStub("LibUIDropDownMenu-4.0")

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------
local dropdown = LibDD:Create_UIDropDownMenu(ADDON_NAME .. "TrackingMenu", UIParent)

-- Larger font for the menu. LibDD only honours info.fontObject on enabled
-- buttons, so both the title and the ability rows are rendered as enabled
-- (non-functional) entries to pick this up. Text colour comes from the inline
-- colour codes already embedded in the button text.
local menuFont = CreateFont(ADDON_NAME .. "TrackingMenuFont")
do
	local file, _, flags = _G.GameFontHighlightSmallLeft:GetFont()
	menuFont:SetFont(file, 14, flags)
	menuFont:SetJustifyH("LEFT")
end

-- Add an empty, non-interactive row to create vertical spacing.
local function AddSpacer(level)
	local spacer = LibDD:UIDropDownMenu_CreateInfo()
	spacer.text = ""
	spacer.notClickable = true
	spacer.notCheckable = true
	LibDD:UIDropDownMenu_AddButton(spacer, level)
end

--------------------------------------------------------------------------------
-- Menu Logic
--------------------------------------------------------------------------------
local function InitMenu(_, level)
	if level ~= 1 then
		return
	end

	-- Rendered as an enabled (but func-less) button: LibDD ignores fontObject on
	-- disabled/isTitle rows, so this is the only way to enlarge the title font.
	local titleInfo = LibDD:UIDropDownMenu_CreateInfo()
	titleInfo.text = GetColor("TITLE") .. L["TRACKING_MENU"] .. "|r"
	titleInfo.notCheckable = true
	titleInfo.fontObject = menuFont
	LibDD:UIDropDownMenu_AddButton(titleInfo, level)

	-- Spacer under the title.
	AddSpacer(level)

	local list = {}
	for _, id in ipairs(ns.TRACKING_IDS) do
		local name = GetSpellInfo(id)
		if name then
			table.insert(list, { id = id, name = name })
		end
	end

	table.sort(list, function(a, b)
		return a.name < b.name
	end)

	local isCat = ns.GetPlayerStates()

	local addedAbility = false
	for _, data in ipairs(list) do
		-- Hide DRUID_HUMANOIDS unless the player is currently in cat form
		if IsPlayerSpell(data.id) and (data.id ~= ns.SPELLS.DRUID_HUMANOIDS or isCat) then
			-- Spacer row between abilities (not before the first one).
			if addedAbility then
				AddSpacer(level)
			end
			addedAbility = true

			local info = LibDD:UIDropDownMenu_CreateInfo()
			info.text = string.format("|T%s:16|t %s", GetSpellTexture(data.id) or "", data.name)
			info.fontObject = menuFont
			info.value = data.id
			info.checked = (ns.db and ns.db.profile.selectedSpellId == data.id)
			info.func = function(button)
				if ns.db then
					ns.db.profile.selectedSpellId = button.value
				end
				ns.state.wasFarming = false
				ns.CastTracking(button.value)
				LibDD:CloseDropDownMenus()
			end
			LibDD:UIDropDownMenu_AddButton(info, level)
		end
	end
end

LibDD:UIDropDownMenu_Initialize(dropdown, InitMenu, "MENU")

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------
function ns.ToggleMenu(anchor)
	local xOffset = 0
	if anchor and anchor.GetWidth then
		xOffset = anchor:GetWidth()
	end
	LibDD:ToggleDropDownMenu(1, nil, dropdown, anchor, xOffset, 0)
end
