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
L["CHAT_KEY_BINDINGS_IN_COMBAT"] = "안전을 위해 전투 중에는 단축키 목록을 열 수 없습니다."
L["KEY_BINDINGS_LOCATION"] =
	"게임 메뉴를 연 다음 %s, %s 순서로 이동해 Tracking Eye 항목을 찾으세요."

--------------------------------------------------------------------------------
-- Feature Names & Descriptions
--------------------------------------------------------------------------------

-- The descriptions show in the mini-map tooltip: bare bones, two lines at most.

L["TRACKING_MENU"] = "추적 메뉴"
L["TRACKING_MENU_DESCRIPTION"] = "지속 추적 능력을 선택하세요."
L["PERSISTENT_TRACKING"] = "지속 추적"
L["TARGET_TRACKING"] = "자동 대상 추적"
L["TARGET_TRACKING_DESCRIPTION"] = "대상으로 지정한 생물과 같은 종류를 추적합니다."
L["FARM_MODE"] = "파밍 모드"
L["FARM_MODE_DESCRIPTION"] = "이동하는 동안 추적 능력을 순환합니다."

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
L["FARM_PAUSED_NO_ABILITIES"] = "체크된 파밍 모드 능력이 없습니다."
L["FARM_PAUSED_NOT_LEARNED"] = "체크한 파밍 모드 능력을 하나도 배우지 않았습니다."
L["FARM_PAUSED_CAT_FORM_NAMED"] = "%s 추적은 %s 상태에서만 순환합니다."
L["FARM_PAUSED_NO_STATES"] = "켜져 있는 파밍 모드 조건이 없습니다."
L["FARM_PAUSED_NOT_MOUNTED"] = "탈것에 타고 있지 않습니다."
L["FARM_PAUSED_NOT_TRAVEL"] = "여행 변신 상태가 아닙니다."
L["FARM_PAUSED_NOT_ASPECT_NAMED"] = "%s 사용 중이 아닙니다."
L["FARM_PAUSED_NOT_GHOST_WOLF_NAMED"] = "%s 상태가 아닙니다."
L["FARM_PAUSED_NOT_MOUNTED_TRAVEL"] = "탈것에 타고 있지 않고 여행 변신 상태도 아닙니다."
L["FARM_PAUSED_NOT_MOUNTED_ASPECT_NAMED"] = "탈것에 타고 있지 않고 %s 사용 중도 아닙니다."
L["FARM_PAUSED_NOT_MOUNTED_GHOST_WOLF_NAMED"] = "탈것에 타고 있지 않고 %s 상태도 아닙니다."
L["FARM_PAUSED_MOUNTED_OFF"] = "파밍 모드가 탈것 탑승 중에 실행되도록 설정되어 있지 않습니다."
L["FARM_PAUSED_TRAVEL_OFF"] = "파밍 모드가 여행 변신 중에 실행되도록 설정되어 있지 않습니다."
L["FARM_PAUSED_ASPECT_OFF_NAMED"] =
	"파밍 모드가 %s 사용 중에 실행되도록 설정되어 있지 않습니다."
L["FARM_PAUSED_GHOST_WOLF_OFF_NAMED"] =
	"파밍 모드가 %s 상태에서 실행되도록 설정되어 있지 않습니다."
L["FARM_PAUSED_COMBAT"] = "전투 중입니다."
L["FARM_PAUSED_CASTING"] = "시전 중입니다."
L["FARM_PAUSED_STEALTHED"] = "은신 중입니다."
L["FARM_PAUSED_LOOTING"] = "전리품 창이 열려 있습니다."
L["FARM_PAUSED_CURSOR"] = "커서에 무언가 들려 있습니다."
L["FARM_PAUSED_OPTIONS"] = "옵션 인터페이스가 열려 있습니다."
L["FARM_PAUSED_WINDOW"] = "창이 열려 있습니다."
L["FARM_PAUSED_TOOLTIP"] = "툴팁을 읽는 중입니다."
L["FARM_PAUSED_TARGET"] = "공격할 수 있는 대상을 선택하고 있습니다."
L["FARM_PAUSED_STANDING_STILL"] = "멈춰 서 있습니다."

L["PERSISTENT_ABILITY"] = "지속 추적 능력"
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
	"체크된 파밍 모드 능력이 없습니다. 설정 > 애드온 > Tracking Eye > 파밍 모드에서 체크하세요."

