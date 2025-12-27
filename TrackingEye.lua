local addonName = ...
local addonTitle = C_AddOns.GetAddOnMetadata(addonName, "Title")

--------------------------------------------------------------------------------
-- 1. Libraries & Constants
--------------------------------------------------------------------------------
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

local ICON_DEFAULT = "Interface\\Icons\\inv_misc_map_01"
local ICON_SIZE = 24
local FRAME_SIZE = 37
local FARM_INTERVAL = 4.0

local SPELL_FIND_FISH = 43308
local SPELL_FIND_HERBS = 2383
local SPELL_FIND_MINERALS = 2580
local SPELL_FIND_TREASURE = 2481
local SPELL_TRACK_HUMAN = 5225

local FORM_CAT = 768
local FORM_TRAVEL = 783
local FORM_AQUATIC = 1066
local FORM_FLIGHT = 33943
local FORM_SWIFT_FLIGHT = 40120

local TRACKING_SPELLS = {
	[SPELL_FIND_FISH] = "Find Fish",
	[SPELL_FIND_HERBS] = "Find Herbs",
	[SPELL_FIND_MINERALS] = "Find Minerals",
	[SPELL_FIND_TREASURE] = "Find Treasure",
	[1494] = "Track Beasts",
	[19878] = "Track Demons",
	[19879] = "Track Dragonkin",
	[19880] = "Track Elementals",
	[19882] = "Track Giants",
	[19885] = "Track Hidden",
	[19883] = "Track Humanoids",
	[SPELL_TRACK_HUMAN] = "Track Humanoids",
	[19884] = "Track Undead",
	[5500] = "Sense Demons",
	[5502] = "Sense Undead"
}

local FARM_CYCLE = {
	SPELL_FIND_FISH,
	SPELL_FIND_HERBS,
	SPELL_FIND_MINERALS,
	SPELL_FIND_TREASURE 
}

local COLOR_PREFIX = "|cff"
local C_TITLE = "FFD100"
local C_INFO = "00BBFF"
local C_BODY = "CCCCCC"
local C_TEXT = "FFFFFF"
local C_SUCCESS = "33CC33"
local C_DISABLED = "CC3333"
local C_SEP = "AAAAAA"
local C_MUTED = "808080"

local COLORS = {
	TITLE = COLOR_PREFIX .. C_TITLE,
	INFO = COLOR_PREFIX .. C_INFO,
	DESC = COLOR_PREFIX .. C_BODY,
	TEXT = COLOR_PREFIX .. C_TEXT,
	SUCCESS = COLOR_PREFIX .. C_SUCCESS,
	DISABLED = COLOR_PREFIX .. C_DISABLED,
	SEP = COLOR_PREFIX .. C_SEP,
	MUTED = COLOR_PREFIX .. C_MUTED
}

--------------------------------------------------------------------------------
-- 2. Variables & State
--------------------------------------------------------------------------------
local DB
local freeFrame
local ldbLauncher
local dropdown = CreateFrame("Frame", addonName .. "Dropdown", UIParent, "UIDropDownMenuTemplate")
local eventFrame = CreateFrame("Frame")

local state = {
	currentIcon = ICON_DEFAULT,
	retryPending = false,
	retryCount = 0,
	farmIndex = 0,
	wasFarming = false,
	cycleCache = {},
	shiftPending = false
}

--------------------------------------------------------------------------------
-- 3. Utility & Helpers
--------------------------------------------------------------------------------
local function HasAnyTrackingSpell()
	for id in pairs(TRACKING_SPELLS) do
		if id == SPELL_TRACK_HUMAN then
			if IsPlayerSpell(FORM_CAT) then
				return true
			end
		elseif IsPlayerSpell(id) then
			return true
		end
	end
	return false
end

local function HasBuff(spellID)
	for i = 1, 40 do
		local _, _, _, _, _, _, _, _, _, id = UnitBuff("player", i)
		if not id then
			break
		end
		if id == spellID then
			return true
		end
	end
	return false
end

local function IsCatForm()
	return HasBuff(FORM_CAT)
end

local function IsFarmingForm()
	if UnitOnTaxi("player") then
		return false
	end
	if IsMounted() then
		return true
	end
	if HasBuff(FORM_TRAVEL) then
		return true
	end
	if HasBuff(FORM_AQUATIC) then
		return true
	end
	if HasBuff(FORM_FLIGHT) then
		return true
	end
	if HasBuff(FORM_SWIFT_FLIGHT) then
		return true
	end
	return false
end

local function CanCast()
	return not (UnitIsDeadOrGhost("player") or IsStealthed() or UnitCastingInfo("player") or UnitAffectingCombat("player"))
end

