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

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "Tracking Menu"
L["TRACKING_MENU_DESCRIPTION"] = "Choose your Persistent Tracking Ability."
L["PERSISTENT_TRACKING"] = "Persistent Tracking"
L["TARGET_TRACKING"] = "Automatic Target Tracking"
L["TARGET_TRACKING_DESCRIPTION"] = "Tracks whatever kind of creature you target."
L["FARM_MODE"] = "Farm Mode"
L["FARM_MODE_DESCRIPTION"] = "Cycles your tracking abilities as you travel."

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
L["FARM_PAUSED_NO_ABILITIES"] = "You haven't selected any abilities to cycle for Farm Mode."
L["FARM_PAUSED_NOT_LEARNED"] = "You don't know any of the abilities you have selected to cycle for Farm Mode."
L["FARM_PAUSED_CAT_FORM"] = "Druid tracking only cycles in Cat Form."
L["FARM_PAUSED_NO_STATES"] = "No Farm Mode Conditions are switched on."
L["FARM_PAUSED_NOT_MOUNTED"] = "Not mounted."
L["FARM_PAUSED_NOT_TRAVEL"] = "Not in a travel form."
L["FARM_PAUSED_NOT_CHEETAH"] = "Not using Aspect of the Cheetah."
L["FARM_PAUSED_NOT_PACK"] = "Not using Aspect of the Pack."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "Not in Ghost Wolf."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Not mounted or in a travel form."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "Not mounted or using Aspect of the Cheetah."
L["FARM_PAUSED_NOT_MOUNTED_PACK"] = "Not mounted or using Aspect of the Pack."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "Not mounted or in Ghost Wolf."
L["FARM_PAUSED_MOUNTED_OFF"] = "Farm Mode is not set to run while mounted."
L["FARM_PAUSED_TRAVEL_OFF"] = "Farm Mode is not set to run in travel forms."
L["FARM_PAUSED_CHEETAH_OFF"] = "Farm Mode is not set to run under Aspect of the Cheetah."
L["FARM_PAUSED_PACK_OFF"] = "Farm Mode is not set to run under Aspect of the Pack."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "Farm Mode is not set to run in Ghost Wolf."
L["FARM_PAUSED_COMBAT"] = "In combat."
L["FARM_PAUSED_CASTING"] = "Casting."
L["FARM_PAUSED_STEALTHED"] = "Stealthed."
L["FARM_PAUSED_LOOTING"] = "The loot window is open."
L["FARM_PAUSED_CURSOR"] = "Something is on your cursor."
L["FARM_PAUSED_OPTIONS"] = "The Options Interface is open."
L["FARM_PAUSED_WINDOW"] = "A window is open."
L["FARM_PAUSED_TOOLTIP"] = "Reading a tooltip."
L["FARM_PAUSED_TARGET"] = "Targeting something you can attack."
L["FARM_PAUSED_STANDING_STILL"] = "Standing still."

L["PERSISTENT_ABILITY"] = "Persistent Tracking Ability"
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
	"No tracking abilities are selected for Farm Mode. Pick some under Options > AddOns > Tracking Eye > Farm Mode."
L["BINDING_NOTHING_LEARNED"] = "You don't know any of the abilities you have selected to cycle for Farm Mode."
L["BINDING_NEEDS_CAT_FORM"] = "Druid tracking can only be cast in Cat Form."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESCRIPTION"] =
	"Improved Tracking Menu and automatic switcher that cycles Find Herbs and Find Minerals while farming, restores tracking after death, and tracks targeted creatures while questing. Supports every tracking ability. Never lose track of what you're hunting."
