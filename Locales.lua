local _, te = ...
local L = setmetatable({}, {__index = function(t, k) return k end})
local locale = GetLocale()

--------------------------------------------------------------------------------
-- English (Default)
--------------------------------------------------------------------------------
L["ADDON_TITLE"] = "Tracking Eye"
L["TRACKING_MENU"] = "Tracking Menu"
L["TRACKING_MENU_DESC"] = "See a list of your tracking abilities, and set Persistent Tracking Ability."

L["PERSISTENT_ABILITY"] = "Persistent Tracking Ability"
L["NONE_SET"] = "None Set"
L["CLEAR_TRACKING"] = "Clear Tracking"

L["PERSISTENT_TRACKING"] = "Persistent Tracking"
L["PERSISTENT_DESC"] = "Automatically recasts your tracking spell after resurrection."

L["FARMING_MODE"] = "Farming Mode"
L["FARMING_DESC"] = "Cycles between Herbs, Minerals, Treasure, and whatever Persistent Tracking Ability is set while mounted or in travel form."

L["PLACEMENT_MODE"] = "Free Placement Mode"
L["PLACEMENT_DESC"] = "Replace the minimap button with a standalone icon you can move anywhere."

L["ENABLED"] = "Enabled"
L["DISABLED"] = "Disabled"
L["TOGGLE"] = "Toggle"

L["LEFT_CLICK"] = "Left-Click"
L["RIGHT_CLICK"] = "Right-Click"
L["SHIFT_LEFT"] = "Shift + Left-Click"
L["SHIFT_RIGHT"] = "Shift + Right-Click"
L["SHIFT_MIDDLE"] = "Shift + Middle-Click"

--------------------------------------------------------------------------------
-- German (deDE)
--------------------------------------------------------------------------------
if locale == "deDE" then
    L["TRACKING_MENU"] = "Aufspürungsmenü"
    L["TRACKING_MENU_DESC"] = "Zeigt eine Liste Eurer Aufspürfähigkeiten und legt die dauerhafte Aufspürfähigkeit fest."

    L["PERSISTENT_ABILITY"] = "Dauerhafte Aufspürungsfähigkeit"
    L["NONE_SET"] = "Keine gesetzt"
    L["CLEAR_TRACKING"] = "Aufspürung löschen"

    L["PERSISTENT_TRACKING"] = "Dauerhafte Aufspürung"
    L["PERSISTENT_DESC"] = "Wirkt Aufspürungszauber nach Wiederbelebung automatisch erneut."

    L["FARMING_MODE"] = "Farming-Modus"
    L["FARMING_DESC"] = "Wechselt zwischen Kräutern, Erzen, Schätzen und der dauerhaften Aufspürfähigkeit, während Ihr reitet oder in Reisegestalt seid."

    L["PLACEMENT_MODE"] = "Freie Platzierung"
    L["PLACEMENT_DESC"] = "Ersetzt den Minimap-Button durch ein eigenständiges Symbol, das überall hin bewegt werden kann."
    
    L["ENABLED"] = "Aktiviert"
    L["DISABLED"] = "Deaktiviert"
    L["TOGGLE"] = "Umschalten"
    
    L["LEFT_CLICK"] = "Linksklick"
    L["RIGHT_CLICK"] = "Rechtsklick"
    L["SHIFT_LEFT"] = "Umschalt + Linksklick"
    L["SHIFT_RIGHT"] = "Umschalt + Rechtsklick"
    L["SHIFT_MIDDLE"] = "Umschalt + Mittelklick"

