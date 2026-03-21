local _, te = ...
if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

local L = te.L

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "Menú de rastreo"
L["TRACKING_MENU_DESC"] = "Muestra una lista de tus habilidades de rastreo y establece la habilidad de rastreo persistente."

L["PERSISTENT_ABILITY"] = "Habilidad de rastreo persistente"
L["NONE_SET"]           = "Ninguno establecido"
L["CLEAR_TRACKING"]     = "Borrar rastreo"

L["PERSISTENT_TRACKING"] = "Rastreo persistente"
L["PERSISTENT_DESC"]      = "Vuelve a lanzar tu hechizo de rastreo automáticamente tras resucitar."

L["FARM_MODE"]    = "Modo de recolección"
L["FARMING_DESC"] = "Alterna entre Hierbas y Minerales mientras estás montado o en forma de viaje."

L["PLACEMENT_MODE"] = "Modo de ubicación libre"
L["PLACEMENT_DESC"] = "Reemplaza el botón del minimapa con un icono independiente que puedes mover a cualquier lugar."

L["ENABLED"]  = "Habilitado"
L["DISABLED"] = "Deshabilitado"
L["TOGGLE"]   = "Alternar"

L["LEFT_CLICK"]   = "Clic Izquierdo"
L["RIGHT_CLICK"]  = "Clic Derecho"
L["SHIFT_LEFT"]   = "Mayús + Clic Izquierdo"
L["SHIFT_RIGHT"]  = "Mayús + Clic Derecho"
L["SHIFT_MIDDLE"] = "Mayús + Clic Central"

L["TOOLTIP_OPTIONS_HINT"] = "Hay opciones adicionales disponibles en Opciones > Accesorios > Tracking Eye."

-- Options Panel
L["OPTIONS_RESET"]               = "Restablecer todas las opciones"
L["OPTIONS_ENABLE_PERSISTENT"]   = "Habilitar Rastreo persistente"
L["OPTIONS_ENABLE_FARM"]         = "Habilitar Modo de recolección"
L["OPTIONS_ENABLE_FREE"]         = "Habilitar Modo de ubicación libre"
L["OPTIONS_FARM_ABILITIES"]      = "Habilidades del Modo de recolección"
L["OPTIONS_FARM_ABILITIES_DESC"] = "Selecciona qué habilidades de rastreo alternará el Modo de recolección mientras estás montado o en forma de viaje."
L["OPTIONS_CYCLE_SPEED"]         = "Velocidad de ciclo"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "Con qué frecuencia el Modo de recolección cambia entre las habilidades de rastreo (en segundos)."
L["OPTIONS_ICON_SCALE"]          = "Tamaño del icono"
L["OPTIONS_ICON_SCALE_DESC"]     = "Escala del icono de rastreo al usar el Modo de ubicación libre."
L["OPTIONS_ICON_SHAPE"]          = "Forma del icono"
L["OPTIONS_ICON_SHAPE_DESC"]     = "Forma del borde del icono de rastreo al usar el Modo de ubicación libre."
L["OPTIONS_SHAPE_CIRCLE"]        = "Círculo"
L["OPTIONS_SHAPE_SQUARE"]        = "Cuadrado"
L["OPTIONS_LINKS"]               = "Comentarios y soporte"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_SECONDS"]             = "%.1f seg"
L["OPTIONS_PERCENT"]             = "%d%%"