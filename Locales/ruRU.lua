local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "ruRU")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"Версия %s. Настройки (включая возможность отключить это сообщение) находятся в разделе Параметры > Модификации > Tracking Eye. Нравится аддон? Расскажите другу! (="
L["CHAT_OPTIONS_IN_COMBAT"] =
	"В целях безопасности интерфейс настроек нельзя открыть в бою."
L["CHAT_KEY_BINDINGS_IN_COMBAT"] =
	"В целях безопасности список назначения клавиш нельзя открыть в бою."
L["KEY_BINDINGS_LOCATION"] =
	"Откройте игровое меню, затем пункт %s, затем пункт %s и найдите раздел Tracking Eye."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "Меню отслеживания"
L["TRACKING_MENU_DESCRIPTION"] =
	"Выберите способность постоянного отслеживания."
L["PERSISTENT_TRACKING"] = "Постоянное отслеживание"
L["TARGET_TRACKING"] = "Автоматическое отслеживание цели"
L["TARGET_TRACKING_DESCRIPTION"] =
	"Отслеживает существ того же вида, что и ваша цель."
L["FARM_MODE"] = "Режим фарма"
L["FARM_MODE_DESCRIPTION"] = "Переключает способности отслеживания в пути."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "Состояние Режима фарма"
L["FARM_STATUS_ACTIVE"] = "Активен"
L["FARM_STATUS_PAUSED"] = "Приостановлен"

L["FARM_PAUSED_DEAD"] = "Вы мертвы."
L["FARM_PAUSED_TAXI"] = "На маршруте полета."
L["FARM_PAUSED_INSTANCE"] = "Внутри подземелья."
L["FARM_PAUSED_RESTING"] = "В городе или таверне."
L["FARM_PAUSED_NO_ABILITIES"] = "Не отмечено ни одной способности Режима фарма."
L["FARM_PAUSED_NOT_LEARNED"] =
	"Вы не знаете ни одной из отмеченных способностей Режима фарма."
L["FARM_PAUSED_CAT_FORM_NAMED"] = "%s: для переключения отслеживания требуется %s."
L["FARM_PAUSED_NO_STATES"] = "Ни одно из Условий Режима фарма не включено."
L["FARM_PAUSED_NOT_MOUNTED"] = "Вы не верхом."
L["FARM_PAUSED_NOT_TRAVEL"] = "Вы не в походном облике."
L["FARM_PAUSED_NOT_ASPECT_NAMED"] = "%s не используется."
L["FARM_PAUSED_NOT_GHOST_WOLF_NAMED"] = "Вы не в облике: %s."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "Вы не верхом и не в походном облике."
L["FARM_PAUSED_NOT_MOUNTED_ASPECT_NAMED"] = "Вы не верхом, и %s не используется."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF_NAMED"] = "Вы не верхом и не в облике: %s."
L["FARM_PAUSED_MOUNTED_OFF"] = "Режим фарма не настроен на работу верхом."
L["FARM_PAUSED_TRAVEL_OFF"] =
	"Режим фарма не настроен на работу в походных обликах."
L["FARM_PAUSED_ASPECT_OFF_NAMED"] =
	"Режим фарма не настроен на работу, когда используется %s."
L["FARM_PAUSED_GHOST_WOLF_OFF_NAMED"] =
	"Режим фарма не настроен на работу в облике: %s."
L["FARM_PAUSED_COMBAT"] = "В бою."
L["FARM_PAUSED_CASTING"] = "Идет применение заклинания."
L["FARM_PAUSED_STEALTHED"] = "В незаметности."
L["FARM_PAUSED_LOOTING"] = "Открыто окно добычи."
L["FARM_PAUSED_CURSOR"] = "На курсоре что-то есть."
L["FARM_PAUSED_OPTIONS"] = "Открыт интерфейс настроек."
L["FARM_PAUSED_WINDOW"] = "Открыто окно."
L["FARM_PAUSED_TOOLTIP"] = "Вы читаете подсказку."
L["FARM_PAUSED_TARGET"] = "У вас в цели тот, кого можно атаковать."
L["FARM_PAUSED_STANDING_STILL"] = "Вы стоите на месте."

L["PERSISTENT_ABILITY"] = "Способность постоянного отслеживания"
L["NONE_SET"] = "Не выбрано"
L["CLEAR_TRACKING"] = "Очистить отслеживание"

L["ENABLED"] = "Включено"
L["DISABLED"] = "Выключено"
L["TOGGLE"] = "Переключить"

