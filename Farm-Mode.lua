local _, te = ...

--------------------------------------------------------------------------------
-- Farm Mode
--------------------------------------------------------------------------------

local farmIndex = 0
local cachedCycle = nil
local farmTicker = nil

--------------------------------------------------------------------------------
-- Casting
--------------------------------------------------------------------------------
function te.CastTracking(spellId)
    if not spellId or not IsPlayerSpell(spellId) then
        return
    end

    if spellId == te.SPELLS.DRUID_HUMANOIDS then
        local isCat = te.GetPlayerStates()
        if not isCat then
            return
        end
    end

    local start, duration = GetSpellCooldown(spellId)
    if start and duration and start > 0 and duration > 0 then
        return
    end

    te.state.lastCastSpell = spellId
    te.UpdateIcon()
    pcall(CastSpellByID, spellId)
end

--------------------------------------------------------------------------------
-- Farm Cycle Cache
--------------------------------------------------------------------------------
local function BuildCycleCache()
    cachedCycle = {}
    local spells = TrackingEyeDB and TrackingEyeDB.farmCycleSpells
    if not spells then
        return
    end
    for id, enabled in pairs(spells) do
        if enabled and id ~= te.SPELLS.DRUID_HUMANOIDS and IsPlayerSpell(id) then
            table.insert(cachedCycle, id)
        end
    end
    table.sort(cachedCycle)
end

function te.InvalidateFarmCache()
    cachedCycle = nil
end

--------------------------------------------------------------------------------
-- Farm Cycle Logic
--------------------------------------------------------------------------------
function te.RunFarmLogic()
    -- Pause while options panel is open
    if te.optionsOpen then
        return
    end

    if not TrackingEyeDB or not TrackingEyeDB.farmingMode then
        return
    end

    local _, inForm = te.GetPlayerStates()
    local currentTrackingTex = GetTrackingTexture()

    if not inForm and te.state.wasFarming then
        te.state.wasFarming = false
        if TrackingEyeDB.autoTracking and TrackingEyeDB.selectedSpellId then
            local spellId = TrackingEyeDB.selectedSpellId
            local targetTex = GetSpellTexture(spellId)
            if currentTrackingTex ~= targetTex then
                te.CastTracking(spellId)
            end
        end
        return
    end

    if not inForm or not te.CanCast() then
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
        local spellTex = GetSpellTexture(spellId)

        if currentTrackingTex == spellTex or te.state.lastCastSpell == spellId then
            te.state.wasFarming = true
            return
        end
        farmIndex = 0
    end

    farmIndex = (farmIndex % #cachedCycle) + 1
    local nextSpellId = cachedCycle[farmIndex]
    local nextTex = GetSpellTexture(nextSpellId)

    if currentTrackingTex ~= nextTex then
        te.CastTracking(nextSpellId)
    end

    te.state.wasFarming = true
end

--------------------------------------------------------------------------------
-- Ticker Management
--------------------------------------------------------------------------------
function te.RestartFarmTicker()
    if farmTicker then
        farmTicker:Cancel()
        farmTicker = nil
    end
    local interval = (TrackingEyeDB and TrackingEyeDB.farmInterval) or te.FARM_INTERVAL_DEFAULT
    farmTicker = C_Timer.NewTicker(interval, te.RunFarmLogic)
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function te.InitFarmMode()
    te.RestartFarmTicker()
end