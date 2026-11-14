local _, ns = ...

local L = ns.L

--------------------------------------------------------------------------------
-- Options Registration (AceConfig-3.0)
--------------------------------------------------------------------------------

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local REGISTRY = ns.OPTIONS_REGISTRY

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

--[[
    Registration is deferred to ns.RegisterOptionsPanels, called once from
    Features/Core.lua after AceDB creates ns.db: the Profiles panel's tree label
    is read from the stock AceDBOptions-3.0 table, which needs the database.

    One panel per feature directly under the root, in the root panel's Features
    order (ns.FEATURES):

      Tracking Eye    (welcome, mini-map, Features, Key Bindings, /Commands)
        Persistent Tracking
        Farm Mode               Abilities
        Target Tracking
        Come & Get It
        Free Placement Mode
        Profiles, Feedback & Support, Diagnostic Tools

    Child-panel order is the order of the AddToBlizOptions calls. The last
    argument is the parent: the root's display name for a feature panel, or a
    panel's category ID to nest a sub-panel a level deeper. AceConfigDialog maps
    only root names to IDs, so a sub-panel passes the ID its parent's
    registration returned; the Settings panel finds a category at any depth by
    ID and indents each level.

    AddToBlizOptions returns (frame, categoryID). Both are kept by registry key:
    the frame so ns.IsOptionsPanelOpen can check it, the ID so
    ns:OpenOptionsPanel can open any panel directly. A lookup by localized name
    instead is fragile: AceConfigDialog only aliases category.ID to the display
    name on clients that lack C_SettingsUtil.OpenSettingsPanel, and clients that
    have that API keep a generated ID, so a name lookup returns nil.
]]
local frames = {}
local categories = {}

local function Register(registryKey, builder, displayName, parent)
	AceConfigRegistry:RegisterOptionsTable(REGISTRY[registryKey], builder)
	local frame, categoryID = AceConfigDialog:AddToBlizOptions(REGISTRY[registryKey], displayName, parent)
	frames[registryKey] = frame
	categories[registryKey] = categoryID
	return categoryID
end

local function RegisterChild(registryKey, builder, displayName, parentID)
	return Register(registryKey, builder, displayName, parentID or L["ADDON_TITLE"])
end

function ns.RegisterOptionsPanels()
	Register("General", ns.BuildGeneralOptions, L["ADDON_TITLE"])

	RegisterChild("PersistentTracking", ns.BuildPersistentTrackingOptions, L["PERSISTENT_TRACKING"])
	local farmModeID = RegisterChild("FarmMode", ns.BuildFarmModeOptions, L["TAB_FARM_MODE"])
	RegisterChild("FarmAbilities", ns.BuildFarmAbilitiesOptions, L["TAB_FARM_ABILITIES"], farmModeID)
	RegisterChild("TargetTracking", ns.BuildTargetTrackingOptions, L["TARGET_TRACKING"])
	RegisterChild("ComeAndGetIt", ns.BuildComeAndGetItOptions, L["TAB_COME_AND_GET_IT"])
	RegisterChild("FreePlacement", ns.BuildFreePlacementOptions, L["PLACEMENT_MODE"])

	--[[
        Profiles panel: the stock AceDBOptions-3.0 table, unmodified. Its display
        name comes already-localized from AceDBOptions, read off the built table
        so we neither hardcode it nor add a locale key for a stock widget.
    ]]
	local profilesOptions = ns.BuildProfilesOptions()
	RegisterChild("Profiles", profilesOptions, profilesOptions.name)

	RegisterChild("FeedbackSupport", ns.BuildFeedbackSupportOptions, L["OPTIONS_FEEDBACK"])

	--[[
        Diagnostic Tools last so it sits at the bottom of the tree. Its display
        name is a plain English string, never a locale key.
    ]]
	RegisterChild("Diagnostics", ns.BuildDiagnosticsOptions, ns.DiagnosticsStrings.TAB)
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
	for _, frame in pairs(frames) do
		if frame:IsVisible() then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

--[[
    Opens the root panel, or the panel named by an ns.OPTIONS_REGISTRY key.

    Blizzard's Settings panel is protected in combat: without this gate the
    player gets an ADDON_ACTION_BLOCKED error naming Tracking Eye. One gate in
    front of the whole routing chain, and it returns rather than queueing — a
    refusal the player asked for is printed every time.
]]
function ns:OpenOptionsPanel(panel)
	if InCombatLockdown() then
		ns:PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end

	if not frames.General and not categories.General then
		return
	end

	--[[
        Routed by the category ID captured at registration, never by a name or
        title lookup, which returns nil wherever AceConfigDialog keeps a generated
        category ID and drops the panel into a floating standalone window.
    ]]
	local categoryID = categories[panel] or categories.General
	if Settings and Settings.OpenToCategory and categoryID then
		Settings.OpenToCategory(categoryID)
		return
	end

	--[[
        Last resort, reached only when registration failed to return a category
        ID. Opens a standalone window rather than the in-game Settings panel, so it
        is a visible symptom rather than a silent no-op.
    ]]
	AceConfigDialog:Open(REGISTRY[panel] or REGISTRY.General)
end
