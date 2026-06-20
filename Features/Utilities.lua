local _, ns = ...

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

--[[
    Derived color table and accessor. The raw hex palette lives in Data/Data.lua
    (ns.HEX); this layer applies the |cff prefix. GetColor returns the prefixed
    escape string — append |r at the point of use.
]]
local COLOR_PREFIX = "|cff"
local COLORS = {
    TITLE = ns.HEX.TITLE,
    INFO = ns.HEX.INFO,
    BODY = ns.HEX.BODY,
    TEXT = ns.HEX.TEXT,
    ON = ns.HEX.ON,
    OFF = ns.HEX.OFF,
    SEPARATOR = ns.HEX.SEPARATOR,
    MUTED = ns.HEX.MUTED
}

function ns.GetColor(key)
    return COLOR_PREFIX .. (COLORS[key] or "FFFFFF")
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

    local db = TrackingEyeCharDB
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

function ns.CanCast()
    return not (UnitIsDeadOrGhost("player") or IsStealthed() or UnitCastingInfo("player") or
        UnitAffectingCombat("player"))
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
    local inInstance = IsInInstance()
    if inInstance then
        return true
    end
    return IsResting()
end
