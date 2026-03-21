local _, te = ...
if GetLocale() ~= "zhTW" then return end

local L = te.L

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "追蹤選單"
L["TRACKING_MENU_DESC"] = "查看追蹤技能列表，並設置持久追蹤能力。"

L["PERSISTENT_ABILITY"] = "持久追蹤能力"
L["NONE_SET"]           = "未設置"
L["CLEAR_TRACKING"]     = "清除追蹤"

L["PERSISTENT_TRACKING"] = "持久追蹤"
L["PERSISTENT_DESC"]      = "復活後自動重新施放追蹤法術。"

L["FARM_MODE"]    = "採集模式"
L["FARMING_DESC"] = "在坐騎或旅行形態下，於草藥和礦石之間循環。"

L["PLACEMENT_MODE"] = "自由移動模式"
L["PLACEMENT_DESC"] = "將小地圖按鈕替換為可隨處移動的獨立圖示。"

L["ENABLED"]  = "已開啟"
L["DISABLED"] = "已關閉"
L["TOGGLE"]   = "切換"

L["LEFT_CLICK"]   = "左鍵"
L["RIGHT_CLICK"]  = "右鍵"
L["SHIFT_LEFT"]   = "Shift + 左鍵"
L["SHIFT_RIGHT"]  = "Shift + 右鍵"
L["SHIFT_MIDDLE"] = "Shift + 中鍵"

L["TOOLTIP_OPTIONS_HINT"] = "更多選項可在 選項 > 插件 > Tracking Eye 中查看。"

-- Options Panel
L["OPTIONS_ALWAYS_ON"]           = "(始終開啟)"
L["OPTIONS_CYCLE_SPEED"]         = "循環速度"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "採集模式在追蹤技能之間切換的頻率（秒）。"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_ENABLE_FARM"]         = "啟用採集模式"
L["OPTIONS_ENABLE_FREE"]         = "啟用自由移動模式"
L["OPTIONS_ENABLE_PERSISTENT"]   = "啟用持久追蹤"
L["OPTIONS_FARM_ABILITIES"]      = "採集模式技能"
L["OPTIONS_FARM_ABILITIES_DESC"] = "選擇在坐騎或旅行形態下，採集模式要循環的追蹤技能。"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_ICON_SCALE"]          = "圖示大小"
L["OPTIONS_ICON_SCALE_DESC"]     = "使用自由移動模式時追蹤圖示的縮放比例。"
L["OPTIONS_ICON_SHAPE"]          = "圖示形狀"
L["OPTIONS_ICON_SHAPE_DESC"]     = "使用自由移動模式時追蹤圖示邊框的形狀。"
L["OPTIONS_LINKS"]               = "回饋與支援"
L["OPTIONS_PERCENT"]             = "%d%%"
L["OPTIONS_RESET"]               = "重置所有選項"
L["OPTIONS_SECONDS"]             = "%.1f 秒"
L["OPTIONS_SHAPE_CIRCLE"]        = "圓形"
L["OPTIONS_SHAPE_SQUARE"]        = "方形"