-- ruRU.lua
local _, te = ...
if GetLocale() ~= "ruRU" then return end

local L = te.L

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "Меню отслеживания"
L["TRACKING_MENU_DESC"] = "Показать список способностей отслеживания и выбрать способность для постоянного отслеживания."

L["PERSISTENT_ABILITY"] = "Способность постоянного отслеживания"
L["NONE_SET"]           = "Не выбрано"
L["CLEAR_TRACKING"]     = "Очистить отслеживание"

L["PERSISTENT_TRACKING"] = "Постоянное отслеживание"
L["PERSISTENT_DESC"]      = "Автоматически восстанавливает заклинание отслеживания после воскрешения."

L["FARM_MODE"]    = "Режим фарма"
L["FARMING_DESC"] = "Переключает поиск трав, минералов и сокровищ во время езды верхом или в походном облике."

L["PLACEMENT_MODE"] = "Свободное перемещение"
L["PLACEMENT_DESC"] = "Заменяет кнопку у миникарты отдельным значком, который можно переместить куда угодно."

L["ENABLED"]  = "Включено"
L["DISABLED"] = "Выключено"
L["TOGGLE"]   = "Переключить"

L["LEFT_CLICK"]   = "ЛКМ"
L["RIGHT_CLICK"]  = "ПКМ"
L["SHIFT_LEFT"]   = "Shift + ЛКМ"
L["SHIFT_RIGHT"]  = "Shift + ПКМ"
L["SHIFT_MIDDLE"] = "Shift + СКМ"

L["TOOLTIP_OPTIONS_HINT"] = "Дополнительные настройки доступны при вводе /te или в Настройки > Модификации > Tracking Eye."

-- Options Panel
L["OPTIONS_RESET"]               = "Сбросить все настройки"
L["OPTIONS_RESET_HEADER"]        = "Сброс"
L["OPTIONS_RESET_CONFIRM"]       = "Сбросить все настройки Tracking Eye по умолчанию?"
L["OPTIONS_ENABLE_PERSISTENT"]   = "Включить Постоянное отслеживание"
L["OPTIONS_ENABLE_FARM"]         = "Включить Режим фарма"
L["OPTIONS_ENABLE_FREE"]         = "Включить Свободное перемещение"
L["OPTIONS_FARM_ABILITIES"]      = "Способности Режима фарма"
L["OPTIONS_FARM_ABILITIES_DESC"] = "Выберите, какие способности отслеживания будет переключать Режим фарма во время езды верхом или в походном облике."
L["OPTIONS_CYCLE_SPEED"]         = "Скорость цикла"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "Как часто Режим фарма переключается между способностями отслеживания (в секундах)."
L["OPTIONS_ICON_SCALE"]          = "Размер значка"
L["OPTIONS_ICON_SCALE_DESC"]     = "Масштаб значка отслеживания при использовании Свободного перемещения."
L["OPTIONS_ICON_SHAPE"]          = "Форма значка"
L["OPTIONS_ICON_SHAPE_DESC"]     = "Форма рамки значка отслеживания при использовании Свободного перемещения."
L["OPTIONS_SHAPE_CIRCLE"]        = "Круг"
L["OPTIONS_SHAPE_SQUARE"]        = "Квадрат"
L["OPTIONS_LINKS"]               = "Отзывы и поддержка"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_SECONDS"]             = "%.1f сек."
L["OPTIONS_PERCENT"]             = "%d%%"