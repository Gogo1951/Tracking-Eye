local _, ns = ...

--------------------------------------------------------------------------------
-- Spell Tables
--------------------------------------------------------------------------------

--[[
    Lookups built once at load from this client's flavor data (Data/{Game}/).
    A row a flavor lacks is simply absent, so every lookup tolerates a missing key.
]]
local FORM_KEYS = { CAT = true, TRAVEL = true, AQUATIC = true, FLIGHT = true, SWIFT_FLIGHT = true }

ns.SPELLS = {}
ns.TRACKING_IDS = {}
-- Hash set of TRACKING_IDS for O(1) lookups.
ns.TRACKING_SET = {}
-- spellId -> the row's source ("Hunter", "Herbalism", ...), which groups the Farm Mode Abilities list.
ns.TRACKING_SOURCE = {}
for _, row in ipairs(ns.TRACKING_SPELLS) do
	local spellId, key = row[1], row[2]
	ns.SPELLS[key] = spellId
	if not FORM_KEYS[key] then
		table.insert(ns.TRACKING_IDS, spellId)
		ns.TRACKING_SET[spellId] = true
		ns.TRACKING_SOURCE[spellId] = row[3]
	end
end

ns.FARM_FORMS = {}
for _, key in ipairs({ "TRAVEL", "AQUATIC", "FLIGHT", "SWIFT_FLIGHT" }) do
	if ns.SPELLS[key] then
		ns.FARM_FORMS[ns.SPELLS[key]] = true
	end
end

-- The druid's tracking abilities, castable only in Cat Form: Track Humanoids everywhere, Track Beasts on Retail.
ns.CAT_FORM_ONLY = {}
for _, key in ipairs({ "DRUID_HUMANOIDS", "DRUID_BEASTS" }) do
	if ns.SPELLS[key] then
		ns.CAT_FORM_ONLY[ns.SPELLS[key]] = true
	end
end

ns.CHEETAH_BUFFS = {}
ns.PACK_BUFFS = {}
ns.GHOST_WOLF_BUFFS = {}
for _, row in ipairs(ns.MOVEMENT_BUFF_SPELLS) do
	if row[2] == "cheetah" then
		ns.CHEETAH_BUFFS[row[1]] = true
	elseif row[2] == "pack" then
		ns.PACK_BUFFS[row[1]] = true
	elseif row[2] == "ghostWolf" then
		ns.GHOST_WOLF_BUFFS[row[1]] = true
	end
end

local MOVEMENT_STATE_BUFFS = {
	travelForms = ns.FARM_FORMS,
	cheetah = ns.CHEETAH_BUFFS,
	pack = ns.PACK_BUFFS,
	ghostWolf = ns.GHOST_WOLF_BUFFS,
}

-- False for a state this flavor's data has no buff for, such as Retail's aspects; mounted and on foot need none.
function ns.IsMovementStateDetectable(state)
	local buffs = MOVEMENT_STATE_BUFFS[state]
	return buffs == nil or next(buffs) ~= nil
end

-- Keyed by the creature type ID, which is the same in every locale and on every client.
ns.CREATURE_TYPE_SPELLS = {}
for _, row in ipairs(ns.CREATURE_TYPE_DATA) do
	local ids = {}
	for _, key in ipairs(row[2]) do
		local spellId = ns.SPELLS[key]
		if spellId then
			table.insert(ids, spellId)
		end
	end
	if ids[1] then
		ns.CREATURE_TYPE_SPELLS[row[1]] = ids
	end
end

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

--[[
    Names the client supplies by ID (Style Guide → GAME NAMES), for our own
    sentences that place a spell, class or item type. Each falls back to an empty
    string, never to typed text, while the client hasn't loaded the record.
]]
function ns.GetSpellNameText(spellId)
	return spellId and C_Spell.GetSpellName(spellId) or ""
end

function ns.GetClassNameText(classToken)
	return LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[classToken] or ""
end

-- Every rank of a movement buff carries the same name, so any one row names its state.
local MOVEMENT_STATE_SPELL = {}
for _, row in ipairs(ns.MOVEMENT_BUFF_SPELLS) do
	MOVEMENT_STATE_SPELL[row[2]] = row[1]
end

function ns.GetMovementStateName(state)
	return ns.GetSpellNameText(MOVEMENT_STATE_SPELL[state])
end

