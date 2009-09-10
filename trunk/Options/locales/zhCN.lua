﻿local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "zhCN")
if not L then return end

L["Debug"] = "除错"
L["Debugging"] = "除错"
L["Module debugging menu."] = "除错模块菜单。"

L["Show Tooltip"] = "显示提示信息"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "显示单位框架的提示信息。选择“一直”，“不显示”或“非战斗”。"
L["Always"] = "一直"
L["Never"] = "不显示"
L["OOC"] = "非战斗"

L["location"] = "location"
L["indicator"] = "indicator"
L["status"] = "status"

L["Advanced"] = "高级"
L["Advanced options."] = "高级选项。"

L["Frame Width"] = "框架宽度"
L["Adjust the width of each unit's frame."] = "调整个体框架的宽度。"
L["Frame Height"] = "框架高度"
L["Adjust the height of each unit's frame."] = "调整个体框架的高度。"
L["Border Size"] = "Frame Border"
L["Adjust the border of each unit's frame."] = "Adjust the border of each unit's frame."

L["Options for %s."] = "%s状态的选项。"
L["Toggle debugging for %s."] = "打开/关闭%s的除错。"

L["Show Frame"] = "显示框架"
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = "选择什么时候显示 Grid：“一直”，“组队”或“团队”。"
L["Always"] = "一直"
L["Grouped"] = "组队"
L["Raid"] = "团队"

L["Layouts"] = "布局"
L["Layouts for each type of groups you're in."] = "你所在组的布局类型。"
L["Solo Layout"] = "单人布局"
L["Select which layout to use for solo."] = "选择使用哪个单人布局。"
L["Party Layout"] = "小队布局"
L["Select which layout to use for party."] = "选择使用哪个小队布局。"
L["Raid Layout"] = "团队布局"
L["Select which layout to use for raid."] = "选择使用哪个团队布局。"
L["Battleground Layout"] = "战场布局"
L["Select which layout to use for battlegrounds."] = "选择使用哪个战场布局。"
L["Arena Layout"] = "竞技场布局"
L["Select which layout to use for arenas."] = "选择使用哪个竞技场布局。"

L["Horizontal groups"] = "横向排列队伍"
L["Switch between horzontal/vertical groups."] = "选择横向/竖向排列队伍。"
L["Clamped to screen"] = "限制在屏幕內"
L["Toggle whether to permit movement out of screen."] = "打开/关闭是否允许把框架移到超出屏幕的位置。"
L["Frame lock"] = "锁定框架"
L["Locks/unlocks the grid for movement."] = "锁定/解锁 Grid 框架来让其移动。"
L["Click through the Grid Frame"] = "透过 Grid 框体点击"
L["Allows mouse click through the Grid Frame."] = "是否允许鼠标透过 Grid 框体点击。"

L["Display"] = "显示"
L["Padding"] = "填白"
L["Adjust frame padding."] = "调整框架填白。"
L["Spacing"] = "空隙"
L["Adjust frame spacing."] = "调整框架空隙。"
L["Scale"] = "缩放"
L["Adjust Grid scale."] = "调整框架缩放。"

L["Border"] = "边框"
L["Adjust border color and alpha."] = "调整边框的颜色和透明度。"
L["Background"] = "背景"
L["Adjust background color and alpha."] = "调整背景颜色和透明度。"

L["Layout Anchor"] = "布局锚点"
L["Sets where Grid is anchored relative to the screen."] = "设置屏幕中 Grid 的锚点。"

L["CENTER"] = "中心"
L["TOP"] = "顶部"
L["BOTTOM"] = "底部"
L["LEFT"] = "左侧"
L["RIGHT"] = "右侧"
L["TOPLEFT"] = "左上"
L["TOPRIGHT"] = "右上"
L["BOTTOMLEFT"] = "左下"
L["BOTTOMRIGHT"] = "右下"

L["corner-top-left"] = "corner-top-left"
L["corner-top-right"] = "corner-top-right"
L["corner-bottom-left"] = "corner-bottom-left"
L["corner-bottom-right"] = "corner-bottom-right"
L["side-left"] = "side-left"
L["side-right"] = "side-right"
L["side-top"] = "side-top"
L["side-bottom"] = "side-bottom"
L["side-bottom-left"] = "side-bottom-left"
L["side-bottom-right"] = "side-bottom-right"
L["center"] = "center"
L["center-left"] = "center-left"
L["center-right"] = "center-right"
L["center-top"] = "center-top"
L["center-bottom"] = "center-bottom"

