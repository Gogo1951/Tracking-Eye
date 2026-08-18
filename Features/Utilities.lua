local _, ns = ...

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

--[[
    Derived color table and accessor. The raw hex palette lives in Data/Data.lua
    (ns.PALETTE); this layer bakes the |cff prefix into each value once at build
    time. GetColor returns the prefixed escape string — append |r at the point
    of use.
]]
local COLOR_PREFIX = "|cff"
local COLORS = {}
for key, hex in pairs(ns.PALETTE) do
	COLORS[key] = COLOR_PREFIX .. hex
end

function ns.GetColor(key)
	return COLORS[key] or COLORS.TEXT
end

--------------------------------------------------------------------------------
-- Game-State Predicates
--------------------------------------------------------------------------------
--[[
    Returns isCat (Cat Form, for Track Humanoids gating), isFarming (Farm Mode is
    active right now), and movementState — the state the player is actually in,
    which ns.GetFarmPauseReason needs to explain an idle cycle. isFarming is true
    only when the master Farm Mode toggle is on AND the current movement state has
    its per-state toggle enabled. Movement states are mutually exclusive in
    practice — mounting cancels forms and aspects — so check mounted first, then
    the class movement buffs, then plain on-foot.
]]
local function ComputePlayerStates()
	if UnitOnTaxi("player") then
		return false, false, "taxi"
	end

	local isCat = false
	local hasTravelForm, hasCheetah, hasGhostWolf = false, false, false
	for i = 1, 40 do
		local name, _, _, _, _, _, _, _, _, id = UnitBuff("player", i)
		if not name then
			break
		end
		if id then
			if id == ns.SPELLS.CAT then
				isCat = true
			elseif ns.FARM_FORMS[id] then
				hasTravelForm = true
			elseif ns.CHEETAH_BUFFS[id] then
				hasCheetah = true
			elseif id == ns.GHOST_WOLF then
				hasGhostWolf = true
			end
		end
	end

	local movementState = "foot"
	if IsMounted() and not UnitAffectingCombat("player") then
		movementState = "mounted"
	elseif hasTravelForm then
		movementState = "travelForms"
	elseif hasCheetah then
		movementState = "cheetah"
	elseif hasGhostWolf then
		movementState = "ghostWolf"
	end

	local db = ns.db and ns.db.profile
	local isFarming = false
	if db and db.farmMode then
		isFarming = db[ns.MOVEMENT_STATE_TOGGLES[movementState]]
	end

	return isCat, isFarming and true or false, movementState
end

--[[
    Frame-scoped memo over the scan above. UpdateIcon and RunFarmLogic each derive
    these states twice in a single pass — once directly, once through
    ns.GetFarmPauseReason — and FlushIconAfterTrackingChange runs UpdateIcon eight
    times in about two seconds. GetTime() is constant for the whole frame, so a
    cache keyed on it can never serve an answer from a previous frame.

    Two deliberate bypasses. While ns.db is nil the result is recomputed and never
    stamped, because isFarming reads the profile and the database appears mid-frame
    during ADDON_LOADED. And ns:ApplyProfile invalidates explicitly, since a profile
    switch rewrites the per-state toggles that isFarming is derived from.
]]
local statesStamp = nil
local statesIsCat, statesIsFarming, statesMovement

function ns.InvalidatePlayerStates()
	statesStamp = nil
end

function ns.GetPlayerStates()
	if not ns.db then
		return ComputePlayerStates()
	end

	local now = GetTime()
	if statesStamp ~= now then
		statesStamp = now
		statesIsCat, statesIsFarming, statesMovement = ComputePlayerStates()
	end
	return statesIsCat, statesIsFarming, statesMovement
end

