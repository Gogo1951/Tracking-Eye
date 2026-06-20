local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "koKR")
if not L then return end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] = "버전 %s. 설정(이 메시지를 비활성화하는 옵션 포함)은 설정 > 애드온 > Tracking Eye에서 찾을 수 있습니다. 애드온이 마음에 드시나요? 친구에게 알려주세요! (="

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "추적 메뉴"
L["TRACKING_MENU_DESC"] = "추적 능력 목록을 확인하고 지속 추적 능력을 설정합니다."

L["PERSISTENT_ABILITY"] = "지속 추적 능력"
L["NONE_SET"] = "설정되지 않음"
L["CLEAR_TRACKING"] = "추적 해제"

L["PERSISTENT_TRACKING"] = "지속적인 추적"
L["PERSISTENT_DESC"] = "부활 및 태세/변신 후 추적 주문을 자동으로 다시 시전합니다."

L["FARM_MODE"] = "파밍 모드"
L["FARM_MODE_DESC"] = "이동 중일 때 선택한 추적 능력 사이를 순환합니다."

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

L["TOOLTIP_OPTIONS_HINT"] = "추가 설정은 설정 > 애드온 > Tracking Eye에서 찾을 수 있습니다."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] = "개선된 추적 메뉴와 자동 추적 전환기로, 파밍 중에 약초 찾기와 광물 찾기를 순환하고 사망 후 추적을 다시 적용합니다. 모든 추적 능력을 지원합니다. 사냥 중인 자원을 절대 놓치지 마세요."
L["OPTIONS_ENABLE_WELCOME"] = "환영 메시지 활성화"
L["OPTIONS_WELCOME_DESC"] = "Tracking Eye가 로드될 때 대화창에 한 줄 인사말을 출력합니다."
L["OPTIONS_ENABLE_MINIMAP"] = "미니맵 버튼 활성화"
L["OPTIONS_ENABLE_MINIMAP_DESC"] = "미니맵에 Tracking Eye 버튼을 표시합니다. 숨겨져 있을 때도 파밍 모드와 지속적인 추적은 계속 실행됩니다."

-- Slash Commands

L["OPTIONS_COMMANDS_INTRO"] = "Tracking Eye 슬래시 명령어. 옵션 패널에 필요한 모든 것이 있습니다. 키보드 사용을 선호하는 분들을 위한 명령어입니다."
L["OPTIONS_COMMAND_TE"] = "Tracking Eye 옵션 인터페이스를 엽니다."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "지속적인 추적 활성화"

-- Farm Mode

L["OPTIONS_ENABLE_FARM"] = "파밍 모드 활성화"
L["OPTIONS_FARM_ACTIVATE"] = "다음 상태일 때 파밍 모드 활성화:"
L["OPTIONS_FARM_MOUNTED"] = "탈것 탑승"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "여행 및 비행 변신"
L["OPTIONS_FARM_CHEETAH"] = "치타의 상"
L["OPTIONS_FARM_GHOST_WOLF"] = "늑대 정령"
L["OPTIONS_FARM_NOT_MOUNTED"] = "탈것 미탑승"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "탈것이나 이동 변신 상태가 아니어도 순환합니다."
L["OPTIONS_FARM_NOTE"] = "참고: 파밍 모드는 전투 중이 아니고, 주문을 시전하지 않으며, 마을, 여관, 인스턴스 외부에 있을 때만 실행됩니다."
L["OPTIONS_FARM_ABILITIES"] = "파밍 모드 능력"
L["OPTIONS_CYCLE_SPEED"] = "순환 속도"
L["OPTIONS_CYCLE_SPEED_DESC"] = "파밍 모드가 추적 능력 사이를 전환하는 빈도입니다(초 단위)."

-- Free Placement Mode

L["OPTIONS_ENABLE_FREE"] = "자유 배치 모드 활성화"
L["OPTIONS_ICON_SCALE"] = "아이콘 크기"
L["OPTIONS_ICON_SCALE_DESC"] = "자유 배치 모드를 사용할 때 추적 아이콘의 크기입니다."
L["OPTIONS_ICON_SHAPE"] = "아이콘 모양"
L["OPTIONS_ICON_SHAPE_DESC"] = "자유 배치 모드를 사용할 때 추적 아이콘 테두리의 모양입니다."
L["OPTIONS_SHAPE_CIRCLE"] = "원형"
L["OPTIONS_SHAPE_SQUARE"] = "사각형"

-- Reset

L["OPTIONS_RESET_HEADER"] = "초기화"
L["OPTIONS_RESET_DESC"] = "모든 Tracking Eye 설정을 기본값으로 복원합니다."
L["OPTIONS_RESET"] = "모든 설정 초기화"
L["OPTIONS_RESET_CONFIRM"] = "모든 Tracking Eye 설정을 기본값으로 초기화하시겠습니까?"

-- Feedback & Support

L["OPTIONS_LINKS"] = "피드백 및 지원"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"