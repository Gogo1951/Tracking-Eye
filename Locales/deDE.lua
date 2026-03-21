local _, te = ...
if GetLocale() ~= "deDE" then return end

local L = te.L

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "Aufspürungsmenü"
L["TRACKING_MENU_DESC"] = "Zeigt eine Liste Eurer Aufspürfähigkeiten und legt die dauerhafte Aufspürfähigkeit fest."

L["PERSISTENT_ABILITY"] = "Dauerhafte Aufspürungsfähigkeit"
L["NONE_SET"]           = "Keine gesetzt"
L["CLEAR_TRACKING"]     = "Aufspürung löschen"

L["PERSISTENT_TRACKING"] = "Dauerhafte Aufspürung"
L["PERSISTENT_DESC"]      = "Wirkt Aufspürungszauber nach Wiederbelebung automatisch erneut."

L["FARM_MODE"]    = "Farming-Modus"
L["FARMING_DESC"] = "Wechselt zwischen Kräutern und Erzen, während Ihr reitet oder in Reisegestalt seid."

L["PLACEMENT_MODE"] = "Freie Platzierung"
L["PLACEMENT_DESC"] = "Ersetzt den Minimap-Button durch ein eigenständiges Symbol, das überall hin bewegt werden kann."

L["ENABLED"]  = "Aktiviert"
L["DISABLED"] = "Deaktiviert"
L["TOGGLE"]   = "Umschalten"

L["LEFT_CLICK"]   = "Linksklick"
L["RIGHT_CLICK"]  = "Rechtsklick"
L["SHIFT_LEFT"]   = "Umschalt + Linksklick"
L["SHIFT_RIGHT"]  = "Umschalt + Rechtsklick"
L["SHIFT_MIDDLE"] = "Umschalt + Mittelklick"

L["TOOLTIP_OPTIONS_HINT"] = "Weitere Optionen sind unter Optionen > AddOns > Tracking Eye verfügbar."

-- Options Panel
L["OPTIONS_RESET"]               = "Alle Optionen zurücksetzen"
L["OPTIONS_ENABLE_PERSISTENT"]   = "Dauerhafte Aufspürung aktivieren"
L["OPTIONS_ENABLE_FARM"]         = "Farming-Modus aktivieren"
L["OPTIONS_ENABLE_FREE"]         = "Freie Platzierung aktivieren"
L["OPTIONS_FARM_ABILITIES"]      = "Farming-Modus Fähigkeiten"
L["OPTIONS_FARM_ABILITIES_DESC"] = "Wählt aus, durch welche Aufspürfähigkeiten der Farming-Modus wechseln soll, während Ihr reitet oder in Reisegestalt seid."
L["OPTIONS_CYCLE_SPEED"]         = "Wechselgeschwindigkeit"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "Wie oft der Farming-Modus zwischen Aufspürfähigkeiten wechselt (in Sekunden)."
L["OPTIONS_ICON_SCALE"]          = "Symbolgröße"
L["OPTIONS_ICON_SCALE_DESC"]     = "Skalierung des Aufspürungssymbols bei Verwendung der freien Platzierung."
L["OPTIONS_ICON_SHAPE"]          = "Symbolform"
L["OPTIONS_ICON_SHAPE_DESC"]     = "Form des Rahmens des Aufspürungssymbols bei Verwendung der freien Platzierung."
L["OPTIONS_SHAPE_CIRCLE"]        = "Kreis"
L["OPTIONS_SHAPE_SQUARE"]        = "Quadrat"
L["OPTIONS_LINKS"]               = "Feedback & Support"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_SECONDS"]             = "%.1f Sek."
L["OPTIONS_PERCENT"]             = "%d%%"