--------------------------------------------------------------------------------
-- Options Interface
--------------------------------------------------------------------------------

--[[
    Each section's description sells the feature. Each control's description is
    its mouseover tooltip: a pro tip the label and section don't already say.
]]

-- General

L["OPTIONS_DESCRIPTION"] =
	"개선된 추적 메뉴와 자동 추적 전환기로, 파밍 중에는 약초 찾기와 광물 찾기를 순환하고, 사망 후에는 추적을 다시 적용하며, 퀘스트 중에는 대상으로 지정한 생물을 추적합니다. 모든 추적 능력을 지원합니다. 쫓고 있는 대상을 절대 놓치지 마세요."
L["OPTIONS_ENABLE_WELCOME"] = "환영 메시지 활성화"
L["OPTIONS_ENABLE_WELCOME_DESCRIPTION"] =
	"Tracking Eye가 로드될 때 대화창에 한 줄짜리 인사말을 출력합니다."
L["OPTIONS_ENABLE_MINIMAP"] = "미니맵 버튼 활성화"
L["OPTIONS_ENABLE_MINIMAP_DESCRIPTION"] = "버튼을 숨겨도 모든 기능이 계속 작동합니다."

-- Slash Commands

L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/te"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 옵션 인터페이스를 엽니다."

-- Key Bindings

L["OPTIONS_KEYBINDS"] = "단축키 설정"
L["OPTIONS_KEY_SET"] = "단축키 지정"
L["OPTIONS_KEY_SET_DESCRIPTION"] = "Tracking Eye 전용 항목이 있는 게임 단축키 목록을 엽니다."
L["OPTIONS_KEYBINDS_DESCRIPTION"] =
	"키 하나로 다음 추적 능력으로 넘어갑니다. 파밍 모드가 꺼져 있어도 작동합니다."

-- Tracking Menu

L["OPTIONS_TRACKING_MENU_DESCRIPTION"] =
	"알고 있는 모든 추적 능력을 가나다순 메뉴 하나에 모았습니다. 여기서 고른 능력이 지속 추적 능력이 됩니다."
L["OPTIONS_HOOK_BLIZZARD"] = "기본 추적 버튼 사용"
L["OPTIONS_HOOK_BLIZZARD_DESCRIPTION"] =
	"기본 추적 버튼으로도 이 메뉴가 열립니다. 다른 애드온이 이미 그 버튼을 사용 중이라면 꺼 두세요."

-- Persistent Tracking

L["OPTIONS_PERSISTENT_DESCRIPTION"] =
	"다시는 추적을 잃지 마세요. 죽거나, 변신하거나, 지역을 이동해도 곧바로 돌아옵니다."
L["OPTIONS_ENABLE_PERSISTENT"] = "지속 추적 활성화"
L["OPTIONS_ENABLE_PERSISTENT_DESCRIPTION"] =
	"전투에서 벗어날 때까지 기다리므로 전투 중에 전역 재사용 대기시간을 쓰는 일이 없습니다."
L["OPTIONS_FISHING_POLE_FISH_NAMED"] = "%s (%s 장착 시)"
L["OPTIONS_FISHING_POLE_FISH_DESCRIPTION"] = "낚싯대를 해제하면 직접 고른 추적이 돌아옵니다."
L["OPTIONS_CAT_FORM_HUMANOIDS_NAMED"] = "%s: %s (%s 시)"
L["OPTIONS_CAT_FORM_HUMANOIDS_STEALTH_DESCRIPTION"] =
	"은신이 끝날 때까지 기다리며, 변신을 풀면 직접 고른 추적이 돌아옵니다."
L["OPTIONS_BATTLEGROUND_HUMANOIDS_NAMED"] = "%s: 전장에서 %s"
L["OPTIONS_BATTLEGROUND_HUMANOIDS_DESCRIPTION"] =
	"투기장도 포함되며, 나가면 직접 고른 추적이 돌아옵니다."

-- Automatic Target Tracking

L["OPTIONS_TARGET_TRACKING_DESCRIPTION"] =
	"생물을 대상으로 지정하면 같은 종류가 모두 미니맵에 표시됩니다. 퀘스트할 때 아주 좋습니다!"
