local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "zhCN")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本 %s。设置（包含禁用此消息的选项）可以在 选项 > 插件 > Tracking Eye 中找到。喜欢这个插件？告诉你的朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开选项界面。"

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "追踪菜单"
L["TRACKING_MENU_DESC"] = "列出您的追踪技能，并可设置持久追踪技能。"
L["PERSISTENT_TRACKING"] = "持久追踪"
L["PERSISTENT_DESC"] = "复活和变形后自动重新施放追踪技能。"
L["FARM_MODE"] = "采集模式"
L["FARM_MODE_DESC"] = "在移动时，在您选择的追踪技能之间循环。"

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "采集模式状态"
L["FARM_STATUS_ACTIVE"] = "运行中"
L["FARM_STATUS_PAUSED"] = "已暂停"

L["FARM_PAUSED_DEAD"] = "您已死亡。"
L["FARM_PAUSED_TAXI"] = "正在飞行路线上。"
L["FARM_PAUSED_INSTANCE"] = "位于副本内。"
L["FARM_PAUSED_RESTING"] = "位于城镇或旅店。"
L["FARM_PAUSED_NO_ABILITIES"] = "未选择任何追踪技能。"
L["FARM_PAUSED_NO_STATES"] = "未开启任何采集模式条件。"
L["FARM_PAUSED_NOT_MOUNTED"] = "未骑乘。"
L["FARM_PAUSED_NOT_TRAVEL"] = "未处于旅行形态。"
L["FARM_PAUSED_NOT_CHEETAH"] = "未使用猎豹守护。"
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "未使用幽魂之狼。"
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "未骑乘，也未处于旅行形态。"
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] = "未骑乘，也未使用猎豹守护。"
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] = "未骑乘，也未使用幽魂之狼。"
L["FARM_PAUSED_MOUNTED_OFF"] = "采集模式未设置为在骑乘时运行。"
L["FARM_PAUSED_TRAVEL_OFF"] = "采集模式未设置为在旅行形态下运行。"
L["FARM_PAUSED_CHEETAH_OFF"] = "采集模式未设置为在猎豹守护下运行。"
L["FARM_PAUSED_GHOST_WOLF_OFF"] = "采集模式未设置为在幽魂之狼下运行。"
L["FARM_PAUSED_COMBAT"] = "正在战斗中。"
L["FARM_PAUSED_CASTING"] = "正在施法。"
L["FARM_PAUSED_STEALTHED"] = "处于潜行状态。"
L["FARM_PAUSED_LOOTING"] = "拾取窗口已打开。"
L["FARM_PAUSED_CURSOR"] = "光标上有东西。"
L["FARM_PAUSED_OPTIONS"] = "选项界面已打开。"
L["FARM_PAUSED_WINDOW"] = "有窗口已打开。"
L["FARM_PAUSED_TOOLTIP"] = "正在查看提示信息。"

L["PERSISTENT_ABILITY"] = "持久追踪技能"
L["SILENCE_TRACKING_SOUNDS"] = "静音追踪音效"
L["NONE_SET"] = "未设置"
L["CLEAR_TRACKING"] = "清除追踪"

L["ENABLED"] = "已开启"
L["DISABLED"] = "已关闭"
L["TOGGLE"] = "切换"

L["OPEN"] = "打开"
L["LEFT_CLICK"] = "左键"
L["RIGHT_CLICK"] = "右键"
L["SHIFT_LEFT"] = "Shift + 左键"
L["SHIFT_RIGHT"] = "Shift + 右键"
L["SHIFT_MIDDLE"] = "Shift + 中键"

