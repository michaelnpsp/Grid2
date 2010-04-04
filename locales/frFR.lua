local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2", "frFR")
if not L then return end

--{{{ Actually used
L["Border"] = "Bordure"
L["Charmed"] = "Charme"
L["Default"] = "Default"
L["Drink"] = "Boisson"
L["Food"] = "Nourriture"
--L["Grid2"] = true
L["Beast"] = "Bête"
L["Demon"] = "Démon"
L["Humanoid"] = "Humanoïde"
L["Elemental"] = "Elementaire"
--}}}



--{{{ GridCore
L["Configure"] = "Configurer"
L["Configure Grid"] = "Configurer Grid"
--}}}

--{{{ GridFrame
L["Frame"] = "Cadre"
L["Options for GridFrame."] = "Options du cadre"

L["Indicators"] = "Indicateurs"
L["Health Bar"] = "Barre de vie"
L["Health Bar Color"] = "Couleur de la barre de vie"
L["Center Text"] = "Texte central"
L["Center Text 2"] = "Texte central 2"
L["Center Icon"] = "Icône central"
L["Top Left Corner"] = "Coin sup. gauche"
L["Top Right Corner"] = "Coin sup. droit"
L["Bottom Left Corner"] = "Coin bas gauche"
L["Bottom Right Corner"] = "Coin bas droit"
L["Frame Alpha"] = "Transparence du cadre"

L["Options for %s indicator."] = "Options de l'indicateur %s."
L["Statuses"] = "Statuts"
L["Toggle status display."] = "Affichage des statuts."

-- Advanced options
L["Enable %s indicator"] = "Autoriser l'indicateur %s"
L["Toggle the %s indicator."] = "Afficher l'indicateur %s."
L["Orientation of Text"] = "Orientation du texte"
L["Set frame text orientation."] = "Orientation du cadre du texte."
--}}}

--{{{ GridLayout
L["Layout"] = "Agencement"
L["Options for GridLayout."] = "Options d'agencement de la grille."


-- Display options
L["Pet color"] = "Couleur du familier"
L["Set the color of pet units."] = "Définis la couleur des familiers."
L["Pet coloring"] = "Coloration du familier"
L["Set the coloring strategy of pet units."] = "Définis la stratégie de coloration des familiers."
L["By Owner Class"] = "Par classe"
L["By Creature Type"] = "Par type de créature"
L["Using Fallback color"] = "Utiliser la couleur secondaire"
L["Colors"] = "Couleurs"
L["Color options for class and pets."] = "Options de couleurs pour les classes et les familiers."
L["Fallback colors"] = "Couleurs secondaires"
L["Color of unknown units or pets."] = "Couleur des unités ou familiers inconnues."
L["Unknown Unit"] = "Unité inconnue"
L["The color of unknown units."] = "La couleur des unités inconnues."
L["Unknown Pet"] = "Familier inconnu"
L["The color of unknown pets."] = "La couleur des  inconnuess inconnus."
L["Class colors"] = "Couleurs des classes"
L["Color of player unit classes."] = "Couleur."
L["Creature type colors"] = "Couleurs des types de créatures"
L["Color of pet unit creature types."] = "Couleurs des  inconnues par types de créature."
L["Color for %s."] = "Couleur pour %s."

-- Advanced options
L["Advanced"] = "Avancé"
L["Advanced options."] = "Options Avancées."
--}}}

--{{{ GridLayoutLayouts
-- ToDo: move into options
L["None"] = "Aucun"
L["Solo"] = "Seul"
L["Solo w/Pet"] = "Seul avec familier"
L["By Group 5"] = "Groupe de 5"
L["By Group 5 w/Pets"] = "Groupe de 5 avec familier"
L["By Group 40"] = "Groupe de 40"
L["By Group 25"] = "Groupe de 25"
L["By Group 25 w/Pets"] = "Groupe de 25 avec familier"
L["By Group 20"] = "Groupe de 20"
L["By Group 15"] = "Groupe de 15"
L["By Group 15 w/Pets"] = "Groupe de 15 avec familier"
L["By Group 10"] = "Groupe de 10"
L["By Group 10 w/Pets"] = "Groupe de 10 avec familier"
L["By Group 4 x 10 Wide"] = "Par groupe de 4 x 10 Large"
L["By Class 25"] = "Par classe 25"
L["By Class 1 x 25 Wide"] = "Par classe 1 x 25 Large"
L["By Class 2 x 15 Wide"] = "Par classe 2 x 15 Large"
L["By Role 25"] = "Par Rôle 25"
L["By Class"] = "Par Classe"
L["By Class w/Pets"] = "Par Classe avec familiers"
L["Onyxia"] = "Onyxia"
L["By Group 25 w/tanks"] = "Groupe de 25 avec tanks"
--}}}

--{{{ GridRange
-- used for getting spell range from tooltip
L["(%d+) yd range"] = "portée de (%d+) m"
--}}}

