local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "deDE")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Version %s. Einstellungen (einschließlich der Option, diese Nachricht zu deaktivieren) finden Sie unter Optionen > AddOns > Tracking Eye. Gefällt Euch das AddOn? Erzählt es einem Freund! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Aufspürungsmenü"
L["TRACKING_MENU_DESC"] = "Zeigt eine Liste Eurer Aufspürfähigkeiten und legt die dauerhafte Aufspürfähigkeit fest."

L["PERSISTENT_ABILITY"] = "Dauerhafte Aufspürungsfähigkeit"
L["NONE_SET"] = "Keine gesetzt"
L["CLEAR_TRACKING"] = "Aufspürung löschen"

L["PERSISTENT_TRACKING"] = "Dauerhafte Aufspürung"
L["PERSISTENT_DESC"] = "Wirkt Euren Aufspürungszauber nach Wiederbelebung und Gestaltwandel automatisch erneut."

L["FARM_MODE"] = "Farming-Modus"
L["FARM_MODE_DESC"] = "Wechselt zwischen Euren ausgewählten Aufspürfähigkeiten, während Ihr in Bewegung seid."

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

-- General

L["OPTIONS_DESC"] = "Verbessertes Aufspürungsmenü und automatischer Aufspürungs-Wechsler, der während des Farmens zwischen Kräuter- und Erzsuche wechselt und die Aufspürung nach dem Tod wiederherstellt. Unterstützt jede Aufspürfähigkeit. Verliert nie die Ressourcen aus den Augen, die Ihr jagt."
L["OPTIONS_ENABLE_WELCOME"] = "Begrüßungsnachricht aktivieren"
L["OPTIONS_WELCOME_DESC"] = "Gibt eine einzeilige Begrüßung im Chat aus, wenn Tracking Eye geladen wird."
L["OPTIONS_ENABLE_MINIMAP"] = "Minimap-Button aktivieren"
L["OPTIONS_ENABLE_MINIMAP_DESC"] = "Zeigt den Tracking Eye-Button an der Minimap; Farming-Modus und Dauerhafte Aufspürung laufen weiterhin, wenn er versteckt ist."

-- Slash Commands

L["OPTIONS_COMMANDS_INTRO"] = "Slash-Befehle für Tracking Eye. Das Optionsfenster deckt alles ab, was du brauchst; diese hier sind für diejenigen, die lieber die Tastatur benutzen."
L["OPTIONS_COMMAND_TE"] = "Öffnet die Benutzeroberfläche für Tracking Eye-Optionen."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Dauerhafte Aufspürung aktivieren"

-- Farm Mode

L["OPTIONS_ENABLE_FARM"] = "Farming-Modus aktivieren"
L["OPTIONS_FARM_ACTIVATE"] = "Farming-Modus aktivieren während:"
L["OPTIONS_FARM_MOUNTED"] = "Reitend"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Reise- & Fluggestalten"
L["OPTIONS_FARM_CHEETAH"] = "Aspekt des Geparden"
L["OPTIONS_FARM_GHOST_WOLF"] = "Geisterwolf"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Nicht reitend"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Wechselt auch ohne Reittier oder Bewegungsgestalt."
L["OPTIONS_FARM_NOTE"] = "Hinweis: Der Farming-Modus läuft nur, wenn Ihr Euch außerhalb des Kampfes befindet, nicht zaubert und außerhalb von Städten, Gasthäusern und Instanzen seid."
L["OPTIONS_FARM_ABILITIES"] = "Farming-Modus Fähigkeiten"
L["OPTIONS_CYCLE_SPEED"] = "Wechselgeschwindigkeit"
L["OPTIONS_CYCLE_SPEED_DESC"] = "Wie oft der Farming-Modus zwischen Aufspürfähigkeiten wechselt (in Sekunden)."

-- Free Placement Mode

L["OPTIONS_ENABLE_FREE"] = "Freie Platzierung aktivieren"
L["OPTIONS_ICON_SCALE"] = "Symbolgröße"
L["OPTIONS_ICON_SCALE_DESC"] = "Skalierung des Aufspürungssymbols bei Verwendung der freien Platzierung."
L["OPTIONS_ICON_SHAPE"] = "Symbolform"
L["OPTIONS_ICON_SHAPE_DESC"] = "Form des Rahmens des Aufspürungssymbols bei Verwendung der freien Platzierung."
L["OPTIONS_SHAPE_CIRCLE"] = "Kreis"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrat"

-- Reset

L["OPTIONS_RESET_HEADER"] = "Zurücksetzen"
L["OPTIONS_RESET_DESC"] = "Jede Einstellung von Tracking Eye auf den Standardwert zurücksetzen."
L["OPTIONS_RESET"] = "Alle Optionen von Tracking Eye zurücksetzen"
L["OPTIONS_RESET_CONFIRM"] = "Alle Optionen von Tracking Eye auf Standard zurücksetzen?"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback & Support"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"