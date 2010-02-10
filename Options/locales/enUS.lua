local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "enUS", true, true)
if not L then return end

L["Debug"] = true
L["Debugging"] = true
L["Module debugging menu."] = true

L["Show Tooltip"] = true
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = true
L["Always"] = true
L["Never"] = true
L["OOC"] = true

L["blink"] = true
L["category"] = true
L["frame"] = true
L["layout"] = true
L["location"] = true
L["indicator"] = true
L["status"] = true

L["buff"] = true
L["debuff"] = true

L["Icon"] = true
L["Square"] = true
L["Text"] = true

L["Advanced"] = true
L["Advanced options."] = true

L["Frame Width"] = true
L["Adjust the width of each unit's frame."] = true
L["Frame Height"] = true
L["Adjust the height of each unit's frame."] = true
L["Border Size"] = true
L["Adjust the border of each unit's frame."] = true

L["Options for %s."] = true
L["Toggle debugging for %s."] = true

L["Show Frame"] = true
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = true
L["Always"] = true
L["Grouped"] = true
L["Raid"] = true

L["Layouts"] = true
L["Layouts for each type of groups you're in."] = true
L["Solo Layout"] = true
L["Select which layout to use for solo."] = true
L["Party Layout"] = true
L["Select which layout to use for party."] = true
L["Raid Layout"] = true
L["Raid 40 Layout"] = true
L["Select which layout to use for raid."] = true
L["Heroic Raid Layout"] = true
L["Select which layout to use for raid in heroic mode."] = true
L["Battleground Layout"] = true
L["Select which layout to use for battlegrounds."] = true
L["Arena Layout"] = true
L["Select which layout to use for arenas."] = true

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

L["Alpha"] = true
L["Border"] = true
L["Adjust border color and alpha."] = true
L["Background"] = true
L["Adjust background color and alpha."] = true

L["Layout Anchor"] = true
L["Sets where Grid is anchored relative to the screen."] = true

L["CENTER"] = true
L["TOP"] = true
L["BOTTOM"] = true
L["LEFT"] = true
L["RIGHT"] = true
L["TOPLEFT"] = true
L["TOPRIGHT"] = true
L["BOTTOMLEFT"] = true
L["BOTTOMRIGHT"] = true

L["corner-top-left"] = "corner-top-left"
L["corner-top-right"] = "corner-top-right"
L["corner-bottom-left"] = "corner-bottom-left"
L["corner-bottom-right"] = "corner-bottom-right"
L["side-left"] = "side-left"
L["side-left-top"] = "side-left-top"
L["side-left-bottom"] = "side-left-bottom"
L["side-right"] = "side-right"
L["side-right-top"] = "side-right-top"
L["side-right-bottom"] = "side-right-bottom"
L["side-top"] = "side-top"
L["side-top-left"] = "side-top-left"
L["side-top-right"] = "side-top-right"
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

L["Beast"] = true
L["Demon"] = true
L["Humanoid"] = true
L["Elemental"] = true

L["DEATHKNIGHT"] = "Death Knight"
L["DRUID"] = "Druid"
L["HUNTER"] = "Hunter"
L["MAGE"] = "Mage"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Priest"
L["ROGUE"] = "Rogue"
L["SHAMAN"] = "Shaman"
L["WARLOCK"] = "Warlock"
L["WARRIOR"] = "Warrior"

--Account Layer
L["account"] = true

--Class Layer
L["druid"] = true
L["paladin"] = true
L["priest"] = true
L["shaman"] = true

--Spec Layer
L["tree"] = true
L["holy1"] = true
L["holy2"] = true
L["resto"] = true

L["Layer"] = true
L["Layer level.  Higher layers (like Class or Spec) supercede lower ones like Account."] = true

L["Opacity"] = true
L["Set the opacity."] = true

