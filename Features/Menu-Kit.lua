local ADDON_NAME, ns = ...

--------------------------------------------------------------------------------
-- Menu Kit
--------------------------------------------------------------------------------

--[[
    The plates the mini-map menu and its flyout are drawn on, laid out as Pretty
    Wide Quest Log's Quest Arrow menu is: a dark plate with angled corners and a
    one-line row for each thing to do. Nothing here knows about Tracking Eye: a
    panel takes a list of entries and lays them out top to bottom, so the same kit
    can serve every Gogo1951 add-on.

    Entries, each a table with a `kind`:
      header     left, right            The add-on's name, its version on the right
      spacer                            A line's room
      section    left, right            A group's small gold label
      submenu    left, right, submenu   A gold label that opens a flyout, Blizzard's
                                        submenu arrow after its right side
      separator                         A thin line
      action     left, right            A row to click
      toggle     left, on               A switch: On in green, or Off with its name
                                        gray, so what's off sits back
      choice     left, selected         One of a set: the pick white with a check,
                                        the rest gray
      status     left, right            A row with nothing to click
      hint       left, right            A click hint, blue, clickable with onClick
      note       left                   Gray helper text, wrapped to the panel

    Any entry may carry leftColor and rightColor (palette keys), onClick, and
    tooltip, a function(GameTooltip) shown beside the row under the cursor.
]]

local Kit = {}
ns.MenuKit = Kit

local SPACE = { LINE = 4, NEAR = 8, GROUP = 16 }

--[[
    The plate's art, drawn at half its size so the edges stay sharp: PLATE_SIZE
    pixels square, the plate itself PLATE_MARGIN in from each edge and the rest its
    shadow, each corner piece PLATE_CORNER across.
]]
local PLATE_TEXTURE = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Images\\Menu-Plate"
local PLATE_SIZE = 128
local PLATE_MARGIN = { left = 12, right = 12, top = 10, bottom = 14 }
local PLATE_CORNER = 32
local PLATE_SCALE = 0.5
local PLATE_ALPHA = 0.8 -- The art is black: a little of the world shows through, so it reads lighter

local MIN_WIDTH = 128
local NOTE_MAX_WIDTH = 260 -- A note wraps here when nothing else makes the panel wider
local ROW_INSET = SPACE.LINE -- From the plate's edge to a row's highlight
local TEXT_INSET = SPACE.NEAR -- From a row's edge to its text
local HIGHLIGHT_ALPHA = 0.16

-- Blizzard's own arrow on a dropdown row with a submenu, and its check mark.
Kit.SUBMENU_ARROW = "|TInterface\\ChatFrame\\ChatFrameExpandArrow:0|t"
local CHECK_MARK = "|TInterface\\Buttons\\UI-CheckBox-Check:0|t"

local ON_TEXT, OFF_TEXT = "On", "Off"

-- The words a toggle shows, localized by the add-on.
function Kit.SetToggleText(on, off)
	ON_TEXT, OFF_TEXT = on, off
end

local function RGB(key)
	local hex = ns.PALETTE and ns.PALETTE[key] or "FFFFFF"
	return tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255
end

local function PlayClick()
	if PlaySound and SOUNDKIT and SOUNDKIT.U_CHAT_SCROLL_BUTTON then
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON)
	end
end

--------------------------------------------------------------------------------
-- Cursor Test
--------------------------------------------------------------------------------

--[[
    True while the cursor is over a frame. Read from the cursor position rather
    than IsMouseOver, so a controller's virtual cursor reports here too.
]]
function Kit.IsCursorOver(frame)
	if not frame or not frame:IsVisible() then
		return false
	end
	local left, right, top, bottom = frame:GetLeft(), frame:GetRight(), frame:GetTop(), frame:GetBottom()
	if not left then
		return false
	end
	local scale = frame:GetEffectiveScale()
	local x, y = GetCursorPosition()
	x, y = x / scale, y / scale
	return x >= left and x <= right and y >= bottom and y <= top
