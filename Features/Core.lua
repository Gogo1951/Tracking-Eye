local addonName, ns = ...

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

ns.Version = GetVersion()

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------
ns.state = {
    currentIcon = ns.ICON_DEFAULT,
    wasFarming = false,
    lastCastSpell = nil
}

ns.optionsOpen = false

--[[
    Single write-site for lastCastSpell. Mirrors the value into
    TrackingEyeCharDB so the icon survives logout/login — without
    this, the API blackout during the Classic login event storm
    leaves the minimap icon on the default until the next user
    action, even though tracking is still active server-side.
]]
function ns.SetLastCast(spellId)
    ns.state.lastCastSpell = spellId
    if TrackingEyeCharDB then
        TrackingEyeCharDB.lastCastSpell = spellId
    end
end

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------
function ns.GetColor(key)
    return ns.COLOR_PREFIX .. (ns.COLORS[key] or "FFFFFF")
end

function ns.GetPlayerStates()
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
            if id == ns.SPELLS.CAT then
                isCat = true
            elseif ns.FARM_FORMS[id] then
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

function ns.CanCast()
    return not (UnitIsDeadOrGhost("player") or IsStealthed() or UnitCastingInfo("player") or
        UnitAffectingCombat("player"))
end

function ns.HasTrackingAbility()
    for _, id in ipairs(ns.TRACKING_IDS) do
        if IsPlayerSpell(id) then
            return true
        end
    end
    return false
end

function ns.IsRestrictedZone()
    local inInstance = IsInInstance()
    if inInstance then
        return true
    end
    return IsResting()
end

--------------------------------------------------------------------------------
-- Icon Management
--------------------------------------------------------------------------------
--[[
    GetTrackingTexture is unreliable in Anniversary — returns nil for
    several active trackers (notably racial passives like Find
    Treasure) even when the Blizzard minimap tracking icon clearly
    shows them. Read MiniMapTrackingIcon directly and match its
    texture back to a known tracking spell. This also lets us
    self-heal the persisted lastCastSpell for users who toggled
    tracking via the default WoW UI without ever casting through
    the addon.
]]
local function ReadActiveTracking()
    if not MiniMapTrackingIcon then
        return nil, nil
    end
    local tex = MiniMapTrackingIcon:GetTexture()
    if not tex then
        return nil, nil
    end
    for _, id in ipairs(ns.TRACKING_IDS) do
        if GetSpellTexture(id) == tex then
            return tex, id
        end
    end
    return nil, nil
end

function ns.UpdateIcon()
    local texture = nil
    local isCat = ns.GetPlayerStates()

    -- Clear cat-form humanoid tracking state if we've left cat form
    if ns.state.lastCastSpell == ns.SPELLS.DRUID_HUMANOIDS and not isCat then
        ns.SetLastCast(nil)
    end

    --[[
        Prefer live sources over the saved lastCastSpell. If the user
        toggles tracking outside the addon (e.g., default WoW UI) the
        saved spell can lag behind reality; consulting the minimap
        icon and GetTrackingTexture first keeps the icon honest, and
        the persistence branch below self-heals the saved value.
    ]]
    local mirroredTex, mirroredId = ReadActiveTracking()
    if mirroredTex then
        texture = mirroredTex
        if mirroredId and (not TrackingEyeCharDB or TrackingEyeCharDB.lastCastSpell ~= mirroredId) then
            ns.SetLastCast(mirroredId)
        end
    end

    if not texture then
        texture = GetTrackingTexture()
    end

    if not texture and ns.state.lastCastSpell then
        texture = GetSpellTexture(ns.state.lastCastSpell)
    end

    if not texture and TrackingEyeCharDB and TrackingEyeCharDB.selectedSpellId then
        local selected = TrackingEyeCharDB.selectedSpellId
        if selected ~= ns.SPELLS.DRUID_HUMANOIDS or isCat then
            texture = GetSpellTexture(selected)
        end
    end

    ns.state.currentIcon = texture or ns.ICON_DEFAULT

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
    ns.SetLastCast(nil)
    if TrackingEyeCharDB then
        TrackingEyeCharDB.selectedSpellId = nil
    end
    CancelTrackingBuff()

    --[[
        Set icon to default immediately (CancelTrackingBuff is async,
        so GetTrackingTexture still returns the old texture for a frame)
    ]]
    ns.state.currentIcon = ns.ICON_DEFAULT
    if ns.ldb then
        ns.ldb.icon = ns.ICON_DEFAULT
    end
    if ns.freeFrame and ns.freeFrame.icon then
        ns.freeFrame.icon:SetTexture(ns.ICON_DEFAULT)
    end
    if ns.RefreshTooltip then
        ns.RefreshTooltip()
    end