L["charmed"] = "charmed"
L["classcolor"] = "classcolor"
L["death"] = "death"
L["feign-death"] = "feign-death"
L["healing-impossible"] = "healing-impossible"
L["healing-prevented"] = "healing-prevented"
L["healing-reduced"] = "healing-reduced"
L["heals-incoming"] = "heals-incoming"
L["health"] = "health"
L["health-deficit"] = "health-deficit"
L["health-low"] = "health-low"
L["lowmana"] = "lowmana"
L["mana"] = "mana"
L["name"] = "name"
L["offline"] = "offline"
L["pvp"] = "pvp"
L["range"] = "range"
L["ready-check"] = "ready-check"
L["target"] = "target"
L["threat"] = "threat"
L["vehicle"] = "vehicle"
L["voice"] = "voice"

L["Beast"] = "野兽"
L["Demon"] = "恶魔"
L["Humanoid"] = "人型"
L["Elemental"] = "元素"

L["DEATHKNIGHT"] = "死亡骑士"
L["DRUID"] = "德鲁伊"
L["HUNTER"] = "猎人"
L["MAGE"] = "法师"
L["PALADIN"] = "圣骑士"
L["PRIEST"] = "牧师"
L["ROGUE"] = "潜行者"
L["SHAMAN"] = "萨满祭司"
L["WARLOCK"] = "术士"
L["WARRIOR"] = "战士"

L["%d yards"] = "%d码"
L["Class Filter"] = "职业过滤"
L["Display status only if the buff is not active."] = "仅在增益缺少时才显示状态。"
L["Display status only if the buff was cast by you."] = "显示你施放增益时的状态。"
L["Range"] = "距离"
L["Range in yards beyond which the status will be lost."] = "超出距离以外的状态都将丢失。"
L["Show duration"] = "显示持续效果"
L["Show if mine"] = "显示自身"
L["Show if missing"] = "缺少时显示"
L["Show on %s."] = "在%s上显示。"
L["Show status for the selected classes."] = "显示选定职业的状态。"
L["Show the time remaining."] = "显示的剩余时间。"

L["Group Anchor"] = "队伍锚点"
L["Position and Anchor"] = "Position and Anchor"
L["Sets where groups are anchored relative to the layout frame."] = "设置布局中队伍的锚点。"
L["Resets the layout frame's position and anchor."] = "重置布局框架的位置和锚点。"

L["Center Text Length"] = "中间文字长度"
L["Number of characters to show on Center Text indicator."] = "中间文字提示器所显示文字的长度。"
L["Font Size"] = "字体大小"
L["Adjust the font size."] = "调整字体尺寸。"
L["Font"] = "字体"
L["Adjust the font settings"] = "调整字体设置"
L["Frame Texture"] = "框架材质"
L["Adjust the texture of each unit's frame."] = "调整个体框架的材质。"
L["Orientation of Frame"] = "框架方向"
L["Set frame orientation."] = "设置框架方向。"
L["VERTICAL"] = "竖直"
L["HORIZONTAL"] = "水平"

L["Icon Size"] = "图标大小"
L["Adjust the size of the center icon."] = "调整中心图标的尺寸。"
L["Size"] = "边角大小"
L["Adjust the size of the indicators."] = "调整边角指示器的大小。"

L["Blink effect"] = "闪烁效果"
L["Select the type of Blink effect used by Grid2."] = "选择 Grid2 闪烁效果。"
L["None"] = "无"
L["Blink"] = "闪烁"
L["Flash"] = "闪光"
L["Blink Frequency"] = "闪烁频率"
L["Adjust the frequency of the Blink effect."] = "调整闪烁效果频率。"

L["Color"] = "颜色"
L["Color for %s."] = "%s的颜色。"
L["Color Charmed Unit"] = "高亮被魅惑单位"
L["Color Units that are charmed."] = "高亮显示被魅惑单位。"
L["Unit Colors"] = "单位颜色"
L["Charmed unit Color"] = "被魅惑单位颜色"
L["Default unit Color"] = "默认单位颜色"
L["Default pet Color"] = "默认宠物颜色"
L["%s Color"] = "%s颜色"
L["Show dead as having Full Health"] = "显示死亡或生命值全满"
L["Default alpha"] = "默认透明度"
L["Default alpha value when units are way out of range."] = "当单位超出距离时的默认透明度。"
L["Update rate"] = "更新速度"
L["Rate at which the range gets updated"] = "距离获取的更新速度。"
L["Invert Bar Color"] = "反转颜色"
L["Swap foreground/background colors on bars."] = "反转提示条上背景/前景的颜色。"
