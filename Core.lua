local addonName, ns = ...
local eventFrame = CreateFrame("Frame")

--------------------------------------------------------------------------------
-- State & Variables
--------------------------------------------------------------------------------
ns.state = {
    currentIcon = ns.ICON_DEFAULT,
    farmIndex = 0,
    wasFarming = false,
    cycleCache = {},
    lastCastSpell = nil
}

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------
function ns.GetPlayerStates()
    local isCat, isFarming = false, false
    
    if UnitOnTaxi("player") then
        return false, false
    end
    
    if IsMounted() then
        isFarming = true
    end

    for i = 1, 40 do
        local _, _, _, _, _, _, _, _, _, id = UnitBuff("player", i)
        if not id then break end
        
        if id == ns.SPELLS.CAT then
            isCat = true
        elseif ns.FARM_FORMS[id] then
            isFarming = true
        end
    end

    return isCat, isFarming
end

function ns.CanCast()
    return not (UnitIsDeadOrGhost("player") or IsStealthed() or UnitCastingInfo("player") or UnitAffectingCombat("player"))
end

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------
function ns.UpdateIcon()
    local tex = nil
    local isCat, _ = ns.GetPlayerStates()

    if ns.state.lastCastSpell == ns.SPELLS.HUMAN and not isCat then
        ns.state.lastCastSpell = nil
    end

    if ns.state.lastCastSpell then
        tex = GetSpellTexture(ns.state.lastCastSpell)
    end

    if not tex then
        tex = GetTrackingTexture()
    end

    if not tex and TrackingEyeDB and TrackingEyeDB.lastIcon then
        tex = TrackingEyeDB.lastIcon
    end

    ns.state.currentIcon = tex or ns.ICON_DEFAULT

    if TrackingEyeDB and tex and tex ~= ns.ICON_DEFAULT then
        TrackingEyeDB.lastIcon = tex
    end

    if ns.ldb then
        ns.ldb.icon = ns.state.currentIcon
    end
    if ns.freeFrame and ns.freeFrame.icon then
        ns.freeFrame.icon:SetTexture(ns.state.currentIcon)
    end
    
    if ns.RefreshTooltip then
        ns.RefreshTooltip()
    end
end

function ns.ClearTracking()
    ns.state.lastCastSpell = nil
    if TrackingEyeDB then
        TrackingEyeDB.selectedSpellId = nil
        TrackingEyeDB.lastIcon = nil
    end
    CancelTrackingBuff()
    ns.UpdateIcon()
end

--------------------------------------------------------------------------------
-- Farm Logic
--------------------------------------------------------------------------------
function ns.RunFarmLogic()
    if not TrackingEyeDB or not TrackingEyeDB.farmingMode then return end
    
    local isCat, inForm = ns.GetPlayerStates()
    local currentTrackingTex = GetTrackingTexture()

    if not inForm and ns.state.wasFarming then
        ns.state.wasFarming = false
        if TrackingEyeDB.autoTracking and TrackingEyeDB.selectedSpellId then
            local targetTex = GetSpellTexture(TrackingEyeDB.selectedSpellId)
            if currentTrackingTex ~= targetTex then
                ns.CastTracking(TrackingEyeDB.selectedSpellId)
            end
        end
        return
    end

    if not inForm or not ns.CanCast() then return end

    table.wipe(ns.state.cycleCache)
    
    for _, id in ipairs(ns.FARM_CYCLE) do
        if IsPlayerSpell(id) then
            local usable, noMana = IsUsableSpell(id)
            if usable or noMana then
                table.insert(ns.state.cycleCache, id)
            end
        end
    end

    if #ns.state.cycleCache == 0 then return end

    if #ns.state.cycleCache == 1 then
        local spellId = ns.state.cycleCache[1]
        local spellTex = GetSpellTexture(spellId)
        
        if currentTrackingTex == spellTex or ns.state.lastCastSpell == spellId then
            ns.state.wasFarming = true
            return
        end
        ns.state.farmIndex = 0
    end

    ns.state.farmIndex = (ns.state.farmIndex % #ns.state.cycleCache) + 1
    local nextSpellId = ns.state.cycleCache[ns.state.farmIndex]
    local nextTex = GetSpellTexture(nextSpellId)

    if currentTrackingTex ~= nextTex then
        ns.CastTracking(nextSpellId)
    end

    ns.state.wasFarming = true
end

function ns.CastTracking(spellId)
    if not spellId or not IsPlayerSpell(spellId) then return end
    
    local start, duration = GetSpellCooldown(spellId)
    if start and duration and (start > 0 and duration > 1.5) then
        return
    end
    
    ns.state.lastCastSpell = spellId
    ns.UpdateIcon()
    pcall(CastSpellByID, spellId)
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
eventFrame:SetScript(
    "OnEvent",
    function(_, event, arg1, ...)
        if event == "ADDON_LOADED" and arg1 == addonName then
            TrackingEyeDB = TrackingEyeDB or {autoTracking = true, farmingMode = true, minimap = {}}
            TrackingEyeDB.minimap = TrackingEyeDB.minimap or {}
            
            if ns.CreateFreeFrame then ns.CreateFreeFrame() end
            ns.UpdateIcon()
            
        elseif event == "PLAYER_LOGIN" then
            if ns.InitMinimap then ns.InitMinimap() end
            
            ns.UpdateIcon()
            C_Timer.NewTicker(ns.FARM_INTERVAL, ns.RunFarmLogic)
            
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
            local spellId = select(3, ...)
            for _, id in ipairs(ns.TRACKING_IDS) do
                if id == spellId then
                    ns.state.lastCastSpell = spellId
                    ns.UpdateIcon()
                    break
                end
            end
        elseif event == "MINIMAP_UPDATE_TRACKING" or event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "UPDATE_SHAPESHIFT_FORM" then
            ns.UpdateIcon()
            
            if event == "UPDATE_SHAPESHIFT_FORM" and TrackingEyeDB.autoTracking and TrackingEyeDB.selectedSpellId then
                local _, isFarming = ns.GetPlayerStates()
                if not isFarming then
                    local currentTex = GetTrackingTexture()
                    local targetTex = GetSpellTexture(TrackingEyeDB.selectedSpellId)
                    
                    if currentTex ~= targetTex then
                        local usable, noMana = IsUsableSpell(TrackingEyeDB.selectedSpellId)
                        if usable or noMana then
                            ns.CastTracking(TrackingEyeDB.selectedSpellId)
                        end
                    end
                end
            end
        end
    end
)

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
eventFrame:RegisterEvent("MINIMAP_UPDATE_TRACKING")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")