--------------------------------------------------------------------------------
-- French (frFR)
--------------------------------------------------------------------------------
elseif locale == "frFR" then
    L["TRACKING_MENU"] = "Menu de pistage"
    L["TRACKING_MENU_DESC"] = "Affiche une liste de vos capacités de pistage et définit la capacité de pistage persistant."

    L["PERSISTENT_ABILITY"] = "Capacité de pistage persistant"
    L["NONE_SET"] = "Aucun défini"
    L["CLEAR_TRACKING"] = "Effacer le pistage"

    L["PERSISTENT_TRACKING"] = "Pistage persistant"
    L["PERSISTENT_DESC"] = "Relance automatiquement votre pistage après une résurrection."

    L["FARMING_MODE"] = "Mode de collecte"
    L["FARMING_DESC"] = "Alterne entre Herbes, Minerais, Trésors et la capacité de pistage persistant définie lorsque vous êtes monté ou en forme de voyage."

    L["PLACEMENT_MODE"] = "Mode de placement libre"
    L["PLACEMENT_DESC"] = "Remplace le bouton de la mini-carte par une icône autonome que vous pouvez déplacer n'importe où."
    
    L["ENABLED"] = "Activé"
    L["DISABLED"] = "Désactivé"
    L["TOGGLE"] = "Basculer"
    
    L["LEFT_CLICK"] = "Clic gauche"
    L["RIGHT_CLICK"] = "Clic droit"
    L["SHIFT_LEFT"] = "Maj + Clic gauche"
    L["SHIFT_RIGHT"] = "Maj + Clic droit"
    L["SHIFT_MIDDLE"] = "Maj + Clic milieu"

--------------------------------------------------------------------------------
-- Spanish (esES & esMX)
--------------------------------------------------------------------------------
elseif locale == "esES" or locale == "esMX" then
    L["TRACKING_MENU"] = "Menú de rastreo"
    L["TRACKING_MENU_DESC"] = "Muestra una lista de tus habilidades de rastreo y establece la habilidad de rastreo persistente."

    L["PERSISTENT_ABILITY"] = "Habilidad de rastreo persistente"
    L["NONE_SET"] = "Ninguno establecido"
    L["CLEAR_TRACKING"] = "Borrar rastreo"

    L["PERSISTENT_TRACKING"] = "Rastreo persistente"
    L["PERSISTENT_DESC"] = "Vuelve a lanzar el hechizo de rastreo automáticamente tras resucitar."

    L["FARMING_MODE"] = "Modo de recolección"
    L["FARMING_DESC"] = "Alterna entre Hierbas, Minerales, Tesoros y la habilidad de rastreo persistente establecida mientras estás montado o en forma de viaje."

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

--------------------------------------------------------------------------------
-- Portuguese (ptBR)
--------------------------------------------------------------------------------
elseif locale == "ptBR" then
    L["TRACKING_MENU"] = "Menu de Rastreamento"
    L["TRACKING_MENU_DESC"] = "Veja uma lista de suas habilidades de rastreamento e defina a Habilidade de Rastreamento Persistente."

    L["PERSISTENT_ABILITY"] = "Habilidade de Rastreamento Persistente"
    L["NONE_SET"] = "Nenhum definido"
    L["CLEAR_TRACKING"] = "Limpar Rastreamento"

    L["PERSISTENT_TRACKING"] = "Rastreamento Persistente"
    L["PERSISTENT_DESC"] = "Relança automaticamente o feitiço de rastreamento após a ressurreição."

    L["FARMING_MODE"] = "Modo de Coleta"
    L["FARMING_DESC"] = "Alterna entre Ervas, Minérios, Tesouros e qualquer Habilidade de Rastreamento Persistente definida enquanto montado ou em forma de viagem."

    L["PLACEMENT_MODE"] = "Modo de Posicionamento Livre"
    L["PLACEMENT_DESC"] = "Substitui o botão do minimapa por um ícone independente que você pode mover para qualquer lugar."
    
    L["ENABLED"] = "Habilitado"
    L["DISABLED"] = "Desabilitado"
    L["TOGGLE"] = "Alternar"
    
    L["LEFT_CLICK"] = "Clique Esquerdo"
    L["RIGHT_CLICK"] = "Clique Direito"
    L["SHIFT_LEFT"] = "Shift + Clique Esquerdo"
    L["SHIFT_RIGHT"] = "Shift + Clique Direito"
    L["SHIFT_MIDDLE"] = "Shift + Clique do Meio"

