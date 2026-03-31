local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "koKR")
if not L then return end

L["ADDON_TITLE"]        = "Tracking Eye"

L["TRACKING_MENU"]      = "추적 메뉴"
L["TRACKING_MENU_DESC"] = "추적 능력 목록을 확인하고 지속 추적 능력을 설정합니다."

L["PERSISTENT_ABILITY"] = "지속 추적 능력"
L["NONE_SET"]           = "설정되지 않음"
L["CLEAR_TRACKING"]     = "추적 해제"

L["PERSISTENT_TRACKING"] = "지속적인 추적"
L["PERSISTENT_DESC"]      = "부활 후 추적 주문을 자동으로 다시 시전합니다."

L["FARM_MODE"]    = "파밍 모드"
L["FARMING_DESC"] = "탈것에 탑승하거나 여행 형상일 때 약초, 광석, 보물 사이를 순환합니다."

L["PLACEMENT_MODE"] = "자유 배치 모드"
L["PLACEMENT_DESC"] = "미니맵 버튼을 어디든 이동할 수 있는 독립형 아이콘으로 대체합니다."

L["ENABLED"]  = "활성화됨"
L["DISABLED"] = "비활성화됨"
L["TOGGLE"]   = "전환"

L["LEFT_CLICK"]   = "왼쪽 클릭"
L["RIGHT_CLICK"]  = "오른쪽 클릭"
L["SHIFT_LEFT"]   = "Shift + 왼쪽 클릭"
L["SHIFT_RIGHT"]  = "Shift + 오른쪽 클릭"
L["SHIFT_MIDDLE"] = "Shift + 휠 클릭"

L["TOOLTIP_OPTIONS_HINT"] = "추가 설정은 설정 > 애드온 > Tracking Eye에서 찾을 수 있습니다."

-- Options Panel
L["OPTIONS_DESC"]                = "탈것에 탑승 중 약초와 광석 추적을 자동 순환하고 사망 후 추적 능력을 자동으로 복원하는 스마트 추적 메뉴입니다."
L["OPTIONS_RESET"]               = "모든 설정 초기화"
L["OPTIONS_RESET_HEADER"]        = "초기화"
L["OPTIONS_RESET_CONFIRM"]       = "모든 Tracking Eye 설정을 기본값으로 초기화하시겠습니까?"
L["OPTIONS_ENABLE_PERSISTENT"]   = "지속적인 추적 활성화"
L["OPTIONS_ENABLE_FARM"]         = "파밍 모드 활성화"
L["OPTIONS_ENABLE_FREE"]         = "자유 배치 모드 활성화"
L["OPTIONS_FARM_ABILITIES"]      = "파밍 모드 능력"
L["OPTIONS_FARM_ABILITIES_DESC"] = "탈것에 탑승하거나 여행 형상일 때 파밍 모드가 순환할 추적 능력을 선택합니다."
L["OPTIONS_CYCLE_SPEED"]         = "순환 속도"
L["OPTIONS_CYCLE_SPEED_DESC"]    = "파밍 모드가 추적 능력 사이를 전환하는 빈도입니다(초 단위)."
L["OPTIONS_ICON_SCALE"]          = "아이콘 크기"
L["OPTIONS_ICON_SCALE_DESC"]     = "자유 배치 모드를 사용할 때 추적 아이콘의 크기입니다."
L["OPTIONS_ICON_SHAPE"]          = "아이콘 모양"
L["OPTIONS_ICON_SHAPE_DESC"]     = "자유 배치 모드를 사용할 때 추적 아이콘 테두리의 모양입니다."
L["OPTIONS_SHAPE_CIRCLE"]        = "원형"
L["OPTIONS_SHAPE_SQUARE"]        = "사각형"
L["OPTIONS_LINKS"]               = "피드백 및 지원"
L["OPTIONS_CURSEFORGE"]          = "CurseForge"
L["OPTIONS_DISCORD"]             = "Discord"
L["OPTIONS_GITHUB"]              = "GitHub"
L["OPTIONS_SECONDS"]             = "%.1f초"
L["OPTIONS_PERCENT"]             = "%d%%"