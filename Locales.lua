local _, ns = ...
local L = setmetatable({}, {__index = function(t, k) return k end})
local locale = GetLocale()

--------------------------------------------------------------------------------
-- English (Default)
--------------------------------------------------------------------------------
L["ADDON_TITLE"] = "Tracking Eye"
L["NO_TRACKING"] = "No Tracking Selected"

L["PERSISTENT_TRACKING"] = "Persistent Tracking"
L["PERSISTENT_DESC"] = "Automatically recasts your tracking spell after resurrection."

L["FARMING_MODE"] = "Farming Mode"
L["FARMING_DESC"] = "Cycles between Herbs, Minerals, and Treasure while mounted or in travel form."

L["PLACEMENT_MODE"] = "Free Placement Mode"
L["PLACEMENT_DESC"] = "Replaces the minimap button with a standalone icon you can move anywhere."

L["ENABLED"] = "Enabled"
L["DISABLED"] = "Disabled"
L["TOGGLE"] = "Toggle"
L["TRACKING_MENU"] = "Tracking Menu"
L["CLEAR_TRACKING"] = "Clear Persistent Tracking"

L["MOD_SHIFT_LEFT"] = "Shift + Left-Click"
L["MOD_SHIFT_RIGHT"] = "Shift + Right-Click"
L["MOD_MIDDLE"] = "Middle-Click"
L["MOD_LEFT"] = "Left-Click"
L["MOD_RIGHT"] = "Right-Click"

--------------------------------------------------------------------------------
-- German (deDE)
--------------------------------------------------------------------------------
if locale == "deDE" then
    L["NO_TRACKING"] = "Keine Aufspürung ausgewählt"
    L["PERSISTENT_TRACKING"] = "Dauerhafte Aufspürung"
    L["PERSISTENT_DESC"] = "Wirkt Aufspürungszauber nach Wiederbelebung automatisch erneut."
    L["FARMING_MODE"] = "Farming-Modus"
    L["FARMING_DESC"] = "Wechselt zwischen Kräutern, Erzen und Schätzen, während du reitest."
    L["PLACEMENT_MODE"] = "Freie Platzierung"
    L["PLACEMENT_DESC"] = "Ersetzt die Minimap-Schaltfläche durch ein frei bewegliches Symbol."
    L["ENABLED"] = "Aktiviert"
    L["DISABLED"] = "Deaktiviert"
    L["TOGGLE"] = "Umschalten"
    L["TRACKING_MENU"] = "Aufspürungsmenü"
    L["CLEAR_TRACKING"] = "Dauerhafte Aufspürung löschen"
    
    L["MOD_SHIFT_LEFT"] = "Umschalt + Linksklick"
    L["MOD_SHIFT_RIGHT"] = "Umschalt + Rechtsklick"
    L["MOD_MIDDLE"] = "Mittelklick"
    L["MOD_LEFT"] = "Linksklick"
    L["MOD_RIGHT"] = "Rechtsklick"

--------------------------------------------------------------------------------
-- French (frFR)
--------------------------------------------------------------------------------
elseif locale == "frFR" then
    L["NO_TRACKING"] = "Aucun pistage sélectionné"
    L["PERSISTENT_TRACKING"] = "Pistage persistant"
    L["PERSISTENT_DESC"] = "Relance automatiquement votre pistage après une résurrection."
    L["FARMING_MODE"] = "Mode de collecte"
    L["FARMING_DESC"] = "Alterne entre herbes, minerais et trésors en monture."
    L["PLACEMENT_MODE"] = "Mode de placement libre"
    L["PLACEMENT_DESC"] = "Remplace le bouton de la minicarte par une icône indépendante."
    L["ENABLED"] = "Activé"
    L["DISABLED"] = "Désactivé"
    L["TOGGLE"] = "Basculer"
    L["TRACKING_MENU"] = "Menu de pistage"
    L["CLEAR_TRACKING"] = "Effacer le pistage persistant"
    
    L["MOD_SHIFT_LEFT"] = "Maj + Clic gauche"
    L["MOD_SHIFT_RIGHT"] = "Maj + Clic droit"
    L["MOD_MIDDLE"] = "Clic milieu"
    L["MOD_LEFT"] = "Clic gauche"
    L["MOD_RIGHT"] = "Clic droit"

