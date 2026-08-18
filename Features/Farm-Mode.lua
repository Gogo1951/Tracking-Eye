local _, ns = ...

--------------------------------------------------------------------------------
-- Farm Mode
--------------------------------------------------------------------------------

local farmIndex = 0
local cachedCycle = nil
local farmTicker = nil

--------------------------------------------------------------------------------
-- Farm Cycle Cache
--------------------------------------------------------------------------------
local function BuildCycleCache()
	cachedCycle = {}
	local db = ns.db and ns.db.profile
	if not db then
		return
	end

	local inCycle = {}
	local spells = db.farmCycleSpells
	if spells then
		for id, enabled in pairs(spells) do
			if enabled and id ~= ns.SPELLS.DRUID_HUMANOIDS and IsPlayerSpell(id) then
				inCycle[id] = true
				table.insert(cachedCycle, id)
			end
		end
	end

	--[[
        The Persistent Tracking ability joins the rotation when the option is on,
        but only ONCE: picking Find Herbs as the persistent ability while Find
        Herbs is already ticked in the list must not queue it twice, which would
        hand it double the airtime of everything else in the cycle. Druid Track
        Humanoids is excluded here for the same reason it is excluded above — it
        requires Cat Form, which is mutually exclusive with every farm state.
    ]]
	local selected = db.selectedSpellId
	if
		db.farmIncludePersistent
		and selected
		and not inCycle[selected]
		and selected ~= ns.SPELLS.DRUID_HUMANOIDS
		and IsPlayerSpell(selected)
	then
		table.insert(cachedCycle, selected)
	end

	table.sort(cachedCycle)
end

function ns.InvalidateFarmCache()
	cachedCycle = nil
end

-- Single reader of the cycle's size, so nothing else has to know about the cache.
function ns.GetFarmCycleCount()
	if not cachedCycle then
		BuildCycleCache()
	end
	return #cachedCycle
end

--------------------------------------------------------------------------------
-- Cast Seam
--------------------------------------------------------------------------------

--[[
    Every automatic cast in this file goes through here, so the optional cycle
    mute has exactly one seam to wrap. The tracking menu, the persistent recast,
    and the post-resurrection recast all call ns.CastTracking directly and keep
    their sound, which is what the option promises.

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

local function CastCycleSpell(spellId)
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

--------------------------------------------------------------------------------
-- Farm Cycle Logic
--------------------------------------------------------------------------------
--[[
    Avoids raw GetTrackingTexture comparisons: the Era mirror lags real state by
    up to minutes, so it's consulted only as positive confirmation, never as a
    gate. The cycle compares against ns.state.lastCastSpell (written only from
    UNIT_SPELLCAST_SUCCEEDED), reliable on every client. Recasting an active
    spell is a harmless refresh, so the check only avoids burning a GCD on a no-op.
]]
function ns.RunFarmLogic()
	--[[
        Keep the dimmed icon honest before any bail. The ticker is the only thing
        that notices conditions firing no registered event — a taxi flight above
        all — so the pause reason is re-resolved here and the icon refreshed only
        when it actually changed.
    ]]
	if ns.GetFarmPauseReason() ~= ns.state.farmPauseReason then
		ns.UpdateIcon()
	end

	if ns.IsOptionsPanelOpen and ns.IsOptionsPanelOpen() then
		return
	end

	-- Hold while any window is open, or while the player is reading a tooltip.
	if ns.IsBlockingWindowOpen() or ns.IsTooltipShowing() then
		return
	end

	if not ns.db or not ns.db.profile.farmMode then
		return
	end

	local _, inForm = ns.GetPlayerStates()

	--[[
        Form-leave restore runs before the restricted-zone gate so a
        player who unmounts inside an instance or resting area still
        gets their persistent tracking spell back. Restore unless the
        selected spell is provably active (Blizzard icon / mirror via
        ns.GetActiveTrackingSpell) or our own cast of it is still in
        flight — bookkeeping alone (lastCastSpell) cannot see tracking
        cancelled outside the addon.
    ]]
	if not inForm and ns.state.wasFarming then
		ns.state.wasFarming = false
		if ns.db.profile.persistentTracking and ns.db.profile.selectedSpellId then
			local spellId = ns.db.profile.selectedSpellId
			if ns.GetActiveTrackingSpell() ~= spellId then
				local inFlight = ns.state.lastCastSpell == spellId
					and (GetTime() - (ns.state.lastTrackingCastAt or 0)) < ns.CAST_IN_FLIGHT_SECONDS
				if not inFlight then
					ns.CastTracking(spellId)
				end
			end
		end
		return
	end

	if ns.IsRestrictedZone() then
		return
	end

	if not inForm or not ns.CanCast() then
		return
	end

	if not cachedCycle then
		BuildCycleCache()
	end

	if #cachedCycle == 0 then
		return
	end

	if #cachedCycle == 1 then
		local spellId = cachedCycle[1]

		--[[
            Idle only while the spell is provably active (Blizzard icon /
            mirror via ns.GetActiveTrackingSpell) or our own cast is still
            in flight (the icon can lag the UNIT_SPELLCAST_SUCCEEDED by a
            moment). Anything else — including tracking cancelled outside
            the addon, which bookkeeping alone cannot see — recasts.
        ]]
		if ns.GetActiveTrackingSpell() ~= spellId then
			local inFlight = ns.state.lastCastSpell == spellId
				and (GetTime() - (ns.state.lastTrackingCastAt or 0)) < ns.CAST_IN_FLIGHT_SECONDS
			if not inFlight then
				CastCycleSpell(spellId)
			end
		end
		ns.state.wasFarming = true
		return
	end

	ns.AdvanceFarmCycle()

	ns.state.wasFarming = true
end

--------------------------------------------------------------------------------
-- Manual Cycle Advance
--------------------------------------------------------------------------------

--[[
    One step of the cycle, shared by the farm ticker and the key binding so there
    is a single advance path. Returns true when the cycle advanced, which is not
    the same as having cast: an entry that already matches ns.state.lastCastSpell
    is skipped rather than recast. It honors ns.CanCast itself, so the manual
    binding obeys the same guards as the automatic cycle (combat, an open loot
    window, a loaded cursor). A one-entry cycle recasts that entry: pressing the
    key must always do something visible.
]]
function ns.AdvanceFarmCycle()
	if not cachedCycle then
		BuildCycleCache()
	end

	if #cachedCycle == 0 or not ns.CanCast() then
		return false
	end

	if #cachedCycle == 1 then
		CastCycleSpell(cachedCycle[1])
		return true
	end

	farmIndex = (farmIndex % #cachedCycle) + 1
	local nextSpellId = cachedCycle[farmIndex]

	if nextSpellId ~= ns.state.lastCastSpell then
		CastCycleSpell(nextSpellId)
	end

	return true
end

--------------------------------------------------------------------------------
-- Ticker Management
--------------------------------------------------------------------------------
function ns.RestartFarmTicker()
	if farmTicker then
		farmTicker:Cancel()
		farmTicker = nil
	end
	local interval = (ns.db and ns.db.profile.farmInterval) or ns.DATABASE_DEFAULTS.profile.farmInterval
	farmTicker = C_Timer.NewTicker(interval, ns.RunFarmLogic)
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function ns.InitFarmMode()
	ns.RestartFarmTicker()
end
