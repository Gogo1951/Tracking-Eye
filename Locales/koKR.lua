local L = LibStub("AceLocale-3.0"):NewLocale("TrackingEye", "koKR")
if not L then
	return
end

L["ADDON_TITLE"] = "Tracking Eye"

--------------------------------------------------------------------------------
-- Printed Messages
--------------------------------------------------------------------------------

L["CHAT_LOADED"] =
	"버전 %s. 설정(이 메시지를 비활성화하는 옵션 포함)은 설정 > 애드온 > Tracking Eye에서 찾을 수 있습니다. 애드온이 마음에 드시나요? 친구에게 알려주세요! (="
L["CHAT_OPTIONS_IN_COMBAT"] = "안전을 위해 전투 중에는 옵션 인터페이스를 열 수 없습니다."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

L["TRACKING_MENU"] = "추적 메뉴"
L["TRACKING_MENU_DESC"] = "추적 능력 목록을 표시하고 지속 추적 능력을 설정할 수 있습니다."
L["PERSISTENT_TRACKING"] = "지속적인 추적"
L["PERSISTENT_DESC"] = "부활 및 변신 후 추적 능력을 자동으로 다시 시전합니다."
L["FARM_MODE"] = "파밍 모드"
L["FARM_MODE_DESC"] = "이동 중일 때 선택한 추적 능력 사이를 순환합니다."

--------------------------------------------------------------------------------
-- Minimap Button Tooltip
--------------------------------------------------------------------------------

L["FARM_STATUS"] = "파밍 모드 상태"
L["FARM_STATUS_ACTIVE"] = "활성"
L["FARM_STATUS_PAUSED"] = "일시 중지"

L["FARM_PAUSED_DEAD"] = "사망 상태입니다."
L["FARM_PAUSED_TAXI"] = "비행 경로 이용 중입니다."
L["FARM_PAUSED_INSTANCE"] = "인스턴스 내부입니다."
L["FARM_PAUSED_RESTING"] = "마을 또는 여관에 있습니다."
L["FARM_PAUSED_NO_ABILITIES"] = "선택된 추적 능력이 없습니다."
L["FARM_PAUSED_NO_STATES"] = "활성화된 파밍 모드 조건이 없습니다."
L["FARM_PAUSED_NOT_MOUNTED"] = "탈것에 타고 있지 않습니다."
L["FARM_PAUSED_NOT_TRAVEL"] = "여행 변신 상태가 아닙니다."
L["FARM_PAUSED_NOT_CHEETAH"] = "치타의 상을 사용하고 있지 않습니다."
L["FARM_PAUSED_NOT_GHOST_WOLF"] = "늑대 정령을 사용하고 있지 않습니다."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "탈것에 타고 있지 않고 여행 변신 상태도 아닙니다."
L["FARM_PAUSED_NOT_MOUNTED_CHEETAH"] =
	"탈것에 타고 있지 않고 치타의 상도 사용하고 있지 않습니다."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF"] =
	"탈것에 타고 있지 않고 늑대 정령도 사용하고 있지 않습니다."
L["FARM_PAUSED_MOUNTED_OFF"] = "파밍 모드가 탈것 탑승 중 실행되도록 설정되어 있지 않습니다."
L["FARM_PAUSED_TRAVEL_OFF"] = "파밍 모드가 여행 변신 중 실행되도록 설정되어 있지 않습니다."
L["FARM_PAUSED_CHEETAH_OFF"] =
	"파밍 모드가 치타의 상 사용 중 실행되도록 설정되어 있지 않습니다."
L["FARM_PAUSED_GHOST_WOLF_OFF"] =
	"파밍 모드가 늑대 정령 사용 중 실행되도록 설정되어 있지 않습니다."
L["FARM_PAUSED_COMBAT"] = "전투 중입니다."
L["FARM_PAUSED_CASTING"] = "시전 중입니다."
L["FARM_PAUSED_STEALTHED"] = "은신 중입니다."
L["FARM_PAUSED_LOOTING"] = "전리품 창이 열려 있습니다."
L["FARM_PAUSED_CURSOR"] = "커서에 무언가 들려 있습니다."
L["FARM_PAUSED_OPTIONS"] = "옵션 인터페이스가 열려 있습니다."
L["FARM_PAUSED_WINDOW"] = "창이 열려 있습니다."
L["FARM_PAUSED_TOOLTIP"] = "툴팁을 읽는 중입니다."

L["PERSISTENT_ABILITY"] = "지속 추적 능력"
L["SILENCE_TRACKING_SOUNDS"] = "추적 소리 음소거"
L["NONE_SET"] = "설정되지 않음"
L["CLEAR_TRACKING"] = "추적 해제"

L["ENABLED"] = "활성화됨"
L["DISABLED"] = "비활성화됨"
L["TOGGLE"] = "전환"

L["OPEN"] = "열기"
L["LEFT_CLICK"] = "왼쪽 클릭"
L["RIGHT_CLICK"] = "오른쪽 클릭"
L["SHIFT_LEFT"] = "Shift + 왼쪽 클릭"
L["SHIFT_RIGHT"] = "Shift + 오른쪽 클릭"
L["SHIFT_MIDDLE"] = "Shift + 휠 클릭"

L["TOOLTIP_OPTIONS"] = "Tracking Eye 옵션"

--------------------------------------------------------------------------------
-- Key Bindings
--------------------------------------------------------------------------------

L["BINDING_CYCLE_FARM_ABILITY"] = "파밍 모드 능력 전환"
L["BINDING_NOTHING_TO_CYCLE"] =
	"파밍 모드에 선택된 추적 능력이 없습니다. 설정 > 애드온 > Tracking Eye에서 선택하세요."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

