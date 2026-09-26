local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "esES")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Versión %s. Los ajustes (incluyendo la opción de desactivar este mensaje) se pueden encontrar en Opciones > Addons > Tracking Eye. ¿Te gusta el complemento? ¡Cuéntaselo a un amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Como medida de seguridad, la Interfaz de Opciones no se puede abrir durante el combate."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "Menú de rastreo"
L["TRACKING_MENU_DESCRIPTION"] = "Elige tu Habilidad de rastreo persistente."
L["PERSISTENT_TRACKING"] = "Rastreo persistente"
L["TARGET_TRACKING"] = "Rastreo automático de objetivo"
L["TARGET_TRACKING_DESCRIPTION"] = "Rastrea la especie de cualquier criatura que tengas como objetivo."
L["FARM_MODE"] = "Modo de recolección"
L["FARM_MODE_DESCRIPTION"] = "Alterna tus habilidades de rastreo mientras viajas."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "Estado del Modo de recolección"
L["FARM_STATUS_ACTIVE"] = "Activo"
L["FARM_STATUS_PAUSED"] = "En pausa"

L["FARM_PAUSED_DEAD"] = "Estás muerto."
L["FARM_PAUSED_TAXI"] = "En una ruta de vuelo."
L["FARM_PAUSED_INSTANCE"] = "Dentro de una estancia."
L["FARM_PAUSED_RESTING"] = "En una ciudad o posada."
L["FARM_PAUSED_NO_ABILITIES"] = "No has seleccionado ninguna habilidad para alternar en el Modo de recolección."
L["FARM_PAUSED_NOT_LEARNED"] =
	"No conoces ninguna de las habilidades que has seleccionado para alternar en el Modo de recolección."
L["FARM_PAUSED_CAT_FORM"] = "El rastreo de druida solo alterna en Forma felina."
L["FARM_PAUSED_NO_STATES"] = "Ninguna de las Condiciones del Modo de recolección está activada."
L["FARM_PAUSED_NOT_MOUNTED"] = "No estás montado."
L["FARM_PAUSED_NOT_TRAVEL"] = "No estás en una forma de viaje."
L["FARM_PAUSED_NOT_CHEETAH"] = "No estás usando Aspecto del guepardo."
L["FARM_PAUSED_NOT_PACK"] = "No estás usando Aspecto de la manada."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "No estás en forma de Lobo fantasmal."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "No estás montado ni en una forma de viaje."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "No estás montado ni usando Aspecto del guepardo."
L["FARM_PAUSED_NOT_MOUNTED_PACK"] = "No estás montado ni usando Aspecto de la manada."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "No estás montado ni en forma de Lobo fantasmal."
L["FARM_PAUSED_MOUNTED_OFF"] = "El Modo de recolección no está configurado para ir montado."
L["FARM_PAUSED_TRAVEL_OFF"] = "El Modo de recolección no está configurado para formas de viaje."
L["FARM_PAUSED_CHEETAH_OFF"] = "El Modo de recolección no está configurado para Aspecto del guepardo."
L["FARM_PAUSED_PACK_OFF"] = "El Modo de recolección no está configurado para Aspecto de la manada."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "El Modo de recolección no está configurado para la forma de Lobo fantasmal."
L["FARM_PAUSED_COMBAT"] = "En combate."
L["FARM_PAUSED_CASTING"] = "Lanzando un hechizo."
L["FARM_PAUSED_STEALTHED"] = "En sigilo."
L["FARM_PAUSED_LOOTING"] = "La ventana de botín está abierta."
L["FARM_PAUSED_CURSOR"] = "Tienes algo en el cursor."
L["FARM_PAUSED_OPTIONS"] = "La Interfaz de Opciones está abierta."
L["FARM_PAUSED_WINDOW"] = "Hay una ventana abierta."
L["FARM_PAUSED_TOOLTIP"] = "Estás leyendo una descripción."
L["FARM_PAUSED_TARGET"] = "Tienes como objetivo algo que puedes atacar."
L["FARM_PAUSED_STANDING_STILL"] = "Estás quieto."

L["PERSISTENT_ABILITY"] = "Habilidad de rastreo persistente"
L["NONE_SET"] = "Sin establecer"
L["CLEAR_TRACKING"] = "Borrar rastreo"

L["ENABLED"] = "Habilitado"
L["DISABLED"] = "Deshabilitado"
L["TOGGLE"] = "Alternar"

L["OPEN"] = "Abrir"
L["LEFT_CLICK"] = "Clic izquierdo"
L["RIGHT_CLICK"] = "Clic derecho"
L["SHIFT_LEFT"] = "Mayús + Clic izquierdo"
L["SHIFT_RIGHT"] = "Mayús + Clic derecho"
L["SHIFT_MIDDLE"] = "Mayús + Clic central"

