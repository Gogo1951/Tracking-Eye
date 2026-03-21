local addonName, te = ...

--------------------------------------------------------------------------------
-- Options Panel (Interface > AddOns)
--------------------------------------------------------------------------------

local panel = CreateFrame("Frame", addonName .. "OptionsPanel", UIParent)
panel.name = "Tracking Eye"

-- Layout constants
local PADDING    = 16
local LINE       = 16
local DOUBLE     = 32
local CHECKBOX_H = 26
local SLIDER_H   = 50
local CONTENT_W  = 440

-- HR line color (gold)
local HR_COLOR  = {1, 0.82, 0, 1}
local DIM_COLOR = {0.5, 0.5, 0.5}

-- State
local initialized = false
local optionsCategory = nil

-- Widget refs
local content
local persistentCB, farmCB, freeCB
local farmAbilityCheckboxes = {}
local speedSlider, scaleSlider, speedValue, scaleValue
local shapeDropdownRef, shapeDropdownNames

-- For reflowing: Y where checkboxes start, and widgets that follow them
local checkboxAnchorY = 0
local postCheckboxWidgets = {} -- {widget=, gap=, height=}

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

--- Create a wrapped text block. Returns the fontstring and Y below it.
local function MakeText(parent, template, text, x, y, width)
    local fs = parent:CreateFontString(nil, "ARTWORK", template)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    if width then
        fs:SetWidth(width)
        fs:SetJustifyH("LEFT")
    end
    fs:SetText(text)
    return fs, y - fs:GetStringHeight() - 4
end

local function MakeHR(parent, text, y)
    local W = CONTENT_W + 20
    local gap = 10

    local leftTex = parent:CreateTexture(nil, "ARTWORK")
    leftTex:SetColorTexture(unpack(HR_COLOR))
    leftTex:SetHeight(1)

    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    label:SetText(text)

    local rightTex = parent:CreateTexture(nil, "ARTWORK")
    rightTex:SetColorTexture(unpack(HR_COLOR))
    rightTex:SetHeight(1)

    local tw = label:GetStringWidth()
    local lw = math.max(20, (W - tw - gap * 2) / 2)

    leftTex:SetWidth(lw)
    leftTex:SetPoint("TOPLEFT", parent, "TOPLEFT", PADDING, y - 6)
    label:SetPoint("LEFT", leftTex, "RIGHT", gap, 0)
    rightTex:SetWidth(lw)
    rightTex:SetPoint("LEFT", label, "RIGHT", gap, 0)

    return y - 22
end

local function MakeToggle(parent, text, x, y, onClick)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    cb:SetSize(24, 24)

    local label = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    label:SetText(text)
    cb.label = label

    if onClick then
        cb:SetScript("OnClick", onClick)
    end
    return cb, y - CHECKBOX_H
end

local function MakeSlider(parent, name, minV, maxV, step, y)
    -- TBC 2.5.5 requires BackdropTemplate for SetBackdrop to exist
    local templates = "OptionsSliderTemplate"
    if BackdropTemplateMixin then
        templates = "OptionsSliderTemplate, BackdropTemplate"
    end

    local s = CreateFrame("Slider", addonName .. name, parent, templates)
    s:SetPoint("TOPLEFT", parent, "TOPLEFT", PADDING + 4, y)
    s:SetWidth(220)
    s:SetMinMaxValues(minV, maxV)
    s:SetValueStep(step)
    if s.SetObeyStepOnDrag then
        s:SetObeyStepOnDrag(true)
    end

    -- Apply backdrop (works now that BackdropTemplate is inherited on TBC)
    if s.SetBackdrop then
        s:SetBackdrop({
            bgFile   = "Interface\\Buttons\\UI-SliderBar-Background",
            edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
            tile     = true,
            tileSize = 8,
            edgeSize = 8,
            insets   = {left = 3, right = 3, top = 6, bottom = 6}
        })
    end

    local k = s:GetName()
    if _G[k .. "Low"] then _G[k .. "Low"]:SetText("") end
    if _G[k .. "High"] then _G[k .. "High"]:SetText("") end
    if _G[k .. "Text"] then _G[k .. "Text"]:SetText("") end

    local vt = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    vt:SetPoint("LEFT", s, "RIGHT", 12, 0)

    return s, vt, y - SLIDER_H
