local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "deDE")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Einstellungen (einschließlich der Option, diese Nachricht zu deaktivieren) findet Ihr unter Optionen > AddOns > Tracking Eye. Gefällt Euch das AddOn? Erzählt es einem Freund! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Aus Sicherheitsgründen kann die Optionsoberfläche im Kampf nicht geöffnet werden."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Aufspürungsmenü"
L["TRACKING_MENU_DESC"] =
	"Listet Eure Aufspürfähigkeiten auf und lässt Euch Eure Dauerhafte Aufspürungsfähigkeit festlegen."
L["PERSISTENT_TRACKING"] = "Dauerhafte Aufspürung"
L["PERSISTENT_DESC"] = "Wirkt Eure Aufspürfähigkeit nach Wiederbelebung und Gestaltwandel automatisch erneut."
L["FARM_MODE"] = "Farming-Modus"
L["FARM_MODE_DESC"] = "Wechselt zwischen Euren ausgewählten Aufspürfähigkeiten, während Ihr in Bewegung seid."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "Farming-Modus-Status"
L["FARM_STATUS_ACTIVE"] = "Aktiv"
L["FARM_STATUS_PAUSED"] = "Pausiert"

L["FARM_PAUSED_DEAD"] = "Ihr seid tot."
L["FARM_PAUSED_TAXI"] = "Auf einer Flugroute."
L["FARM_PAUSED_INSTANCE"] = "In einer Instanz."
L["FARM_PAUSED_RESTING"] = "In einer Stadt oder einem Gasthaus."
L["FARM_PAUSED_NO_ABILITIES"] = "Keine Aufspürfähigkeiten ausgewählt."
L["FARM_PAUSED_NO_STATES"] = "Keine Farming-Modus-Bedingungen sind aktiviert."
L["FARM_PAUSED_NOT_MOUNTED"] = "Nicht reitend."
L["FARM_PAUSED_NOT_TRAVEL"] = "Nicht in Reisegestalt."
L["FARM_PAUSED_NOT_CHEETAH"] = "Kein Aspekt des Geparden aktiv."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "Kein Geisterwolf aktiv."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Nicht reitend, nicht in Reisegestalt."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "Nicht reitend, kein Aspekt des Geparden aktiv."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "Nicht reitend, kein Geisterwolf aktiv."
L["FARM_PAUSED_MOUNTED_OFF"] = "Der Farming-Modus ist nicht für den Einsatz beim Reiten eingestellt."
L["FARM_PAUSED_TRAVEL_OFF"] = "Der Farming-Modus ist nicht für den Einsatz in Reisegestalt eingestellt."
L["FARM_PAUSED_CHEETAH_OFF"] = "Der Farming-Modus ist nicht für den Einsatz unter Aspekt des Geparden eingestellt."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "Der Farming-Modus ist nicht für den Einsatz unter Geisterwolf eingestellt."
L["FARM_PAUSED_COMBAT"] = "Im Kampf."
L["FARM_PAUSED_CASTING"] = "Beim Zaubern."
L["FARM_PAUSED_STEALTHED"] = "Verstohlen."
L["FARM_PAUSED_LOOTING"] = "Das Beutefenster ist geöffnet."
L["FARM_PAUSED_CURSOR"] = "Ihr habt etwas am Mauszeiger."
L["FARM_PAUSED_OPTIONS"] = "Die Optionsoberfläche ist geöffnet."
L["FARM_PAUSED_WINDOW"] = "Ein Fenster ist geöffnet."
L["FARM_PAUSED_TOOLTIP"] = "Ihr lest einen Tooltip."

L["PERSISTENT_ABILITY"] = "Dauerhafte Aufspürungsfähigkeit"
L["SILENCE_TRACKING_SOUNDS"] = "Aufspürungsgeräusche stummschalten"
L["NONE_SET"] = "Keine gesetzt"
L["CLEAR_TRACKING"] = "Aufspürung löschen"

L["ENABLED"] = "Aktiviert"
L["DISABLED"] = "Deaktiviert"
L["TOGGLE"] = "Umschalten"

L["OPEN"] = "Öffnen"
L["LEFT_CLICK"] = "Linksklick"
L["RIGHT_CLICK"] = "Rechtsklick"
L["SHIFT_LEFT"] = "Umschalt + Linksklick"
L["SHIFT_RIGHT"] = "Umschalt + Rechtsklick"
L["SHIFT_MIDDLE"] = "Umschalt + Mittelklick"

L["TOOLTIP_OPTIONS"] = "Tracking Eye-Optionen"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "Farming-Modus-Fähigkeit wechseln"
L["BINDING_NOTHING_TO_CYCLE"] =
	"Es sind keine Aufspürfähigkeiten für den Farming-Modus ausgewählt. Wählt welche unter Optionen > AddOns > Tracking Eye aus."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"Verbessertes Aufspürungsmenü und automatischer Aufspürungs-Wechsler, der während des Farmens zwischen Kräuter- und Erzsuche wechselt und die Aufspürung nach dem Tod wiederherstellt. Unterstützt jede Aufspürfähigkeit. Verliert nie die Ressourcen aus den Augen, die Ihr jagt."
