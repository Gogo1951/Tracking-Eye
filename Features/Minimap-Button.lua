local addonName, ns = ...
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Free Frame Position
--------------------------------------------------------------------------------

--[[
    Position is stored in *absolute screen pixels* — `freePos.x` and
    `freePos.y` are the frame's center expressed at scale 1.0. Restore
    divides by the frame's current effective scale to convert back into
    the frame's own coordinate space (which is what SetPoint offsets are
    measured in). This makes the saved position survive UI-scale changes
    and Free Placement icon-scale changes without drifting.
]]
local function SaveFreePosition(frame)
    if not TrackingEyeDB or not frame then
        return
    end
    local x, y = frame:GetCenter()
    if not x or not y then
        return
    end
    local scale = frame:GetEffectiveScale()
    TrackingEyeDB.freePos = {x = x * scale, y = y * scale}
end

local function ApplyFreePosition(frame)
    if not frame then
        return
    end
    local pos = TrackingEyeDB and TrackingEyeDB.freePos

    --[[
        Migrate the legacy array format
        ({point, relativePoint, xOffset, yOffset}) to the new
        {x, y} screen-pixel format. Apply the old anchor briefly,
        read the resulting screen-pixel center, re-anchor in the new
        format, and overwrite the stored value.
    ]]
    if type(pos) == "table" and type(pos[1]) == "string" and type(pos[2]) == "string" then
        frame:ClearAllPoints()
        frame:SetPoint(pos[1], UIParent, pos[2], pos[3] or 0, pos[4] or 0)
        SaveFreePosition(frame)
        pos = TrackingEyeDB.freePos
    end

    frame:ClearAllPoints()
    if type(pos) == "table" and type(pos.x) == "number" and type(pos.y) == "number" then
        local scale = frame:GetEffectiveScale()
        frame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", pos.x / scale, pos.y / scale)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    --[[
        Clear user-placed even on plain restore. WoW silently flags any
        frame that has been moved with StartMoving/StopMovingOrSizing as
        user-placed for the rest of the session, and a stale flag can
        cause the client to write a layout-local entry on logout that
        out-races our SavedVariables on next login.
    ]]
    frame:SetUserPlaced(false)
end

ns.SaveFreeFramePosition = function()
    SaveFreePosition(ns.freeFrame)
end

--------------------------------------------------------------------------------
-- Visuals & Placement
--------------------------------------------------------------------------------
function ns.UpdateFreeFrameScale()
    if ns.freeFrame then
        local scale = (TrackingEyeDB and TrackingEyeDB.freeIconScale) or ns.GLOBAL_DEFAULTS.freeIconScale
        ns.freeFrame:SetScale(scale)
        --[[
            SetPoint offsets are interpreted in the frame's *own* scale.
            After a scale change those offsets resolve to a different
            screen position, so the frame visually drifts. Re-applying
            the position immediately after SetScale converts our stored
            absolute-pixel coords back into the new scale and pins the
            frame to its true location.
        ]]
        ApplyFreePosition(ns.freeFrame)
    end
end

function ns.UpdateFreeFrameShape()
    if not ns.freeFrame then
        return
    end
    local shape = (TrackingEyeDB and TrackingEyeDB.freeIconShape) or ns.GLOBAL_DEFAULTS.freeIconShape
    local isSquare = (shape == ns.SHAPES.SQUARE)

    ns.freeFrame.circleBg:SetShown(not isSquare)
    ns.freeFrame.circleBorder:SetShown(not isSquare)
    ns.freeFrame.squareBg:SetShown(isSquare)
    ns.freeFrame.squareBorder:SetShown(isSquare)
end

function ns.UpdatePlacement()
    if not TrackingEyeDB then
        return
    end

    if not ns.HasTrackingAbility() then
        if ns.freeFrame then
            ns.freeFrame:Hide()
        end
        LDBIcon:Hide(addonName)
        return
    end

    if not TrackingEyeDB.minimap then
        TrackingEyeDB.minimap = {}
    end

    if TrackingEyeDB.freePlacement then
        TrackingEyeDB.minimap.hide = true
        LDBIcon:Hide(addonName)
        if ns.freeFrame then
            --[[
                Re-apply position on every show. Defends against any
                other code path (LibDBIcon callbacks, addon-on-addon
                conflicts, layout-local replay) that might have
                silently re-anchored the frame while it was hidden.
            ]]
            ApplyFreePosition(ns.freeFrame)
            ns.freeFrame:Show()
        end
    else
        TrackingEyeDB.minimap.hide = false
        LDBIcon:Show(addonName)
        if ns.freeFrame then
            ns.freeFrame:Hide()
        end
    end

    ns.UpdateFreeFrameScale()
    ns.UpdateFreeFrameShape()
end

