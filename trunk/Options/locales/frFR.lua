local L =  LibStub:GetLibrary("AceLocale-3.0"):NewLocale("Grid2Options", "frFR")
if not L then return end

--{{{ General options
L["GRID2_DESC"] = "Bienvenue sur Grid2"

L["General Settings"] = "Paramètres généraux"

-- L["statuses"] = ""
-- L["indicators"] = ""

-- L["Frames"] = ""
L["frame"] = "Cadre"

L["Invert Bar Color"] = "Inverser les couleurs de barre"
L["Swap foreground/background colors on bars."] = "Intervertir les couleurs avant/arrière des barres."

-- L["Background Color"] = ""
-- L["Sets the background color of each unit frame"] = ""

L["Mouseover Highlight"] = "Activer la surbrillance au survol"
L["Toggle mouseover highlight."] = "Active ou non la surbrillance lors du passage de la souris."

L["Show Tooltip"] = "Afficher tooltip"
L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."] = "Afficher le tooltip de l'unité. Choisir 'Toujours', 'Jamais', ou 'OOC'."
L["Always"] = "Toujours"
L["Never"] = "Jamais"
L["OOC"] = "OOC"

-- L["Background Texture"] = ""
-- L["Select the frame background texture."] = ""

-- L["Inner Border Size"] = ""
-- L["Sets the size of the inner border of each unit frame"] = ""

-- L["Inner Border Color"] = ""
-- L["Sets the color of the inner border of each unit frame"] = ""

L["Frame Width"] = "Largeur du cadre"
L["Adjust the width of each unit's frame."] = "Ajuster la largeur de chaque cadre d'unité."

L["Frame Height"] = "Hauteur du cadre"
L["Adjust the height of each unit's frame."] = "Ajuster la hauteur de chaque cadre d'unité."

L["Orientation of Frame"] = "Orientation du cadre"
L["Set frame orientation."] = "Sélectionner l'orientation du cadre."
L["VERTICAL"] = "VERTICAL"
L["HORIZONTAL"] = "HORIZONTAL"

L["Orientation of Text"] = "Orientation du texte"
L["Set frame text orientation."] = "Détermine l'orientation du texte de la grille."

L["Show Frame"] = "Afficher Cadre"
L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."] = "Configure la visibilité de Grid : Choisir 'Toujours', 'Groupé', ou 'Raid'."
L["Always"] = "Toujours"
L["Grouped"] = "Groupé"
L["Raid"] = "Raid"

L["Layout Anchor"] = "Ancre de la grille"
L["Sets where Grid is anchored relative to the screen."] = "Configure ou Grid sera ancré sur l'écran"

L["Horizontal groups"] = "Groupes Horizontaux"
L["Switch between horzontal/vertical groups."] = "Inverser Groupes Horizontaux/Verticaux."
L["Clamped to screen"] = "Restreindre à l'écran"
L["Toggle whether to permit movement out of screen."] = "Cocher pour interdire les mouvements hors de l'écran."
L["Frame lock"] = "Verrouiller le cadre"
L["Locks/unlocks the grid for movement."] = "Verrouiller/Deverrouiller la grille."
L["Click through the Grid Frame"] = "Cliquer au travers de la grille"
L["Allows mouse click through the Grid Frame."] = "Autoriser le clic au travers de la grille."

L["Display"] = "Affichage"
L["Padding"] = "Remplissage"
L["Adjust frame padding."] = "Ajuste le remplissage du cadre."
L["Spacing"] = "Espacement"
L["Adjust frame spacing."] = "Ajuster l'espacement des cadres."
L["Scale"] = "Agrandissement"
L["Adjust Grid scale."] = "Ajuster l'agrandissement."

L["Group Anchor"] = "Ancre des groupes"
L["Position and Anchor"] = "Position et Ancrage"
L["Sets where groups are anchored relative to the layout frame."] = "Défini l'ancrage des groupes par rapport au cadre de la grille."
L["Resets the layout frame's position and anchor."] = "Réinitialise la position et l'ancrage du cadre de la grille."

--blink
-- L["Misc"] = ""
L["blink"] = "Clignotement"
L["Blink effect"] = "Effet de clignotement"
L["Select the type of Blink effect used by Grid2."] = "Sélectionner le type de clignotement "
L["None"] = "Aucun"
L["Blink"] = "Clignotement"
L["Flash"] = "Flash"
L["Blink Frequency"] = "Fréquence de clignotement"
L["Adjust the frequency of the Blink effect."] = "Ajuste la fréquence de clignotement de l'effet de clignotement."

-- debugging & maintenance
L["debugging"] = "debugging"
L["Module debugging menu."] = "Menu du module de débugging"
L["Debug"] = "Debug"
L["Reset"] = "Réinitialiser"
L["Reset and ReloadUI."] = "RAZ et reloadUI."
L["Reset Setup"] = "RAZ Setup"
L["Reset current setup and ReloadUI."] = "RAZ paramètres et ReloadUI."
L["Reset Indicators"] = "RAZ des indicateurs"
L["Reset indicators to defaults."] = "Indicateurs par défaut."
L["Reset Locations"] = "RAZ des emplacements"
L["Reset locations to the default list."] = "Emplacements par défaut."
L["Reset to defaults."] = "RAZ"
L["Reset Statuses"] = "RAZ des Statuts"
L["Reset statuses to defaults."] = "Statuts par défaut."

-- L["Warning! This option will delete all settings and profiles, are you sure ?"] = ""

-- L["About"] = ""

--{{{ Layouts options
L["Layout"] = "Agencement"
L["Layouts"] = "Agencements"
L["layout"] = "Grille"
L["Layouts for each type of groups you're in."] = "Agencements pour chaque type de groupe dans lequel vous êtes."
L["Layout Settings"] = "Paramètres d'agencement"
L["Solo Layout"] = "Agencement Solo"
L["Select which layout to use for solo."] = "Choisir l'agencement à utiliser en Solo."
L["Party Layout"] = "Agencement de groupe"
L["Select which layout to use for party."] = "Choisir l'agencement à utiliser en Groupe."
L["Raid %s Layout"] = "Agencement de Raid %s"
L["Select which layout to use for %s person raids."] = "Choisir l'agencement à utiliser en Raid %s."
L["Battleground Layout"] = "Agencement de Champ de Bataille"
L["Select which layout to use for battlegrounds."] = "Choisir l'agencement à utiliser en Champ de Bataille."
L["Arena Layout"] = "Agencement d'Arène"
L["Select which layout to use for arenas."] = "Choisir l'agencement à utiliser en Arène."
-- L["Test"] = ""
-- L["Test the layout."] = ""

--{{{ Miscelaneous
L["Name"] = "Nom"
L["New"] = "Nouveau"
L["Order"] = "Ordre"
L["Delete"] = "Effacer"
L["Color"] = "Couleur"
L["Color %d"] = "Couleur %d"
L["Color for %s."] = "Couleur pour %s."
L["Font"] = "Style"
L["Adjust the font settings"] = "Ajuste les caractèristiques de styles."
L["Border"] = "Bordure"
L["Background"] = "Fond"
L["Adjust border color and alpha."] = "Ajuster la couleur de la bordure et de l'Alpha."
L["Adjust background color and alpha."] = "Ajuster la couleur du fond et de l'Alpha."
L["Opacity"] = "Opacité"
L["Set the opacity."] = "Régle l'opacité"
L["<CharacterOnlyString>"] = "<CharacterOnlyString>"
L["Options for %s."] = "Options de %s."

--{{{ Indicator management
L["New Indicator"] = "Nouvel Indicateur"
L["Create a new indicator."] = "Créer un nouvel indicateur."
L["Name of the new indicator"] = "Nom du nouvel indicateur"
-- L["Enable Test Mode"] = ""
-- L["Disable Test Mode"] = ""
-- L["Appearance"] = ""
L["Adjust the border size of the indicator."] = "Ajuster la taille de la bordure de l'indicateur."
L["Reverse Cooldown"] = "Compte à Rebours inversé"
L["Set cooldown to become darker over time instead of lighter."] = "Paramètre le CD pour devenir plus sombre suivant le temps écoulé au lieu de plus clair."
-- L["Cooldown"] = ""
-- L["Text Location"] = ""
-- L["Disable OmniCC"] = ""
 
L["Type"] = "Type"
L["Type of indicator"] = "Type d'indicateur"
L["Type of indicator to create"] = "Type d'indicateur à créer"

-- L["Text Length"] = ""
-- L["Maximum number of characters to show."] = ""
L["Font Size"] = "Taille des caractères."
L["Adjust the font size."] = "Ajuste la taille des caractères."
L["Size"] = "Taille"
L["Adjust the size of the indicator."] = "Ajuste la taille des indicateur."

L["Frame Texture"] = "Texture du cadre"
-- L["Adjust the texture of the bar."] = ""

L["Show stack"] = "Montrer stack"
L["Show the number of stacks."] = "Montrer le nombre de stacks."
L["Show duration"] = "Montrer durée"
L["Show the time remaining."] = "Montrer le temps restant."
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

L["Border Size"] = "Taille de la bordure"
L["Adjust the border of each unit's frame."] = "Ajuster la bordure de chaque cadre d'unité."
-- L["Border Background Color"] = ""
-- L["Adjust border background color and alpha."] = ""

L["Select statuses to display with the indicator"] = "Sélectionner les statuts à afficher avec l'indicateur"
L["+"] = "+"
L["-"] = "-"
L["Available Statuses"] = "Statuts disponibles"
L["Available statuses you may add"] = "Statuts disponibles que vous pouvez ajouter"
L["Current Statuses"] = "Statuts actuels"
L["Current statuses in order of priority"] = "Statuts actuels par ordre de priorité"
L["Move the status higher in priority"] = "Bouger le statut en priorité plus haute"
L["Move the status lower in priority"] = "Bouger le statut en priorité plus basse"

L["indicator"] = "Indicateur"

-- indicator types
L["icon"] = "icône"
L["square"] = "carré"
L["text"] = "texte"
-- L["bar"] = ""

-- indicators
L["corner-top-left"] = "coin-haut-gauche"
L["corner-top-right"] = "coin-haut-droit"
L["corner-bottom-right"] = "coin-bas-droit"
L["corner-bottom-left"] = "coin-bas-gauche"
L["side-top"] = "côté-haut"
L["side-right"] = "côté-droit"
L["side-bottom"] = "côté-bas"
L["side-left"] = "côté-gauche"
-- L["text-up"] = ""
-- L["text-down"] = ""
-- L["icon-left"] = ""
-- L["icon-center"] = ""
-- L["icon-right"] = ""

-- locations
L["CENTER"] = "CENTRE"
L["TOP"] = "HAUT"
L["BOTTOM"] = "BAS"
L["LEFT"] = "GAUCHE"
L["RIGHT"] = "DROITE"
L["TOPLEFT"] = "HAUT GAUCHE"
L["TOPRIGHT"] = "HAUT DROIT"
L["BOTTOMLEFT"] = "BAS GAUCHE"
L["BOTTOMRIGHT"] = "BAS DROIT"

L["location"] = "Position"

L["Location"] = "Emplacement"
L["Align my align point relative to"] = "Aligner le point d'alignement par rapport à "
L["Align Point"] = "Point d'alignement"
L["Align this point on the indicator"] = "Aligner ce point sur l'indicateur"
L["X Offset"] = "Décalage en X"
L["X - Horizontal Offset"] = "X - Décalage horizontal"
L["Y Offset"] = "Décalage en Y"
L["Y - Vertical Offset"] = "Y - Décalage vertical"

--{{{ Statuses
-- L["-color"] = ""
-- L["-mine"] = ""
-- L["-not-mine"] = ""
-- L["buff-"] = ""
-- L["debuff-"] = ""
-- L["color-"] = ""

L["status"] = "Statut"

L["buff"] = "Buff"
L["debuff"] = "Débuff"

-- L["New Color"] = ""
L["New Status"] = "Nouveau Statut"
L["Create a new status."] = "Créer un nouveau statut."

L["Threshold"] = "Seuil"
L["Threshold at which to activate the status."] = "Seuil d'activation du statut."

-- buff & debuff statuses management
L["Auras"] = "Auras"
-- L["Buffs"] = ""
-- L["Debuffs"] = ""
L["Colors"] = "Couleurs"
-- L["Health&Heals"] = ""
-- L["Mana&Power"] = ""
-- L["Combat"] = ""
-- L["Targeting&Distances"] = ""
-- L["Raid&Party Roles"] = ""
-- L["Miscellaneous"] = ""

L["Show if mine"] = "Montrer si le mien"
-- L["Show if not mine"] = ""
L["Show if missing"] = "Montrer si manquant"
L["Display status only if the buff is not active."] = "Afficher le statut uniquement si le buff n'est pas actif."
L["Display status only if the buff was cast by you."] = "Afficher le statut uniquement si le buff est le votre."
-- L["Display status only if the buff was not cast by you."] = ""
-- L["Color count"] = ""
-- L["Select how many colors the status must provide."] = ""
-- L["You can include a descriptive prefix using separators \"@#>\""] = ""
-- L["examples: Druid@Regrowth Chimaeron>Low Health"] = ""

L["Class Filter"] = "Filtre de classe"
L["Show on %s."] = "Montrer sur %s."

L["Blink Threshold"] = "Seuil de clignotement"
L["Blink Threshold at which to start blinking the status."] = "Seuil pour lequel le clignotement du statut commencera."

-- L["Select Type"] = ""
-- L["Buff"] = ""
-- L["Debuff"] = ""
-- L["Buffs Group"] = ""
-- L["Debuffs Group"] = ""
-- L["Buffs Group: Defensive Cooldowns"] = ""
-- L["Debuffs Group: Healing Prevented "] = ""
-- L["Debuffs Group: Healing Reduced"] = ""

-- general statuses
L["name"] = "nom"
L["mana"] = "mana"
-- L["poweralt"] = ""
-- L["alpha"] = ""
-- L["border"] = ""
-- L["heals"] = ""
L["health"] = "vie"
L["charmed"] = "charmé"
-- L["afk"] = ""
L["death"] = "mort"
L["classcolor"] = "couleur-de-classe"
-- L["creaturecolor"] = ""
-- L["friendcolor"] = ""
L["feign-death"] = "feign-death"
L["heals-incoming"] = "soins-entrant"
-- L["health-current"] = ""
L["health-deficit"] = "déficit-de-vie"
L["health-low"] = "vie-basse"
L["lowmana"] = "mana-basse"
L["offline"] = "déco"
-- L["raid-icon-player"] = ""
-- L["raid-icon-target"] = ""
L["range"] = "distance"
L["ready-check"] = "Appel"
-- L["role"] = ""
-- L["dungeon-role"] = ""
-- L["leader"] = ""
-- L["master-looter"] = ""
-- L["raid-assistant"] = ""
L["target"] = "cible"
L["threat"] = "menace"
-- L["banzai"] = ""
L["vehicle"] = "véhicule"
L["voice"] = "voix"
L["pvp"] = "pvp"
-- L["direction"] = ""
-- L["resurrection"] = ""

L["Curse"] = "Malédiction"
L["Poison"] = "Poison"
L["Disease"] = "Maladie"
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
L["%s Color"] = "Couleur de %s"
-- L["Player color"] = ""
L["Pet color"] = "Couleur du familier"
L["Color Charmed Unit"] = "Couleur des Unités Charmées"
L["Color Units that are charmed."] = "Colore des Unités Charmées"
L["Unit Colors"] = "Couleur des unités"
L["Charmed unit Color"] = "Couleur des unités Charmées"
L["Default unit Color"] = "Couleur par défaut des unités"
L["Default pet Color"] = "Couleur par défaut des pets"

L["DEATHKNIGHT"] = "Chevalier de la mort"
L["DRUID"] = "Druide"
L["HUNTER"] = "Hunt"
L["MAGE"] = "Mage"
L["PALADIN"] = "Paladin"
L["PRIEST"] = "Prêtre"
L["ROGUE"] = "Voleur"
L["SHAMAN"] = "Shaman"
L["WARLOCK"] = "Démoniste"
L["WARRIOR"] = "Guerrier"
L["Beast"] = "Bête"
L["Demon"] = "Démon"
L["Humanoid"] = "Humanoide"
L["Elemental"] = "Elémentaire"

-- heal-current status
L["Show dead as having Full Health"] = "Montrer les morts comme par étant full vie"
-- L["Frequent Updates"] = ""

-- range status 
L["Range"] = "Distance"
L["%d yards"] = "%d mètres"
L["Range in yards beyond which the status will be lost."] = "Distance en mètres au-dessus de laquelle le statut sera perdu."
L["Default alpha"] = "Alpha par défaut"
L["Default alpha value when units are way out of range."] = "Valeur par défaut de l'alpha lorsque les unités sont hors de portée"
L["Update rate"] = "Taux de mise à jour"
-- L["Rate at which the status gets updated"] = ""

-- ready-check status
L["Delay"] = "Délai"
L["Set the delay until ready check results are cleared."] = "Timer avant disparition des résultats de l'appel"
L["Waiting color"] = "Couleur d'attente"
L["Color for Waiting."] = "Couleur pour l'attente"
L["Ready color"] = "Couleur ok"
L["Color for Ready."] = "Couleur pour prêt"
L["Not Ready color"] = "Couleur nok"
L["Color for Not Ready."] = "Couleur pour non prêt"
L["AFK color"] = "Couleur d'AFK"
L["Color for AFK."] = "Couleur pour AFK"

-- heals-incoming status 
L["Include player heals"] = "Inclure les soins du joueur"
L["Display status for the player's heals."] = "Afficher le statut des soins du joueur"
-- L["Minimum value"] = ""
-- L["Incoming heals below the specified value will not be shown."] = ""

--role status
L["MAIN_ASSIST"] = MAIN_ASSIST
L["MAIN_TANK"] = MAIN_TANK

--target status
L["Your Target"] = "Votre Cible"

--threat status
L["Not Tanking"] = "Ne tank pas"
L["Higher threat than tank."] = "Menace plus élevée que le Tank"
L["Insecurely Tanking"] = "Tanking dangeureux"
L["Tanking without having highest threat."] = "Tank sans avoir la menace la plus élevée."
L["Securely Tanking"] = "Tanking sûr"
L["Tanking with highest threat."] = "Tank avec la menace la plus élevée."

-- voice status
L["Voice Chat"] = "Chat Vocal"

-- raid debuffs
-- L["General"] = ""
L["Advanced"] = "Avancé"
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