--------------------------------------------------------------------------------
-- Italian (itIT)
--------------------------------------------------------------------------------
elseif locale == "itIT" then
    L["TRACKING_MENU"] = "Menu Tracciamento"
    L["TRACKING_MENU_DESC"] = "Visualizza un elenco delle tue abilità di tracciamento e imposta l'Abilità di Tracciamento Persistente."

    L["PERSISTENT_ABILITY"] = "Abilità di Tracciamento Persistente"
    L["NONE_SET"] = "Nessuno impostato"
    L["CLEAR_TRACKING"] = "Cancella Tracciamento"

    L["PERSISTENT_TRACKING"] = "Tracciamento Persistente"
    L["PERSISTENT_DESC"] = "Rilancia automaticamente l'incantesimo di tracciamento dopo la resurrezione."

    L["FARMING_MODE"] = "Modalità Raccolta"
    L["FARMING_DESC"] = "Cicla tra Erbe, Minerali, Tesori e qualsiasi Abilità di Tracciamento Persistente impostata mentre sei a cavallo o in forma di viaggio."

    L["PLACEMENT_MODE"] = "Posizionamento Libero"
    L["PLACEMENT_DESC"] = "Sostituisce il pulsante della minimappa con un'icona autonoma che puoi spostare ovunque."
    
    L["ENABLED"] = "Abilitato"
    L["DISABLED"] = "Disabilitato"
    L["TOGGLE"] = "Attiva/Disattiva"
    
    L["LEFT_CLICK"] = "Clic Sinistro"
    L["RIGHT_CLICK"] = "Clic Destro"
    L["SHIFT_LEFT"] = "Maiusc + Clic Sinistro"
    L["SHIFT_RIGHT"] = "Maiusc + Clic Destro"
    L["SHIFT_MIDDLE"] = "Maiusc + Clic Centrale"

--------------------------------------------------------------------------------
-- Russian (ruRU)
--------------------------------------------------------------------------------
elseif locale == "ruRU" then
    L["TRACKING_MENU"] = "Меню отслеживания"
    L["TRACKING_MENU_DESC"] = "Показать список способностей отслеживания и выбрать способность для постоянного отслеживания."

    L["PERSISTENT_ABILITY"] = "Способность постоянного отслеживания"
    L["NONE_SET"] = "Не выбрано"
    L["CLEAR_TRACKING"] = "Очистить отслеживание"

    L["PERSISTENT_TRACKING"] = "Постоянное отслеживание"
    L["PERSISTENT_DESC"] = "Автоматически восстанавливает отслеживание после воскрешения."

    L["FARMING_MODE"] = "Режим фарма"
    L["FARMING_DESC"] = "Переключает поиск трав, минералов, сокровищ и выбранную способность постоянного отслеживания во время езды верхом или в походном облике."

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

