local addonName, te = ...
local eventFrame = CreateFrame("Frame")

--------------------------------------------------------------------------------
-- State & Variables
--------------------------------------------------------------------------------
te.state = {
    currentIcon = te.ICON_DEFAULT,
    farmIndex = 0,
    wasFarming = false,
    cycleCache = {},
    lastCastSpell = nil
}

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------
function te.GetPlayerStates()
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
        
        if id == te.SPELLS.CAT then
            isCat = true
        elseif te.FARM_FORMS[id] then
            isFarming = true
        end
    end

    return isCat, isFarming
end

function te.CanCast()
    return not (UnitIsDeadOrGhost("player") or IsStealthed() or UnitCastingInfo("player") or UnitAffectingCombat("player"))
end

function te.HasTrackingAbility()
    for _, id in ipairs(te.TRACKING_IDS) do
        if IsPlayerSpell(id) then
            return true
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------
function te.UpdateIcon()
    local tex = nil
    local isCat, _ = te.GetPlayerStates()

    if te.state.lastCastSpell == te.SPELLS.DRUID_HUMANOIDS and not isCat then
        te.state.lastCastSpell = nil
    end

    if te.state.lastCastSpell then
        tex = GetSpellTexture(te.state.lastCastSpell)
    end

    if not tex then
        tex = GetTrackingTexture()
    end

    if not tex and TrackingEyeDB and TrackingEyeDB.lastIcon then
        tex = TrackingEyeDB.lastIcon
    end

    te.state.currentIcon = tex or te.ICON_DEFAULT

    if TrackingEyeDB and tex and tex ~= te.ICON_DEFAULT then
        TrackingEyeDB.lastIcon = tex
    end

    if te.ldb then
        te.ldb.icon = te.state.currentIcon
    end
    if te.freeFrame and te.freeFrame.icon then
        te.freeFrame.icon:SetTexture(te.state.currentIcon)
    end
    
    if te.RefreshTooltip then
        te.RefreshTooltip()
    end
end

function te.ClearTracking()
    te.state.lastCastSpell = nil
    if TrackingEyeDB then
        TrackingEyeDB.selectedSpellId = nil
        TrackingEyeDB.lastIcon = nil
    end
    CancelTrackingBuff()
    te.UpdateIcon()
end

--------------------------------------------------------------------------------
-- Farm Logic
--------------------------------------------------------------------------------
function te.RunFarmLogic()
    if not TrackingEyeDB or not TrackingEyeDB.farmingMode then return end
    
    local _, inForm = te.GetPlayerStates()
    local currentTrackingTex = GetTrackingTexture()

    if not inForm and te.state.wasFarming then
        te.state.wasFarming = false
        if TrackingEyeDB.autoTracking and TrackingEyeDB.selectedSpellId then
            local targetTex = GetSpellTexture(TrackingEyeDB.selectedSpellId)
            if currentTrackingTex ~= targetTex then
                te.CastTracking(TrackingEyeDB.selectedSpellId)
            end
        end
        return
    end

    if not inForm or not te.CanCast() then return end

    table.wipe(te.state.cycleCache)
    
    for _, id in ipairs(te.FARM_CYCLE) do
        if IsPlayerSpell(id) then
            local usable, noMana = IsUsableSpell(id)
            if usable or noMana then
                table.insert(te.state.cycleCache, id)
            end
        end
    end

    if #te.state.cycleCache == 0 then return end

    if #te.state.cycleCache == 1 then
        local spellId = te.state.cycleCache[1]
        local spellTex = GetSpellTexture(spellId)
        
        if currentTrackingTex == spellTex or te.state.lastCastSpell == spellId then
            te.state.wasFarming = true
            return
        end
        te.state.farmIndex = 0
    end

    te.state.farmIndex = (te.state.farmIndex % #te.state.cycleCache) + 1
    local nextSpellId = te.state.cycleCache[te.state.farmIndex]
    local nextTex = GetSpellTexture(nextSpellId)

    if currentTrackingTex ~= nextTex then
        te.CastTracking(nextSpellId)
    end

    te.state.wasFarming = true
end

function te.CastTracking(spellId)
    if not spellId or not IsPlayerSpell(spellId) then return end
    
    local start, duration = GetSpellCooldown(spellId)
    if start and duration and (start > 0 and duration > 1.5) then
        return
    end
    
    te.state.lastCastSpell = spellId
    te.UpdateIcon()
    pcall(CastSpellByID, spellId)
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
eventFrame:SetScript(
    "OnEvent",
    function(_, event, arg1, ...)
        if event == "ADDON_LOADED" and arg1 == addonName then
            TrackingEyeDB = TrackingEyeDB or {
                autoTracking = true, 
                farmingMode = true
            }
            
            TrackingEyeGlobalDB = TrackingEyeGlobalDB or {
                minimap = {}
            }
            TrackingEyeGlobalDB.minimap = TrackingEyeGlobalDB.minimap or {}
            
            if te.CreateFreeFrame then te.CreateFreeFrame() end
            te.UpdateIcon()
            
        elseif event == "PLAYER_LOGIN" then
            if te.InitMinimap then te.InitMinimap() end
            
            te.UpdateIcon()
            C_Timer.NewTicker(te.FARM_INTERVAL, te.RunFarmLogic)
            
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
            local spellId = select(3, ...)
            for _, id in ipairs(te.TRACKING_IDS) do
                if id == spellId then
                    te.state.lastCastSpell = spellId
                    te.UpdateIcon()
                    break
                end
            end
        elseif event == "MINIMAP_UPDATE_TRACKING" or event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or event == "UPDATE_SHAPESHIFT_FORM" or event == "SPELLS_CHANGED" then
            te.UpdateIcon()
            
            -- Re-check placement/visibility on spell changes (learning tracking)
            if event == "SPELLS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
                 if te.UpdatePlacement then te.UpdatePlacement() end
            end

            if event == "UPDATE_SHAPESHIFT_FORM" and TrackingEyeDB.autoTracking and TrackingEyeDB.selectedSpellId then
                local _, isFarming = te.GetPlayerStates()
                if not isFarming then
                    local currentTex = GetTrackingTexture()
                    local targetTex = GetSpellTexture(TrackingEyeDB.selectedSpellId)
                    
                    -- Check if we already cast this spell to prevent spamming
                    if currentTex ~= targetTex and te.state.lastCastSpell ~= TrackingEyeDB.selectedSpellId then
                        local usable, noMana = IsUsableSpell(TrackingEyeDB.selectedSpellId)
                        if usable or noMana then
                            te.CastTracking(TrackingEyeDB.selectedSpellId)
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
eventFrame:RegisterEvent("SPELLS_CHANGED")