--------------------------------------------------------------------------------
-- Spanish (esES & esMX)
--------------------------------------------------------------------------------
elseif locale == "esES" or locale == "esMX" then
    L["NO_TRACKING"] = "Rastreo no seleccionado"
    L["PERSISTENT_TRACKING"] = "Rastreo persistente"
    L["PERSISTENT_DESC"] = "Vuelve a lanzar el hechizo de rastreo automáticamente tras resucitar."
    L["FARMING_MODE"] = "Modo de recolección"
    L["FARMING_DESC"] = "Alterna entre hierbas, minerales y tesoros mientras montas."
    L["PLACEMENT_MODE"] = "Modo de ubicación libre"
    L["PLACEMENT_DESC"] = "Reemplaza el botón del minimapa con un icono independiente."
    L["ENABLED"] = "Habilitado"
    L["DISABLED"] = "Deshabilitado"
    L["TOGGLE"] = "Alternar"
    L["TRACKING_MENU"] = "Menú de rastreo"
    L["CLEAR_TRACKING"] = "Borrar rastreo persistente"
    
    L["MOD_SHIFT_LEFT"] = "Mayús + Clic Izquierdo"
    L["MOD_SHIFT_RIGHT"] = "Mayús + Clic Derecho"
    L["MOD_MIDDLE"] = "Clic Central"
    L["MOD_LEFT"] = "Clic Izquierdo"
    L["MOD_RIGHT"] = "Clic Derecho"

--------------------------------------------------------------------------------
-- Portuguese (ptBR)
--------------------------------------------------------------------------------
elseif locale == "ptBR" then
    L["NO_TRACKING"] = "Nenhum rastreamento selecionado"
    L["PERSISTENT_TRACKING"] = "Rastreamento Persistente"
    L["PERSISTENT_DESC"] = "Relança automaticamente o feitiço de rastreamento após a ressurreição."
    L["FARMING_MODE"] = "Modo de Coleta"
    L["FARMING_DESC"] = "Alterna entre Ervas, Minérios e Tesouros enquanto montado."
    L["PLACEMENT_MODE"] = "Modo de Posicionamento Livre"
    L["PLACEMENT_DESC"] = "Substitui o botão do minimapa por um ícone independente."
    L["ENABLED"] = "Habilitado"
    L["DISABLED"] = "Desabilitado"
    L["TOGGLE"] = "Alternar"
    L["TRACKING_MENU"] = "Menu de Rastreamento"
    L["CLEAR_TRACKING"] = "Limpar Rastreamento"
    
    L["MOD_SHIFT_LEFT"] = "Shift + Clique Esquerdo"
    L["MOD_SHIFT_RIGHT"] = "Shift + Clique Direito"
    L["MOD_MIDDLE"] = "Clique do Meio"
    L["MOD_LEFT"] = "Clique Esquerdo"
    L["MOD_RIGHT"] = "Clique Direito"

--------------------------------------------------------------------------------
-- Italian (itIT)
--------------------------------------------------------------------------------
elseif locale == "itIT" then
    L["NO_TRACKING"] = "Nessun tracciamento selezionato"
    L["PERSISTENT_TRACKING"] = "Tracciamento Persistente"
    L["PERSISTENT_DESC"] = "Rilancia automaticamente l'incantesimo di tracciamento dopo la resurrezione."
    L["FARMING_MODE"] = "Modalità Raccolta"
    L["FARMING_DESC"] = "Cicla tra Erbe, Minerali e Tesori mentre sei a cavallo."
    L["PLACEMENT_MODE"] = "Posizionamento Libero"
    L["PLACEMENT_DESC"] = "Sostituisce il pulsante della minimappa con un'icona indipendente."
    L["ENABLED"] = "Abilitato"
    L["DISABLED"] = "Disabilitato"
    L["TOGGLE"] = "Attiva/Disattiva"
    L["TRACKING_MENU"] = "Menu Tracciamento"
    L["CLEAR_TRACKING"] = "Cancella Tracciamento"
    
    L["MOD_SHIFT_LEFT"] = "Maiusc + Clic Sinistro"
    L["MOD_SHIFT_RIGHT"] = "Maiusc + Clic Destro"
    L["MOD_MIDDLE"] = "Clic Centrale"
    L["MOD_LEFT"] = "Clic Sinistro"
    L["MOD_RIGHT"] = "Clic Destro"

--------------------------------------------------------------------------------
-- Russian (ruRU)
--------------------------------------------------------------------------------
elseif locale == "ruRU" then
    L["NO_TRACKING"] = "Отслеживание не выбрано"
    L["PERSISTENT_TRACKING"] = "Постоянное отслеживание"
    L["PERSISTENT_DESC"] = "Автоматически восстанавливает отслеживание после воскрешения."
    L["FARMING_MODE"] = "Режим фарма"
    L["FARMING_DESC"] = "Переключает поиск трав, руды и сокровищ во время езды."
    L["PLACEMENT_MODE"] = "Свободное перемещение"
    L["PLACEMENT_DESC"] = "Заменяет кнопку у мини-карты на отдельный значок."
    L["ENABLED"] = "Включено"
    L["DISABLED"] = "Выключено"
    L["TOGGLE"] = "Переключить"
    L["TRACKING_MENU"] = "Меню отслеживания"
    L["CLEAR_TRACKING"] = "Очистить отслеживание"
    
    L["MOD_SHIFT_LEFT"] = "Shift + ЛКМ"
    L["MOD_SHIFT_RIGHT"] = "Shift + ПКМ"
    L["MOD_MIDDLE"] = "СКМ"
    L["MOD_LEFT"] = "ЛКМ"
    L["MOD_RIGHT"] = "ПКМ"

