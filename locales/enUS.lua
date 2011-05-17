local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "enUS", true, true)
if not L then return end

--{{{ Actually used
L["Border"] = true
L["Charmed"] = true
L["Default"] = true
L["Grid2"] = true
L["Beast"] = true
L["Demon"] = true
L["Humanoid"] = true
L["Elemental"] = true
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = true
--}}}

--{{{ GridStatusHealth
L["Low HP"] = true
L["DEAD"] = true
L["GHOST"] = true
L["FD"] = true
L["Offline"] = true
--}}}

--{{{ GridStatusPvp
L["PvP"] = true
L["FFA"] = true
--}}}

--{{{ GridStatusRange
L["OOR"] = true
--}}}

--{{{ GridStatusReadyCheck
L["?"] = true
L["R"] = true
L["X"] = true
L["AFK"] = true
--}}}

--{{{ GridStatusTarget
L["target"] = true
--}}}

--{{{ GridStatusVehicle
L["vehicle"] = true
--}}}

--{{{ GridStatusVoiceComm
L["talking"] = true
--}}}

--{{{ GridStatusDungeonRole
L["TANK"] = true
L["HEALER"] = true
L["DAMAGER"] = true
--}}}

--Layouts
L["None"] = true
L["Solo"] = true
L["Solo w/Pet"] = true
L["By Group 5"] = true
L["By Group 5 w/Pets"] = true
L["By Group 10"] = true
L["By Group 10 w/Pets"] = true
L["By Group 15"] = true
L["By Group 15 w/Pets"] = true
L["By Group 25"] = true
L["By Group 25 w/Pets"] = true
L["By Class"] = true
L["By Class w/Pets"] = true
L["By Class 25"] = true
L["By Role 25"] = true
L["By Class 1 x 25 Wide"] = true
L["By Class 2 x 15 Wide"] = true
L["By Group 4 x 10 Wide"] = true
L["By Group 20"] = true
L["By Group 25 w/tanks"] = true
L["By Group 40"] = true
L["By Group 25 Tanks First"] = true
L["By Group 10 Tanks First"] = true
L["Select Layout"] = true