local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "deDE")
if not L then return end

--{{{ Actually used
L["Border"] = "Rand"
L["Charmed"] = "Verzaubert"
L["Drink"] = "Trinken"
L["Food"] = "Essen"
-- L["Grid2"] = "Grid2"
--}}}



--{{{ GridCore
L["Configure"] = "Konfiguration"
L["Configure Grid"] = "Konfiguration Grid"
--}}}

--{{{ GridFrame
L["Frame"] = "Rahmen"
L["Options for GridFrame."] = "Optionen für Grid Rahmen"

L["Indicators"] = "Indikatoren"
L["Health Bar"] = "Gesundheitsleiste"
L["Health Bar Color"] = "Gesundheitsleisten Farbe"
L["Center Text"] = "Center Text"
L["Center Text 2"] = "Center Text 2"
L["Center Icon"] = "Center Icon"
L["Top Left Corner"] = "Ecke oben Links"
L["Top Right Corner"] = "Ecke oben Rechts"
L["Bottom Left Corner"] = "Ecke unten Links"
L["Bottom Right Corner"] = "Ecke unten Rechts"
L["Frame Alpha"] = "Frame/Rahmen Alpha"

L["Options for %s indicator."] = "Optionen für %s Indikator"
L["Statuses"] = "Status/Zustand"
L["Toggle status display."] = "einschalten/ausschalten Status Display"

-- Advanced options
L["Enable %s indicator"] = "Aktiviert %s indikator"
L["Toggle the %s indicator."] = "einschalten/ausschalten %s Indikator."
L["Orientation of Text"] = "Ausrichtung des Textes"
L["Set frame text orientation."] = "Ausrichtung vom Rahmen Text"
--}}}

--{{{ GridLayout
L["Layout"] = "Layout"
L["Options for GridLayout."] = "Optionen für GridLayout"

-- Layout options
L["Raid Layout"] = "Raid Layout"
L["Select which raid layout to use."] = "Auswahl welches Raid Layout genutzt werden soll"
L["Show Party in Raid"] = "Zeige deine Gruppe im Raid"
L["Show party/self as an extra group."] = "Zeige 5er Gruppe/selbst als eine extra Gruppe"
L["Show Pets for Party"] = "Zeige die Begleiter in einer 5er Gruppe"
L["Show the pets for the party below the party itself."] = " Zeige Begleiter der 5er Gruppe unter dem Gruppen Fenster"

-- Display options
L["Pet color"] = "Begleiter Farbe"
L["Set the color of pet units."] = "Setze eine Farbe für die Begleiter Einheiten"
L["Pet coloring"] = "Begleiter Farbanpassung"
L["Set the coloring strategy of pet units."] = "Legt fest, wie die Begleiter eingefÃ¤rbt werden."
L["By Owner Class"] = "Nach Besitzer Klasse"
L["By Creature Type"] = "Nach Kreatur Art"
L["Using Fallback color"] = "Benutze Rücksicherungs Farbe"
L["Beast"] = "Bestie"
L["Demon"] = "Dämon"
L["Humanoid"] = "Humanoid"
L["Elemental"] = "Elementar"
L["Colors"] = "Farben"
L["Color options for class and pets."] = "Farb Optionen für Klassen und Begleiter"
L["Fallback colors"] = "Rücksicherungs Farben"
L["Color of unknown units or pets."] = "Farbe für unbekannte Einheiten oder Begleiter"
L["Unknown Unit"] = "Unbekannte Einheit"
L["The color of unknown units."] = "Die Farbe für unbekannte Einheiten"
L["Unknown Pet"] = "Unbekannte Begleiter"
L["The color of unknown pets."] = "Die Farbe für unbekannte Begleiter"
L["Class colors"] = "Klassen Farben"
L["Color of player unit classes."] = "Farbe für Spieler Einheit Klassen"
L["Creature type colors"] = "Kreaturen Typ Farbe"
L["Color of pet unit creature types."] = "Farbe der Begleiter Einheiten und Art"
L["Color for %s."] = "Farbe für %s"

-- Advanced options
L["Advanced"] = "Erweitert"
L["Advanced options."] = "Erweiterte Optionen"
--}}}

--{{{ GridLayoutLayouts
-- ToDo: move into options
L["None"] = "Keine"
L["Solo"] = "Allein"
L["Solo w/Pet"] = "Allein mit Begleiter"
L["By Group 5"] = "5er Gruppe"
L["By Group 5 w/Pets"] = "5er Gruppe mit Begleiter"
L["By Group 40"] = "40er Gruppe"
L["By Group 25"] = "25er Gruppe"
L["By Group 25 w/Pets"] = "25er Gruppe mit Begleiter"
L["By Group 20"] = "20er Gruppe"
L["By Group 15"] = "15er Gruppe"
L["By Group 15 w/Pets"] = "15er Gruppe mit Begleiter"
L["By Group 10"] = "10er Gruppe"
L["By Group 10 w/Pets"] = "10er Gruppe mit Begleiter"
L["By Group 4 x 10 Wide"] = "Gruppe 4 x 10 Breit"
L["By Class 25"] = "25er nach Klasse"
L["By Class 1 x 25 Wide"] = "Nach Klasse 1 x 25 Breit"
L["By Class 2 x 15 Wide"] = "Nach Klasse 2x 15 Breit"
L["By Role 25"] = "25er nach Rolle"
L["By Class"] = "Nach Klasse"
L["By Class w/Pets"] = "Nach Klasse mit Begleiter"
L["Onyxia"] = "Onyxia"
L["By Group 25 w/tanks"] = "25er Gruppe mit Tanks"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "(%d+) yd Reichweite"
--}}}

