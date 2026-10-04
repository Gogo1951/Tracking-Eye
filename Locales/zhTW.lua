local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "zhTW")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本 %s。設定（包含停用此訊息的選項）可以在 選項 > 插件 > Tracking Eye 中找到。喜歡這個插件？告訴您的朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟選項介面。"
L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟按鍵綁定清單。"
L["KEY_BINDINGS_LOCATION"] = "開啟遊戲選單，點選%s，再點選%s，然後找到 Tracking Eye 分類。"

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "追蹤選單"
L["TRACKING_MENU_DESCRIPTION"] = "選擇您的持久追蹤技能。"
L["PERSISTENT_TRACKING"] = "持久追蹤"
L["TARGET_TRACKING"] = "自動目標追蹤"
L["TARGET_TRACKING_DESCRIPTION"] = "追蹤您所選目標的同類生物。"
L["FARM_MODE"] = "採集模式"
L["FARM_MODE_DESCRIPTION"] = "在旅途中循環切換您的追蹤技能。"

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "採集模式狀態"
L["FARM_STATUS_ACTIVE"] = "運作中"
L["FARM_STATUS_PAUSED"] = "已暫停"

L["FARM_PAUSED_DEAD"] = "您已死亡。"
L["FARM_PAUSED_TAXI"] = "正在飛行路線上。"
L["FARM_PAUSED_INSTANCE"] = "位於副本內。"
L["FARM_PAUSED_RESTING"] = "位於城鎮或旅館。"
L["FARM_PAUSED_NO_ABILITIES"] = "未勾選任何採集模式技能。"
L["FARM_PAUSED_NOT_LEARNED"] = "您尚未學會任何已勾選的採集模式技能。"
L["FARM_PAUSED_CAT_FORM_NAMED"] = "%s追蹤只在%s下循環。"
L["FARM_PAUSED_NO_STATES"] = "未開啟任何採集模式條件。"
L["FARM_PAUSED_NOT_MOUNTED"] = "未騎乘。"
L["FARM_PAUSED_NOT_TRAVEL"] = "未處於旅行類形態。"
L["FARM_PAUSED_NOT_ASPECT_NAMED"] = "未使用%s。"
L["FARM_PAUSED_NOT_GHOST_WOLF_NAMED"] = "未處於%s形態。"
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "未騎乘，也未處於旅行類形態。"
L["FARM_PAUSED_NOT_MOUNTED_ASPECT_NAMED"] = "未騎乘，也未使用%s。"
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF_NAMED"] = "未騎乘，也未處於%s形態。"
L["FARM_PAUSED_MOUNTED_OFF"] = "採集模式未設定為在騎乘時運作。"
L["FARM_PAUSED_TRAVEL_OFF"] = "採集模式未設定為在旅行類形態下運作。"
L["FARM_PAUSED_ASPECT_OFF_NAMED"] = "採集模式未設定為在%s下運作。"
L["FARM_PAUSED_GHOST_WOLF_OFF_NAMED"] = "採集模式未設定為在%s形態下運作。"
L["FARM_PAUSED_COMBAT"] = "正在戰鬥中。"
L["FARM_PAUSED_CASTING"] = "正在施法。"
L["FARM_PAUSED_STEALTHED"] = "處於潛行狀態。"
L["FARM_PAUSED_LOOTING"] = "拾取視窗已開啟。"
L["FARM_PAUSED_CURSOR"] = "游標上有東西。"
L["FARM_PAUSED_OPTIONS"] = "選項介面已開啟。"
L["FARM_PAUSED_WINDOW"] = "有視窗已開啟。"
L["FARM_PAUSED_TOOLTIP"] = "正在查看提示資訊。"
L["FARM_PAUSED_TARGET"] = "正以可攻擊的單位為目標。"
L["FARM_PAUSED_STANDING_STILL"] = "正站著不動。"

L["PERSISTENT_ABILITY"] = "持久追蹤技能"
L["NONE_SET"] = "未設定"
L["CLEAR_TRACKING"] = "清除追蹤"

