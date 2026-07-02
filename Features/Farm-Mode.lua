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
    local spells = TrackingEyeCharDB and TrackingEyeCharDB.farmCycleSpells
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
    Farm logic deliberately never reads GetTrackingTexture. On the
    Vanilla-based client (Classic Era 1.15.x) the tracking mirror lags
    the real state, sometimes by minutes (client bug since 1.15.1), so
    comparing against it silently skips or misdirects casts. Our own
    bookkeeping — ns.state.lastCastSpell, written only from
    UNIT_SPELLCAST_SUCCEEDED — is reliable on every client, so the
    cycle compares against that instead. Recasting an already-active
    tracking spell is a harmless refresh, so the comparison only exists
    to avoid burning a GCD on a no-op.
]]
function ns.RunFarmLogic()
    -- Pause while options panel is open
    if ns.optionsOpen then
        return
    end

    if not TrackingEyeCharDB or not TrackingEyeCharDB.farmMode then
        return
    end

    local _, inForm = ns.GetPlayerStates()

    --[[
        Form-leave restore runs before the restricted-zone gate so a
        player who unmounts inside an instance or resting area still
        gets their persistent tracking spell back. Restore unless the
        selected spell is already the last thing we successfully cast.
    ]]
    if not inForm and ns.state.wasFarming then
        ns.state.wasFarming = false
        if TrackingEyeCharDB.persistentTracking and TrackingEyeCharDB.selectedSpellId then
            local spellId = TrackingEyeCharDB.selectedSpellId
            if ns.state.lastCastSpell ~= spellId then
                ns.CastTracking(spellId)
            end
        end
        return
    end

    -- Skip farm cycling inside instances and while resting
    if ns.IsRestrictedZone() then
        return
    end

    if not inForm or not ns.CanCast() then
        return
    end

    -- Rebuild cache if invalidated
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
            local inFlight = ns.state.lastCastSpell == spellId and
                (GetTime() - (ns.state.lastTrackingCastAt or 0)) < ns.CAST_IN_FLIGHT_SECONDS
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
    local interval = (TrackingEyeCharDB and TrackingEyeCharDB.farmInterval) or ns.CHAR_DEFAULTS.farmInterval
    farmTicker = C_Timer.NewTicker(interval, ns.RunFarmLogic)
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function ns.InitFarmMode()
    ns.RestartFarmTicker()
end