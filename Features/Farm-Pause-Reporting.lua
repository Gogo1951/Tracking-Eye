local _, ns = ...

--------------------------------------------------------------------------------
-- Pause Reporting
--------------------------------------------------------------------------------

--[[
    True while the mouse is over something showing a tooltip. Farm Mode holds off
    then, so a cycle cast never fires under the player mid-inspection.

    Our own tooltip holds it too, but is checked apart, by ns.IsOwnTooltipShowing.
    The mini-map button and the free-placement frame both draw into GameTooltip,
    and hovering them is how the player reads the Farm Mode Status, so the pause
    reason for our own tooltip ranks last and the status names any other cause.
]]
local function IsOwnTooltipOwner(owner)
	return owner ~= nil and (owner == ns.freeFrame or owner == ns.minimapButton)
end

function ns.IsTooltipShowing()
	if not GameTooltip or not GameTooltip:IsVisible() then
		return false
	end
	return not IsOwnTooltipOwner(GameTooltip:GetOwner())
end

function ns.IsOwnTooltipShowing()
	if not GameTooltip or not GameTooltip:IsVisible() then
		return false
	end
	return IsOwnTooltipOwner(GameTooltip:GetOwner())
end

--[[
    Frames that block play but are not registered in UIPanelWindows, so the sweep
    below cannot see them.
]]
local EXTRA_BLOCKING_FRAMES = {
	"GameMenuFrame",
	"SettingsPanel",
	"InterfaceOptionsFrame",
	"VideoOptionsFrame",
	"KeyBindingFrame",
	"StaticPopup1",
}

--[[
    True while any full window is on screen — merchant, mailbox, auction house,
    quest, gossip, bank, trade, the game menu, Blizzard's options. Farm Mode holds
    off for all of them: the player is reading or transacting, not farming, and a
    cast fired underneath can close what they are looking at.

    Driven off UIPanelWindows rather than a hand-written frame list, so every
    standard window is covered at once and stays covered when Blizzard adds one.
]]
function ns.IsBlockingWindowOpen()
	if UIPanelWindows then
		for name in pairs(UIPanelWindows) do
			local frame = _G[name]
			if frame and frame.IsShown and frame:IsShown() then
				return true
			end
		end
	end

	for _, name in ipairs(EXTRA_BLOCKING_FRAMES) do
		local frame = _G[name]
		if frame and frame.IsShown and frame:IsShown() then
			return true
		end
	end

	return false
end

--[[
    Which movement states would start the cycle, phrased as what the player is
    not currently doing. Only the states this class can reach and this flavor can
    detect are considered, so a mage is never told about Ghost Wolf nor a Retail
    hunter about Aspect of the Cheetah, and a class that owns several names
    the first one switched on in ns.CLASS_STATE_ORDER. One precomposed sentence
    per pair rather than fragments joined at runtime: a comma-spliced sentence
    assembled from pieces cannot be translated correctly.
]]
local FOOT_REASONS = {
	mounted = "FARM_PAUSED_NOT_MOUNTED",
	travelForms = "FARM_PAUSED_NOT_TRAVEL",
	cheetah = "FARM_PAUSED_NOT_CHEETAH",
	pack = "FARM_PAUSED_NOT_PACK",
	ghostWolf = "FARM_PAUSED_NOT_GHOST_WOLF",
	mountedTravelForms = "FARM_PAUSED_NOT_MOUNTED_TRAVEL",
	mountedCheetah = "FARM_PAUSED_NOT_MOUNTED_CHEETAH",
	mountedPack = "FARM_PAUSED_NOT_MOUNTED_PACK",
	mountedGhostWolf = "FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF",
}

-- The player is in this state, but its own toggle is switched off.
local STATE_OFF_REASONS = {
	mounted = "FARM_PAUSED_MOUNTED_OFF",
	travelForms = "FARM_PAUSED_TRAVEL_OFF",
	cheetah = "FARM_PAUSED_CHEETAH_OFF",
	pack = "FARM_PAUSED_PACK_OFF",
	ghostWolf = "FARM_PAUSED_GHOST_WOLF_OFF",
}

local function GetMovementReason(movementState)
	local db = ns.db.profile

	if movementState ~= "foot" then
		return STATE_OFF_REASONS[movementState]
	end

	-- On foot with the on-foot toggle off: name the states that would start it.
	local classState
	for _, state in ipairs(ns.CLASS_STATE_ORDER) do
		if
			ns.IsPlayerClass(ns.MOVEMENT_STATE_CLASS[state])
			and db[ns.MOVEMENT_STATE_TOGGLES[state]]
			and ns.IsMovementStateDetectable(state)
		then
			classState = state
			break
		end
	end

	if db.farmMounted then
		return classState and FOOT_REASONS["mounted" .. classState:gsub("^%l", string.upper)] or FOOT_REASONS.mounted
	end
	if classState then
		return FOOT_REASONS[classState]
	end
	return "FARM_PAUSED_NO_STATES"
end

-- ns.GetEmptyCycleKind -> the pause reason that explains it.
local EMPTY_CYCLE_REASONS = {
	none = "FARM_PAUSED_NO_ABILITIES",
	unlearned = "FARM_PAUSED_NOT_LEARNED",
	catForm = "FARM_PAUSED_CAT_FORM",
}

--[[
    Why Farm Mode is sitting idle right now, as a locale key, or nil when the
    cycle is free to run. Farm Mode switched off is not a pause — the tooltip
    reports Disabled for that.
]]
function ns.GetFarmPauseReason(ownTooltipShowing)
	if not ns.db or not ns.db.profile.farmMode then
		return nil
	end

	if UnitIsDeadOrGhost("player") then
		return "FARM_PAUSED_DEAD"
	end

	local _, isFarming, movementState = ns.GetPlayerStates()

	if movementState == "taxi" then
		return "FARM_PAUSED_TAXI"
	end

	local restricted = ns.GetRestrictedKind()
	if restricted == "instance" then
		return "FARM_PAUSED_INSTANCE"
	elseif restricted == "resting" then
		return "FARM_PAUSED_RESTING"
	end

	if ns.GetFarmCycleCount and ns.GetFarmCycleCount() == 0 then
		return EMPTY_CYCLE_REASONS[ns.GetEmptyCycleKind()]
	end

	if not isFarming then
		return GetMovementReason(movementState)
	end

	-- Everything below is transient.
	if ns.IsOptionsPanelOpen and ns.IsOptionsPanelOpen() then
		return "FARM_PAUSED_OPTIONS"
	end
	if ns.IsBlockingWindowOpen() then
		return "FARM_PAUSED_WINDOW"
	end
	if ns.IsTooltipShowing() then
		return "FARM_PAUSED_TOOLTIP"
	end
	if UnitAffectingCombat("player") then
		return "FARM_PAUSED_COMBAT"
	end
	if ns.IsPlayerCasting() then
		return "FARM_PAUSED_CASTING"
	end
	if IsStealthed() then
		return "FARM_PAUSED_STEALTHED"
	end
	if ns.state.lootWindowOpen then
		return "FARM_PAUSED_LOOTING"
	end
	if GetCursorInfo() then
		return "FARM_PAUSED_CURSOR"
	end
	if ns.HasAttackableTarget() then
		return "FARM_PAUSED_TARGET"
	end
	if not ns.IsPlayerMoving() then
		return "FARM_PAUSED_STANDING_STILL"
	end
	if ownTooltipShowing or ns.IsOwnTooltipShowing() then
		return "FARM_PAUSED_TOOLTIP"
	end

	return nil
end
