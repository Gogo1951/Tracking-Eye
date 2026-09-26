local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "deDE")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Version %s. Einstellungen (einschließlich der Option, diese Nachricht zu deaktivieren) findet Ihr unter Optionen > Addons > Tracking Eye. Gefällt Euch das Add-on? Erzählt einem Freund davon! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Aus Sicherheitsgründen kann die Optionsoberfläche im Kampf nicht geöffnet werden."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "Aufspürungsmenü"
L["TRACKING_MENU_DESCRIPTION"] = "Wählt Eure Dauerhafte Aufspürungsfähigkeit."
L["PERSISTENT_TRACKING"] = "Dauerhafte Aufspürung"
L["TARGET_TRACKING"] = "Automatische Zielaufspürung"
L["TARGET_TRACKING_DESCRIPTION"] = "Spürt die Art jeder Kreatur auf, die Ihr anvisiert."
L["FARM_MODE"] = "Farming-Modus"
L["FARM_MODE_DESCRIPTION"] = "Wechselt unterwegs zwischen Euren Aufspürungsfähigkeiten."

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
L["FARM_PAUSED_NO_ABILITIES"] = "Ihr habt keine Fähigkeiten für den Farming-Modus ausgewählt."
L["FARM_PAUSED_NOT_LEARNED"] = "Ihr beherrscht keine der Fähigkeiten, die Ihr für den Farming-Modus ausgewählt habt."
L["FARM_PAUSED_CAT_FORM"] = "Die Druiden-Aufspürung wechselt nur in Katzengestalt."
L["FARM_PAUSED_NO_STATES"] = "Es sind keine Farming-Modus-Bedingungen aktiviert."
L["FARM_PAUSED_NOT_MOUNTED"] = "Nicht beritten."
L["FARM_PAUSED_NOT_TRAVEL"] = "Nicht in einer Reisegestalt."
L["FARM_PAUSED_NOT_CHEETAH"] = "Kein Aspekt des Geparden aktiv."
L["FARM_PAUSED_NOT_PACK"] = "Kein Aspekt des Rudels aktiv."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "Nicht in Geisterwolfgestalt."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Weder beritten noch in einer Reisegestalt."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "Weder beritten noch mit Aspekt des Geparden."
L["FARM_PAUSED_NOT_MOUNTED_PACK"] = "Weder beritten noch mit Aspekt des Rudels."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "Weder beritten noch in Geisterwolfgestalt."
L["FARM_PAUSED_MOUNTED_OFF"] = "Der Farming-Modus ist nicht fürs Reiten eingestellt."
L["FARM_PAUSED_TRAVEL_OFF"] = "Der Farming-Modus ist nicht für Reisegestalten eingestellt."
L["FARM_PAUSED_CHEETAH_OFF"] = "Der Farming-Modus ist nicht für Aspekt des Geparden eingestellt."
L["FARM_PAUSED_PACK_OFF"] = "Der Farming-Modus ist nicht für Aspekt des Rudels eingestellt."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "Der Farming-Modus ist nicht für die Geisterwolfgestalt eingestellt."
L["FARM_PAUSED_COMBAT"] = "Im Kampf."
L["FARM_PAUSED_CASTING"] = "Beim Zaubern."
L["FARM_PAUSED_STEALTHED"] = "Getarnt."
L["FARM_PAUSED_LOOTING"] = "Das Beutefenster ist geöffnet."
L["FARM_PAUSED_CURSOR"] = "Ihr habt etwas am Mauszeiger."
L["FARM_PAUSED_OPTIONS"] = "Die Optionsoberfläche ist geöffnet."
L["FARM_PAUSED_WINDOW"] = "Ein Fenster ist geöffnet."
L["FARM_PAUSED_TOOLTIP"] = "Ihr lest einen Tooltip."
L["FARM_PAUSED_TARGET"] = "Ihr habt etwas im Ziel, das Ihr angreifen könnt."
L["FARM_PAUSED_STANDING_STILL"] = "Ihr steht still."

L["PERSISTENT_ABILITY"] = "Dauerhafte Aufspürungsfähigkeit"
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
	"Es sind keine Aufspürungsfähigkeiten für den Farming-Modus ausgewählt. Wählt welche unter Optionen > Addons > Tracking Eye > Farming-Modus aus."
L["BINDING_NOTHING_LEARNED"] = "Ihr beherrscht keine der Fähigkeiten, die Ihr für den Farming-Modus ausgewählt habt."
L["BINDING_NEEDS_CAT_FORM"] = "Die Druiden-Aufspürung kann nur in Katzengestalt gewirkt werden."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESCRIPTION"] =
	"Verbessertes Aufspürungsmenü und automatischer Aufspürungs-Wechsler, der beim Farmen zwischen Kräutersuche und Mineraliensuche wechselt und die Aufspürung nach dem Tod wiederherstellt. Unterstützt jede Aufspürungsfähigkeit. Verliert die Ressourcen, die Ihr jagt, nie aus den Augen."