L["TOOLTIP_OPTIONS"] = "Tracking Eye 选项"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "切换采集模式技能"
L["BINDING_NOTHING_TO_CYCLE"] =
	"未为采集模式选择任何追踪技能。请在 选项 > 插件 > Tracking Eye 中选择。"

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"改进的追踪菜单和自动追踪切换器，在采集时循环寻找草药和寻找矿物，并在死亡后重新应用追踪。支持所有追踪技能。绝不会跟丢您正在寻找的资源。"
L["OPTIONS_ENABLE_WELCOME"] = "启用欢迎消息"
L["OPTIONS_WELCOME_DESC"] = "在 Tracking Eye 加载时，于聊天窗口打印一行问候语。"
L["OPTIONS_ENABLE_MINIMAP"] = "启用小地图按钮"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"在小地图上显示 Tracking Eye 按钮；当其隐藏时，采集模式和持久追踪仍在运行。"
L["OPTIONS_HOOK_BLIZZARD"] = "使用默认追踪按钮"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"启用此选项后，暴雪的追踪按钮将打开追踪菜单，该菜单仅更改您追踪的内容。其余设置仍保留在选项界面中。"
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"点击小地图上暴雪的追踪按钮时打开追踪菜单。如果其他插件已使用该按钮，请保持关闭。"
L["OPTIONS_KEYBINDS"] = "按键设置"
L["OPTIONS_KEYBINDS_DESC"] =
	"按需将采集模式切换至下一个技能。请在游戏菜单的按键设置中，于 Tracking Eye 分类下进行绑定。"

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Tracking Eye 的斜杠命令。选项界面涵盖了您需要的一切；这个是为喜欢使用键盘的玩家准备的。"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开此插件的选项界面。"

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "启用持久追踪"
L["OPTIONS_TARGET_TRACKING"] = "自动目标追踪"
L["OPTIONS_TARGET_TRACKING_DESC"] = "追踪您选中的目标，使同类的其余成员显示在小地图上。"
L["OPTIONS_TARGET_TRACKING_QUESTING"] = "注意：自动目标追踪非常适合做任务！"

-- Farm Mode

L["TAB_FARM_MODE"] = "采集模式"
L["OPTIONS_ENABLE_FARM"] = "启用采集模式"
L["OPTIONS_FARM_CONDITIONS"] = "采集模式条件"
L["OPTIONS_FARM_MOUNTED"] = "骑乘时"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "旅行和飞行形态"
L["OPTIONS_FARM_CHEETAH"] = "猎豹守护"
L["OPTIONS_FARM_GHOST_WOLF"] = "幽魂之狼"
L["OPTIONS_FARM_NOT_MOUNTED"] = "未骑乘"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "即使没有坐骑或移动形态也会循环。"
L["OPTIONS_FARM_NOTE"] =
	"注意：采集模式仅在您脱离战斗、未施法，且位于城镇、旅店、副本和飞行路线之外时运行。"
L["OPTIONS_FARM_ABILITIES"] = "采集模式技能"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"将您的持久追踪技能加入循环。即使下方已勾选该技能，它也只会出现一次。"
L["OPTIONS_CYCLE_EVERY"] = "每 %s 秒切换"
L["OPTIONS_CYCLE_EVERY_DESC"] = "采集模式在追踪技能之间切换的频率（秒）。"
L["SILENCE_TRACKING_SOUNDS_DESC"] =
	"在采集模式循环时静音施法音效。您自己施放的技能不受影响。"

-- Free Placement Mode

L["PLACEMENT_MODE"] = "自由移动模式"
L["PLACEMENT_DESC"] = "将小地图按钮替换为可随处移动的独立图标。"
L["OPTIONS_ENABLE_FREE"] = "启用自由移动模式"
L["OPTIONS_ICON_SCALE"] = "图标大小"
L["OPTIONS_ICON_SCALE_DESC"] = "使用自由移动模式时追踪图标的大小。"
L["OPTIONS_ICON_SHAPE"] = "图标形状"
L["OPTIONS_ICON_SHAPE_DESC"] = "使用自由移动模式时追踪图标边框的形状。"
L["OPTIONS_SHAPE_CIRCLE"] = "圆形"
L["OPTIONS_SHAPE_SQUARE"] = "方形"

-- Feedback & Support

L["OPTIONS_LINKS"] = "反馈与支持"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
