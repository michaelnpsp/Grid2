local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "zhTW")
if not L then return end

--{{{ Actually used
L["Border"] = "邊框"
L["Charmed"] = "Charmed"
L["Default"] = "Default"
L["Drink"] = "Drink"
L["Food"] = "Food"
L["Grid2"] = "Grid2"
--}}}

--{{{ GridCore
L["Configure"] = "配置"
L["Configure Grid"] = "配置 Grid"
--}}}

--{{{ GridFrame
L["Frame"] = "框架"
L["Options for GridFrame."] = "Grid 框架選項"

L["Indicators"] = "提示器"
L["Health Bar"] = "生命條"
L["Health Bar Color"] = "生命條顏色"
L["Center Text"] = "中央顏色"
L["Center Text 2"] = "中央文字2"
L["Center Icon"] = "中央圖示"
L["Top Left Corner"] = "左上角"
L["Top Right Corner"] = "右上角"
L["Bottom Left Corner"] = "左下角"
L["Bottom Right Corner"] = "右下角"
L["Frame Alpha"] = "框架透明度"

L["Options for %s indicator."] = "%s提示器選項。"
L["Statuses"] = "狀態"
L["Toggle status display."] = "打開/關閉顯示狀態。"

-- Advanced options
L["Enable %s indicator"] = "啟用%s指示器"
L["Toggle the %s indicator."] = "打開/關閉%s指示器。"
L["Orientation of Text"] = "文字排列方式"
L["Set frame text orientation."] = "設定框架文字排列方式。"
--}}}

--{{{ GridLayout
L["Layout"] = "佈局"
L["Options for GridLayout."] = "Grid 佈局選項。"

-- Display options
L["Pet color"] = "寵物顏色"
L["Set the color of pet units."] = "設定寵物單位顏色。"
L["Pet coloring"] = "寵物顏色"
L["Set the coloring strategy of pet units."] = "設定寵物單位顏色策略。"
L["By Owner Class"] = "以主人的職業顏色"
L["By Creature Type"] = "以種類"
L["Using Fallback color"] = "使用後備顏色"
L["Beast"] = "野獸"
L["Demon"] = "惡魔"
L["Humanoid"] = "人型"
L["Elemental"] = "元素"
L["Colors"] = "顏色"
L["Color options for class and pets."] = "玩家和寵物的顏色選項。"
L["Fallback colors"] = "已知顏色"
L["Color of unknown units or pets."] = "未知單位/寵物單位顏色。"
L["Unknown Unit"] = "未知單位"
L["The color of unknown units."] = "未知單位顏色。"
L["Unknown Pet"] = "未知寵物"
L["The color of unknown pets."] = "未知寵物的顏色。"
L["Class colors"] = "職業顏色"
L["Color of player unit classes."] = "玩家職業單位顏色。"
L["Creature type colors"] = "生物種類顏色"
L["Color of pet unit creature types."] = "寵物的生物種類單位的顏色。"
L["Color for %s."] = "%s的顏色。"

-- Advanced options
L["Advanced"] = "進階"
L["Advanced options."] = "進階選項。"
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
L["By Class"] = "職業"
L["By Class w/Pets"] = "職業以及寵物"
L["Onyxia"] = "單數雙數隊伍排列"
L["By Group 25 w/tanks"] = "25人團隊及坦克"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "(%d+)碼距離"
--}}}

--{{{ GridStatus
L["Status"] = "狀態"
L["Statuses"] = "狀態"

-- module prototype
L["Status: %s"] = "狀態：%s"
L["Color"] = "顏色"
L["Color for %s"] = "%s的顏色"
L["Priority"] = "優先度"
L["Priority for %s"] = "%s的優先度"
L["Range filter"] = "距離過濾"
L["Range filter for %s"] = "%s的距離過濾"
L["Enable"] = "啟用"
L["Enable %s"] = "啟用%s"
--}}}