end

local function MakeLinkBox(parent, url, y)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetPoint("TOPLEFT", parent, "TOPLEFT", PADDING + 8, y)
    box:SetSize(260, 20)
    box:SetAutoFocus(false)
    box:SetText(url)
    box:SetCursorPosition(0)
    box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    box:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    box:SetScript("OnTextChanged", function(self)
        self:SetText(url)
        self:HighlightText()
    end)
    return box, y - 26
end

--------------------------------------------------------------------------------
-- Refresh (forward-declared)
--------------------------------------------------------------------------------
local RefreshPanel

RefreshPanel = function()
    if persistentCB and TrackingEyeDB then
        persistentCB:SetChecked(TrackingEyeDB.autoTracking and true or false)
    end
    if farmCB and TrackingEyeDB then
        farmCB:SetChecked(TrackingEyeDB.farmingMode and true or false)
    end
    if freeCB and TrackingEyeGlobalDB then
        freeCB:SetChecked(TrackingEyeGlobalDB.freePlacement and true or false)
    end

    -- Reflow checkboxes: position only visible ones, no gaps
    local y = checkboxAnchorY
    for _, cb in ipairs(farmAbilityCheckboxes) do
        local known = IsPlayerSpell(cb.spellId)

        local show = false

        if cb.isAlwaysOn then
            -- Always visible, always checked, disabled
            show = true
            cb:SetChecked(true)
            cb:Disable()
            if cb.label then
                cb.label:SetTextColor(known and 1 or DIM_COLOR[1], known and 1 or DIM_COLOR[2], known and 1 or DIM_COLOR[3])
            end
        elseif known then
            show = true
            cb:Enable()
            local enabled = TrackingEyeDB and TrackingEyeDB.farmCycleSpells and
                TrackingEyeDB.farmCycleSpells[cb.spellId]
            cb:SetChecked(enabled and true or false)
            if cb.label then
                cb.label:SetTextColor(1, 1, 1)
            end
        end

        if show then
            cb:ClearAllPoints()
            cb:SetPoint("TOPLEFT", content, "TOPLEFT", PADDING + 4, y)
            cb:Show()
            if cb.label then cb.label:Show() end
            y = y - CHECKBOX_H
        else
            cb:Hide()
            if cb.label then cb.label:Hide() end
        end
    end

    -- Reflow everything below the checkboxes
    for _, entry in ipairs(postCheckboxWidgets) do
        y = y - (entry.gap or 0)
        entry.widget:ClearAllPoints()
        entry.widget:SetPoint("TOPLEFT", content, "TOPLEFT", entry.x or PADDING, y)
        y = y - (entry.height or 0)
    end

    -- Update scroll content height
    content:SetHeight(math.abs(y) + DOUBLE)

    -- Update slider values
    if speedSlider and TrackingEyeDB then
        speedSlider:SetValue(TrackingEyeDB.farmInterval or te.FARM_INTERVAL_DEFAULT)
    end
    if scaleSlider and TrackingEyeGlobalDB then
        scaleSlider:SetValue(TrackingEyeGlobalDB.freeIconScale or te.FREE_ICON_SCALE_DEFAULT)
    end

    if shapeDropdownRef and shapeDropdownNames and TrackingEyeGlobalDB then
        local LibDD = LibStub("LibUIDropDownMenu-4.0")
        local shape = TrackingEyeGlobalDB.freeIconShape or te.FREE_ICON_SHAPE_DEFAULT
        LibDD:UIDropDownMenu_SetText(shapeDropdownRef, shapeDropdownNames[shape] or shape)
    end
end

