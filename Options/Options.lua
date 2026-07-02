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
local diagnosticsPanel

function ns.InitOptions()
    AC:RegisterOptionsTable(ns.OPTIONS_REGISTRY.General, ns.BuildGeneralOptions)
    mainPanel = ACD:AddToBlizOptions(ns.OPTIONS_REGISTRY.General, ns.L["ADDON_TITLE"])

    -- Diagnostic Tools panel, registered last so it sits at the bottom of the tree
    if ns.BuildDiagnosticsOptions and ns.OPTIONS_REGISTRY then
        AC:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions)
        diagnosticsPanel = ACD:AddToBlizOptions(ns.OPTIONS_REGISTRY.Diagnostics, ns.DiagnosticsStrings.TAB, ns.L["ADDON_TITLE"])
    end

    --[[
        Pause Farm Mode while any of our options panels is visible. Recompute on
        every Show/Hide so the flag is correct regardless of the order Blizzard
        fires Hide/Show when the user switches between the General and Diagnostic
        Tools category panels.

        Use IsVisible(), NOT IsShown(): the Settings canvas keeps its OWN shown
        flag set when the parent Settings window closes, so IsShown() stays true
        and would latch Farm Mode paused forever after the panel is opened once.
        IsVisible() is true only when the frame and all ancestors are shown, so
        it goes false the moment the Settings window closes.
    ]]
    local function UpdateOptionsOpen()
        ns.optionsOpen = (mainPanel and mainPanel:IsVisible()) or (diagnosticsPanel and diagnosticsPanel:IsVisible()) or false
    end

    if mainPanel then
        mainPanel:HookScript("OnShow", UpdateOptionsOpen)
        mainPanel:HookScript("OnHide", UpdateOptionsOpen)
    end
    if diagnosticsPanel then
        diagnosticsPanel:HookScript("OnShow", UpdateOptionsOpen)
        diagnosticsPanel:HookScript("OnHide", UpdateOptionsOpen)
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