L["OPTIONS_ENABLE_WELCOME"] = "Enable Welcome Message"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] = "Prints a one-line greeting in chat when Tracking Eye loads."
L["OPTIONS_ENABLE_MINIMAP"] = "Enable Mini-map Button"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "Everything keeps running with the button hidden."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "Key Bindings"
L["OPTIONS_KEYBINDS_DESCRIPTION"] =
	"Jump to the next tracking ability with one key, even with Farm Mode off. Bind it under Key Bindings in the game menu."

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"Every tracking ability you know, in one alphabetical menu. Whatever you pick becomes your Persistent Tracking Ability."
L["OPTIONS_HOOK_BLIZZARD"] = "Use the Default Tracking Button"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"Blizzard's tracking button opens this menu too. Leave it off if another add-on already uses that button."

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"Never lose your tracking again: it comes right back after you die, shapeshift, or zone."
L["OPTIONS_ENABLE_PERSISTENT"] = "Enable Persistent Tracking"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"Waits until you're out of combat, so it never costs you a global cooldown mid-fight."
L["OPTIONS_FISHING_POLE_FISH"] = "Find Fish when you Equip a Fishing Pole"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "Your own pick comes back when you put the pole away."
L["OPTIONS_CAT_FORM_HUMANOIDS"] = "Druid: Track Humanoids when you Shift into Cat Form"
L["OPTIONS_CAT_FORM_HUMANOIDS_DESCRIPTION"] = "Waits out Prowl, and your own pick comes back when you shift out."
L["OPTIONS_BATTLEGROUND_HUMANOIDS"] = "Hunter: Track Humanoids in Battlegrounds"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] = "Arenas count too, and your own pick comes back when you leave."

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"Target a creature and the rest of its kind lights up on your mini-map. Great for questing!"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "Enable Automatic Target Tracking"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"Never switches in combat, so adds can't hijack your tracking. Looting a corpse won't switch it either."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Free Placement Mode"
L["OPTIONS_PLACEMENT_DESCRIPTION"] =
	"Crowded mini-map? Pull the tracking icon off it and park it anywhere on your screen."
L["OPTIONS_ENABLE_FREE"] = "Enable Free Placement Mode"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"Its spot is shared by all your characters and holds through reloads and UI scale changes."
L["OPTIONS_ICON_SHAPE"] = "Icon Shape"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] = "Circle matches the mini-map; square sits neatly beside action buttons."
L["OPTIONS_SHAPE_CIRCLE"] = "Circle"
L["OPTIONS_SHAPE_SQUARE"] = "Square"
L["OPTIONS_ICON_SCALE"] = "Icon Size"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] = "Resizes in place, so the icon keeps its spot."

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback & Support"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Version %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "Farm Mode"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"Herbs and ore on the same mini-map. Farm Mode flips between your tracking abilities while you travel, so no node slips past."
L["OPTIONS_ENABLE_FARM"] = "Enable Farm Mode"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"Pauses on its own in combat, towns, instances, and on flights. Hover the Tracking Eye button to see why."
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "Silence Sounds from Tracking Ability Casts"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"Only Farm Mode's own switches go quiet. Tracking you pick yourself still makes its sound."
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "Zoom Mini-map Out"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] =
	"Zoomed all the way out, the mini-map shows tracked nodes from much farther away."