--------------------------------------------------------------------------------
-- 4. Visual Updates
--------------------------------------------------------------------------------
local function UpdateIcon()
	local tex = ICON_DEFAULT
	if state.lastCastSpell == SPELL_TRACK_HUMAN and not IsCatForm() then
		state.lastCastSpell = nil
	end
	if state.lastCastSpell then
		tex = GetSpellTexture(state.lastCastSpell)
	elseif GetTrackingTexture() then
		tex = GetTrackingTexture()
	end
	if not tex then
		tex = ICON_DEFAULT
	end
	state.currentIcon = tex
	if ldbLauncher then
		ldbLauncher.icon = tex
	end
	if freeFrame and freeFrame.icon then
		freeFrame.icon:SetTexture(tex)
	end
end

local function UpdatePlacement()
	if not DB then
		return
	end
	if not ldbLauncher then
		return
	end
	if DB.freePlacement then
		if LDBIcon then
			LDBIcon:Hide(addonName)
		end
		if freeFrame then
			freeFrame:Show();
			UpdateIcon()
		end
	else
		if LDBIcon then
			LDBIcon:Show(addonName)
		end
		if freeFrame then
			freeFrame:Hide()
		end
	end
end

--------------------------------------------------------------------------------
-- 5. Tracking Logic
--------------------------------------------------------------------------------
local IsTrackingActive, CastTracking, ReapplyTracking

function IsTrackingActive(spellId)
	if not spellId then
		return false
	end
	if not state.lastCastSpell then
		return false
	end
	return state.lastCastSpell == spellId
end

function CastTracking(spellId)
	if not IsPlayerSpell(spellId) then
		return
	end
	if spellId == SPELL_TRACK_HUMAN and not IsCatForm() then
		return
	end
	if IsTrackingActive(spellId) then
		return
	end
	local start, duration = GetSpellCooldown(spellId)
	if start and duration and (start > 0 and duration > 1.5) then
		return
	end
	state.lastCastSpell = spellId
	UpdateIcon()
	pcall(CastSpellByID, spellId)
end

function ReapplyTracking(isAuto)
	if not DB then
		return
	end
	if state.shiftPending then
		return
	end
	if DB.farmingMode and IsFarmingForm() then
		return
	end
	if isAuto and not DB.autoTracking then
		return
	end
	local spellId = DB.selectedSpellId
	if not spellId or not CanCast() then
		return
	end
	if spellId == SPELL_TRACK_HUMAN and not IsCatForm() then
		return
	end
	if IsTrackingActive(spellId) then
		return
	end
	local start, duration = GetSpellCooldown(spellId)
	if start > 0 and duration > 0 then
		if not state.retryPending and state.retryCount < 5 then
			state.retryPending = true
			state.retryCount = state.retryCount + 1
			C_Timer.After((start + duration - GetTime()) + 0.1, function()
				state.retryPending = false
				ReapplyTracking(isAuto)
			end)
		end
		return
	end
	state.retryCount = 0
	CastTracking(spellId)
end

--------------------------------------------------------------------------------
-- 6. Farming Mode
--------------------------------------------------------------------------------
local function RunFarmLogic()
	if not DB then
		return
	end
	if state.shiftPending then
		return
	end
	local inForm = IsFarmingForm()
	if not inForm and state.wasFarming then
		state.wasFarming = false
		if DB.selectedSpellId and IsTrackingActive(DB.selectedSpellId) then
			return
		end
		ReapplyTracking(true)
		return
	end
	if not DB.farmingMode or not inForm then
		return
	end
	if not CanCast() then
		return
	end
	table.wipe(state.cycleCache)
	local seen = {}
	local function AddToCache(id)
		if not id or not IsPlayerSpell(id) or seen[id] then
			return
		end
		if id == SPELL_TRACK_HUMAN and not IsCatForm() then
			return
		end
		table.insert(state.cycleCache, id)
		seen[id] = true
	end
	if DB.selectedSpellId then
		AddToCache(DB.selectedSpellId)
	end
	for _, id in ipairs(FARM_CYCLE) do
		AddToCache(id)
	end
	if # state.cycleCache == 0 then
		return
	end
	state.farmIndex = state.farmIndex + 1
	if state.farmIndex > # state.cycleCache then
		state.farmIndex = 1
	end
	local spellToCast = state.cycleCache[state.farmIndex]
	if not IsTrackingActive(spellToCast) then
		CastTracking(spellToCast)
	end
	state.wasFarming = true
end

--------------------------------------------------------------------------------
-- 7. Interaction & Menus
--------------------------------------------------------------------------------
local function RefreshVisuals(self)
	UpdateIcon()
	if self and self.GetScript then
		local onEnter = self:GetScript("OnEnter")
		if onEnter and (MouseIsOver(self) or GameTooltip:GetOwner() == self) then
			GameTooltip:Hide()
			onEnter(self)
		end
	end
