local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "ruRU")
if not L then return end

--{{{ Actually used
L["Border"] = "Края"
L["Charmed"] = "Зачарованный"
L["Default"] = "Default"
L["Drink"] = "Питье"
L["Food"] = "Пища"
L["Grid2"] = "Grid2"
L["Beast"] = "Животное"
L["Demon"] = "Демон"
L["Humanoid"] = "Гуманоид"
L["Elemental"] = "Элементаль"
--}}}

--{{{ GridLayoutLayouts
L["None"] = "Нет"
L["Solo"] = "Соло"
L["Solo w/Pet"] = "Соло,с питомцем"
L["By Group 5"] = "Для группы из 5 чел."
L["By Group 5 w/Pets"] = "Для группы из 5 чел. с питомцами"
L["By Group 40"] = "Для группы из 40 чел."
L["By Group 25"] = "Для группы из 25 чел."
L["By Group 25 w/Pets"] = "Для группы из 25 чел. с питомцами"
L["By Group 20"] = "Для группы из 20 чел."
L["By Group 15"] = "Для группы из 15 чел."
L["By Group 15 w/Pets"] = "Для группы из 15 чел. с питомцами"
L["By Group 10"] = "Для группы из 10 чел."
L["By Group 10 w/Pets"] = "Для группы из 10 чел. с питомцами"
L["By Group 4 x 10 Wide"] = "Для группы из 4 x 10-широкий"
L["By Class 25"] = "По классам 25"
L["By Class 1 x 25 Wide"] = "По классам 1 x 25-широкий"
L["By Class 2 x 15 Wide"] = "По классам 2 x 15-широкий"
L["By Role 25"] = "По роле 25"
L["By Class"] = "По классам"
L["By Class w/Pets"] = "По классам с питомцами"
L["By Group 25 w/tanks"] = "Группой из 25 чел. с танками"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "Радиус действия: (%d+) м"
--}}}

--[[
--{{{ GridStatus
-- module prototype
L["Range filter"] = "Фильтр радиуса"
L["Range filter for %s"] = "Фильтр радиуса для %s"
--}}}

--{{{ GridStatusAuras
L["Auras"] = "Ауры"
L["Debuff type: %s"] = "Тип дебаффа: %s"
L["Poison"] = "Яды"
L["Disease"] = "Болезнь"
L["Magic"] = "Магия"
L["Curse"] = "Проклятье"
L["Filter Abolished units"] = "Фильтр персонажей находящихся под исцелением"
L["Skip units that have an active Abolish buff."] = "Пропускает персонажей на которых есть активное Устранение баффа."
--}}}

--{{{ GridStatusName
L["Unit Name"] = "Имя игрока"
L["Color by class"] = "Цвет классов"
--}}}

--{{{ GridStatusMana
L["Mana"] = "Мана"
L["Low Mana"] = "Мало маны"
L["Mana threshold"] = "Порог маны"
L["Set the percentage for the low mana warning."] = "Установить процент для предупреждения об окончании маны."
L["Low Mana warning"] = "Предупреждение о заканчивающейся мане"
--}}}
--]]

--{{{ GridStatusHealth
L["Low HP"] = "Мало ЗД"
L["DEAD"] = "ТРУП"
L["GHOST"] = "ПРИЗРАК"
L["FD"] = "ПМ"
L["Offline"] = "Вышел из сети"
--}}}

--{{{ GridStatusPvp
L["PvP"] = "PvP"
L["FFA"] = "FFA"
--}}}

--{{{ GridStatusRange
L["OOR"] = "OOR"
--}}}

--{{{ GridStatusReadyCheck
L["?"] = "?"
L["R"] = "Г"
L["X"] = "X"
L["AFK"] = "Отсутствует"
--}}}

--{{{ GridStatusTarget
L["target"] = "Цель"
--}}}

--{{{ GridStatusVehicle
L["vehicle"] = "Транспортное средство"
--}}}

--{{{ GridStatusVoiceComm
L["talking"] = "Говорит"
--}}}