L["OPTIONS_ENABLE_TARGET_TRACKING"] = "자동 대상 추적 활성화"
L["OPTIONS_ENABLE_TARGET_TRACKING_DESCRIPTION"] =
	"전투 중에는 전환되지 않으므로 몰려든 적 때문에 추적이 바뀌지 않습니다. 시체에서 전리품을 챙겨도 전환되지 않습니다."

-- Free Placement Mode

L["PLACEMENT_MODE"] = "자유 배치 모드"
L["OPTIONS_PLACEMENT_DESCRIPTION"] =
	"미니맵이 복잡한가요? 추적 아이콘을 떼어 내 화면 어디에든 두세요."
L["OPTIONS_ENABLE_FREE"] = "자유 배치 모드 활성화"
L["OPTIONS_ENABLE_FREE_DESCRIPTION"] =
	"아이콘 위치는 모든 캐릭터가 공유하며, UI를 다시 불러오거나 UI 크기를 바꿔도 유지됩니다."
L["OPTIONS_ICON_SHAPE"] = "아이콘 모양"
L["OPTIONS_ICON_SHAPE_DESCRIPTION"] =
	"원형은 미니맵과 어울리고, 사각형은 행동 단축바 옆에 깔끔하게 놓입니다."
L["OPTIONS_SHAPE_CIRCLE"] = "원형"
L["OPTIONS_SHAPE_SQUARE"] = "사각형"
L["OPTIONS_ICON_SCALE"] = "아이콘 크기"
L["OPTIONS_ICON_SCALE_DESCRIPTION"] =
	"제자리에서 크기가 바뀌므로 아이콘 위치가 그대로 유지됩니다."

-- Feedback & Support

