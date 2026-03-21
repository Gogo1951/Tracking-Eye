local _, te = ...
local L = setmetatable({}, {__index = function(_, k) return k end})
te.L = L

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "Tracking Menu"
L["TRACKING_MENU_DESC"] = "See a list of your tracking abilities, and set Persistent Tracking Ability."

L["PERSISTENT_ABILITY"] = "Persistent Tracking Ability"
L["NONE_SET"]           = "None Set"
L["CLEAR_TRACKING"]     = "Clear Tracking"

L["PERSISTENT_TRACKING"] = "Persistent Tracking"
L["PERSISTENT_DESC"]      = "Automatically recasts your tracking spell after resurrection."

L["FARM_MODE"]    = "Farm Mode"
L["FARMING_DESC"] = "Cycles between Herbs, Minerals, and Treasure while mounted or in travel form."

L["PLACEMENT_MODE"] = "Free Placement Mode"
L["PLACEMENT_DESC"] = "Replace the minimap button with a standalone icon you can move anywhere."

L["ENABLED"]  = "Enabled"
L["DISABLED"] = "Disabled"
L["TOGGLE"]   = "Toggle"

L["LEFT_CLICK"]    = "Left-Click"
L["RIGHT_CLICK"]   = "Right-Click"
L["SHIFT_LEFT"]    = "Shift + Left-Click"
L["SHIFT_RIGHT"]   = "Shift + Right-Click"
L["SHIFT_MIDDLE"]  = "Shift + Middle-Click"

L["TOOLTIP_OPTIONS_HINT"] = "Additional options available by typing /te or going to Options > AddOns > Tracking Eye."

-- Options Panel
L["OPTIONS_RESET"]               = "Reset All Options"
L["OPTIONS_ENABLE_PERSISTENT"]   = "Enable Persistent Tracking"
L["OPTIONS_ENABLE_FARM"]         = "Enable Farm Mode"
L["OPTIONS_ENABLE_FREE"]         = "Enable Free Placement Mode"
L["OPTIONS_FARM_ABILITIES"]      = "Farm Mode Abilities"
L["OPTIONS_FARM_ABILITIES_DESC"] = "Select which tracking abilities Farm Mode will cycle through while mounted or in travel form."
L["OPTIONS_CYCLE_SPEED"]         = "Cycle Speed"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "How often Farm Mode switches between tracking abilities (in seconds)."
L["OPTIONS_ICON_SCALE"]          = "Icon Size"
L["OPTIONS_ICON_SCALE_DESC"]     = "Scale of the tracking icon when using Free Placement Mode."
L["OPTIONS_ICON_SHAPE"]          = "Icon Shape"
L["OPTIONS_ICON_SHAPE_DESC"]     = "Shape of the tracking icon border when using Free Placement Mode."
L["OPTIONS_SHAPE_CIRCLE"]        = "Circle"
L["OPTIONS_SHAPE_SQUARE"]        = "Square"
L["OPTIONS_LINKS"]               = "Feedback & Support"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_SECONDS"]             = "%.1f sec"
L["OPTIONS_PERCENT"]             = "%d%%"