L["ENABLED"] = "已開啟"
L["DISABLED"] = "已關閉"
L["TOGGLE"] = "切換"

L["OPEN"] = "開啟"
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
	"未勾選任何採集模式技能。請在 選項 > 插件 > Tracking Eye > 採集模式 中勾選。"

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- General

L["OPTIONS_DESCRIPTION"] =
	"改進的追蹤選單和自動追蹤切換器，在採集時循環尋找草藥和尋找礦物，在死亡後恢復追蹤，並在解任務時追蹤您所選目標的同類生物。支援所有追蹤技能。再也不會跟丟您要找的目標。"
L["OPTIONS_ENABLE_WELCOME"] = "啟用歡迎訊息"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] = "Tracking Eye 載入時在聊天中顯示一行歡迎語。"
L["OPTIONS_ENABLE_MINIMAP"] = "啟用小地圖按鈕"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "隱藏按鈕後，所有功能照常運作。"

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的選項介面。"

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "按鍵綁定"
L["OPTIONS_KEY_SET"] = "設定按鍵"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "開啟遊戲的按鍵綁定清單，Tracking Eye 在其中有專屬分類。"
L["OPTIONS_KEYBINDS_DESCRIPTION"] = "一鍵跳到下一個追蹤技能，即使採集模式已關閉也能使用。"

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"您掌握的所有追蹤技能，匯集在一個依名稱排序的選單中。選取的技能將成為您的持久追蹤技能。"
L["OPTIONS_HOOK_BLIZZARD"] = "使用預設追蹤按鈕"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"預設追蹤按鈕也會開啟此選單。如果其他插件已在使用該按鈕，請保持關閉。"

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"再也不會失去追蹤：死亡、變形或切換區域後，它都會立即恢復。"
L["OPTIONS_ENABLE_PERSISTENT"] = "啟用持久追蹤"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"會等到您脫離戰鬥再施放，絕不會在戰鬥中佔用共用冷卻時間。"
L["OPTIONS_FISHING_POLE_FISH_NAMED"] = "%s（裝備%s時）"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "收起魚竿後，您自己選擇的追蹤會恢復。"
L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"] = "%s：%s（變為%s時）"
L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"] =
	"會等到您脫離潛行，離開該形態後您自己選擇的追蹤會恢復。"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"] = "%s：在戰場中%s"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] =
	"競技場也算在內，離開後您自己選擇的追蹤會恢復。"

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"選取一個生物，小地圖上就會亮起牠的所有同類。非常適合解任務！"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "啟用自動目標追蹤"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"戰鬥中絕不切換，增援的怪物搶不走您的追蹤。拾取屍體也不會觸發切換。"

-- Free Placement Mode

L["PLACEMENT_MODE"] = "自由移動模式"
L["OPTIONS_PLACEMENT_DESCRIPTION"] = "小地圖太擁擠？把追蹤圖示拖出來，放在螢幕上任意位置。"
L["OPTIONS_ENABLE_FREE"] = "啟用自由移動模式"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"它的位置由您的所有角色共用，重新載入介面或調整介面縮放後也會保持不變。"
L["OPTIONS_ICON_SHAPE"] = "圖示形狀"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] = "圓形與小地圖相配；方形可以整齊地放在快捷列旁邊。"
L["OPTIONS_SHAPE_CIRCLE"] = "圓形"
L["OPTIONS_SHAPE_SQUARE"] = "方形"
L["OPTIONS_ICON_SCALE"] = "圖示大小"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] = "原地縮放，圖示會保持在原來的位置。"

-- Feedback & Support