end

-- True when frame is the panel or sits anywhere inside it.
function Kit.IsInside(frame, panel)
	while frame do
		if frame == panel then
			return true
		end
		frame = frame.GetParent and frame:GetParent() or nil
	end
	return false
end

--------------------------------------------------------------------------------
-- The Plate
--------------------------------------------------------------------------------

-- Nine pieces: the corners at their own size, keeping the angle and shadow, the edges and middle stretched.
local function AddPlate(panel)
	local plate = CreateFrame("Frame", nil, panel)
	plate:SetPoint("TOPLEFT", -PLATE_MARGIN.left * PLATE_SCALE, PLATE_MARGIN.top * PLATE_SCALE)
	plate:SetPoint("BOTTOMRIGHT", PLATE_MARGIN.right * PLATE_SCALE, -PLATE_MARGIN.bottom * PLATE_SCALE)
	plate:SetFrameLevel(panel:GetFrameLevel()) -- Under the rows
	plate:SetAlpha(PLATE_ALPHA)

	local near, far = PLATE_CORNER / PLATE_SIZE, 1 - PLATE_CORNER / PLATE_SIZE
	local corner = PLATE_CORNER * PLATE_SCALE

	local function Piece(left, right, top, bottom)
		local texture = plate:CreateTexture(nil, "BACKGROUND")
		texture:SetTexture(PLATE_TEXTURE)
		texture:SetTexCoord(left, right, top, bottom)
		return texture
	end

	local topLeft = Piece(0, near, 0, near)
	topLeft:SetSize(corner, corner)
	topLeft:SetPoint("TOPLEFT")
	local topRight = Piece(far, 1, 0, near)
	topRight:SetSize(corner, corner)
	topRight:SetPoint("TOPRIGHT")
	local bottomLeft = Piece(0, near, far, 1)
	bottomLeft:SetSize(corner, corner)
	bottomLeft:SetPoint("BOTTOMLEFT")
	local bottomRight = Piece(far, 1, far, 1)
	bottomRight:SetSize(corner, corner)
	bottomRight:SetPoint("BOTTOMRIGHT")

	local top = Piece(near, far, 0, near)
	top:SetPoint("TOPLEFT", topLeft, "TOPRIGHT")
	top:SetPoint("BOTTOMRIGHT", topRight, "BOTTOMLEFT")
	local bottom = Piece(near, far, far, 1)
	bottom:SetPoint("TOPLEFT", bottomLeft, "TOPRIGHT")
	bottom:SetPoint("BOTTOMRIGHT", bottomRight, "BOTTOMLEFT")
	local left = Piece(0, near, near, far)
	left:SetPoint("TOPLEFT", topLeft, "BOTTOMLEFT")
	left:SetPoint("BOTTOMRIGHT", bottomLeft, "TOPRIGHT")
	local right = Piece(far, 1, near, far)
	right:SetPoint("TOPLEFT", topRight, "BOTTOMLEFT")
	right:SetPoint("BOTTOMRIGHT", bottomRight, "TOPRIGHT")
	local middle = Piece(near, far, near, far)
	middle:SetPoint("TOPLEFT", topLeft, "BOTTOMRIGHT")
	middle:SetPoint("BOTTOMRIGHT", bottomRight, "TOPLEFT")
end

--------------------------------------------------------------------------------
-- Rows
--------------------------------------------------------------------------------

local function Paint(fontString, text, colorKey)
	fontString:SetText(text or "")
	if colorKey then
		fontString:SetTextColor(RGB(colorKey))
	end
	fontString:SetShown(text ~= nil)
end

local function HideOwnTooltip(owner)
	if GameTooltip:GetOwner() == owner then
		GameTooltip:Hide()
	end
end

