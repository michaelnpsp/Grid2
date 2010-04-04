local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "zhCN")
if not L then return end

--{{{ Actually used
L["Border"] = "边框"
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
L["Options for GridFrame."] = "Grid 框架选项"

L["Indicators"] = "提示器"
L["Health Bar"] = "生命条"
L["Health Bar Color"] = "生命条颜色"
L["Center Text"] = "中心文字"
L["Center Text 2"] = "中心文字2"
L["Center Icon"] = "中心图标"
L["Top Left Corner"] = "左上角"
L["Top Right Corner"] = "右上角"
L["Bottom Left Corner"] = "左下角"
L["Bottom Right Corner"] = "右下角"
L["Frame Alpha"] = "框架透明度"

L["Options for %s indicator."] = "%s提示器选项。"
L["Statuses"] = "状态"
L["Toggle status display."] = "打开/关闭显示状态。"

-- Advanced options
L["Enable %s indicator"] = "启用%s指示器"
L["Toggle the %s indicator."] = "打开/关闭%s指示器。"
L["Orientation of Text"] = "文字排列方式"
L["Set frame text orientation."] = "设置框架文字排列方式。"
--}}}

--{{{ GridLayout
L["Layout"] = "布局"
L["Options for GridLayout."] = "Grid 布局选项。"

-- Display options
L["Pet color"] = "宠物颜色"
L["Set the color of pet units."] = "设置宠物单位颜色。"
L["Pet coloring"] = "宠物颜色"
L["Set the coloring strategy of pet units."] = "设置宠物单位颜色策略。"
L["By Owner Class"] = "以主人的职业颜色"
L["By Creature Type"] = "以种类"
L["Using Fallback color"] = "使用后备颜色"
L["Beast"] = "野兽"
L["Demon"] = "恶魔"
L["Humanoid"] = "人型"
L["Elemental"] = "元素"
L["Colors"] = "颜色"
L["Color options for class and pets."] = "玩家和宠物的颜色选项。"
L["Fallback colors"] = "已知颜色"
L["Color of unknown units or pets."] = "未知单位/宠物单位颜色。"
L["Unknown Unit"] = "未知单位"
L["The color of unknown units."] = "未知单位颜色。"
L["Unknown Pet"] = "未知宠物"
L["The color of unknown pets."] = "未知宠物的颜色。"
L["Class colors"] = "职业颜色"
L["Color of player unit classes."] = "玩家职业单位颜色。"
L["Creature type colors"] = "生物种类颜色"
L["Color of pet unit creature types."] = "宠物的生物种类单位的颜色。"
L["Color for %s."] = "%s的颜色。"

-- Advanced options
L["Advanced"] = "高级"
L["Advanced options."] = "高级选项。"
--}}}

--{{{ GridLayoutLayouts
L["None"] = "无"
L["Solo"] = "单人"
L["Solo w/Pet"] = "单人以及宠物"
L["By Group 5"] = "5人小队"
L["By Group 5 w/Pets"] = "5人小队以及宠物"
L["By Group 40"] = "40人团队"
L["By Group 25"] = "25人团队"
L["By Group 25 w/Pets"] = "25人团队以及宠物"
L["By Group 20"] = "20人团队"
L["By Group 15"] = "15人团队"
L["By Group 15 w/Pets"] = "15人团队以及宠物"
L["By Group 10"] = "10人团队"
L["By Group 10 w/Pets"] = "10人团队以及宠物"
L["By Class"] = "职业"
L["By Class w/Pets"] = "职业以及宠物"
L["Onyxia"] = "单数双数队伍排列"
L["By Group 25 w/tanks"] = "25人团队及 Tank"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "(%d+)码射程"
--}}}

--{{{ GridStatus
L["Status"] = "状态"
L["Statuses"] = "状态"

-- module prototype
L["Status: %s"] = "状态：%s"
L["Color"] = "颜色"
L["Color for %s"] = "%s的颜色"
L["Priority"] = "优先度"
L["Priority for %s"] = "%s的优先度"
L["Range filter"] = "距离过滤"
L["Range filter for %s"] = "%s的距离过滤"
L["Enable"] = "启用"
L["Enable %s"] = "启用%s"
--}}}

--{{{ GridStatusAggro
L["Aggro"] = "仇恨"
L["Aggro alert"] = "仇恨警报"
--}}}