L["OPEN"] = "Открыть"
L["LEFT_CLICK"] = "ЛКМ"
L["RIGHT_CLICK"] = "ПКМ"
L["SHIFT_LEFT"] = "Shift + ЛКМ"
L["SHIFT_RIGHT"] = "Shift + ПКМ"
L["SHIFT_MIDDLE"] = "Shift + СКМ"

L["TOOLTIP_OPTIONS"] = "Настройки Tracking Eye"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "Переключить способность Режима фарма"
L["BINDING_NOTHING_TO_CYCLE"] =
	"Не отмечено ни одной способности Режима фарма. Отметьте нужные в разделе Параметры > Модификации > Tracking Eye > Режим фарма."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- General

L["OPTIONS_DESCRIPTION"] =
	"Улучшенное меню отслеживания и автоматический переключатель, который чередует Поиск трав и Поиск минералов во время фарма, восстанавливает отслеживание после смерти, а во время заданий отслеживает существ, взятых в цель. Поддерживает все способности отслеживания. Никогда не упускайте добычу из виду."
L["OPTIONS_ENABLE_WELCOME"] = "Включить приветственное сообщение"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] =
	"Выводит в чат однострочное приветствие при загрузке Tracking Eye."
L["OPTIONS_ENABLE_MINIMAP"] = "Включить кнопку у мини-карты"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] =
	"Все продолжает работать и со скрытой кнопкой."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Открывает интерфейс настроек этого аддона."

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "Назначение клавиш"
L["OPTIONS_KEY_SET"] = "Назначить клавишу"
L["OPTIONS_KEY_SET_DESCRIPTION"] =
	"Открывает игровой список назначения клавиш, где у Tracking Eye есть собственный раздел."
L["OPTIONS_KEYBINDS_DESCRIPTION"] =
	"Переход к следующей способности отслеживания одной клавишей, даже при выключенном Режиме фарма."

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"Все известные вам способности отслеживания в одном меню по алфавиту. Выбранная становится вашей способностью постоянного отслеживания."
L["OPTIONS_HOOK_BLIZZARD"] = "Использовать стандартную кнопку отслеживания"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"Стандартная кнопка отслеживания тоже открывает это меню. Не включайте, если эту кнопку уже использует другой аддон."

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"Больше никогда не теряйте отслеживание: оно сразу возвращается после смерти, смены облика или перехода в другую зону."
L["OPTIONS_ENABLE_PERSISTENT"] = "Включить Постоянное отслеживание"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"Ждет, пока вы выйдете из боя, поэтому никогда не тратит глобальное время восстановления посреди схватки."
L["OPTIONS_FISHING_POLE_FISH_NAMED"] = "%s при экипировке: %s"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] =
	"Ваш собственный выбор вернется, когда вы уберете удочку."
L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"] = "%s: %s при переходе в %s"
L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"] =
	"Дожидается выхода из незаметности, а ваш выбор вернется, когда вы покинете облик."
L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"] = "%s: %s на полях боя"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] =
	"Арены тоже считаются, а ваш выбор вернется, когда вы их покинете."

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"Возьмите существо в цель, и все его сородичи появятся на мини-карте. Отлично подходит для заданий!"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "Включить Автоматическое отслеживание цели"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"Не переключается в бою, поэтому набежавшие противники не собьют отслеживание. Обыск трупа тоже его не переключит."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "Свободное перемещение"
L["OPTIONS_PLACEMENT_DESCRIPTION"] =
	"Мини-карта перегружена? Снимите с нее значок отслеживания и поставьте в любое место экрана."
L["OPTIONS_ENABLE_FREE"] = "Включить Свободное перемещение"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"Его место общее для всех ваших персонажей и сохраняется после перезагрузки интерфейса и смены его масштаба."
L["OPTIONS_ICON_SHAPE"] = "Форма значка"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] =
	"Круг сочетается с мини-картой, квадрат аккуратно встает рядом с панелями команд."
L["OPTIONS_SHAPE_CIRCLE"] = "Круг"
L["OPTIONS_SHAPE_SQUARE"] = "Квадрат"
L["OPTIONS_ICON_SCALE"] = "Размер значка"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] =
	"Меняет размер на месте, так что значок не сдвигается."

-- Feedback & Support

