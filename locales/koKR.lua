local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "koKR")
if not L then return end

--{{{ Actually used
L["Border"] = "테두리"
L["Charmed"] = "매혹"
L["Default"] = "Default"
L["Drink"] = "음료"
L["Food"] = "음식"
L["Grid2"] = "Grid2"
L["Beast"] = "야수"
L["Demon"] = "악마"
L["Humanoid"] = "인간형"
L["Elemental"] = "정령"
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
L["By Group 4 x 10 Wide"] = "4 x 10인 공격대"
L["By Class 25"] = "25인 직업별"
L["By Class 1 x 25 Wide"] = "1 x 25인 직업별"
L["By Class 2 x 15 Wide"] = "2 x 15인 직업별"
L["By Role 25"] = "25인 역할별"
L["By Class"] = "직업별"
L["By Class w/Pets"] = "직업별, 소환수"
L["By Group 25 w/tanks"] = "25인 공격대, 탱커"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "(%d+)미터"
--}}}

--[[
--{{{ GridStatus
-- module prototype
L["Range filter"] = "범위 필터"
L["Range filter for %s"] = "%s|1을;를; 위한 거리 필터"
--}}}

--{{{ GridStatusAuras
L["Auras"] = "오라"
L["Debuff type: %s"] = "디버프 타입: %s"
L["Poison"] = "독"
L["Disease"] = "질병"
L["Magic"] = "마법"
L["Curse"] = "저주"
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
--]]

--{{{ GridStatusHealth
L["Low HP"] = "생명력 낮음"
L["DEAD"] = "죽음"
L["GHOST"] = "유령"
L["FD"] = "죽척"
L["Offline"] = "오프라인"
--}}}

--{{{ GridStatusPvp
L["PvP"] = "PvP"
L["FFA"] = "FFA"
--}}}

--{{{ GridStatusRange
L["OOR"] = "범위 벗어남"
--}}}

--{{{ GridStatusReadyCheck
L["?"] = "?"
L["R"] = "R"
L["X"] = "X"
L["AFK"] = "자리비움"
--}}}

--{{{ GridStatusTarget
L["target"] = "대상"
--}}}

--{{{ GridStatusVehicle
L["vehicle"] = "탈것"
--}}}

--{{{ GridStatusVoiceComm
L["talking"] = "대화중"
--}}}