L["OPTIONS_LINKS"] = "回饋與支援"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "版本 %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "採集模式"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"草藥和礦石盡在同一張小地圖上。採集模式會在您旅行時輪換追蹤技能，不放過任何一個採集點。"
L["OPTIONS_ENABLE_FARM"] = "啟用採集模式"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"在戰鬥中、城鎮裡、副本內和飛行途中會自動暫停。將滑鼠游標停在 Tracking Eye 按鈕上即可查看原因。"
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "靜音追蹤技能的施法音效"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"只有採集模式自己的切換會靜音。您親自選擇的追蹤仍會發出聲音。"
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "縮小小地圖"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] = "小地圖縮到最小後，能顯示遠得多的已追蹤資源點。"
L["OPTIONS_FARM_CONDITIONS"] = "採集模式條件"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"隨心採集：騎乘、步行或使用本職業的旅行形態皆可。採集模式會在您勾選的任一狀態下循環。"
L["OPTIONS_FARM_MOUNTED"] = "騎乘時"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] = "在採集點下馬後，循環會等您採集完畢。"
L["OPTIONS_FARM_NOT_MOUNTED"] = "未騎乘"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] = "停下來採集或進食時，循環會等您繼續前進。"
L["OPTIONS_FARM_TRAVEL_FORMS_NAMED"] = "%s：旅行類形態"
L["OPTIONS_FARM_TRAVEL_FORMS_ONE_DESCRIPTION"] = "%s也算在內。"
L["OPTIONS_FARM_TRAVEL_FORMS_TWO_DESCRIPTION"] = "%s和%s也算在內。"
L["OPTIONS_FARM_CLASS_STATE"] = "%s：%s"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "只在您移動時循環，和其他條件一樣。"
L["OPTIONS_FARM_PACK_GROUP_DESCRIPTION"] = "適合組隊跑圖採集，全隊都能跟上您的速度。"
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "獲得第一隻坐騎之前跑圖採集的好幫手。"
L["OPTIONS_CYCLE_SPEED"] = "循環速度"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"每次切換都會佔用一次共用冷卻時間，因此循環越慢，越少干擾您自己的施法。"
L["OPTIONS_CYCLE_EVERY"] = "每 %s 秒切換"
L["OPTIONS_FARM_ABILITIES"] = "採集模式技能"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"勾選您想找的東西。採集模式會循環此角色已學會的所有勾選技能，並略過其餘技能。"
L["OPTIONS_FARM_GROUP_GENERAL"] = "專業技能與種族特長"
L["OPTIONS_FARM_CAT_FORM_NOTE_NAMED"] = "只在%s下循環，該形態算作未騎乘。"
L["OPTIONS_FARM_PERSISTENT"] = "包含持久追蹤技能"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"即使下方也已勾選，它也絕不會出現兩次。自動目標追蹤會用追蹤您目標同類的技能取代它。"

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

L["MATCH_HERB"] = "草藥學"
L["MATCH_MINE"] = "採礦"

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

L["MSG_FORMAT_LOCKED"] = "盜賊們！%s，座標 %s, %s（%s）。"
L["MSG_FORMAT_HERB"] = "草藥學家們！%s，座標 %s, %s（%s）。"
L["MSG_FORMAT_MINE"] = "礦工們！%s，座標 %s, %s（%s）。"

L["CHAT_TOO_LONG"] = "此草稿為 %d 位元組，超過了 %d 位元組的聊天上限。請在傳送前縮短。"

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"發現了採不了的草藥、挖不了的礦脈，或是一個上了鎖的寶箱，附近卻沒有盜賊？右鍵點擊它，Come & Get It 就會產生一則訊息，供您分享或廣播座標。當英雄從未如此輕鬆。"
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "啟用 Come & Get It"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"在戰鬥中和副本內保持安靜，聊天視窗絕不會在戰鬥中搶走您的鍵盤輸入。"
L["OPTIONS_OUTPUT_NAME"] = "預設輸出"
L["OPTIONS_OUTPUT_DESCRIPTION"] =
	"公會頻道會送達所有線上的公會成員，無論其位於哪個位面或區域。"
L["OPTIONS_OUTPUT_NOTE"] = "注意：本地 (/1) 只能送達與您處於同一位面的玩家。"
L["OPTIONS_OUTPUT_CHANNEL1"] = "本地 (/1)"
