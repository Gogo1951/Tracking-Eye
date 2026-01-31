local addonName, ns = ...

local LibDD = LibStub("LibUIDropDownMenu-4.0")

local dropdown = LibDD:Create_UIDropDownMenu(addonName .. "TrackingMenu", UIParent)

--------------------------------------------------------------------------------
-- Menu Logic
--------------------------------------------------------------------------------
local function InitMenu(_, level)
    if level ~= 1 then return end
    
    local list = {}
    for _, id in ipairs(ns.TRACKING_IDS) do
        local name = ns.GetSpellName(id)
        if name then
            table.insert(list, {id = id, name = name})
        end
    end

    table.sort(list, function(a, b) return a.name < b.name end)

    local isCat, _ = ns.GetPlayerStates()

    for _, data in ipairs(list) do
        if IsPlayerSpell(data.id) and (data.id ~= ns.SPELLS.DRUID_HUMANOIDS or isCat) then
            local info = LibDD:UIDropDownMenu_CreateInfo()
            info.text = string.format("|T%s:16|t %s", GetSpellTexture(data.id) or "", data.name)
            info.value = data.id
            info.checked = (TrackingEyeDB.selectedSpellId == data.id)
            info.func = function(btn)
                TrackingEyeDB.selectedSpellId = btn.value
                ns.state.wasFarming = false
                ns.CastTracking(btn.value)
                LibDD:CloseDropDownMenus()
            end
            LibDD:UIDropDownMenu_AddButton(info, level)
        end
    end
end

LibDD:UIDropDownMenu_Initialize(dropdown, InitMenu, "MENU")

function ns.ToggleMenu(anchor)
    LibDD:ToggleDropDownMenu(1, nil, dropdown, anchor, 0, 0)
end
