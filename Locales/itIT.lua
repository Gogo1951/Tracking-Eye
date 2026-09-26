local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "itIT")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Versione %s. Le impostazioni (inclusa l'opzione per disabilitare questo messaggio) si trovano in Opzioni > Add-on > Tracking Eye. Ti piace l'add-on? Parlane a un amico! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Per precauzione, l'Interfaccia Opzioni non può essere aperta durante il combattimento."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "Menu Tracciamento"
L["TRACKING_MENU_DESCRIPTION"] = "Scegli la tua Abilità di Tracciamento Persistente."
L["PERSISTENT_TRACKING"] = "Tracciamento Persistente"
L["TARGET_TRACKING"] = "Tracciamento Automatico del Bersaglio"
L["TARGET_TRACKING_DESCRIPTION"] = "Traccia la specie di qualsiasi creatura che bersagli."
L["FARM_MODE"] = "Modalità Raccolta"
L["FARM_MODE_DESCRIPTION"] = "Alterna le tue abilità di tracciamento mentre viaggi."

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
L["FARM_PAUSED_NO_ABILITIES"] = "Non hai selezionato nessuna abilità da alternare per la Modalità Raccolta."
L["FARM_PAUSED_NOT_LEARNED"] =
	"Non conosci nessuna delle abilità che hai selezionato da alternare per la Modalità Raccolta."
L["FARM_PAUSED_CAT_FORM"] = "Il tracciamento del druido si alterna solo in Forma Felina."
L["FARM_PAUSED_NO_STATES"] = "Nessuna delle Condizioni della Modalità Raccolta è attiva."
L["FARM_PAUSED_NOT_MOUNTED"] = "Non sei in sella."
L["FARM_PAUSED_NOT_TRAVEL"] = "Non sei in una forma di viaggio."
L["FARM_PAUSED_NOT_CHEETAH"] = "Non stai usando Aspetto del Ghepardo."
L["FARM_PAUSED_NOT_PACK"] = "Non stai usando Aspetto del Branco."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "Non sei in forma di Lupo Spettrale."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Non sei in sella né in una forma di viaggio."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "Non sei in sella né stai usando Aspetto del Ghepardo."
L["FARM_PAUSED_NOT_MOUNTED_PACK"] = "Non sei in sella né stai usando Aspetto del Branco."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "Non sei in sella né in forma di Lupo Spettrale."
L["FARM_PAUSED_MOUNTED_OFF"] = "La Modalità Raccolta non è impostata per funzionare in sella."
L["FARM_PAUSED_TRAVEL_OFF"] = "La Modalità Raccolta non è impostata per le forme di viaggio."
L["FARM_PAUSED_CHEETAH_OFF"] = "La Modalità Raccolta non è impostata per Aspetto del Ghepardo."
L["FARM_PAUSED_PACK_OFF"] = "La Modalità Raccolta non è impostata per Aspetto del Branco."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "La Modalità Raccolta non è impostata per la forma di Lupo Spettrale."
L["FARM_PAUSED_COMBAT"] = "In combattimento."
L["FARM_PAUSED_CASTING"] = "Stai lanciando un incantesimo."
L["FARM_PAUSED_STEALTHED"] = "In furtività."
L["FARM_PAUSED_LOOTING"] = "La finestra del bottino è aperta."
L["FARM_PAUSED_CURSOR"] = "Hai qualcosa sul cursore."
L["FARM_PAUSED_OPTIONS"] = "L'Interfaccia Opzioni è aperta."
L["FARM_PAUSED_WINDOW"] = "Una finestra è aperta."
L["FARM_PAUSED_TOOLTIP"] = "Stai leggendo una descrizione."
L["FARM_PAUSED_TARGET"] = "Stai bersagliando qualcosa che puoi attaccare."
L["FARM_PAUSED_STANDING_STILL"] = "Sei fermo."

L["PERSISTENT_ABILITY"] = "Abilità di Tracciamento Persistente"
L["NONE_SET"] = "Nessuna impostata"
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
	"Nessuna abilità di tracciamento è selezionata per la Modalità Raccolta. Selezionane alcune in Opzioni > Add-on > Tracking Eye > Modalità Raccolta."
L["BINDING_NOTHING_LEARNED"] =
	"Non conosci nessuna delle abilità che hai selezionato da alternare per la Modalità Raccolta."
L["BINDING_NEEDS_CAT_FORM"] = "Il tracciamento del druido si può lanciare solo in Forma Felina."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESCRIPTION"] =
	"Menu Tracciamento migliorato e commutatore automatico del tracciamento che alterna Trova Erbe e Trova Minerali durante la raccolta e riapplica il tracciamento dopo la morte. Supporta ogni abilità di tracciamento. Non perdere mai di vista le risorse a cui dai la caccia."
L["OPTIONS_ENABLE_WELCOME"] = "Abilita Messaggio di Benvenuto"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] = "Mostra in chat un saluto di una riga al caricamento di Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Abilita Pulsante Minimappa"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "Tutto continua a funzionare anche con il pulsante nascosto."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'Interfaccia Opzioni di questo add-on."

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "Assegnazione Tasti"
L["OPTIONS_KEYBINDS_DESCRIPTION"] =
	"Passa alla prossima abilità di tracciamento con un solo tasto, anche con la Modalità Raccolta disattivata. Assegnalo in Assegnazione tasti, nel menu di gioco."

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"Tutte le abilità di tracciamento che conosci, in un unico menu alfabetico. Quella che scegli diventa la tua Abilità di Tracciamento Persistente."
L["OPTIONS_HOOK_BLIZZARD"] = "Usa il Pulsante di Tracciamento Predefinito"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"Anche il pulsante di tracciamento di Blizzard apre questo menu. Lascia l'opzione disattivata se un altro add-on usa già quel pulsante."

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"Non perdere mai più il tuo tracciamento: torna subito dopo che muori, cambi forma o cambi zona."
L["OPTIONS_ENABLE_PERSISTENT"] = "Abilita Tracciamento Persistente"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"Aspetta che tu sia fuori dal combattimento, così non ti costa mai un tempo di recupero globale in piena lotta."
L["OPTIONS_FISHING_POLE_FISH"] = "Trova Pesci quando Equipaggi una Canna da Pesca"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "La tua scelta torna quando togli la canna."
L["OPTIONS_CAT_FORM_HUMANOIDS"] = "Druido: Individua Umanoidi quando Passi in Forma Felina"
L["OPTIONS_CAT_FORM_HUMANOIDS_DESCRIPTION"] =
	"Aspetta la fine di Movimento Furtivo, e la tua scelta torna quando esci dalla forma."
