local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Options Registration (AceConfig-3.0)
--------------------------------------------------------------------------------

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

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
local farmModePanel
local comeAndGetItPanel
local profilesPanel
local diagnosticsPanel

function ns.RegisterOptionsPanels()
	AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.General, ns.BuildGeneralOptions)
	--[[
        AddToBlizOptions returns (frame, categoryID). Capture the ID: it is what
        Settings.OpenToCategory expects. Looking the category up by localized name
        instead is fragile, because AceConfigDialog only aliases category.ID to the
        display name on clients that lack C_SettingsUtil.OpenSettingsPanel. Clients
        that have that API keep a generated ID, so a name lookup returns nil.
    ]]
	mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.General, L["ADDON_TITLE"])

	-- Farm Mode panel, registered after General so it sits directly beneath it.
	if ns.BuildFarmModeOptions then
		AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.FarmMode, ns.BuildFarmModeOptions)
		farmModePanel =
			AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.FarmMode, L["TAB_FARM_MODE"], L["ADDON_TITLE"])
	end

	-- Come & Get It panel, registered after Farm Mode so it sits directly beneath it.
	if ns.BuildComeAndGetItOptions then
		AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.ComeAndGetIt, ns.BuildComeAndGetItOptions)
		comeAndGetItPanel = AceConfigDialog:AddToBlizOptions(
			ns.OPTIONS_REGISTRY.ComeAndGetIt,
			L["TAB_COME_AND_GET_IT"],
			L["ADDON_TITLE"]
		)
	end

	-- Profiles panel, registered second-to-last (the stock AceDBOptions table).
	if ns.BuildProfilesOptions then
		local profilesTable = ns.BuildProfilesOptions()
		AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Profiles, profilesTable)
		profilesPanel =
			AceConfigDialog:AddToBlizOptions(ns.OPTIONS_REGISTRY.Profiles, profilesTable.name, L["ADDON_TITLE"])
	end

	-- Diagnostic Tools panel, registered last so it sits at the bottom of the tree
	if ns.BuildDiagnosticsOptions and ns.OPTIONS_REGISTRY then
		AceConfigRegistry:RegisterOptionsTable(ns.OPTIONS_REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions)
		diagnosticsPanel = AceConfigDialog:AddToBlizOptions(
			ns.OPTIONS_REGISTRY.Diagnostics,
			ns.DiagnosticsStrings.TAB,
			L["ADDON_TITLE"]
		)
	end
end

--[[
    Pause Farm Mode while any of our options panels is on screen, so a cycle cast
    can't fire under the player mid-edit.

    Evaluated live on every call, never cached behind Show/Hide hooks. Closing the
    Settings window hides the WINDOW, not our canvas, so the canvas keeps its own
    shown flag and its OnHide never fires — a cached flag therefore keeps the last
    value it saw (true) and pauses Farm Mode until the next reload.

    IsVisible(), not IsShown(), for the same underlying reason: IsShown() reports
    the frame's own flag, which stays set, while IsVisible() also requires every
    ancestor to be shown and so goes false the moment the Settings window closes.
]]
function ns.IsOptionsPanelOpen()
	return (mainPanel and mainPanel:IsVisible())
		or (farmModePanel and farmModePanel:IsVisible())
		or (comeAndGetItPanel and comeAndGetItPanel:IsVisible())
		or (profilesPanel and profilesPanel:IsVisible())
		or (diagnosticsPanel and diagnosticsPanel:IsVisible())
		or false
end

--[[
    Redraw every registered panel. AceConfig only re-evaluates a widget's dynamic
    name, disabled, or get callbacks when it redraws, so a setting changed from
    outside the panel — the tracking menu, the mini-map button — leaves an open
    page showing stale values until something calls this.
]]
function ns.RefreshOptionsPanels()
	local registry = LibStub("AceConfigRegistry-3.0")
	for _, name in pairs(ns.OPTIONS_REGISTRY) do
		registry:NotifyChange(name)
	end
end

function ns:OpenOptionsPanel()
	--[[
        Blizzard's Settings panel is protected in combat: without this gate the
        player gets an ADDON_ACTION_BLOCKED error naming Tracking Eye. One gate in
        front of the whole routing chain, and it returns rather than queueing —
        a refusal the player asked for is printed every time.
    ]]
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end

	if not mainPanel and not mainCategoryID then
		return
	end

	--[[
        Routed by the category ID captured at registration, never by a name or
        title lookup, which returns nil wherever AceConfigDialog keeps a generated
        category ID and drops the panel into a floating standalone window.
    ]]
	if Settings and Settings.OpenToCategory and mainCategoryID then
		Settings.OpenToCategory(mainCategoryID)
		return
	end

	--[[
        Last resort, reached only when registration failed to return a category
        ID. Opens a standalone window rather than the in-game Settings panel, so it
        is a visible symptom rather than a silent no-op.
    ]]
	AceConfigDialog:Open(ns.OPTIONS_REGISTRY.General)
end