-- The druid's class name and Cat Form, the pair every Cat Form-only message names.
function ns.GetCatFormNames()
	return ns.GetClassNameText("DRUID"), ns.GetSpellNameText(ns.SPELLS.CAT)
end

local GetItemSubClassInfo = C_Item.GetItemSubClassInfo

function ns.GetFishingPoleName()
	return GetItemSubClassInfo(Enum.ItemClass.Weapon, Enum.ItemWeaponSubclass.Fishingpole) or ""
end

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
-- API Compatibility
--------------------------------------------------------------------------------

--[[
    WoW Forever carries Midnight's secret values. While a restriction is in force
    (combat, in practice) aura reads from add-on code throw, the player's own buffs
    included, and cooldown, casting, and identity reads return values add-on code
    may not test or compare. C_Secrets reports each restriction ahead of the read,
    so every read that can go secret asks first. All three supported clients ship
    C_Secrets, so it is called directly.
]]

--[[
    Start and duration, or nil while cooldowns are secret: callers read nil as "not
    known to be cooling down" and let the cast attempt decide. C_Spell packs the
    pair into one table, which this unpacks for every caller.
]]
function ns.GetSpellCooldown(spellId)
	if C_Secrets.ShouldCooldownsBeSecret() then
		return nil
	end
	local info = C_Spell.GetSpellCooldown(spellId)
	if not info then
		return nil
	end
	return info.startTime, info.duration
end

--[[
    A channel counts as casting: any cast ends it, so a tracking cast would cut
    short Fishing, a bandage, or Eagle Eye. While casting reads are secret the
    answer is unknowable, so it errs toward yes: every caller holds an automatic
    cast and retries.
]]
function ns.IsPlayerCasting()
	if C_Secrets.ShouldUnitSpellCastingBeSecret("player") then
		return true
	end
	return UnitCastingInfo("player") ~= nil or UnitChannelInfo("player") ~= nil
end

-- The unit's localized creature type and its creature type ID, or nil while its identity is secret.
function ns.GetUnitCreatureType(unit)
	if C_Secrets.ShouldUnitIdentityBeSecret(unit) then
		return nil
	end
	return UnitCreatureType(unit)
end

--[[
    An item's or spell's tooltip as plain lines, a right-hand column kept after
    " >> ". kind is "item" or "spell". C_TooltipInfo hands the lines over as
    data where the client ships its GetItemByID and GetSpellByID getters;
    elsewhere they are read off a hidden tooltip that is never shown. Color
    escapes are stripped so each line reads as its words. Resolved once at load.
    A read can throw on an odd id, so callers protect it. Validate Data is the
    only reader.
]]
local SCAN_TOOLTIP_NAME = "TrackingEyeScanTooltip"
local TOOLTIP_DATA_GETTERS = C_TooltipInfo
	and C_TooltipInfo.GetItemByID
	and C_TooltipInfo.GetSpellByID
	and { item = C_TooltipInfo.GetItemByID, spell = C_TooltipInfo.GetSpellByID }
local scanTooltip

local function PlainText(text)
	if type(text) ~= "string" then
		return nil
	end
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|cn[^:]*:", ""):gsub("|r", ""))
end

local function JoinTooltipLine(left, right)
	left = PlainText(left) or ""
	right = PlainText(right)
	if right and right ~= "" then
		return left .. " >> " .. right
	end
	return left
end