end

--------------------------------------------------------------------------------
-- Casting
--------------------------------------------------------------------------------
function ns.CastTracking(spellId)
    if not spellId or not IsPlayerSpell(spellId) then
        return
    end

    if spellId == ns.SPELLS.DRUID_HUMANOIDS then
        local isCat = ns.GetPlayerStates()
        if not isCat then
            return
        end
    end

    local start, duration = GetSpellCooldown(spellId)
    if start and duration and start > 0 and duration > 0 then
        return
    end

    --[[
        Do not write lastCastSpell or refresh the icon here — the cast
        can still fail silently (LOS, range, server reject). Let
        UNIT_SPELLCAST_SUCCEEDED be the single source of truth for a
        successful cast; otherwise TryRecastPersistent would see a
        matching lastCastSpell and skip a real recast.
    ]]
    pcall(CastSpellByID, spellId)
end

--------------------------------------------------------------------------------
-- Persistent Tracking Recast Helper
--------------------------------------------------------------------------------

--[[
    TryRecastPersistent handles mid-play recasts triggered by
    UPDATE_SHAPESHIFT_FORM (e.g. druid leaving cat form). It relies
    on GetTrackingTexture to compare the active spell against the
    saved one.

    If GetTrackingTexture returns nil, the tracking API is not ready
    (happens for 10+ seconds during the Classic login/reload event
    storm). Casting blindly here causes the login-recast bug. DO NOT
    remove the nil bail — it is the fix. Post-death recasts are
    handled separately by PLAYER_UNGHOST, which bypasses this
    function entirely.
]]
local function TryRecastPersistent()
    if not TrackingEyeCharDB or not TrackingEyeCharDB.autoTracking or not TrackingEyeCharDB.selectedSpellId then
        return
    end

    local _, isFarming = ns.GetPlayerStates()
    if isFarming then
        return
    end

    local spellId = TrackingEyeCharDB.selectedSpellId
    if not IsPlayerSpell(spellId) then
        return
    end

    local currentTexture = GetTrackingTexture()

    --[[
        If the tracking API hasn't initialized yet (returns nil during
        login/reload), bail. We cannot tell whether the spell is already
        active, so casting would be a guess. DO NOT remove this check.
    ]]
    if not currentTexture then
        return
    end

    local targetTexture = GetSpellTexture(spellId)

    --[[
        If the correct spell is already active, sync lastCastSpell and
        skip the cast
    ]]
    if targetTexture and currentTexture == targetTexture then
        ns.SetLastCast(spellId)
        return
    end

    if ns.state.lastCastSpell ~= spellId then
        ns.CastTracking(spellId)
    end
end

--------------------------------------------------------------------------------
-- Welcome Message
--------------------------------------------------------------------------------
local function PrintMessage(msg)
    print(ns.GetColor("INFO") .. ns.L["ADDON_TITLE"] .. "|r "
       .. ns.GetColor("SEPARATOR") .. "//" .. "|r "
       .. ns.GetColor("TEXT") .. msg .. "|r")
end

local function PrintWelcome()
    if not TrackingEyeDB or not TrackingEyeDB.showWelcome then return end
    PrintMessage(ns.L["CHAT_LOADED"]:format(ns.Version))
end

