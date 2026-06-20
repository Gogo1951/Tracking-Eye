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
L["PERSISTENT_DESC"] = "Automatically recasts your tracking spell after resurrection and shapeshifting."

L["FARM_MODE"] = "Farm Mode"
L["FARM_MODE_DESC"] = "Cycles between your selected tracking abilities while you're on the move."

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

-- General

L["OPTIONS_DESC"] = "Improved Tracking Menu and automatic tracking switcher that cycles Find Herbs and Find Minerals while farming and reapplies tracking after death. Supports every tracking ability. Never lose track of the resources you're hunting."
L["OPTIONS_ENABLE_WELCOME"] = "Enable Welcome Message"
L["OPTIONS_WELCOME_DESC"] = "Print a one-line greeting in chat when Tracking Eye loads."
L["OPTIONS_ENABLE_MINIMAP"] = "Enable Mini-map Button"
L["OPTIONS_ENABLE_MINIMAP_DESC"] = "Shows the Tracking Eye button on the minimap; Farm Mode and Persistent Tracking still run when it's hidden."

-- Slash Commands

L["OPTIONS_COMMANDS_INTRO"] = "Slash commands for Tracking Eye. The options panel covers everything you need; these are here for the keyboard-first folks."
L["OPTIONS_COMMAND_TE"] = "Opens the Tracking Eye options interface."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Enable Persistent Tracking"

-- Farm Mode

L["OPTIONS_ENABLE_FARM"] = "Enable Farm Mode"
L["OPTIONS_FARM_ACTIVATE"] = "Activate Farm Mode While:"
L["OPTIONS_FARM_MOUNTED"] = "Mounted"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Travel & Flight Forms"
L["OPTIONS_FARM_CHEETAH"] = "Aspect of the Cheetah"
L["OPTIONS_FARM_GHOST_WOLF"] = "Ghost Wolf"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Not Mounted"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Cycle even without a mount or movement form."
L["OPTIONS_FARM_NOTE"] = "Note: Farm Mode only runs while you're out of combat, not casting, and outside towns, inns, and instances."
L["OPTIONS_FARM_ABILITIES"] = "Farm Mode Abilities"
L["OPTIONS_CYCLE_SPEED"] = "Cycle Speed"
L["OPTIONS_CYCLE_SPEED_DESC"] = "How often Farm Mode switches between tracking abilities (in seconds)."

-- Free Placement Mode

L["OPTIONS_ENABLE_FREE"] = "Enable Free Placement Mode"
L["OPTIONS_ICON_SCALE"] = "Icon Size"
L["OPTIONS_ICON_SCALE_DESC"] = "Scale of the tracking icon when using Free Placement Mode."
L["OPTIONS_ICON_SHAPE"] = "Icon Shape"
L["OPTIONS_ICON_SHAPE_DESC"] = "Shape of the tracking icon border when using Free Placement Mode."
L["OPTIONS_SHAPE_CIRCLE"] = "Circle"
L["OPTIONS_SHAPE_SQUARE"] = "Square"

-- Reset

L["OPTIONS_RESET_HEADER"] = "Reset"
L["OPTIONS_RESET_DESC"] = "Restore every Tracking Eye setting to its default value."
L["OPTIONS_RESET"] = "Reset All Tracking Eye Options"
L["OPTIONS_RESET_CONFIRM"] = "Reset all Tracking Eye options to defaults?"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback & Support"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"