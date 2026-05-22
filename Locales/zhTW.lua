local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "zhTW")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "版本 %s。設定（包含停用此訊息的選項）可以在 選項 > 插件 > Tracking Eye 中找到。喜歡這個插件？告訴你的朋友吧！(="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "追蹤選單"
L["TRACKING_MENU_DESC"] = "查看追蹤技能列表，並設置持久追蹤能力。"

L["PERSISTENT_ABILITY"] = "持久追蹤能力"
L["NONE_SET"] = "未設置"
L["CLEAR_TRACKING"] = "清除追蹤"

L["PERSISTENT_TRACKING"] = "持久追蹤"
L["PERSISTENT_DESC"] = "復活後自動重新施放追蹤法術。"

L["FARM_MODE"] = "採集模式"
L["FARMING_DESC"] = "在坐騎或旅行形態下，於草藥、礦石和寶藏之間循環。"

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

L["TOOLTIP_OPTIONS_HINT"] = "更多設定可以在 選項 > 插件 > Tracking Eye 中找到。"

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

L["OPTIONS_DESC"] = "一個智能追蹤選單，在坐騎狀態下自動循環草藥和礦石追蹤，並在死亡後自動恢復追蹤技能。"
L["OPTIONS_COMMANDS_INTRO"] = "Tracking Eye 的斜線指令。選項面板涵蓋了您需要的一切；這些是為喜歡使用鍵盤的玩家準備的。"
L["OPTIONS_COMMAND_TE"] = "打開 Tracking Eye 選項介面。"
L["OPTIONS_WELCOME_DESC"] = "在 Tracking Eye 載入時，於聊天視窗印出一行問候語。"
L["OPTIONS_RESET"] = "重置所有選項"
L["OPTIONS_RESET_HEADER"] = "重置"
L["OPTIONS_RESET_DESC"] = "將每一個 Tracking Eye 設定還原為預設值。"
L["OPTIONS_RESET_CONFIRM"] = "將所有 Tracking Eye 選項重置為預設值？"
L["OPTIONS_ENABLE_PERSISTENT"] = "啟用持久追蹤"
L["OPTIONS_ENABLE_FARM"] = "啟用採集模式"
L["OPTIONS_ENABLE_FREE"] = "啟用自由移動模式"
L["OPTIONS_ENABLE_WELCOME"] = "啟用歡迎訊息"
L["OPTIONS_FARM_ABILITIES"] = "採集模式技能"
L["OPTIONS_CYCLE_SPEED"] = "循環速度"
L["OPTIONS_CYCLE_SPEED_DESC"] = "採集模式在追蹤技能之間切換的頻率（秒）。"
L["OPTIONS_ICON_SCALE"] = "圖示大小"
L["OPTIONS_ICON_SCALE_DESC"] = "使用自由移動模式時追蹤圖示的縮放比例。"
L["OPTIONS_ICON_SHAPE"] = "圖示形狀"
L["OPTIONS_ICON_SHAPE_DESC"] = "使用自由移動模式時追蹤圖示邊框的形狀。"
L["OPTIONS_SHAPE_CIRCLE"] = "圓形"
L["OPTIONS_SHAPE_SQUARE"] = "方形"
L["OPTIONS_LINKS"] = "回饋與支援"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"