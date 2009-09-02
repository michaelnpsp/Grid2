﻿local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "ruRU")
if not L then return end

L["Debug"] = "Отладка"
L["Debugging"] = "Отлаживание"
L["Module debugging menu."] = "Модуль отладки меню."

L["Show Tooltip"] = "Показать подсказки"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "Показывать подсказку единицы.  Выберите 'Всегда', 'Никогда', или 'Вне боя'."
L["Always"] = "Всегда"
L["Never"] = "Никогда"
L["OOC"] = "Вне боя"

L["blink"] = "Мигание"
L["category"] = "Категория"
L["frame"] = "Фрейм"
L["layout"] = "Расположение"
L["location"] = "Расположение"
L["indicator"] = "Индикатор"
L["status"] = "Статус"

L["buff"] = "Бафф"
L["debuff"] = "Дебафф"

L["Icon"] = "Иконка"
L["Square"] = "Квадрат"
L["Text"] = "Текст"

L["Advanced"] = "Дополнительные"
L["Advanced options."] = "Допонительные опции."

L["Frame Width"] = "Ширина области"
L["Adjust the width of each unit's frame."] = "Регулировка ширины области."
L["Frame Height"] = "Высота области"
L["Adjust the height of each unit's frame."] = "Регулировка высоты области."
L["Border Size"] = "Размер края"
L["Adjust the border of each unit's frame."] = "Регулировка края области."

L["Options for %s."] = " Опции для %s."
L["Toggle debugging for %s."] = "Показать отладку для %s."

L["Show Frame"] = "Показать Область"
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = "Установить отображение Gridа: 'Всегда', 'Группа' или 'Рейд'."
L["Always"] = "Всегда"
L["Grouped"] = "Группа"
L["Raid"] = "Рейд"

L["Layouts"] = "Местонахождение"
L["Layouts for each type of groups you're in."] = "Расположение для каждого типа групп при нахождении в."
L["Solo Layout"] = "Соло Расположение"
L["Select which layout to use for solo."] = "Выбирает расположение для соло."
L["Party Layout"] = "Расположение группы"
L["Select which layout to use for party."] = "Выбирает расположение для группы."
L["Raid Layout"] = "Расположение рейда"
L["Raid 40 Layout"] = "Расположение рейда в 40чел"
L["Select which layout to use for raid."] = "Выбирает расположение для рейда."
L["Heroic Raid Layout"] = "Расположение в героике"
L["Select which layout to use for raid in heroic mode."] = "Выбирает расположение для героического подземелья."
L["Battleground Layout"] = "Расположение для полей битв"
L["Select which layout to use for battlegrounds."] = "Выбирает расположение для полей битв."
L["Arena Layout"] = "Расположение для арены"
L["Select which layout to use for arenas."] = "Выбирает расположение для арен."

L["Horizontal groups"] = "Группы горизонтально"
L["Switch between horzontal/vertical groups."] = "Переключить между группы вертикально/горизонтально."
L["Clamped to screen"] = "В пределах экрана"
L["Toggle whether to permit movement out of screen."] = "Не позволять перемещать окно за пределы экрана."
L["Frame lock"] = "Закрепить область"
L["Locks/unlocks the grid for movement."] = "Закрепить/открепить окно для передвижения."
L["Click through the Grid Frame"] = "Выбирать через окно Grid"
L["Allows mouse click through the Grid Frame."] = "Разрешает мышкой кликать сквозь окно Grid."

L["Display"] = "Отображение"
L["Padding"] = "Заполнение"
L["Adjust frame padding."] = "Настройка заполнения области."
L["Spacing"] = "Промежуток"
L["Adjust frame spacing."] = "Настройка промежутка фрейма."
L["Scale"] = "Масштаб"
L["Adjust Grid scale."] = "Настройка масштаба Gridа."

L["Border"] = "Граница"
L["Adjust border color and alpha."] = "Настройка цвет границы и прозрачность."
L["Background"] = "Фон"
L["Adjust background color and alpha."] = "Настройка цвета фона и прозрачности."

L["Layout Anchor"] = "Нахождение якоря"
L["Sets where Grid is anchored relative to the screen."] = "Настривает где якорь Grid будет находиться на экране."

L["CENTER"] = "ЦЕНТР"
L["TOP"] = "ВЕРХ"
L["BOTTOM"] = "ОСНОВАНИЕ"
L["LEFT"] = "СЛЕВА"
L["RIGHT"] = "СПРАВА"
L["TOPLEFT"] = "ВВЕРХУ СЛЕВА"
L["TOPRIGHT"] = "ВВЕРХУ СПРАВА"
L["BOTTOMLEFT"] = "СНИЗУ СЛЕВА"
L["BOTTOMRIGHT"] = "СНИЗУ СПРАВА"