--------------------------------------------------------------------------------
-- Korean (koKR)
--------------------------------------------------------------------------------
elseif locale == "koKR" then
    L["NO_TRACKING"] = "추적 선택되지 않음"
    L["PERSISTENT_TRACKING"] = "지속적인 추적"
    L["PERSISTENT_DESC"] = "부활 후 추적 주문을 자동으로 다시 시전합니다."
    L["FARMING_MODE"] = "파밍 모드"
    L["FARMING_DESC"] = "탈것을 타거나 이동 형태일 때 약초, 광물, 보물을 순환합니다."
    L["PLACEMENT_MODE"] = "자유 배치 모드"
    L["PLACEMENT_DESC"] = "미니맵 버튼을 독립적인 아이콘으로 대체하여 이동할 수 있습니다."
    L["ENABLED"] = "활성화됨"
    L["DISABLED"] = "비활성화됨"
    L["TOGGLE"] = "전환"
    L["TRACKING_MENU"] = "추적 메뉴"
    L["CLEAR_TRACKING"] = "지속 추적 해제"
    
    L["MOD_SHIFT_LEFT"] = "Shift + 왼쪽 클릭"
    L["MOD_SHIFT_RIGHT"] = "Shift + 오른쪽 클릭"
    L["MOD_MIDDLE"] = "휠 클릭"
    L["MOD_LEFT"] = "왼쪽 클릭"
    L["MOD_RIGHT"] = "오른쪽 클릭"

--------------------------------------------------------------------------------
-- Simplified Chinese (zhCN)
--------------------------------------------------------------------------------
elseif locale == "zhCN" then
    L["NO_TRACKING"] = "未选择追踪"
    L["PERSISTENT_TRACKING"] = "持久追踪"
    L["PERSISTENT_DESC"] = "复活后自动重新开启追踪。"
    L["FARMING_MODE"] = "采集模式"
    L["FARMING_DESC"] = "在骑乘或旅行形态下循环切换草药、矿石和宝藏追踪。"
    L["PLACEMENT_MODE"] = "自由移动模式"
    L["PLACEMENT_DESC"] = "将小地图按钮替换为可随处移动的独立图标。"
    L["ENABLED"] = "已开启"
    L["DISABLED"] = "已关闭"
    L["TOGGLE"] = "切换"
    L["TRACKING_MENU"] = "追踪菜单"
    L["CLEAR_TRACKING"] = "清除持久追踪"
    
    L["MOD_SHIFT_LEFT"] = "Shift + 左键"
    L["MOD_SHIFT_RIGHT"] = "Shift + 右键"
    L["MOD_MIDDLE"] = "中键"
    L["MOD_LEFT"] = "左键"
    L["MOD_RIGHT"] = "右键"

--------------------------------------------------------------------------------
-- Traditional Chinese (zhTW)
--------------------------------------------------------------------------------
elseif locale == "zhTW" then
    L["NO_TRACKING"] = "未選擇追蹤"
    L["PERSISTENT_TRACKING"] = "持久追蹤"
    L["PERSISTENT_DESC"] = "復活後自動重新開啟追蹤。"
    L["FARMING_MODE"] = "採集模式"
    L["FARMING_DESC"] = "在騎乘或旅行形態下循環切換草藥、礦石和寶藏追蹤。"
    L["PLACEMENT_MODE"] = "自由移動模式"
    L["PLACEMENT_DESC"] = "將小地圖按鈕替換為可隨處移動的獨立圖示。"
    L["ENABLED"] = "已開啟"
    L["DISABLED"] = "已關閉"
    L["TOGGLE"] = "切換"
    L["TRACKING_MENU"] = "追蹤選單"
    L["CLEAR_TRACKING"] = "清除持久追蹤"
    
    L["MOD_SHIFT_LEFT"] = "Shift + 左鍵"
    L["MOD_SHIFT_RIGHT"] = "Shift + 右鍵"
    L["MOD_MIDDLE"] = "中鍵"
    L["MOD_LEFT"] = "左鍵"
    L["MOD_RIGHT"] = "右鍵"
end

ns.L = L