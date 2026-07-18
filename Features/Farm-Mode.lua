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
	local spells = ns.db and ns.db.profile.farmCycleSpells
	if not spells then
		return
	end
	for id, enabled in pairs(spells) do
		if enabled and id ~= ns.SPELLS.DRUID_HUMANOIDS and IsPlayerSpell(id) then
			table.insert(cachedCycle, id)
		end
	end
	table.sort(cachedCycle)
end

function ns.InvalidateFarmCache()
	cachedCycle = nil
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
	if ns.optionsOpen then
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
				ns.CastTracking(spellId)
			end
		end
		ns.state.wasFarming = true
		return
	end

	farmIndex = (farmIndex % #cachedCycle) + 1
	local nextSpellId = cachedCycle[farmIndex]

	if nextSpellId ~= ns.state.lastCastSpell then
		ns.CastTracking(nextSpellId)
	end

	ns.state.wasFarming = true
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
