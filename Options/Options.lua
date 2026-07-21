local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Options Registration (AceConfig-3.0)
--------------------------------------------------------------------------------

local AC = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Slash Command
--------------------------------------------------------------------------------
SLASH_TRACKINGEYE1 = "/te"
SlashCmdList["TRACKINGEYE"] = function()
	ns:OpenOptionsPanel()
end

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------
local mainPanel
local mainCategoryID
local profilesPanel
local diagnosticsPanel

function ns.InitOptions()
	AC:RegisterOptionsTable(ns.OPTIONS_REGISTRY.General, ns.BuildGeneralOptions)
	--[[
        AddToBlizOptions returns (frame, categoryID). Capture the ID: it is what
        Settings.OpenToCategory expects. Looking the category up by localized name
        instead is fragile, because AceConfigDialog only aliases category.ID to the
        display name on clients that lack C_SettingsUtil.OpenSettingsPanel. Clients
        that have that API keep a generated ID, so a name lookup returns nil.
    ]]
	mainPanel, mainCategoryID = ACD:AddToBlizOptions(ns.OPTIONS_REGISTRY.General, L["ADDON_TITLE"])

	-- Profiles panel, registered second-to-last (the stock AceDBOptions table).
	if ns.BuildProfilesOptions then
		local profilesTable = ns.BuildProfilesOptions()
		AC:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Profiles, profilesTable)
		profilesPanel = ACD:AddToBlizOptions(ns.OPTIONS_REGISTRY.Profiles, profilesTable.name, L["ADDON_TITLE"])
	end

	-- Diagnostic Tools panel, registered last so it sits at the bottom of the tree
	if ns.BuildDiagnosticsOptions and ns.OPTIONS_REGISTRY then
		AC:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions)
		diagnosticsPanel =
			ACD:AddToBlizOptions(ns.OPTIONS_REGISTRY.Diagnostics, ns.DiagnosticsStrings.TAB, L["ADDON_TITLE"])
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
		ns.optionsOpen = (mainPanel and mainPanel:IsVisible())
			or (profilesPanel and profilesPanel:IsVisible())
			or (diagnosticsPanel and diagnosticsPanel:IsVisible())
			or false
	end

	if mainPanel then
		mainPanel:HookScript("OnShow", UpdateOptionsOpen)
		mainPanel:HookScript("OnHide", UpdateOptionsOpen)
	end
	if profilesPanel then
		profilesPanel:HookScript("OnShow", UpdateOptionsOpen)
		profilesPanel:HookScript("OnHide", UpdateOptionsOpen)
	end
	if diagnosticsPanel then
		diagnosticsPanel:HookScript("OnShow", UpdateOptionsOpen)
		diagnosticsPanel:HookScript("OnHide", UpdateOptionsOpen)
	end
end

function ns:OpenOptionsPanel()
	if Settings and Settings.OpenToCategory and mainCategoryID then
		Settings.OpenToCategory(mainCategoryID)
		return
	end
	if InterfaceOptionsFrame_OpenToCategory then
		InterfaceOptionsFrame_OpenToCategory(mainPanel)
		-- Called twice for Classic compatibility
		InterfaceOptionsFrame_OpenToCategory(mainPanel)
		return
	end
	-- Last resort only: a standalone window, not the in-game Settings panel.
	ACD:Open(ns.OPTIONS_REGISTRY.General)
end
