local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "zhTW")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本 %s。設定（包含停用此訊息的選項）可以在 選項 > 插件 > Tracking Eye 中找到。喜歡這個插件？告訴你的朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟選項介面。"

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "追蹤選單"
L["TRACKING_MENU_DESC"] = "列出您的追蹤技能，並可設定持久追蹤技能。"
L["PERSISTENT_TRACKING"] = "持久追蹤"
L["PERSISTENT_DESC"] = "復活和變形後自動重新施放追蹤技能。"
L["FARM_MODE"] = "採集模式"
L["FARM_MODE_DESC"] = "在移動時，在您選擇的追蹤技能之間循環。"

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "採集模式狀態"
L["FARM_STATUS_ACTIVE"] = "運行中"
L["FARM_STATUS_PAUSED"] = "已暫停"

L["FARM_PAUSED_DEAD"] = "您已死亡。"
L["FARM_PAUSED_TAXI"] = "正在飛行路線上。"
L["FARM_PAUSED_INSTANCE"] = "位於副本內。"
L["FARM_PAUSED_RESTING"] = "位於城鎮或旅館。"
L["FARM_PAUSED_NO_ABILITIES"] = "未選擇任何追蹤技能。"
L["FARM_PAUSED_NO_STATES"] = "未開啟任何採集模式條件。"
L["FARM_PAUSED_NOT_MOUNTED"] = "未騎乘。"
L["FARM_PAUSED_NOT_TRAVEL"] = "未處於旅行形態。"
L["FARM_PAUSED_NOT_CHEETAH"] = "未使用獵豹守護。"
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "未使用鬼魂之狼。"
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "未騎乘，也未處於旅行形態。"
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "未騎乘，也未使用獵豹守護。"
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "未騎乘，也未使用鬼魂之狼。"
L["FARM_PAUSED_MOUNTED_OFF"] = "採集模式未設定為在騎乘時運行。"
L["FARM_PAUSED_TRAVEL_OFF"] = "採集模式未設定為在旅行形態下運行。"
L["FARM_PAUSED_CHEETAH_OFF"] = "採集模式未設定為在獵豹守護下運行。"
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "採集模式未設定為在鬼魂之狼下運行。"
L["FARM_PAUSED_COMBAT"] = "正在戰鬥中。"
L["FARM_PAUSED_CASTING"] = "正在施法。"
L["FARM_PAUSED_STEALTHED"] = "處於潛行狀態。"
L["FARM_PAUSED_LOOTING"] = "拾取視窗已開啟。"
L["FARM_PAUSED_CURSOR"] = "游標上有東西。"
L["FARM_PAUSED_OPTIONS"] = "選項介面已開啟。"
L["FARM_PAUSED_WINDOW"] = "有視窗已開啟。"
L["FARM_PAUSED_TOOLTIP"] = "正在查看提示資訊。"

L["PERSISTENT_ABILITY"] = "持久追蹤技能"
L["SILENCE_TRACKING_SOUNDS"] = "靜音追蹤音效"
L["NONE_SET"] = "未設定"
L["CLEAR_TRACKING"] = "清除追蹤"

L["ENABLED"] = "已開啟"
L["DISABLED"] = "已關閉"
L["TOGGLE"] = "切換"

L["OPEN"] = "打開"
L["LEFT_CLICK"] = "左鍵"
L["RIGHT_CLICK"] = "右鍵"
L["SHIFT_LEFT"] = "Shift + 左鍵"
L["SHIFT_RIGHT"] = "Shift + 右鍵"
L["SHIFT_MIDDLE"] = "Shift + 中鍵"