L["OPTIONS_ENABLE_WELCOME"] = "Begrüßungsnachricht aktivieren"
L["OPTIONS_WELCOME_DESC"] = "Gibt eine einzeilige Begrüßung im Chat aus, wenn Tracking Eye geladen wird."
L["OPTIONS_ENABLE_MINIMAP"] = "Minimap-Button aktivieren"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"Zeigt den Tracking Eye-Button an der Minimap; Farming-Modus und Dauerhafte Aufspürung laufen weiterhin, wenn er versteckt ist."
L["OPTIONS_HOOK_BLIZZARD"] = "Standard-Aufspürungsbutton verwenden"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"Während dies aktiviert ist, öffnet das Aufspürungssymbol von Blizzard das Tracking Eye-Menü, welches nur ändert, was Ihr aufspürt. Alles Weitere bleibt hier in der Optionsoberfläche."
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"Öffnet das Aufspürungsmenü, wenn Ihr auf das Aufspürungssymbol von Blizzard an der Minimap klickt. Lasst dies deaktiviert, wenn ein anderes AddOn diesen Button bereits verwendet."
L["OPTIONS_KEYBINDS"] = "Tastenbelegungen"
L["OPTIONS_KEYBINDS_DESC"] =
	"Schaltet den Farming-Modus auf Befehl zur nächsten Fähigkeit weiter. Legt sie unter Tastenbelegung im Spielmenü im Bereich Tracking Eye fest."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Slash-Befehl für Tracking Eye. Die Optionsoberfläche deckt alles ab, was Ihr braucht; dieser hier ist für diejenigen, die lieber die Tastatur benutzen."
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet die Optionsoberfläche für dieses AddOn."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Dauerhafte Aufspürung aktivieren"
L["OPTIONS_TARGET_TRACKING"] = "Automatische Zielaufspürung"
L["OPTIONS_TARGET_TRACKING_DESC"] =
	"Spürt auf, was Ihr anvisiert, sodass der Rest seiner Art auf Eurer Minimap erscheint."
L["OPTIONS_TARGET_TRACKING_QUESTING"] =
	"Hinweis: Die automatische Zielaufspürung eignet sich hervorragend für Quests!"

-- Farm Mode

L["TAB_FARM_MODE"] = "Farming-Modus"
L["OPTIONS_ENABLE_FARM"] = "Farming-Modus aktivieren"
L["OPTIONS_FARM_CONDITIONS"] = "Farming-Modus-Bedingungen"
L["OPTIONS_FARM_MOUNTED"] = "Reitend"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Reise- & Fluggestalten"
L["OPTIONS_FARM_CHEETAH"] = "Aspekt des Geparden"
L["OPTIONS_FARM_GHOST_WOLF"] = "Geisterwolf"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Nicht reitend"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Wechselt auch ohne Reittier oder Bewegungsgestalt."
L["OPTIONS_FARM_NOTE"] =
	"Hinweis: Der Farming-Modus läuft nur, wenn Ihr Euch außerhalb des Kampfes befindet, nicht zaubert und außerhalb von Städten, Gasthäusern, Instanzen und Flugrouten seid."
L["OPTIONS_FARM_ABILITIES"] = "Farming-Modus-Fähigkeiten"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"Nimmt Eure Dauerhafte Aufspürungsfähigkeit in die Rotation auf. Ist sie unten bereits angehakt, kommt sie trotzdem nur einmal vor."
L["OPTIONS_CYCLE_EVERY"] = "Alle %s Sekunden wechseln"
L["OPTIONS_CYCLE_EVERY_DESC"] = "Wie oft der Farming-Modus zwischen Aufspürfähigkeiten wechselt (in Sekunden)."
L["SILENCE_TRACKING_SOUNDS_DESC"] =
	"Schaltet das Zaubergeräusch stumm, während der Farming-Modus wechselt. Eure eigenen Zauber sind nicht betroffen."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Freie Platzierung"
L["PLACEMENT_DESC"] =
	"Ersetzt den Minimap-Button durch ein eigenständiges Symbol, das überall hin bewegt werden kann."
L["OPTIONS_ENABLE_FREE"] = "Freie Platzierung aktivieren"
L["OPTIONS_ICON_SCALE"] = "Symbolgröße"
L["OPTIONS_ICON_SCALE_DESC"] = "Größe des Aufspürungssymbols bei Verwendung der freien Platzierung."
L["OPTIONS_ICON_SHAPE"] = "Symbolform"
L["OPTIONS_ICON_SHAPE_DESC"] = "Form des Rahmens des Aufspürungssymbols bei Verwendung der freien Platzierung."
L["OPTIONS_SHAPE_CIRCLE"] = "Kreis"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrat"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback & Unterstützung"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