function ns.BuildTooltip(tooltip)
    -- Header
    tooltip:AddDoubleLine(ns.GetColor("TITLE") .. ns.L["ADDON_TITLE"] .. "|r", ns.GetColor("MUTED") .. ns.Version .. "|r")
    tooltip:AddLine(" ")
    tooltip:AddLine(" ")

    -- Tracking Menu
    tooltip:AddLine(ns.GetColor("TITLE") .. ns.L["TRACKING_MENU"] .. "|r")
    tooltip:AddLine(ns.GetColor("DESC") .. ns.L["TRACKING_MENU_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddLine(ns.GetColor("INFO") .. ns.L["LEFT_CLICK"] .. "|r")
    tooltip:AddLine(" ")

    -- Persistent Tracking Ability
    tooltip:AddLine(ns.GetColor("TITLE") .. ns.L["PERSISTENT_ABILITY"] .. "|r")
    local selectedSpellId = TrackingEyeCharDB and TrackingEyeCharDB.selectedSpellId
    if selectedSpellId then
        local name = GetSpellInfo(selectedSpellId) or ns.L["NONE_SET"]
        tooltip:AddLine("|T" .. (GetSpellTexture(selectedSpellId) or "") .. ":16|t " .. ns.GetColor("TEXT") .. name .. "|r")
    else
        tooltip:AddLine("|TInterface\\Icons\\inv_misc_map_01:16|t " .. ns.GetColor("DESC") .. ns.L["NONE_SET"] .. "|r")
    end
    tooltip:AddDoubleLine(
        ns.GetColor("INFO") .. ns.L["RIGHT_CLICK"] .. "|r",
        ns.GetColor("INFO") .. ns.L["CLEAR_TRACKING"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Persistent Tracking Toggle
    local persistentState =
        (TrackingEyeCharDB and TrackingEyeCharDB.autoTracking) and (ns.GetColor("ON") .. ns.L["ENABLED"] .. "|r") or
        (ns.GetColor("OFF") .. ns.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(ns.GetColor("TITLE") .. ns.L["PERSISTENT_TRACKING"] .. "|r", persistentState)
    tooltip:AddLine(ns.GetColor("DESC") .. ns.L["PERSISTENT_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(
        ns.GetColor("INFO") .. ns.L["SHIFT_LEFT"] .. "|r",
        ns.GetColor("INFO") .. ns.L["TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Farm Mode Toggle
    local farmState =
        (TrackingEyeCharDB and TrackingEyeCharDB.farmingMode) and (ns.GetColor("ON") .. ns.L["ENABLED"] .. "|r") or
        (ns.GetColor("OFF") .. ns.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(ns.GetColor("TITLE") .. ns.L["FARM_MODE"] .. "|r", farmState)
    tooltip:AddLine(ns.GetColor("DESC") .. ns.L["FARMING_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(
        ns.GetColor("INFO") .. ns.L["SHIFT_RIGHT"] .. "|r",
        ns.GetColor("INFO") .. ns.L["TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")

    -- Free Placement Mode
    local freePlacementState =
        (TrackingEyeDB and TrackingEyeDB.freePlacement) and
        (ns.GetColor("ON") .. ns.L["ENABLED"] .. "|r") or
        (ns.GetColor("OFF") .. ns.L["DISABLED"] .. "|r")
    tooltip:AddDoubleLine(ns.GetColor("TITLE") .. ns.L["PLACEMENT_MODE"] .. "|r", freePlacementState)
    tooltip:AddLine(ns.GetColor("DESC") .. ns.L["PLACEMENT_DESC"] .. "|r", 1, 1, 1, true)
    tooltip:AddDoubleLine(
        ns.GetColor("INFO") .. ns.L["SHIFT_MIDDLE"] .. "|r",
        ns.GetColor("INFO") .. ns.L["TOGGLE"] .. "|r"
    )
    tooltip:AddLine(" ")
    tooltip:AddLine(ns.GetColor("DESC") .. ns.L["TOOLTIP_OPTIONS_HINT"] .. "|r", 1, 1, 1, true)
end

function ns.RefreshTooltip()
    local function TryRefresh(frame)
        if frame and frame:IsVisible() then
            if MouseIsOver(frame) or GameTooltip:GetOwner() == frame then
                local onEnter = frame:GetScript("OnEnter")
                if onEnter then
                    GameTooltip:Hide()
                    onEnter(frame)
                end
            end
        end
    end

    if ns.freeFrame then
        TryRefresh(ns.freeFrame)
    end

    local minimapButton = LDBIcon:GetMinimapButton(addonName)
    if minimapButton then
        TryRefresh(minimapButton)
    end
end

--------------------------------------------------------------------------------
-- Interaction
--------------------------------------------------------------------------------
local function OnClick(self, button)
    if not TrackingEyeCharDB then
        return
    end

    local updateNeeded = false

    if IsShiftKeyDown() then
        if button == "MiddleButton" then
            if TrackingEyeDB then
                TrackingEyeDB.freePlacement = not TrackingEyeDB.freePlacement
                ns.UpdatePlacement()
                updateNeeded = true
            end
        elseif button == "LeftButton" then
            TrackingEyeCharDB.autoTracking = not TrackingEyeCharDB.autoTracking
            updateNeeded = true
        elseif button == "RightButton" then
            TrackingEyeCharDB.farmingMode = not TrackingEyeCharDB.farmingMode
            updateNeeded = true
        end
    else
        if button == "LeftButton" then
            ns.ToggleMenu(self)
        elseif button == "RightButton" then
            ns.ClearTracking()
            updateNeeded = true
        end
    end

    if updateNeeded then
        ns.RefreshTooltip()
    end
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------
function ns.CreateFreeFrame()
    --[[
        Anonymous frame (nil name) on purpose. WoW's per-character
        layout-local.txt cache keys on frame name — if this frame has
        any name, WoW will look it up there at creation time and apply
        the per-character cached position, overriding the account-wide
        TrackingEyeDB.freePos. SetUserPlaced(false) from Lua does NOT
        prevent that lookup. Making the frame anonymous removes it from
        the layout-local system entirely, so positioning is owned
        100% by TrackingEyeDB.freePos.
    ]]
    local frame = CreateFrame("Button", nil, UIParent)
    frame:SetSize(37, 37)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:RegisterForClicks("AnyUp")
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")

    -- Circle elements
    frame.circleBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.circleBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    frame.circleBg:SetSize(24, 24)
    frame.circleBg:SetPoint("CENTER")
    frame.circleBg:SetVertexColor(0, 0, 0, 0.6)

    frame.circleBorder = frame:CreateTexture(nil, "OVERLAY")
    frame.circleBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    frame.circleBorder:SetSize(62, 62)
    frame.circleBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)

    -- Square elements
    frame.squareBorder = frame:CreateTexture(nil, "BACKGROUND")
    frame.squareBorder:SetColorTexture(0, 0, 0, 0.8)
    frame.squareBorder:SetSize(27, 27)
    frame.squareBorder:SetPoint("CENTER")

    frame.squareBg = frame:CreateTexture(nil, "BACKGROUND")
    frame.squareBg:SetColorTexture(0, 0, 0, 0)
    frame.squareBg:SetSize(1, 1)
    frame.squareBg:SetPoint("CENTER")

    -- Shared icon
    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetSize(24, 24)
    frame.icon:SetPoint("CENTER")

    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript(
        "OnDragStop",
        function(self)
            self:StopMovingOrSizing()
            --[[
                StartMoving / StopMovingOrSizing implicitly flag the
                frame as user-placed. Clear the flag so WoW does not
                write a layout-local entry that out-races our
                SavedVariables on next login.
            ]]
            self:SetUserPlaced(false)
            SaveFreePosition(self)
            --[[
                Re-anchor immediately. After a drag the live anchor is
                whatever WoW chose during the move, which is not the
                stable CENTER -> UIParent BOTTOMLEFT anchor we
                serialize. Normalizing now means a Show/Hide cycle or a
                scale change does not shift the icon.
            ]]
            ApplyFreePosition(self)
        end
    )
    frame:SetScript("OnClick", OnClick)
    frame:SetScript(
        "OnEnter",
        function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
            ns.BuildTooltip(GameTooltip)
            GameTooltip:Show()
        end
    )
    frame:SetScript(
        "OnLeave",
        function()
            GameTooltip:Hide()
        end
    )

    ns.freeFrame = frame
    --[[
        ApplyFreePosition does its own ClearAllPoints, handles the
        legacy {point, relativePoint, x, y} array migration, and pins
        the frame to its saved screen-pixel coordinates via the stable
        CENTER -> UIParent BOTTOMLEFT anchor.
    ]]
    ApplyFreePosition(frame)
    ns.UpdatePlacement()
end

function ns.InitMinimap()
    ns.ldb =
        LDB:NewDataObject(
        addonName,
        {
            type = "launcher",
            icon = ns.state.currentIcon or ns.ICON_DEFAULT,
            OnClick = OnClick,
            OnTooltipShow = function(tooltip)
                ns.BuildTooltip(tooltip)
            end
        }
    )

    if TrackingEyeDB and TrackingEyeDB.minimap then
        LDBIcon:Register(addonName, ns.ldb, TrackingEyeDB.minimap)
    end

    local button = LDBIcon:GetMinimapButton(addonName)
    if button then
        button:SetScript(
            "OnEnter",
            function(self)
                GameTooltip:SetOwner(self, "ANCHOR_NONE")
                GameTooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT")
                ns.BuildTooltip(GameTooltip)
                GameTooltip:Show()
            end
        )
        button:SetScript(
            "OnLeave",
            function()
                GameTooltip:Hide()
            end
        )
    end

    ns.UpdatePlacement()
end