--[[
    Live "which tracking is up right now?" check, returning the active
    tracking spellId or nil. GetTrackingTexture alone cannot answer this:
    on Classic Era 1.15.x it returns nil for several active trackers
    (racials like Find Treasure) and lags state changes. The Blizzard
    minimap tracking icon is authoritative there — the Vanilla client
    hides it entirely when nothing is tracked, so it is only read while
    visible (a hidden frame can retain a stale texture). Falls back to
    GetTrackingTexture for clients where the icon shows a generic "None"
    texture instead (TBC+).
]]
--[[
    Lazily built reverse lookup (texture -> spellId) so every call isn't a linear
    GetSpellTexture scan over ns.TRACKING_IDS. During the login event storm
    GetSpellTexture returns nil for spells whose data hasn't loaded, so a cache
    built then is missing entries and has to be rebuilt once more data arrives.

    Rebuilds are driven by a dirty flag, NOT by testing whether every ID resolved.
    Find Fish (43308) is a TBC spell that does not exist in the Era client at all,
    so "every ID resolved" is unreachable there: a completeness test stays false
    forever and rebuilds the whole table on every lookup miss, which is most of
    them while nothing is tracked. SPELLS_CHANGED and PLAYER_ENTERING_WORLD are
    the only points where new spell data can appear, so they mark it dirty and the
    next lookup rebuilds exactly once.
]]
local textureToSpellId = nil
local textureCacheDirty = true

function ns.InvalidateTextureCache()
	textureCacheDirty = true
end

local function BuildTextureCache()
	textureToSpellId = {}
	for _, id in ipairs(ns.TRACKING_IDS) do
		local tex = GetSpellTexture(id)
		if tex then
			textureToSpellId[tex] = id
		end
	end
	textureCacheDirty = false
end

local function MatchTrackingTexture(tex)
	if not tex then
		return nil
	end
	if not textureToSpellId or textureCacheDirty then
		BuildTextureCache()
	end
	return textureToSpellId[tex]
end

function ns.GetActiveTrackingSpell()
	if MiniMapTrackingIcon and MiniMapTrackingIcon:IsVisible() then
		local id = MatchTrackingTexture(MiniMapTrackingIcon:GetTexture())
		if id then
			return id
		end
	end
	return MatchTrackingTexture(GetTrackingTexture())
end

--[[
    Gate for the add-on's automatic casts only; a tracking-menu click always
    casts. Two of the bails cost the player something rather than a GCD: a spell
    cast closes an open loot window, so a cycle tick mid-loot can lose the node
    that was just gathered, and casting while the cursor holds an item or spell
    discards what is on the cursor. Both are momentary, and every caller retries.
]]
function ns.CanCast()
	return not (
		UnitIsDeadOrGhost("player")
		or IsStealthed()
		or UnitCastingInfo("player")
		or UnitAffectingCombat("player")
		or ns.state.lootWindowOpen
		or GetCursorInfo()
	)
end

--[[
    True while the mouse is over something showing a tooltip. Farm Mode holds off
    then, so a cycle cast never fires under the player mid-inspection.

    Our own tooltip is deliberately excluded. The mini-map button and the
    free-placement frame both draw into GameTooltip, so counting them would mean
    the Farm Mode Status block reported "paused" every single time the player
    hovered the icon to read it, which is the one moment it has to be accurate.
]]
function ns.IsTooltipShowing()
	if not GameTooltip or not GameTooltip:IsVisible() then
		return false
	end

	local owner = GameTooltip:GetOwner()
	if owner and (owner == ns.freeFrame or owner == ns.minimapButton) then
		return false
	end

	return true
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
    The tracking spell this character would use for a creature type, or nil. The
    candidates are tried in order so the class-specific spell wins where one
    exists — a Paladin resolves Undead to Sense Undead, a Hunter to Track Undead.
]]
function ns.GetCreatureTypeSpell(creatureType)
	local candidates = creatureType and ns.CREATURE_TYPE_SPELLS[creatureType]
	if not candidates then
		return nil
	end
	for _, spellId in ipairs(candidates) do
		if IsPlayerSpell(spellId) then
			return spellId
		end
	end
	return nil
end

--[[
    True when this character can track at least one creature type, which is the
    condition Target Tracking means anything under. Shared by the options section's
    hidden predicate and the mini-map tooltip's status row, so the two can never
    disagree about whether the feature applies to this character.
]]
function ns.HasCreatureTypeTracking()
	for creatureType in pairs(ns.CREATURE_TYPE_SPELLS) do
		if ns.GetCreatureTypeSpell(creatureType) then
			return true
		end
	end
	return false
end

function ns.HasTrackingAbility()
	for _, id in ipairs(ns.TRACKING_IDS) do
		if IsPlayerSpell(id) then
			return true
		end
	end
	return false
end

--[[
    Gate class-specific Farm Mode toggles by class token, not by the learned
    spell, so a new player can find and pre-configure them before reaching the
    level where the movement ability is learned.
]]
function ns.IsPlayerClass(class)
	return select(2, UnitClass("player")) == class
