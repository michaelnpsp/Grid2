local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "koKR")
if not L then return end

--{{{ Actually used
L["Border"] = "테두리"
L["Charmed"] = "매혹"
--}}}

--{{{ GridCore
L["Configure"] = "설정"
L["Configure Grid"] = "Grid 옵션을 설정합니다."
--}}}

--{{{ GridFrame
L["Frame"] = "창"
L["Options for GridFrame."] = "각 유닛 창의 표시를 위한 옵션을 설정합니다."

L["Indicators"] = "지시기"
L["Health Bar"] = "생명력 바"
L["Health Bar Color"] = "생명력 바 색상"
L["Center Text"] = "중앙 문자"
L["Center Text 2"] = "중앙 문자 2"
L["Center Icon"] = "중앙 아이콘"
L["Top Left Corner"] = "좌측 상단 모서리"
L["Top Right Corner"] = "우측 상단 모서리"
L["Bottom Left Corner"] = "좌측 하단 모서리"
L["Bottom Right Corner"] = "우측 하단 모서리"
L["Frame Alpha"] = "창 투명도"

L["Options for %s indicator."] = "%s 지시기를 위한 옵션 설정합니다."
L["Statuses"] = "상태"
L["Toggle status display."] = "상태 표시 사용"

-- Advanced options
L["Enable %s indicator"] = "%s 지시기 사용"
L["Toggle the %s indicator."] = "%s 지시기를 사용합니다."
L["Orientation of Text"] = "문자의 방향"
L["Set frame text orientation."] = "프레임 문자의 방향을 설정합니다."
--}}}

--{{{ GridLayout
L["Layout"] = "배치"
L["Options for GridLayout."] = "배치 창과 그룹 배치를 위한 옵션을 설정합니다."

-- Layout options
L["Raid Layout"] = "공격대 배치"
L["Select which raid layout to use."] = "사용할 공격대 배치를 선택합니다."
L["Show Party in Raid"] = "공격대시 파티원 표시"
L["Show party/self as an extra group."] = "공격대시 자신과 파티원을 추가로 표시합니다."
L["Show Pets for Party"] = "파티시 소환수 표시"
L["Show the pets for the party below the party itself."] = "파티시 소환수를 표시합니다."

-- Display options
L["Pet color"] = "소환수 색상"
L["Set the color of pet units."] = "소환수 유닛의 색상을 설정합니다."
L["Pet coloring"] = "소환수 채색"
L["Set the coloring strategy of pet units."] = "소환수의 유닛 채색 방법을 설정합니다."
L["By Owner Class"] = "소환자의 직업에 의해"
L["By Creature Type"] = "창조물의 타입에 의해"
L["Using Fallback color"] = "사용자의 색상에 의해"
L["Beast"] = "야수형"
L["Demon"] = "악마형"
L["Humanoid"] = "인간형"
L["Elemental"] = "정령형"
L["Colors"] = "색상"
L["Color options for class and pets."] = "직업과 소환수의 색상 옵션을 설정합니다."
L["Fallback colors"] = "대체 색상"
L["Color of unknown units or pets."] = "알수없는 유닛이나 소환수의 색상을 설정합니다."
L["Unknown Unit"] = "알수없는 유닛"
L["The color of unknown units."] = "알수없는 유닛의 색상을 설정합니다."
L["Unknown Pet"] = "알수없는 소환수"
L["The color of unknown pets."] = "알수없는 소환수의 색상을 설정합니다."
L["Class colors"] = "직업 색상"
L["Color of player unit classes."] = "플레이어들의 유닛 색상을 설정합니다."
L["Creature type colors"] = "소환수 타입 색상"
L["Color of pet unit creature types."] = "소환수 유닛 타입 색상을 설정합니다."
L["Color for %s."] = "%s 색상"

-- Advanced options
L["Advanced"] = "고급"
L["Advanced options."] = "고급 옵션을 설정합니다."
--}}}

--{{{ GridLayoutLayouts
L["None"] = "없음"
L["Solo"] = "솔로잉"
L["Solo w/Pet"] = "솔로잉, 소환수"
L["By Group 5"] = "5인 공격대"
L["By Group 5 w/Pets"] = "5인 공격대, 소환수"
L["By Group 40"] = "40인 공격대"
L["By Group 25"] = "25인 공격대"
L["By Group 25 w/Pets"] = "25인 공격대, 소환수"
L["By Group 20"] = "20인 공격대"
L["By Group 15"] = "15인 공격대"
L["By Group 15 w/Pets"] = "15인 공격대, 소환수"
L["By Group 10"] = "10인 공격대"
L["By Group 10 w/Pets"] = "10인 공격대, 소환수"
L["By Class 25"] = "25인 직업별"
L["By Class 25 Wide"] = "25인 직업별 Wide"
L["By Role 25"] = "25인 역할별"
L["By Class"] = "직업별"
L["By Class w/Pets"] = "직업별, 소환수"
L["Onyxia"] = "오닉시아"
L["By Group 25 w/tanks"] = "25인 공격대, 탱커"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "(%d+)미터"
--}}}

--{{{ GridStatus
L["Status"] = "상태"
L["Statuses"] = "%s|1을;를; 위한 옵션을 설정합니다."

-- module prototype
L["Status: %s"] = "상태: %s"
L["Color"] = "색상"
L["Color for %s"] = "%s 색상"
L["Priority"] = "우선 순위"
L["Priority for %s"] = "%s|1을;를; 위한 우선 순위"
L["Range filter"] = "범위 필터"
L["Range filter for %s"] = "%s|1을;를; 위한 거리 필터"
L["Enable"] = "사용"
L["Enable %s"] = "%s|1을;를; 사용"
--}}}

