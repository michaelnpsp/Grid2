--Bugs:
--Fix health bar ordering / layering

--Standardize the way buff and debuff Aura statuses get instantiated from info.
--Split the current <object>.name into <object>.<Object Type>Key (so indicatorKey, statusKey etc.) and <object>.name or maybe displayName which would be the possibly localized display name / renamed name / custom name someone typed in.
--Defaults system
--directly use location for indicators instead of grafting it on like right now
--finish default set of indicators and renaming them

--TODO:
--location
	--relative
--status
	--create
	--delete
	--rename
	--countdown
	--class filters
--indicator
	--create
		--specify location up front
	--delete
	--rename
	--priority editing for their statuses
	--frame-level settings for indicators
--category
	--create
	--delete
	--rename
--localization
--individual setups
	--class
	--spec

--Ideas:
--color picker
	--show values
	--web colors?
	--drag & drop?
--buffs-raid
--group-swiftmend disable during swiftmend cooldown
--layout
	--editable and reorderable

--Defaults:
	--Setup
		--Sets up the defaults (as in the metatable for AceDB)
		--Queried values are instantiated from this if they do not exist (& thus user modified)
		--Values are unaffected by a reload
		--Values are a result of defaults set up by various plugins and modules
	--Profile
		--Actual values used by Grid2
		--Changes survive reload

--[[
CopyTable() !!!


tank druid, I use almost the same configuration, with the following changes:
Frame is smaller, around 40 x 30, since its primary use is for dispelling debuffs and identifying squishies who need mobs taunted off of them
Disease debuffs - top left corner, priority 40 (same as Magic debuffs)
Riptide is moved to the top left with other HoTs
Earthliving is moved to the top left with other HoTs
Earth Shield is moved to the top left with other reactive heal buffs
Innervate - bottom left corner

My other alts get similar treatment, with only minor changes to accomodate their class and spec, and how I will be using Grid while playing them.

My config : (I always note from lowest priority to highest)
- Shadow Priest: (edit : yes, my spriest has the same set up as my healers, though I have to admit, depending on which healer one or two things do change.)
* Frame - 35 x 35 - text 12px - size 7 corners - size 17 icon - default colors for frame (dark fg, bright bg)
* center icon for debuffs I can cure or for debuffs that reduce/prevent healing (yes, even on my shadow priest, because I drop out of shadowform to help heal if needed)
* center text : Inc. Heals - health deficit - death/FD/Ghost/Offline - Name
* top left : aggro
* top right : debuffs (magic, poison, disease, curse)
* bottom left : green for heals-incoming
* bottom right : HoTs + low mana
* border : MCed (this also shows up as debuff) - PW:S - my target
* range : frame alpha

Depending on my role, I would change a few things, eg on non-healing classes, I did not have PW:S, Healing reduced/prevented or heals-incoming.
- Mage :
* frame : 30*30 - text 11px - corner 5 - center icon 15 - default frame colors
* center icon : Curses + MC + RaidDebuffs (eg. Infected on Grob)
* center text : Missing HP - Dead/FD/Ghost/Offline/Afk - Name
* top left : aggro
* top right : Debuffs
* bottom left : OOC Missing AI - Low Health - Low mana
* bottom right : Low health
* border : MCed - my target
* range : frame alpha for decursing


With my warlock I would use:
1 corner: soulstone
center icon: magic debuffs (that I can dispel with my felhunter)
text 1: name
border: important raid debuffs



I checked in some modifications to Priest defaults.  Requires SV reset.

Summarizing the healing priest layouts posted here I get the following:

[B]healers-common[/B]
*aggro : corner-bottom-left
*raid-debuff : icon-center
*target : border
*death, range, offline : alpha
*healing-prevented : alpha [if StatusAuraGroup installed]
*healing-reduced : corner-bottom-right [if StatusAuraGroup installed]
*name : text-up
*death, offline, charmed, heals-incoming : text-down
resurrected, res-incoming, soulstone : text-down [if StatusRes installed])
afk : text-down [if StatusAFK installed])
*heals-incoming : bar-heals & text-down & text-down-color
*group-hots : side-left

[B]druid-specific[/B]
debuff-Poison : icon-center-left
debuff-Curse : icon-center-right
group-Swiftmend : side-left [if StatusAuraGroup installed]
buff-Lifebloom : corner-top-left
buff-Regrowth : side-top
buff-Rejuv : corner-top-right
buff-AbolishPoison : corner-bottom-right
buff-WildGrowth : side-bottom (mine)
[B]druid-optional[/B]
buff-LivingSeed :

[B]paladin-specific[/B]
*shield : corner-top-right
[INDENT]*buff-DivineIntervention
*buff-DivineShield
*buff-DivineProtection
*buff-HandOfProtection
*debuff-Forbearance
[/INDENT]
*cure : icon-center
[INDENT]*debuff-Disease
*debuff-Magic
*debuff-Poison[/INDENT]

[B]priest-specific[/B]
*buff-Renew : corner-top-left
*shield : corner-top-right
[INDENT]*buff-PowerWordShield
*debuff-WeakenedSoul[/INDENT]
*buff-PrayerOfMending : side-right (mine)
*cure : icon-center
[INDENT]*debuff-Disease
*debuff-Magic[/INDENT]
[B]priest-optional[/B]
*buff-DivineAegis : side-bottom

[B]shaman-specific[/B]
buff-Riptide : side-left
buff-Earthliving : corner-top-left
*shield : corner-top-right
[INDENT]*buff-EarthShield[/INDENT]
*cure : icon-center
[INDENT]*debuff-Poison
*debuff-Disease
*debuff-Curse (should check for Cleanse Spirit talent?)[/INDENT]

[B]optional[/B]
*healthdeficit (text-down)
*lowmana : border (25%)
*buffs-mine : side-bottom (show when missing, ooc only?) [if StatusAuraGroup installed]



healing shaman goes something like this:
Frame is 60 x 50 with a single size 18 text, size 10 corners, and a size 20 icon, dark foreground with bright background
Aggro - frame border, binary (no threat level coloring), priority 50
Low mana - frame border, priority 10
My target - frame border, priority 20
Curse debuffs - frame border, priority 90
Disease debuffs - frame border, priority 70
Poison debuffs - frame border, priority 80
Magic debuffs - top right corner, priority 40
healing-prevented : border + health bar color + frame alpha, priority 60
healing-reduced : top right corner, priority 60
heals-incoming : incoming heal bar
group-hots : corner-top-left , priority 80
Prayer of Mending + Living Seed - top left corner, priority 70
Power Word: Shield - top left corner, priority 60
buff-EarthShield - bottom right corner, priority 50
buff-Riptide : bottom left corner, mine only, priority 80
buff-Earthliving - bottom left corner, priority 50
Health deficit - center text, priority 60
Unit name - center text, priority 40
Feign Death - center text, priority 80
Dead + Ghost + Offline + Feign Death - center text + health bar color, priority 80
Resurrection incoming/received - center text, priority 90
afk - center text, priority 50
Charmed - health bar color, priority 80
In vehicle - health bar color + frame alpha, priority 90
Ready check - center icon, priority 80
raid-debuff : icon-center, priority 90
Range (40yds) - frame alpha, priority 80
--]]
