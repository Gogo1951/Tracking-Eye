local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "enUS", true)
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Settings (including the option to disable this message) can be found under Options > AddOns > Tracking Eye. Enjoying the add-on? Tell a friend about it! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "As a safety precaution, the Options Interface cannot be opened during combat."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Tracking Menu"
L["TRACKING_MENU_DESC"] = "Lists your tracking abilities and lets you set your Persistent Tracking Ability."
L["PERSISTENT_TRACKING"] = "Persistent Tracking"
L["PERSISTENT_DESC"] = "Automatically recasts your tracking ability after resurrection and shapeshifting."
L["FARM_MODE"] = "Farm Mode"
L["FARM_MODE_DESC"] = "Cycles between your selected tracking abilities while you're on the move."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "Farm Mode Status"
L["FARM_STATUS_ACTIVE"] = "Active"
L["FARM_STATUS_PAUSED"] = "Paused"

L["FARM_PAUSED_DEAD"] = "Dead."
L["FARM_PAUSED_TAXI"] = "On a flight path."
L["FARM_PAUSED_INSTANCE"] = "Inside an instance."
L["FARM_PAUSED_RESTING"] = "In a town or inn."
L["FARM_PAUSED_NO_ABILITIES"] = "No tracking abilities selected."
L["FARM_PAUSED_NO_STATES"] = "No Farm Mode conditions are switched on."
L["FARM_PAUSED_NOT_MOUNTED"] = "Not mounted."
L["FARM_PAUSED_NOT_TRAVEL"] = "Not in Travel Form."
L["FARM_PAUSED_NOT_CHEETAH"] = "Not using Aspect of the Cheetah."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "Not using Ghost Wolf."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Not mounted, not in Travel Form."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "Not mounted, not using Aspect of the Cheetah."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "Not mounted, not using Ghost Wolf."
L["FARM_PAUSED_MOUNTED_OFF"] = "Farm Mode is not set to run while mounted."
L["FARM_PAUSED_TRAVEL_OFF"] = "Farm Mode is not set to run in Travel Form."
L["FARM_PAUSED_CHEETAH_OFF"] = "Farm Mode is not set to run under Aspect of the Cheetah."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "Farm Mode is not set to run under Ghost Wolf."
L["FARM_PAUSED_COMBAT"] = "In combat."
L["FARM_PAUSED_CASTING"] = "Casting."
L["FARM_PAUSED_STEALTHED"] = "Stealthed."
L["FARM_PAUSED_LOOTING"] = "Loot window is open."
L["FARM_PAUSED_CURSOR"] = "Something is on your cursor."
L["FARM_PAUSED_OPTIONS"] = "Options Interface is open."
L["FARM_PAUSED_WINDOW"] = "A window is open."
L["FARM_PAUSED_TOOLTIP"] = "Reading a tooltip."

L["PERSISTENT_ABILITY"] = "Persistent Tracking Ability"
L["SILENCE_TRACKING_SOUNDS"] = "Silence Tracking Sounds"
L["NONE_SET"] = "None Set"
L["CLEAR_TRACKING"] = "Clear Tracking"

L["ENABLED"] = "Enabled"
L["DISABLED"] = "Disabled"
L["TOGGLE"] = "Toggle"

L["OPEN"] = "Open"
L["LEFT_CLICK"] = "Left-Click"
L["RIGHT_CLICK"] = "Right-Click"
L["SHIFT_LEFT"] = "Shift + Left-Click"
L["SHIFT_RIGHT"] = "Shift + Right-Click"
L["SHIFT_MIDDLE"] = "Shift + Middle-Click"

L["TOOLTIP_OPTIONS"] = "Tracking Eye Options"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "Cycle Farm Mode Ability"
L["BINDING_NOTHING_TO_CYCLE"] =
	"No tracking abilities are selected for Farm Mode. Pick some under Options > AddOns > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"Improved Tracking Menu and automatic tracking switcher that cycles Find Herbs and Find Minerals while farming and reapplies tracking after death. Supports every tracking ability. Never lose track of the resources you're hunting."
L["OPTIONS_ENABLE_WELCOME"] = "Enable Welcome Message"
L["OPTIONS_WELCOME_DESC"] = "Prints a one-line greeting in chat when Tracking Eye loads."
L["OPTIONS_ENABLE_MINIMAP"] = "Enable Mini-map Button"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"Shows the Tracking Eye button on the mini-map; Farm Mode and Persistent Tracking still run when it's hidden."
L["OPTIONS_HOOK_BLIZZARD"] = "Use the Default Tracking Button"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"While this is on, Blizzard's tracking icon opens the Tracking Eye menu, which only changes what you're tracking. Everything else stays here in the Options Interface."
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"Opens the Tracking Menu when you click Blizzard's tracking icon on the mini-map. Leave this off if another add-on already uses that button."
L["OPTIONS_KEYBINDS"] = "Key Bindings"
L["OPTIONS_KEYBINDS_DESC"] =
	"Advances Farm Mode to its next ability on demand. Set it under Key Bindings in the game menu, in the Tracking Eye section."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Slash command for Tracking Eye. The Options Interface covers everything you need; this is here for the keyboard-first folks."
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Enable Persistent Tracking"
L["OPTIONS_TARGET_TRACKING"] = "Automatic Target Tracking"
L["OPTIONS_TARGET_TRACKING_DESC"] = "Tracks whatever you target, so the rest of its kind appears on your mini-map."
L["OPTIONS_TARGET_TRACKING_QUESTING"] = "Note: Automatic Target Tracking is great for questing!"

-- Farm Mode

L["TAB_FARM_MODE"] = "Farm Mode"
L["OPTIONS_ENABLE_FARM"] = "Enable Farm Mode"
L["OPTIONS_FARM_CONDITIONS"] = "Farm Mode Conditions"
L["OPTIONS_FARM_MOUNTED"] = "Mounted"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Travel & Flight Forms"
L["OPTIONS_FARM_CHEETAH"] = "Aspect of the Cheetah"
L["OPTIONS_FARM_GHOST_WOLF"] = "Ghost Wolf"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Not Mounted"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Cycles even without a mount or movement form."
L["OPTIONS_FARM_NOTE"] =
	"Note: Farm Mode only runs while you're out of combat, not casting, and outside towns, inns, instances, and flight paths."
L["OPTIONS_FARM_ABILITIES"] = "Farm Mode Abilities"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"Includes your Persistent Tracking Ability in the rotation. If it is already ticked below, it still comes up only once."
L["OPTIONS_CYCLE_EVERY"] = "Cycle Every %s Seconds"
L["OPTIONS_CYCLE_EVERY_DESC"] = "How often Farm Mode switches between tracking abilities (in seconds)."
L["SILENCE_TRACKING_SOUNDS_DESC"] = "Silences the casting sound as Farm Mode cycles. Your own casts are unaffected."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Free Placement Mode"
L["PLACEMENT_DESC"] = "Replaces the mini-map button with a standalone icon you can move anywhere."
L["OPTIONS_ENABLE_FREE"] = "Enable Free Placement Mode"
L["OPTIONS_ICON_SCALE"] = "Icon Size"
L["OPTIONS_ICON_SCALE_DESC"] = "Size of the tracking icon when using Free Placement Mode."
L["OPTIONS_ICON_SHAPE"] = "Icon Shape"
L["OPTIONS_ICON_SHAPE_DESC"] = "Shape of the tracking icon border when using Free Placement Mode."
L["OPTIONS_SHAPE_CIRCLE"] = "Circle"
L["OPTIONS_SHAPE_SQUARE"] = "Square"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback & Support"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
