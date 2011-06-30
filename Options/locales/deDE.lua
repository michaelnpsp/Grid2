local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "deDE")
if not L then return end

--{{{ General options
L["GRID2_DESC"] = "Wilkommen bei Grid2"

L["General Settings"] = "Allgemeine Einstellungen"

-- L["statuses"] = ""
-- L["indicators"] = ""

-- L["Frames"] = ""
L["frame"] = "Rahmen"

L["Invert Bar Color"] = "Invertiere Leisten Farbe"
L["Swap foreground/background colors on bars."] = "Umschalten Vorder/Hintergrund Farbe der Leisten"

-- L["Background Color"] = ""
-- L["Sets the background color of each unit frame"] = ""

L["Mouseover Highlight"] = "Rahmen Hervorhebung"
L["Toggle mouseover highlight."] = "Rahmen Hervorhebung (Mouseover Highlight) ein-/ausschalten."

L["Show Tooltip"] = "Zeige Tooltip"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "Zeige Einheiten Tooltip. Wähle:'Immer', 'Nie', oder 'OOC'"
L["Always"] = "Immer"
L["Never"] = "Nie"
L["OOC"] = "Ausserhalb des Kampfes 'OOC'"

-- L["Background Texture"] = ""
-- L["Select the frame background texture."] = ""

-- L["Inner Border Size"] = ""
-- L["Sets the size of the inner border of each unit frame"] = ""

-- L["Inner Border Color"] = ""
-- L["Sets the color of the inner border of each unit frame"] = ""

L["Frame Width"] = "Rahmen Breite"
L["Adjust the width of each unit's frame."] = "Einstellung für die Breite des Einheiten Rahmens"

L["Frame Height"] = "Rahmen Höhe"
L["Adjust the height of each unit's frame."] = "Einstellung für die Höhe des Einheiten Rahmens"

L["Orientation of Frame"] = "Ausrichtung des Rahmens"
L["Set frame orientation."] = "Setzt die Rahmen Ausrichtung"
L["VERTICAL"] = "Vertikal"
L["HORIZONTAL"] = "Horizontal"

L["Orientation of Text"] = "Ausrichtung des Texts"
L["Set frame text orientation."] = "Text Ausrichtung festlegen."

L["Show Frame"] = "Rahmen Anzeige"
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = "Auswahl wenn GRID angezeigt werden soll:'Immer'. 'Gruppe', oder 'Raid'."
L["Always"] = "Immer"
L["Grouped"] = "Gruppe"
L["Raid"] = "Raid"

L["Layout Anchor"] = "Layout Ankerpunkt"
L["Sets where Grid is anchored relative to the screen."] = "Einstellung wo GRID relativ zum Bildschirm befestigt'Ankerpunkt' soll"

L["Horizontal groups"] = "Horizontale Gruppen"
L["Switch between horzontal/vertical groups."] = "Umschalten zwischen Horizontale/Vertikale Gruppen"
L["Clamped to screen"] = "Am Bildschirm fest machen"
L["Toggle whether to permit movement out of screen."] = "ein-/ausschalten um das Grid2 Fenster über den Bildschirmrand hinaus zu bewegen"
L["Frame lock"] = "Rahmen Lock"
L["Locks/unlocks the grid for movement."] = "Lock/unlock um GRID2 zu bewegen"
L["Click through the Grid Frame"] = "Durch den GRID2 Rahmen klicken"
L["Allows mouse click through the Grid Frame."] = "Erlaubt Mausklick durch den GRID2 Rahmen"

L["Display"] = "Anzeige"
L["Padding"] = "Padding"
L["Adjust frame padding."] = "Einstellung für das Rahmen Padding"
L["Spacing"] = "Abstand"
L["Adjust frame spacing."] = "Einstellung für den Rahmen Abstand"
L["Scale"] = "Größe"
L["Adjust Grid scale."] = "Einstellung der Grid2 größen Scalierung"

L["Group Anchor"] = "Gruppe Befestigungspunkt"
L["Position and Anchor"] = "Position und Befestigungspunkt"
L["Sets where groups are anchored relative to the layout frame."] = "Setzt fest wo die Gruppen befestigt werden in der Relation zum Layout Rahmen"
L["Resets the layout frame's position and anchor."] = "Resetet die Layout Rahmen Position und Befestigungspunkte"

--blink
-- L["Misc"] = ""
L["blink"] = "Blink"
L["Blink effect"] = "Blink Effekt"
L["Select the type of Blink effect used by Grid2."] = "Auswahl der Art des Blink Effekts der von GRID2 genutzt werden soll"
L["None"] = "Kein"
L["Blink"] = "Blinkt"
L["Flash"] = "Aufblinken"
L["Blink Frequency"] = "Blink Frequenz"
L["Adjust the frequency of the Blink effect."] = "Stellt die Frequenz des Blink Effekts ein"

-- debugging & maintenance
L["debugging"] = "debuggen"
L["Module debugging menu."] = "Module debugging Menü"
L["Debug"] = "Debug"
L["Reset"] = "Reset"
L["Reset and ReloadUI."] = "Reset und neu laden der UI"
L["Reset Setup"] = "Reset Setup"
L["Reset current setup and ReloadUI."] = "Reset bestehendes Setup und neu laden UI"
L["Reset Indicators"] = "Reset Indikatoren"
L["Reset indicators to defaults."] = "Reset Indikatoren auf Standart Werte"
L["Reset Locations"] = "Reset Positionen"
L["Reset locations to the default list."] = "Reset Positionen auf Standart Werte"
L["Reset to defaults."] = "Zurücksetzten auf Standart"
L["Reset Statuses"] = "Reset Status"
L["Reset statuses to defaults."] = "Reset Status auf Standart Werte"

-- L["Warning! This option will delete all settings and profiles, are you sure ?"] = ""

-- L["About"] = ""

--{{{ Layouts options
-- L["Layout"] = ""
L["Layouts"] = "Layouts"
L["layout"] = "Layout"
L["Layouts for each type of groups you're in."] = "Layout für jede Gruppe in der du bist"
L["Layout Settings"] = "Layout Einstellungen"
L["Solo Layout"] = "Solo Layout"
L["Select which layout to use for solo."] = "Auswahl des Layout's welches für Solo genutzt werden soll"
L["Party Layout"] = "Gruppen Layout"
L["Select which layout to use for party."] = "Auswahl des Layout's welches für Gruppe genutzt werden soll"
L["Raid %s Layout"] = "Raid Layout"
L["Select which layout to use for %s person raids."] = "Auswahl Layout für %s Personen Raids"
L["Battleground Layout"] = "Schlachtfeld Layout"
L["Select which layout to use for battlegrounds."] = "Auswahl welches Layout für Schlachtfelder genutzt werden soll"
L["Arena Layout"] = "Arena Layout"
L["Select which layout to use for arenas."] = "Auswahl welches Layout für Arena genutzt werden soll"
-- L["Test"] = ""
-- L["Test the layout."] = ""

--{{{ Miscelaneous
L["Name"] = "Name"
L["New"] = "Neu"
L["Order"] = "Anordnung"
L["Delete"] = "Löschen"
L["Color"] = "Farbe"
L["Color %d"] = "Farbe %d"
L["Color for %s."] = "Farbe für %s"
L["Font"] = "Schrift"
L["Adjust the font settings"] = "Anpassen der Schrift Einstellung"
-- L["Border Texture"] = ""
-- L["Adjust the border texture."] = ""
L["Border"] = "Rand"
-- L["Border Color"] = ""
L["Background"] = "Hintergrund"
-- L["Background Color"] = ""
L["Adjust border color and alpha."] = "Einstellung der Randfarbe und Alpha"
L["Adjust background color and alpha."] = "Einstellung der Hintergrundfarbe und Alpa"
L["Opacity"] = "Durchsichtigkeit"
L["Set the opacity."] = "Einstellung der Durchsichtigkeit"
L["<CharacterOnlyString>"] = "<CharacterOnlyString>"
L["Options for %s."] = "Optionen für %s-"

--{{{ Indicator management
L["New Indicator"] = "Neuer Indikator"
L["Create a new indicator."] = "Erstelle neuen Indikator"
L["Name of the new indicator"] = "Name des neuen Indikators"
-- L["Enable Test Mode"] = ""
-- L["Disable Test Mode"] = ""
-- L["Appearance"] = ""
L["Adjust the border size of the indicator."] = "Einstellung Rand Größe für den Indikator"
L["Reverse Cooldown"] = "Cooldown umdrehen"
L["Set cooldown to become darker over time instead of lighter."] = "Einstellung das der CD über Zeit dunkler anstatt Heller wird"
-- L["Cooldown"] = ""
-- L["Text Location"] = ""
-- L["Disable OmniCC"] = ""
 
L["Type"] = "Art"
L["Type of indicator"] = "Art des Indikators"
L["Type of indicator to create"] = "Art des Indikators der erstellt werden soll"

-- L["Text Length"] = ""
-- L["Maximum number of characters to show."] = ""
L["Font Size"] = "Schrift Größe"
L["Adjust the font size."] = "Anpassen der Schrift Größe"
L["Size"] = "Größe"
L["Adjust the size of the indicator."] = "Einstellung der Indikator Größe"

L["Frame Texture"] = "Rahmen Texture"
-- L["Adjust the texture of the bar."] = ""

L["Show stack"] = "Anzeige Stack"
L["Show the number of stacks."] = "Anzeige Anzahl der Stacks"
L["Show duration"] = "Anzeige Dauer"
L["Show the time remaining."] = "Anzeige verstrichene Zeit"
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

L["Border Size"] = "Rand Größe"
L["Adjust the border of each unit's frame."] = "Einstellung für den Rand des Einheiten Rahmens"
-- L["Border Background Color"] = ""
-- L["Adjust border background color and alpha."] = ""

L["Select statuses to display with the indicator"] = "Auswahl Status für Anzeige mit Indiaktor"
L["+"] = "+"
L["-"] = "-"
L["Available Statuses"] = "Verfügbarer Status"
L["Available statuses you may add"] = "Verfügbarer Status den du dazu fügen möchtest"
L["Current Statuses"] = "Derzeitiger Status"
L["Current statuses in order of priority"] = "Derzeitiger Statur in der Reihenfolge der Priorität"
L["Move the status higher in priority"] = "Status nach oben in der Prioriätenliste"
L["Move the status lower in priority"] = "Status nach unten in der Prioritätenliste"

L["indicator"] = "Indikator"

-- indicator types
L["icon"] = "icon"
L["square"] = "quadrat"
L["text"] = "text"
-- L["bar"] = ""

-- indicators
L["corner-top-left"] = "Ecke oben Links"
L["corner-top-right"] = "Ecke oben Rechts"
L["corner-bottom-right"] = "Ecke unten Rechts"
L["corner-bottom-left"] = "Ecke unten Links"
L["side-top"] = "Seite oben"
L["side-right"] = "Rechte Seite"
L["side-bottom"] = "Seite unten"
L["side-left"] = "Linke Seite"
-- L["text-up"] = ""
-- L["text-down"] = ""
-- L["icon-left"] = ""
-- L["icon-center"] = ""
-- L["icon-right"] = ""

-- locations
L["CENTER"] = "Mitte"
L["TOP"] = "Oben"
L["BOTTOM"] = "Unten"
L["LEFT"] = "Links"
L["RIGHT"] = "Rechts"
L["TOPLEFT"] = "Oben Links"
L["TOPRIGHT"] = "Oben Rechts"
L["BOTTOMLEFT"] = "Unten Links"
L["BOTTOMRIGHT"] = "Unten Rechts"

L["location"] = "Position"

L["Location"] = "Position"
L["Align my align point relative to"] = "Richte meinen Ausrichtungspunkt relativ zu"
L["Align Point"] = "Ausrichtungs Punkt"
L["Align this point on the indicator"] = "Diesen Punkt am Indikator ausrichten"
L["X Offset"] = "X Offset"
L["X - Horizontal Offset"] = "X - Horizontal Offset"
L["Y Offset"] = "Y Offset"
L["Y - Vertical Offset"] = "Y - Vertical Offset"

--{{{ Statuses
-- L["-color"] = ""
-- L["-mine"] = ""
-- L["-not-mine"] = ""
-- L["buff-"] = ""
-- L["debuff-"] = ""
-- L["color-"] = ""

L["status"] = "Status/Zustand"

L["buff"] = "Buff"
L["debuff"] = "Debuff"

-- L["New Color"] = ""
L["New Status"] = "Neuer Status"
L["Create a new status."] = "Erstelle neuen Status"

L["Threshold"] = "Schwelle"
L["Threshold at which to activate the status."] = "Schwelle ab wann der Status Aktiviert werden soll"

-- buff & debuff statuses management
L["Auras"] = "Auren"
-- L["Buffs"] = ""
-- L["Debuffs"] = ""
L["Colors"] = "Farben"
-- L["Health&Heals"] = ""
-- L["Mana&Power"] = ""
-- L["Combat"] = ""
-- L["Targeting&Distances"] = ""
-- L["Raid&Party Roles"] = ""
-- L["Miscellaneous"] = ""

L["Show if mine"] = "Anzeige ob deins"
-- L["Show if not mine"] = ""
L["Show if missing"] = "Zeige an ob fehlt"
L["Display status only if the buff is not active."] = "Anzeige Status nur wenn Buff nicht Aktiv"
L["Display status only if the buff was cast by you."] = "Zeigt den Status nur an wenn der Buff von dir vergeben wurde"
-- L["Display status only if the buff was not cast by you."] = ""
-- L["Color count"] = ""
-- L["Select how many colors the status must provide."] = ""
-- L["You can include a descriptive prefix using separators \"@#>\""] = ""
-- L["examples: Druid@Regrowth Chimaeron>Low Health"] = ""

L["Class Filter"] = "Klassen Filter"
L["Show on %s."] = "Zeigt auf %s."

L["Blink Threshold"] = "Blink Schwelle"
L["Blink Threshold at which to start blinking the status."] = "Blink Schwelle ab wann der 'Status' Aufblinken soll"

-- L["Select Type"] = ""
-- L["Buff"] = ""
-- L["Debuff"] = ""
-- L["Buffs Group"] = ""
-- L["Debuffs Group"] = ""
-- L["Buffs Group: Defensive Cooldowns"] = ""
-- L["Debuffs Group: Healing Prevented "] = ""
-- L["Debuffs Group: Healing Reduced"] = ""

-- general statuses
L["name"] = "Name"
L["mana"] = "Mana"
-- L["poweralt"] = ""
-- L["alpha"] = ""
-- L["border"] = ""
-- L["heals"] = ""
L["health"] = "Heilung"
L["charmed"] = "Verzaubert"
-- L["afk"] = ""
L["death"] = "Tot"
L["classcolor"] = "Klassenfarbe"
-- L["creaturecolor"] = ""
-- L["friendcolor"] = ""
L["feign-death"] = "Totstellen"
L["heals-incoming"] = "Eingehende Heilung"
-- L["health-current"] = ""
L["health-deficit"] = "Heilungs-defizit"
L["health-low"] = "Wenig Gesundheit"
L["lowmana"] = "Wenig Mana"
L["offline"] = "Offline"
-- L["raid-icon-player"] = ""
-- L["raid-icon-target"] = ""
L["range"] = "Reichweite"
L["ready-check"] = "Bereitschafts Check"
-- L["role"] = ""
-- L["dungeon-role"] = ""
-- L["leader"] = ""
-- L["master-looter"] = ""
-- L["raid-assistant"] = ""
L["target"] = "Ziel"
L["threat"] = "Bedrohung"
-- L["banzai"] = ""
L["vehicle"] = "Fahrzeug"
L["voice"] = "Stimme"
L["pvp"] = "PvP"
-- L["direction"] = ""
-- L["resurrection"] = ""

L["Curse"] = "Fluch"
L["Poison"] = "Gift"
L["Disease"] = "Krankheit"
L["Magic"] = "Magie"

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
L["%s Color"] = "%s Farbe"
-- L["Player color"] = ""
L["Pet color"] = "Begleiter Farbe"
L["Color Charmed Unit"] = "Farbe für verzauberte Einheit"
L["Color Units that are charmed."] = "Farbe für Einheiten die Verzaubert sind"
L["Unit Colors"] = "Einheiten Farbe"
L["Charmed unit Color"] = "Farbe für Verzauberte Einheiten"
L["Default unit Color"] = "Farbe für Standart Einheiten"
L["Default pet Color"] = "Farbe für Standart Begleiter"

L["DEATHKNIGHT"] = "Todesritter"
L["DRUID"] = "Druidin"
L["HUNTER"] = "Jägerin"
L["MAGE"] = "Magierin"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Priesterin"
L["ROGUE"] = "Schurkin"
L["SHAMAN"] = "Schamanin"
L["WARLOCK"] = "Hexenmeisterin"
L["WARRIOR"] = "Kriegerin"
L["Beast"] = "Bestie"
L["Demon"] = "Dämon"
L["Humanoid"] = "Humanoid"
L["Elemental"] = "Elementar"

-- heal-current status
L["Show dead as having Full Health"] = "Zeige Tote mit voller Gesundheit an"
-- L["Frequent Updates"] = ""

-- range status 
L["Range"] = "Reichweite"
L["%d yards"] = "%d Reichweite"
L["Range in yards beyond which the status will be lost."] = "Ausserhalb der Reichweite in Yards, mit welchem der Status aufgehoben wird"
L["Default alpha"] = "Standart Alpha"
L["Default alpha value when units are way out of range."] = "Standart Alpha Wert wenn Einheiten ausser Reichweite sind"
L["Update rate"] = "Aktualisierungsrate"
-- L["Rate at which the status gets updated"] = ""

-- ready-check status
L["Delay"] = "Verzögerung"
L["Set the delay until ready check results are cleared."] = "Setzt die Verzögerung nachdem die Bereitschafts Ergebnisse OK sind."
L["Waiting color"] = "Warten Farbe"
L["Color for Waiting."] = "Farbe für Warten"
L["Ready color"] = "Bereitschafts Farbe"
L["Color for Ready."] = "Farbe für Bereit"
L["Not Ready color"] = "Nicht Bereit Farbe"
L["Color for Not Ready."] = "Farbe für nicht Bereit"
L["AFK color"] = "AFK Farbe"
L["Color for AFK."] = "Farbe für AFK"

-- heals-incoming status 
L["Include player heals"] = "Beinhaltet Spieler Heilung"
L["Display status for the player's heals."] = "Anzeige Status für Spieler Heilung"
-- L["Minimum value"] = ""
-- L["Incoming heals below the specified value will not be shown."] = ""

--role status
L["MAIN_ASSIST"] = MAIN_ASSIST
L["MAIN_TANK"] = MAIN_TANK

--target status
L["Your Target"] = "Mein Ziel"

--threat status
L["Not Tanking"] = "Wird nicht getankt"
L["Higher threat than tank."] = "Höhere Bedrohung als Tank"
L["Insecurely Tanking"] = "Unsicheres Tanken"
L["Tanking without having highest threat."] = "Wird getankt ohne die höchste Bedrohung"
L["Securely Tanking"] = "Sicher Getankt"
L["Tanking with highest threat."] = "Wird mit höchster Bedrohung getankt"

-- voice status
L["Voice Chat"] = "Stem Spricht"

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
