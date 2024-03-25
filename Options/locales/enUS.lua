local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "enUS", true, true)
if not L then return end

--{{{ General options
L["GRID2_WELCOME"] = "Welcome to Grid2"
L["GRID2_DESC"]  = "Grid2 is a party&raid unit frame addon. Grid2 displays health and all relevant information about the party&raid members in a more comprehensible manner."

L["General Settings"] = true

L["Default Font"] = true
L["Default values"] = true
L["Default Font Border"] = true
L["Default Texture"] = true
L["Enabled indicators"] = true
L["Right Click Menu"] = true
L["Display the standard unit menu when right clicking on a frame."] = true

L["statuses"] = "Statuses"
L["indicators"] = "Indicators"
L["Assigned indicators"] = true

L["Frames"] = true
L["frame"] = true

L["Invert Bar Color"] = true
L["Swap foreground/background colors on bars."] = true

L["Background Color"] = true
L["Sets the background color of each unit frame"] = true

L["Mouseover Highlight"] = true
L["Toggle mouseover highlight."] = true
L["Highlight Color"] = true
L["Sets the hightlight color of each unit frame"] = true
L["Highlight Texture"] = true
L["Sets the highlight border texture of each unit frame"] = true

L["Background Texture"] = true
L["Select the frame background texture."] = true

L["Inner Border Size"] = true
L["Sets the size of the inner border of each unit frame"] = true

L["Inner Border Color"] = true
L["Sets the color of the inner border of each unit frame"] = true

L["Frame Width"] = true
L["Adjust the width of each unit's frame."] = true

L["Frame Height"] = true
L["Adjust the height of each unit's frame."] = true

L["Default Orientation"] = true
L["Set default bars orientation."] = true
L["VERTICAL"] = true
L["HORIZONTAL"] = true

L["Orientation of Text"] = true
L["Set frame text orientation."] = true

L["Show Frame"] = true
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = true
L["Always"] = true
L["Grouped"] = true
L["Raid"] = true

L["Layout Anchor"] = true
L["Sets where Grid is anchored relative to the screen."] = true

L["Horizontal groups"] = true
L["Switch between horzontal/vertical groups."] = true
L["Clamped to screen"] = true
L["Toggle whether to permit movement out of screen."] = true
L["Frame lock"] = true
L["Locks/unlocks the grid for movement."] = true
L["Click through the Grid Frame"] = true
L["Allows mouse click through the Grid Frame."] = true

L["Display"] = true
L["Padding"] = true
L["Adjust frame padding."] = true
L["Spacing"] = true
L["Adjust frame spacing."] = true
L["Scale"] = true
L["Adjust Grid scale."] = true

L["Group Anchor"] = true
L["Position and Anchor"] = true
L["Sets where groups are anchored relative to the layout frame."] = true
L["Resets the layout frame's position and anchor."] = true

L["Frame Strata"] = true
L["Sets the strata in which the layout frame should be layered."] = true
L["BACKGROUND"] = true
L["LOW"] = true
L["MEDIUM"] = true
L["HIGH"] = true

L["Layout Disposition"] = true
L["Layout Look&Feel"] = true
L["Frames Look&Feel"] = true
L["Main Window Position"] =  true
L["Default Settings"] = true
L["Groups Orientation"] = true
L['Header Types'] = true
L["Units per Column"] = true
L["Hide Empty Units"] = true
L["Hide frames of non-existant units."] = true
L["Lock Frame Size"] = true
L["Forbid dynamic changes in frame dimensions for this kind of header."] = true
L["Adjust the width percent of each unit's frame."] = true
L["Adjust the height percent of each unit's frame."] = true
L["Adjust the default units per column for this group type."] = true

L["Players"] = true
L["Pets"] = true
L["Player"] = true
L["Target"] = true
L["Target of Target"] = true
L["Focus"] = true
L["Target of Focus"] = true
L["Others"] = true

-- minimap icon
L["Minimap Icon"] = true
L["Show Minimap Icon"] = true

-- icon textures zoom
L["Icon Textures Zoom"] = true
L["Zoom In buffs and debuffs icon textures"] = true
L["Enable this option to hide the default blizzard border of buffs and debuffs Icons."] = true

--blink
L["Misc"] = true
L["blink"] = true
L["Blink effect"] = true
L["Select the type of Blink effect used by Grid2."] = true
L["None"] = true
L["Blink"] = true
L["Flash"] = true
L["Blink Frequency"] = true
L["Adjust the frequency of the Blink effect."] = true
L["Highlight Effect"] = true
L["Zoom In"] = true

-- text formatting
L["Text Formatting"] = true
L["Duration Format"] = true
L["Examples:\n(%d)\n%d seconds"] = true
L["Duration+Stacks Format"] = true
L["Examples:\n%d/%s\n%s(%d)"] = true
L["Display tenths of a second"] = true
L["When duration<1sec"] = true

-- misc
L["Blizzard Raid Frames"] = true
L["Hide Blizzard Raid Frames"] = true
L["Hide Blizzard Party Frames"] = true
L["Hide Blizzard Frames"] = true

-- debugging & maintenance
L["debugging"] = true
L["Module debugging menu."] = true
L["Debug"]= true
L["Reset"] = true
L["Reset and ReloadUI."] = true
L["Reset Setup"] = true
L["Reset current setup and ReloadUI."] = true
L["Reset Indicators"] = true
L["Reset indicators to defaults."] = true
L["Reset Locations"] = true
L["Reset locations to the default list."] = true
L["Reset to defaults."] = true
L["Reset Statuses"] = true
L["Reset statuses to defaults."] = true
L["Reset Position"] = true

L["Warning! This option will delete all settings and profiles, are you sure ?"]= true

L["About"] = true

--{{{ Layouts options
L["Layout"] = true
L["Layouts"] = true
L["layout"] = true
L["Layouts for each type of groups you're in."] = true
L["Select which layout to use for: "] = true
L["Layout editor"] = true
L["Use Raid layout"] = true
L["Solo"] = true
L["Party"] = true
L["Arena"] = true
L["Raid"] = true
L["PvP Instances (BGs)"] = true
L["LFR Instances"] = true
L["Flexible raid Instances (normal/heroic)"] = true
L["Mythic raids Instances"] = true
L["Other raids Instances"] = true
L["In World"] = true
L["Layout Settings"] = true
L["Solo Layout"] = true
L["Party Layout"] = true
L["Raid %s Layout"] = true
L["Select which layout to use for %s person raids."] = true
L["Battleground Layout"] = true
L["Select which layout to use for battlegrounds."] = true
L["Arena Layout"] = true
L["Select which layout to use for arenas."] = true
L["Test"] = true
L["Test the layout."] = true
L["Select Layout"] = true
L["New Layout Name"] = true
L["Delete selected layout"] = true
L["Refresh"] = true
L["Refresh the Layout"] = true
L["Toggle for vehicle"] = true
L["When the player is in a vehicle replace the player frame with the vehicle frame."] = true
L["Header"] = true
L["Type of units to display"] = true
L["Columns"] = true
L["Maximum number of columns to display"] = true
L["Units/Column"] = true
L["Maximum number of units per column to display"] = true
L["First group"] = true
L["First group to display"] = true
L["Last Group"] = true
L["Last group to display"] = true
L["Group by"] = true
L["Sort by"] = true
L["Action"] = true
L["all"] = true
L["Class"] = true
L["Group"] = true
L["Role"] = true
L["Name"] = true
L["Index"] = true
L["party"] = true
L["raid"] = true
L["partypet"] = true
L["raidpet"] = true
L["Insert"] = true
L["Copy"] = true
L["By Instance Type"] = true
L["By Raid Size"] = true
L["Spec"] = true
L["Select which layout to use for solo."] = true
L["Select which layout to use for party."] = true
L["%d man instances"] = true
L["Display all groups"] = true
L["Display all raid groups, if unchecked the groups will by filtered according to the instance size. Not all layouts will obey this setting."] = true
L["Sort units by name"] = true
L["Sort the units by player name, if unchecked the units will be displayed in raid order. Not all layouts will obey this setting."] = true
L["Index (Raid Order)\nName (Unit Names))\nList (Name List)\nDef (Default)"] = true
L["Default"] = true
L["Tank"] = true
L["Healer"] = true
L["Dps"] = true
L["MT"] = true
L["MA"] = true
L["Damager"] = true
L["MainTank"] = true
L["MainAssist"] = true
L["Clone"] = true
L["Roles"] = true
L["Groups"] = true
L["Name List"] = true
L["Roles Order"] = true
L["Create New Layout"] = true
L["Create a new user defined layout by entering a name in the editbox."] = true
L["Delete existing layouts from the database."] = true
L["Are you sure you want to delete the selected layout?"] = true
L["Default settings applied to all user defined layouts and some built-in layouts."] = true
L["General Options"] = true
L["Add a new header.\nA header displays a group of players or pets in a compat way."] = true
L["Create New Header"] = true
L["Select what kind of units you want to display on the new header and click the create button."] = true
L["New Header Type"] = true
L["players"] = true
L["pets"] = true
L["Def."] = true
L["List"] = true
L["Are you sure you want to remove this header?"] = true
L["Are you sure you want to delete the selected layout?"] = true
L["Layout Editor"] = true
L["Copy Layout"] = true
L["Type the name of the new Layout:"] = true
L["Copy the selected layout into a new layout."] = true
L["Detach Header"] = true
L["Header Type"] = true

--{{{ Miscelaneous
L["New"] = true
L["Order"] = true
L["Delete"] = true
L["Color"] = true
L["Color %d"] = true
L["Color for %s."] = true
L["Font"] = true
L["Font Border"] = true
L["Thin"] = true
L["Thick"] = true
L["Soft"] = true
L["Sharp"] = true
L["Adjust the font settings"] = true
L["Border Texture"] = true
L["Adjust the border texture."] = true
L["Border"] = true
L["Border Color"] = true
L["Background"] = true
L["Enable Background"] = true
L["Adjust border color and alpha."] = true
L["Adjust background color and alpha."] = true
L["Opacity"] = true
L["Set the opacity."] = true
L["<CharacterOnlyString>"] = true
L["Options for %s."]= true
L["Delete this element"] = true
L["Disable shadow"] = true
L["Shadow"] = true

--{{{ Indicator management
L["New Indicator"] = true
L["Create Indicator"] = true
L["Create a new indicator."] = true
L["Name of the new indicator"] = true
L["Enable or disable test mode for indicators"] = true
L["Appearance"] = true
L["Adjust the border size of the indicator."] = true
L["Stack Text"] = true
L["Disable Stack Text"] = true
L["Disable Cooldown"] = true
L["Disable the Cooldown Frame"] = true
L["Reverse Cooldown"] = true
L["Set cooldown to become darker over time instead of lighter."] = true
L["Cooldown"]= true
L["Text Location"]= true
L["Disable OmniCC"]= true
L["Animations"] = true
L["Enable animation"] = true
L["Turn on/off zoom animation of icons."] = true
L["Duration"] = true
L["Sets the duration in seconds."] = true
L["Scale"] = true
L["Sets the zoom factor."] = true

L["Type"] = true
L["Type of indicator"] = true
L["Type of indicator to create"] = true
L["Change type"] = true
L["Change the indicator type"] = true

L["Text Length"] = true
L["Maximum number of characters to show."] = true
L["Font Size"] = true
L["Adjust the font size."] = true
L["Size"] = true
L["Adjust the size of the indicator."] = true
L["Width"] = true
L["Adjust the width of the indicator."] = true
L["Height"] = true
L["Adjust the height of the indicator."] = true
L["Rectangle"] = true
L["Allows to independently adjust width and height."] = true
L["Use Status Color"] = true
L["Always use the status color for the border"] = true

L["Frame Texture"] = true
L["Adjust the frame texture."] = true
L["Blend Mode"] = true
L["Select how to mix the texture with the background."] = true
L["Additive"] = true

L["Show stack"] = true
L["Show the number of stacks."] = true
L["Show duration"] = true
L["Show the time remaining."] = true
L["Show elapsed time"] = true
L["Show the elapsed time."] = true
L["Show percent"] = true
L["Show percent value"] = true

L["Orientation of the Bar"] = true
L["Set status bar orientation."] = true
L["DEFAULT"]= true
L["Frame Level"] = true
L["Bars with higher numbers always show up on top of lower numbers."] = true
L["Bar Width"] = true
L["Choose zero to set the bar to the same width as parent frame"] = true
L["Bar Height"] = true
L["Choose zero to set the bar to the same height as parent frame"] = true
L["Anchor to"] = true
L["Anchor the indicator to the selected bar."] = true
L["Reverse Fill"] = true
L["Fill the bar in reverse."] = true
L["Bars"] = true
L["Extra Bar"] = true
L["Main Bar Color"] = true
L["Anchor to MainBar"] = true
L["Anchor the background bar to the Main Bar instead of the last bar."] = true
L["Reverse"] = true
L["Overlap"] = true
L["Texture"] = true
L["Sublevel"] = true
L["Add"] = true
L["Status Color"] = true
L["Main Bar"] = true
L["Fill bar in reverse"] = true
L["Anchor & Direction"] = true
L["Select where to anchor the bar and optional you can reverse the grow direction."] = true
L["Previous Bar"] = true
L["Topmost Bar"] = true
L["Previous Bar & Reverse"] = true
L["Glow Line"] = true
L["Line"] = true
L["Line Thickness"] = true
L["Set the thickness of the glow line."] = true
L["Line Position"] = true
L["Fine adjust the position of the line relative to the previous bar."] = true

L["Border Size"] = true
L["Adjust the border of each unit's frame."] = true
L["Border Background Color"] = true
L["Adjust border background color and alpha."] = true
L["Border separation"] = true
L["Adjust the distance between the border and the frame content."] = true

L["Show statuses in Tooltip"] = true
L["Show selected statuses information in tooltip when mouseover a unit."] = true
L["Tooltip Anchor"] = true
L["Sets where Tooltip is anchored relative to Grid2 window or select the game default anchor."] = true
L["Always display unit tooltip information when Out of Combat"] = true
L["This option takes priority over any other tooltip configuration."] = true
L["Never"] = true
L["Always"] = true
L["In Combat"] = true
L["Out of Combat"] = true
L["Tooltip"] = true
L["Display Tooltip"] = true
L["Check this option to display a tooltip when the mouse is over the icon."] = true
L["Show Tooltip"] = true
L["Enable Advanced Tooltips"] = true
L["Display default unit tooltip when Out of Combat"] = true
L["Icon Tooltips"] = true
L["Unit Tooltips"] = true
L["Sets where the Tooltip is anchored relative to the icon."] = true
L["Check this option to display a tooltip when the mouse is over this indicator."] = true

L["Select statuses to display with the indicator"] = true
L["Available Statuses"] = true
L["Available statuses you may add"] = true
L["Current Statuses"] = true
L["Current statuses in order of priority"] = true
L["Move the status higher in priority"] = true
L["Move the status lower in priority"] = true

L["indicator"] = true

L["Maintenance"] = true
L["Create"] = true
L["indicators management"] = true
L["Create new indicator"] = true
L["Delete Indicator"] = true
L["Rename Indicator"] = true
L["Highlight Indicator"] = true
L["Indicator Type"] = true
L["Icon"] = true
L["Max Icons"] = true
L["Icons per row"] = true
L["Icon Size"] = true
L["Icon Spacing"] = true
L["Direction"] = true
L["Select the direction of the main bar."] = true

L["First Aura"] = true
L["Select the index of the first private aura to display."] = true
L["Last Aura"] = true
L["Select the index of the last private aura to display."] = true
L["Enable Cooldown"] = true
L["Display a cooldown animation."] = true
L["Enable Numbers"] = true
L["Display cooldown numbers."] = true

-- indicator types
L["icon"] = true
L["square"] = true
L["text"] = true
L["bar"] = true
L["icons"] = true
L["multibar"] = true
L["portrait"] = true
L["glowborder"] = true
L["privateauras"] = true

-- indicators
L["corner-top-left"]= true
L["corner-top-right"]= true
L["corner-bottom-right"]= true
L["corner-bottom-left"]= true
L["side-top"]= true
L["side-right"]= true
L["side-bottom"]= true
L["side-left"]= true
L["text-up"]= true
L["text-down"]= true
L["icon-left"]= true
L["icon-center"]= true
L["icon-right"]= true

-- locations
L["CENTER"] = true
L["TOP"] = true
L["BOTTOM"] = true
L["LEFT"] = true
L["RIGHT"] = true
L["TOPLEFT"] = true
L["TOPRIGHT"] = true
L["BOTTOMLEFT"] = true
L["BOTTOMRIGHT"] = true
L["LEFTTOP"] = true
L["LEFTBOTTOM"] = true
L["RIGHTTOP"] = true
L["RIGHTBOTTOM"] = true

L["location"] = true

L["Location"] = true
L["Align my align point relative to"] = true
L["Align Point"] = true
L["Align this point on the indicator"] = true
L["X Offset"] = true
L["X - Horizontal Offset"] = true
L["Y Offset"] = true
L["Y - Vertical Offset"] = true

--{{{ Statuses
L["-value"] = "(value)"
L["-color"] = ":color"
L["-mine"] = ":mine"
L["-not-mine"] = ":not mine"
L["buff-"] = "buff: "
L["buffs-"] = "buffs: "
L["debuff-"] = "debuff: "
L["debuffs-"] = "debuffs: "
L["color-"] = "color: "
L["aoe-"] = "aoe: "
L["spells-"] = "spells: "

L["Status"] = true
L["status"] = true

L["buff"] = true
L["debuff"] = true
L["debuffType"] = true
L["buffs-"] = true
L["debuffs-"] = true


L["New Buff"] = true
L["New Debuff"] = true
L["New Color"] = true
L["New Status"] = true
L["Delete Status"] = true
L["Create a new status."] = true
L["Create Buff"] = true
L["Create Debuff"] = true
L["Create Color"] = true

L["Threshold"] = true
L["Thresholds"] = true
L["Threshold at which to activate the status."] = true

L["Stacks"] = true
L["Activation"] = true
L["Highlight"] = true
L["Combine Stacks"] = true
L["Multiple instances of the same debuff will be treated as multiple stacks of the same debuff."] = true

L["available statuses"] = true

-- buff & debuff statuses management
L["Auras"] = true
L["Buffs"] = true
L["Debuffs"] = true
L["Colors"] = true
L["Health&Heals"] = true
L["Mana&Power"] = true
L["Combat"] = true
L["Targeting&Distances"] = true
L["Raid&Party Roles"] = true
L["Miscellaneous"] = true
L["Show if mine"] = true
L["Show if not mine"] = true
L["Show if missing"] = true
L["Display status only if the buff is not active."] = true
L["Hide on pets"] = true
L["Never display this status on pets."] = true
L["Display status only if the buff was cast by you."] = true
L["Display status only if the buff was not cast by you."] = true
L["Color count"]= true
L["Select how many colors the status must provide."]= true
L["You can include a descriptive prefix using separators \"@#>\""]= true
L["examples: Druid@Regrowth Chimaeron>Low Health"]= true
L["Threshold to activate Color"] = true
L["Track by SpellId"] = true
L["Track by spellId instead of aura name"] = true
L["Assigned to"] = true
L["Coloring based on"] = true
L["Single Color"] = true
L["Debuff Type"] = true
L["Number of stacks"] = true
L["Remaining time"] = true
L["Elapsed time"] = true
L["Class Filter"] = true
L["Show on %s."] = true
L["Blink Threshold"] = true
L["Blink Threshold at which to start blinking the status."] = true
L["Name or SpellId"] = true
L["Select Type"] = true
L["Buff"] = true
L["Debuff"] = true
L["Buffs Group"] = true
L["Debuffs Group"] = true
L["Buffs Group: Defensive Cooldowns"] = true
L["Debuffs Group: Healing Prevented "] = true
L["Debuffs Group: Healing Reduced"] = true
L["Filtered debuffs"] = true
L["Listed debuffs will be ignored."] = true
L["AURAVALUE_DESC"] = "Select an aura value to track. Auras can provide up to 3 values, but not all auras have additional values. Examples of auras providing additional values are: priest shields (shield amount is stored in Value1) or DeathKnight purgatory debuff."
L["Enabled for"] = true
L["All Classes"] = true
L["Activation Stacks"] = true
L["Select the minimum number of aura stacks to activate the status."] = true
L["Track extra value"] = true
L["Track"] = true
L["Duration&Stacks"] = true
L["Value"] = true
L["Value Index"] = true
L["Value Track"] = true
L["NONE"] = true
L["Value1"] = true
L["Value2"] = true
L["Value3"] = true
L["Maximum Value"] = true
L["Low value color"] = true
L["Medium value color"] = true
L["Normal value color"] = true
L["Buffs: Defensive Cooldowns"] = true
L["Debuffs: Healing Prevented "] = true
L["Debuffs: Healing Reduced"] = true
L["Non Boss Debuffs"] = true
L["Boss Debuffs"] = true
L["Short Duration"] = true
L["Long Duration"] = true
L["Temporary Debuffs"] = true
L["Permanent Debuffs"] = true
L["Non Self Casted"] = true
L["Self Casted"] = true
L["Relevant Debuffs"] = true
L["Non-Relevant Debuffs"] = true
L["Whitelist"] = true
L["Blacklist"] = true
L["Use debuff Type color"] = true
L["Use the debuff Type color first. The specified color will be applied only if the debuff has no type."] = true
L["Low value"] = true
L["Medium value"] = true
L["Maximum value"] = true

-- general statuses
L["name"]= true
L["mana"]= true
L["manaalt"]= true
L["power"]= true
L["poweralt"]= true
L["alpha"] = true
L["border"] = true
L["heals"] = true
L["health"] = true
L["overhealing"] = true
L["charmed"] = true
L["afk"] = true
L["death"] = true
L["classcolor"] = true
L["creaturecolor"] = true
L["friendcolor"] = true
L["feign-death"] = true
L["heals-incoming"] = true
L["health-current"] = true
L["health-deficit"] = true
L["health-low"] = true
L["lowmana"] = true
L["offline"] = true
L["raid-icon-player"] = true
L["raid-icon-target"] = true
L["range"] = true
L["rangealt"] = true
L["ready-check"] = true
L["role"] = true
L["dungeon-role"] = true
L["leader"]= true
L["master-looter"]= true
L["raid-assistant"]= true
L["target"] = true
L["threat"] = true
L["banzai"] = true
L["banzai-threat"] = true
L["vehicle"] = true
L["voice"] = true
L["pvp"] = true
L["direction"] = true
L["resurrection"] = true
L["self"] = true
L["boss-shields"] = true
L["my-heals-incoming"] = true
L["boss-debuffs"] = true
L["unit-index"] = true

L["Curse"] = true
L["Poison"] = true
L["Disease"] = true
L["Magic"] = true

L["raid-debuffs"]  = "Raid Debuffs"
L["raid-debuffs2"] = "Raid Debuffs(2)"
L["raid-debuffs3"] = "Raid Debuffs(3)"
L["raid-debuffs4"] = "Raid Debuffs(4)"
L["raid-debuffs5"] = "Raid Debuffs(5)"

-- shaman
L["EarthShield"] = true
L["Earthliving"] = true
L["Riptide"] = true
L["ChainHeal"] = true
L["HealingRain"] = true

-- Druid
L["Rejuvenation"]= true
L["Lifebloom"]= true
L["Regrowth"]= true
L["WildGrowth"]= true

-- paladin
L["BeaconOfLight"]= true
L["FlashOfLight"]= true
L["DivineShield"]= true
L["DivineProtection"]= true
L["HandOfProtection"]= true
L["HandOfSalvation"]= true
L["Forbearance"]= true

-- priest
L["Grace"]= true
L["DivineAegis"]= true
L["InnerFire"]= true
L["PrayerOfMending"]= true
L["PowerWordShield"]= true
L["Renew"]= true
L["WeakenedSoul"]= true
L["SpiritOfRedemption"]= true
L["CircleOfHealing"]= true
L["PrayerOfHealing"]= true

-- monk
L["EnvelopingMist"]= true
L["RenewingMist"]= true
L["LifeCocoon"]= true
L["monk-stagger"] = true

-- mage
L["FocusMagic"]= true
L["IceArmor"]= true
L["IceBarrier"]= true

-- rogue
L["Evasion"]= true

-- warlock
L["ShadowWard"]= true
L["SoulLink"]= true
L["DemonArmor"]= true
L["FelArmor"]= true

-- warrior
L["Vigilance"]= true
L["BattleShout"]= true
L["CommandingShout"]= true
L["ShieldWall"]= true
L["LastStand"]= true

-- class color, creature color, friend color status
L["%s Color"] = "%s"
L["Player color"]= true
L["Pet color"] = true
L["Color Charmed Unit"] = true
L["Color Units that are charmed."] = true
L["Unit Colors"] = true
L["Charmed unit Color"] = true
L["Default unit Color"] = true
L["Default pet Color"] = true

L["DEATHKNIGHT"] = "DeathKnight"
L["DRUID"] = "Druid"
L["HUNTER"] = "Hunter"
L["MAGE"] = "Mage"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Priest"
L["ROGUE"] = "Rogue"
L["SHAMAN"] = "Shaman"
L["WARLOCK"] = "Warlock"
L["WARRIOR"] = "Warrior"
L["Beast"] = "Beast"
L["Demon"] = "Demon"
L["Humanoid"] = "Humanoid"
L["Elemental"] = "Elemental"

-- health-current status
L["Full Health"] = true
L["Medium Health"] = true
L["Low Health"] = true
L["Show dead as having Full Health"] = true
L["Frequent Updates"] = true
L["Instant Updates"] = true
L["Normal"] = true
L["Fast"] = true
L["Instant"] = true
L["Update frequency"] = true
L["Select the health update frequency."] = true
L["Add shields to health percent"] = true
L["Add shields to health amount"] = true

-- health-low status
L["Use Health Percent"] = true
L["Invert status activation"] = true

-- mana
L["Hide mana of non healer players"] = true
L["Primary resource"] = true
L["Secondary resource"] = true
L["Mana visible when it is the primary resource."] = true
L["Mana visible when it is not the primary resource, for example: druids in bear form or shadow priests."] = true

-- range status
L["Range"] = true
L["%d yards"] = true
L["Range in yards beyond which the status will be lost."] = true
L["Default alpha"] = true
L["Default alpha value when units are way out of range."] = true
L["Update rate"] = true
L["Rate at which the status gets updated"] = true
L["Out of range alpha"] = true
L["Out of range"] = true
L["Alpha value when units are way out of range."] = true
L["Heal Range"] = true
L["Spell Range"] = true
L["Range by class"] = true
L["Check this option to setup different range configuration for each player class."] = true

-- ready-check status
L["Delay"] = true
L["Set the delay until ready check results are cleared."] = true
L["Waiting color"] = true
L["Color for Waiting."] = true
L["Ready color"] = true
L["Color for Ready."] = true
L["Not Ready color"] = true
L["Color for Not Ready."] = true
L["AFK color"] = true
L["Color for AFK."] = true
L["Hide on Combat Start"] = true
L["Hide ready check status if combat starts."] = true

-- heals-incoming status
L["Include player heals"] = true
L["Substract heal absorbs"] =  true
L["Substract heal absorbs shields from the incoming heals"] = true
L["Display status for the player's heals."] = true
L["Minimum value"] = true
L["Incoming heals below the specified value will not be shown."] = true
L["Heals multiplier"] = true

--target status
L["Your Target"] = true

--threat status
L["Not Tanking"] = true
L["Higher threat than tank."] = true
L["Insecurely Tanking"] = true
L["Tanking without having highest threat."] = true
L["Securely Tanking"] = true
L["Tanking with highest threat."] = true
L["Disable Blink"] = true

-- voice status
L["Voice Chat"] = true

-- raid debuffs
L["General"]= true
L["Advanced"]= true
L["Enabled raid debuffs modules"]= true
L["Enabled"]= true
L["Enable All"]= true
L["Disable All"]= true
L["Copy to Debuffs"]= true
L["Select module"]= true
L["Select instance"]= true
L["Cataclysm"]= true
L["The Lich King"]= true
L["The Burning Crusade"] = true
L["New raid debuff"] = true
L["Type the SpellId of the new raid debuff"] = true
L["Create raid debuff"] = true
L["Delete raid debuff"] = true

-- direction
L["Out of Range"] = true
L["Display status for units out of range."] = true
L["Visible Units"] = true
L["Display status for units less than 100 yards away"] = true
L["Dead Units"] = true
L["Display status only for dead units"] = true
L["Show only selected sticky units"] = true
L["Show only when all conditions are met"] = true
L["Show always for selected sticky units"] = true

-- resurrection
L["Casting resurrection"] = true
L["A resurrection spell is being casted on the unit"] = true
L["Resurrected"] = true
L["A resurrection spell has been casted on the unit"] = true

-- power
L["Mana"] = true
L["Rage"] = true
L["Energy"] = true
L["Runic Power"] = true

-- shields status
L["shields"] = true
L["Maximum shield amount"] = true
L["Value used by bar indicators. Select zero to use players Maximum Health."] = true
L["Normal"] = true
L["Medium"] = true
L["Low"] = true
L["Normal shield color"] = true
L["Medium shield color"] = true
L["Low shield color"] = true
L["Low shield threshold"] = true
L["The value below which a shield is considered low."] = true
L["Medium shield threshold"] = true
L["The value below which a shield is considered medium."] = true
L["Custom Shields"] = true
L["Type shield spell IDs separated by commas."] = true

-- shields-overflow status
L["shields-overflow"] = true

-- heal-absorbs status
L["heal-absorbs"] = true
L["Maximum absorb amount"] = true
L["Medium absorb threshold"] = true
L["Low absorb threshold"] = true

-- role related statuses
L["Hide in combat"] = true
L["Hide Damagers"] = true

-- combat status
L["combat"] = true
L["Active Out Of Combat"] = true
L["Enable this option to invert the status so it will become activated when the player is Out Of Combat."] = true

-- pvp status
L["Hide inside Instances"] = true

-- summon status
L["summon"] = true
L["Player Summoned"] = true
L["Player has been summoned, waiting for a response."] = true
L["Summon Accepted"] = true
L["Player accepted the summon."] = true
L["Summon Declined"] = true
L["Player declined the summon."] = true

-- unit-index status
L["Enabled only for party units"] = true
L["Raid indexes will not be displayed."] = true
L["Enabled for player unit"] = true
L["Display a zero index for player unit while in party or raid."] = true

-- status descriptions
L["highlights your target"] = true
L["hostile casts against raid members"] = true
L["advanced threat detection"] = true
L["arrows pointing to each raid member"] = true
L["display remaining amount of heal absorb shields"] = true
L["display remaining amount of damage absorption shields"] = true
L["display remaining amount of damage absorb shields"] = true
L["Sticky Units"] = true
L["Tanks"] = true

-- aoe heals
L["neighbors"] = true
L["highlighter"] = true
L["OutgoingHeals"] = true
L["AOE Heals"] = true
L["Highlight status"] = true
L["Autodetect"] = true
L["Select the status the Highlighter will use."] = true
L["Mouse Enter Delay"] = true
L["Delay in seconds before showing the status."] = true
L["Mouse Leave Delay"] = true
L["Delay in seconds before hiding the status."] = true
L["Min players"] = true
L["Minimum players to enable the status."] = true
L["Radius"] = true
L["Max distance of nearby units."] = true
L["Health deficit"] = true
L["Minimum health deficit of units to enable the status."] = true
L["Keep same targets"] = true
L["Try to keep same heal targets solutions if posible."] = true
L["Max solutions"] = true
L["Maximum number of solutions to display."] = true
L["Hide on cooldown"] = true
L["Hide the status while the spell is on cooldown."] = true
L["Show overlapping heals"]  = true
L["Show heal targets even if they overlap with other heals."] = true
L["Show only in combat"]  = true
L["Enable the statuses only in combat."] = true
L["Show only in raid"] = true
L["Enable the statuses only in raid."]  = true
L["Active time"] = true
L["Show the status for the specified number of seconds."] = true
L["Spells"] = true
L["You can type spell IDs or spell names."] = true
L["Display all solutions"] = true
L["Display all solutions instead of only one solution per group."] = true

-- raid debuffs
L["Debuff Configuration"] = true
L["Link to Chat"] = true
L["Show in Encounter Journal"] = true
L["Encounter Journal difficulty"] = true
L["Delete this Instance"] = true
L["Bosses"] = true
L["Move To"] = true
L["Add a New Boss"] = true
L["RaidDebuffs Autodetection"] = true
L["Debuffs Autodetection"] = true
L["Enable Autodetection"] = true
L["Enable Zones and Debuffs autodetection"] = true
L["Move to Top"] = true
L["Move to Bottom"] = true
L["Delete Boss"] = true

-- profiles management
L["Profiles"] = true
L["You can change the active database profile, so you can have different settings for every character.\n"] = true
L["Current Profile"] = true
L["Select one of your currently available profiles."] = true
L["Reset"] = true
L["Reset the current profile back to its default values."] = true
L["Create a new empty profile by entering a name in the editbox."] = true
L["New Profile"] = true
L["Copy the settings from one existing profile into the currently active profile."] = true
L["Copy From"] = true
L["Copy the settings from one existing profile into the currently active profile."] = true
L["Are you sure you want to overwrite current profile values?"] = true
L["Delete existing and unused profiles from the database."] = true
L["Delete a Profile"] = true
L["Delete existing and unused profiles from the database."] = true
L["Are you sure you want to delete the selected profile?"] = true
L["You can assign a different database profile for each specialization, type of group or raid type."] = true
L["Enable profiles by Specialization"] = true
L["When enabled, your profile will be set according to the character specialization."] = true
L["Enable profiles by Type of Group"] = true
L["When enabled, your profile will be set according to the type of group."] = true
L["Enable profiles by Raid Type"] = true
L["When enabled, profiles by raid type can be configured."] = true
L["Select which profile to use for: "] = true
L["Solo"] = true
L["Party"] = true
L["Arena"] = true
L["Raid"] = true
L["Raid (PvP)"] = true
L["Raid (LFR)"] = true
L["Raid (Normal&Heroic)"] = true
L["Raid (Mythic)"] = true
L["Raid (World)"] = true
L["Raid (Other)"] = true

-- themes
L["Enable Themes"] = true
L["Themes"] = true
L["themes management"] = true
L["Default Theme"] = true
L["Additional Themes"] = true
L["Theme"] = true
L["Enable Theme for:"] = true
L["Create New Theme"] = true
L["Rename Theme"] = true
L["Reset Theme"] = true
L["Delete Theme"] = true
L["Single Theme"] = true
L["Specialization"] = true
L["Group Type"] = true
L["Group&Raid Type"] = true
L["By Group Type"] = true
L["By Raid Type"] = true

-- Import/export profiles module
L["Import&Export"] = true
L["Import/export options"]= true
L["Import profile"]= true
L["Export profile"]= true
L["Network sharing"]= true
L["Accept profiles from other players"]= true
L["Type player name"]= true
L["Send current profile"]= true
L["Profile import/export"]= true
L["Paste here a profile in text format"]= true
L["Press CTRL-V to paste a Grid2 configuration text"]= true
L["This is your current profile in text format"]= true
L["Press CTRL-C to copy the configuration to your clipboard"]= true
L["Progress"]= true
L["Data size: %.1fKB"]= true
L["Transmision progress: %d%%"]= true
L["Transmission completed"]= true
L["\"%s\" has sent you a profile configuration. Do you want to activate received profile ?"]= true
L["Include Custom Layouts"] = true

-- Open manager
L["Options management"] = true
L["Load options on demand (requires UI reload)"] = true
L["OPTIONS_ONDEMAND_DESC"] = "Options are not created until user clicks on them, reducing memory usage and load time. If you experiment any problem with this feature disable this option."

L["Delete this indicator"] = true
L["This indicator cannot be deleted because is in use. Uncheck the statuses linked to the indicator first."] = true
L["Are you sure you want to delete this indicator ?"] = true
L["Delete the selected indicator."] = true
L["Select a indicator to rename."] = true
L["Toggle test mode for indicators"] = true
L["Delete this status"] = true
L["Are you sure you want to delete this status ?"] = true
L["This status cannot be deleted because is attached to some indicators or the status is not enabled for this character."] = true
L["Show relevant buffs for each unit frame (the same buffs displayed by the Blizzard raid frames)."] = true
L["Are you sure do you want to delete this condition ?"] = true
L["Select one of your currently available themes."] = true
L["You can change the active theme, you can also assign different themes for each specialization, group type, raid type or instance size."] = true
L["Select the condition that must be met to display a new theme."] = true
L["Select an existing theme to be used as template to create the new theme."] = true
L["Type the name of the new Theme:"] = true
L["Select a Theme to Rename"] = true
L["Rename Theme:"] = true
L["Reset the selected theme back to the default values."] = true
L["Are you sure you want to reset the selected theme?"] = true
L["Delete the selected theme from the database."] = true
L["There are conditions referencing this theme. Are you sure you want to delete the selected theme ?"] = true
L["Are you sure you want to delete the selected theme?"] = true
L["Delete this condition"] = true
L["Raid (N&H)"] = true
L["5 man"] = true
L["10 man"] = true
L["15 man"] = true
L["20 man"] = true
L["25 man"] = true
L["30 man"] = true
L["35 man"] = true
L["40 man"] = true
L["Shape"] = true
L["Effect"] = true
L["Special"] = true
L["Text"] = true
L["Toggle debugging for %s."] = true
L["Resets the Grid2 main window position and anchor."] = true
L["\"%s\" has sent you a profile configuration. Do you want to activate received profile ?"] = true
L["Profile database maintenance"] = true
L["Clean Current Profile"] = true
L["Remove invalid or obsolete objects (indicators, statuses, etc) from the current profile database."] = true
L["Warning, the clean process will remove statuses and indicators of non enabled modules. Are you sure you want to clean the current profile ?"] = true
L["Enable support for multiple themes, allowing to define different visual styles for the Grid2 frames. General options will change and a new Themes section will be displayed."] = true
L["Error: this option cannot be disabled because extra themes have been created. Remove the extra themes first."] = true
L["Examples:\n(%d)\n%d seconds"] = true
L["Examples:\n%d/%s\n%s(%d)"] = true
L["Seconds Format"] = true
L["Examples:\n%ds\n%d seconds"] = true
L["Minutes Format"] = true
L["Examples:\n%dm\n%d minutes"] = true
L["Enable Durations"] = true
L["Check this option to be able to display auras duration & expiration time."] = true
L["UI must be reloaded to change this option. Are you sure?"] = true
L["Role(Raid)"] = true
L["Index (Raid Order)\nName (Unit Names))\nList (Name List)\nDef (Default)"] = true
L["Type a list of player names"] = true
L["Hide Player"] = true
L["Do not display the player frame (only applied when in group)."] = true
L["Clone this header"] = true
L["Delete this header"] = true
L["Auto"] = true
L["Automatic filter: groups will by filtered according to the instance size, for example for a 10 man raid instance, only players in groups 1&2 will be displayed."] = true
L["Add a new header.\nA header displays a group of players or pets in a compat way."] = true
L["Editor"] = true
L["Delete Layout"] = true
L["You can change the active database profile, so you can have different settings for every character.\n"] = true
L["Profile cannot be changed in combat"] = true
L["Are you sure you want to reset current profile?"] = true
L["shape"] = true
L["Are you sure do you want to convert the indicator to the new selected type?"] = true
L["Default:\nUse the size specified by the active theme.\nPixels:\nUser defined size in pixels.\nPercent:\nUser defined size as percent of the frame height."] = true
L["Pixels"] = true
L["Percent"] = true
L["Adjust the size of the icon."] = true
L["Adjust the texture of the indicator."] = true
L["Only on Activation"] = true
L["Start the animation only when the indicator is activated, not on updates."] = true
L["Origin"] = true
L["Zoom origin point"] = true
L["This indicator cannot be changed from here: go to indicators section to assign/unassign statuses to this indicator."] = true
L["Default Alpha"] = true
L["Default Alpha Value"] = true
L["Alpha/opacity when the indicator is not activated.\n0 = full transparent\n1 = full opaque"] = true
L["Active Alpha"] = true
L["Use Status Alpha"] = true
L["Check this option to use the alpha value provided by the active status."] = true
L["Active Alpha Value"] = true
L["Alpha/Opacity value to apply to the frame when the indicator is activated.\n0 = full transparent\n1 = full opaque"] = true
L["Sets the background color to use when no status is active."] = true
L["|cFFe0e000\nThese options are applied to the active theme, if you want to change the settings for another theme go to the Appearance tab inside the Themes section."] = true
L["Always Visible"] = true
L["Display the background even when the indicator is not active."] = true
L["Adjust the background texture."] = true
L["Sets the color for the border when no status is active."] = true
L["Custom Color"] = true
L["Blizzard"] = true
L["Blizzard Glow effect is already in use by another indicator, select another effect."] = true
L["Glow Color"] = true
L["Choose how to colorize the glow border."] = true
L["Sets the glow color to use when the indicator is active."] = true
L["Glow Effect"] = true
L["Select the glow effect."] = true
L["Animation Speed"] = true
L["Number of Lines"] = true
L["Thickness"] = true
L["Number of particles"] = true
L["Scale of particles"] = true
L["Pixel"] = true
L["Shine"] = true
L["Display Square"] = true
L["Display a flat square texture instead of the icon provided by the status."] = true
L["Adjust the horizontal offset of the text"] = true
L["Adjust the vertical offset of the text"] = true
L["Set the font border type."] = true
L["Orientation"] = true
L["Set the icons orientation."] = true
L["Display Squares"] = true
L["Display flat square textures instead of the icons provided by the statuses."] = true
L["Select maximum number of icons to display."] = true
L["Select the number of icons per row."] = true
L["Adjust the size of the icons, select Zero to use the theme default icon size."] = true
L["Adjust the space between icons."] = true
L["Prev. Bar & Reverse"] = true
L["Whole Background"] = true
L["Select bar texture."] = true
L["Color Source"] = true
L["Select howto colorize the main bar."] = true
L["Bar color"] = true
L["Invert"] = true
L["Swap foreground/background colors on main bar."] = true
L["Select howto colorize the bar."] = true
L["Select bar color"] = true
L["Anchor"] = true
L["Select howto anchor the background bar."] = true
L["Add Bar"] = true
L["Add a new bar"] = true
L["Delete Bar"] = true
L["Delete last bar"] = true
L["This action cannot be undone. Are you sure?"] = true
L["Del Background"] = true
L["Add Background"] = true
L["Enable or disable the background texture"] = true
L["Portrait Type"] = true
L["Select the portrait to display."] = true
L["Inner Border"] = true
L["2D Model"] = true
L["3D Model"] = true
L["Class Icon"] = true
L["Square"] = true
L["Rounded Square"] = true
L["Circle"] = true
L["Diamond"] = true
L["Triangle"] = true
L["Right Triangle"] = true
L["Semi Circle"] = true
L["Quarter Circle"] = true
L["0 degrees"] = true
L["90 degrees"] = true
L["180 degrees"] = true
L["270 degrees"] = true
L["Select the shape to display"] = true
L["Rotation"] = true
L["Select the shape angle"] = true
L["Adjust the size of the shape, select zero to use the theme default icon size."] = true
L["Enable Shadow"] = true
L["Display a Shadow under the Shape."] = true
L["Extra Size"] = true
L["Extra size of the shadow shape."] = true
L["Swap Colors"] = true
L["Swap border and square colors. Square will be filled with the border color and linked statuses colors will be applied to the border."] = true
L["Adjust the font size, select zero to use the theme default font size."] = true
L["Show tooltip when mouseover a unit."] = true
L["Enable this option to be able to customize the tooltip. Once enabled you can go to the 'statuses' tab to select which information you want to display."] = true
L["Are you sure you want to disable the advanced tooltips?"] = true
L["Enable this option to display the default unit tooltip when Out of Combat."] = true
L["Enable the status only if your toon belong to the specified class."] = true
L["There are indicators linked to this status or the status is not enabled for this character."] = true
L["Aura Name or Spell ID"] = true
L["Change Buff/Debuff Name or Spell ID."] = true
L["Text to Display"] = true
L["Type Custom Text"] = true
L["Text to display in Text Indicators."] = true
L["Value Tracked"] = true
L["Aura Name"] = true
L["Custom Text"] = true
L["Dispellable by Me"] = true
L["Display debuffs i can dispell"] = true
L["Non Dispellable by Me"] = true
L["Display debuffs i can not dispell"] = true
L["Typed Debuffs"] = true
L["Display Magic, Curse, Poison or Disease type debuffs."] = true
L["Untyped Debuffs"] = true
L["Display debuffs with no type."] = true
L["Display debuffs not casted by Bosses"] = true
L["Display debuffs direct casted by Bosses"] = true
L["Display debuffs with duration below 5 minutes."] = true
L["Display debuffs with duration above 5 minutes."] = true
L["Display debuffs with a duration."] = true
L["Display debuffs with no duration."] = true
L["Display non self debuffs"] = true
L["Display self debuffs"] = true
L["Display only debuffs defined in a user defined list."] = true
L["Ignore debuffs defined in a user defined list."] = true
L["Type a list of debuffs, one debuff per line."] = true
L["You can include a descriptive prefix using separators \"@#>\""] = true
L["Create a new Buff."] = true
L["Display status only if the debuff was cast by you."] = true
L["Display status only if the debuff was not cast by you."] = true
L["Use Empty Icon"] = true
L["Displays an invisible Icon."] = true
L["Color by distance"] = true
L["Always display direction for tanks"] = true
L["Mouseover"] = true
L["Always display direction for mouseover"] = true
L["Target Unit"] = true
L["Always display direction for target"] = true
L["Focus Unit"] = true
L["Always display direction for focus"] = true
L["Normal heal absorbs color"] = true
L["Medium heal absorbs color"] = true
L["Low heal absorbs color"] = true
L["Show my spells only."] = true
L["Show others spells only."] = true
L["Add heal spells"] = true
L["Raid Cooldowns"] = true
L["Type New Status Name"] = true
L["Type the name of the new AOE-Heals status to create."] = true
L["Invalid status name or already in use."] = true
L["Select heal spells"] = true
L["%d seconds"] = true
L["Heals Time Band"] = true
L["Show only heals that are going to land within the selected time period. Select None to display all heals."] = true
L["Heal Types"] = true
L["Shorten Heal Numbers"] = true
L["Shorten Health Numbers"] = true
L["Shorten Thousand Numbers"] = true
L["Shorten Above Million Numbers"] = true
L["Include heals casted by me, if unchecked only other players heals are displayed."] = true
L["Apply this multiplier value to incoming heals."] = true
L["Incoming overheals below the specified value will not be shown."] = true
L["Shorten Overhealing Numbers"] = true
L["display heals above max hp"] = true
L["Add Incoming Heals"] = true
L["Add incoming heals to health deficit."] = true
L["Casted"] = true
L["Channeled"] = true
L["HOTs"] = true
L["Bomb"] = true
L["Insanity"] = true
L["Maelstrom"] = true
L["Lunar Power"] = true
L["Fury"] = true
L["Pain"] = true
L["High stagger"] = true
L["Medium stagger"] = true
L["Low stagger"] = true
L["Default Name"] = true
L["Select the text to display when the unit name is not available."] = true
L["Unit Tag"] = true
L["Nothing"] = true
L["Transliterate cyrillic letters"] = true
L["Convert cyrillic letters to latin alphabet."] = true
L["Display Pet's Owner"] = true
L["Display the pet's owner name instead of the pet name."]  = true
L["Display Vehicle's Owner"] = true
L["Display the vehicle's owner name instead of the vehicle name."] = true
L["Use Owner/Vehicle Class Color"] = true
L["N/A"] = true
L["Use alternate icons"] = true
L["display damage absorb shields above max hp"] = true
L["Hide in Pet Battles"] = true
L["Toggle to hide Grid2 window in Pet Battles"] = true
L["Horizontal Position"] = true
L["Adjust Grid2 horizontal position."] = true
L["Vertical Position"] = true
L["Adjust Grid2 vertical position."] = true
L["Sets the default color for the background indicator."] = true
L["Borders"] = true
L["Sets the default color for the border indicator."] = true
L["Select the default texture for bars indicators."] = true
L["Select the default font for text indicators."] = true
L["Set the default border type for fonts."] = true
L["Default font size for text indicators."] = true
L["Default size for icon indicators."] = true
L["A Layout defines which unit frames will be displayed and the way in which they are arranged. Here you can set different layouts for each group or raid type."] = true
L["Select zero to use default Frame Width"] = true
L["Select zero to use default Frame Height"] = true
L["Are you sure?"] = true
L["A Layout defines which unit frames will be displayed and the way in which they are arranged. Here you can set different layouts for each raid size."] = true
L["Add instance size"] = true
L["Bar"] = true
L["Back"] = true
L["Adjust"] = true
L["Horizontal Tiles"] = true
L["Vertical Tiles"] = true
L["Repeat"] = true
L["Mirror"] = true
L["Percent Format"] = true
L["Examples:\n%p\n%p percent"] = true
L["Raid Size"] = true
L["Choose the Raid Size calculation method"] = true
L["This setting is used to setup different layouts, frame sizes or themes depending of the raid size."] = true
L["Maximum capacity of the instance"] = true
L["Maximum non-empty raid group"] = true
L["Number of non-empty raid groups"] = true
L["Number of players in raid"] = true

-- RaidDebuffsOptions
L["[Custom Debuffs]"] = true
L["Develop"] = true
L["This instance is not empty. Are you sure you want to remove it ?"] = true
L["Rename Boss"] = true
L["Move Up"] = true
L["Move debuff higher in the priority list."] = true
L["This debuff is already at the top of the list."] = true
L["Move Down"] = true
L["Move debuff lower in the priority list."] = true
L["This debuff is already at the bottom of the list."] = true
L["Delete last status"] = true
L["Are your sure you want to delete %s status ?"] = true
L["Assign autodetected raid debuffs to the specified status"] = true
L["Default difficulty for Encounter Journal links"] = true
L["multiple icons support"] = true
L["Enable multiple icons support for icons indicators."] = true
L["Battle for Azeroth"] = true
L["Legion"] = true
L["Shadowlands"] = true

-- Extra translations
L["tooltip"] = true
L["background"] = true
L["Typeless"] = true
L["phased"] = true
L["color"] = true

L["Disabled in instances"] = true
L["Disable this status inside instances."] = true
L["Display other groups"] = true
L["Enable the status if the player is in another LFG or PvP instance."] = true

L["Enable harmful spells Allowlist"] = true
L["Display only the spells specified in a user defined list."] = true

L["Load"] = true
L["Indicators"] = true
L["Display health percent text for enemies"] = true
L["Display health percent text instead of health deficit for non friendly units."] = true
L["Never load this status"] = true
L["Player Class"] = true
L["Load the status only if your toon belong to the specified class."] = true
L["Player Class&Spec"] = true
L["Load the status only if your toon has the specified class and specialization."] = true
L["Instance Type"] = true
L["Load the status only if you are in the specified instance type."] = true
L["Load the status only if you are in the specified group type."] = true
L["Instance Name/ID"] = true
L["Supports multiple names or IDs separated by commas or newlines.\n\nCurrent Instance:\n%s(%d)"] = true
L["Spell Ready"] = true
L["Load the status only if the specified player spell is not in cooldown."] = true
L["Unit Reaction"] = true
L["Load the status only if the unit has the specified reaction towards the player."] = true
L["Unit Class"] = true
L["Load the status only if the unit belong to the specified class."] = true
L["Unit Role"] = true
L["Load the status only if the unit has the specified role."] = true
L["Unit Type"] = true
L["Load the status only for the specified unit types."] = true
L["Load the indicator only for the specified unit types."] = true
L["Active Theme"] = true
L["Load the indicator only for the specified themes."] = true
L["Unit Alive"] = true
L["Load the status only if the unit is alive/dead."] = true

L["Select layouts for different Raid types."] = true
L["Use Blizzard Unit Frames"] = true
L["Disable this option to use custom unit frames instead of blizzard frames. This fixes some bugs in blizzard code, but units cannot join/leave the roster while in combat."] = true
L["Detach all groups"] = true
L["Enable this option to detach unit frame groups, so each group can be moved individually."] = true
L["Detach pets groups"] = true
L["Enable this option to detach the pets group, so pets group can be moved individually."] = true
L["Special units headers visibility."] = true
L["Display Player unit"] = true
L["Enable this option to display the player unit."] = true
L["Display Target unit"] = true
L["Enable this option to display the target unit."] = true
L["Display Focus unit"] = true
L["Enable this option to display the focus unit."] = true
L["Display Bosses units"] = true
L["Enable this option to display the bosses unit."] = true
L["Display Target of Target unit"] = true
L["Enable this option to display the target of target unit."] = true
L["Display Target of Focus unit"] = true
L["Enable this option to display the target of focus unit."] = true
L["Units Per Column"] =  true
L["Bosses units to display per column."] = true
L['Hide Empty'] = true
L["Hide empty bosses units."] = true

L["Party (Normal)"] = true
L["Party (Heroic)"] = true
L["Party (Mythic)"] = true

L["Click Targeting"] = true
L["Trigger targeting on the down portion of the mouse click"] = true

L["Show when all buffs are active"] = true
L["Display the status only when all buffs are active."] = true