local function ReadTooltipData(kind, id)
	local lines = {}
	local data = TOOLTIP_DATA_GETTERS[kind](id)
	for _, line in ipairs(data and data.lines or {}) do
		lines[#lines + 1] = JoinTooltipLine(line.leftText, line.rightText)
	end
	return lines
end

local function ReadScanTooltip(kind, id)
	if not scanTooltip then
		scanTooltip = CreateFrame("GameTooltip", SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
	end
	scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	scanTooltip:ClearLines()
	scanTooltip:SetHyperlink(kind .. ":" .. id)
	local lines = {}
	for index = 1, scanTooltip:NumLines() do
		local left = _G[SCAN_TOOLTIP_NAME .. "TextLeft" .. index]
		local right = _G[SCAN_TOOLTIP_NAME .. "TextRight" .. index]
		lines[#lines + 1] = JoinTooltipLine(left and left:GetText(), right and right:IsShown() and right:GetText())
	end
	scanTooltip:Hide()
	return lines
end

ns.GetTooltipLines = TOOLTIP_DATA_GETTERS and ReadTooltipData or ReadScanTooltip

--------------------------------------------------------------------------------
-- Formatting
--------------------------------------------------------------------------------

function ns:FormatCommaNumber(number)
	return (tostring(number):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

--------------------------------------------------------------------------------
-- Game-State Predicates
--------------------------------------------------------------------------------

--[[
    The movement-relevant buffs on the player: Cat Form, a travel form, Aspect of
    the Cheetah, Aspect of the Pack, Ghost Wolf. C_UnitAuras is called directly
    with no legacy fallback, since every supported client ships it (COMPATIBILITY).

    While auras are secret the last readable scan stands in: forms rarely change
    mid-fight, Farm Mode is paused for combat anyway, and the first scan after the
    restriction lifts refreshes it.
]]
local lastIsCat, lastTravelForm, lastCheetah, lastPack, lastGhostWolf = false, false, false, false, false

local function ScanMovementBuffs()
	if C_Secrets.ShouldAurasBeSecret() then
		return lastIsCat, lastTravelForm, lastCheetah, lastPack, lastGhostWolf
	end

	local isCat = false
	local hasTravelForm, hasCheetah, hasPack, hasGhostWolf = false, false, false, false
	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", i)
		if not aura then
			break
		end
		local id = aura.spellId
		if id then
			if id == ns.SPELLS.CAT then
				isCat = true
			elseif ns.FARM_FORMS[id] then
				hasTravelForm = true
			elseif ns.CHEETAH_BUFFS[id] then
				hasCheetah = true
			elseif ns.PACK_BUFFS[id] then
				hasPack = true
			elseif ns.GHOST_WOLF_BUFFS[id] then
				hasGhostWolf = true
			end
		end
	end

	lastIsCat, lastTravelForm, lastCheetah, lastPack, lastGhostWolf =
		isCat, hasTravelForm, hasCheetah, hasPack, hasGhostWolf
	return isCat, hasTravelForm, hasCheetah, hasPack, hasGhostWolf
end

--[[
    Returns isCat (Cat Form, for ns.CAT_FORM_ONLY gating), isFarming (Farm Mode is
    active right now), and movementState — the state the player is actually in,
    which ns.GetFarmPauseReason needs to explain an idle cycle. isFarming is true
    only when the master Farm Mode toggle is on AND the current movement state has
    its per-state toggle enabled. Movement states are mutually exclusive in
    practice — mounting cancels forms and aspects — so check mounted first, then a
    travel form, then the aspects and Ghost Wolf, then plain on-foot.
]]
local function ComputePlayerStates()
	if UnitOnTaxi("player") then
		return false, false, "taxi"
	end

	local isCat, hasTravelForm, hasCheetah, hasPack, hasGhostWolf = ScanMovementBuffs()

	local movementState = "foot"
	if IsMounted() then
		movementState = "mounted"
	elseif hasTravelForm then
		movementState = "travelForms"
	elseif hasCheetah then
		movementState = "cheetah"
	elseif hasPack then
		movementState = "pack"
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

-- While unit stats are secret the answer is unknowable, so it errs toward standing still: every caller waits for movement.
function ns.IsPlayerMoving()
	if C_Secrets.ShouldUnitStatsBeSecret() then
		return false
	end
	return GetUnitSpeed("player") > 0
end

--[[
    A living target the player can attack. Yourself, a party member, a friendly
    NPC, and a corpse don't count. Farm Mode holds while one is targeted, and
    Target Tracking hunts only from one. None of these reads goes secret on WoW
    Forever.
]]
function ns.HasAttackableTarget()
	return UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")
end

function ns.IsFishingPoleEquipped()
	local itemId = GetInventoryItemID("player", INVSLOT_MAINHAND)
	if not itemId then
		return false
	end
	-- GetItemInfoInstant reads the client's own item table, so unlike C_Item.GetItemInfo it never comes back empty on a cold call.
	local _, _, _, _, _, classId, subclassId = C_Item.GetItemInfoInstant(itemId)
	return classId == Enum.ItemClass.Weapon and subclassId == Enum.ItemWeaponSubclass.Fishingpole
end

--[[
    Lazily built reverse lookup (texture -> spellId) so every call isn't a linear
    C_Spell.GetSpellTexture scan over ns.TRACKING_IDS. During the login event storm
    C_Spell.GetSpellTexture returns nil for spells whose data hasn't loaded, so a cache
    built then is missing entries and has to be rebuilt once more data arrives.

    Rebuilds are driven by a dirty flag, NOT by testing whether every ID resolved.
    An ID this client lacks never resolves, so a completeness test can stay false
    forever and rebuild the whole table on every lookup miss, which is most of
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
		local texture = C_Spell.GetSpellTexture(id)
		if texture then
			textureToSpellId[texture] = id
		end
	end
	textureCacheDirty = false
end

local function MatchTrackingTexture(texture)
	if not texture then
		return nil
	end
	if not textureToSpellId or textureCacheDirty then
		BuildTextureCache()
	end
	return textureToSpellId[texture]
end

--[[
    The tracking spell an active C_Minimap entry stands for, or nil. Only entries
    backed by one of this add-on's spells count, so a town service switched on in
    the minimap menu is never mistaken for tracking. A spell entry without a spell
    ID is matched by its texture instead.
]]
local function GetMinimapEntrySpell(index)
	local info = C_Minimap.GetTrackingInfo(index)
	if not info or not info.active then
		return nil
	end
	if info.spellID then
		return ns.TRACKING_SET[info.spellID] and info.spellID or nil
	end
	if info.type == "spell" then
		return MatchTrackingTexture(info.texture)
	end
	return nil
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
    texture instead (TBC+). WoW Forever ships neither the icon nor
    GetTrackingTexture and reads the C_Minimap tracking list instead.
]]
function ns.GetActiveTrackingSpell()
	if MiniMapTrackingIcon and MiniMapTrackingIcon:IsVisible() then
		local id = MatchTrackingTexture(MiniMapTrackingIcon:GetTexture())
		if id then
			return id
		end
	end
	if GetTrackingTexture then
		return MatchTrackingTexture(GetTrackingTexture())
	end
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		local id = GetMinimapEntrySpell(index)
		if id then
			return id
		end
	end
	return nil
end

--[[
    Drops the add-on's tracking. CancelTrackingBuff covers Era and TBC. On WoW
    Forever every active entry backed by one of this add-on's spells is switched
    off, and any town service beside them is left alone. Never ClearAllTracking:
    it also clears Blizzard's own quest and target filters.
]]
function ns.CancelActiveTracking()
	if CancelTrackingBuff then
		CancelTrackingBuff()
		return
	end
	for index = 1, C_Minimap.GetNumTrackingTypes() do
		if GetMinimapEntrySpell(index) then
			C_Minimap.SetTracking(index, false)
		end
	end
end

--[[
    Gate for the add-on's automatic casts only; a tracking-menu click always
    casts. Three of the bails cost the player something rather than a GCD: a
    cast ends a channel (ns.IsPlayerCasting counts one), a spell cast closes an
    open loot window, so a cycle tick mid-loot can lose the node that was just
    gathered, and casting while the cursor holds an item or spell discards what
    is on the cursor. All are momentary, and every caller retries.
]]
function ns.CanCast()
	return not (
		UnitIsDeadOrGhost("player")
		or IsStealthed()
		or ns.IsPlayerCasting()
		or UnitAffectingCombat("player")
		or ns.state.lootWindowOpen
		or GetCursorInfo()
	)
end

--[[
    The tracking spell this character would use for a creature type, or nil. The
    candidates are tried in order so the class-specific spell wins where one
    exists — a Paladin resolves Undead to Sense Undead, a Hunter to Track Undead.
]]
function ns.GetCreatureTypeSpell(creatureTypeId)
	local candidates = creatureTypeId and ns.CREATURE_TYPE_SPELLS[creatureTypeId]
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

function ns.HasTrackingAbility()
	for _, id in ipairs(ns.TRACKING_IDS) do
		if IsPlayerSpell(id) then
			return true
		end
	end
	return false
end

--[[
    By class token, not by the learned spell: the Farm Mode pause reason uses it
    to name only the movement states this character's class owns.
]]
function ns.IsPlayerClass(class)
	return select(2, UnitClass("player")) == class
end

--[[
    Which kind of restricted zone the player is in, or nil. Split out so
    ns.IsRestrictedZone (a yes/no gate) and ns.GetFarmPauseReason (which needs to
    tell an instance apart from a town) share one definition of "restricted".
]]
function ns.GetRestrictedKind()
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
	return ns.GetRestrictedKind() ~= nil
end

-- Farm Mode's definition of "out in the world", shared with Automatic Target Tracking.
function ns.IsOutInTheWorld()
	return not UnitOnTaxi("player") and not ns.IsRestrictedZone()
end
