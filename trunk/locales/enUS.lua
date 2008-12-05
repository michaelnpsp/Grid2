local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "enUS", true)
if not L then return end

--{{{ GridCore
L["Configure"] = true
L["Configure Grid"] = true

--}}}
--{{{ GridFrame
L["Frame"] = true
L["Options for GridFrame."] = true

L["Indicators"] = true
L["Border"] = true
L["Health Bar"] = true
L["Health Bar Color"] = true
L["Center Text"] = true
L["Center Text 2"] = true
L["Center Icon"] = true
L["Top Left Corner"] = true
L["Top Right Corner"] = true
L["Bottom Left Corner"] = true
L["Bottom Right Corner"] = true
L["Frame Alpha"] = true

L["Options for %s indicator."] = true
L["Statuses"] = true
L["Toggle status display."] = true

-- Advanced options
L["Enable %s indicator"] = true
L["Toggle the %s indicator."] = true
L["Orientation of Text"] = true
L["Set frame text orientation."] = true

--}}}
--{{{ GridLayout
L["Layout"] = true
L["Options for GridLayout."] = true

-- Layout options
L["Raid Layout"] = true
L["Select which raid layout to use."] = true
L["Show Party in Raid"] = true
L["Show party/self as an extra group."] = true
L["Show Pets for Party"] = true
L["Show the pets for the party below the party itself."] = true

-- Display options
L["Pet color"] = true
L["Set the color of pet units."] = true
L["Pet coloring"] = true
L["Set the coloring strategy of pet units."] = true
L["By Owner Class"] = true
L["By Creature Type"] = true
L["Using Fallback color"] = true
L["Beast"] = true
L["Demon"] = true
L["Humanoid"] = true
L["Elemental"] = true
L["Colors"] = true
L["Color options for class and pets."] = true
L["Fallback colors"] = true
L["Color of unknown units or pets."] = true
L["Unknown Unit"] = true
L["The color of unknown units."] = true
L["Unknown Pet"] = true
L["The color of unknown pets."] = true
L["Class colors"] = true
L["Color of player unit classes."] = true
L["Creature type colors"] = true
L["Color of pet unit creature types."] = true
L["Color for %s."] = true

-- Advanced options
L["Advanced"] = true
L["Advanced options."] = true

--}}}
--{{{ GridLayoutLayouts
L["None"] = true
L["Solo"] = true
L["Solo w/Pet"] = true
L["By Group 5"] = true
L["By Group 5 w/Pets"] = true
L["By Group 40"] = true
L["By Group 25"] = true
L["By Group 25 w/Pets"] = true
L["By Group 20"] = true
L["By Group 15"] = true
L["By Group 15 w/Pets"] = true
L["By Group 10"] = true
L["By Group 10 w/Pets"] = true
L["By Class"] = true
L["By Class w/Pets"] = true
L["Onyxia"] = true
L["By Group 25 w/tanks"] = true

--}}}
--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = true

--}}}
--{{{ GridStatus
L["Status"] = true
L["Statuses"] = true

-- module prototype
L["Status: %s"] = true
L["Color"] = true
L["Color for %s"] = true
L["Priority"] = true
L["Priority for %s"] = true
L["Range filter"] = true
L["Range filter for %s"] = true
L["Enable"] = true
L["Enable %s"] = true

--}}}
--{{{ GridStatusAggro
L["Aggro"] = true
L["Aggro alert"] = true

--}}}
--{{{ GridStatusAuras
L["Auras"] = true
L["Debuff type: %s"] = true
L["Poison"] = true
L["Disease"] = true
L["Magic"] = true
L["Curse"] = true
L["Ghost"] = true
L["Add new Buff"] = true
L["Adds a new buff to the status module"] = true
L["<buff name>"] = true
L["Add new Debuff"] = true
L["Adds a new debuff to the status module"] = true
L["<debuff name>"] = true
L["Delete (De)buff"] = true
L["Deletes an existing debuff from the status module"] = true
L["Remove %s from the menu"] = true
L["Debuff: %s"] = true
L["Buff: %s"] = true
L["Class Filter"] = true
L["Show status for the selected classes."] = true
L["Show on %s."] = true
L["Show if missing"] = true
L["Display status only if the buff is not active."] = true
L["Filter Abolished units"] = true
L["Skip units that have an active Abolish buff."] = true

--}}}
--{{{ GridStatusName
L["Unit Name"] = true
L["Color by class"] = true

--}}}
--{{{ GridStatusMana
L["Mana"] = true
L["Low Mana"] = true
L["Mana threshold"] = true
L["Set the percentage for the low mana warning."] = true
L["Low Mana warning"] = true

--}}}
--{{{ GridStatusHeals
L["Heals"] = true
L["Incoming heals"] = true
L["Ignore Self"] = true
L["Ignore heals cast by you."] = true
L["(.+) begins to cast (.+)."] = true
L["(.+) gains (.+) Mana from (.+)'s Life Tap."] = true
L["^Corpse of (.+)$"] = true

--}}}
--{{{ GridStatusHealth
L["Low HP"] = true
L["DEAD"] = true
L["GHOST"] = true
L["FD"] = true
L["Offline"] = true
L["Unit health"] = true
L["Health deficit"] = true
L["Low HP warning"] = true
L["Feign Death warning"] = true
L["Death warning"] = true
L["Offline warning"] = true
L["Health"] = true
L["Show dead as full health"] = true
L["Treat dead units as being full health."] = true
L["Use class color"] = true
L["Color health based on class."] = true
L["Health threshold"] = true
L["Only show deficit above % damage."] = true
L["Color deficit based on class."] = true
L["Low HP threshold"] = true
L["Set the HP % for the low HP warning."] = true

--}}}
--{{{ GridStatusRange
L["Range"] = true
L["Range check frequency"] = true
L["Seconds between range checks"] = true
L["Out of Range"] = true
L["OOR"] = true
L["Range to track"] = true
L["Range in yard beyond which the status will be lost."] = true
L["%d yards"] = true

--}}}
--{{{ GridStatusTarget
L["Target"] = true
L["Your Target"] = true

--}}}
--{{{ GridStatusVoiceComm
L["Voice Chat"] = true
L["Talking"] = true

--}}}
