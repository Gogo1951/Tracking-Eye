local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "itIT")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Versione %s. Le impostazioni (inclusa l'opzione per disabilitare questo messaggio) si trovano in Opzioni > Addon > Tracking Eye. Ti piace l'addon? Parlane a un amico! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Menu Tracciamento"
L["TRACKING_MENU_DESC"] = "Visualizza un elenco delle tue abilità di tracciamento e imposta l'Abilità di Tracciamento Persistente."

L["PERSISTENT_ABILITY"] = "Abilità di Tracciamento Persistente"
L["NONE_SET"] = "Nessuno impostato"
L["CLEAR_TRACKING"] = "Cancella Tracciamento"

L["PERSISTENT_TRACKING"] = "Tracciamento Persistente"
L["PERSISTENT_DESC"] = "Rilancia automaticamente l'incantesimo di tracciamento dopo la resurrezione e il mutamento di forma."

L["FARM_MODE"] = "Modalità Raccolta"
L["FARM_MODE_DESC"] = "Cicla tra le tue abilità di tracciamento selezionate mentre sei in movimento."

L["PLACEMENT_MODE"] = "Posizionamento Libero"
L["PLACEMENT_DESC"] = "Sostituisce il pulsante della minimappa con un'icona autonoma che puoi spostare ovunque."

L["ENABLED"] = "Abilitato"
L["DISABLED"] = "Disabilitato"
L["TOGGLE"] = "Attiva/Disattiva"

L["LEFT_CLICK"] = "Clic Sinistro"
L["RIGHT_CLICK"] = "Clic Destro"
L["SHIFT_LEFT"] = "Maiusc + Clic Sinistro"
L["SHIFT_RIGHT"] = "Maiusc + Clic Destro"
L["SHIFT_MIDDLE"] = "Maiusc + Clic Centrale"

L["TOOLTIP_OPTIONS_HINT"] = "Impostazioni aggiuntive possono essere trovate in Opzioni > Addon > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] = "Menu di tracciamento migliorato e commutatore automatico che cicla tra Trova Erbe e Trova Minerali durante la raccolta e riapplica il tracciamento dopo la morte. Supporta ogni abilità di tracciamento. Non perdere mai di vista le risorse a cui dai la caccia."
L["OPTIONS_ENABLE_WELCOME"] = "Abilita Messaggio di Benvenuto"
L["OPTIONS_WELCOME_DESC"] = "Stampa un messaggio di benvenuto di una riga in chat al caricamento di Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Abilita Pulsante Minimappa"
L["OPTIONS_ENABLE_MINIMAP_DESC"] = "Mostra il pulsante di Tracking Eye sulla minimappa; la Modalità Raccolta e il Tracciamento Persistente funzionano ancora quando è nascosto."

-- Slash Commands

L["OPTIONS_COMMANDS_INTRO"] = "Comandi slash per Tracking Eye. Il pannello delle opzioni copre tutto ciò di cui hai bisogno; questi sono qui per chi preferisce la tastiera."
L["OPTIONS_COMMAND_TE"] = "Apre l'interfaccia delle opzioni di Tracking Eye."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Abilita Tracciamento Persistente"

-- Farm Mode

L["OPTIONS_ENABLE_FARM"] = "Abilita Modalità Raccolta"
L["OPTIONS_FARM_ACTIVATE"] = "Attiva Modalità Raccolta mentre:"
L["OPTIONS_FARM_MOUNTED"] = "In sella"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Forme di viaggio e volo"
L["OPTIONS_FARM_CHEETAH"] = "Aspetto del Ghepardo"
L["OPTIONS_FARM_GHOST_WOLF"] = "Lupo Spettrale"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Non in sella"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Cicla anche senza cavalcatura o forma di movimento."
L["OPTIONS_FARM_NOTE"] = "Nota: la Modalità Raccolta funziona solo mentre sei fuori dal combattimento, non stai lanciando incantesimi e sei fuori da città, locande e istanze."
L["OPTIONS_FARM_ABILITIES"] = "Abilità della Modalità Raccolta"
L["OPTIONS_CYCLE_SPEED"] = "Velocità di ciclo"
L["OPTIONS_CYCLE_SPEED_DESC"] = "Con quale frequenza la Modalità Raccolta passa tra le abilità di tracciamento (in secondi)."

-- Free Placement Mode

L["OPTIONS_ENABLE_FREE"] = "Abilita Posizionamento Libero"
L["OPTIONS_ICON_SCALE"] = "Dimensione Icona"
L["OPTIONS_ICON_SCALE_DESC"] = "Scala dell'icona di tracciamento quando si utilizza il Posizionamento Libero."
L["OPTIONS_ICON_SHAPE"] = "Forma Icona"
L["OPTIONS_ICON_SHAPE_DESC"] = "Forma del bordo dell'icona di tracciamento quando si utilizza il Posizionamento Libero."
L["OPTIONS_SHAPE_CIRCLE"] = "Cerchio"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrato"

-- Reset

L["OPTIONS_RESET_HEADER"] = "Ripristina"
L["OPTIONS_RESET_DESC"] = "Ripristina ogni impostazione di Tracking Eye al suo valore predefinito."
L["OPTIONS_RESET"] = "Ripristina tutte le opzioni"
L["OPTIONS_RESET_CONFIRM"] = "Ripristinare tutte le opzioni di Tracking Eye ai valori predefiniti?"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback e Supporto"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"