--{{{ GridStatus
L["Status"] = "Statut"
L["Statuses"] = "Statuts"

-- module prototype
L["Status: %s"] = "Statut : %s"
L["Color"] = "Couleur"
L["Color for %s"] = "Couleur pour %s"
L["Priority"] = "Priorité"
L["Priority for %s"] = "Priorité pour %s"
L["Range filter"] = "Filtre de distance"
L["Range filter for %s"] = "Filtre de distance pour %s"
L["Enable"] = "Activer"
L["Enable %s"] = "Activer %s"
--}}}

--{{{ GridStatusAggro
L["Aggro"] = "Aggro"
L["Aggro alert"] = "Alerte d'Aggro"
--}}}

--{{{ GridStatusAuras
L["Auras"] = "Auras"
L["Debuff type: %s"] = "Type de débuff : %s"
L["Poison"] = "Poison"
L["Disease"] = "Maladie"
L["Magic"] = "Magie"
L["Curse"] = "Malédiction"
L["Ghost"] = "Fantôme"
L["Add new Buff"] = "Ajouter nouveau buff"
L["Adds a new buff to the status module"] = "Ajouter nouveau buff au module de statut"
L["<buff name>"] = "<nom du buff>"
L["Add new Debuff"] = "Ajouter nouveau débuff"
L["Adds a new debuff to the status module"] = "Ajouter nouveau débuff au module de statut"
L["<debuff name>"] = "<nom du débuff>"
L["Delete (De)buff"] = "Effacer (dé)buff"
L["Deletes an existing debuff from the status module"] = "Efface un débuff existant du module de statut"
L["Remove %s from the menu"] = "Retirer %s du menu"
L["Debuff: %s"] = "Débuff : %s"
L["Buff: %s"] = "Buff : %s"
L["Class Filter"] = "Filtre de classe"
L["Show status for the selected classes."] = "Montrer le statut des classes selectionnées"
L["Show on %s."] = "Montrer sur %s"
L["Show if missing"] = "Montrer si manquant"
L["Display status only if the buff is not active."] = "Montrer le statut uniquement si le buff est inactif."
L["Filter Abolished units"] = "Filtrer les unités abolies"
L["Skip units that have an active Abolish buff."] = "Passer les unités qui ont un buff abolis actif."
--}}}

--{{{ GridStatusName
L["Unit Name"] = "Nom de l'unité"
L["Color by class"] = "Couleur de la classe"
--}}}

--{{{ GridStatusMana
L["Mana"] = "Mana"
L["Low Mana"] = "Mana bas"
L["Mana threshold"] = "Seuil de mana"
L["Set the percentage for the low mana warning."] = "Définir le pourcentage d'avertissement de mana bas."
L["Low Mana warning"] = "Avertissement de Mana bas"
--}}}

--{{{ GridStatusHeals
L["Heals"] = "Soins"
L["Incoming heals"] = "Soins entrants"
L["Ignore Self"] = "S'ignorer"
L["Ignore heals cast by you."] = "Ignorer les soins incantés par vous."
L["(.+) begins to cast (.+)."] = "(.+) commence à incanter (.+)."
L["(.+) gains (.+) Mana from (.+)'s Life Tap."] = "(.+) gagne (.+) Mana de (.+)'s connexion."
L["^Corpse of (.+)$"] = "^Corps de (.+)$"
--}}}

--{{{ GridStatusHealth
L["Low HP"] = "Vie basse"
L["DEAD"] = "MORT"
L["GHOST"] = "FANTOME"
L["FD"] = "FD"
L["Offline"] = "Déco."
L["Unit health"] = "Vie de l'unité"
L["Health deficit"] = "Déficit de vie"
L["Low HP warning"] = "Alerte vie basse"
L["Feign Death warning"] = "Alerte Feign Death"
L["Death warning"] = "Alerte mort"
L["Offline warning"] = "Alerte Déco."
L["Health"] = "Vie"
L["Show dead as full health"] = "Montrer les morts en vie pleine"
L["Treat dead units as being full health."] = "Traiter les unités mortes comme si elles étaient full vie."
L["Use class color"] = "Utiliser la couleur de classe"
L["Color health based on class."] = "Couleur de vie basée sur la classe."
L["Health threshold"] = "Seuil de Vie"
L["Only show deficit above % damage."] = "Montre uniquement le déficit supérieur à ce % de dommages."
L["Color deficit based on class."] = "Couleur du déficit basée sur la classe."
L["Low HP threshold"] = "Seuil de vie basse"
L["Set the HP % for the low HP warning."] = "Définis le % de vie pour l'alerte de vie basse."
--}}}

--{{{ GridStatusPvp
L["PvP"] = "JCJ"
L["FFA"] = "FFA"
--}}}

--{{{ GridStatusRange
L["Out of Range"] = "Hors de portée"
L["OOR"] = "HDP"
--}}}

--{{{ GridStatusReadyCheck
L["?"] = "?"
L["R"] = "V"
L["X"] = "X"
L["AFK"] = "ABS"
--}}}

--{{{ GridStatusTarget
L["target"] = "Cible"
--}}}

--{{{ GridStatusVehicle
L["vehicle"] = "Véhicule"
--}}}

--{{{ GridStatusVoiceComm
L["talking"] = "Parle"
--}}}