L["TOOLTIP_OPTIONS"] = "Opciones de Tracking Eye"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "Alternar habilidad del Modo de recolección"
L["BINDING_NOTHING_TO_CYCLE"] =
	"No hay habilidades de rastreo seleccionadas para el Modo de recolección. Elige algunas en Opciones > Addons > Tracking Eye > Modo de recolección."
L["BINDING_NOTHING_LEARNED"] =
	"No conoces ninguna de las habilidades que has seleccionado para alternar en el Modo de recolección."
L["BINDING_NEEDS_CAT_FORM"] = "El rastreo de druida solo se puede lanzar en Forma felina."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESCRIPTION"] =
	"Menú de rastreo mejorado y cambio automático de rastreo que alterna entre Buscar hierbas y Buscar minerales mientras recolectas y vuelve a aplicar el rastreo después de morir. Compatible con todas las habilidades de rastreo. Nunca pierdas el rastro de los recursos que estás cazando."
L["OPTIONS_ENABLE_WELCOME"] = "Habilitar mensaje de bienvenida"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] = "Muestra un saludo de una línea en el chat al cargarse Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Habilitar botón del minimapa"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "Todo sigue funcionando con el botón oculto."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la Interfaz de Opciones de este complemento."

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "Atajos de teclado"
L["OPTIONS_KEYBINDS_DESCRIPTION"] =
	"Salta a la siguiente habilidad de rastreo con una sola tecla, incluso con el Modo de recolección desactivado. Asígnala en Atajos de teclado, dentro del menú del juego."

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"Todas las habilidades de rastreo que conoces, en un solo menú alfabético. La que elijas pasa a ser tu Habilidad de rastreo persistente."
L["OPTIONS_HOOK_BLIZZARD"] = "Usar el botón de rastreo predeterminado"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"El botón de rastreo de Blizzard también abre este menú. Déjalo desactivado si otro complemento ya usa ese botón."

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"No vuelvas a perder tu rastreo: regresa enseguida cuando mueres, cambias de forma o cambias de zona."
L["OPTIONS_ENABLE_PERSISTENT"] = "Habilitar Rastreo persistente"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"Espera a que salgas de combate, así nunca te cuesta un tiempo de reutilización global en plena pelea."
L["OPTIONS_FISHING_POLE_FISH"] = "Buscar pescado al equipar una caña de pescar"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "Tu propia elección vuelve cuando te quitas la caña."
L["OPTIONS_CAT_FORM_HUMANOIDS"] = "Druida: Rastrear humanoides al cambiar a Forma felina"
L["OPTIONS_CAT_FORM_HUMANOIDS_DESCRIPTION"] =
	"Espera a que termine Acechar, y tu propia elección vuelve cuando sales de la forma."
L["OPTIONS_BATTLEGROUND_HUMANOIDS"] = "Cazador: Rastrear humanoides en campos de batalla"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] =
	"Las arenas también cuentan, y tu propia elección vuelve cuando sales."

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"Toma como objetivo una criatura y el resto de su especie se ilumina en tu minimapa. ¡Ideal para hacer misiones!"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "Habilitar Rastreo automático de objetivo"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"Nunca cambia en combate, así que los enemigos que se suman a la pelea no te quitan el rastreo. Saquear un cadáver tampoco lo cambia."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Modo de ubicación libre"
L["OPTIONS_PLACEMENT_DESCRIPTION"] =
	"¿Minimapa abarrotado? Saca de él el icono de rastreo y colócalo donde quieras en la pantalla."
L["OPTIONS_ENABLE_FREE"] = "Habilitar Modo de ubicación libre"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"Su posición la comparten todos tus personajes y se mantiene tras recargar la interfaz o cambiar su escala."
L["OPTIONS_ICON_SHAPE"] = "Forma del icono"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] =
	"El círculo combina con el minimapa; el cuadrado encaja bien junto a las barras de acción."
L["OPTIONS_SHAPE_CIRCLE"] = "Círculo"
L["OPTIONS_SHAPE_SQUARE"] = "Cuadrado"
L["OPTIONS_ICON_SCALE"] = "Tamaño del icono"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] = "Cambia de tamaño sin moverse, así que el icono conserva su sitio."

-- Feedback & Support