--{{{ GridStatusAggro
L["Aggro"] = "어그로"
L["Aggro alert"] = "어그로 경고"
--}}}

--{{{ GridStatusAuras
L["Auras"] = "오라"
L["Debuff type: %s"] = "디버프 타입: %s"
L["Poison"] = "독"
L["Disease"] = "질병"
L["Magic"] = "마법"
L["Curse"] = "저주"
L["Ghost"] = "유령"
L["Add new Buff"] = "새로운 버프 추가"
L["Adds a new buff to the status module"] = "상태 모듈에 새로운 버프를 추가합니다."
L["<buff name>"] = "<버프 이름>"
L["Add new Debuff"] = "새로운 디버프 추가"
L["Adds a new debuff to the status module"] = "상태 모듈에 새로운 디버프를 추가합니다."
L["<debuff name>"] = "<디버프 이름>"
L["Delete (De)buff"] = "(디)버프 삭제"
L["Deletes an existing debuff from the status module"] = "기존의 디버프를 상태 모듈에서 삭제합니다."
L["Remove %s from the menu"] = "메뉴에서 %s|1을;를; 제거합니다."
L["Debuff: %s"] = "디버프: %s"
L["Buff: %s"] = "버프: %s"
L["Class Filter"] = "직업 필터"
L["Show status for the selected classes."] = "선택된 직업을 위해 상태에 표시합니다."
L["Show on %s."] = "%s 표시"
L["Show if missing"] = "사라짐 표시"
L["Display status only if the buff is not active."] = "버프가 사라졌을 경우에만 상태를 표시합니다."
L["Filter Abolished units"] = "해제 유닛 필터"
L["Skip units that have an active Abolish buff."] = "버프를 해제할 수 있는 유닛을 무시합니다."
--}}}

--{{{ GridStatusName
L["Unit Name"] = "유닛 이름"
L["Color by class"] = "직업별 색상"
--}}}

--{{{ GridStatusMana
L["Mana"] = "마나"
L["Low Mana"] = "마나 낮음"
L["Mana threshold"] = "마나 수치"
L["Set the percentage for the low mana warning."] = "마나 낮음 경고를 위한 백분율을 설정합니다."
L["Low Mana warning"] = "마나 낮음 경고"
--}}}

--{{{ GridStatusHeals
L["Heals"] = "치유"
L["Incoming heals"] = "치유 받음"
L["Ignore Self"] = "자신 무시"
L["Ignore heals cast by you."] = "자신의 치유 시전은 무시합니다."
L["(.+) begins to cast (.+)."] = "(.+)|1이;가; (.+)|1을;를; 시전합니다."
L["(.+) gains (.+) Mana from (.+)'s Life Tap."] = "(.+)|1이;가; (.+)의 생명력 전환으로 (.+) 마나를 얻었습니다."	--check
L["^Corpse of (.+)$"] = "^(.+)의 시체$"	--check
--}}}

--{{{ GridStatusHealth
L["Low HP"] = "생명력 낮음"
L["DEAD"] = "죽음"
L["GHOST"] = "유령"
L["FD"] = "죽척"
L["Offline"] = "오프라인"
L["Unit health"] = "유닛 생명력"
L["Health deficit"] = "결손 생명력"
L["Low HP warning"] = "생명력 낮음 경고"
L["Feign Death warning"] = "죽은척하기 경고"
L["Death warning"] = "죽음 경고"
L["Offline warning"] = "오프라인 경고"
L["Health"] = "생명력"
L["Show dead as full health"] = "죽은후 모든 생명력 표시"
L["Treat dead units as being full health."] = "죽은 플레이어들의 전체 생명력을 표시합니다."
L["Use class color"] = "직업 색상 사용"
L["Color health based on class."] = "직업에 기준을 둔 생명력 색상을 사용합니다."
L["Health threshold"] = "생명력 수치"
L["Only show deficit above % damage."] = "결손량을 표시할 백분율(%)을 설정합니다."
L["Color deficit based on class."] = "직업에 기준을 둔 결손 색상을 사용합니다."
L["Low HP threshold"] = "생명력 낮음 수치"
L["Set the HP % for the low HP warning."] = "생명력 낮음 경고를 위한 백분율(%)을 설정합니다."
--}}}

--{{{ GridStatusPvp
L["PvP"] = "PvP"
L["FFA"] = "FFA"
--}}}

--{{{ GridStatusRange
L["Range"] = "거리"
L["Range check frequency"] = "거리 체크 빈도"
L["Seconds between range checks"] = "거리 체크의 시간(초)를 설정합니다."
L["Out of Range"] = "범위 벗어남"
L["OOR"] = "범위 벗어남"
L["Range to track"] = "범위 추적"
L["Range in yard beyond which the status will be lost."] = "범위가 사정 거리 밖에 있으면 상태 정보를 가져 올수 없습니다."
L["%d yards"] = "%d 미터"
--}}}

--{{{ GridStatusReadyCheck
L["?"] = "?"
L["R"] = "R"
L["X"] = "X"
L["AFK"] = "자리비움"
--}}}

--{{{ GridStatusTarget
L["Target"] = "대상"
L["Your Target"] = "당신의 대상"
--}}}

--{{{ GridStatusVehicle
L["vehicle"] = "vehicle"
--}}}

--{{{ GridStatusVoiceComm
L["Voice Chat"] = "음성 대화"
L["Talking"] = "대화중"

--}}}
