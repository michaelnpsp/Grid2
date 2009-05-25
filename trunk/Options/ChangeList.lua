-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua ClassSpell.Druid.Restoration
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Misc.Usable.Starts
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Consumable
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Gear
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Misc
-- C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\lua5.1.exe C:\Users\Dirk\Documents\dev\LibPeriodicTable-3.1\dataminer.lua Tradeskill

--Bugs:
--Fix health bar ordering / layering

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
		--adjust decimals setting (global)
		--decimals threshold
	--Cleanse Spirit check for Shaman debuff-Curse
	--StatusRaidDebuffs
		--access to individual debuffs
		--duration
		--stack counts
--indicator
	--create
		--specify location up front
	--delete
	--rename
	--fix priority editing for statuses
	--frame-level settings for indicators
	--border size adjustment
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
* center text : Inc. Heals - health-deficit - death/FD/Ghost/Offline - Name
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
* bottom left : OOC Missing AI - health-low - Low mana
* bottom right : health-low
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
*resurrected, res-incoming, soulstone : text-down [if StatusRes installed])
*death, offline, charmed, heals-incoming : text-down
*health-deficit : text-down
*afk : text-down [if StatusAFK installed])
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
buff-Riptide : corner-top-left
*shield : corner-top-right
[INDENT]*buff-EarthShield[/INDENT]
*cure : icon-center
[INDENT]*debuff-Poison
*debuff-Disease
*debuff-Curse (should check for Cleanse Spirit talent?)[/INDENT]
[B]shaman-optional[/B]
buff-Earthliving : corner-top-left

[B]optional[/B]
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
healing-prevented : border + bar-health-color + alpha, priority 60
healing-reduced : top right corner, priority 60
heals-incoming : incoming heal bar
group-hots : corner-top-left , priority 80
Prayer of Mending + Living Seed - top left corner, priority 70
Power Word: Shield - top left corner, priority 60
buff-EarthShield - bottom right corner, priority 50
buff-Riptide : bottom left corner, mine only, priority 80
buff-Earthliving - bottom left corner, priority 50
health-deficit - center text, priority 60
Unit name - center text, priority 40
Feign Death - center text, priority 80
Dead + Ghost + Offline + Feign Death - center text +  bar-health-color, priority 80
Resurrection incoming/received - center text, priority 90
afk - center text, priority 50
charmed -  bar-health-color, priority 80
In vehicle - bar-health-color + alpha, priority 90
Ready check - center icon, priority 80
raid-debuff : icon-center, priority 90
Range (40yds) - alpha, priority 80


With this in mind, we're making the following change to UnitAura, UnitBuff, and UnitDebuff:

name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitAura("unit", index or ["name", "rank"][, "filter"])
name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuff("unit", index or ["name", "rank"][, "filter"])
name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitDebuff("unit", index or ["name", "rank"][, "filter"])

The isMine return value has been changed to caster, where caster is the unit token of the unit that applied the aura. This works for all unit tokens, including "pet" and its incarnations, "focus", and "target".

Most importantly, if the aura was applied by a unit that does not have a token (for instance, a vehicle) but is controlled by one that does (the player), this function will return the token of the unit's controller. In other words, if I'm a shaman and I cast Totem of Wrath, which applies the Totem of Wrath buff, the buff will return the "player" token as its caster unit because totems don't have their own unit tokens.

Auras will also be sorted by the game code in a similar fashion such that the first n auras returned by the unit aura functions will be auras applied by either the player or a unit the player controls or owns (e.g. vehicles, pets, totems).

EDIT: I previously stated the "caster" return for the new UnitAura functions could not be an arena unit token. This is incorrect. The new UnitAura functions will return "arena" tokens when appropriate.



On a different topic - The last PTR build included a bunch of changes to the secure handlers code, they're summarized as follows:
1) The SetUpAnimation method that was added in 3.0.8 has been removed (since there's now animation support directly in the UI objects) - Note that the animation API's dont require secure code so there's no explicit functions for them in the secure environment.
2) Many of the information gathering frame methods removed in 3.0.8 have been restored, as has the Show/Hide driver.
3) There's a new driver for performing auto-hide of frames based on mouse hover. Testing today has revealed that there are some bugs which severely limit its usefulness right now (i.e. it's broken), but it should get fixed in a future build.

The hover driver works as follows:
You can register a frame for auto-hiding, specifying an expiration time. Once the mouse enters and then leaves the frame, and stays out of the frame for the expiration time, the frame will be automatically hidden. If the mouse re-enters the frame the expiration time resets.
If the frame is hidden explicitly (and stays hidden for at least one update cycle) then the auto hide is cancelled.
If the frame has moved between when it was registered and when the hiding would occur, the hide is cancelled.
Finally for complex scenarios you can add additional regions to the hover boundary, by adding additional frames to be included in the 'is over' calculation. For a number of reasons the rects of the frames are captured at point of registration and not re-queried afterwards, neither is the visibility of these additional frames important. This provides a fairly flexible way of supporting more or less arbitrary shapes (though there is an overhead in getting too clever, the driver has to check all of the rects)

The methods to control hover registration for normal code (operable when not in combat) are:

RegisterAutoHide(frame, duration) -- Registers a frame for auto-hiding. The duration is in seconds, any previous registration for that frame is replaced.
UnregisterAutoHide(frame) -- Cancels the auto-hiding for a frame.
AddToAutoHide(frame, child) -- Adds the rect of a child to the auto-hide footprint of a frame. This can only be called immediately after registration (before the next OnUpdate cycle).

As noted above, the current implementation has a ocuple of bugs which render it largely unusuable right now.


GetCursorInfo() and GetActionInfo() now correctly work with companions.
GetCursorInfo() returns "companion", <companion index>, "MOUNT/CRITTER"
GetActionInfo() returns "companion", <companion index>, "MOUNT/CRITTER", <creature spell id>
<companion index> is the value used in GetCompanionInfo("type", index) and <creature spell id> is the same as the third return of GetCompanionInfo().
At that, GetActionInfo() was changed so it also returns the spellID of spells as the 4th return too.


The new macro option is "spec" and the possible values are 1 and 2 as follows:
/cast [spec:1] Lightning Bolt; Healing Wave


It's just a way of doing frame recycling instead of having to create a new frame every single time, it'll try and reuse an already created one. http://wowcompares.com/0109742/FrameXML/UIPanelTemplates.lua see bottom of file.


StaticPopupDialogs["PARTY_INVITE"].OnHide = function(self) self:Hide(); end
That stops invite canceling when you hide the frame regardless, you can just save OnHide's value and then set it to nil when you accept the invite and then reset it right after and it works fine.

/dump (UnitGUID("player"))
/dump bit.band(UnitGUID("player"):sub(1, 5), 0x00f) == 0x004

--]]