L["OPTIONS_LINKS"] = "Отзывы и поддержка"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Версия %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "Режим фарма"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"Травы и руда на одной мини-карте. Режим фарма переключает способности отслеживания в пути, чтобы ни один ресурс не ускользнул от вас."
L["OPTIONS_ENABLE_FARM"] = "Включить Режим фарма"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"Сам встает на паузу в бою, в городах, подземельях и во время полетов. Наведите курсор на кнопку Tracking Eye, чтобы узнать причину."
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "Заглушить звуки способностей отслеживания"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"Затихают только переключения самого Режима фарма. Отслеживание, выбранное вами, по-прежнему звучит."
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "Отдалить мини-карту"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] =
	"При максимальном отдалении мини-карта показывает отслеживаемые ресурсы с гораздо большего расстояния."
L["OPTIONS_FARM_CONDITIONS"] = "Условия Режима фарма"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"Фармите как удобно: верхом, пешком или в походном облике вашего класса. Режим фарма работает в любом отмеченном состоянии."
L["OPTIONS_FARM_MOUNTED"] = "Верхом"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] =
	"Спешьтесь у ресурса, и цикл подождет, пока вы собираете."
L["OPTIONS_FARM_NOT_MOUNTED"] = "Пешком"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] =
	"Остановитесь, чтобы собрать ресурс или поесть, и цикл подождет, пока вы не двинетесь дальше."
L["OPTIONS_FARM_TRAVEL_FORMS_NAMED"] = "%s: походные облики"
L["OPTIONS_FARM_TRAVEL_FORMS_ONE_DESCRIPTION"] = "%s тоже считается."
L["OPTIONS_FARM_TRAVEL_FORMS_TWO_DESCRIPTION"] = "%s и %s тоже считаются."
L["OPTIONS_FARM_CLASS_STATE"] = "%s: %s"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] =
	"Переключает только в движении, как и при любом другом условии."
L["OPTIONS_FARM_PACK_GROUP_DESCRIPTION"] =
	"Удобно при групповом сборе, когда вся группа держит ваш темп."
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] =
	"Отлично подходит для сбора ресурсов до первого средства передвижения."
L["OPTIONS_CYCLE_SPEED"] = "Скорость цикла"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"Каждое переключение тратит глобальное время восстановления, поэтому медленный цикл меньше мешает вашим заклинаниям."
L["OPTIONS_CYCLE_EVERY"] = "Переключать каждые %s сек."
L["OPTIONS_FARM_ABILITIES"] = "Способности Режима фарма"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"Отметьте то, что хотите найти. Режим фарма переключает все отмеченные способности, известные этому персонажу, и пропускает остальные."
L["OPTIONS_FARM_GROUP_GENERAL"] = "Профессии и расовые способности"
L["OPTIONS_FARM_CAT_FORM_NOTE_NAMED"] =
	"Переключается только в облике: %s. Он относится к условию Пешком."
L["OPTIONS_FARM_PERSISTENT"] = "Включать способность постоянного отслеживания"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"Никогда не появляется дважды, даже если отмечена и ниже. Автоматическое отслеживание цели подставляет вместо нее вид вашей цели."

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

L["MATCH_HERB"] = "Травничество"
L["MATCH_MINE"] = "Горное дело"

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

L["MSG_FORMAT_LOCKED"] = "Эй, разбойники! %s (%s, %s), %s."
L["MSG_FORMAT_HERB"] = "Эй, травники! %s (%s, %s), %s."
L["MSG_FORMAT_MINE"] = "Эй, рудокопы! %s (%s, %s), %s."

L["CHAT_TOO_LONG"] =
	"Этот черновик занимает %d байт и превышает лимит чата в %d байт. Сократите его перед отправкой."

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"Нашли траву, которую не можете собрать, рудную жилу, которую не можете разработать, или запертый сундук с сокровищами, а разбойника рядом нет? Щелкните по находке правой кнопкой мыши, и Come & Get It создаст сообщение, с помощью которого можно поделиться координатами или объявить их всем. Быть героем еще никогда не было так просто."
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "Включить Come & Get It"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"Молчит в бою и в подземельях, чтобы окно чата не перехватывало клавиатуру посреди схватки."
L["OPTIONS_OUTPUT_NAME"] = "Вывод по умолчанию"
L["OPTIONS_OUTPUT_DESCRIPTION"] =
	"Гильдия доходит до всех согильдийцев в сети, на любом слое и в любой зоне."
L["OPTIONS_OUTPUT_NOTE"] =
	"Примечание: Локальный (/1) доходит только до игроков на вашем слое."
L["OPTIONS_OUTPUT_CHANNEL1"] = "Локальный (/1)"
