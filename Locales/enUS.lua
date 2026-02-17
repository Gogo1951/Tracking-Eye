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

L["FARMING_MODE"] = "Farming Mode"
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