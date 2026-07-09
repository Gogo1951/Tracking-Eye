local ADDON_NAME, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local LibDD = LibStub("LibUIDropDownMenu-4.0")

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------
local dropdown = LibDD:Create_UIDropDownMenu(ADDON_NAME .. "TrackingMenu", UIParent)

--------------------------------------------------------------------------------
-- Menu Logic
--------------------------------------------------------------------------------
local function InitMenu(_, level)
	if level ~= 1 then
		return
	end

	local titleInfo = LibDD:UIDropDownMenu_CreateInfo()
	titleInfo.text = GetColor("TITLE") .. L["TRACKING_MENU"] .. "|r"
	titleInfo.isTitle = true
	titleInfo.notCheckable = true
	LibDD:UIDropDownMenu_AddButton(titleInfo, level)

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

	for _, data in ipairs(list) do
		-- Hide DRUID_HUMANOIDS unless the player is currently in cat form
		if IsPlayerSpell(data.id) and (data.id ~= ns.SPELLS.DRUID_HUMANOIDS or isCat) then
			local info = LibDD:UIDropDownMenu_CreateInfo()
			info.text = string.format("|T%s:16|t %s", GetSpellTexture(data.id) or "", data.name)
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