--[[
    Poll until the Blizzard minimap tracking icon has a texture, then
    refresh the icon once. During the Classic login event storm
    MiniMapTrackingIcon may not have its texture set yet, so every
    UpdateIcon call falls through to the default icon, and
    MINIMAP_UPDATE_TRACKING does not fire because tracking state
    hasn't changed — without this poll the icon stays stuck on
    default until the user toggles something.
]]
local function PollUntilTrackingReady(attempts)
    attempts = attempts or 0
    if MiniMapTrackingIcon and MiniMapTrackingIcon:GetTexture() then
        ns.UpdateIcon()
        return
    end
    if attempts >= 15 then
        return
    end
    C_Timer.After(1, function() PollUntilTrackingReady(attempts + 1) end)
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
            if not TrackingEyeDB then
                TrackingEyeDB = {}
            end

            --[[
                Cross-character reset propagation. When the user hits the
                Reset button, the account-wide resetGeneration is bumped.
                Any character whose stored resetGeneration is behind that
                value has its per-character settings wiped on next login,
                so a single Reset clears every alt eventually.
            ]]
            local globalGen = TrackingEyeDB.resetGeneration or 0
            if (TrackingEyeCharDB.resetGeneration or 0) < globalGen then
                wipe(TrackingEyeCharDB)
                TrackingEyeCharDB.resetGeneration = globalGen
            end

            for k, v in pairs(ns.CHAR_DEFAULTS) do
                if TrackingEyeCharDB[k] == nil then
                    TrackingEyeCharDB[k] = v
                end
            end
            if TrackingEyeCharDB.farmCycleSpells == nil then
                TrackingEyeCharDB.farmCycleSpells = {}
                for id, enabled in pairs(ns.FARM_CYCLE_DEFAULTS) do
                    TrackingEyeCharDB.farmCycleSpells[id] = enabled
                end
            end

            if not TrackingEyeDB.minimap then
                TrackingEyeDB.minimap = {}
            end
            for k, v in pairs(ns.GLOBAL_DEFAULTS) do
                if TrackingEyeDB[k] == nil then
                    TrackingEyeDB[k] = v
                end
            end

            --[[
                Restore last-cast spell so the icon can render correctly
                during the login API blackout, before GetTrackingTexture
                is ready.
            ]]
            ns.state.lastCastSpell = TrackingEyeCharDB.lastCastSpell

            if ns.CreateFreeFrame then
                ns.CreateFreeFrame()
            end
            ns.UpdateIcon()
        elseif event == "PLAYER_LOGIN" then
            if ns.InitMinimap then
                ns.InitMinimap()
            end
            if ns.InitFarmMode then
                ns.InitFarmMode()
            end
            if ns.InitOptions then
                ns.InitOptions()
            end
            ns.UpdateIcon()
            PollUntilTrackingReady()
            PrintWelcome()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
            local spellId = select(2, ...)
            if ns.TRACKING_SET[spellId] then
                ns.SetLastCast(spellId)
                ns.UpdateIcon()
            end
        elseif event == "PLAYER_LOGOUT" then
            --[[
                Final position save before WoW serializes SavedVariables.
                OnDragStop already writes freePos after every drag, but
                logging out here guarantees we capture the live position
                even if something (e.g., another addon nudging the
                frame, a SetClampedToScreen rebound) shifted it after
                the last drag.
            ]]
            if ns.SaveFreeFramePosition then
                ns.SaveFreeFramePosition()
            end
        elseif event == "PLAYER_UNGHOST" then
            --[[
                After resurrection, tracking is genuinely cleared by the
                server. Recast directly without relying on
                GetTrackingTexture — it would return nil here regardless,
                and we know a recast is needed.
            ]]
            C_Timer.After(
                1.5,
                function()
                    if not TrackingEyeCharDB or not TrackingEyeCharDB.autoTracking or not TrackingEyeCharDB.selectedSpellId then
                        ns.UpdateIcon()
                        return
                    end

                    local _, isFarming = ns.GetPlayerStates()
                    if isFarming then
                        ns.UpdateIcon()
                        return
                    end

                    local spellId = TrackingEyeCharDB.selectedSpellId
                    if IsPlayerSpell(spellId) then
                        ns.CastTracking(spellId)
                    end
                    ns.UpdateIcon()
                end
            )
        elseif
            event == "MINIMAP_UPDATE_TRACKING" or event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" or
                event == "UPDATE_SHAPESHIFT_FORM" or
                event == "SPELLS_CHANGED"
         then
            ns.UpdateIcon()

            if event == "SPELLS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
                if ns.UpdatePlacement then
                    ns.UpdatePlacement()
                end
                if ns.InvalidateFarmCache then
                    ns.InvalidateFarmCache()
                end
            end

            if event == "UPDATE_SHAPESHIFT_FORM" then
                --[[
                    Delay recast so the GCD from shapeshifting expires
                    before we attempt to cast
                ]]
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
eventFrame:RegisterEvent("PLAYER_LOGOUT")