L["<CharacterOnlyString>"] = true
L["+"] = true
L["-"] = true
L["%d yards"] = true
L["Align Point"] = true
L["Align this point on the indicator"] = true
L["Align relative to"] = true
L["Align my align point relative to"] = true
L["Available Statuses"] = true
L["Available statuses you may add"] = true
L["Blink Threshold"] = true
L["Blink Threshold at which to start blinking the status."] = true
L["Class Filter"] = true
L["Create a new category of statuses."] = true
L["Create a new indicator."] = true
L["Create a new location for an indicator."] = true
L["Create a new status."] = true
L["Current Statuses"] = true
L["Current statuses in order of priority"] = true
L["Delete"] = true
L["Display status only if the buff is not active."] = true
L["Display status only if the buff was cast by you."] = true
L["Down"] = true
L["Location"] = true
L["Move the status higher in priority"] = true
L["Move the status lower in priority"] = true
L["Name"] = true
L["Name of the new indicator"] = true
L["New Category"] = true
L["New Indicator"] = true
L["New Location"] = true
L["New Status"] = true
L["Range"] = true
L["Range in yards beyond which the status will be lost."] = true
L["Reset"] = true
L["Reset and ReloadUI."] = true
L["Reset Setup"] = true
L["Reset current setup and ReloadUI."] = true
L["Reset Categories"] = true
L["Reset categories to the default list."] = true
L["Reset Indicators"] = true
L["Reset indicators to defaults."] = true
L["Reset Locations"] = true
L["Reset locations to the default list."] = true
L["Reset Statuses"] = true
L["Reset statuses to defaults."] = true
L["Select statuses to display with the indicator"] = true
L["Select the location of the indicator"] = true
L["Show duration"] = true
L["Show if mine"] = true
L["Show if missing"] = true
L["Show on %s."] = true
L["Show status for the selected classes."] = true
L["Show the time remaining."] = true
L["Threshold"] = true
L["Threshold at which to activate the status."] = true
L["Type"] = true
L["Type of indicator to create"] = true
L["Up"] = true
L["X Offset"] = true
L["X - Horizontal Offset"] = true
L["Y Offset"] = true
L["Y - Vertical Offset"] = true

L["Group Anchor"] = true
L["Position and Anchor"] = true
L["Sets where groups are anchored relative to the layout frame."] = true
L["Resets the layout frame's position and anchor."] = true

L["Center Text Length"] = true
L["Number of characters to show on Center Text indicator."] = true
L["Font Size"] = true
L["Adjust the font size."] = true
L["Font"] = true
L["Adjust the font settings"] = true
L["Frame Texture"] = true
L["Adjust the texture of each unit's frame."] = true
L["Orientation of Frame"] = true
L["Set frame orientation."] = true
L["VERTICAL"] = true
L["HORIZONTAL"] = true

L["Icon Size"] = true
L["Adjust the size of the center icon."] = true
L["Size"] = true
L["Adjust the size of the indicators."] = true

L["Blink effect"] = true
L["Select the type of Blink effect used by Grid2."] = true
L["None"] = true
L["Blink"] = true
L["Flash"] = true
L["Blink Frequency"] = true
L["Adjust the frequency of the Blink effect."] = true

L["Color"] = true
L["Color %d"] = true
L["Color for %s."] = true
L["Color Charmed Unit"] = true
L["Color Units that are charmed."] = true
L["Unit Colors"] = true
L["Charmed unit Color"] = true
L["Default unit Color"] = true
L["Default pet Color"] = true
L["%s Color"] = true
L["Show dead as having Full Health"] = true
L["Default alpha"] = true
L["Default alpha value when units are way out of range."] = true
L["Update rate"] = true
L["Rate at which the range gets updated"] = true
L["Invert Bar Color"] = true
L["Swap foreground/background colors on bars."] = true

L["ready-check"] = true
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

L["Include player heals"] = true
L["Display status for the player's heals."] = true
L["Type of Heals taken into account"] = true
L["Select the type of healing spell taken into account for the amount of incoming heals calculated."] = true
L["Casted heals, both direct and channeled"] = true
L["Direct heals only."] = true
L["All heals, including casted and HoTs"] = true