L["OPTIONS_ENABLE_WELCOME"] = "Begrüßungsnachricht aktivieren"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] =
	"Gibt im Chat eine einzeilige Begrüßung aus, wenn Tracking Eye geladen wird."
L["OPTIONS_ENABLE_MINIMAP"] = "Minikarten-Button aktivieren"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "Auch mit ausgeblendetem Button läuft alles weiter."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet die Optionsoberfläche für dieses Add-on."

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "Tastaturbelegung"
L["OPTIONS_KEYBINDS_DESCRIPTION"] =
	"Springt mit einer Taste zur nächsten Aufspürungsfähigkeit, auch bei ausgeschaltetem Farming-Modus. Belegt die Taste im Spielmenü unter Tastaturbelegung."

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"Jede Aufspürungsfähigkeit, die Ihr beherrscht, in einem alphabetischen Menü. Was Ihr wählt, wird zu Eurer Dauerhaften Aufspürungsfähigkeit."
L["OPTIONS_HOOK_BLIZZARD"] = "Standard-Aufspürungsbutton verwenden"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"Blizzards Aufspürungsbutton öffnet dieses Menü ebenfalls. Lasst die Option aus, wenn ein anderes Add-on diesen Button bereits nutzt."

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"Verliert nie wieder Eure Aufspürung: Sie kehrt nach dem Tod, einem Gestaltwechsel oder einem Zonenwechsel sofort zurück."
L["OPTIONS_ENABLE_PERSISTENT"] = "Dauerhafte Aufspürung aktivieren"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"Wartet, bis Ihr den Kampf verlasst, und kostet Euch so nie eine globale Abklingzeit mitten im Gefecht."
L["OPTIONS_FISHING_POLE_FISH"] = "Fischsuche, wenn Ihr eine Angel anlegt"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "Eure eigene Wahl kehrt zurück, sobald Ihr die Angel wieder ablegt."
L["OPTIONS_CAT_FORM_HUMANOIDS"] = "Druide: Humanoide aufspüren beim Wechsel in Katzengestalt"
L["OPTIONS_CAT_FORM_HUMANOIDS_DESCRIPTION"] =
	"Wartet Schleichen ab, und Eure eigene Wahl kehrt zurück, sobald Ihr die Gestalt verlasst."
L["OPTIONS_BATTLEGROUND_HUMANOIDS"] = "Jäger: Humanoide aufspüren auf Schlachtfeldern"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] =
	"Arenen zählen auch, und Eure eigene Wahl kehrt zurück, sobald Ihr sie verlasst."

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"Visiert eine Kreatur an, und alle ihrer Art leuchten auf Eurer Minikarte auf. Ideal zum Questen!"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "Automatische Zielaufspürung aktivieren"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"Wechselt nie im Kampf, damit Adds Eure Aufspürung nicht kapern. Auch das Plündern einer Leiche löst keinen Wechsel aus."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Freie Platzierung"
L["OPTIONS_PLACEMENT_DESCRIPTION"] =
	"Volle Minikarte? Holt das Aufspürungssymbol herunter und parkt es an einer beliebigen Stelle Eures Bildschirms."
L["OPTIONS_ENABLE_FREE"] = "Freie Platzierung aktivieren"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"Seine Position gilt für alle Eure Charaktere und hält Neuladen und Änderungen der Interface-Skalierung stand."
L["OPTIONS_ICON_SHAPE"] = "Symbolform"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] = "Kreis passt zur Minikarte; Quadrat sitzt sauber neben Euren Aktionsleisten."
L["OPTIONS_SHAPE_CIRCLE"] = "Kreis"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrat"
L["OPTIONS_ICON_SCALE"] = "Symbolgröße"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] = "Skaliert an Ort und Stelle, sodass das Symbol seinen Platz behält."

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback & Unterstützung"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Version %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "Farming-Modus"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"Kräuter und Erz auf derselben Minikarte. Der Farming-Modus wechselt unterwegs zwischen Euren Aufspürungsfähigkeiten, damit Euch kein Vorkommen entgeht."
L["OPTIONS_ENABLE_FARM"] = "Farming-Modus aktivieren"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"Pausiert von selbst im Kampf, in Städten, in Instanzen und auf Flügen. Fahrt mit der Maus über den Tracking Eye-Button, um den Grund zu sehen."
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "Zaubergeräusche beim Aufspüren stummschalten"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"Nur die Wechsel des Farming-Modus werden stumm. Aufspürung, die Ihr selbst wählt, ist weiterhin zu hören."
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "Minikarte herauszoomen"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] =
	"Ganz herausgezoomt zeigt die Minikarte aufgespürte Vorkommen aus viel größerer Entfernung."