--------------------------------------------------------------------------------
-- Reset
--------------------------------------------------------------------------------
local function ResetAllOptions()
    if TrackingEyeDB then
        TrackingEyeDB.autoTracking = true
        TrackingEyeDB.farmingMode = true
        TrackingEyeDB.farmInterval = te.FARM_INTERVAL_DEFAULT
        TrackingEyeDB.selectedSpellId = nil
        TrackingEyeDB.lastIcon = nil
        TrackingEyeDB.farmCycleSpells = {}
        for id, v in pairs(te.FARM_CYCLE_DEFAULTS) do
            TrackingEyeDB.farmCycleSpells[id] = v
        end
    end
    if TrackingEyeGlobalDB then
        TrackingEyeGlobalDB.freePlacement = false
        TrackingEyeGlobalDB.freeIconScale = te.FREE_ICON_SCALE_DEFAULT
        TrackingEyeGlobalDB.freeIconShape = te.FREE_ICON_SHAPE_DEFAULT
    end

    te.InvalidateFarmCache()
    te.RestartFarmTicker()
    te.UpdatePlacement()
    te.UpdateFreeFrameScale()
    te.UpdateFreeFrameShape()
    te.UpdateIcon()
    RefreshPanel()
end

--------------------------------------------------------------------------------
-- Post-checkbox widget registration
--   Queues a widget so RefreshPanel can reposition it dynamically.
--   gap = space above the widget, height = space the widget itself takes.
--------------------------------------------------------------------------------
local function QueueWidget(widget, gap, height, x)
    table.insert(postCheckboxWidgets, {
        widget = widget,
        gap    = gap or 0,
        height = height or 0,
        x      = x or PADDING
    })
end