L["OPTIONS_LINKS"] = "피드백 및 지원"
L["OPTIONS_DISCORD"] = "Discord"
L["OPTIONS_GITHUB"] = "GitHub"
L["OPTIONS_CURSEFORGE"] = "CurseForge"
L["OPTIONS_WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "버전 %s"

-- Farm Mode

L["TAB_FARM_MODE"] = "파밍 모드"
L["OPTIONS_FARM_MODE_DESCRIPTION"] =
	"약초와 광석을 한 미니맵에서. 파밍 모드가 이동 중에 추적 능력을 번갈아 켜 주니 채집물을 하나도 놓치지 않습니다."
L["OPTIONS_ENABLE_FARM"] = "파밍 모드 활성화"
L["OPTIONS_ENABLE_FARM_DESCRIPTION"] =
	"전투 중이나 마을, 인스턴스, 비행 중에는 알아서 일시 중지됩니다. Tracking Eye 버튼에 마우스를 올리면 이유를 볼 수 있습니다."
L["OPTIONS_SILENCE_TRACKING_SOUNDS"] = "추적 능력 시전 소리 끄기"
L["OPTIONS_SILENCE_TRACKING_SOUNDS_DESCRIPTION"] =
	"파밍 모드의 전환만 조용해집니다. 직접 고른 추적은 여전히 소리가 납니다."
L["OPTIONS_ZOOM_MINIMAP_OUT"] = "미니맵 축소"
L["OPTIONS_ZOOM_MINIMAP_OUT_DESCRIPTION"] =
	"미니맵을 끝까지 축소하면 훨씬 먼 곳의 추적 대상도 표시됩니다."
L["OPTIONS_FARM_CONDITIONS"] = "파밍 모드 조건"
L["OPTIONS_FARM_CONDITIONS_DESCRIPTION"] =
	"원하는 방식으로 파밍하세요. 탈것을 타고, 걸어서, 또는 직업 고유의 이동 형태로. 체크한 상태라면 언제든 파밍 모드가 순환합니다."
L["OPTIONS_FARM_MOUNTED"] = "탈것 탑승"
L["OPTIONS_FARM_MOUNTED_DESCRIPTION"] = "채집물 앞에서 내리면 채집하는 동안 순환이 기다립니다."
L["OPTIONS_FARM_NOT_MOUNTED"] = "탈것 미탑승"
L["OPTIONS_FARM_NOT_MOUNTED_DESCRIPTION"] =
	"채집하거나 음식을 먹으려고 멈추면 다시 움직일 때까지 순환이 기다립니다."
L["OPTIONS_FARM_TRAVEL_FORMS_NAMED"] = "%s: 여행 변신"
L["OPTIONS_FARM_TRAVEL_FORMS_ONE_DESCRIPTION"] = "%s도 포함됩니다."
L["OPTIONS_FARM_TRAVEL_FORMS_TWO_DESCRIPTION"] = "%s 및 %s도 포함됩니다."
L["OPTIONS_FARM_CLASS_STATE"] = "%s: %s"
L["OPTIONS_FARM_CHEETAH_DESCRIPTION"] = "다른 조건과 마찬가지로 이동하는 동안에만 순환합니다."
L["OPTIONS_FARM_PACK_GROUP_DESCRIPTION"] =
	"파티 전체가 같은 속도로 따라오는 파티 채집 때 유용합니다."
L["OPTIONS_FARM_GHOST_WOLF_DESCRIPTION"] = "첫 탈것을 얻기 전 채집하러 다닐 때 좋습니다."
L["OPTIONS_CYCLE_SPEED"] = "순환 속도"
L["OPTIONS_CYCLE_SPEED_DESCRIPTION"] =
	"전환할 때마다 전역 재사용 대기시간이 들기 때문에, 순환이 느릴수록 직접 시전하는 주문과 덜 겹칩니다."
L["OPTIONS_CYCLE_EVERY"] = "%s초마다 전환"
L["OPTIONS_FARM_ABILITIES"] = "파밍 모드 능력"
L["OPTIONS_FARM_ABILITIES_DESCRIPTION"] =
	"찾고 싶은 것을 체크하세요. 파밍 모드는 이 캐릭터가 아는 체크된 능력을 모두 순환하고 나머지는 건너뜁니다."
L["OPTIONS_FARM_GROUP_GENERAL"] = "전문 기술 및 종족 특성"
L["OPTIONS_FARM_CAT_FORM_NOTE_NAMED"] =
	"%s 상태에서만 순환하며, 이 상태는 탈것 미탑승으로 간주됩니다."
L["OPTIONS_FARM_PERSISTENT"] = "지속 추적 능력 포함"
L["OPTIONS_FARM_PERSISTENT_DESCRIPTION"] =
	"아래에서 함께 체크되어 있어도 두 번 나오지 않습니다. 자동 대상 추적은 이 자리에 대상의 종류를 대신 넣습니다."

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

L["MATCH_HERB"] = "약초학;약초 채집;약초채집"
L["MATCH_MINE"] = "채광"

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

L["MSG_FORMAT_LOCKED"] = "도적 여러분! %s, 위치 %s, %s (%s)."
L["MSG_FORMAT_HERB"] = "약초채집가 여러분! %s, 위치 %s, %s (%s)."
L["MSG_FORMAT_MINE"] = "광부 여러분! %s, 위치 %s, %s (%s)."

L["CHAT_TOO_LONG"] =
	"이 초안은 %d바이트로 채팅 제한인 %d바이트를 초과합니다. 보내기 전에 줄여주세요."

-- Options

L["TAB_COME_AND_GET_IT"] = "Come & Get It"
L["OPTIONS_COME_AND_GET_IT_DESCRIPTION"] =
	"채집할 수 없는 약초, 캘 수 없는 광맥, 아니면 주변에 도적도 없는데 잠겨 있는 보물 상자를 발견하셨나요? 우클릭하면 Come & Get It이 좌표를 공유하거나 널리 알릴 수 있는 메시지를 만들어 줍니다. 영웅이 되는 일이 이렇게 쉬웠던 적은 없습니다."
L["OPTIONS_ENABLE_COME_AND_GET_IT"] = "Come & Get It 활성화"
L["OPTIONS_ENABLE_COME_AND_GET_IT_DESCRIPTION"] =
	"전투 중이나 인스턴스에서는 작동하지 않으므로, 전투 도중 대화창이 키보드 입력을 가로채는 일이 없습니다."
L["OPTIONS_OUTPUT_NAME"] = "기본 출력"
L["OPTIONS_OUTPUT_DESCRIPTION"] =
	"길드는 레이어나 지역에 상관없이 접속 중인 모든 길드원에게 전달됩니다."
L["OPTIONS_OUTPUT_NOTE"] = "참고: 지역 (/1)은 같은 레이어에 있는 플레이어에게만 전달됩니다."
L["OPTIONS_OUTPUT_CHANNEL1"] = "지역 (/1)"
