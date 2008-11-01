local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "ruRU")
if not L then return end

--{{{ GridCore
L["Configure"] = "Настройки"
L["Configure Grid"] = "Настройка Grid"

--}}}
--{{{ GridFrame
L["Frame"] = "Области"
L["Options for GridFrame."] = "Опции для областей Grid"

L["Indicators"] = "Индикатор"
L["Border"] = "Граница"
L["Health Bar"] = "Полоса Здоровья"
L["Health Bar Color"] = "Цвет полосы здоровья"
L["Center Text"] = "Текст в центре"
L["Center Text 2"] = "Текст в центре 2"
L["Center Icon"] = "Иконка в центре"
L["Top Left Corner"] = "Верхний левый угол"
L["Top Right Corner"] = "Верхний правый угол"
L["Bottom Left Corner"] = "Нижний левый угол"
L["Bottom Right Corner"] = "Нижний правый угол"
L["Frame Alpha"] = "Прозрачная область"

L["Options for %s indicator."] = "Опции для %s индикаторов"
L["Statuses"] = "Состояния"
L["Toggle status display."] = "Показать состояние на экране"

-- Advanced options
L["Enable %s indicator"] = "Включить %s индикатор"
L["Toggle the %s indicator."] = "Переключить %s индикатор"
L["Orientation of Text"] = "Ориентация текста"
L["Set frame text orientation."] = "Настройка области ориентации текста"

--}}}
--{{{ GridLayout
L["Layout"] = "Расположение"
L["Options for GridLayout."] = "Опции для GridLayout"

-- Layout options
L["Raid Layout"] = "Расположение рейда"
L["Select which raid layout to use."] = "Настраивает расположение рейда"
L["Show Party in Raid"] = "Показывать группу в рейде"
L["Show party/self as an extra group."] = "Показать группу/себя как отдельную группу"
L["Show Pets for Party"] = "Показывать питомцев в группе"
L["Show the pets for the party below the party itself."] = "Показывает питомцев группы непоредсвенно ниже группы."

-- Display options
L["Pet color"] = "Цвет питомцев"
L["Set the color of pet units."] = "Установить цвет питомцев."
L["Pet coloring"] = "Окраска  питомцев"
L["Set the coloring strategy of pet units"] = "Установить стратегию окраски питомцев"
L["By Owner Class."] = "По классу."
L["By Creature Type"] = "По типу существа"
L["Using Fallback color"] = "Использовать истинный цвет"
L["Beast"] = "Животное"
L["Demon"] = "Демон"
L["Humanoid"] = "Гуманоид"
L["Elemental"] = "Элементаль"
L["Colors"] = "Цвета"
L["Color options for class and pets."] = "Опции окраски для классов и питомцев"
L["Fallback colors"] = "Цвета неизвестных"
L["Color of unknown units or pets."] = "Цвет неизвестных единиц или питомцев"
L["Unknown Unit"] = "Неизвестная единица"
L["The color of unknown units."] = "Цвет неизвестной единицы"
L["Unknown Pet"] = "Неизвестные питомцы"
L["The color of unknown pets."] = "Цвет неизветстных питомцев"
L["Class colors"] = "Цвет классов"
L["Color of player unit classes."] = "Цвет классов персонажей"
L["Creature type colors"] = "Цвет типов созданий"
L["Color of pet unit creature types."] = "Цвет типов питомцев созданий"
L["Color for %s."] = "Цвет для %s."

-- Advanced options
L["Advanced"] = "Дополниельные"
L["Advanced options."] = "Дополнительные опции"

--}}}
--{{{ GridLayoutLayouts
L["None"] = "Нет"
L["Solo"] = "Соло"
L["Solo w/Pet"] = "Соло,с Питомцем"
L["By Group 5"] = "Для Группы из 5 чел."
L["By Group 5 w/Pets"] = "Для Группы из 5 чел. с питомцами"
L["By Group 40"] = "Для Группы из 40 чел."
L["By Group 25"] = "Для Группы из 25 чел."
L["By Group 25 w/Pets"] = "Для Группы из 25 чел. с питомцами"
L["By Group 20"] = "Для Группы из 20 чел."
L["By Group 15"] = "Для Группы из 15 чел."
L["By Group 15 w/Pets"] = "Для Группы из 15 чел. с питомцами"
L["By Group 10"] = "Для Группы из 10 чел."
L["By Group 10 w/Pets"] = "Для Группы из 10 чел. с питомцами"
L["By Class"] = "По классам"
L["By Class w/Pets"] = "По классам с питомцами"
L["Onyxia"] = "Для Ониксии"
L["By Group 25 w/tanks"] = "Группой из 25 чел. с танками"

--}}}
--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "Радиус действия: (%d+) м"