--------------------------------------------------------------------------------
-- Build UI (once)
--------------------------------------------------------------------------------
local function BuildPanel()
    -- Scroll frame
    local scroll = CreateFrame("ScrollFrame", addonName .. "OptionsScroll", panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, 0)
    scroll:SetPoint("BOTTOMRIGHT", -22, 0)

    content = CreateFrame("Frame", addonName .. "OptionsContent", scroll)
    content:SetWidth(580)
    scroll:SetScrollChild(content)

    scroll:SetScript("OnSizeChanged", function(self)
        content:SetWidth(self:GetWidth())
    end)

    local _, fs, y

    y = -PADDING

    --------------------------------------------------------------------------
    -- Title + Reset button
    --------------------------------------------------------------------------
    MakeText(content, "GameFontNormalLarge", te.L["ADDON_TITLE"], PADDING, y)

    local resetBtn = CreateFrame("Button", addonName .. "ResetBtn", content, "UIPanelButtonTemplate")
    resetBtn:SetSize(150, 24)
    resetBtn:SetPoint("TOPRIGHT", content, "TOPRIGHT", -PADDING, y + 2)
    resetBtn:SetText(te.L["OPTIONS_RESET"])
    resetBtn:SetScript("OnClick", ResetAllOptions)

    y = y - 24

    --------------------------------------------------------------------------
    -- Persistent Tracking
    --------------------------------------------------------------------------
    y = y - DOUBLE
    y = MakeHR(content, te.L["PERSISTENT_TRACKING"], y)

    _, y = MakeText(content, "GameFontHighlight",
        te.L["PERSISTENT_DESC"], PADDING + 2, y, CONTENT_W)

    y = y - LINE

    persistentCB, y = MakeToggle(content, te.L["OPTIONS_ENABLE_PERSISTENT"],
        PADDING + 2, y, function(self)
            if TrackingEyeDB then
                TrackingEyeDB.autoTracking = self:GetChecked() and true or false
            end
        end)

    --------------------------------------------------------------------------
    -- Farm Mode
    --------------------------------------------------------------------------
    y = y - DOUBLE
    y = MakeHR(content, te.L["FARM_MODE"], y)

    _, y = MakeText(content, "GameFontHighlight",
        te.L["FARMING_DESC"], PADDING + 2, y, CONTENT_W)

    y = y - LINE

    farmCB, y = MakeToggle(content, te.L["OPTIONS_ENABLE_FARM"],
        PADDING + 2, y, function(self)
            if TrackingEyeDB then
                TrackingEyeDB.farmingMode = self:GetChecked() and true or false
            end
        end)

    y = y - LINE

    -- Sub: Farm Mode Abilities
    MakeText(content, "GameFontNormal",
        te.L["OPTIONS_FARM_ABILITIES"], PADDING + 2, y)
    y = y - LINE

    _, y = MakeText(content, "GameFontHighlightSmall",
        te.L["OPTIONS_FARM_ABILITIES_DESC"], PADDING + 2, y, CONTENT_W)

    y = y - LINE

    -- Save Y where checkboxes will be placed (RefreshPanel handles positioning)
    checkboxAnchorY = y

    -- Build sorted spell list: always-on first, then alphabetical
    -- Exclude Druid Humanoids (farm mode = mounted/travel, humanoids = cat form)
    local allSpells = {}
    for _, id in ipairs(te.TRACKING_IDS) do
        if id ~= te.SPELLS.DRUID_HUMANOIDS then
            local name = te.GetSpellName(id)
            if name then
                table.insert(allSpells, {id = id, name = name})
            end
        end
    end
    table.sort(allSpells, function(a, b)
        local aOn = te.FARM_ALWAYS_ON[a.id] and true or false
        local bOn = te.FARM_ALWAYS_ON[b.id] and true or false
        if aOn ~= bOn then return aOn end
        return a.name < b.name
    end)

    for i, data in ipairs(allSpells) do
        local isAlwaysOn = te.FARM_ALWAYS_ON[data.id]

        local cb = CreateFrame("CheckButton", addonName .. "FarmCB" .. i, content, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb.spellId = data.id
        cb.isAlwaysOn = isAlwaysOn

        local labelText = string.format("|T%s:16|t %s",
            GetSpellTexture(data.id) or te.ICON_DEFAULT, data.name)
        if isAlwaysOn then
            labelText = labelText .. "  " .. te.GetColor("MUTED") .. te.L["OPTIONS_ALWAYS_ON"] .. "|r"
        end

        local label = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        label:SetText(labelText)
        cb.label = label

        if not isAlwaysOn then
            cb:SetScript("OnClick", function(self)
                if TrackingEyeDB and TrackingEyeDB.farmCycleSpells then
                    TrackingEyeDB.farmCycleSpells[self.spellId] = self:GetChecked() and true or nil
                    te.InvalidateFarmCache()
                end
            end)
        end

        table.insert(farmAbilityCheckboxes, cb)
    end

    --------------------------------------------------------------------------
    -- Everything below checkboxes is queued for dynamic reflow
    --------------------------------------------------------------------------

    -- Sub: Cycle Speed
    fs = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetText(te.L["OPTIONS_CYCLE_SPEED"])
    QueueWidget(fs, LINE, LINE, PADDING + 2)

    fs = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    fs:SetWidth(CONTENT_W)
    fs:SetJustifyH("LEFT")
    fs:SetText(te.L["OPTIONS_CYCLE_SPEED_DESC"])
    QueueWidget(fs, 0, fs:GetStringHeight() + 4, PADDING + 2)

    speedSlider, speedValue = MakeSlider(content, "SpeedSlider", 2, 10, 0.5, -9999)
    speedSlider:SetScript("OnValueChanged", function(_, value)
        value = math.floor(value * 2 + 0.5) / 2
        if TrackingEyeDB then
            TrackingEyeDB.farmInterval = value
        end
        if speedValue then
            speedValue:SetText(string.format(te.L["OPTIONS_SECONDS"], value))
        end
        te.RestartFarmTicker()
    end)
    QueueWidget(speedSlider, LINE, SLIDER_H, PADDING + 4)

    -- Free Placement Mode HR (built manually, queued as parts)
    -- We need to queue an HR, but HRs are multi-widget. Use a container frame.
    local fpHR = CreateFrame("Frame", nil, content)
    fpHR:SetSize(CONTENT_W + 20, 22)
    do
        local W = CONTENT_W + 20
        local gap = 10
        local left = fpHR:CreateTexture(nil, "ARTWORK")
        left:SetColorTexture(unpack(HR_COLOR))
        left:SetHeight(1)
        local lbl = fpHR:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        lbl:SetText(te.L["PLACEMENT_MODE"])
        local right = fpHR:CreateTexture(nil, "ARTWORK")
        right:SetColorTexture(unpack(HR_COLOR))
        right:SetHeight(1)
        local tw = lbl:GetStringWidth()
        local lw = math.max(20, (W - tw - gap * 2) / 2)
        left:SetWidth(lw)
        left:SetPoint("LEFT", fpHR, "LEFT", 0, 0)
        lbl:SetPoint("LEFT", left, "RIGHT", gap, 0)
        right:SetWidth(lw)
        right:SetPoint("LEFT", lbl, "RIGHT", gap, 0)
    end
    QueueWidget(fpHR, DOUBLE, 22, PADDING)

    fs = content:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fs:SetWidth(CONTENT_W)
    fs:SetJustifyH("LEFT")
    fs:SetText(te.L["PLACEMENT_DESC"])
    QueueWidget(fs, 0, fs:GetStringHeight() + 4, PADDING + 2)

    freeCB = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    freeCB:SetSize(24, 24)
    local freeLabel = freeCB:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    freeLabel:SetPoint("LEFT", freeCB, "RIGHT", 4, 0)
    freeLabel:SetText(te.L["OPTIONS_ENABLE_FREE"])
    freeCB.label = freeLabel
    freeCB:SetScript("OnClick", function(self)
        if TrackingEyeGlobalDB then
            TrackingEyeGlobalDB.freePlacement = self:GetChecked() and true or false
            te.UpdatePlacement()
        end
    end)
    QueueWidget(freeCB, LINE, CHECKBOX_H, PADDING + 2)

    -- Sub: Icon Size
    fs = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetText(te.L["OPTIONS_ICON_SCALE"])
    QueueWidget(fs, LINE, LINE, PADDING + 2)

    fs = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    fs:SetWidth(CONTENT_W)
    fs:SetJustifyH("LEFT")
    fs:SetText(te.L["OPTIONS_ICON_SCALE_DESC"])
    QueueWidget(fs, 0, fs:GetStringHeight() + 4, PADDING + 2)

    scaleSlider, scaleValue = MakeSlider(content, "ScaleSlider", 0.25, 3.0, 0.05, -9999)
    scaleSlider:SetScript("OnValueChanged", function(_, value)
        value = math.floor(value * 20 + 0.5) / 20
        if TrackingEyeGlobalDB then
            TrackingEyeGlobalDB.freeIconScale = value
        end
        if scaleValue then
            scaleValue:SetText(string.format(te.L["OPTIONS_PERCENT"], math.floor(value * 100 + 0.5)))
        end
        te.UpdateFreeFrameScale()
    end)
    QueueWidget(scaleSlider, LINE, SLIDER_H, PADDING + 4)

    -- Sub: Icon Shape
    fs = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetText(te.L["OPTIONS_ICON_SHAPE"])
    QueueWidget(fs, LINE, LINE, PADDING + 2)

    fs = content:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    fs:SetWidth(CONTENT_W)
    fs:SetJustifyH("LEFT")
    fs:SetText(te.L["OPTIONS_ICON_SHAPE_DESC"])
    QueueWidget(fs, 0, fs:GetStringHeight() + 4, PADDING + 2)

    local LibDD = LibStub("LibUIDropDownMenu-4.0")
    local shapeDropdown = LibDD:Create_UIDropDownMenu(addonName .. "ShapeDropdown", content)
    LibDD:UIDropDownMenu_SetWidth(shapeDropdown, 120)

    local shapeNames = {
        [te.SHAPES.CIRCLE] = te.L["OPTIONS_SHAPE_CIRCLE"],
        [te.SHAPES.SQUARE] = te.L["OPTIONS_SHAPE_SQUARE"]
    }
    local shapeOrder = { te.SHAPES.CIRCLE, te.SHAPES.SQUARE }

    LibDD:UIDropDownMenu_Initialize(shapeDropdown, function(self, level)
        for _, shape in ipairs(shapeOrder) do
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = shapeNames[shape]
            info.value = shape
            info.checked = (TrackingEyeGlobalDB and TrackingEyeGlobalDB.freeIconShape == shape)
            info.func = function(btn)
                if TrackingEyeGlobalDB then
                    TrackingEyeGlobalDB.freeIconShape = btn.value
                end
                LibDD:UIDropDownMenu_SetText(shapeDropdown, shapeNames[btn.value])
                te.UpdateFreeFrameShape()
            end
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end)

    -- Set initial text (will be updated in RefreshPanel too)
    shapeDropdownRef = shapeDropdown
    shapeDropdownNames = shapeNames

    QueueWidget(shapeDropdown, 4, 36, PADDING - 4)

    -- Feedback & Support HR
    local fbHR = CreateFrame("Frame", nil, content)
    fbHR:SetSize(CONTENT_W + 20, 22)
    do
        local W = CONTENT_W + 20
        local gap = 10
        local left = fbHR:CreateTexture(nil, "ARTWORK")
        left:SetColorTexture(unpack(HR_COLOR))
        left:SetHeight(1)
        local lbl = fbHR:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        lbl:SetText(te.L["OPTIONS_LINKS"])
        local right = fbHR:CreateTexture(nil, "ARTWORK")
        right:SetColorTexture(unpack(HR_COLOR))
        right:SetHeight(1)
        local tw = lbl:GetStringWidth()
        local lw = math.max(20, (W - tw - gap * 2) / 2)
        left:SetWidth(lw)
        left:SetPoint("LEFT", fbHR, "LEFT", 0, 0)
        lbl:SetPoint("LEFT", left, "RIGHT", gap, 0)
        right:SetWidth(lw)
        right:SetPoint("LEFT", lbl, "RIGHT", gap, 0)
    end
    QueueWidget(fbHR, DOUBLE, 22, PADDING)

    -- Discord
    fs = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetText(te.L["OPTIONS_DISCORD"])
    QueueWidget(fs, 4, LINE, PADDING + 2)

    local discordBox = CreateFrame("EditBox", addonName .. "DiscordBox", content, "InputBoxTemplate")
    discordBox:SetSize(260, 20)
    discordBox:SetAutoFocus(false)
    discordBox:SetText(te.DISCORD_URL)
    discordBox:SetCursorPosition(0)
    discordBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    discordBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    discordBox:SetScript("OnTextChanged", function(self)
        self:SetText(te.DISCORD_URL)
        self:HighlightText()
    end)
    QueueWidget(discordBox, 2, 26, PADDING + 8)

    -- GitHub
    fs = content:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetText(te.L["OPTIONS_GITHUB"])
    QueueWidget(fs, LINE, LINE, PADDING + 2)

    local githubBox = CreateFrame("EditBox", addonName .. "GitHubBox", content, "InputBoxTemplate")
    githubBox:SetSize(260, 20)
    githubBox:SetAutoFocus(false)
    githubBox:SetText(te.GITHUB_URL)
    githubBox:SetCursorPosition(0)
    githubBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    githubBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    githubBox:SetScript("OnTextChanged", function(self)
        self:SetText(te.GITHUB_URL)
        self:HighlightText()
    end)
    QueueWidget(githubBox, 2, 26, PADDING + 8)
end

--------------------------------------------------------------------------------
-- Show / Hide
--------------------------------------------------------------------------------
panel:SetScript("OnShow", function()
    if not initialized then
        BuildPanel()
        initialized = true
    end
    te.optionsOpen = true
    RefreshPanel()
end)

panel:SetScript("OnHide", function()
    te.optionsOpen = false
end)

--------------------------------------------------------------------------------
-- Registration & Slash Command
--------------------------------------------------------------------------------
function te.InitOptions()
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
        optionsCategory = category
        Settings.RegisterAddOnCategory(category)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(panel)
    end
end

function te.OpenOptions()
    if Settings and Settings.OpenToCategory and optionsCategory then
        Settings.OpenToCategory(optionsCategory:GetID())
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end