local function Row(panel, index)
	local row = panel.rows[index]
	if not row then
		row = CreateFrame("Button", nil, panel)
		row:RegisterForClicks("LeftButtonUp")
		row.highlight = row:CreateTexture(nil, "HIGHLIGHT")
		row.highlight:SetAllPoints()
		local red, green, blue = RGB("TITLE")
		row.highlight:SetColorTexture(red, green, blue, HIGHLIGHT_ALPHA)
		row.left = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.left:SetJustifyH("LEFT")
		row.right = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		row.right:SetJustifyH("RIGHT")
		row.right:SetWordWrap(false)
		row.line = row:CreateTexture(nil, "ARTWORK")
		row.line:SetHeight(1)
		row.line:SetPoint("LEFT", TEXT_INSET, 0)
		row.line:SetPoint("RIGHT", -TEXT_INSET, 0)
		red, green, blue = RGB("SEPARATOR")
		row.line:SetColorTexture(red, green, blue, 0.35)
		row:SetScript("OnClick", function(self)
			local entry = self.entry
			if entry and entry.onClick then
				PlayClick()
				entry.onClick()
			end
		end)
		row:SetScript("OnEnter", function(self)
			local entry = self.entry
			if entry and entry.tooltip then
				GameTooltip:SetOwner(self, panel.tooltipAnchor or "ANCHOR_RIGHT")
				entry.tooltip(GameTooltip)
				GameTooltip:Show()
			end
			if panel.onEnterRow then
				panel.onEnterRow(self, entry)
			end
		end)
		row:SetScript("OnLeave", HideOwnTooltip)
		panel.rows[index] = row
	end
	row:Show()
	return row
end

-- What each kind shows: its fonts, colors, and right side, filled in from the entry.
local function Look(entry)
	local kind = entry.kind
	local left, right = entry.left, entry.right
	local leftColor, rightColor = entry.leftColor, entry.rightColor
	local leftFont, rightFont = "GameFontHighlight", "GameFontHighlight"
	if kind == "header" or kind == "submenu" then
		leftFont, rightFont = "GameFontNormal", "GameFontHighlight"
		leftColor, rightColor = leftColor or "TITLE", rightColor or "MUTED"
		if kind == "submenu" then
			right = (right and right .. " " or "") .. Kit.SUBMENU_ARROW
		end
	elseif kind == "section" then
		leftFont, rightFont = "GameFontNormalSmall", "GameFontNormalSmall"
		leftColor, rightColor = leftColor or "TITLE", rightColor or "MUTED"
	elseif kind == "toggle" then
		right = entry.on and ON_TEXT or OFF_TEXT
		leftColor = leftColor or (not entry.on and "MUTED") or "TEXT"
		rightColor = rightColor or (entry.on and "ON") or "MUTED"
	elseif kind == "choice" then
		right = entry.selected and CHECK_MARK or nil
		leftColor = leftColor or (not entry.selected and "MUTED") or "TEXT"
	elseif kind == "hint" then
		leftColor, rightColor = leftColor or "INFO", rightColor or "INFO"
	elseif kind == "note" then
		leftFont = "GameFontHighlightSmall"
		leftColor = leftColor or "MUTED"
	end
	return {
		left = left,
		right = right,
		leftColor = leftColor or "TEXT",
		rightColor = rightColor or "TEXT",
		leftFont = leftFont,
		rightFont = rightFont,
	}
end

--------------------------------------------------------------------------------
-- Panel
--------------------------------------------------------------------------------

local Panel = {}

