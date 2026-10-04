local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "zhCN")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"版本 %s。设置（包含禁用此消息的选项）可以在 设置选项 > 插件 > Tracking Eye 中找到。喜欢这个插件？告诉您的朋友吧！(="
L["CHAT_OPTIONS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开选项界面。"
L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开快捷键列表。"
L["KEY_BINDINGS_LOCATION"] = "打开游戏菜单，点击%s，再点击%s，然后找到 Tracking Eye 分类。"

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "追踪菜单"
L["TRACKING_MENU_DESCRIPTION"] = "选择您的持久追踪技能。"
L["PERSISTENT_TRACKING"] = "持久追踪"
L["TARGET_TRACKING"] = "自动目标追踪"
L["TARGET_TRACKING_DESCRIPTION"] = "追踪您所选目标的同类生物。"
L["FARM_MODE"] = "采集模式"
L["FARM_MODE_DESCRIPTION"] = "在旅途中循环切换您的追踪技能。"

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
L["FARM_PAUSED_NO_ABILITIES"] = "未勾选任何采集模式技能。"
L["FARM_PAUSED_NOT_LEARNED"] = "您尚未学会任何已勾选的采集模式技能。"
L["FARM_PAUSED_CAT_FORM_NAMED"] = "%s追踪只在%s下循环。"
L["FARM_PAUSED_NO_STATES"] = "未开启任何采集模式条件。"
L["FARM_PAUSED_NOT_MOUNTED"] = "未骑乘。"
L["FARM_PAUSED_NOT_TRAVEL"] = "未处于旅行类形态。"
L["FARM_PAUSED_NOT_ASPECT_NAMED"] = "未使用%s。"
L["FARM_PAUSED_NOT_GHOST_WOLF_NAMED"] = "未处于%s形态。"
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "未骑乘，也未处于旅行类形态。"
L["FARM_PAUSED_NOT_MOUNTED_ASPECT_NAMED"] = "未骑乘，也未使用%s。"
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF_NAMED"] = "未骑乘，也未处于%s形态。"
L["FARM_PAUSED_MOUNTED_OFF"] = "采集模式未设置为在骑乘时运行。"
L["FARM_PAUSED_TRAVEL_OFF"] = "采集模式未设置为在旅行类形态下运行。"
L["FARM_PAUSED_ASPECT_OFF_NAMED"] = "采集模式未设置为在%s下运行。"
L["FARM_PAUSED_GHOST_WOLF_OFF_NAMED"] = "采集模式未设置为在%s形态下运行。"
L["FARM_PAUSED_COMBAT"] = "正在战斗中。"
L["FARM_PAUSED_CASTING"] = "正在施法。"
L["FARM_PAUSED_STEALTHED"] = "处于潜行状态。"
L["FARM_PAUSED_LOOTING"] = "拾取窗口已打开。"
L["FARM_PAUSED_CURSOR"] = "光标上有东西。"
L["FARM_PAUSED_OPTIONS"] = "选项界面已打开。"
L["FARM_PAUSED_WINDOW"] = "有窗口已打开。"
L["FARM_PAUSED_TOOLTIP"] = "正在查看提示信息。"
L["FARM_PAUSED_TARGET"] = "正以可攻击的单位为目标。"
L["FARM_PAUSED_STANDING_STILL"] = "正站着不动。"

L["PERSISTENT_ABILITY"] = "持久追踪技能"
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
	"未勾选任何采集模式技能。请在 设置选项 > 插件 > Tracking Eye > 采集模式 中勾选。"

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- General

L["OPTIONS_DESCRIPTION"] =
	"改进的追踪菜单和自动追踪切换器，在采集时循环寻找草药和寻找矿物，在死亡后恢复追踪，并在做任务时追踪您所选目标的同类生物。支持所有追踪技能。再也不会跟丢您要找的目标。"
L["OPTIONS_ENABLE_WELCOME"] = "启用欢迎消息"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] = "Tracking Eye 加载时在聊天中显示一行欢迎语。"
L["OPTIONS_ENABLE_MINIMAP"] = "启用小地图按钮"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "隐藏按钮后，所有功能照常运行。"

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开此插件的选项界面。"

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "快捷键"
L["OPTIONS_KEY_SET"] = "设置按键"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "打开游戏的快捷键列表，Tracking Eye 在其中有专属分类。"
L["OPTIONS_KEYBINDS_DESCRIPTION"] = "一键跳到下一个追踪技能，即使采集模式已关闭也能使用。"

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"您掌握的所有追踪技能，汇集在一个按名称排序的菜单中。选中的技能将成为您的持久追踪技能。"
L["OPTIONS_HOOK_BLIZZARD"] = "使用默认追踪按钮"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"默认追踪按钮也会打开此菜单。如果其他插件已在使用该按钮，请保持关闭。"

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"再也不会丢失追踪：死亡、变形或切换区域后，它都会立即恢复。"
L["OPTIONS_ENABLE_PERSISTENT"] = "启用持久追踪"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"会等到您脱离战斗再施放，绝不会在战斗中占用公共冷却时间。"
L["OPTIONS_FISHING_POLE_FISH_NAMED"] = "%s（装备%s时）"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "收起鱼竿后，您自己选择的追踪会恢复。"
L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"] = "%s：%s（变为%s时）"
L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"] =
	"会等到您脱离潜行，离开该形态后您自己选择的追踪会恢复。"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"] = "%s：在战场中%s"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] =
	"竞技场也算在内，离开后您自己选择的追踪会恢复。"

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"选中一个生物，小地图上就会亮起它的所有同类。非常适合做任务！"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "启用自动目标追踪"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"战斗中绝不切换，增援的怪物抢不走您的追踪。拾取尸体也不会触发切换。"

