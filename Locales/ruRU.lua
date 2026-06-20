local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "ruRU")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "Версия %s. Настройки (включая возможность отключить это сообщение) можно найти в Настройки > Модификации > Tracking Eye. Нравится аддон? Расскажите другу! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "Меню отслеживания"
L["TRACKING_MENU_DESC"] = "Показать список способностей отслеживания и выбрать способность для постоянного отслеживания."

L["PERSISTENT_ABILITY"] = "Способность постоянного отслеживания"
L["NONE_SET"] = "Не выбрано"
L["CLEAR_TRACKING"] = "Очистить отслеживание"

L["PERSISTENT_TRACKING"] = "Постоянное отслеживание"
L["PERSISTENT_DESC"] = "Автоматически восстанавливает заклинание отслеживания после воскрешения и смены облика."

L["FARM_MODE"] = "Режим фарма"
L["FARM_MODE_DESC"] = "Переключает выбранные способности отслеживания во время движения."

L["PLACEMENT_MODE"] = "Свободное перемещение"
L["PLACEMENT_DESC"] = "Заменяет кнопку у миникарты отдельным значком, который можно переместить куда угодно."

L["ENABLED"] = "Включено"
L["DISABLED"] = "Выключено"
L["TOGGLE"] = "Переключить"

L["LEFT_CLICK"] = "ЛКМ"
L["RIGHT_CLICK"] = "ПКМ"
L["SHIFT_LEFT"] = "Shift + ЛКМ"
L["SHIFT_RIGHT"] = "Shift + ПКМ"
L["SHIFT_MIDDLE"] = "Shift + СКМ"

L["TOOLTIP_OPTIONS_HINT"] = "Дополнительные настройки можно найти в Настройки > Модификации > Tracking Eye."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] = "Улучшенное меню отслеживания и автоматический переключатель, который чередует Поиск трав и Поиск минералов во время фарма и восстанавливает отслеживание после смерти. Поддерживает все способности отслеживания. Никогда не теряйте из виду ресурсы, за которыми охотитесь."
L["OPTIONS_ENABLE_WELCOME"] = "Включить приветственное сообщение"
L["OPTIONS_WELCOME_DESC"] = "Выводит однострочное приветствие в чат при загрузке Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Включить кнопку у миникарты"
L["OPTIONS_ENABLE_MINIMAP_DESC"] = "Показывает кнопку Tracking Eye у миникарты; Режим фарма и Постоянное отслеживание продолжают работать, когда она скрыта."

-- Slash Commands

L["OPTIONS_COMMANDS_INTRO"] = "Слеш-команды для Tracking Eye. Панель настроек содержит все необходимое; это для тех, кто предпочитает использовать клавиатуру."
L["OPTIONS_COMMAND_TE"] = "Открывает интерфейс настроек Tracking Eye."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "Включить Постоянное отслеживание"

-- Farm Mode

L["OPTIONS_ENABLE_FARM"] = "Включить Режим фарма"
L["OPTIONS_FARM_ACTIVATE"] = "Активировать режим фарма во время:"
L["OPTIONS_FARM_MOUNTED"] = "Верхом"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "Походный облик и облик птицы"
L["OPTIONS_FARM_CHEETAH"] = "Дух гепарда"
L["OPTIONS_FARM_GHOST_WOLF"] = "Призрачный волк"
L["OPTIONS_FARM_NOT_MOUNTED"] = "Пешком"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "Переключать даже без средства передвижения или облика для движения."
L["OPTIONS_FARM_NOTE"] = "Примечание: Режим фарма работает только вне боя, когда вы не применяете заклинания и находитесь вне городов, таверн и подземелий."
L["OPTIONS_FARM_ABILITIES"] = "Способности Режима фарма"
L["OPTIONS_CYCLE_SPEED"] = "Скорость цикла"
L["OPTIONS_CYCLE_SPEED_DESC"] = "Как часто Режим фарма переключается между способностями отслеживания (в секундах)."

-- Free Placement Mode

L["OPTIONS_ENABLE_FREE"] = "Включить Свободное перемещение"
L["OPTIONS_ICON_SCALE"] = "Размер значка"
L["OPTIONS_ICON_SCALE_DESC"] = "Масштаб значка отслеживания при использовании Свободного перемещения."
L["OPTIONS_ICON_SHAPE"] = "Форма значка"
L["OPTIONS_ICON_SHAPE_DESC"] = "Форма рамки значка отслеживания при использовании Свободного перемещения."
L["OPTIONS_SHAPE_CIRCLE"] = "Круг"
L["OPTIONS_SHAPE_SQUARE"] = "Квадрат"

-- Reset

L["OPTIONS_RESET_HEADER"] = "Сброс"
L["OPTIONS_RESET_DESC"] = "Восстановить все настройки Tracking Eye по умолчанию."
L["OPTIONS_RESET"] = "Сбросить все настройки"
L["OPTIONS_RESET_CONFIRM"] = "Сбросить все настройки Tracking Eye по умолчанию?"

-- Feedback & Support

L["OPTIONS_LINKS"] = "Отзывы и поддержка"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"