-- General

L["OPTIONS_DESC"] =
	"개선된 추적 메뉴와 자동 추적 전환기로, 파밍 중에 약초 찾기와 광물 찾기를 순환하고 사망 후 추적을 다시 적용합니다. 모든 추적 능력을 지원합니다. 사냥 중인 자원을 절대 놓치지 마세요."
L["OPTIONS_ENABLE_WELCOME"] = "환영 메시지 활성화"
L["OPTIONS_WELCOME_DESC"] = "Tracking Eye가 로드될 때 대화창에 한 줄 인사말을 출력합니다."
L["OPTIONS_ENABLE_MINIMAP"] = "미니맵 버튼 활성화"
L["OPTIONS_ENABLE_MINIMAP_DESC"] =
	"미니맵에 Tracking Eye 버튼을 표시합니다. 숨겨져 있을 때도 파밍 모드와 지속적인 추적은 계속 실행됩니다."
L["OPTIONS_HOOK_BLIZZARD"] = "기본 추적 버튼 사용"
L["OPTIONS_HOOK_BLIZZARD_NOTE"] =
	"이 옵션이 켜져 있으면 블리자드의 추적 아이콘이 Tracking Eye 메뉴를 열며, 추적 대상만 변경합니다. 나머지 설정은 모두 옵션 인터페이스에 그대로 남아 있습니다."
L["OPTIONS_HOOK_BLIZZARD_DESC"] =
	"미니맵의 블리자드 추적 아이콘을 클릭하면 추적 메뉴를 엽니다. 다른 애드온이 이미 해당 버튼을 사용 중이라면 꺼 두십시오."
L["OPTIONS_KEYBINDS"] = "단축키"
L["OPTIONS_KEYBINDS_DESC"] =
	"원할 때 파밍 모드를 다음 능력으로 넘깁니다. 게임 메뉴의 단축키 설정에서 Tracking Eye 항목을 통해 지정하세요."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMANDS_INTRO"] =
	"Tracking Eye 슬래시 명령어. 옵션 인터페이스에 필요한 모든 것이 있습니다. 키보드 사용을 선호하는 분들을 위한 명령어입니다."
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 옵션 인터페이스를 엽니다."

-- Persistent Tracking

L["OPTIONS_ENABLE_PERSISTENT"] = "지속적인 추적 활성화"
L["OPTIONS_TARGET_TRACKING"] = "자동 대상 추적"
L["OPTIONS_TARGET_TRACKING_DESC"] =
	"대상으로 지정한 것을 추적하여 같은 종류의 나머지가 미니맵에 표시됩니다."
L["OPTIONS_TARGET_TRACKING_QUESTING"] =
	"참고: 자동 대상 추적은 퀘스트를 진행할 때 아주 유용합니다!"

-- Farm Mode

L["TAB_FARM_MODE"] = "파밍 모드"
L["OPTIONS_ENABLE_FARM"] = "파밍 모드 활성화"
L["OPTIONS_FARM_CONDITIONS"] = "파밍 모드 조건"
L["OPTIONS_FARM_MOUNTED"] = "탈것 탑승"
L["OPTIONS_FARM_TRAVEL_FORMS"] = "여행 및 비행 변신"
L["OPTIONS_FARM_CHEETAH"] = "치타의 상"
L["OPTIONS_FARM_GHOST_WOLF"] = "늑대 정령"
L["OPTIONS_FARM_NOT_MOUNTED"] = "탈것 미탑승"
L["OPTIONS_FARM_NOT_MOUNTED_DESC"] = "탈것이나 이동 변신 상태가 아니어도 순환합니다."
L["OPTIONS_FARM_NOTE"] =
	"참고: 파밍 모드는 전투 중이 아니고, 주문을 시전하지 않으며, 마을, 여관, 인스턴스, 비행 경로 외부에 있을 때만 실행됩니다."
L["OPTIONS_FARM_ABILITIES"] = "파밍 모드 능력"
L["OPTIONS_FARM_PERSISTENT_DESC"] =
	"지속 추적 능력을 순환에 포함합니다. 아래에서 이미 선택되어 있더라도 한 번만 등장합니다."
L["OPTIONS_CYCLE_EVERY"] = "%s초마다 전환"
L["OPTIONS_CYCLE_EVERY_DESC"] = "파밍 모드가 추적 능력 사이를 전환하는 빈도입니다(초 단위)."
L["SILENCE_TRACKING_SOUNDS_DESC"] =
	"파밍 모드가 순환할 때 나는 시전 소리를 음소거합니다. 직접 시전한 주문은 영향을 받지 않습니다."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "자유 배치 모드"
L["PLACEMENT_DESC"] = "미니맵 버튼을 어디든 이동할 수 있는 독립형 아이콘으로 대체합니다."
L["OPTIONS_ENABLE_FREE"] = "자유 배치 모드 활성화"
L["OPTIONS_ICON_SCALE"] = "아이콘 크기"
L["OPTIONS_ICON_SCALE_DESC"] = "자유 배치 모드를 사용할 때 추적 아이콘의 크기입니다."
L["OPTIONS_ICON_SHAPE"] = "아이콘 모양"
L["OPTIONS_ICON_SHAPE_DESC"] = "자유 배치 모드를 사용할 때 추적 아이콘 테두리의 모양입니다."
L["OPTIONS_SHAPE_CIRCLE"] = "원형"
L["OPTIONS_SHAPE_SQUARE"] = "사각형"

-- Feedback & Support

L["OPTIONS_LINKS"] = "피드백 및 지원"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_WAGO"] = "Wago"
