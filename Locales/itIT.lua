local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "itIT")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Versione %s. Le impostazioni (inclusa l'opzione per disabilitare questo messaggio) si trovano in Opzioni > Addon > Tracking Eye. Ti piace l'addon? Parlane a un amico! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Per precauzione, l'Interfaccia Opzioni non può essere aperta durante il combattimento."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Menu Tracciamento"
L["TRACKING_MENU_DESC"] =
	"Elenca le tue abilità di tracciamento e ti permette di impostare la tua Abilità di Tracciamento Persistente."
L["PERSISTENT_TRACKING"] = "Tracciamento Persistente"
L["PERSISTENT_DESC"] =
	"Rilancia automaticamente la tua abilità di tracciamento dopo la resurrezione e il mutamento di forma."
L["FARM_MODE"] = "Modalità Raccolta"
L["FARM_MODE_DESC"] = "Cicla tra le tue abilità di tracciamento selezionate mentre sei in movimento."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "Stato della Modalità Raccolta"
L["FARM_STATUS_ACTIVE"] = "Attiva"
L["FARM_STATUS_PAUSED"] = "In pausa"

L["FARM_PAUSED_DEAD"] = "Sei morto."
L["FARM_PAUSED_TAXI"] = "Su una rotta di volo."
L["FARM_PAUSED_INSTANCE"] = "All'interno di un'istanza."
L["FARM_PAUSED_RESTING"] = "In una città o locanda."
L["FARM_PAUSED_NO_ABILITIES"] = "Nessuna abilità di tracciamento selezionata."
L["FARM_PAUSED_NO_STATES"] = "Nessuna condizione della Modalità Raccolta è attiva."
L["FARM_PAUSED_NOT_MOUNTED"] = "Non sei in sella."
L["FARM_PAUSED_NOT_TRAVEL"] = "Non sei in Forma da Viaggio."
L["FARM_PAUSED_NOT_CHEETAH"] = "Non stai usando Aspetto del Ghepardo."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "Non stai usando Lupo Spettrale."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Non sei in sella né in Forma da Viaggio."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "Non sei in sella né stai usando Aspetto del Ghepardo."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "Non sei in sella né stai usando Lupo Spettrale."
L["FARM_PAUSED_MOUNTED_OFF"] = "La Modalità Raccolta non è impostata per funzionare mentre sei in sella."
L["FARM_PAUSED_TRAVEL_OFF"] = "La Modalità Raccolta non è impostata per funzionare in Forma da Viaggio."
L["FARM_PAUSED_CHEETAH_OFF"] = "La Modalità Raccolta non è impostata per funzionare con Aspetto del Ghepardo."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "La Modalità Raccolta non è impostata per funzionare con Lupo Spettrale."
L["FARM_PAUSED_COMBAT"] = "In combattimento."
L["FARM_PAUSED_CASTING"] = "Stai lanciando un incantesimo."
L["FARM_PAUSED_STEALTHED"] = "In furtività."
L["FARM_PAUSED_LOOTING"] = "La finestra del bottino è aperta."
L["FARM_PAUSED_CURSOR"] = "Hai qualcosa sul cursore."
L["FARM_PAUSED_OPTIONS"] = "L'Interfaccia Opzioni è aperta."
L["FARM_PAUSED_WINDOW"] = "Una finestra è aperta."
L["FARM_PAUSED_TOOLTIP"] = "Stai leggendo una descrizione."

L["PERSISTENT_ABILITY"] = "Abilità di Tracciamento Persistente"
L["SILENCE_TRACKING_SOUNDS"] = "Silenzia i Suoni di Tracciamento"
L["NONE_SET"] = "Nessuno impostato"
L["CLEAR_TRACKING"] = "Cancella Tracciamento"

L["ENABLED"] = "Abilitato"
L["DISABLED"] = "Disabilitato"
L["TOGGLE"] = "Attiva/Disattiva"

L["OPEN"] = "Apri"
L["LEFT_CLICK"] = "Clic Sinistro"
L["RIGHT_CLICK"] = "Clic Destro"
L["SHIFT_LEFT"] = "Maiusc + Clic Sinistro"
L["SHIFT_RIGHT"] = "Maiusc + Clic Destro"
L["SHIFT_MIDDLE"] = "Maiusc + Clic Centrale"

L["TOOLTIP_OPTIONS"] = "Opzioni di Tracking Eye"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "Cicla Abilità della Modalità Raccolta"
L["BINDING_NOTHING_TO_CYCLE"] =
	"Nessuna abilità di tracciamento è selezionata per la Modalità Raccolta. Selezionane alcune in Opzioni > Addon > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"Menu di tracciamento migliorato e commutatore automatico che cicla tra Trova Erbe e Trova Minerali durante la raccolta e riapplica il tracciamento dopo la morte. Supporta ogni abilità di tracciamento. Non perdere mai di vista le risorse a cui dai la caccia."
L["OPTIONS_ENABLE_WELCOME"] = "Abilita Messaggio di Benvenuto"
L["OPTIONS_WELCOME_DESC"] = "Stampa un messaggio di benvenuto di una riga in chat al caricamento di Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Abilita Pulsante Minimappa"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"Mostra il pulsante di Tracking Eye sulla minimappa; la Modalità Raccolta e il Tracciamento Persistente funzionano ancora quando è nascosto."
L["OPTIONS_HOOK_BLIZZARD"] = "Usa il Pulsante di Tracciamento Predefinito"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"Mentre questa opzione è attiva, l'icona di tracciamento di Blizzard apre il menu di Tracking Eye, che cambia soltanto ciò che stai tracciando. Tutto il resto resta qui, nell'Interfaccia Opzioni."
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"Apre il Menu Tracciamento quando fai clic sull'icona di tracciamento di Blizzard sulla minimappa. Lascia questa opzione disattivata se un altro addon usa già quel pulsante."
L["OPTIONS_KEYBINDS"] = "Assegnazione Tasti"
L["OPTIONS_KEYBINDS_DESC"] =
	"Fa avanzare la Modalità Raccolta alla sua abilità successiva su richiesta. Impostala in Assegnazione Tasti nel menu di gioco, nella sezione Tracking Eye."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Comando slash per Tracking Eye. L'Interfaccia Opzioni copre tutto ciò di cui hai bisogno; questo è qui per chi preferisce la tastiera."
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'Interfaccia Opzioni di questo addon."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Abilita Tracciamento Persistente"
L["OPTIONS_TARGET_TRACKING"] = "Tracciamento Automatico del Bersaglio"
L["OPTIONS_TARGET_TRACKING_DESC"] = "Traccia ciò che bersagli, così il resto della sua specie appare sulla minimappa."
L["OPTIONS_TARGET_TRACKING_QUESTING"] = "Nota: il Tracciamento Automatico del Bersaglio è ottimo per le missioni!"

-- Farm Mode

L["TAB_FARM_MODE"] = "Modalità Raccolta"
L["OPTIONS_ENABLE_FARM"] = "Abilita Modalità Raccolta"
L["OPTIONS_FARM_CONDITIONS"] = "Condizioni della Modalità Raccolta"
L["OPTIONS_FARM_MOUNTED"] = "In sella"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Forme di viaggio e volo"
L["OPTIONS_FARM_CHEETAH"] = "Aspetto del Ghepardo"
L["OPTIONS_FARM_GHOST_WOLF"] = "Lupo Spettrale"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Non in sella"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Cicla anche senza cavalcatura o forma di movimento."
L["OPTIONS_FARM_NOTE"] =
	"Nota: la Modalità Raccolta funziona solo mentre sei fuori dal combattimento, non stai lanciando incantesimi e sei fuori da città, locande, istanze e rotte di volo."
L["OPTIONS_FARM_ABILITIES"] = "Abilità della Modalità Raccolta"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"Include la tua Abilità di Tracciamento Persistente nella rotazione. Se è già selezionata qui sotto, compare comunque una sola volta."
L["OPTIONS_CYCLE_EVERY"] = "Cicla ogni %s secondi"
L["OPTIONS_CYCLE_EVERY_DESC"] =
	"Con quale frequenza la Modalità Raccolta passa tra le abilità di tracciamento (in secondi)."
L["SILENCE_TRACKING_SOUNDS_DESC"] =
	"Silenzia il suono di lancio mentre la Modalità Raccolta cicla. I tuoi incantesimi non sono influenzati."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Posizionamento Libero"
L["PLACEMENT_DESC"] = "Sostituisce il pulsante della minimappa con un'icona autonoma che puoi spostare ovunque."
L["OPTIONS_ENABLE_FREE"] = "Abilita Posizionamento Libero"
L["OPTIONS_ICON_SCALE"] = "Dimensione Icona"
L["OPTIONS_ICON_SCALE_DESC"] = "Dimensione dell'icona di tracciamento quando si utilizza il Posizionamento Libero."
L["OPTIONS_ICON_SHAPE"] = "Forma Icona"
L["OPTIONS_ICON_SHAPE_DESC"] = "Forma del bordo dell'icona di tracciamento quando si utilizza il Posizionamento Libero."
L["OPTIONS_SHAPE_CIRCLE"] = "Cerchio"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrato"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback e Supporto"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
