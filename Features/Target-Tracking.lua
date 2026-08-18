local _, ns = ...

--------------------------------------------------------------------------------
-- Target Tracking
--------------------------------------------------------------------------------

--[[
    Sets the Persistent Tracking Ability from the creature the player targets, so
    the rest of that pack shows on the mini-map. It is a sub-option of Persistent
    Tracking and behaves like one in both directions. It does nothing at all while
    ns.db.profile.persistentTracking is off — the options panel hides the control
    then, so a feature that kept acting would be rewriting the saved ability and
    burning a GCD for something the player believes is switched off. Its own
    targetTracking key is never written by that gate: the setting survives
    untouched and resumes when the parent comes back on.

    When it does run it writes ns.db.profile.selectedSpellId, the same key the
    tracking menu writes, and everything downstream follows for free — the
    post-death recast, the form-leave restore, and the farm cycle's optional
    persistent entry all read that one key.

    Writing the key rather than borrowing the slot is what keeps this simple.
    There is no hold flag and no revert path, so Persistent Tracking never has to
    be suppressed and the two features cannot fight each other.

    It never casts in combat: a tracking spell costs a global cooldown, which is
    least affordable mid-fight, so a switch asked for during combat is remembered
    and applied on PLAYER_REGEN_ENABLED instead.
]]

-- The switch a target change asked for while the player was in combat, or nil.
local pendingSpellId = nil

function ns.HandleTargetChanged()
	-- Off, or the parent is off: drop any stored switch rather than applying it later.
	if not ns.db or not ns.db.profile.targetTracking or not ns.db.profile.persistentTracking then
		pendingSpellId = nil
		return
	end

	-- Friendly units must not drive a switch; targeting a city guard is not a hunt.
	if not UnitExists("target") or not UnitCanAttack("player", "target") then
		return
	end

	local spellId = ns.GetCreatureTypeSpell(UnitCreatureType("target"))
	if not spellId then
		return
	end

	if ns.db.profile.selectedSpellId == spellId then
		pendingSpellId = nil
		return
	end

	if UnitAffectingCombat("player") then
		pendingSpellId = spellId
		return
	end

	pendingSpellId = nil
	ns.db.profile.selectedSpellId = spellId
	-- The farm cycle can include the persistent ability, so its cache is now stale.
	ns.InvalidateFarmCache()

	--[[
        Cast straight away, Farm Mode running or not. Deferring to the cycle made
        the feature look dead in the state players actually use it in: mounted, the
        pick becomes one entry in a rotation of three or four and is overwritten
        within seconds, so targeting a beast showed nothing. Casting now puts the
        pack on the mini-map immediately and the cycle simply reclaims the slot on
        its next tick — still no hold flag, so the two features never suppress each
        other.
    ]]
	if ns.CanCast() then
		ns.CastTracking(spellId)
	end
end

--[[
    Combat ended. Re-run the whole decision rather than casting the stored ID: the
    target may be dead, swapped, or long gone, and re-validating costs one cheap
    pass while casting blind would set tracking from a corpse.
]]
function ns.HandleRegenEnabled()
	if not pendingSpellId then
		return
	end

	pendingSpellId = nil
	ns.HandleTargetChanged()
end