L["OPTIONS_FARM_CONDITIONS"] = "Farm Mode Conditions"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"Farm your way: mounted, on foot, or in your class's travel form. Farm Mode cycles in any state you tick."
L["OPTIONS_FARM_MOUNTED"] = "Mounted"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] = "Dismount at a node and the cycle waits while you gather."
L["OPTIONS_FARM_NOT_MOUNTED"] = "Not Mounted"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] = "Stop to gather or eat and the cycle waits until you move on."
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Druid: Travel Forms"
L["OPTIONS_FARM_TRAVEL_FORMS_DESCRIPTION"] = "Aquatic Form and Flight Form count too."
L["OPTIONS_FARM_CHEETAH"] = "Hunter: Aspect of the Cheetah"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "Only cycles while you're on the move, like every other condition."
L["OPTIONS_FARM_PACK"] = "Hunter: Aspect of the Pack"
L["OPTIONS_FARM_PACK_DESCRIPTION"] = "Handy on group gathering runs, where the whole party moves at Cheetah speed."
L["OPTIONS_FARM_GHOST_WOLF"] = "Shaman: Ghost Wolf"
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "Great for gathering runs before your first mount."
L["OPTIONS_CYCLE_SPEED"] = "Cycle Speed"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"Each switch costs a global cooldown, so a slower cycle clashes less with your own casts."
L["OPTIONS_CYCLE_EVERY"] = "Cycle Every %s Seconds"
L["OPTIONS_FARM_ABILITIES"] = "Farm Mode Abilities"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"Tick what you want to find. Farm Mode cycles every ticked ability this character knows and skips the rest."
L["OPTIONS_FARM_GROUP_GENERAL"] = "Professions & Racial Abilities"
L["OPTIONS_FARM_CAT_FORM_NOTE"] = "Only cycles in Cat Form, which counts as Not Mounted."
L["OPTIONS_FARM_PERSISTENT"] = "Include Persistent Tracking Ability"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"Never comes up twice, even if it's also ticked below. Automatic Target Tracking swaps your target's kind in for it."

--------------------------------------------------------------------------------
-- Come & Get It
--------------------------------------------------------------------------------

--[[
    Not display copy. MATCH_* must equal the profession skill names exactly as
    the game client displays them in this language: they are substring-matched
    against the client's error text, so a loose or stylized translation silently
    stops Come & Get It from detecting herbs and ore at all. Where this
    language's clients disagree on a name, list every one, separated by
    semicolons.
]]

L["MATCH_HERB"] = "Herbalism"
L["MATCH_MINE"] = "Mining"

--[[
    Translator guidance. Each MSG_FORMAT_* string is the complete line drafted
    into the player's chat box, picked by what the player could not interact
    with. The code fills four %s placeholders in this fixed order: node name,
    x coordinate, y coordinate, zone name. Reorder the sentence freely for your
    language, but never reorder, add, or drop placeholders.

    The greeting closes on "!" so the node name starts a fresh clause with nothing
    in front of it. That is load-bearing, not stylistic: no article or adjective
    has to agree with a name whose gender and number are unknown until runtime, and
    English dodges a/an ("an Iron Deposit" vs "a Gold Vein") for free. If your
    language reads better with an article, attach it to a fixed word rather than to
    the placeholder.

    Don't add a raid marker or the add-on name: WoW Forever blocks raid markers
    in chat, and the line reads as the player talking.
]]

L["MSG_FORMAT_LOCKED"] = "Hey Rogues! %s at %s, %s in %s."
L["MSG_FORMAT_HERB"] = "Hey Herbalists! %s at %s, %s in %s."
L["MSG_FORMAT_MINE"] = "Hey Miners! %s at %s, %s in %s."

L["CHAT_TOO_LONG"] = "This draft is %d bytes, over the %d-byte chat limit. Shorten it before sending."

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"Found an herb you can't pick, a mineral vein you can't mine, or a locked treasure chest with no Rogue in sight? Right-click it, and Come & Get It creates a message you can use to share or broadcast the coordinates. Being a hero has never been so easy."
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "Enable Come & Get It"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"Stays quiet in combat and in instances, so the chat box never grabs your keyboard mid-fight."
L["OPTIONS_OUTPUT_NAME"] = "Default Output"
L["OPTIONS_OUTPUT_DESCRIPTION"] = "Guild reaches every guildmate online, whatever their layer or zone."
L["OPTIONS_OUTPUT_NOTE"] = "Note: Local (/1) only reaches players on your layer."
L["OPTIONS_OUTPUT_CHANNEL1"] = "Local (/1)"
L["OPTIONS_OUTPUT_SAY"] = "Say"
L["OPTIONS_OUTPUT_YELL"] = "Yell"
L["OPTIONS_OUTPUT_PARTY"] = "Party"
L["OPTIONS_OUTPUT_GUILD"] = "Guild"