L["OPTIONS_FARM_CONDITIONS"] = "Farming-Modus-Bedingungen"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"Farmt, wie Ihr wollt: beritten, zu Fuß oder in der Reisegestalt Eurer Klasse. Der Farming-Modus wechselt in jedem Zustand, den Ihr ankreuzt."
L["OPTIONS_FARM_MOUNTED"] = "Beritten"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] = "Steigt an einem Vorkommen ab, und der Wechsel wartet, während Ihr sammelt."
L["OPTIONS_FARM_NOT_MOUNTED"] = "Nicht beritten"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] =
	"Haltet an, um zu sammeln oder zu essen, und der Wechsel wartet, bis Ihr weiterzieht."
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Druide: Reisegestalten"
L["OPTIONS_FARM_TRAVEL_FORMS_DESCRIPTION"] = "Wassergestalt und Fluggestalt zählen auch."
L["OPTIONS_FARM_CHEETAH"] = "Jäger: Aspekt des Geparden"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "Wechselt nur, solange Ihr in Bewegung seid, wie bei jeder anderen Bedingung."
L["OPTIONS_FARM_PACK"] = "Jäger: Aspekt des Rudels"
L["OPTIONS_FARM_PACK_DESCRIPTION"] =
	"Praktisch bei Sammelrunden in der Gruppe, wenn alle mit Gepardentempo unterwegs sind."
L["OPTIONS_FARM_GHOST_WOLF"] = "Schamane: Geisterwolf"
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "Ideal für Sammelrunden vor Eurem ersten Reittier."
L["OPTIONS_CYCLE_SPEED"] = "Wechselgeschwindigkeit"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"Jeder Wechsel kostet eine globale Abklingzeit, also kommt ein langsamerer Wechsel Euren eigenen Zaubern seltener in die Quere."
L["OPTIONS_CYCLE_EVERY"] = "Alle %s Sekunden wechseln"
L["OPTIONS_FARM_ABILITIES"] = "Farming-Modus-Fähigkeiten"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"Kreuzt an, was Ihr finden wollt. Der Farming-Modus wechselt durch jede angekreuzte Fähigkeit, die dieser Charakter beherrscht, und überspringt den Rest."
L["OPTIONS_FARM_GROUP_GENERAL"] = "Berufe & Volksfähigkeiten"
L["OPTIONS_FARM_CAT_FORM_NOTE"] = "Wechselt nur in Katzengestalt, die als Nicht beritten zählt."
L["OPTIONS_FARM_PERSISTENT"] = "Dauerhafte Aufspürungsfähigkeit einbeziehen"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"Kommt nie doppelt vor, auch wenn sie unten ebenfalls angekreuzt ist. Die Automatische Zielaufspürung setzt stattdessen die Art Eures Ziels ein."

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

L["MATCH_HERB"] = "Kräuterkunde"
L["MATCH_MINE"] = "Bergbau"

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

L["MSG_FORMAT_LOCKED"] = "Hey Schurken! %s bei %s, %s in %s."
L["MSG_FORMAT_HERB"] = "Hey Kräuterkundige! %s bei %s, %s in %s."
L["MSG_FORMAT_MINE"] = "Hey Bergleute! %s bei %s, %s in %s."

L["CHAT_TOO_LONG"] =
	"Dieser Entwurf hat %d Bytes und überschreitet das Chat-Limit von %d Bytes. Kürzt ihn vor dem Senden."

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"Ein Kraut gefunden, das Ihr nicht pflücken könnt, eine Erzader, die Ihr nicht abbauen könnt, oder eine verschlossene Schatztruhe, und kein Schurke in Sicht? Rechtsklickt darauf, und Come & Get It erstellt eine Nachricht, mit der Ihr die Koordinaten teilen oder verbreiten könnt. Ein Held zu sein war noch nie so einfach."
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "Come & Get It aktivieren"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"Bleibt im Kampf und in Instanzen still, damit Euch das Chatfenster nie mitten im Gefecht die Tastatur wegschnappt."
L["OPTIONS_OUTPUT_NAME"] = "Standardausgabe"
L["OPTIONS_OUTPUT_DESCRIPTION"] =
	"Gilde erreicht jedes Gildenmitglied, das online ist, egal auf welchem Layer oder in welcher Zone."
L["OPTIONS_OUTPUT_NOTE"] = "Hinweis: Lokal (/1) erreicht nur Spieler auf Eurem Layer."
L["OPTIONS_OUTPUT_CHANNEL1"] = "Lokal (/1)"
L["OPTIONS_OUTPUT_SAY"] = "Sagen"
L["OPTIONS_OUTPUT_YELL"] = "Schreien"
L["OPTIONS_OUTPUT_PARTY"] = "Gruppe"
L["OPTIONS_OUTPUT_GUILD"] = "Gilde"
