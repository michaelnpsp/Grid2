﻿local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "zhTW")
if not L then return end

L["Debug"] = "除錯"
L["Debugging"] = "除錯"
L["Module debugging menu."] = "除錯模組菜單。"

L["Show Tooltip"] = "顯示提示訊息"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "顯示單位框架的提示訊息。選擇“總是”，“不顯示”或“非戰鬥”。"
L["Always"] = "總是"
L["Never"] = "不顯示"
L["OOC"] = "非戰斗"

L["location"] = "location"
L["indicator"] = "indicator"
L["status"] = "status"

L["Advanced"] = "進階"
L["Advanced options."] = "進階選項。"

L["Frame Width"] = "框架寬度"
L["Adjust the width of each unit's frame."] = "調整個體框架的寬度。"
L["Frame Height"] = "框架高度"
L["Adjust the height of each unit's frame."] = "調整個體框架的高度。"
L["Border Size"] = "Frame Border"
L["Adjust the border of each unit's frame."] = "Adjust the border of each unit's frame."

L["Options for %s."] = "%s狀態的選項。"
L["Toggle debugging for %s."] = "打開/關閉%s的除错。"

L["Show Frame"] = "顯示框架"
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = "選擇什么時候顯示 Grid：“總是”，“組隊”或“團隊”。"
L["Always"] = "總是"
L["Grouped"] = "組隊"
L["Raid"] = "團隊"

L["Layouts"] = "佈局"
L["Layouts for each type of groups you're in."] = "你所在組的佈局類型。"
L["Solo Layout"] = "單人佈局"
L["Select which layout to use for solo."] = "選擇使用哪個單人佈局。"
L["Party Layout"] = "隊伍佈局"
L["Select which layout to use for party."] = "選擇使用哪個隊伍佈局。"
L["Raid Layout"] = "團隊佈局"
L["Select which layout to use for raid."] = "選擇使用哪個團隊佈局。"
L["Battleground Layout"] = "戰場佈局"
L["Select which layout to use for battlegrounds."] = "選擇使用哪個戰場佈局。"
L["Arena Layout"] = "競技場佈局"
L["Select which layout to use for arenas."] = "選擇使用哪個競技場佈局。"

L["Horizontal groups"] = "橫向排列隊伍"
L["Switch between horzontal/vertical groups."] = "選擇橫向/豎向排列隊伍。"
L["Clamped to screen"] = "限制在螢幕內"
L["Toggle whether to permit movement out of screen."] = "打開/關閉是否允許把框架移到超出螢幕的位置。"
L["Frame lock"] = "鎖定框架"
L["Locks/unlocks the grid for movement."] = "鎖定/解鎖 Grid 框架來讓其移動。"
L["Click through the Grid Frame"] = "透過 Grid 框架點擊"
L["Allows mouse click through the Grid Frame."] = "是否允許滑鼠透過 Grid 框架點擊。"

L["Display"] = "顯示"
L["Padding"] = "填白"
L["Adjust frame padding."] = "調整框架填白。"
L["Spacing"] = "空隙"
L["Adjust frame spacing."] = "調整框架空隙。"
L["Scale"] = "縮放"
L["Adjust Grid scale."] = "調整框架縮放。"

L["Border"] = "邊框"
L["Adjust border color and alpha."] = "調整邊框的顏色和透明度。"
L["Background"] = "背景"
L["Adjust background color and alpha."] = "調整背景顏色和透明度。"

L["Layout Anchor"] = "佈局錨點"
L["Sets where Grid is anchored relative to the screen."] = "設定螢幕中 Grid 的錨點。"

L["CENTER"] = "中央"
L["TOP"] = "頂部"
L["BOTTOM"] = "底部"
L["LEFT"] = "左側"
L["RIGHT"] = "右側"
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

L["Beast"] = "野獸"
L["Demon"] = "惡魔"
L["Humanoid"] = "人型"
L["Elemental"] = "元素"

L["DEATHKNIGHT"] = "死亡騎士"
L["DRUID"] = "德魯伊"
L["HUNTER"] = "獵人"
L["MAGE"] = "法師"
L["PALADIN"] = "聖騎士"
L["PRIEST"] = "牧師"
L["ROGUE"] = "盜賊"
L["SHAMAN"] = "薩滿"
L["WARLOCK"] = "術士"
L["WARRIOR"] = "戰士"

L["Class Filter"] = "職業過濾"
L["Display status only if the buff is not active."] = "當缺少增益時提示。"
L["Display status only if the buff was cast by you."] = "顯示只有你所施放的增益。"
L["Show duration"] = "顯示持續時間"
L["Show if mine"] = "顯示我的"
L["Show if missing"] = "顯示缺少"
L["Show on %s."] = "在%s上顯示。"
L["Show status for the selected classes."] = "顯示選定職業的狀態。"
L["Show the time remaining."] = "在圖示中顯示持續時間。"

L["Group Anchor"] = "隊伍錨點"
L["Position and Anchor"] = "Position and Anchor"
L["Sets where groups are anchored relative to the layout frame."] = "設定佈局中隊伍的錨點。"
L["Resets the layout frame's position and anchor."] = "重置佈局框架的位置和錨點。"

L["Center Text Length"] = "中间文字长度"
L["Number of characters to show on Center Text indicator."] = "中央文字提示器所顯示文字的長度。"
L["Font Size"] = "字型大小"
L["Adjust the font size."] = "調整字型尺寸。"
L["Font"] = "字型"
L["Adjust the font settings"] = "調整字型設定"
L["Frame Texture"] = "框架材質"
L["Adjust the texture of each unit's frame."] = "調整個體框架的材質。"
L["Orientation of Frame"] = "框架方向"
L["Set frame orientation."] = "設定框架方向。"
L["VERTICAL"] = "豎直"
L["HORIZONTAL"] = "水平"

L["Icon Size"] = "圖示大小"
L["Adjust the size of the center icon."] = "調整中央圖示的尺寸。"
L["Size"] = "邊角大小"
L["Adjust the size of the indicators."] = "調整边角指示器的大小。"

L["Blink effect"] = "閃爍效果"
L["Select the type of Blink effect used by Grid2."] = "選擇 Grid2 閃爍效果。"
L["None"] = "無"
L["Blink"] = "閃爍"
L["Flash"] = "閃光"
L["Blink Frequency"] = "閃爍頻率"
L["Adjust the frequency of the Blink effect."] = "調整閃爍效果頻率。"

L["Color"] = "顏色"
L["Color for %s."] = "%s的顏色。"
L["Color Charmed Unit"] = "高亮被魅惑單位"
L["Color Units that are charmed."] = "高亮顯示被魅惑單位。"
L["Unit Colors"] = "單位顏色"
L["Charmed unit Color"] = "被魅惑單位顏色"
L["Default unit Color"] = "默認單位顏色"
L["Default pet Color"] = "默認寵物顏色"
L["%s Color"] = "%s顏色"
L["Show dead as having Full Health"] = "顯示死亡或生命值全滿"
L["Default alpha"] = "默認透明度"
L["Default alpha value when units are way out of range."] = "当單位超出距離市的默認透明度。"
L["Update rate"] = "更新速度"
L["Rate at which the range gets updated"] = "距離獲取的更新速度。"
L["Invert Bar Color"] = "反轉顏色"
L["Swap foreground/background colors on bars."] = "反轉提示條上背景/前景的顏色。"
