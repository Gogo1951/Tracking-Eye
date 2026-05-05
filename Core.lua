local addonName, te = ...

local eventFrame = CreateFrame("Frame")

--------------------------------------------------------------------------------
-- Version
--------------------------------------------------------------------------------
local function GetVersion()
    local version =
        C_AddOns and C_AddOns.GetAddOnMetadata(addonName, "Version") or GetAddOnMetadata(addonName, "Version")
    if not version or version:find("@") then
        return "Dev"
    end
    return version
end

te.Version = GetVersion()

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
function te.GetColor(key)
    return "|cff" .. (te.COLORS[key] or "FFFFFF")
end

function te.GetSpellName(spellId)
    local name = GetSpellInfo(spellId)
    return name
end

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

function te.IsRestrictedZone()
    local inInstance = IsInInstance()
    if inInstance then
        return true
    end
    return IsResting()
end

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------
function te.UpdateIcon()
    local texture = nil
    local isCat = te.GetPlayerStates()

    -- Clear cat-form humanoid tracking state if we've left cat form
    if te.state.lastCastSpell == te.SPELLS.DRUID_HUMANOIDS and not isCat then
        te.state.lastCastSpell = nil
    end

    if te.state.lastCastSpell then
        texture = GetSpellTexture(te.state.lastCastSpell)
    end

    if not texture then
        texture = GetTrackingTexture()
    end

    if not texture and TrackingEyeCharDB and TrackingEyeCharDB.lastIcon then
        texture = TrackingEyeCharDB.lastIcon
    end

    te.state.currentIcon = texture or te.ICON_DEFAULT

    if TrackingEyeCharDB and texture and texture ~= te.ICON_DEFAULT then
        TrackingEyeCharDB.lastIcon = texture
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
    if TrackingEyeCharDB then
        TrackingEyeCharDB.selectedSpellId = nil
        TrackingEyeCharDB.lastIcon = nil
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

-- TryRecastPersistent handles mid-play recasts triggered by
-- UPDATE_SHAPESHIFT_FORM (e.g. druid leaving cat form). It relies
-- on GetTrackingTexture to compare the active spell against the
-- saved one.
--
-- If GetTrackingTexture returns nil, the tracking API is not ready
-- (happens for 10+ seconds during the Classic login/reload event
-- storm). Casting blindly here causes the login-recast bug. DO NOT
-- remove the nil bail — it is the fix. Post-death recasts are
-- handled separately by PLAYER_UNGHOST, which bypasses this
-- function entirely.
local function TryRecastPersistent()
    if not TrackingEyeCharDB or not TrackingEyeCharDB.autoTracking or not TrackingEyeCharDB.selectedSpellId then
        return
    end

    local _, isFarming = te.GetPlayerStates()
    if isFarming then
        return
    end

    local spellId = TrackingEyeCharDB.selectedSpellId
    if not IsPlayerSpell(spellId) then
        return
    end

    local currentTexture = GetTrackingTexture()

    -- If the tracking API hasn't initialized yet (returns nil during
    -- login/reload), bail. We cannot tell whether the spell is already
    -- active, so casting would be a guess. DO NOT remove this check.
    if not currentTexture then
        return
    end

    local targetTexture = GetSpellTexture(spellId)

    -- If the correct spell is already active, sync lastCastSpell and
    -- skip the cast
    if targetTexture and currentTexture == targetTexture then
        te.state.lastCastSpell = spellId
        return
    end

    if te.state.lastCastSpell ~= spellId then
        te.CastTracking(spellId)
    end
end

--------------------------------------------------------------------------------
-- Welcome Message
--------------------------------------------------------------------------------
local function PrintMessage(msg)
    print(te.GetColor("INFO") .. "Tracking Eye" .. "|r "
       .. te.GetColor("SEP") .. "//" .. "|r "
       .. te.GetColor("TEXT") .. msg .. "|r")
end

local function PrintWelcome()
    if not TrackingEyeCharDB or not TrackingEyeCharDB.showWelcome then return end
    local cmd = te.GetColor("INFO") .. "/te" .. "|r"
    PrintMessage(te.L["CHAT_LOADED"]:format(cmd))
end

