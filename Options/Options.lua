local _, ns = ...

--------------------------------------------------------------------------------
-- Options Registration (AceConfig-3.0)
--------------------------------------------------------------------------------

local AC = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Slash Command
--------------------------------------------------------------------------------
SLASH_TRACKINGEYE1 = "/te"
SLASH_TRACKINGEYE2 = "/trackingeye"
SlashCmdList["TRACKINGEYE"] = function()
    ns.OpenOptions()
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------
local mainPanel

function ns.InitOptions()
    AC:RegisterOptionsTable(ns.OPTIONS_REGISTRY.General, ns.BuildGeneralOptions)
    mainPanel = ACD:AddToBlizOptions(ns.OPTIONS_REGISTRY.General, ns.L["ADDON_TITLE"])

    -- Pause Farm Mode while options panel is visible
    if mainPanel then
        mainPanel:HookScript("OnShow", function()
            ns.optionsOpen = true
        end)
        mainPanel:HookScript("OnHide", function()
            ns.optionsOpen = false
        end)
    end

    -- Diagnostic Tools panel, registered last so it sits at the bottom of the tree
    if ns.BuildDiagnosticsOptions and ns.OPTIONS_REGISTRY then
        AC:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions)
        ACD:AddToBlizOptions(ns.OPTIONS_REGISTRY.Diagnostics, ns.DiagnosticsStrings.TAB, ns.L["ADDON_TITLE"])
    end
end

function ns.OpenOptions()
    if Settings and Settings.GetCategory then
        local category = Settings.GetCategory(ns.L["ADDON_TITLE"])
        if category then
            Settings.OpenToCategory(category.ID)
            return
        end
    end
    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(mainPanel)
        InterfaceOptionsFrame_OpenToCategory(mainPanel)
        return
    end
    ACD:Open(ns.OPTIONS_REGISTRY.General)
end
