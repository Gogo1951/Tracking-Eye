local addonName, te = ...
local eventFrame = CreateFrame("Frame")

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------
te.state = {
    currentIcon = te.ICON_DEFAULT,
    wasFarming = false,
    lastCastSpell = nil
}

te.optionsOpen = false

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------
function te.GetPlayerStates()
    local isCat, isFarming = false, false

    if UnitOnTaxi("player") then
        return false, false
    end

    if IsMounted() and not UnitAffectingCombat("player") then
        isFarming = true
    end

    for i = 1, 40 do
        local name, _, _, _, _, _, _, _, _, id = UnitBuff("player", i)
        if not name then
            break
        end

        if id then
            if id == te.SPELLS.CAT then
                isCat = true
            elseif te.FARM_FORMS[id] then
                isFarming = true
            end
        end

        -- Early exit once both flags are set
        if isCat and isFarming then
            break
        end
    end

    return isCat, isFarming
end

function te.CanCast()
    return not (UnitIsDeadOrGhost("player") or IsStealthed() or UnitCastingInfo("player") or
        UnitAffectingCombat("player"))
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
    local isCat = te.GetPlayerStates()

    -- Clear cat-form humanoid tracking state if we've left cat form
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

    -- Set icon to default immediately (CancelTrackingBuff is async,
    -- so GetTrackingTexture still returns the old texture for a frame)
    te.state.currentIcon = te.ICON_DEFAULT
    if te.ldb then
        te.ldb.icon = te.ICON_DEFAULT
    end
    if te.freeFrame and te.freeFrame.icon then
        te.freeFrame.icon:SetTexture(te.ICON_DEFAULT)
    end
    if te.RefreshTooltip then
        te.RefreshTooltip()
    end
end

--------------------------------------------------------------------------------
-- Persistent Tracking Recast Helper
--------------------------------------------------------------------------------
local function TryRecastPersistent()
    if not TrackingEyeDB or not TrackingEyeDB.autoTracking or not TrackingEyeDB.selectedSpellId then
        return
    end

    local _, isFarming = te.GetPlayerStates()
    if isFarming then
        return
    end

    local spellId = TrackingEyeDB.selectedSpellId
    if not IsPlayerSpell(spellId) then
        return
    end

    local currentTex = GetTrackingTexture()
    local targetTex = GetSpellTexture(spellId)
    if currentTex ~= targetTex and te.state.lastCastSpell ~= spellId then
        te.CastTracking(spellId)
    end
end

--------------------------------------------------------------------------------
-- Slash Command
--------------------------------------------------------------------------------
SLASH_TRACKINGEYE1 = "/te"
SLASH_TRACKINGEYE2 = "/trackingeye"
SlashCmdList["TRACKINGEYE"] = function()
    te.OpenOptions()
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
eventFrame:SetScript(
    "OnEvent",
    function(_, event, arg1, ...)
        if event == "ADDON_LOADED" and arg1 == addonName then
            if not TrackingEyeDB then
                TrackingEyeDB = {}
            end

            if TrackingEyeDB.autoTracking == nil then
                TrackingEyeDB.autoTracking = true
            end
            if TrackingEyeDB.farmingMode == nil then
                TrackingEyeDB.farmingMode = true
            end
            if TrackingEyeDB.farmInterval == nil then
                TrackingEyeDB.farmInterval = te.FARM_INTERVAL_DEFAULT
            end
            if TrackingEyeDB.farmCycleSpells == nil then
                TrackingEyeDB.farmCycleSpells = {}
                for id, v in pairs(te.FARM_CYCLE_DEFAULTS) do
                    TrackingEyeDB.farmCycleSpells[id] = v
                end
            end

            if not TrackingEyeGlobalDB then
                TrackingEyeGlobalDB = {}
            end
            if not TrackingEyeGlobalDB.minimap then
                TrackingEyeGlobalDB.minimap = {}
            end
            if TrackingEyeGlobalDB.freeIconScale == nil then
                TrackingEyeGlobalDB.freeIconScale = te.FREE_ICON_SCALE_DEFAULT
            end
            if TrackingEyeGlobalDB.freeIconShape == nil then
                TrackingEyeGlobalDB.freeIconShape = te.FREE_ICON_SHAPE_DEFAULT
            end

            if te.CreateFreeFrame then
                te.CreateFreeFrame()
            end
            te.UpdateIcon()
        elseif event == "PLAYER_LOGIN" then
            if te.InitMinimap then
                te.InitMinimap()
            end
            if te.InitFarmMode then
                te.InitFarmMode()
            end
            if te.InitOptions then
                te.InitOptions()
            end
            te.UpdateIcon()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
            local spellId = select(2, ...)
            if te.TRACKING_SET[spellId] then
                te.state.lastCastSpell = spellId
                te.UpdateIcon()
            end
        elseif event == "PLAYER_UNGHOST" then
            -- Delay recast slightly so the client settles after resurrection
            C_Timer.After(1.5, function()
                TryRecastPersistent()
                te.UpdateIcon()
            end)
        elseif
            event == "MINIMAP_UPDATE_TRACKING" or event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or
                event == "UPDATE_SHAPESHIFT_FORM" or
                event == "SPELLS_CHANGED"
         then
            te.UpdateIcon()

            if event == "SPELLS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
                if te.UpdatePlacement then
                    te.UpdatePlacement()
                end
                if te.InvalidateFarmCache then
                    te.InvalidateFarmCache()
                end
            end

            if event == "UPDATE_SHAPESHIFT_FORM" then
                C_Timer.After(1.5, function()
                    TryRecastPersistent()
                end)
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
eventFrame:RegisterEvent("PLAYER_UNGHOST")