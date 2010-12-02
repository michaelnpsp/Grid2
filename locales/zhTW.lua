local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "zhTW")
if not L then return end

--{{{ Actually used
L["Border"] = "邊框"
L["Charmed"] = "魅惑"
L["Default"] = "預設"
L["Drink"] = "飲料"
L["Food"] = "食物"
L["Grid2"] = "Grid2"
L["Beast"] = "野獸"
L["Demon"] = "惡魔"
L["Humanoid"] = "人形"
L["Elemental"] = "元素"
--}}}

--{{{ GridLayoutLayouts
L["None"] = "無"
L["Solo"] = "單人"
L["Solo w/Pet"] = "單人以及寵物"
L["By Group 5"] = "5人隊伍"
L["By Group 5 w/Pets"] = "5人隊伍以及寵物"
L["By Group 40"] = "40人團隊"
L["By Group 25"] = "25人團隊"
L["By Group 25 w/Pets"] = "25人團隊以及寵物"
L["By Group 20"] = "20人團隊"
L["By Group 15"] = "15人團隊"
L["By Group 15 w/Pets"] = "15人團隊以及寵物"
L["By Group 10"] = "10人團隊"
L["By Group 10 w/Pets"] = "10人團隊以及寵物"
--L["By Group 4 x 10 Wide"] = true
--L["By Class 25"] = true
--L["By Class 1 x 25 Wide"] = true
--L["By Class 2 x 15 Wide"] = true
--L["By Role 25"] = true
L["By Class"] = "職業"
L["By Class w/Pets"] = "職業以及寵物"
L["By Group 25 w/tanks"] = "25人團隊及坦克"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "(%d+)碼距離"
--}}}

--[[
--{{{ GridStatus
-- module prototype
L["Range filter"] = "距離過濾"
L["Range filter for %s"] = "%s的距離過濾"
--}}}

--{{{ GridStatusAuras
L["Auras"] = "光環"
L["Debuff type: %s"] = "減益類型：%s"
L["Poison"] = "毒藥"
L["Disease"] = "疾病"
L["Magic"] = "魔法"
L["Curse"] = "詛咒"
L["Filter Abolished units"] = "過濾無效單位"
L["Skip units that have an active Abolish buff."] = "忽略單位上存在無效效果。"
--}}}

--{{{ GridStatusName
L["Unit Name"] = "單位名字"
L["Color by class"] = "使用職業顏色"
--}}}

--{{{ GridStatusMana
L["Mana"] = "法力"
L["Low Mana"] = "低法力"
L["Mana threshold"] = "法力臨界點"
L["Set the percentage for the low mana warning."] = "設定低法力警報的臨界點。"
L["Low Mana warning"] = "低法力警報"
--}}}
--]]

--{{{ GridStatusHealth
L["Low HP"] = "低血量"
L["DEAD"] = "死亡"
L["GHOST"] = "靈魂"
L["FD"] = "假死"
L["Offline"] = "離線"
--}}}

--{{{ GridStatusPvp
L["PvP"] = "PvP"
L["FFA"] = "FFA"
--}}}

--{{{ GridStatusRange
L["OOR"] = "遠"
--}}}

--{{{ GridStatusReadyCheck
L["?"] = "？"
L["R"] = "是"
L["X"] = "否"
L["AFK"] = "暫離"
--}}}

--{{{ GridStatusTarget
L["target"] = "目標"
--}}}

--{{{ GridStatusVehicle
L["vehicle"] = "載具"
--}}}

--{{{ GridStatusVoiceComm
L["talking"] = "正在說話"
--}}}
