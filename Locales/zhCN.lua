-- zhCN.lua
local _, te = ...
if GetLocale() ~= "zhCN" then return end

local L = te.L

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "追踪菜单"
L["TRACKING_MENU_DESC"] = "查看追踪技能列表，并设置持久追踪能力。"

L["PERSISTENT_ABILITY"] = "持久追踪能力"
L["NONE_SET"]           = "未设置"
L["CLEAR_TRACKING"]     = "清除追踪"

L["PERSISTENT_TRACKING"] = "持久追踪"
L["PERSISTENT_DESC"]      = "复活后自动重新施放追踪法术。"

L["FARM_MODE"]    = "采集模式"
L["FARMING_DESC"] = "在坐骑或旅行形态下，于草药、矿石和宝藏之间循环。"

L["PLACEMENT_MODE"] = "自由移动模式"
L["PLACEMENT_DESC"] = "将小地图按钮替换为可随处移动的独立图标。"

L["ENABLED"]  = "已开启"
L["DISABLED"] = "已关闭"
L["TOGGLE"]   = "切换"

L["LEFT_CLICK"]   = "左键"
L["RIGHT_CLICK"]  = "右键"
L["SHIFT_LEFT"]   = "Shift + 左键"
L["SHIFT_RIGHT"]  = "Shift + 右键"
L["SHIFT_MIDDLE"] = "Shift + 中键"

L["TOOLTIP_OPTIONS_HINT"] = "输入 /te 或在 选项 > 插件 > Tracking Eye 中查看更多选项。"

-- Options Panel
L["OPTIONS_RESET"]               = "重置所有选项"
L["OPTIONS_RESET_HEADER"]        = "重置"
L["OPTIONS_RESET_CONFIRM"]       = "将所有 Tracking Eye 选项重置为默认值？"
L["OPTIONS_ENABLE_PERSISTENT"]   = "启用持久追踪"
L["OPTIONS_ENABLE_FARM"]         = "启用采集模式"
L["OPTIONS_ENABLE_FREE"]         = "启用自由移动模式"
L["OPTIONS_FARM_ABILITIES"]      = "采集模式技能"
L["OPTIONS_FARM_ABILITIES_DESC"] = "选择在坐骑或旅行形态下，采集模式要循环的追踪技能。"
L["OPTIONS_CYCLE_SPEED"]         = "循环速度"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "采集模式在追踪技能之间切换的频率（秒）。"
L["OPTIONS_ICON_SCALE"]          = "图标大小"
L["OPTIONS_ICON_SCALE_DESC"]     = "使用自由移动模式时追踪图标的缩放比例。"
L["OPTIONS_ICON_SHAPE"]          = "图标形状"
L["OPTIONS_ICON_SHAPE_DESC"]     = "使用自由移动模式时追踪图标边框的形状。"
L["OPTIONS_SHAPE_CIRCLE"]        = "圆形"
L["OPTIONS_SHAPE_SQUARE"]        = "方形"
L["OPTIONS_LINKS"]               = "反馈与支持"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_SECONDS"]             = "%.1f 秒"
L["OPTIONS_PERCENT"]             = "%d%%"