--{{{ GridStatus
L["Status"] = "Status/Zustand"
L["Statuses"] = "Statuse/Zustände"

-- module prototype
L["Status: %s"] = "Status %s"
L["Color"] = "Farbe"
L["Color for %s"] = "Farbe für %s"
L["Priority"] = "Priorität"
L["Priority for %s"] = "Priorität für %s"
L["Range filter"] = "Reichweiten Filter"
L["Range filter for %s"] = "Reichweiten Filter für %s"
L["Enable"] = "Aktiviert"
L["Enable %s"] = "Aktiviert %s"
--}}}

--{{{ GridStatusAggro
L["Aggro"] = "Bedrohung"
L["Aggro alert"] = "Bedrohungs Alarm"
--}}}

--{{{ GridStatusAuras
L["Auras"] = "Auren"
L["Debuff type: %s"] = "Debuff Art %s"
L["Poison"] = "Gift"
L["Disease"] = "Krankheit"
L["Magic"] = "Magie"
L["Curse"] = "Fluch"
L["Ghost"] = "Geist"
L["Add new Buff"] = "Neuen Buff zufügen"
L["Adds a new buff to the status module"] = "Fügt einen neuen Buff zum Status Module"
L["<buff name>"] = "<Buff Name>"
L["Add new Debuff"] = "Fügt einen neuen Debuff hinzu"
L["Adds a new debuff to the status module"] = "Fügt einen neuen Debuff zum Status Modul hinzu"
L["<debuff name>"] = "Debuff Name"
L["Delete (De)buff"] = "Lösche (De)Buff"
L["Deletes an existing debuff from the status module"] = "Löscht einen existierenden Debuff aus dem Status Modul"
L["Remove %s from the menu"] = "Entfernt %s aus dem Menue"
L["Debuff: %s"] = "Debuff: %s"
L["Buff: %s"] = "Buff: %s"
L["Class Filter"] = "Klassen Filter"
L["Show status for the selected classes."] = "Zeigt den Status der ausgewählten Klasse"
L["Show on %s."] = "Zeigt auf %s."
L["Show if missing"] = "Zeigt an ob fehlt"
L["Display status only if the buff is not active."] = "Anzeige Status nur wenn Buff nicht Aktiv"
L["Filter Abolished units"] = "Filter aufhebbarer Einheiten"
L["Skip units that have an active Abolish buff."] = "Überspringe Einheiten mit aktiven aufhebbarem Buff"
--}}}

--{{{ GridStatusName
L["Unit Name"] = "Einheiten Name"
L["Color by class"] = "Farbe bei Klasse"
--}}}

--{{{ GridStatusMana
L["Mana"] = "Mana"
L["Low Mana"] = "Wenig Mana"
L["Mana threshold"] = "Mana Grenzwert"
L["Set the percentage for the low mana warning."] = "Setze die Prozente für die wenig Mana Warnung"
L["Low Mana warning"] = "Wenig Mana Warnung"
--}}}

--{{{ GridStatusHeals
L["Heals"] = "Heilung"
L["Incoming heals"] = "Eingehende Heilung"
L["Ignore Self"] = "Ignoriere Selbst"
L["Ignore heals cast by you."] = "Ignoriere eigene gewirkte Heilungen"
L["(.+) begins to cast (.+)."] = "(.+) Beginnt zu casten (.+)."
L["(.+) gains (.+) Mana from (.+)'s Life Tap."] = "(.+) gewinnt (.+) Mana von (.+)'s Life Tap."
L["^Corpse of (.+)$"] = "^Körper von .+)$"
--}}}

--{{{ GridStatusHealth
L["Low HP"] = "Wenig HP"
L["DEAD"] = "Tot"
L["GHOST"] = "Geist"
L["FD"] = "Totstellen"
L["Offline"] = "Offline"
L["Unit health"] = "Einheit Heilung"
L["Health deficit"] = "Heilungs defizit"
L["Low HP warning"] = "Wenig HP Warnung"
L["Feign Death warning"] = "Totstellen Warnung"
L["Death warning"] = "Todes Warnung"
L["Offline warning"] = "Offline Warnung"
L["Health"] = "Gesundheit"
L["Show dead as full health"] = "Zeige Tote mit voller Gesundheit"
L["Treat dead units as being full health."] = "Behandle Tote Einheiten als hätten sie volle Gesundheit."
L["Use class color"] = "Benutze Klassen Farbe"
L["Color health based on class."] = "Gesundheitsanzeige Farbe basierend auf Klasse"
L["Health threshold"] = "Gesundheits Grenzwert"
L["Only show deficit above % damage."] = "Zeige nur Defizit über % Schaden"
L["Color deficit based on class."] = "Farben defizit basierend auf Klasse"
L["Low HP threshold"] = "Wenig Gesundheit Grenzwert"
L["Set the HP % for the low HP warning."] = "Setzt die Gesundheit % für die wenig Gesundheit Warnung"
--}}}

--{{{ GridStatusPvp
L["PvP"] = "PvP"
L["FFA"] = "FFA"
--}}}

--{{{ GridStatusRange
L["Out of Range"] = "Ausserhalb der Reichweite"
L["OOR"] = "OOR"
--}}}

--{{{ GridStatusReadyCheck
L["?"] = "?"
L["R"] = "R"
L["X"] = "X"
L["AFK"] = "AFK"
--}}}

--{{{ GridStatusTarget
L["Target"] = "Ziel"
L["Your Target"] = "Mein Ziel"
--}}}

--{{{ GridStatusVehicle
L["vehicle"] = "Fahrzeug"
--}}}

--{{{ GridStatusVoiceComm
L["Voice Chat"] = "Voice Chat"
L["Talking"] = "Spricht"
--}}}

