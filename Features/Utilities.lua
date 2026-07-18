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
    Returns isCat (Cat Form, for Track Humanoids gating) and isFarming (Farm Mode
    is active right now). isFarming is true only when the master Farm Mode toggle
    is on AND the player's current movement state has its per-state toggle
    enabled. Movement states are mutually exclusive in practice — mounting cancels
    forms and aspects — so check mounted first, then the class movement buffs,
    then plain on-foot.
]]
function ns.GetPlayerStates()
	if UnitOnTaxi("player") then
		return false, false
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

	local db = ns.db and ns.db.profile
	local isFarming = false
	if db and db.farmMode then
		if IsMounted() and not UnitAffectingCombat("player") then
			isFarming = db.farmMounted
		elseif hasTravelForm then
			isFarming = db.farmTravelForms
		elseif hasCheetah then
			isFarming = db.farmCheetah
		elseif hasGhostWolf then
			isFarming = db.farmGhostWolf
		else
			isFarming = db.farmNotMounted
		end
	end

	return isCat, isFarming and true or false
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
    Lazily built reverse lookup (texture -> spellId) so every call isn't a
    linear GetSpellTexture scan over ns.TRACKING_IDS. During the login event
    storm GetSpellTexture can return nil for spells whose data isn't loaded
    yet, so a cache built then would be permanently missing entries — track
    completeness and rebuild once on a miss until every id resolved.
]]
local textureToSpellId = nil
local textureCacheComplete = false

local function BuildTextureCache()
	textureToSpellId = {}
	textureCacheComplete = true
	for _, id in ipairs(ns.TRACKING_IDS) do
		local tex = GetSpellTexture(id)
		if tex then
			textureToSpellId[tex] = id
		else
			textureCacheComplete = false
		end
	end
end

local function MatchTrackingTexture(tex)
	if not tex then
		return nil
	end
	if not textureToSpellId then
		BuildTextureCache()
	end
	local id = textureToSpellId[tex]
	if not id and not textureCacheComplete then
		BuildTextureCache()
		id = textureToSpellId[tex]
	end
	return id
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

function ns.CanCast()
	return not (
		UnitIsDeadOrGhost("player")
		or IsStealthed()
		or UnitCastingInfo("player")
		or UnitAffectingCombat("player")
	)
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

function ns.IsRestrictedZone()
	if IsInInstance() then
		return true
	end
	local _, _, _, _, _, _, _, instanceMapID = GetInstanceInfo()
	if instanceMapID and ns.RESTRICTED_MAP_IDS[instanceMapID] then
		return true
	end
	return IsResting()
end