L["corner-top-left"] = "в верхнем левом углу"
L["corner-top-right"] = "в верхнем правом углу"
L["corner-bottom-left"] = "в нижнем левом углу"
L["corner-bottom-right"] = "в нижнем правом углу"
L["side-left"] = "по краю-влево"
L["side-right"] = "по краю-вправо"
L["side-top"] = "по краю-вверх"
L["side-bottom"] = "по краю-вниз"
L["side-bottom-left"] = "side-bottom-left"
L["side-bottom-right"] = "side-bottom-right"
L["center"] = "по центру"
L["center-left"] = "по центру-влево"
L["center-right"] = "по центру-вправо"
L["center-top"] = "по центру-вверху"
L["center-bottom"] = "по центру-внизу"

L["charmed"] = "зачарованн"
L["classcolor"] = "цвет-класса"
L["death"] = "труп"
L["feign-death"] = "притворяется"
L["healing-impossible"] = "исцеление-невозможно"
L["healing-prevented"] = "исцеление-предотвращёно"
L["healing-reduced"] = "исцеление-подавлено"
L["heals-incoming"] = "входящее-исцеление"
L["health"] = "здоровье"
L["health-deficit"] = "нехватка-здоровья"
L["health-low"] = "мало-здоровья"
L["lowmana"] = "мало-маны"
L["mana"] = "мана"
L["name"] = "название"
L["offline"] = "вне-сети"
L["pvp"] = "pvp"
L["range"] = "радиус"
L["ready-check"] = "проверка-готовности"
L["target"] = "цель"
L["threat"] = "угроза"
L["vehicle"] = "транспорт"
L["voice"] = "голос"

L["Beast"] = "Животное"
L["Demon"] = "Демон"
L["Humanoid"] = "Гуманоид"
L["Elemental"] = "Элементаль"

L["DEATHKNIGHT"] = "Рыцарь смерти"
L["DRUID"] = "Друид"
L["HUNTER"] = "Охотница"
L["MAGE"] = "Маг"
L["PALADIN"] = "Паладин"
L["PRIEST"] = "Жрица"
L["ROGUE"] = "Разбойница"
L["SHAMAN"] = "Шаманка"
L["WARLOCK"] = "Чернокнижница"
L["WARRIOR"] = "Воин"

L["<CharacterOnlyString>"] = "<CharacterOnlyString>"
L["+"] = "+"
L["-"] = "-"
L["Align Point"] = "Точка выравнивания"
L["Align this point on the indicator"] = "Выравнивание данной точки на индикаторе"
L["Align relative to"] = "Выровнять по отношению к"
L["Align my align point relative to"] = "Выровнять мою точки относительн к"
L["Available Statuses"] = "Доступные статусы"
L["Available statuses you may add"] = "Доступные статусы которые вы можете добавить на индикатор"
L["Blink Threshold"] = "Порог мерцания"
L["Blink Threshold at which to start blinking the status."] = "Порог мерцания, при котором будет начинать мерцание статуса."
L["Class Filter"] = "Фильтр классов"
L["Create a new category of statuses."] = "Создать новую категорию статусов."
L["Create a new indicator."] = "Создать новый индикатор."
L["Create a new location for an indicator."] = "Создать новое расположение индикатора."
L["Create a new status."] = "Создать новый статус."
L["Current Statuses"] = "Текущие статусы"
L["Current statuses in order of priority"] = "Текущий статус в индикаторе, в порядке очередности"
L["Delete"] = "Удалить"
L["Display status only if the buff is not active."] = "Показывать статус только если баффы не активны."
L["Display status only if the buff was cast by you."] = "Показывать статус только если баффы применяются на вас"
L["Down"] = "Вниз"
L["Location"] = "Расположение"
L["Move the status higher in priority"] = "Переместитт статус выше по приоритету"
L["Move the status lower in priority"] = "Переместитт статус ниже по приоритету"
L["Name"] = "Название"
L["Name of the new indicator"] = "Название нового индикатора"
L["New Category"] = "Новая категория"
L["New Indicator"] = "Новый индикатор"
L["New Location"] = "Новое расположение"
L["New Status"] = "Новый статус"
L["Reset"] = "Сброс"
L["Reset and ReloadUI."] = "Сброс и перезагрузка UI"
L["Reset Categories"] = "Сброс категорий"
L["Reset categories to the default list."] = "Сброс категорий на стандартный список."
L["Reset Indicators"] = "Сброс индикаторов"
L["Reset indicators to defaults."] = "Сбросить индикаторы на стандартные."
L["Reset Locations"] = "Сброс расположения"
L["Reset locations to the default list."] = "Сбросить расположения на стандартные."
L["Reset Statuses"] = "Сброс статусов"
L["Reset statuses to defaults."] = "Сбросить статусы на стандартные."
L["Select statuses to display with the indicator"] = "Выберите статусы которые будут отображаться на индикаторе."
L["Select the location of the indicator"] = "Выберите расположение индикатора."
L["Show duration"] = "Длительность"
L["Show if mine"] = "Показать если моё"
L["Show if missing"] = "Показывать если пропущен"
L["Show on %s."] = "Показать на %s."
L["Show status for the selected classes."] = "Показывает статус для выбранных классов."
L["Show the time remaining."] = "Показывать оставшееся время."
L["Threshold"] = "Порог"
L["Threshold at which to activate the status."] = "Порог, при котором активируется статус."
L["Type"] = "Тип"
L["Type of indicator to create"] = "Тип создаваемого индикатора"
L["Up"] = "Вверх"
L["X Offset"] = "Смещение по Х"
L["X - Horizontal Offset"] = "Х - смещение по горизонтале"
L["Y Offset"] = "Смещение по У"
L["Y - Vertical Offset"] = "У - смещение по вертикале"

