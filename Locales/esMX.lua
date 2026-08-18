local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "esMX")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Versión %s. Los ajustes (incluyendo la opción de desactivar este mensaje) se pueden encontrar en Opciones > Accesorios > Tracking Eye. ¿Te gusta el complemento? ¡Cuéntaselo a un amigo! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "Como medida de seguridad, la Interfaz de Opciones no se puede abrir durante el combate."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Menú de rastreo"
L["TRACKING_MENU_DESC"] =
	"Muestra una lista de tus habilidades de rastreo y te permite establecer tu Habilidad de rastreo persistente."
L["PERSISTENT_TRACKING"] = "Rastreo persistente"
L["PERSISTENT_DESC"] = "Vuelve a lanzar tu habilidad de rastreo automáticamente tras resucitar y cambiar de forma."
L["FARM_MODE"] = "Modo de recolección"
L["FARM_MODE_DESC"] = "Alterna entre tus habilidades de rastreo seleccionadas mientras estás en movimiento."

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
L["FARM_PAUSED_NO_ABILITIES"] = "No hay habilidades de rastreo seleccionadas."
L["FARM_PAUSED_NO_STATES"] = "No hay condiciones del Modo de recolección activadas."
L["FARM_PAUSED_NOT_MOUNTED"] = "No estás montado."
L["FARM_PAUSED_NOT_TRAVEL"] = "No estás en Forma de viaje."
L["FARM_PAUSED_NOT_CHEETAH"] = "No estás usando Aspecto del guepardo."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "No estás usando Lobo fantasmal."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "No estás montado ni en Forma de viaje."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "No estás montado ni usando Aspecto del guepardo."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "No estás montado ni usando Lobo fantasmal."
L["FARM_PAUSED_MOUNTED_OFF"] = "El Modo de recolección no está configurado para funcionar mientras estás montado."
L["FARM_PAUSED_TRAVEL_OFF"] = "El Modo de recolección no está configurado para funcionar en Forma de viaje."
L["FARM_PAUSED_CHEETAH_OFF"] = "El Modo de recolección no está configurado para funcionar con Aspecto del guepardo."
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "El Modo de recolección no está configurado para funcionar con Lobo fantasmal."
L["FARM_PAUSED_COMBAT"] = "En combate."
L["FARM_PAUSED_CASTING"] = "Lanzando un hechizo."
L["FARM_PAUSED_STEALTHED"] = "Con sigilo."
L["FARM_PAUSED_LOOTING"] = "La ventana de botín está abierta."
L["FARM_PAUSED_CURSOR"] = "Tienes algo en el cursor."
L["FARM_PAUSED_OPTIONS"] = "La Interfaz de Opciones está abierta."
L["FARM_PAUSED_WINDOW"] = "Hay una ventana abierta."
L["FARM_PAUSED_TOOLTIP"] = "Estás leyendo una descripción."

L["PERSISTENT_ABILITY"] = "Habilidad de rastreo persistente"
L["SILENCE_TRACKING_SOUNDS"] = "Silenciar sonidos de rastreo"
L["NONE_SET"] = "Ninguno establecido"
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
	"No hay habilidades de rastreo seleccionadas para el Modo de recolección. Elige algunas en Opciones > Accesorios > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"Menú de rastreo mejorado y cambio automático de rastreo que alterna entre Buscar hierbas y Buscar minerales mientras recolectas y vuelve a aplicar el rastreo después de morir. Soporta todas las habilidades de rastreo. Nunca pierdas el rastro de los recursos que estás cazando."