--------------------------------------------------------------------------------
-- Event Handling
--------------------------------------------------------------------------------
eventFrame:SetScript(
    "OnEvent",
    function(_, event, arg1, ...)
        if event == "ADDON_LOADED" and arg1 == addonName then
            if not TrackingEyeCharDB then
                TrackingEyeCharDB = {}
            end

            -- One-time migration: legacy per-character TrackingEyeDB → TrackingEyeCharDB.
            -- Copies any field not already set in the new table, then wipes the old.
            -- The legacy declaration in the TOC will be removed in a future release
            -- once active users have had time to migrate.
            --
            -- TODO(2026-07): Stage 2 of the SavedVariables migration.
            -- By July 2026, active users will have run the Stage 1 migration below
            -- at least once. We can then drop the legacy TrackingEyeDB declaration
            -- and complete the account-wide rename TrackingEyeGlobalDB → TrackingEyeDB
            -- (matching the style guide canonical names AddonNameDB / AddonNameCharDB).
            --
            -- Prompt to run at that time:
            --
            -- """
            -- Stage 2 of the SavedVariables migration. We need to:
            --
            --   1. In TrackingEye.toc:
            --      - Remove ", TrackingEyeDB" from the
            --        ## SavedVariablesPerCharacter: line.
            --      - Change the ## SavedVariables: line to
            --        "TrackingEyeDB, TrackingEyeGlobalDB".
            --   2. In Core.lua's ADDON_LOADED handler:
            --      - Delete the Stage 1 TrackingEyeDB migration block (the
            --        per-character rename is now complete; the wipe is a no-op).
            --      - Add a parallel migration for the account-wide rename
            --        TrackingEyeGlobalDB → TrackingEyeDB using the same pattern:
            --        copy non-nil fields, wipe(), set the legacy global to nil.
            --   3. Run replace_all TrackingEyeGlobalDB → TrackingEyeDB in every
            --      .lua file (Core, Farm-Mode, Tracking-Menu, Minimap-Button,
            --      Options) and both READMEs.
            --   4. In README-Technical.md's Migration Chain subsection: mark
            --      step 1 complete, mark step 2 active.
            --
            -- A Stage 3 release (a few weeks after Stage 2 ships) drops
            -- TrackingEyeGlobalDB from the TOC entirely and removes the
            -- Stage 2 migration block.
            -- """
            if TrackingEyeDB and next(TrackingEyeDB) ~= nil then
                for k, v in pairs(TrackingEyeDB) do
                    if TrackingEyeCharDB[k] == nil then
                        TrackingEyeCharDB[k] = v
                    end
                end
                wipe(TrackingEyeDB)
            end
            TrackingEyeDB = nil

            for k, v in pairs(te.CHAR_DEFAULTS) do
                if TrackingEyeCharDB[k] == nil then
                    TrackingEyeCharDB[k] = v
                end
            end
            if TrackingEyeCharDB.farmCycleSpells == nil then
                TrackingEyeCharDB.farmCycleSpells = {}
                for id, enabled in pairs(te.FARM_CYCLE_DEFAULTS) do
                    TrackingEyeCharDB.farmCycleSpells[id] = enabled
                end
            end

            if not TrackingEyeGlobalDB then
                TrackingEyeGlobalDB = {}
            end
            if not TrackingEyeGlobalDB.minimap then
                TrackingEyeGlobalDB.minimap = {}
            end
            for k, v in pairs(te.GLOBAL_DEFAULTS) do
                if TrackingEyeGlobalDB[k] == nil then
                    TrackingEyeGlobalDB[k] = v
                end
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
            PrintWelcome()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
            local spellId = select(2, ...)
            if te.TRACKING_SET[spellId] then
                te.state.lastCastSpell = spellId
                te.UpdateIcon()
            end
        elseif event == "PLAYER_UNGHOST" then
            -- After resurrection, tracking is genuinely cleared by the
            -- server. Recast directly without relying on
            -- GetTrackingTexture — it would return nil here regardless,
            -- and we know a recast is needed.
            C_Timer.After(
                1.5,
                function()
                    if not TrackingEyeCharDB or not TrackingEyeCharDB.autoTracking or not TrackingEyeCharDB.selectedSpellId then
                        te.UpdateIcon()
                        return
                    end

                    local _, isFarming = te.GetPlayerStates()
                    if isFarming then
                        te.UpdateIcon()
                        return
                    end

                    local spellId = TrackingEyeCharDB.selectedSpellId
                    if IsPlayerSpell(spellId) then
                        te.CastTracking(spellId)
                    end
                    te.UpdateIcon()
                end
            )
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
                -- Delay recast so the GCD from shapeshifting expires
                -- before we attempt to cast
                C_Timer.After(
                    1.5,
                    function()
                        TryRecastPersistent()
                    end
                )
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