local _, ns = ...

--------------------------------------------------------------------------------
-- Free Frame Position
--------------------------------------------------------------------------------

--[[
    Position is stored as the frame's center in UI units at scale 1.0
    (`freePos.x`, `freePos.y`), not in physical screen pixels. Restore
    divides by the frame's current effective scale to convert back into
    the frame's own coordinate space (which is what SetPoint offsets are
    measured in). This makes the saved position survive UI-scale changes
    and Free Placement icon-scale changes without drifting.
]]
local function SaveFreePosition(frame)
	if not ns.db or not frame then
		return
	end
	local x, y = frame:GetCenter()
	if not x or not y then
		return
	end
	local scale = frame:GetEffectiveScale()
	ns.db.global.freePos = { x = x * scale, y = y * scale }
end

local function ApplyFreePosition(frame)
	if not frame then
		return
	end
	local pos = ns.db and ns.db.global.freePos

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

--[[
    Backstop only — OnDragStop already saves after every drag. Bail unless the
    frame is shown, because a hidden frame is never re-anchored: UpdatePlacement
    returns early for characters with no tracking ability, skipping the
    ApplyFreePosition that reconciles the frame with UIParent's settled effective
    scale. Saving one then re-encodes stale offsets against the live scale and
    writes a drifted freePos — which is account-wide, so it moves the icon for
    every character.
]]
ns.SaveFreeFramePosition = function()
	if not ns.freeFrame or not ns.freeFrame:IsShown() then
		return
	end
	SaveFreePosition(ns.freeFrame)
end

-- ns.UpdatePlacement (Minimap-Button.lua) re-anchors the frame through this before showing it.
ns.ApplyFreePosition = ApplyFreePosition

--------------------------------------------------------------------------------
-- Scale & Shape
--------------------------------------------------------------------------------

function ns.UpdateFreeFrameScale()
	if ns.freeFrame then
		ns.freeFrame:SetScale(ns.db.global.freeIconScale)
		--[[
            SetPoint offsets are interpreted in the frame's *own* scale.
            After a scale change those offsets resolve to a different
            screen position, so the frame visually drifts. Re-applying
            the position immediately after SetScale converts the saved
            position back into the new scale and pins the frame to its
            true location.
        ]]
		ApplyFreePosition(ns.freeFrame)
	end
end

function ns.UpdateFreeFrameShape()
	if not ns.freeFrame then
		return
	end
	local isSquare = (ns.db.global.freeIconShape == ns.SHAPES.SQUARE)

	ns.freeFrame.circleBg:SetShown(not isSquare)
	ns.freeFrame.circleBorder:SetShown(not isSquare)
	ns.freeFrame.squareBg:SetShown(isSquare)
	ns.freeFrame.squareBorder:SetShown(isSquare)
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function ns.CreateFreeFrame()
	--[[
        Anonymous frame (nil name) on purpose: WoW's per-character layout-local
        cache keys on frame name and would apply a cached position over our
        account-wide freePos (SetUserPlaced(false) doesn't prevent the lookup).
        No name removes the frame from that system, so freePos owns placement.
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
	frame:SetScript("OnDragStop", function(self)
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
	end)
	frame:SetScript("OnClick", ns.HandleLauncherClick)
	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
		ns.BuildTooltip(GameTooltip)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	ns.freeFrame = frame
	--[[
        ApplyFreePosition does its own ClearAllPoints and pins the frame
        to its saved position via the stable CENTER -> UIParent
        BOTTOMLEFT anchor.
    ]]
	ApplyFreePosition(frame)
	ns.UpdatePlacement()
end