--{{{ GridStatusAuras
L["Auras"] = "光环"
L["Debuff type: %s"] = "减益类型：%s"
L["Poison"] = "毒药"
L["Disease"] = "疾病"
L["Magic"] = "魔法"
L["Curse"] = "诅咒"
L["Ghost"] = "幽灵"
L["Add new Buff"] = "添加新的增益"
L["Adds a new buff to the status module"] = "状态模块添加一个新的增益"
L["<buff name>"] = "<增益名称>"
L["Add new Debuff"] = "添加新的减益"
L["Adds a new debuff to the status module"] = "状态模块添加一个新的减益"
L["<debuff name>"] = "<减益名称>"
L["Delete (De)buff"] = "删除增（减）益"
L["Deletes an existing debuff from the status module"] = "删除状态模块内已有的一个增（减）益"
L["Remove %s from the menu"] = "从列表中移除%s"
L["Debuff: %s"] = "减益：%s"
L["Buff: %s"] = "增益：%s"
L["Class Filter"] = "职业过滤"
L["Show status for the selected classes."] = "显示选定职业的状态。"
L["Show on %s."] = "在%s上显示。"
L["Show if missing"] = "缺少时显示"
L["Display status only if the buff is not active."] = "仅在增益缺少时才显示状态。"
L["Filter Abolished units"] = "过滤无效单位"
L["Skip units that have an active Abolish buff."] = "忽略单位上存在无效效果。" --try...
--}}}

--{{{ GridStatusName
L["Unit Name"] = "单位名字"
L["Color by class"] = "使用职业颜色"
--}}}

--{{{ GridStatusMana
L["Mana"] = "法力"
L["Low Mana"] = "低法力"
L["Mana threshold"] = "法力临界点"
L["Set the percentage for the low mana warning."] = "设置低法力警报的临界点。"
L["Low Mana warning"] = "低法力警报"
--}}}

--{{{ GridStatusHeals
L["Heals"] = "治疗"
L["Incoming heals"] = "正被治疗"
L["Ignore Self"] = "忽略自己"
L["Ignore heals cast by you."] = "忽略对自己施放的治疗。"
L["(.+) begins to cast (.+)."] = "(.+)开始施放(.+)。" --test
L["(.+) gains (.+) Mana from (.+)'s Life Tap."] = "(.+)从(.+)的生命分流获得(.+)点法力值。" --test
L["^Corpse of (.+)$"] = "(.+)的尸体。$" --test
--}}}

--{{{ GridStatusHealth
L["Low HP"] = "低"
L["DEAD"] = "死"
L["GHOST"] = "魂"
L["FD"] = "假"
L["Offline"] = "离"
L["Unit health"] = "单位生命值"
L["Health deficit"] = "损失的生命值"
L["Low HP warning"] = "低生命值警报"
L["Feign Death warning"] = "假死提示"
L["Death warning"] = "死亡警报"
L["Offline warning"] = "掉线警报"
L["Health"] = "生命值"
L["Show dead as full health"] = "把死亡的显示为满血"
L["Treat dead units as being full health."] = "把死亡的单位显示为满血。"
L["Use class color"] = "使用职业颜色"
L["Color health based on class."] = "用职业颜色来显示生命值。"
L["Health threshold"] = "生命值临界点"
L["Only show deficit above % damage."] = "只显示已经损失了%的生命值。"
L["Color deficit based on class."] = "用职业颜色来显示损失的生命值。"
L["Low HP threshold"] = "低生命值临界点"
L["Set the HP % for the low HP warning."] = "设置低生命值警报的临界点。"
--}}}

--{{{ GridStatusPvp
L["PvP"] = "PvP"
L["FFA"] = "FFA"
--}}}

--{{{ GridStatusRange
L["Range check frequency"] = "距离检测的频率"
L["Seconds between range checks"] = "多少秒检测一次距离"
L["Out of Range"] = "超出距离"
L["OOR"] = "远"
L["Range to track"] = "距离跟踪"
--}}}

--{{{ GridStatusReadyCheck
L["?"] = "？"
L["R"] = "是"
L["X"] = "否"
L["AFK"] = "暂离"
--}}}

--{{{ GridStatusTarget
L["target"] = "目标"
--}}}

--{{{ GridStatusVehicle
L["vehicle"] = "vehicle"
--}}}

--{{{ GridStatusVoiceComm
L["talking"] = "正在说话"
--}}}
