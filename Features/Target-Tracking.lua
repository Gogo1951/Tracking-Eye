local _, ns = ...

--------------------------------------------------------------------------------
-- Target Tracking
--------------------------------------------------------------------------------

--[[
    Out in the world, the kind of creature the player targets stands in for the
    Persistent Tracking Ability: a "hunt". The hunt is runtime state only
    (ns.state.huntSpellId) and is never saved, so login and /reload always start
    without one, and nothing automatic ever writes selectedSpellId. An automatic
    signal must never overwrite a choice the player saved.

    ns.GetPersistentSpell (Persistent-Tracking.lua) decides what Persistent
    Tracking keeps up, the hunt included, so the post-resurrection recast, the
    form-leave restore, and the farm cycle's persistent entry all follow the hunt
    without knowing about it.

    A hunt starts or switches only out in the world and out of combat, from a
    living, attackable creature. A target picked mid-fight never counts and is
    never queued. A hunt ends at a context break: a town, an inn, an instance, a
    flight, a Tracking Menu pick, Clear Tracking, switching the feature off, or a
    profile change. Every break except the menu pick and Clear Tracking brings the
    Persistent Tracking Ability back through ns.TryRecastPersistent.
]]

-- Seconds between attempts while ns.CanCast() or a cooldown refuses a hunt's cast.
local HUNT_RETRY_SECONDS = 2

-- Bumped on every hunt change, so a pending retry for an older hunt stops.
local huntGeneration = 0

-- Starts, switches, or (with nil) ends the hunt. Returns false when nothing changed.
local function SetHunt(spellId)
	if ns.state.huntSpellId == spellId then
		return false
	end
	ns.state.huntSpellId = spellId
	huntGeneration = huntGeneration + 1
	-- The farm cycle's persistent entry holds the hunt, so its cache is now stale.
	ns.InvalidateFarmCache()
	ns.UpdateIcon()
	return true
end

--[[
    Ends a running hunt. A Tracking Menu pick and Clear Tracking pass false,
    since each sets tracking itself; every other break brings the Persistent
    Tracking Ability back.
]]
function ns.EndHunt(restorePersistent)
	if not SetHunt(nil) then
		return
	end
	if restorePersistent then
		ns.TryRecastPersistent()
	end
end

-- Shared by the options toggle and the launcher's Shift + Right-Click.
function ns.SetTargetTracking(enabled)
	ns.db.profile.targetTracking = enabled
	if not enabled then
		ns.EndHunt(true)
	end
end

--[[
    Casts the running hunt, retrying until it lands or the hunt changes or ends.
    Uses ns.GetActiveTrackingSpell() only as a positive "already up" signal, and
    never casts while Farm Mode is cycling without the Persistent Tracking
    Ability's entry: the form-leave restore brings the hunt back when the farm
    state ends.
]]
local function CastHunt(generation)
	if generation ~= huntGeneration then
		return
	end
	local spellId = ns.state.huntSpellId
	if not spellId or not ns.IsOutInTheWorld() then
		return
	end

	local _, isFarming = ns.GetPlayerStates()
	if isFarming and not ns.db.profile.farmIncludePersistent then
		return
	end

	if ns.GetActiveTrackingSpell() == spellId then
		return
	end

	if not ns.CanCast() or not ns.CastTracking(spellId) then
		C_Timer.After(HUNT_RETRY_SECONDS, function()
			CastHunt(generation)
		end)
	end
end

function ns.OnPlayerTargetChanged()
	if not ns.db or not ns.db.profile.targetTracking then
		return
	end

	if not ns.IsOutInTheWorld() or UnitAffectingCombat("player") then
		return
	end

	--[[
        Creatures only: an enemy player, a friendly unit, or a corpse never
        drives a switch, so clicking an add's corpse to loot it keeps the hunt.
        UnitIsPlayer never goes secret on WoW Forever; the creature type can, so
        it goes through ns.GetUnitCreatureType.
    ]]
	if not ns.HasAttackableTarget() or UnitIsPlayer("target") then
		return
	end

	local _, creatureTypeId = ns.GetUnitCreatureType("target")
	local spellId = ns.GetCreatureTypeSpell(creatureTypeId)
	if not spellId or not SetHunt(spellId) then
		return
	end

	-- A switch casts at once: one global cooldown per new kind, not per pull.
	CastHunt(huntGeneration)
end

--[[
    Called from the farm ticker, the only thing that sees a flight start or land:
    no registered event fires for either. Taking off ends a running hunt, and
    landing after that brings the Persistent Tracking Ability back.
]]
local wasOnTaxi = false
local restoreAfterLanding = false

function ns.HandleFlightState()
	local onTaxi = UnitOnTaxi("player") and true or false
	if onTaxi == wasOnTaxi then
		return
	end
	wasOnTaxi = onTaxi

	if onTaxi then
		if ns.state.huntSpellId then
			restoreAfterLanding = true
			ns.EndHunt(true)
		end
	elseif restoreAfterLanding then
		restoreAfterLanding = false
		ns.TryRecastPersistent()
	end
end
