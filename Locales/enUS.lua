local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "enUS", true)
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Version %s. Settings (including the option to disable this message) can be found under Options > AddOns > Tracking Eye. Enjoying the add-on? Tell a friend about it! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Tracking Menu"
L["TRACKING_MENU_DESC"] = "See a list of your tracking abilities, and set Persistent Tracking Ability."

L["PERSISTENT_ABILITY"] = "Persistent Tracking Ability"
L["NONE_SET"] = "None Set"
L["CLEAR_TRACKING"] = "Clear Tracking"

L["PERSISTENT_TRACKING"] = "Persistent Tracking"
L["PERSISTENT_DESC"] = "Automatically recasts your tracking spell after resurrection."

L["FARM_MODE"] = "Farm Mode"
L["FARMING_DESC"] = "Cycles between your selected tracking abilities while mounted or in travel form."

L["PLACEMENT_MODE"] = "Free Placement Mode"
L["PLACEMENT_DESC"] = "Replace the minimap button with a standalone icon you can move anywhere."

L["ENABLED"] = "Enabled"
L["DISABLED"] = "Disabled"
L["TOGGLE"] = "Toggle"

L["LEFT_CLICK"] = "Left-Click"
L["RIGHT_CLICK"] = "Right-Click"
L["SHIFT_LEFT"] = "Shift + Left-Click"
L["SHIFT_RIGHT"] = "Shift + Right-Click"
L["SHIFT_MIDDLE"] = "Shift + Middle-Click"

L["TOOLTIP_OPTIONS_HINT"] = "Additional settings can be found under Options > AddOns > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] = "Improved Tracking Menu and automatic tracking switcher that cycles Find Herbs and Find Minerals while farming and reapplies tracking after death. Supports every tracking ability. Never lose track of the resources you’re hunting."
L["OPTIONS_COMMANDS_INTRO"] = "Slash commands for Tracking Eye. The options panel covers everything you need; these are here for the keyboard-first folks."
L["OPTIONS_COMMAND_TE"] = "Opens the Tracking Eye options interface."
L["OPTIONS_WELCOME_DESC"] = "Print a one-line greeting in chat when Tracking Eye loads."
L["OPTIONS_RESET"] = "Reset All Tracking Eye Options"
L["OPTIONS_RESET_HEADER"] = "Reset"
L["OPTIONS_RESET_DESC"] = "Restore every Tracking Eye setting to its default value."
L["OPTIONS_RESET_CONFIRM"] = "Reset all Tracking Eye options to defaults?"
L["OPTIONS_ENABLE_PERSISTENT"] = "Enable Persistent Tracking"
L["OPTIONS_ENABLE_FARM"] = "Enable Farm Mode"
L["OPTIONS_ENABLE_FREE"] = "Enable Free Placement Mode"
L["OPTIONS_ENABLE_WELCOME"] = "Enable Welcome Message"
L["OPTIONS_FARM_ABILITIES"] = "Farm Mode Abilities"
L["OPTIONS_CYCLE_SPEED"] = "Cycle Speed"
L["OPTIONS_CYCLE_SPEED_DESC"] = "How often Farm Mode switches between tracking abilities (in seconds)."
L["OPTIONS_ICON_SCALE"] = "Icon Size"
L["OPTIONS_ICON_SCALE_DESC"] = "Scale of the tracking icon when using Free Placement Mode."
L["OPTIONS_ICON_SHAPE"] = "Icon Shape"
L["OPTIONS_ICON_SHAPE_DESC"] = "Shape of the tracking icon border when using Free Placement Mode."
L["OPTIONS_SHAPE_CIRCLE"] = "Circle"
L["OPTIONS_SHAPE_SQUARE"] = "Square"
L["OPTIONS_LINKS"] = "Feedback & Support"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
