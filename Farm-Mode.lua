local _, te = ...

--------------------------------------------------------------------------------
-- Farm Mode
--------------------------------------------------------------------------------

local farmIndex = 0
local cycleCache = {}

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
    if start and duration and start > 0 and duration > 1.5 then
        return
    end

    te.state.lastCastSpell = spellId
    te.UpdateIcon()
    pcall(CastSpellByID, spellId)
end

--------------------------------------------------------------------------------
-- Farm Cycle Logic
--------------------------------------------------------------------------------
function te.RunFarmLogic()
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

    table.wipe(cycleCache)
    for _, id in ipairs(te.FARM_CYCLE) do
        if IsPlayerSpell(id) then
            table.insert(cycleCache, id)
        end
    end

    if #cycleCache == 0 then
        return
    end

    if #cycleCache == 1 then
        local spellId = cycleCache[1]
        local spellTex = GetSpellTexture(spellId)

        if currentTrackingTex == spellTex or te.state.lastCastSpell == spellId then
            te.state.wasFarming = true
            return
        end
        farmIndex = 0
    end

    farmIndex = (farmIndex % #cycleCache) + 1
    local nextSpellId = cycleCache[farmIndex]
    local nextTex = GetSpellTexture(nextSpellId)

    if currentTrackingTex ~= nextTex then
        te.CastTracking(nextSpellId)
    end

    te.state.wasFarming = true
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function te.InitFarmMode()
    C_Timer.NewTicker(te.FARM_INTERVAL, te.RunFarmLogic)
end