L["Group Anchor"] = "Якорь группы"
L["Position and Anchor"] = "Позиция и якорь"
L["Sets where groups are anchored relative to the layout frame."] = "Настройка местоположения якорей групп относительно расположения области."
L["Resets the layout frame's position and anchor."] = "Обновляет позицию области и якоря."

L["Center Text Length"] = "Длина текста в центре"
L["Number of characters to show on Center Text indicator."] = "Количество символов для отображения текста в центре."
L["Font Size"] = "Размер шрифта"
L["Adjust the font size."] = "Настривает размер шрифта."
L["Font"] = "Шрифт"
L["Adjust the font settings"] = "Настройки шрифта."
L["Frame Texture"] = "Текстура области"
L["Adjust the texture of each unit's frame."] = "настройка текстуры выбранной области для игрока."
L["Orientation of Frame"] = "Ориентация области"
L["Set frame orientation."] = "Настрйока ориентации области."
L["VERTICAL"] = "ВЕРТИКАЛЬНО"
L["HORIZONTAL"] = "ГОРИЗОНТАЛЬНО"

L["Icon Size"] = "Размер иконки"
L["Adjust the size of the center icon."] = "Настройка размера значка в центре."
L["Size"] = "Размер"
L["Adjust the size of the indicators."] = "Настрйока размера индикатора."

L["Blink effect"] = "Эффект мерцания"
L["Select the type of Blink effect used by Grid2."] = "Gвыьерите тип эффекта мерцания для использования в Grid2."
L["None"] = "Нет"
L["Blink"] = "Мерцания"
L["Flash"] = "Вспышка"
L["Blink Frequency"] = "Частота мерцания"
L["Adjust the frequency of the Blink effect."] = "Настройка частоты мерцания."

L["Color"] = "Цвет"
L["Color %d"] = "Цвет %d"
L["Color for %s."] = "Цвет для %s."
L["Color Charmed Unit"] = "Цвет Околдованных Игроков"
L["Color Units that are charmed."] = "Цвет для игроков попавший под разные отрицательные дебаффы и контроль."
L["Unit Colors"] = "Цвет игроков"
L["Charmed unit Color"] = "цвет околодованных игроков"
L["Default unit Color"] = "Цвета игроков по умолчанию"
L["Default pet Color"] = "Цвета питомцев по умолчанию"
L["%s Color"] = "%s цвет"
L["Show dead as having Full Health"] = "Показывать мертвого как полным здоровьем"
L["Default alpha"] = "Прозрачность по умолчанию"
L["Default alpha value when units are way out of range."] = "Прозрачность по умолчанию в зависимости от дапозона"
L["Update rate"] = "Частота обновления"
L["Rate at which the range gets updated"] = "Частота при которой обновляется диапозон"
L["Invert Bar Color"] = "Обратить цвет панели"
L["Swap foreground/background colors on bars."] = "Меняет местами окраску передниего плана/заднего на панели."