--{{{ GridStatusAggro
L["Aggro"] = "仇恨"
L["Aggro alert"] = "仇恨警報"
--}}}

--{{{ GridStatusAuras
L["Auras"] = "光環"
L["Debuff type: %s"] = "減益類型：%s"
L["Poison"] = "毒藥"
L["Disease"] = "疾病"
L["Magic"] = "魔法"
L["Curse"] = "詛咒"
L["Ghost"] = "幽靈"
L["Add new Buff"] = "添加新的增益"
L["Adds a new buff to the status module"] = "狀態模組添加一個新的增益"
L["<buff name>"] = "<增益名稱>"
L["Add new Debuff"] = "添加新的減益"
L["Adds a new debuff to the status module"] = "狀態模組添加一個新的減益"
L["<debuff name>"] = "<減益名稱>"
L["Delete (De)buff"] = "刪除增（減）益"
L["Deletes an existing debuff from the status module"] = "刪除狀態模組內已有的一個增（減）益"
L["Remove %s from the menu"] = "從列表中移除%s"
L["Debuff: %s"] = "減益：%s"
L["Buff: %s"] = "增益：%s"
L["Class Filter"] = "職業過濾"
L["Show status for the selected classes."] = "顯示選定職業的狀態。"
L["Show on %s."] = "在%s上顯示。"
L["Show if missing"] = "缺少時顯示"
L["Display status only if the buff is not active."] = "僅在增益缺少時才顯示狀態。"
L["Filter Abolished units"] = "過濾無效單位"
L["Skip units that have an active Abolish buff."] = "忽略單位上存在無效效果。" --try...
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

--{{{ GridStatusHeals
L["Heals"] = "治療"
L["Incoming heals"] = "正被治療"
L["Ignore Self"] = "忽略自己"
L["Ignore heals cast by you."] = "忽略對自己施放的治療。"
L["(.+) begins to cast (.+)."] = "(.+)開始施放(.+)。" --test
L["(.+) gains (.+) Mana from (.+)'s Life Tap."] = "(.+)從(.+)的生命分流獲得(.+)點法力值。" --test
L["^Corpse of (.+)$"] = "(.+)的屍體。$" --test
--}}}

--{{{ GridStatusHealth
L["Low HP"] = "低血量"
L["DEAD"] = "死亡"
L["GHOST"] = "靈魂"
L["FD"] = "假死"
L["Offline"] = "離線"
L["Unit health"] = "單位生命值"
L["Health deficit"] = "損失的生命值"
L["Low HP warning"] = "低生命值警報"
L["Feign Death warning"] = "假死提示"
L["Death warning"] = "死亡警報"
L["Offline warning"] = "離線警報"
L["Health"] = "生命值"
L["Show dead as full health"] = "把死亡的顯示為滿血"
L["Treat dead units as being full health."] = "把死亡的單位顯示為滿血。"
L["Use class color"] = "使用職業顏色"
L["Color health based on class."] = "用職業顏色來顯示生命值。"
L["Health threshold"] = "生命值臨界點"
L["Only show deficit above % damage."] = "只顯示已經損失了%的生命值。"
L["Color deficit based on class."] = "用職業顏色來顯示損失的生命值。"
L["Low HP threshold"] = "低生命值臨界點"
L["Set the HP % for the low HP warning."] = "設定低生命值警報的臨界點。"
--}}}

--{{{ GridStatusPvp
L["PvP"] = "PvP"
L["FFA"] = "FFA"
--}}}

--{{{ GridStatusRange
L["Range check frequency"] = "距離檢測的頻率"
L["Seconds between range checks"] = "多少秒檢測一次距離"
L["Out of Range"] = "超出距離"
L["OOR"] = "遠"
L["Range to track"] = "距離跟蹤"
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
L["vehicle"] = "vehicle"
--}}}

--{{{ GridStatusVoiceComm
L["talking"] = "正在說話"
--}}}
