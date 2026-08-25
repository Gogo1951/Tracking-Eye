std = "lua51"
max_line_length = false -- StyLua owns formatting
self = false -- dot-defined and method-defined helpers share signatures; implicit self is often unused
ignore = { "611", "612", "613", "614", "621" } -- whitespace warnings — StyLua owns these too
exclude_files = { "Includes/" } -- vendored, never linted
read_globals = {
	-- Libraries
	"LibStub",
	-- Frames & UI globals
	"CreateFont",
	"CreateFrame",
	"GameTooltip",
	"MiniMapTracking",
	"MiniMapTrackingButton",
	"MiniMapTrackingIcon",
	"UIPanelWindows",
	"UIParent",
	-- Modern API namespaces
	"C_AddOns",
	"C_EventUtils",
	"C_Timer",
	"Settings",
	-- Legacy halves of compatibility guards
	"GetAddOnInfo",
	"GetAddOnMetadata",
	"GetNumAddOns",
	"InterfaceOptionsFrame_OpenToCategory",
	-- WoW API
	"CancelTrackingBuff",
	"CastSpellByID",
	"GetBuildInfo",
	"GetCVar",
	"GetCursorInfo",
	"GetInstanceInfo",
	"GetLocale",
	"GetPhysicalScreenSize",
	"GetSpellCooldown",
	"GetSpellInfo",
	"GetSpellTexture",
	"GetTime",
	"GetTrackingTexture",
	"InCombatLockdown",
	"IsInInstance",
	"IsMounted",
	"IsPlayerSpell",
	"IsResting",
	"IsShiftKeyDown",
	"IsStealthed",
	"MouseIsOver",
	"SetCVar",
	"UnitAffectingCombat",
	"UnitBuff",
	"UnitCanAttack",
	"UnitCastingInfo",
	"UnitClass",
	"UnitCreatureType",
	"UnitExists",
	"UnitIsDeadOrGhost",
	"UnitLevel",
	"UnitOnTaxi",
	"WOW_PROJECT_ID",
}
globals = {
	-- exactly the add-on's own sanctioned globals
	"TrackingEyeDB",
	"SLASH_TRACKINGEYE1",
	"SlashCmdList",
	"TrackingEye_CycleFarmAbility",
	"BINDING_NAME_TRACKINGEYE_CYCLE_FARM_ABILITY",
}
