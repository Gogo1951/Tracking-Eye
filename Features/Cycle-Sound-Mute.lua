local _, ns = ...

--------------------------------------------------------------------------------
-- Cycle Sound Mute
--------------------------------------------------------------------------------

--[[
    Every cycle cast, the ticker's and the Cycle Farm Mode Ability binding's,
    goes through here, so the optional cycle mute has exactly one seam to wrap.
    The form-leave restore, the tracking menu, the persistent recast, the
    post-resurrection recast, and Target Tracking all call ns.CastTracking
    directly and keep their sound, which is what the option promises.

    Sound_EnableSFX is the only lever available: the tracking spells' audio comes
    from the spell's own SoundKit, played by the engine, and never passes through
    PlaySound, so there is no FileDataID for MuteSoundFile to take.

    The window is the whole trick. The audio does NOT fire inside CastSpellByID —
    it fires when the server confirms the cast, a round trip later — so muting and
    restoring around the call silences nothing. The mute is therefore held until
    UNIT_SPELLCAST_SUCCEEDED reports our spell (ns.NotifyTrackingCastSucceeded,
    the usual path, typically well under 200ms) and lifted a short tail after
    that, with ns.CYCLE_MUTE_SECONDS as the ceiling for a cast the server never
    confirms. Generation-stamped so overlapping casts cannot restore each other
    early, and the cast is pcall-wrapped so an error can never strand the player
    with sound switched off.

    The timers are not the only way back. Sound_EnableSFX persists across
    sessions, so a mute whose timer dies with the UI would leave the player with
    sound effects off and nothing to connect it to. ns.RestoreCycleSoundNow
    restores unconditionally from two teardown points: the PLAYER_LOGOUT handler
    in Core.lua (which covers /reload as well as logout) and the muteCycleSound
    toggle's set handler when the player switches the option off.
]]
local muteGeneration = 0
local mutedValue = nil

local function RestoreCycleSound(generation)
	if mutedValue == nil or generation ~= muteGeneration then
		return
	end
	SetCVar("Sound_EnableSFX", mutedValue)
	mutedValue = nil
end

--[[
    Teardown restore, deliberately ignoring the generation stamp — this is the
    "put it back now, whatever is in flight" path, not a race between overlapping
    casts. Safe to call when nothing is muted.
]]
function ns.RestoreCycleSoundNow()
	if mutedValue == nil then
		return
	end
	SetCVar("Sound_EnableSFX", mutedValue)
	mutedValue = nil
end

-- Called from Core's UNIT_SPELLCAST_SUCCEEDED branch once the server confirms a tracking cast.
function ns.NotifyTrackingCastSucceeded()
	if mutedValue == nil then
		return
	end
	local generation = muteGeneration
	C_Timer.After(ns.CYCLE_MUTE_TAIL_SECONDS, function()
		RestoreCycleSound(generation)
	end)
end

function ns.CastCycleSpell(spellId)
	if not (ns.db and ns.db.profile.muteCycleSound) then
		ns.CastTracking(spellId)
		return
	end

	--[[
	    Cast first, arm second. CastTracking returns false without casting when the
	    spell is unknown, fails its Cat Form gate, or is on cooldown or the GCD, and
	    muting for a cast that never happened switches the player's sound off for
	    nothing. Arming afterwards is safe precisely because the audio plays on
	    server confirmation rather than inside CastSpellByID.
	]]
	local ok, attempted = pcall(ns.CastTracking, spellId)
	if not ok or not attempted then
		return
	end

	muteGeneration = muteGeneration + 1
	local generation = muteGeneration

	-- Never written when the player already plays with sound effects off.
	if mutedValue == nil then
		local previous = GetCVar("Sound_EnableSFX")
		if previous ~= "0" then
			mutedValue = previous
			SetCVar("Sound_EnableSFX", 0)
		end
	end

	C_Timer.After(ns.CYCLE_MUTE_SECONDS, function()
		RestoreCycleSound(generation)
	end)
end