end

--[[
    Which kind of restricted zone the player is in, or nil. Split out so
    ns.IsRestrictedZone (a yes/no gate) and ns.GetFarmPauseReason (which needs to
    tell an instance apart from a town) share one definition of "restricted".
]]
local function GetRestrictedKind()
	if IsInInstance() then
		return "instance"
	end
	local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
	if instanceMapID and ns.RESTRICTED_MAP_IDS[instanceMapID] then
		return "instance"
	end
	if IsResting() then
		return "resting"
	end
	return nil
end

function ns.IsRestrictedZone()
	return GetRestrictedKind() ~= nil
end

--[[
    Which movement states would start the cycle, phrased as what the player is
    not currently doing. Only the states this class can reach are considered, so
    a mage is never told about Ghost Wolf. One precomposed sentence per reachable
    combination rather than fragments joined at runtime: a comma-spliced sentence
    assembled from pieces cannot be translated correctly.
]]
local FOOT_REASONS = {
	mounted = "FARM_PAUSED_NOT_MOUNTED",
	travelForms = "FARM_PAUSED_NOT_TRAVEL",
	cheetah = "FARM_PAUSED_NOT_CHEETAH",
	ghostWolf = "FARM_PAUSED_NOT_GHOST_WOLF",
	mountedTravelForms = "FARM_PAUSED_NOT_MOUNTED_TRAVEL",
	mountedCheetah = "FARM_PAUSED_NOT_MOUNTED_CHEETAH",
	mountedGhostWolf = "FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF",
}

-- The player is in this state, but its own toggle is switched off.
local STATE_OFF_REASONS = {
	mounted = "FARM_PAUSED_MOUNTED_OFF",
	travelForms = "FARM_PAUSED_TRAVEL_OFF",
	cheetah = "FARM_PAUSED_CHEETAH_OFF",
	ghostWolf = "FARM_PAUSED_GHOST_WOLF_OFF",
}

local function GetMovementReason(movementState)
	local db = ns.db.profile

	if movementState ~= "foot" then
		return STATE_OFF_REASONS[movementState]
	end

	-- On foot with the on-foot toggle off: name every state that would start it.
	local classState
	for state, class in pairs(ns.MOVEMENT_STATE_CLASS) do
		if ns.IsPlayerClass(class) and db[ns.MOVEMENT_STATE_TOGGLES[state]] then
			classState = state
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

--[[
    Why Farm Mode is sitting idle right now: a locale key plus whether the reason
    is transient, or nil when the cycle is free to run. Farm Mode switched off is
    not a pause — the tooltip reports Disabled for that.

    Transient reasons clear on their own within seconds. The tooltip reports them
    so the player gets a straight answer, but the icon never dims for them: an
    icon that strobes through every fight and every gathered node reads as a bug.
]]
function ns.GetFarmPauseReason()
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

	local restricted = GetRestrictedKind()
	if restricted == "instance" then
		return "FARM_PAUSED_INSTANCE"
	elseif restricted == "resting" then
		return "FARM_PAUSED_RESTING"
	end

	if ns.GetFarmCycleCount and ns.GetFarmCycleCount() == 0 then
		return "FARM_PAUSED_NO_ABILITIES"
	end

	if not isFarming then
		return GetMovementReason(movementState)
	end

	-- Everything below is transient.
	if ns.IsOptionsPanelOpen and ns.IsOptionsPanelOpen() then
		return "FARM_PAUSED_OPTIONS", true
	end
	if ns.IsBlockingWindowOpen() then
		return "FARM_PAUSED_WINDOW", true
	end
	if ns.IsTooltipShowing() then
		return "FARM_PAUSED_TOOLTIP", true
	end
	if UnitAffectingCombat("player") then
		return "FARM_PAUSED_COMBAT", true
	end
	if UnitCastingInfo("player") then
		return "FARM_PAUSED_CASTING", true
	end
	if IsStealthed() then
		return "FARM_PAUSED_STEALTHED", true
	end
	if ns.state.lootWindowOpen then
		return "FARM_PAUSED_LOOTING", true
	end
	if GetCursorInfo() then
		return "FARM_PAUSED_CURSOR", true
	end

	return nil
end