L["OPTIONS_ENABLE_WELCOME"] = "Habilitar mensaje de bienvenida"
L["OPTIONS_WELCOME_DESC"] = "Imprime un saludo de una línea en el chat cuando Tracking Eye se carga."
L["OPTIONS_ENABLE_MINIMAP"] = "Habilitar botón del minimapa"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"Muestra el botón de Tracking Eye en el minimapa; el Modo de recolección y el Rastreo persistente siguen funcionando cuando está oculto."
L["OPTIONS_HOOK_BLIZZARD"] = "Usar el botón de rastreo predeterminado"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"Mientras esto esté activado, el icono de rastreo de Blizzard abre el menú de Tracking Eye, que solo cambia lo que estás rastreando. Todo lo demás permanece aquí, en la Interfaz de Opciones."
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"Abre el Menú de rastreo al hacer clic en el icono de rastreo de Blizzard en el minimapa. Déjalo desactivado si otro complemento ya usa ese botón."
L["OPTIONS_KEYBINDS"] = "Asignación de teclas"
L["OPTIONS_KEYBINDS_DESC"] =
	"Avanza el Modo de recolección a su siguiente habilidad cuando lo pidas. Configúralo en Asignación de teclas dentro del menú del juego, en la sección Tracking Eye."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Comando de barra para Tracking Eye. La Interfaz de Opciones cubre todo lo que necesitas; este está aquí para los que prefieren usar el teclado."
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la Interfaz de Opciones de este complemento."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Habilitar Rastreo persistente"
L["OPTIONS_TARGET_TRACKING"] = "Rastreo automático de objetivo"
L["OPTIONS_TARGET_TRACKING_DESC"] =
	"Rastrea lo que tengas como objetivo, de modo que el resto de su especie aparezca en el minimapa."
L["OPTIONS_TARGET_TRACKING_QUESTING"] = "Nota: ¡El Rastreo automático de objetivo es ideal para hacer misiones!"

-- Farm Mode

L["TAB_FARM_MODE"] = "Modo de recolección"
L["OPTIONS_ENABLE_FARM"] = "Habilitar Modo de recolección"
L["OPTIONS_FARM_CONDITIONS"] = "Condiciones del Modo de recolección"
L["OPTIONS_FARM_MOUNTED"] = "Montado"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Formas de viaje y vuelo"
L["OPTIONS_FARM_CHEETAH"] = "Aspecto del guepardo"
L["OPTIONS_FARM_GHOST_WOLF"] = "Lobo fantasmal"
L["OPTIONS_FARM_NOT_MOUNTED"] = "No montado"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Alterna incluso sin montura o forma de movimiento."
L["OPTIONS_FARM_NOTE"] =
	"Nota: El Modo de recolección solo funciona cuando estás fuera de combate, sin lanzar hechizos y fuera de ciudades, posadas, estancias y rutas de vuelo."
L["OPTIONS_FARM_ABILITIES"] = "Habilidades del Modo de recolección"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"Incluye tu Habilidad de rastreo persistente en la rotación. Si ya está marcada abajo, aun así aparece solo una vez."
L["OPTIONS_CYCLE_EVERY"] = "Alternar cada %s segundos"
L["OPTIONS_CYCLE_EVERY_DESC"] =
	"Con qué frecuencia el Modo de recolección cambia entre las habilidades de rastreo (en segundos)."
L["SILENCE_TRACKING_SOUNDS_DESC"] =
	"Silencia el sonido de lanzamiento mientras el Modo de recolección alterna. Tus propios lanzamientos no se ven afectados."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Modo de ubicación libre"
L["PLACEMENT_DESC"] = "Reemplaza el botón del minimapa con un icono independiente que puedes mover a cualquier lugar."
L["OPTIONS_ENABLE_FREE"] = "Habilitar Modo de ubicación libre"
L["OPTIONS_ICON_SCALE"] = "Tamaño del icono"
L["OPTIONS_ICON_SCALE_DESC"] = "Tamaño del icono de rastreo al usar el Modo de ubicación libre."
L["OPTIONS_ICON_SHAPE"] = "Forma del icono"
L["OPTIONS_ICON_SHAPE_DESC"] = "Forma del borde del icono de rastreo al usar el Modo de ubicación libre."
L["OPTIONS_SHAPE_CIRCLE"] = "Círculo"
L["OPTIONS_SHAPE_SQUARE"] = "Cuadrado"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Comentarios y soporte"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