L["OPTIONS_BATTLEGROUND_HUMANOIDS"] = "Cacciatore: Individua Umanoidi nei Campi di Battaglia"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] = "Valgono anche le arene, e la tua scelta torna quando esci."

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"Bersaglia una creatura e tutte quelle della sua specie si illuminano sulla minimappa. Ottimo per le missioni!"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "Abilita Tracciamento Automatico del Bersaglio"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"Non cambia mai in combattimento, così i nemici che si aggiungono non ti rubano il tracciamento. Nemmeno saccheggiare un cadavere lo cambia."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Posizionamento Libero"
L["OPTIONS_PLACEMENT_DESCRIPTION"] =
	"Minimappa affollata? Stacca l'icona di tracciamento e piazzala dove vuoi sullo schermo."
L["OPTIONS_ENABLE_FREE"] = "Abilita Posizionamento Libero"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"La sua posizione è condivisa da tutti i tuoi personaggi e resta dopo i ricaricamenti e i cambi di scala dell'interfaccia."
L["OPTIONS_ICON_SHAPE"] = "Forma Icona"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] =
	"Il cerchio si abbina alla minimappa; il quadrato sta bene accanto alle barre delle azioni."
L["OPTIONS_SHAPE_CIRCLE"] = "Cerchio"
L["OPTIONS_SHAPE_SQUARE"] = "Quadrato"
L["OPTIONS_ICON_SCALE"] = "Dimensione Icona"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] = "Si ridimensiona sul posto, così l'icona mantiene la sua posizione."

-- Feedback & Support

L["OPTIONS_LINKS"] = "Feedback e Supporto"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Versione %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "Modalità Raccolta"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"Erbe e minerali sulla stessa minimappa. La Modalità Raccolta alterna le tue abilità di tracciamento mentre viaggi, così nessun nodo ti sfugge."
L["OPTIONS_ENABLE_FARM"] = "Abilita Modalità Raccolta"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"Si mette in pausa da sola in combattimento, in città, nelle istanze e durante i voli. Passa il mouse sul pulsante di Tracking Eye per sapere perché."
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "Silenzia i Suoni dei Lanci di Tracciamento"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"Solo i cambi della Modalità Raccolta diventano silenziosi. Il tracciamento che scegli tu mantiene il suo suono."
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "Riduci lo Zoom della Minimappa"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] =
	"Con lo zoom al minimo, la minimappa mostra i nodi tracciati da molto più lontano."
