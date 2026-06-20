local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "esMX")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Versión %s. Los ajustes (incluyendo la opción de desactivar este mensaje) se pueden encontrar en Opciones > Accesorios > Tracking Eye. ¿Te gusta el addon? ¡Cuéntaselo a un amigo! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Menú de rastreo"
L["TRACKING_MENU_DESC"] = "Muestra una lista de tus habilidades de rastreo y establece la habilidad de rastreo persistente."

L["PERSISTENT_ABILITY"] = "Habilidad de rastreo persistente"
L["NONE_SET"] = "Ninguno establecido"
L["CLEAR_TRACKING"] = "Borrar rastreo"

L["PERSISTENT_TRACKING"] = "Rastreo persistente"
L["PERSISTENT_DESC"] = "Vuelve a lanzar tu hechizo de rastreo automáticamente tras resucitar y cambiar de forma."

L["FARM_MODE"] = "Modo de recolección"
L["FARM_MODE_DESC"] = "Alterna entre tus habilidades de rastreo seleccionadas mientras estás en movimiento."

L["PLACEMENT_MODE"] = "Modo de ubicación libre"
L["PLACEMENT_DESC"] = "Reemplaza el botón del minimapa con un icono independiente que puedes mover a cualquier lugar."

L["ENABLED"] = "Habilitado"
L["DISABLED"] = "Deshabilitado"
L["TOGGLE"] = "Alternar"

L["LEFT_CLICK"] = "Clic Izquierdo"
L["RIGHT_CLICK"] = "Clic Derecho"
L["SHIFT_LEFT"] = "Mayús + Clic Izquierdo"
L["SHIFT_RIGHT"] = "Mayús + Clic Derecho"
L["SHIFT_MIDDLE"] = "Mayús + Clic Central"

L["TOOLTIP_OPTIONS_HINT"] = "Se pueden encontrar ajustes adicionales en Opciones > Accesorios > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] = "Menú de rastreo mejorado y cambio automático de rastreo que alterna entre Buscar hierbas y Buscar minerales mientras recolectas y vuelve a aplicar el rastreo después de morir. Soporta todas las habilidades de rastreo. Nunca pierdas el rastro de los recursos que estás cazando."
L["OPTIONS_ENABLE_WELCOME"] = "Habilitar mensaje de bienvenida"
L["OPTIONS_WELCOME_DESC"] = "Imprime un saludo de una línea en el chat cuando Tracking Eye se carga."
L["OPTIONS_ENABLE_MINIMAP"] = "Habilitar botón del minimapa"
L["OPTIONS_ENABLE_MINIMAP_DESC"] = "Muestra el botón de Tracking Eye en el minimapa; el Modo de recolección y el Rastreo persistente siguen funcionando cuando está oculto."

-- Slash Commands

L["OPTIONS_COMMANDS_INTRO"] = "Comandos de barra para Tracking Eye. El panel de opciones cubre todo lo que necesitas; estos están aquí para los que prefieren usar el teclado."
L["OPTIONS_COMMAND_TE"] = "Abre la interfaz de opciones de Tracking Eye."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Habilitar Rastreo persistente"

-- Farm Mode

L["OPTIONS_ENABLE_FARM"] = "Habilitar Modo de recolección"
L["OPTIONS_FARM_ACTIVATE"] = "Activar Modo de recolección mientras:"
L["OPTIONS_FARM_MOUNTED"] = "Montado"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Formas de viaje y vuelo"
L["OPTIONS_FARM_CHEETAH"] = "Aspecto del guepardo"
L["OPTIONS_FARM_GHOST_WOLF"] = "Lobo fantasmal"
L["OPTIONS_FARM_NOT_MOUNTED"] = "No montado"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Alterna incluso sin montura o forma de movimiento."
L["OPTIONS_FARM_NOTE"] = "Nota: El Modo de recolección solo funciona cuando estás fuera de combate, sin lanzar hechizos y fuera de ciudades, posadas y estancias."
L["OPTIONS_FARM_ABILITIES"] = "Habilidades del Modo de recolección"
L["OPTIONS_CYCLE_SPEED"] = "Velocidad de ciclo"
L["OPTIONS_CYCLE_SPEED_DESC"] = "Con qué frecuencia el Modo de recolección cambia entre las habilidades de rastreo (en segundos)."

-- Free Placement Mode

L["OPTIONS_ENABLE_FREE"] = "Habilitar Modo de ubicación libre"
L["OPTIONS_ICON_SCALE"] = "Tamaño del icono"
L["OPTIONS_ICON_SCALE_DESC"] = "Escala del icono de rastreo al usar el Modo de ubicación libre."
L["OPTIONS_ICON_SHAPE"] = "Forma del icono"
L["OPTIONS_ICON_SHAPE_DESC"] = "Forma del borde del icono de rastreo al usar el Modo de ubicación libre."
L["OPTIONS_SHAPE_CIRCLE"] = "Círculo"
L["OPTIONS_SHAPE_SQUARE"] = "Cuadrado"

-- Reset

L["OPTIONS_RESET_HEADER"] = "Restablecer"
L["OPTIONS_RESET_DESC"] = "Restaura todos los ajustes de Tracking Eye a sus valores predeterminados."
L["OPTIONS_RESET"] = "Restablecer todas las opciones"
L["OPTIONS_RESET_CONFIRM"] = "¿Restablecer todas las opciones de Tracking Eye a los valores predeterminados?"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Comentarios y soporte"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"