L["TOOLTIP_OPTIONS"] = "Tracking Eye 選項"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "切換採集模式技能"
L["BINDING_NOTHING_TO_CYCLE"] =
	"未為採集模式選擇任何追蹤技能。請在 選項 > 插件 > Tracking Eye 中選擇。"

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"改進的追蹤選單和自動追蹤切換器，在採集時循環尋找草藥和尋找礦物，並在死亡後重新應用追蹤。支援所有追蹤技能。絕不會跟丟您正在尋找的資源。"
L["OPTIONS_ENABLE_WELCOME"] = "啟用歡迎訊息"
L["OPTIONS_WELCOME_DESC"] = "在 Tracking Eye 載入時，於聊天視窗印出一行問候語。"
L["OPTIONS_ENABLE_MINIMAP"] = "啟用小地圖按鈕"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"在小地圖上顯示 Tracking Eye 按鈕；當其隱藏時，採集模式和持久追蹤仍在運行。"
L["OPTIONS_HOOK_BLIZZARD"] = "使用預設追蹤按鈕"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"啟用此選項後，暴雪的追蹤圖示將開啟 Tracking Eye 選單，該選單僅更改您追蹤的內容。其餘設定仍保留在選項介面中。"
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"點擊小地圖上暴雪的追蹤圖示時開啟追蹤選單。如果其他插件已使用該按鈕，請保持關閉。"
L["OPTIONS_KEYBINDS"] = "按鍵設定"
L["OPTIONS_KEYBINDS_DESC"] =
	"按需將採集模式切換至下一個技能。請在遊戲選單的按鍵設定中，於 Tracking Eye 分類下進行綁定。"

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Tracking Eye 的斜線指令。選項介面涵蓋了您需要的一切；這個是為喜歡使用鍵盤的玩家準備的。"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的選項介面。"

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "啟用持久追蹤"
L["OPTIONS_TARGET_TRACKING"] = "自動目標追蹤"
L["OPTIONS_TARGET_TRACKING_DESC"] = "追蹤您選取的目標，使同類的其餘成員顯示在小地圖上。"
L["OPTIONS_TARGET_TRACKING_QUESTING"] = "注意：自動目標追蹤非常適合做任務！"

-- Farm Mode

L["TAB_FARM_MODE"] = "採集模式"
L["OPTIONS_ENABLE_FARM"] = "啟用採集模式"
L["OPTIONS_FARM_CONDITIONS"] = "採集模式條件"
L["OPTIONS_FARM_MOUNTED"] = "騎乘時"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "旅行和飛行形態"
L["OPTIONS_FARM_CHEETAH"] = "獵豹守護"
L["OPTIONS_FARM_GHOST_WOLF"] = "鬼魂之狼"
L["OPTIONS_FARM_NOT_MOUNTED"] = "未騎乘"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "即使沒有坐騎或移動形態也會循環。"
L["OPTIONS_FARM_NOTE"] =
	"注意：採集模式僅在您脫離戰鬥、未施法，且位於城鎮、旅館、副本和飛行路線之外時運行。"
L["OPTIONS_FARM_ABILITIES"] = "採集模式技能"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"將您的持久追蹤技能加入循環。即使下方已勾選該技能，它也只會出現一次。"
L["OPTIONS_CYCLE_EVERY"] = "每 %s 秒切換"
L["OPTIONS_CYCLE_EVERY_DESC"] = "採集模式在追蹤技能之間切換的頻率（秒）。"
L["SILENCE_TRACKING_SOUNDS_DESC"] =
	"在採集模式循環時靜音施法音效。您自己施放的技能不受影響。"

-- Free Placement Mode

L["PLACEMENT_MODE"] = "自由移動模式"
L["PLACEMENT_DESC"] = "將小地圖按鈕替換為可隨處移動的獨立圖示。"
L["OPTIONS_ENABLE_FREE"] = "啟用自由移動模式"
L["OPTIONS_ICON_SCALE"] = "圖示大小"
L["OPTIONS_ICON_SCALE_DESC"] = "使用自由移動模式時追蹤圖示的大小。"
L["OPTIONS_ICON_SHAPE"] = "圖示形狀"
L["OPTIONS_ICON_SHAPE_DESC"] = "使用自由移動模式時追蹤圖示邊框的形狀。"
L["OPTIONS_SHAPE_CIRCLE"] = "圓形"
L["OPTIONS_SHAPE_SQUARE"] = "方形"

-- Feedback & Support

L["OPTIONS_LINKS"] = "回饋與支援"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