--------------------------------------------------------------------------------
-- Korean (koKR)
--------------------------------------------------------------------------------
elseif locale == "koKR" then
    L["TRACKING_MENU"] = "추적 메뉴"
    L["TRACKING_MENU_DESC"] = "추적 능력 목록을 확인하고 지속 추적 능력을 설정합니다."

    L["PERSISTENT_ABILITY"] = "지속 추적 능력"
    L["NONE_SET"] = "설정되지 않음"
    L["CLEAR_TRACKING"] = "추적 해제"

    L["PERSISTENT_TRACKING"] = "지속적인 추적"
    L["PERSISTENT_DESC"] = "부활 후 추적 주문을 자동으로 다시 시전합니다."

    L["FARMING_MODE"] = "파밍 모드"
    L["FARMING_DESC"] = "탈것에 탑승하거나 여행 형상일 때 약초, 광석, 보물 및 설정된 지속 추적 능력 사이를 순환합니다."

    L["PLACEMENT_MODE"] = "자유 배치 모드"
    L["PLACEMENT_DESC"] = "미니맵 버튼을 어디든 이동할 수 있는 독립형 아이콘으로 대체합니다."
    
    L["ENABLED"] = "활성화됨"
    L["DISABLED"] = "비활성화됨"
    L["TOGGLE"] = "전환"
    
    L["LEFT_CLICK"] = "왼쪽 클릭"
    L["RIGHT_CLICK"] = "오른쪽 클릭"
    L["SHIFT_LEFT"] = "Shift + 왼쪽 클릭"
    L["SHIFT_RIGHT"] = "Shift + 오른쪽 클릭"
    L["SHIFT_MIDDLE"] = "Shift + 휠 클릭"

--------------------------------------------------------------------------------
-- Simplified Chinese (zhCN)
--------------------------------------------------------------------------------
elseif locale == "zhCN" then
    L["TRACKING_MENU"] = "追踪菜单"
    L["TRACKING_MENU_DESC"] = "查看追踪技能列表，并设置持久追踪能力。"

    L["PERSISTENT_ABILITY"] = "持久追踪能力"
    L["NONE_SET"] = "未设置"
    L["CLEAR_TRACKING"] = "清除追踪"

    L["PERSISTENT_TRACKING"] = "持久追踪"
    L["PERSISTENT_DESC"] = "复活后自动重新开启追踪。"

    L["FARMING_MODE"] = "采集模式"
    L["FARMING_DESC"] = "在坐骑或旅行形态下，于草药、矿石、宝藏及设定的持久追踪能力之间循环。"

    L["PLACEMENT_MODE"] = "自由移动模式"
    L["PLACEMENT_DESC"] = "将小地图按钮替换为可随处移动的独立图标。"
    
    L["ENABLED"] = "已开启"
    L["DISABLED"] = "已关闭"
    L["TOGGLE"] = "切换"
    
    L["LEFT_CLICK"] = "左键"
    L["RIGHT_CLICK"] = "右键"
    L["SHIFT_LEFT"] = "Shift + 左键"
    L["SHIFT_RIGHT"] = "Shift + 右键"
    L["SHIFT_MIDDLE"] = "Shift + 中键"

--------------------------------------------------------------------------------
-- Traditional Chinese (zhTW)
--------------------------------------------------------------------------------
elseif locale == "zhTW" then
    L["TRACKING_MENU"] = "追蹤選單"
    L["TRACKING_MENU_DESC"] = "查看追蹤技能列表，並設置持久追蹤能力。"

    L["PERSISTENT_ABILITY"] = "持久追蹤能力"
    L["NONE_SET"] = "未設置"
    L["CLEAR_TRACKING"] = "清除追蹤"

    L["PERSISTENT_TRACKING"] = "持久追蹤"
    L["PERSISTENT_DESC"] = "復活後自動重新開啟追蹤。"

    L["FARMING_MODE"] = "採集模式"
    L["FARMING_DESC"] = "在坐騎或旅行形態下，於草藥、礦石、寶藏及設定的持久追蹤能力之間循環。"

    L["PLACEMENT_MODE"] = "自由移動模式"
    L["PLACEMENT_DESC"] = "將小地圖按鈕替換為可隨處移動的獨立圖示。"
    
    L["ENABLED"] = "已開啟"
    L["DISABLED"] = "已關閉"
    L["TOGGLE"] = "切換"
    
    L["LEFT_CLICK"] = "左鍵"
    L["RIGHT_CLICK"] = "右鍵"
    L["SHIFT_LEFT"] = "Shift + 左鍵"
    L["SHIFT_RIGHT"] = "Shift + 右鍵"
    L["SHIFT_MIDDLE"] = "Shift + 中鍵"
end

te.L = L