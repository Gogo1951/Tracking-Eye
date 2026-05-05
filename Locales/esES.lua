local strings = {}

strings["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

strings["CHAT_LOADED"] = "Versión @project-version@. Escribe %s para abrir las opciones. ¿Te gusta el addon? ¡Cuéntaselo a un amigo! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

strings["TRACKING_MENU"] = "Menú de rastreo"
strings["TRACKING_MENU_DESC"] = "Muestra una lista de tus habilidades de rastreo y establece la habilidad de rastreo persistente."

strings["PERSISTENT_ABILITY"] = "Habilidad de rastreo persistente"
strings["NONE_SET"] = "Ninguno establecido"
strings["CLEAR_TRACKING"] = "Borrar rastreo"

strings["PERSISTENT_TRACKING"] = "Rastreo persistente"
strings["PERSISTENT_DESC"] = "Vuelve a lanzar tu hechizo de rastreo automáticamente tras resucitar."

strings["FARM_MODE"] = "Modo de recolección"
strings["FARMING_DESC"] = "Alterna entre Hierbas, Minerales y Tesoros mientras estás montado o en forma de viaje."

strings["PLACEMENT_MODE"] = "Modo de ubicación libre"
strings["PLACEMENT_DESC"] = "Reemplaza el botón del minimapa con un icono independiente que puedes mover a cualquier lugar."

strings["ENABLED"] = "Habilitado"
strings["DISABLED"] = "Deshabilitado"
strings["TOGGLE"] = "Alternar"

strings["LEFT_CLICK"] = "Clic Izquierdo"
strings["RIGHT_CLICK"] = "Clic Derecho"
strings["SHIFT_LEFT"] = "Mayús + Clic Izquierdo"
strings["SHIFT_RIGHT"] = "Mayús + Clic Derecho"
strings["SHIFT_MIDDLE"] = "Mayús + Clic Central"

strings["TOOLTIP_OPTIONS_HINT"] = "Se pueden encontrar ajustes adicionales en Opciones > Accesorios > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

strings["OPTIONS_DESC"] = "Un menú de rastreo inteligente que alterna entre rastreo de hierbas y minerales mientras estás montado, y restaura automáticamente tu habilidad de rastreo tras la muerte."
strings["OPTIONS_COMMANDS_INTRO"] = "Comandos de barra para Tracking Eye. El panel de opciones cubre todo lo que necesitas; estos están aquí para los que prefieren usar el teclado."
strings["OPTIONS_COMMAND_TE"] = "Abre la interfaz de opciones de Tracking Eye."
strings["OPTIONS_GENERAL_SETTINGS"] = "Ajustes generales"
strings["OPTIONS_WELCOME_DESC"] = "Imprime un saludo de una línea en el chat cuando Tracking Eye se carga."
strings["OPTIONS_RESET"] = "Restablecer todas las opciones"
strings["OPTIONS_RESET_HEADER"] = "Restablecer"
strings["OPTIONS_RESET_CONFIRM"] = "¿Restablecer todas las opciones de Tracking Eye a los valores predeterminados?"
strings["OPTIONS_ENABLE_PERSISTENT"] = "Habilitar Rastreo persistente"
strings["OPTIONS_ENABLE_FARM"] = "Habilitar Modo de recolección"
strings["OPTIONS_ENABLE_FREE"] = "Habilitar Modo de ubicación libre"
strings["OPTIONS_ENABLE_WELCOME"] = "Habilitar mensaje de bienvenida"
strings["OPTIONS_FARM_ABILITIES"] = "Habilidades del Modo de recolección"
strings["OPTIONS_FARM_ABILITIES_DESC"] = "Selecciona qué habilidades de rastreo alternará el Modo de recolección mientras estás montado o en forma de viaje."
strings["OPTIONS_CYCLE_SPEED"] = "Velocidad de ciclo"
strings["OPTIONS_CYCLE_SPEED_DESC"] = "Con qué frecuencia el Modo de recolección cambia entre las habilidades de rastreo (en segundos)."
strings["OPTIONS_ICON_SCALE"] = "Tamaño del icono"
strings["OPTIONS_ICON_SCALE_DESC"] = "Escala del icono de rastreo al usar el Modo de ubicación libre."
strings["OPTIONS_ICON_SHAPE"] = "Forma del icono"
strings["OPTIONS_ICON_SHAPE_DESC"] = "Forma del borde del icono de rastreo al usar el Modo de ubicación libre."
strings["OPTIONS_SHAPE_CIRCLE"] = "Círculo"
strings["OPTIONS_SHAPE_SQUARE"] = "Cuadrado"
strings["OPTIONS_LINKS"] = "Comentarios y soporte"
strings["OPTIONS_CURSEFORGE"] = "CurseForge"
strings["OPTIONS_DISCORD"] = "Discord"
strings["OPTIONS_GITHUB"] = "GitHub"
strings["OPTIONS_SECONDS"] = "%.1f seg"
strings["OPTIONS_PERCENT"] = "%d%%"

local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "esES")
if L then
    for k, v in pairs(strings) do L[k] = v end
end

local L2 = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "esMX")
if L2 then
    for k, v in pairs(strings) do L2[k] = v end
end