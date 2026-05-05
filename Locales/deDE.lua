local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "deDE")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Version @project-version@. Tippt %s für Optionen. Gefällt Euch das AddOn? Erzählt es einem Freund! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Aufspürungsmenü"
L["TRACKING_MENU_DESC"] = "Zeigt eine Liste Eurer Aufspürfähigkeiten und legt die dauerhafte Aufspürfähigkeit fest."

L["PERSISTENT_ABILITY"] = "Dauerhafte Aufspürungsfähigkeit"
L["NONE_SET"] = "Keine gesetzt"
L["CLEAR_TRACKING"] = "Aufspürung löschen"

L["PERSISTENT_TRACKING"] = "Dauerhafte Aufspürung"
L["PERSISTENT_DESC"] = "Wirkt Aufspürungszauber nach Wiederbelebung automatisch erneut."

L["FARM_MODE"] = "Farming-Modus"
L["FARMING_DESC"] = "Wechselt zwischen Kräutern, Erzen und Schätzen, während Ihr reitet oder in Reisegestalt seid."

L["PLACEMENT_MODE"] = "Freie Platzierung"
L["PLACEMENT_DESC"] = "Ersetzt den Minimap-Button durch ein eigenständiges Symbol, das überall hin bewegt werden kann."

L["ENABLED"] = "Aktiviert"
L["DISABLED"] = "Deaktiviert"
L["TOGGLE"] = "Umschalten"

L["LEFT_CLICK"] = "Linksklick"
L["RIGHT_CLICK"] = "Rechtsklick"
L["SHIFT_LEFT"] = "Umschalt + Linksklick"
L["SHIFT_RIGHT"] = "Umschalt + Rechtsklick"
L["SHIFT_MIDDLE"] = "Umschalt + Mittelklick"

L["TOOLTIP_OPTIONS_HINT"] = "Zusätzliche Einstellungen finden Sie unter Optionen > AddOns > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] = "Ein intelligentes Aufspürungsmenü, das Kräuter- und Erzsuche während des Reitens automatisch wechselt und eure Aufspürfähigkeit nach dem Tod wiederherstellt."
L["OPTIONS_COMMANDS_INTRO"] = "Slash-Befehle für Tracking Eye. Das Optionsfenster deckt alles ab, was du brauchst; diese hier sind für diejenigen, die lieber die Tastatur benutzen."
L["OPTIONS_COMMAND_TE"] = "Öffnet die Benutzeroberfläche für Tracking Eye-Optionen."
L["OPTIONS_GENERAL_SETTINGS"] = "Allgemeine Einstellungen"
L["OPTIONS_WELCOME_DESC"] = "Gibt eine einzeilige Begrüßung im Chat aus, wenn Tracking Eye geladen wird."
L["OPTIONS_RESET"] = "Alle Optionen zurücksetzen"
L["OPTIONS_RESET_HEADER"] = "Zurücksetzen"
L["OPTIONS_RESET_CONFIRM"] = "Alle Optionen von Tracking Eye auf Standard zurücksetzen?"
L["OPTIONS_ENABLE_PERSISTENT"] = "Dauerhafte Aufspürung aktivieren"
L["OPTIONS_ENABLE_FARM"] = "Farming-Modus aktivieren"
L["OPTIONS_ENABLE_FREE"] = "Freie Platzierung aktivieren"
L["OPTIONS_ENABLE_WELCOME"] = "Begrüßungsnachricht aktivieren"
L["OPTIONS_FARM_ABILITIES"] = "Farming-Modus Fähigkeiten"
L["OPTIONS_FARM_ABILITIES_DESC"] = "Wählt aus, durch welche Aufspürfähigkeiten der Farming-Modus wechseln soll, während Ihr reitet oder in Reisegestalt seid."
L["OPTIONS_CYCLE_SPEED"] = "Wechselgeschwindigkeit"
L["OPTIONS_CYCLE_SPEED_DESC"] = "Wie oft der Farming-Modus zwischen Aufspürfähigkeiten wechselt (in Sekunden)."
L["OPTIONS_ICON_SCALE"] = "Symbolgröße"
L["OPTIONS_ICON_SCALE_DESC"] = "Skalierung des Aufspürungssymbols bei Verwendung der freien Platzierung."
L["OPTIONS_ICON_SHAPE"] = "Symbolform"
L["OPTIONS_ICON_SHAPE_DESC"] = "Form des Rahmens des Aufspürungssymbols bei Verwendung der freien Platzierung."
L["OPTIONS_SHAPE_CIRCLE"] = "Kreis"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrat"
L["OPTIONS_LINKS"] = "Feedback & Support"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_SECONDS"] = "%.1f Sek."
L["OPTIONS_PERCENT"] = "%d%%"