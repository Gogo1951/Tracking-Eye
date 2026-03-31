local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "itIT")
if not L then return end

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "Menu Tracciamento"
L["TRACKING_MENU_DESC"] = "Visualizza un elenco delle tue abilità di tracciamento e imposta l'Abilità di Tracciamento Persistente."

L["PERSISTENT_ABILITY"] = "Abilità di Tracciamento Persistente"
L["NONE_SET"]           = "Nessuno impostato"
L["CLEAR_TRACKING"]     = "Cancella Tracciamento"

L["PERSISTENT_TRACKING"] = "Tracciamento Persistente"
L["PERSISTENT_DESC"]      = "Rilancia automaticamente l'incantesimo di tracciamento dopo la resurrezione."

L["FARM_MODE"]    = "Modalità Raccolta"
L["FARMING_DESC"] = "Cicla tra Erbe, Minerali e Tesori mentre sei a cavallo o in forma di viaggio."

L["PLACEMENT_MODE"] = "Posizionamento Libero"
L["PLACEMENT_DESC"] = "Sostituisce il pulsante della minimappa con un'icona autonoma che puoi spostare ovunque."

L["ENABLED"]  = "Abilitato"
L["DISABLED"] = "Disabilitato"
L["TOGGLE"]   = "Attiva/Disattiva"

L["LEFT_CLICK"]   = "Clic Sinistro"
L["RIGHT_CLICK"]  = "Clic Destro"
L["SHIFT_LEFT"]   = "Maiusc + Clic Sinistro"
L["SHIFT_RIGHT"]  = "Maiusc + Clic Destro"
L["SHIFT_MIDDLE"] = "Maiusc + Clic Centrale"

L["TOOLTIP_OPTIONS_HINT"] = "Impostazioni aggiuntive possono essere trovate in Opzioni > Addon > Tracking Eye."

-- Options Panel
L["OPTIONS_DESC"]                = "Un menu di tracciamento intelligente che cicla automaticamente tra erbe e minerali in sella, e ripristina la tua abilità di tracciamento dopo la morte."
L["OPTIONS_RESET"]               = "Ripristina tutte le opzioni"
L["OPTIONS_RESET_HEADER"]        = "Ripristina"
L["OPTIONS_RESET_CONFIRM"]       = "Ripristinare tutte le opzioni di Tracking Eye ai valori predefiniti?"
L["OPTIONS_ENABLE_PERSISTENT"]   = "Abilita Tracciamento Persistente"
L["OPTIONS_ENABLE_FARM"]         = "Abilita Modalità Raccolta"
L["OPTIONS_ENABLE_FREE"]         = "Abilita Posizionamento Libero"
L["OPTIONS_FARM_ABILITIES"]      = "Abilità della Modalità Raccolta"
L["OPTIONS_FARM_ABILITIES_DESC"] = "Seleziona quali abilità di tracciamento cicleranno nella Modalità Raccolta mentre sei a cavallo o in forma di viaggio."
L["OPTIONS_CYCLE_SPEED"]         = "Velocità di ciclo"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "Con quale frequenza la Modalità Raccolta passa tra le abilità di tracciamento (in secondi)."
L["OPTIONS_ICON_SCALE"]          = "Dimensione Icona"
L["OPTIONS_ICON_SCALE_DESC"]     = "Scala dell'icona di tracciamento quando si utilizza il Posizionamento Libero."
L["OPTIONS_ICON_SHAPE"]          = "Forma Icona"
L["OPTIONS_ICON_SHAPE_DESC"]     = "Forma del bordo dell'icona di tracciamento quando si utilizza il Posizionamento Libero."
L["OPTIONS_SHAPE_CIRCLE"]        = "Cerchio"
L["OPTIONS_SHAPE_SQUARE"]        = "Quadrato"
L["OPTIONS_LINKS"]               = "Feedback e Supporto"
L["OPTIONS_CURSEFORGE"]          = "CurseForge"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_SECONDS"]             = "%.1f sec"
L["OPTIONS_PERCENT"]             = "%d%%"