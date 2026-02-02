local addonName, te = ...

local LibDD = LibStub("LibUIDropDownMenu-4.0")

local dropdown = LibDD:Create_UIDropDownMenu(addonName .. "TrackingMenu", UIParent)

--------------------------------------------------------------------------------
-- Menu Logic
--------------------------------------------------------------------------------
local function InitMenu(_, level)
    if level ~= 1 then return end
    
    -- Title
    local titleInfo = LibDD:UIDropDownMenu_CreateInfo()
    titleInfo.text = te.GetColor("TITLE") .. te.L["TRACKING_MENU"] .. "|r"
    titleInfo.isTitle = true
    titleInfo.notCheckable = true
    LibDD:UIDropDownMenu_AddButton(titleInfo, level)

    -- List
    local list = {}
    for _, id in ipairs(te.TRACKING_IDS) do
        local name = te.GetSpellName(id)
        if name then
            table.insert(list, {id = id, name = name})
        end
    end

    table.sort(list, function(a, b) return a.name < b.name end)

    local isCat, _ = te.GetPlayerStates()

    for _, data in ipairs(list) do
        if IsPlayerSpell(data.id) and (data.id ~= te.SPELLS.DRUID_HUMANOIDS or isCat) then
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = string.format("|T%s:16|t %s", GetSpellTexture(data.id) or "", data.name)
            info.value = data.id
            info.checked = (TrackingEyeDB.selectedSpellId == data.id)
            info.func = function(btn)
                TrackingEyeDB.selectedSpellId = btn.value
                te.state.wasFarming = false
                te.CastTracking(btn.value)
                LibDD:CloseDropDownMenus()
            end
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end

LibDD:UIDropDownMenu_Initialize(dropdown, InitMenu, "MENU")

function te.ToggleMenu(anchor)
    local xOffset = 0
    if anchor and anchor.GetWidth then
        -- Anchor Top-Left of menu to Bottom-Right of button.
        xOffset = anchor:GetWidth()
    end
    LibDD:ToggleDropDownMenu(1, nil, dropdown, anchor, xOffset, 0)
end