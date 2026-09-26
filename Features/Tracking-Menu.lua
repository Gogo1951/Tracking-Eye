local ADDON_NAME, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local LibUIDropDownMenu = LibStub("LibUIDropDownMenu-4.0")

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local dropdown = LibUIDropDownMenu:Create_UIDropDownMenu(ADDON_NAME .. "TrackingMenu", UIParent)

--[[
    Larger font for the menu. LibUIDropDownMenu only honours info.fontObject on enabled
    buttons, so both the title and the ability rows are rendered as enabled
    (non-functional) entries to pick this up. Text colour comes from the inline
    colour codes already embedded in the button text.
]]
local menuFont = CreateFont(ADDON_NAME .. "TrackingMenuFont")
do
	local file, _, flags = _G.GameFontHighlightSmallLeft:GetFont()
	menuFont:SetFont(file, 14, flags)
	menuFont:SetJustifyH("LEFT")
end

local function AddSpacer(level)
	local spacer = LibUIDropDownMenu:UIDropDownMenu_CreateInfo()
	spacer.text = ""
	spacer.notClickable = true
	spacer.notCheckable = true
	LibUIDropDownMenu:UIDropDownMenu_AddButton(spacer, level)
end

--------------------------------------------------------------------------------
-- Menu Logic
--------------------------------------------------------------------------------

local function InitMenu(_, level)
	if level ~= 1 then
		return
	end

	--[[
	    Rendered as an enabled (but func-less) button: LibUIDropDownMenu ignores fontObject on
	    disabled/isTitle rows, so this is the only way to enlarge the title font.
	]]
	local titleInfo = LibUIDropDownMenu:UIDropDownMenu_CreateInfo()
	titleInfo.text = GetColor("TITLE") .. L["TRACKING_MENU"] .. "|r"
	titleInfo.notCheckable = true
	titleInfo.fontObject = menuFont
	LibUIDropDownMenu:UIDropDownMenu_AddButton(titleInfo, level)

	AddSpacer(level)

	local list = {}
	for _, id in ipairs(ns.TRACKING_IDS) do
		local name = C_Spell.GetSpellName(id)
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
		if IsPlayerSpell(data.id) and (not ns.CAT_FORM_ONLY[data.id] or isCat) then
			if addedAbility then
				AddSpacer(level)
			end
			addedAbility = true

			local info = LibUIDropDownMenu:UIDropDownMenu_CreateInfo()
			info.text = string.format("|T%s:16|t %s", C_Spell.GetSpellTexture(data.id) or "", data.name)
			info.fontObject = menuFont
			info.value = data.id
			info.checked = (ns.db and ns.db.profile.selectedSpellId == data.id)
			info.func = function(button)
				-- The player's own pick ends any hunt and becomes the Persistent Tracking Ability.
				ns.EndHunt(false)
				if ns.db then
					ns.db.profile.selectedSpellId = button.value
					-- The cycle can include this ability, so the cache is now stale.
					ns.InvalidateFarmCache()
				end
				ns.state.wasFarming = false
				ns.CastTracking(button.value)
				LibUIDropDownMenu:CloseDropDownMenus()
			end
			LibUIDropDownMenu:UIDropDownMenu_AddButton(info, level)
		end
	end
end

LibUIDropDownMenu:UIDropDownMenu_Initialize(dropdown, InitMenu, "MENU")

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

function ns.ToggleMenu(anchor)
	local xOffset = 0
	if anchor and anchor.GetWidth then
		xOffset = anchor:GetWidth()
	end
	LibUIDropDownMenu:ToggleDropDownMenu(1, nil, dropdown, anchor, xOffset, 0)
end

--------------------------------------------------------------------------------
-- Blizzard Tracking Button Hook
--------------------------------------------------------------------------------

--[[
    Optional take-over of Classic Era's mini-map tracking icon, which has no menu
    of its own: a right-click there cancels tracking, and the take-over replaces
    that. On TBC Anniversary and MoP Classic the icon is a Blizzard dropdown button
    that opens Blizzard's tracking menu on mouse-down, which no script swap can
    stop, so it is left alone and the option doesn't show. Off by default: it
    reaches into a frame the add-on does not own, and some UIs already bind it.

    Take-over rather than HookScript, because a hook would leave Blizzard's handler
    running. The original is saved so turning the option off puts the frame back
    exactly as found. The frame is neither secure nor protected, so replacing its
    script raises no taint.
]]
local blizzardHooked = false
local blizzardSavedHandler = nil

local function GetBlizzardTrackingButton()
	if MiniMapTrackingButton then
		return nil
	end
	return MiniMapTracking
end

function ns.HasBlizzardTrackingButton()
	return GetBlizzardTrackingButton() ~= nil
end

function ns.ApplyBlizzardTrackingHook()
	local button = GetBlizzardTrackingButton()
	if not button or not button.SetScript then
		return
	end

	local enabled = ns.db and ns.db.global.hookBlizzardTracking or false

	if enabled and not blizzardHooked then
		blizzardHooked = true
		blizzardSavedHandler = button:GetScript("OnMouseUp")
		button:SetScript("OnMouseUp", function()
			ns.ToggleMenu(button)
		end)
	elseif not enabled and blizzardHooked then
		button:SetScript("OnMouseUp", blizzardSavedHandler)
		blizzardHooked = false
		blizzardSavedHandler = nil
	end
end