end

local function BuildTooltip(tooltip)
	local version = C_AddOns.GetAddOnMetadata(addonName, "Version") or "Dev"
	if version:find("@") then
		version = "Dev"
	end
	tooltip:AddDoubleLine(COLORS.TITLE .. addonTitle .. "|r", COLORS.MUTED .. version .. "|r")
	tooltip:AddLine(" ")
	local displayID = DB.selectedSpellId
	if displayID then
		local name = TRACKING_SPELLS[displayID] or "Unknown"
		local icon = GetSpellTexture(displayID)
		tooltip:AddLine("|T" .. (icon or "") .. ":16|t " .. COLORS.TEXT .. name .. "|r")
	else
		tooltip:AddLine("|TInterface\\Icons\\inv_misc_map_01:16|t " .. COLORS.DESC .. "No Tracking Selected|r")
	end
	tooltip:AddLine(" ")
	local auto = (DB and DB.autoTracking)
	local autoColor = auto and (COLORS.SUCCESS .. "Enabled|r") or (COLORS.DISABLED .. "Disabled|r")
	tooltip:AddDoubleLine(COLORS.TITLE .. "Persistent Tracking|r", autoColor)
	tooltip:AddLine(COLORS.DESC .. "Automatically recasts your tracking spell after resurrection.|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(COLORS.INFO .. "Shift + Left-Click|r", COLORS.INFO .. "Toggle|r")
	tooltip:AddLine(" ")
	local farm = (DB and DB.farmingMode)
	local farmColor = farm and (COLORS.SUCCESS .. "Enabled|r") or (COLORS.DISABLED .. "Disabled|r")
	tooltip:AddDoubleLine(COLORS.TITLE .. "Farming Mode|r", farmColor)
	tooltip:AddLine(COLORS.DESC .. "Cycles between Herbs, Minerals, and Treasure while mounted or in travel form.|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(COLORS.INFO .. "Shift + Right-Click|r", COLORS.INFO .. "Toggle|r")
	tooltip:AddLine(" ")
	local free = (DB and DB.freePlacement)
	local freeColor = free and (COLORS.SUCCESS .. "Enabled|r") or (COLORS.DISABLED .. "Disabled|r")
	tooltip:AddDoubleLine(COLORS.TITLE .. "Free Placement Mode|r", freeColor)
	tooltip:AddLine(COLORS.DESC .. "Replaces the minimap button with a standalone icon you can move anywhere.|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(COLORS.INFO .. "Middle-Click|r", COLORS.INFO .. "Toggle|r")
	tooltip:AddLine(" ")
	tooltip:AddDoubleLine(COLORS.INFO .. "Left-Click|r", COLORS.INFO .. "Tracking Menu|r")
	tooltip:AddLine(" ")
	tooltip:AddDoubleLine(COLORS.INFO .. "Right-Click|r", COLORS.INFO .. "Clear Persistent Tracking|r")
end

local function OnClick(self, button)
	if not DB then
		return
	end
	if button == "MiddleButton" then
		DB.freePlacement = not DB.freePlacement
		UpdatePlacement()
		GameTooltip:Hide()
	elseif IsShiftKeyDown() then
		if button == "LeftButton" then
			DB.autoTracking = not DB.autoTracking
		elseif button == "RightButton" then
			DB.farmingMode = not DB.farmingMode
		end
		RefreshVisuals(self)
	elseif button == "RightButton" then
		DB.selectedSpellId = nil
		state.lastCastSpell = nil
		CancelTrackingBuff()
		state.currentIcon = ICON_DEFAULT
		RefreshVisuals(self)
	elseif button == "LeftButton" then
		ToggleDropDownMenu(1, nil, dropdown, self, 0, 0)
	end
end

local function InitMenu(self, level)
	if level ~= 1 then
		return
	end
	local list = {}
	for id, name in pairs(TRACKING_SPELLS) do
		table.insert(list, {
			id = id,
			name = name
		})
	end
	table.sort(list, function(a, b)
		return a.name < b.name
	end)
	for _, data in ipairs(list) do
		local known = IsPlayerSpell(data.id)
		local usable, noMana = IsUsableSpell(data.id)
		local isUsableState = (usable or noMana)
		local druidCheck = (data.id ~= SPELL_TRACK_HUMAN or IsCatForm())
		if known and druidCheck then
			local info = UIDropDownMenu_CreateInfo()
			local icon = GetSpellTexture(data.id)
			info.text = string.format("|T%s:16|t %s", icon or "", data.name)
			info.value = data.id
			info.checked = (DB.selectedSpellId == data.id)
			info.func = function(btn)
				DB.selectedSpellId = btn.value
				state.wasFarming = false
				pcall(CastSpellByID, btn.value)
				state.lastCastSpell = btn.value
				state.currentIcon = GetSpellTexture(btn.value)
				RefreshVisuals(self)
				CloseDropDownMenus()
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

UIDropDownMenu_Initialize(dropdown, InitMenu, "MENU")

--------------------------------------------------------------------------------
-- 8. Initialization
--------------------------------------------------------------------------------
local function CreateFreeFrame()
	if not HasAnyTrackingSpell() then
		return
	end
	if freeFrame then
		return
	end
	local f = CreateFrame("Button", addonName .. "FreeFrame", UIParent)
	f:SetSize(FRAME_SIZE, FRAME_SIZE)
	f:SetMovable(true)
	f:EnableMouse(true)
	f:RegisterForDrag("LeftButton")
	f:RegisterForClicks("AnyUp")
	f:SetClampedToScreen(true)
	f:SetFrameStrata("HIGH")
	f.bg = f:CreateTexture(nil, "BACKGROUND")
	f.bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
	f.bg:SetSize(ICON_SIZE, ICON_SIZE)
	f.bg:SetPoint("CENTER")
	f.bg:SetVertexColor(0, 0, 0, 0.6)
	f.icon = f:CreateTexture(nil, "ARTWORK")
	f.icon:SetSize(ICON_SIZE, ICON_SIZE)
	f.icon:SetPoint("CENTER")
	f.icon:SetTexture(state.currentIcon or ICON_DEFAULT)
	local mask = f:CreateMaskTexture()
	mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask")
	mask:SetAllPoints(f.icon)
	f.icon:AddMaskTexture(mask)
	f.border = f:CreateTexture(nil, "OVERLAY")
	f.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	f.border:SetSize(62, 62)
	f.border:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	f:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-RoundedButton-Highlight")
	f:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	f:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point, _, relPoint, x, y = self:GetPoint()
		if DB then
			DB.freePos = {
				point,
				relPoint,
				x,
				y
			}
		end
	end)
	f:SetScript("OnClick", OnClick)
	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		BuildTooltip(GameTooltip)
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	if DB and DB.freePos then
		local p = DB.freePos
		f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
	else
		f:SetPoint("CENTER")
	end
	freeFrame = f
end

local function InitLDB()
	if not HasAnyTrackingSpell() then
		return
	end
	ldbLauncher = LDB:NewDataObject(addonName, {
		type = "launcher",
		text = addonTitle,
		icon = state.currentIcon,
		OnTooltipShow = function(tt)
			local b = LDBIcon:GetMinimapButton(addonName)
			if b then
				tt:SetOwner(b, "ANCHOR_NONE");
				tt:SetPoint("TOPRIGHT", b, "BOTTOMLEFT")
			end
			BuildTooltip(tt)
		end,
		OnClick = OnClick
	})
	LDBIcon:Register(addonName, ldbLauncher, DB.minimap)
end

--------------------------------------------------------------------------------
-- 9. Events
--------------------------------------------------------------------------------
local events = {}
local farmTicker = nil

local function ResetFarmCycle()
	if farmTicker then
		farmTicker:Cancel()
	end
	UpdateIcon()
	farmTicker = C_Timer.NewTicker(FARM_INTERVAL, RunFarmLogic)
end

function events.ADDON_LOADED(name)
	if name ~= addonName then
		return
	end
	_G[addonName .. "DB"] = _G[addonName .. "DB"] or {}
	DB = _G[addonName .. "DB"]
	DB.minimap = DB.minimap or {}
	if DB.autoTracking == nil then
		DB.autoTracking = true
	end
	if DB.farmingMode == nil then
		DB.farmingMode = true
	end
end

function events.PLAYER_LOGIN()
	InitLDB()
	CreateFreeFrame()
	C_Timer.NewTicker(0.5, UpdateIcon)
	farmTicker = C_Timer.NewTicker(FARM_INTERVAL, RunFarmLogic)
	UpdateIcon()
	UpdatePlacement()
end

function events.UNIT_SPELLCAST_SUCCEEDED(unit, _, spellId)
	if unit == "player" and TRACKING_SPELLS[spellId] then
		state.lastCastSpell = spellId
		UpdateIcon()
	end
end

events.PLAYER_ENTERING_WORLD = ResetFarmCycle
events.PLAYER_REGEN_ENABLED = ResetFarmCycle
events.UPDATE_SHAPESHIFT_FORM = ResetFarmCycle
events.PLAYER_UNGHOST = ResetFarmCycle
events.PLAYER_ALIVE = ResetFarmCycle
events.MINIMAP_UPDATE_TRACKING = UpdateIcon

eventFrame:SetScript("OnEvent", function(_, event, ...)
	if events[event] then
		events[event](...)
	end
end)

for event in pairs(events) do
	eventFrame:RegisterEvent(event)
end
