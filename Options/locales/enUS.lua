local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "enUS", true, true)
if not L then return end


--{{{ General options
L["GRID2_DESC"] = true

L["General Settings"] = true

L["statuses"] = "Statuses"
L["indicators"] ="Indicators"

L["Frames"] = true
L["frame"] = true

L["Invert Bar Color"] = true
L["Swap foreground/background colors on bars."] = true

L["Background Color"] = true
L["Sets the background color of each unit frame"] = true

L["Mouseover Highlight"] = true
L["Toggle mouseover highlight."] = true

L["Show Tooltip"] = true
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = true
L["Always"] = true
L["Never"] = true
L["OOC"] = true

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

L["Orientation of Frame"] = true
L["Set frame orientation."] = true
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

L["Warning! This option will delete all settings and profiles, are you sure ?"]= true

L["About"] = true

--{{{ Layouts options
L["Layout"] = true
L["Layouts"] = true
L["layout"] = true
L["Layouts for each type of groups you're in."] = true
L["Layout Settings"] = true
L["Solo Layout"] = true
L["Select which layout to use for solo."] = true
L["Party Layout"] = true
L["Select which layout to use for party."] = true
L["Raid %s Layout"] = true
L["Select which layout to use for %s person raids."] = true
L["Battleground Layout"] = true
L["Select which layout to use for battlegrounds."] = true
L["Arena Layout"] = true
L["Select which layout to use for arenas."] = true
L["Test"]= true
L["Test the layout."]= true

--{{{ Miscelaneous
L["Name"] = true
L["New"] = true
L["Order"] = true
L["Delete"] = true
L["Color"] = true
L["Color %d"] = true
L["Color for %s."] = true
L["Font"] = true
L["Adjust the font settings"] = true
L["Border"] = true
L["Background"] = true
L["Adjust border color and alpha."] = true
L["Adjust background color and alpha."] = true
L["Opacity"] = true
L["Set the opacity."] = true
L["<CharacterOnlyString>"] = true
L["Options for %s."]= true

--{{{ Indicator management
L["New Indicator"] = true
L["Create a new indicator."] = true
L["Name of the new indicator"] = true
L["Enable Test Mode"] = true
L["Disable Test Mode"] = true
L["Appearance"] = true
L["Adjust the border size of the indicator."] = true
L["Reverse Cooldown"] = true
L["Set cooldown to become darker over time instead of lighter."] = true
L["Cooldown"]= true
L["Text Location"]= true
L["Disable OmniCC"]= true
 
L["Type"] = true
L["Type of indicator"] = true
L["Type of indicator to create"] = true

L["Text Length"] = true
L["Maximum number of characters to show."] = true
L["Font Size"] = true
L["Adjust the font size."] = true
L["Size"] = true
L["Adjust the size of the indicator."] = true

L["Frame Texture"] = true
L["Adjust the texture of the bar."] = true

L["Show stack"] = true
L["Show the number of stacks."] = true
L["Show duration"] = true
L["Show the time remaining."] = true

L["Orientation of the Bar"] = true
L["Set status bar orientation."] = true
L["DEFAULT"]= true
L["Frame Level"] = true
L["Bars with higher numbers always show up on top of lower numbers."] = true
L["Bar Width"] = true
L["Choose zero to set the bar to the same width as parent frame"] = true
L["Bar Height"] = true
L["Choose zero to set the bar to the same height as parent frame"] = true

L["Border Size"] = true
L["Adjust the border of each unit's frame."] = true
L["Border Background Color"] = true
L["Adjust border background color and alpha."] = true

L["Select statuses to display with the indicator"] = true
L["+"] = true
L["-"] = true
L["Available Statuses"] = true
L["Available statuses you may add"] = true
L["Current Statuses"] = true
L["Current statuses in order of priority"] = true
L["Move the status higher in priority"] = true
L["Move the status lower in priority"] = true

L["indicator"] = true

-- indicator types
L["icon"] = true
L["square"] = true
L["text"] = true
L["bar"] = true

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
L["-color"]= ":color"
L["-mine"]= ":mine"
L["-not-mine"]= ":not mine"
L["buff-"]= "buff: "
L["debuff-"]= "debuff: "

L["status"] = true

L["buff"] = true
L["debuff"] = true

L["New Status"] = true
L["Create a new status."] = true

L["Threshold"] = true
L["Threshold at which to activate the status."] = true

-- buff & debuff statuses management
L["Buffs"] = true
L["Debuffs"] = true
L["Show if mine"] = true
L["Show if not mine"] = true
L["Show if missing"] = true
L["Display status only if the buff is not active."] = true
L["Display status only if the buff was cast by you."] = true
L["Display status only if the buff was not cast by you."] = true
L["Color count"]= true
L["Select how many colors the status must provide."]= true
L["You can include a descriptive prefix using separators \"@#>\""]= true
L["examples: Druid@Regrowth Chimaeron>Low Health"]= true

L["Class Filter"] = true
L["Show on %s."] = true

L["Blink Threshold"] = true
L["Blink Threshold at which to start blinking the status."] = true

-- general statuses
L["name"]= true
L["mana"]= true
L["poweralt"]= true
L["alpha"] = true
L["border"] = true
L["heals"] = true
L["health"] = true
L["charmed"] = true
L["afk"] = true
L["death"] = true
L["classcolor"] = true
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
L["ready-check"] = true
L["role"] = true
L["dungeon-role"] = true
L["target"] = true
L["threat"] = true
L["banzai"] = true
L["vehicle"] = true
L["voice"] = true
L["pvp"] = true
L["direction"] = true

L["Curse"] = true
L["Poison"] = true
L["Disease"] = true
L["Magic"] = true

L["raid-debuffs"] = true

-- class specific buffs & debuffs statuses

-- shaman
L["EarthShield"] = true
L["Earthliving"] = true
L["Riptide"] = true

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

-- class color status
L["%s Color"] = "%s"
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
L["Beast"] = "Beasst"
L["Demon"] = "Demon"
L["Humanoid"] = "Humanoid"
L["Elemental"] = "Elemental"

-- heal-current status
L["Show dead as having Full Health"] = true

-- range status 
L["Range"] = true
L["%d yards"] = true
L["Range in yards beyond which the status will be lost."] = true
L["Default alpha"] = true
L["Default alpha value when units are way out of range."] = true
L["Update rate"] = true
L["Rate at which the range gets updated"] = true

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

-- heals-incoming status 
L["Include player heals"] = true
L["Display status for the player's heals."] = true
L["Minimum value"] = true
L["Incoming heals below the specified value will not be shown."] = true

--role status
L["MAIN_ASSIST"] = MAIN_ASSIST
L["MAIN_TANK"] = MAIN_TANK

--target status
L["Your Target"] = true

--threat status
L["Not Tanking"] = true
L["Higher threat than tank."] = true
L["Insecurely Tanking"] = true
L["Tanking without having highest threat."] = true
L["Securely Tanking"] = true
L["Tanking with highest threat."] = true

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
		
-- Import/export profiles module
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