-- Free Placement Mode

L["PLACEMENT_MODE"] = "自由移动模式"
L["OPTIONS_PLACEMENT_DESCRIPTION"] = "小地图太拥挤？把追踪图标拖出来，放在屏幕上任意位置。"
L["OPTIONS_ENABLE_FREE"] = "启用自由移动模式"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"它的位置由您的所有角色共用，重载界面或调整界面缩放后也会保持不变。"
L["OPTIONS_ICON_SHAPE"] = "图标形状"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] = "圆形与小地图相配；方形可以整齐地放在动作条旁边。"
L["OPTIONS_SHAPE_CIRCLE"] = "圆形"
L["OPTIONS_SHAPE_SQUARE"] = "方形"
L["OPTIONS_ICON_SCALE"] = "图标大小"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] = "原地缩放，图标会保持在原来的位置。"

-- Feedback & Support

L["OPTIONS_LINKS"] = "反馈与支持"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "版本 %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "采集模式"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"草药和矿石尽在同一张小地图上。采集模式会在您旅行时轮换追踪技能，不放过任何一个采集点。"
L["OPTIONS_ENABLE_FARM"] = "启用采集模式"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"在战斗中、城镇里、副本内和飞行途中会自动暂停。将鼠标悬停在 Tracking Eye 按钮上即可查看原因。"
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "静音追踪技能的施法音效"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"只有采集模式自己的切换会静音。您亲自选择的追踪仍会发出声音。"
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "缩小小地图"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] = "小地图缩到最小后，能显示远得多的已追踪资源点。"
L["OPTIONS_FARM_CONDITIONS"] = "采集模式条件"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"随心采集：骑乘、步行或使用本职业的旅行形态皆可。采集模式会在您勾选的任一状态下循环。"
L["OPTIONS_FARM_MOUNTED"] = "骑乘时"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] = "在采集点下马后，循环会等您采集完毕。"
L["OPTIONS_FARM_NOT_MOUNTED"] = "未骑乘"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] = "停下来采集或进食时，循环会等您继续前进。"
L["OPTIONS_FARM_TRAVEL_FORMS_NAMED"] = "%s：旅行类形态"
L["OPTIONS_FARM_TRAVEL_FORMS_ONE_DESCRIPTION"] = "%s也算在内。"
L["OPTIONS_FARM_TRAVEL_FORMS_TWO_DESCRIPTION"] = "%s和%s也算在内。"
L["OPTIONS_FARM_CLASS_STATE"] = "%s：%s"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "只在您移动时循环，和其他条件一样。"
L["OPTIONS_FARM_PACK_GROUP_DESCRIPTION"] = "适合组队跑图采集，全队都能跟上您的速度。"
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "获得第一匹坐骑之前跑图采集的好帮手。"
L["OPTIONS_CYCLE_SPEED"] = "循环速度"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"每次切换都会占用一次公共冷却时间，因此循环越慢，越少干扰您自己的施法。"
L["OPTIONS_CYCLE_EVERY"] = "每 %s 秒切换"
L["OPTIONS_FARM_ABILITIES"] = "采集模式技能"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"勾选您想找的东西。采集模式会循环此角色已掌握的所有勾选技能，并跳过其余技能。"
L["OPTIONS_FARM_GROUP_GENERAL"] = "专业与种族特长"
L["OPTIONS_FARM_CAT_FORM_NOTE_NAMED"] = "只在%s下循环，该形态算作未骑乘。"
L["OPTIONS_FARM_PERSISTENT"] = "包含持久追踪技能"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"即使下方也已勾选，它也绝不会出现两次。自动目标追踪会用追踪您目标同类的技能替代它。"

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

L["MATCH_HERB"] = "草药学"
L["MATCH_MINE"] = "采矿"

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

L["MSG_FORMAT_LOCKED"] = "潜行者们！%s，坐标 %s, %s（%s）。"
L["MSG_FORMAT_HERB"] = "草药师们！%s，坐标 %s, %s（%s）。"
L["MSG_FORMAT_MINE"] = "矿工们！%s，坐标 %s, %s（%s）。"

L["CHAT_TOO_LONG"] = "此草稿为 %d 字节，超过了 %d 字节的聊天上限。请在发送前缩短。"

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"发现了采不了的草药、挖不了的矿脉，或是一个上了锁的宝箱，附近却没有潜行者？右键点击它，Come & Get It 就会生成一条消息，供您分享或广播坐标。当英雄从未如此轻松。"
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "启用 Come & Get It"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"在战斗中和副本内保持安静，聊天框绝不会在战斗中抢走您的键盘输入。"
L["OPTIONS_OUTPUT_NAME"] = "默认输出"
L["OPTIONS_OUTPUT_DESCRIPTION"] =
	"公会频道会送达所有在线的公会成员，无论其位于哪个位面或区域。"
L["OPTIONS_OUTPUT_NOTE"] = "注意：本地 (/1) 只能送达与您处于同一位面的玩家。"
L["OPTIONS_OUTPUT_CHANNEL1"] = "本地 (/1)"