L["OPTIONS_LINKS"] = "Comentarios y soporte"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Versión %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "Modo de recolección"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"Hierbas y minerales en el mismo minimapa. El Modo de recolección alterna tus habilidades de rastreo mientras viajas, para que no se te escape ningún nodo."
L["OPTIONS_ENABLE_FARM"] = "Habilitar Modo de recolección"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"Se pausa solo en combate, en ciudades, en estancias y durante los vuelos. Pasa el ratón por encima del botón de Tracking Eye para ver el motivo."
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "Silenciar sonidos de habilidades de rastreo"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"Solo se silencian los cambios del propio Modo de recolección. El rastreo que eliges tú sigue sonando."
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "Alejar el minimapa"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] =
	"Con el zoom al mínimo, el minimapa muestra los nodos rastreados desde mucho más lejos."
L["OPTIONS_FARM_CONDITIONS"] = "Condiciones del Modo de recolección"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"Recolecta a tu manera: montado, a pie o en la forma de viaje de tu clase. El Modo de recolección alterna en cualquier estado que marques."
L["OPTIONS_FARM_MOUNTED"] = "Montado"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] = "Desmonta junto a un nodo y el ciclo espera mientras recolectas."
L["OPTIONS_FARM_NOT_MOUNTED"] = "No montado"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] =
	"Detente a recolectar o a comer y el ciclo espera hasta que sigas tu camino."
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Druida: Formas de viaje"
L["OPTIONS_FARM_TRAVEL_FORMS_DESCRIPTION"] = "Forma acuática y Forma voladora también cuentan."
L["OPTIONS_FARM_CHEETAH"] = "Cazador: Aspecto del guepardo"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "Solo alterna mientras te mueves, como cualquier otra condición."
L["OPTIONS_FARM_PACK"] = "Cazador: Aspecto de la manada"
L["OPTIONS_FARM_PACK_DESCRIPTION"] =
	"Muy útil en rutas de recolección en grupo, donde todo el grupo se mueve a velocidad de guepardo."
L["OPTIONS_FARM_GHOST_WOLF"] = "Chamán: Lobo fantasmal"
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "Ideal para rutas de recolección antes de tu primera montura."
L["OPTIONS_CYCLE_SPEED"] = "Velocidad del ciclo"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"Cada cambio cuesta un tiempo de reutilización global, así que un ciclo más lento choca menos con tus propios hechizos."
L["OPTIONS_CYCLE_EVERY"] = "Alternar cada %s segundos"
L["OPTIONS_FARM_ABILITIES"] = "Habilidades del Modo de recolección"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"Marca lo que quieras encontrar. El Modo de recolección alterna cada habilidad marcada que conozca este personaje y omite el resto."
L["OPTIONS_FARM_GROUP_GENERAL"] = "Profesiones y habilidades raciales"
L["OPTIONS_FARM_CAT_FORM_NOTE"] = "Solo alterna en Forma felina, que cuenta como No montado."
L["OPTIONS_FARM_PERSISTENT"] = "Incluir Habilidad de rastreo persistente"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"Nunca aparece dos veces, aunque también esté marcada abajo. El Rastreo automático de objetivo la sustituye por la especie de tu objetivo."

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

L["MATCH_HERB"] = "Botánica;Herboristería"
L["MATCH_MINE"] = "Minería"

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

L["MSG_FORMAT_LOCKED"] = "¡Ey, Pícaros! %s (%s, %s) en %s."
L["MSG_FORMAT_HERB"] = "¡Ey, Herboristas! %s (%s, %s) en %s."
L["MSG_FORMAT_MINE"] = "¡Ey, Mineros! %s (%s, %s) en %s."

L["CHAT_TOO_LONG"] =
	"Este borrador tiene %d bytes y supera el límite de %d bytes del chat. Acórtalo antes de enviarlo."

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"¿Has encontrado una hierba que no puedes recoger, una veta de mineral que no puedes extraer o un cofre del tesoro cerrado con llave sin ningún Pícaro a la vista? Haz clic derecho encima y Come & Get It crea un mensaje que puedes usar para compartir o difundir las coordenadas. Ser un héroe nunca ha sido tan fácil."
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "Habilitar Come & Get It"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"Se queda en silencio en combate y en estancias, así que el chat nunca te quita el teclado en plena pelea."
L["OPTIONS_OUTPUT_NAME"] = "Salida predeterminada"
L["OPTIONS_OUTPUT_DESCRIPTION"] = "Hermandad llega a todos los miembros conectados, sea cual sea su capa o su zona."
L["OPTIONS_OUTPUT_NOTE"] = "Nota: Local (/1) solo llega a los jugadores de tu capa."
L["OPTIONS_OUTPUT_CHANNEL1"] = "Local (/1)"
L["OPTIONS_OUTPUT_SAY"] = "Hablar"
L["OPTIONS_OUTPUT_YELL"] = "Gritar"
L["OPTIONS_OUTPUT_PARTY"] = "Grupo"
L["OPTIONS_OUTPUT_GUILD"] = "Hermandad"
