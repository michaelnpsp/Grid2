local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "zhCN")
if not L then return end

--{{{ General options
L["GRID2_DESC"] = "Welcome to Grid2"

L["General Settings"] = "General Settings"

-- L["statuses"] = ""
-- L["indicators"] = ""

-- L["Frames"] = ""
L["frame"] = "frame"

L["Invert Bar Color"] = "反转颜色"
L["Swap foreground/background colors on bars."] = "反转提示条上背景/前景的颜色。"

-- L["Background Color"] = ""
-- L["Sets the background color of each unit frame"] = ""

L["Mouseover Highlight"] = "启用鼠标悬停高亮"
L["Toggle mouseover highlight."] = "打开/关闭鼠标悬停高亮。"

L["Show Tooltip"] = "显示提示信息"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "显示单位框架的提示信息。选择“一直”，“不显示”或“非战斗”。"
L["Always"] = "一直"
L["Never"] = "不显示"
L["OOC"] = "非战斗"

-- L["Background Texture"] = ""
-- L["Select the frame background texture."] = ""

-- L["Inner Border Size"] = ""
-- L["Sets the size of the inner border of each unit frame"] = ""

-- L["Inner Border Color"] = ""
-- L["Sets the color of the inner border of each unit frame"] = ""

L["Frame Width"] = "框架宽度"
L["Adjust the width of each unit's frame."] = "调整个体框架的宽度。"

L["Frame Height"] = "框架高度"
L["Adjust the height of each unit's frame."] = "调整个体框架的高度。"

L["Orientation of Frame"] = "框架方向"
L["Set frame orientation."] = "设置框架方向。"
L["VERTICAL"] = "竖直"
L["HORIZONTAL"] = "水平"

L["Orientation of Text"] = "文字方向"
L["Set frame text orientation."] = "设置文字方向。"

L["Show Frame"] = "显示框架"
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = "选择什么时候显示 Grid：“一直”，“组队”或“团队”。"
L["Always"] = "一直"
L["Grouped"] = "组队"
L["Raid"] = "团队"

L["Layout Anchor"] = "布局锚点"
L["Sets where Grid is anchored relative to the screen."] = "设置屏幕中 Grid 的锚点。"

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

L["Group Anchor"] = "队伍锚点"
L["Position and Anchor"] = "Position and Anchor"
L["Sets where groups are anchored relative to the layout frame."] = "设置布局中队伍的锚点。"
L["Resets the layout frame's position and anchor."] = "重置布局框架的位置和锚点。"

--blink
-- L["Misc"] = ""
L["blink"] = "blink"
L["Blink effect"] = "闪烁效果"
L["Select the type of Blink effect used by Grid2."] = "选择 Grid2 闪烁效果。"
L["None"] = "无"
L["Blink"] = "闪烁"
L["Flash"] = "闪光"
L["Blink Frequency"] = "闪烁频率"
L["Adjust the frequency of the Blink effect."] = "调整闪烁效果频率。"

-- debugging & maintenance
L["debugging"] = "除错"
L["Module debugging menu."] = "除错模块菜单。"
L["Debug"] = "除错"
L["Reset"] = "Reset"
L["Reset and ReloadUI."] = "Reset and ReloadUI."
L["Reset Setup"] = "Reset Setup"
L["Reset current setup and ReloadUI."] = "Reset current setup and ReloadUI."
L["Reset Indicators"] = "Reset Indicators"
L["Reset indicators to defaults."] = "Reset indicators to defaults."
L["Reset Locations"] = "Reset Locations"
L["Reset locations to the default list."] = "Reset locations to the default list."
-- L["Reset to defaults."] = ""
L["Reset Statuses"] = "Reset Statuses"
L["Reset statuses to defaults."] = "Reset statuses to defaults."

-- L["Warning! This option will delete all settings and profiles, are you sure ?"] = ""

-- L["About"] = ""

--{{{ Layouts options
-- L["Layout"] = ""
L["Layouts"] = "布局"
L["layout"] = "layout"
L["Layouts for each type of groups you're in."] = "你所在组的布局类型。"
-- L["Layout Settings"] = ""
L["Solo Layout"] = "单人布局"
L["Select which layout to use for solo."] = "选择使用哪个单人布局。"
L["Party Layout"] = "小队布局"
L["Select which layout to use for party."] = "选择使用哪个小队布局。"
L["Raid %s Layout"] = "团队布局 %s Layout"
L["Select which layout to use for %s person raids."] = "选择使用哪个团队布局。 %s person raids."
L["Battleground Layout"] = "战场布局"
L["Select which layout to use for battlegrounds."] = "选择使用哪个战场布局。"
L["Arena Layout"] = "竞技场布局"
L["Select which layout to use for arenas."] = "选择使用哪个竞技场布局。"
-- L["Test"] = ""
-- L["Test the layout."] = ""

--{{{ Miscelaneous
-- L["Name"] = ""
-- L["New"] = ""
-- L["Order"] = ""
-- L["Delete"] = ""
L["Color"] = "颜色"
-- L["Color %d"] = ""
L["Color for %s."] = "%s的颜色。"
L["Font"] = "字体"
L["Adjust the font settings"] = "调整字体设置"
-- L["Border Texture"] = ""
-- L["Adjust the border texture."] = ""
L["Border"] = "边框"
-- L["Border Color"] = ""
L["Background"] = "背景"
-- L["Background Color"] = ""
L["Adjust border color and alpha."] = "调整边框的颜色和透明度。"
L["Adjust background color and alpha."] = "调整背景颜色和透明度。"
-- L["Opacity"] = ""
-- L["Set the opacity."] = ""
-- L["<CharacterOnlyString>"] = ""
L["Options for %s."] = "%s状态的选项。"

--{{{ Indicator management
-- L["New Indicator"] = ""
-- L["Create a new indicator."] = ""
-- L["Name of the new indicator"] = ""
-- L["Enable Test Mode"] = ""
-- L["Disable Test Mode"] = ""
-- L["Appearance"] = ""
-- L["Adjust the border size of the indicator."] = ""
-- L["Stack Text"] = ""
-- L["Disable Stack Text"] = ""
-- L["Disable Cooldown"] = ""
-- L["Disable the Cooldown Frame"] = ""
-- L["Reverse Cooldown"] = ""
-- L["Set cooldown to become darker over time instead of lighter."] = ""
-- L["Cooldown"] = ""
-- L["Text Location"] = ""
-- L["Disable OmniCC"] = ""
 
-- L["Type"] = ""
-- L["Type of indicator"] = ""
-- L["Type of indicator to create"] = ""

-- L["Text Length"] = ""
-- L["Maximum number of characters to show."] = ""
L["Font Size"] = "字体大小"
L["Adjust the font size."] = "调整字体尺寸。"
L["Size"] = "边角大小"
L["Adjust the size of the indicator."] = "调整边角指示器的大小。"
-- L["Width"] = ""
-- L["Adjust the width of the indicator."] = ""
-- L["Height"] = ""
-- L["Adjust the height of the indicator."] = ""
-- L["Rectangle"] = ""
-- L["Allows to independently adjust width and height."] = ""

L["Frame Texture"] = "框架材质"
-- L["Adjust the frame texture."] = ""

-- L["Show stack"] = ""
-- L["Show the number of stacks."] = ""
L["Show duration"] = "显示持续效果"
L["Show the time remaining."] = "显示的剩余时间。"
-- L["Show elapsed time"] = ""
-- L["Show the elapsed time."] = ""
-- L["Show percent"] = ""
-- L["Show percent value"] = ""

-- L["Orientation of the Bar"] = ""
-- L["Set status bar orientation."] = ""
-- L["DEFAULT"] = ""
-- L["Frame Level"] = ""
-- L["Bars with higher numbers always show up on top of lower numbers."] = ""
-- L["Bar Width"] = ""
-- L["Choose zero to set the bar to the same width as parent frame"] = ""
-- L["Bar Height"] = ""
-- L["Choose zero to set the bar to the same height as parent frame"] = ""

-- L["Border Size"] = ""
-- L["Adjust the border of each unit's frame."] = ""
-- L["Border Background Color"] = ""
-- L["Adjust border background color and alpha."] = ""
-- L["Border separation"] = ""
-- L["Adjust the distance between the border and the frame content."] = ""

-- L["Select statuses to display with the indicator"] = ""
-- L["Available Statuses"] = ""
-- L["Available statuses you may add"] = ""
-- L["Current Statuses"] = ""
-- L["Current statuses in order of priority"] = ""
-- L["Move the status higher in priority"] = ""
-- L["Move the status lower in priority"] = ""

L["indicator"] = "indicator"

-- indicator types
L["icon"] = "icon"
L["square"] = "square"
L["text"] = "text"
-- L["bar"] = ""

-- indicators
L["corner-top-left"] = "corner-top-left"
L["corner-top-right"] = "corner-top-right"
L["corner-bottom-right"] = "corner-bottom-right"
L["corner-bottom-left"] = "corner-bottom-left"
L["side-top"] = "side-top"
L["side-right"] = "side-right"
L["side-bottom"] = "side-bottom"
L["side-left"] = "side-left"
-- L["text-up"] = ""
-- L["text-down"] = ""
-- L["icon-left"] = ""
-- L["icon-center"] = ""
-- L["icon-right"] = ""

-- locations
L["CENTER"] = "中心"
L["TOP"] = "顶部"
L["BOTTOM"] = "底部"
L["LEFT"] = "左侧"
L["RIGHT"] = "右侧"
L["TOPLEFT"] = "左上"
L["TOPRIGHT"] = "右上"
L["BOTTOMLEFT"] = "左下"
L["BOTTOMRIGHT"] = "右下"

L["location"] = "location"

-- L["Location"] = ""
-- L["Align my align point relative to"] = ""
-- L["Align Point"] = ""
-- L["Align this point on the indicator"] = ""
-- L["X Offset"] = ""
-- L["X - Horizontal Offset"] = ""
-- L["Y Offset"] = ""
-- L["Y - Vertical Offset"] = ""

--{{{ Statuses
-- L["-color"] = ""
-- L["-mine"] = ""
-- L["-not-mine"] = ""
-- L["buff-"] = ""
-- L["debuff-"] = ""
-- L["color-"] = ""

L["status"] = "status"

L["buff"] = "buff"
L["debuff"] = "debuff"

-- L["New Color"] = ""
-- L["New Status"] = ""
-- L["Create a new status."] = ""

-- L["Threshold"] = ""
-- L["Threshold at which to activate the status."] = ""

-- buff & debuff statuses management
-- L["Auras"] = ""
-- L["Buffs"] = ""
-- L["Debuffs"] = ""
-- L["Colors"] = ""
-- L["Health&Heals"] = ""
-- L["Mana&Power"] = ""
-- L["Combat"] = ""
-- L["Targeting&Distances"] = ""
-- L["Raid&Party Roles"] = ""
-- L["Miscellaneous"] = ""

L["Show if mine"] = "显示自身"
-- L["Show if not mine"] = ""
L["Show if missing"] = "缺少时显示"
L["Display status only if the buff is not active."] = "仅在增益缺少时才显示状态。"
L["Display status only if the buff was cast by you."] = "显示你施放增益时的状态。"
-- L["Display status only if the buff was not cast by you."] = ""
-- L["Color count"] = ""
-- L["Select how many colors the status must provide."] = ""
-- L["You can include a descriptive prefix using separators \"@#>\""] = ""
-- L["examples: Druid@Regrowth Chimaeron>Low Health"] = ""

L["Class Filter"] = "职业过滤"
L["Show on %s."] = "在%s上显示。"

-- L["Blink Threshold"] = ""
-- L["Blink Threshold at which to start blinking the status."] = ""

-- L["Select Type"] = ""
-- L["Buff"] = ""
-- L["Debuff"] = ""
-- L["Buffs Group"] = ""
-- L["Debuffs Group"] = ""
-- L["Buffs Group: Defensive Cooldowns"] = ""
-- L["Debuffs Group: Healing Prevented "] = ""
-- L["Debuffs Group: Healing Reduced"] = ""

-- general statuses
L["name"] = "name"
L["mana"] = "mana"
-- L["power"] = ""
-- L["poweralt"] = ""
-- L["alpha"] = ""
-- L["border"] = ""
-- L["heals"] = ""
L["health"] = "health"
L["charmed"] = "charmed"
-- L["afk"] = ""
L["death"] = "death"
L["classcolor"] = "classcolor"
-- L["creaturecolor"] = ""
-- L["friendcolor"] = ""
L["feign-death"] = "feign-death"
L["heals-incoming"] = "heals-incoming"
-- L["health-current"] = ""
L["health-deficit"] = "health-deficit"
L["health-low"] = "health-low"
L["lowmana"] = "lowmana"
L["offline"] = "offline"
-- L["raid-icon-player"] = ""
-- L["raid-icon-target"] = ""
L["range"] = "range"
L["ready-check"] = "ready-check"
-- L["role"] = ""
-- L["dungeon-role"] = ""
-- L["leader"] = ""
-- L["master-looter"] = ""
-- L["raid-assistant"] = ""
L["target"] = "target"
L["threat"] = "threat"
-- L["banzai"] = ""
L["vehicle"] = "vehicle"
L["voice"] = "voice"
L["pvp"] = "pvp"
-- L["direction"] = ""
-- L["resurrection"] = ""

-- L["Curse"] = ""
-- L["Poison"] = ""
-- L["Disease"] = ""
-- L["Magic"] = ""

-- L["raid-debuffs"] = ""

-- class specific buffs & debuffs statuses

-- shaman
-- L["EarthShield"] = ""
-- L["Earthliving"] = ""
-- L["Riptide"] = ""

-- Druid
-- L["Rejuvenation"] = ""
-- L["Lifebloom"] = ""
-- L["Regrowth"] = ""
-- L["WildGrowth"] = ""

-- paladin
-- L["BeaconOfLight"] = ""
-- L["FlashOfLight"] = ""
-- L["DivineShield"] = ""
-- L["DivineProtection"] = ""
-- L["HandOfProtection"] = ""
-- L["HandOfSalvation"] = ""
-- L["Forbearance"] = ""

-- priest
-- L["Grace"] = ""
-- L["DivineAegis"] = ""
-- L["InnerFire"] = ""
-- L["PrayerOfMending"] = ""
-- L["PowerWordShield"] = ""
-- L["Renew"] = ""
-- L["WeakenedSoul"] = ""
-- L["SpiritOfRedemption"] = ""

-- mage
-- L["FocusMagic"] = ""
-- L["IceArmor"] = ""
-- L["IceBarrier"] = ""

-- rogue
-- L["Evasion"] = ""

-- warlock
-- L["ShadowWard"] = ""
-- L["SoulLink"] = ""
-- L["DemonArmor"] = ""
-- L["FelArmor"] = ""

-- warrior
-- L["Vigilance"] = ""
-- L["BattleShout"] = ""
-- L["CommandingShout"] = ""
-- L["ShieldWall"] = ""
-- L["LastStand"] = ""

-- class color, creature color, friend color status
L["%s Color"] = "%s颜色"
-- L["Player color"] = ""
-- L["Pet color"] = ""
L["Color Charmed Unit"] = "高亮被魅惑单位"
L["Color Units that are charmed."] = "高亮显示被魅惑单位。"
L["Unit Colors"] = "单位颜色"
L["Charmed unit Color"] = "被魅惑单位颜色"
L["Default unit Color"] = "默认单位颜色"
L["Default pet Color"] = "默认宠物颜色"

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
L["Beast"] = "野兽"
L["Demon"] = "恶魔"
L["Humanoid"] = "人型"
L["Elemental"] = "元素"

-- heal-current status
L["Show dead as having Full Health"] = "显示死亡或生命值全满"
-- L["Frequent Updates"] = ""

-- range status 
L["Range"] = "距离"
L["%d yards"] = "%d码"
L["Range in yards beyond which the status will be lost."] = "超出距离以外的状态都将丢失。"
L["Default alpha"] = "默认透明度"
L["Default alpha value when units are way out of range."] = "当单位超出距离时的默认透明度。"
L["Update rate"] = "更新速度"
-- L["Rate at which the status gets updated"] = ""

-- ready-check status
-- L["Delay"] = ""
-- L["Set the delay until ready check results are cleared."] = ""
-- L["Waiting color"] = ""
-- L["Color for Waiting."] = ""
-- L["Ready color"] = ""
-- L["Color for Ready."] = ""
-- L["Not Ready color"] = ""
-- L["Color for Not Ready."] = ""
-- L["AFK color"] = ""
-- L["Color for AFK."] = ""

-- heals-incoming status 
-- L["Include player heals"] = ""
-- L["Display status for the player's heals."] = ""
-- L["Minimum value"] = ""
-- L["Incoming heals below the specified value will not be shown."] = ""

--target status
L["Your Target"] = "你的目标"

--threat status
L["Not Tanking"] = "Not Tanking"
L["Higher threat than tank."] = "Higher threat than tank."
L["Insecurely Tanking"] = "Insecurely Tanking"
L["Tanking without having highest threat."] = "Tanking without having highest threat."
L["Securely Tanking"] = "Securely Tanking"
L["Tanking with highest threat."] = "Tanking with highest threat."

-- voice status
L["Voice Chat"] = "语音"

-- raid debuffs
-- L["General"] = ""
-- L["Advanced"] = ""
-- L["Enabled raid debuffs modules"] = ""
-- L["Enabled"] = ""
-- L["Enable All"] = ""
-- L["Disable All"] = ""
-- L["Copy to Debuffs"] = ""
-- L["Select module"] = ""
-- L["Select instance"] = ""
-- L["Cataclysm"] = ""
-- L["The Lich King"] = ""
-- L["The Burning Crusade"] = ""
-- L["New raid debuff"] = ""
-- L["Type the SpellId of the new raid debuff"] = ""
-- L["Create raid debuff"] = ""
-- L["Delete raid debuff"] = ""

-- direction
-- L["Out of Range"] = ""
-- L["Display status for units out of range."] = ""
-- L["Visible Units"] = ""
-- L["Display status for units less than 100 yards away"] = ""
-- L["Dead Units"] = ""
-- L["Display status only for dead units"] = ""

-- resurrection
-- L["Casting resurrection"] = ""
-- L["A resurrection spell is being casted on the unit"] = ""
-- L["Resurrected"] = ""
-- L["A resurrection spell has been casted on the unit"] = ""
		
-- power
-- L["Mana"] = ""
-- L["Rage"] = ""
-- L["Focus"] = ""
-- L["Energy"] = ""
-- L["Runic Power"] = ""
		
-- Import/export profiles module
-- L["Import/export options"] = ""
-- L["Import profile"] = ""
-- L["Export profile"] = ""
-- L["Network sharing"] = ""
-- L["Accept profiles from other players"] = ""
-- L["Type player name"] = ""
-- L["Send current profile"] = ""
-- L["Profile import/export"] = ""
-- L["Paste here a profile in text format"] = ""
-- L["Press CTRL-V to paste a Grid2 configuration text"] = ""
-- L["This is your current profile in text format"] = ""
-- L["Press CTRL-C to copy the configuration to your clipboard"] = ""
-- L["Progress"] = ""
-- L["Data size: %.1fKB"] = ""
-- L["Transmision progress: %d%%"] = ""
-- L["Transmission completed"] = ""
-- L["\"%s\" has sent you a profile configuration. Do you want to activate received profile ?"] = ""