--}}}
--{{{ GridStatus
L["Status"] = "Статус"
L["Statuses"] = "Статусы"

-- module prototype
L["Status: %s"] = "Статус: %s"
L["Color"] = "Цвет"
L["Color for %s"] = "Цвет для %s"
L["Priority"] = "Приоритет"
L["Priority for %s"] = "Приоритет для %s"
L["Range filter"] = "Фильтр радиуса"
L["Range filter for %s"] = "Фильтр радиуса для %s"
L["Enable"] = "Включено"
L["Enable %s"] = "Включено %s"

--}}}
--{{{ GridStatusAggro
L["Aggro"] = "Агро"
L["Aggro alert"] = "Сигнал Агро"

--}}}
--{{{ GridStatusAuras
L["Auras"] = "Ауры"
L["Debuff type: %s"] = "Тип Дебаффа: %s"
L["Poison"] = "Яды"
L["Disease"] = "Болезнь"
L["Magic"] = "Магия"
L["Curse"] = "Проклятье"
L["Ghost"] = "Призрак"
L["Add new Buff"] = "Добавить новый бафф"
L["Adds a new buff to the status module"] = "Добавляет новый бафф в модуль"
L["<buff name>"] = "<имя баффа>"
L["Add new Debuff"] = "Добавить новый дебафф"
L["Adds a new debuff to the status module"] = "Добавляет новый дебафф в модуль статуса"
L["<debuff name>"] = "<имя дебаффа>"
L["Delete (De)buff"] = "Удалить бафф/дебафф"
L["Deletes an existing debuff from the status module"] = "Удаляет выбранный дебафф в модуле статуса модуль"
L["Remove %s from the menu"] = "Удалите %s из меню"
L["Debuff: %s"] = "Дебафф: %s"
L["Buff: %s"] = "Бафф: %s"
L["Class Filter"] = "Фильтр классов"
L["Show status for the selected classes."] = "Показывает статус для выбранных классов."
L["Show on %s."] = "Показать на %s."
L["Show if missing"] = "Показывать если пропущен"
L["Display status only if the buff is not active."] = "Показывать статус только если баффы не активны"
L["Filter Abolished units"] = "Фильтр персонажей находящихся под исцелением"
L["Skip units that have an active Abolish buff."] = "Пропускает персонажей на которых есть активные баффы исцеления." --try...

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
--{{{ GridStatusHeals
L["Heals"] = "Лечение"
L["Incoming heals"] = "Поступающее лечение"
L["Ignore Self"] = "Игнорировать себя"
L["Ignore heals cast by you."] = "Игнорировать лечение самого себя"
L["(.+) begins to cast (.+)."] = "(.+)поступает умение(.+)?" --test
L["(.+) gains (.+) Mana from (.+)'s Life Tap."] = "(.+)поступает(.+)?Мана для(.+)  Сигнал жизни" --test
L["^Corpse of (.+)$"] = "(.+) Поражения" --test

--}}}
--{{{ GridStatusHealth
L["Low HP"] = "Мало HP"
L["DEAD"] = "ТРУП"
L["GHOST"] = "ПРИЗРАК"
L["FD"] = "СС"
L["Offline"] = "Оффлайн"
L["Unit health"] = "Здоровье единицы"
L["Health deficit"] = "Дефицит здоровья"
L["Low HP warning"] = "Предупреждение Мало HP"
L["Feign Death warning"] = "Предупреждение о Симуляции смерти"
L["Death warning"] = "Предупреждение о смерти"
L["Offline warning"] = "Предупреждение об оффлайне"
L["Health"] = "Здоровье"
L["Show dead as full health"] = "Показывать мертвых как-будто с полным здоровьем"
L["Treat dead units as being full health."] = "Расматривать данные единицы как имеющие полное здоровье."
L["Use class color"] = "Использовать цвет классов"
L["Color health based on class."] = "Цвет полосы здоровья в зависимости от класса"
L["Health threshold"] = "Порог здоровья"
L["Only show deficit above % damage."] = "Показывать дефицит только после % урона."
L["Color deficit based on class."] = "Цвет дефицита в зависимости от класса"
L["Low HP threshold"] = "Порог \"Мало HP\""
L["Set the HP % for the low HP warning."] = "Установить % для предупредения о том что у единицы мало здоровья."

--}}}
--{{{ GridStatusRange
L["Range"] = "Расстояние"
L["Range check frequency"] = "Частота проверки растояния"
L["Seconds between range checks"] = "Частота проверки в секундах"
L["Out of Range"] = "Из Диапозона"
L["OOR"] = "OOR"
L["Range to track"] = "Диапозон отслеживания"
L["Range in yard beyond which the status will be lost."] = "Диапозон вметрах выдя  за который статус будет утерян."
L["%d yards"] = "%d м."

--}}}
--{{{ GridStatusTarget
L["Target"] = "Цель"
L["Your Target"] = "Ваша Цель"

--}}}
--{{{ GridStatusVoiceComm
L["Voice Chat"] = "Голосовой чат"
L["Talking"] = "Говорит"

--}}}
