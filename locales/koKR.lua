local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "koKR")
if not L then return end

--{{{ Actually used
L["Border"] = "테두리"
L["Charmed"] = "매혹"
L["Default"] = "Default"
L["Grid2"] = "Grid2"
L["Beast"] = "야수"
L["Demon"] = "악마"
L["Humanoid"] = "인간형"
L["Elemental"] = "정령"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "(%d+)미터"
--}}}

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

--{{{ GridStatusDungeonRole
-- L["TANK"] = ""
-- L["HEALER"] = ""
-- L["DAMAGER"] = ""
--}}}

--{{{ Other roles
-- L["RL"] = ""
-- L["RA"] = ""
-- L["ML"] = ""
--}}}

--{{{ Resurrection
-- L["Reviving"] = ""
-- L["Revived"] = ""
---}}}

--Layouts
L["None"] = "없음"
L["Solo"] = "솔로잉"
L["Solo w/Pet"] = "솔로잉, 소환수"
L["By Group 5"] = "5인 공격대"
L["By Group 5 w/Pets"] = "5인 공격대, 소환수"
L["By Group 10"] = "10인 공격대"
L["By Group 10 w/Pets"] = "10인 공격대, 소환수"
L["By Group 15"] = "15인 공격대"
L["By Group 15 w/Pets"] = "15인 공격대, 소환수"
L["By Group 25"] = "25인 공격대"
L["By Group 25 w/Pets"] = "25인 공격대, 소환수"
L["By Class"] = "직업별"
L["By Class w/Pets"] = "직업별, 소환수"
L["By Class 25"] = "25인 직업별"
L["By Role 25"] = "25인 역할별"
L["By Class 1 x 25 Wide"] = "1 x 25인 직업별"
L["By Class 2 x 15 Wide"] = "2 x 15인 직업별"
L["By Group 4 x 10 Wide"] = "4 x 10인 공격대"
L["By Group 20"] = "20인 공격대"
L["By Group 25 w/tanks"] = "25인 공격대, 탱커"
L["By Group 40"] = "40인 공격대"
-- L["By Group 25 Tanks First"] = ""
-- L["By Group 10 Tanks First"] = ""
-- L["Select Layout"] = ""
