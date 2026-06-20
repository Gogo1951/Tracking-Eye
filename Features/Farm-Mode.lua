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
function ns.RunFarmLogic()
    -- Pause while options panel is open
    if ns.optionsOpen then
        return
    end

    if not TrackingEyeCharDB or not TrackingEyeCharDB.farmMode then
        return
    end

    local _, inForm = ns.GetPlayerStates()
    local currentTrackingTexture = GetTrackingTexture()

    --[[
        Form-leave restore runs before the restricted-zone gate so a
        player who unmounts inside an instance or resting area still
        gets their persistent tracking spell back.
    ]]
    if not inForm and ns.state.wasFarming then
        ns.state.wasFarming = false
        if TrackingEyeCharDB.persistentTracking and TrackingEyeCharDB.selectedSpellId then
            local spellId = TrackingEyeCharDB.selectedSpellId
            local targetTexture = GetSpellTexture(spellId)
            if currentTrackingTexture ~= targetTexture then
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
        local spellTexture = GetSpellTexture(spellId)

        --[[
            Only trust lastCastSpell when GetTrackingTexture is nil
            (login/API lag). Outside that window, the live texture is
            authoritative — if tracking was cleared or changed
            externally, we want to re-cast, not skip.
        ]]
        if currentTrackingTexture == spellTexture
            or (currentTrackingTexture == nil and ns.state.lastCastSpell == spellId) then
            ns.state.wasFarming = true
            return
        end
        farmIndex = 0
    end

    farmIndex = (farmIndex % #cachedCycle) + 1
    local nextSpellId = cachedCycle[farmIndex]
    local nextTexture = GetSpellTexture(nextSpellId)

    if currentTrackingTexture ~= nextTexture then
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