L["OPTIONS_FARM_CONDITIONS"] = "Condizioni della Modalità Raccolta"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"Raccogli a modo tuo: in sella, a piedi o nella forma di viaggio della tua classe. La Modalità Raccolta alterna in ogni stato che spunti."
L["OPTIONS_FARM_MOUNTED"] = "In Sella"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] = "Smonta vicino a un nodo e il ciclo aspetta mentre raccogli."
L["OPTIONS_FARM_NOT_MOUNTED"] = "Non in Sella"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] = "Fermati a raccogliere o a mangiare e il ciclo aspetta finché non riparti."
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Druido: Forme di Viaggio"
L["OPTIONS_FARM_TRAVEL_FORMS_DESCRIPTION"] = "Valgono anche Forma Acquatica e Forma di Volo."
L["OPTIONS_FARM_CHEETAH"] = "Cacciatore: Aspetto del Ghepardo"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "Alterna solo mentre ti muovi, come ogni altra condizione."
L["OPTIONS_FARM_PACK"] = "Cacciatore: Aspetto del Branco"
L["OPTIONS_FARM_PACK_DESCRIPTION"] =
	"Utile nei giri di raccolta in gruppo, quando tutto il gruppo si muove alla velocità del ghepardo."
L["OPTIONS_FARM_GHOST_WOLF"] = "Sciamano: Lupo Spettrale"
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "Ottimo per i giri di raccolta prima della tua prima cavalcatura."
L["OPTIONS_CYCLE_SPEED"] = "Velocità del Ciclo"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"Ogni cambio costa un tempo di recupero globale, quindi un ciclo più lento interferisce meno con i tuoi incantesimi."
L["OPTIONS_CYCLE_EVERY"] = "Cicla Ogni %s Secondi"
L["OPTIONS_FARM_ABILITIES"] = "Abilità della Modalità Raccolta"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"Spunta ciò che vuoi trovare. La Modalità Raccolta alterna ogni abilità spuntata che questo personaggio conosce e salta le altre."
L["OPTIONS_FARM_GROUP_GENERAL"] = "Professioni e Abilità Razziali"
L["OPTIONS_FARM_CAT_FORM_NOTE"] = "Si alterna solo in Forma Felina, che conta come Non in Sella."
L["OPTIONS_FARM_PERSISTENT"] = "Includi Abilità di Tracciamento Persistente"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"Non compare mai due volte, anche se è spuntata anche qui sotto. Il Tracciamento Automatico del Bersaglio la sostituisce con la specie del tuo bersaglio."

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

L["MATCH_HERB"] = "Erbalismo"
L["MATCH_MINE"] = "Estrazione"

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

L["MSG_FORMAT_LOCKED"] = "Ehi Ladri! %s (%s, %s) in %s."
L["MSG_FORMAT_HERB"] = "Ehi Erbalisti! %s (%s, %s) in %s."
L["MSG_FORMAT_MINE"] = "Ehi Minatori! %s (%s, %s) in %s."

L["CHAT_TOO_LONG"] =
	"Questa bozza è di %d byte e supera il limite della chat di %d byte. Accorciala prima di inviarla."

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"Hai trovato un'erba che non puoi raccogliere, una vena di minerale che non puoi estrarre o un forziere del tesoro chiuso a chiave senza un Ladro in vista? Cliccaci sopra col tasto destro e Come & Get It crea un messaggio che puoi usare per condividere o diffondere le coordinate. Essere un eroe non è mai stato così facile."
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "Abilita Come & Get It"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"Resta in silenzio in combattimento e nelle istanze, così la chat non ti ruba mai la tastiera in piena lotta."
L["OPTIONS_OUTPUT_NAME"] = "Uscita Predefinita"
L["OPTIONS_OUTPUT_DESCRIPTION"] =
	"Gilda raggiunge tutti i membri della gilda online, qualunque sia il loro layer o la loro zona."
L["OPTIONS_OUTPUT_NOTE"] = "Nota: Locale (/1) raggiunge solo i giocatori sul tuo layer."
L["OPTIONS_OUTPUT_CHANNEL1"] = "Locale (/1)"
L["OPTIONS_OUTPUT_SAY"] = "Parla"
L["OPTIONS_OUTPUT_YELL"] = "Urla"
L["OPTIONS_OUTPUT_PARTY"] = "Gruppo"
L["OPTIONS_OUTPUT_GUILD"] = "Gilda"