--[[
    Lays the entries out and sizes the panel to them: each row as tall as a line
    and SPACE.LINE above and below, a group's label SPACE.NEAR above instead to set
    its group apart, a spacer a line's room, a separator SPACE.NEAR. A note wraps
    to the width the other rows settle on, so it never makes the panel wider than
    NOTE_MAX_WIDTH on its own.
]]
function Panel:Render(entries)
	local rows = self.rows
	local width = MIN_WIDTH
	local notes = {}

	-- First pass: what each row says, and the width the widest needs.
	for index, entry in ipairs(entries) do
		local row = Row(self, index)
		local kind = entry.kind
		row.entry = entry
		row:EnableMouse(entry.onClick ~= nil or entry.tooltip ~= nil or kind == "submenu")
		row.highlight:SetShown(entry.onClick ~= nil or kind == "submenu")
		row.line:SetShown(kind == "separator")
		row:UnlockHighlight()

		if kind == "separator" or kind == "spacer" then
			Paint(row.left, nil)
			Paint(row.right, nil)
			row.height = kind == "spacer" and SPACE.GROUP or SPACE.NEAR
			row.above = SPACE.LINE
		else
			local look = Look(entry)
			row.left:SetFontObject(look.leftFont)
			row.right:SetFontObject(look.rightFont)
			row.left:SetWordWrap(kind == "note")
			row.left:SetWidth(0)
			Paint(row.left, look.left, look.leftColor)
			Paint(row.right, look.right, look.rightColor)
			local _, size = row.left:GetFont()
			local above = kind == "section" and SPACE.NEAR or SPACE.LINE
			row.above = above
			row.height = (size or 12) + above + SPACE.LINE
			if kind == "note" then
				notes[#notes + 1] = row
			else
				local textWidth = row.left:GetStringWidth() or 0
				if look.right then
					textWidth = textWidth + SPACE.GROUP + (row.right:GetStringWidth() or 0)
				end
				width = math.max(width, textWidth + 2 * (TEXT_INSET + ROW_INSET))
			end
		end
	end

	-- Second pass: notes wrap to that width, or to NOTE_MAX_WIDTH when nothing else is that wide.
	local insets = 2 * (TEXT_INSET + ROW_INSET)
	for _, row in ipairs(notes) do
		width = math.max(width, math.min((row.left:GetStringWidth() or 0) + insets, NOTE_MAX_WIDTH))
	end
	local noteWidth = width - insets
	for _, row in ipairs(notes) do
		row.left:SetWidth(noteWidth)
		row.height = row.left:GetStringHeight() + row.above + SPACE.LINE
	end

	-- Third pass: place them.
	local y = SPACE.NEAR
	for index = 1, #entries do
		local row = rows[index]
		local drop = (row.above - SPACE.LINE) / 2 -- A label's extra room is all above it
		row.left:ClearAllPoints()
		row.left:SetPoint("LEFT", TEXT_INSET, -drop)
		row.right:ClearAllPoints()
		row.right:SetPoint("RIGHT", -TEXT_INSET, -drop)
		row:SetHeight(row.height)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", self, "TOPLEFT", ROW_INSET, -y)
		row:SetPoint("TOPRIGHT", self, "TOPRIGHT", -ROW_INSET, -y)
		y = y + row.height
	end
	for index = #entries + 1, #rows do
		rows[index]:Hide()
		rows[index].entry = nil
	end
	self:SetSize(math.ceil(width), y + SPACE.NEAR)
end

-- The row that opens a flyout by name, for placing the flyout beside it.
function Panel:SubmenuRow(name)
	for _, row in ipairs(self.rows) do
		if row:IsShown() and row.entry and row.entry.submenu == name then
			return row
		end
	end
end

--[[
    A new, hidden panel on its plate. A named panel can be listed in
    UISpecialFrames so Escape closes it. Mouse is enabled so a click on the plate
    never falls through to the world.
]]
function Kit.CreatePanel(name, parent)
	local panel = CreateFrame("Frame", name, parent or UIParent)
	panel:Hide()
	panel:SetFrameStrata("DIALOG")
	panel:SetToplevel(true)
	panel:SetClampedToScreen(true)
	panel:EnableMouse(true)
	panel.rows = {}
	AddPlate(panel)
	for key, method in pairs(Panel) do
		panel[key] = method
	end
	return panel
end

-- The gap a flyout keeps from the panel it opens beside.
Kit.FLYOUT_GAP = ROW_INSET + SPACE.NEAR
Kit.FLYOUT_RISE = SPACE.NEAR
