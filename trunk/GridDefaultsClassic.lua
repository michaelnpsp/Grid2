--[[
Created by Michael, based on Grid2Options\GridDefaults.lua from original Grid2 authors
--]]

local Grid2 = Grid2
local type, pairs = type, pairs
local Location = Grid2.CreateLocation
local defaultFont = "Friz Quadrata TT"

-- Default configurations
function Grid2:MakeDefaultsCommon()
	Grid2:DbSetValue( "indicators",  "tooltip", {type = "tooltip", showTooltip = 4, showDefault = true} )

	Grid2:DbSetValue( "indicators",  "alpha", {type = "alpha"})
	Grid2:DbSetMap( "alpha", "range", 99)
	Grid2:DbSetMap( "alpha", "death", 98)
	Grid2:DbSetMap( "alpha", "offline", 97)

	Grid2:DbSetValue( "indicators",  "border", {type = "border", color1 = {r=0,g=0,b=0,a=0}})
	Grid2:DbSetMap( "border", "health-low", 55)
	Grid2:DbSetMap( "border", "target", 50)

	Grid2:DbSetValue( "indicators",  "health", {type = "bar", level = 2, location= Location("CENTER"), texture = "Gradient", color1 = {r=0,g=0,b=0,a=1}})
	Grid2:DbSetMap( "health", "health-current", 99)

	Grid2:DbSetValue( "indicators",  "health-color", {type = "bar-color"})
	Grid2:DbSetMap( "health-color", "classcolor", 99)

	Grid2:DbSetValue( "indicators",  "heals", {type = "bar", anchorTo = "health", level = 1, location = Location("CENTER"), texture = "Gradient", opacity=0.25, color1 = {r=0,g=0,b=0,a=0}})
	Grid2:DbSetMap( "heals", "heals-incoming", 99)

	Grid2:DbSetValue( "indicators",  "heals-color", {type = "bar-color"})
	Grid2:DbSetMap( "heals-color", "classcolor", 99)

	Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "square", level = 9, location = Location("TOPLEFT"), size = 5,})
	Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "square", level = 9, location= Location("TOPRIGHT"), size = 5,})
	Grid2:DbSetValue( "indicators",  "corner-bottom-left", {type = "square", level = 5, location = Location("BOTTOMLEFT"), size = 5, color1 = {r=1,g=1,b=1,a=1},})
	Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "square", level = 5, location = Location("BOTTOMRIGHT"), size = 5,})
	Grid2:DbSetValue( "indicators",  "side-bottom", {type = "square", level = 9, location = Location("BOTTOM"), size = 5,})

	Grid2:DbSetValue( "indicators",  "icon-center", {type = "icon", level = 8, location = Location("CENTER"), size = 14, fontSize = 8,})
	Grid2:DbSetMap( "icon-center", "death", 155)
	Grid2:DbSetMap( "icon-center", "ready-check", 150)

	Grid2:DbSetValue( "indicators",  "icon-right", {type = "icon", level = 8, location = Location("RIGHT",2), size = 12, fontSize = 8,})
	Grid2:DbSetValue( "indicators",  "icon-left", {type = "icon", level = 8, location = Location("LEFT",-2), size = 12, fontSize = 8,})
	Grid2:DbSetMap( "icon-left", "raid-icon-player", 155)

	Grid2:DbSetValue( "indicators",  "text-up", {type = "text", level = 7, location = Location("TOP",0,-8) , textlength = 6, fontSize = 8 })
	Grid2:DbSetMap( "text-up", "health-deficit", 50)
	Grid2:DbSetMap( "text-up", "feign-death", 96)
	Grid2:DbSetMap( "text-up", "death", 95)
	Grid2:DbSetMap( "text-up", "offline", 93)
	Grid2:DbSetMap( "text-up", "charmed", 65)
	Grid2:DbSetValue( "indicators",  "text-up-color", {type = "text-color"})
	Grid2:DbSetMap( "text-up-color", "health-deficit", 50)
	Grid2:DbSetMap( "text-up-color", "feign-death", 96)
	Grid2:DbSetMap( "text-up-color", "death", 95)
	Grid2:DbSetMap( "text-up-color", "offline", 93)
	Grid2:DbSetMap( "text-up-color", "charmed", 65)

	Grid2:DbSetValue( "indicators",  "text-down", {type = "text", level = 6, location = Location("BOTTOM",0,4) , textlength = 6, fontSize = 10 })
	Grid2:DbSetMap( "text-down", "name", 99)
	Grid2:DbSetValue( "indicators",  "text-down-color", {type = "text-color"})
	Grid2:DbSetMap( "text-down-color", "classcolor", 99)
end

do
	local class= select(2, UnitClass("player"))
	if class=="SHAMAN" then Grid2.MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-AncestralFortitude-mine", {type = "buff", spellName = 16237, mine = true, color1 = {r=.9,g=.9,b=.4,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-AncestralFortitude", {type = "buff", spellName = 16237, color1 = {r=.8,g=.8,b=.2,a=1}})
		Grid2:DbSetMap( "corner-top-right", "buff-AncestralFortitude-mine", 99)
		Grid2:DbSetMap( "corner-top-right", "buff-AncestralFortitude", 89)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 90)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 80)
		Grid2:DbSetMap( "border", "debuff-Poison" , 70)
		Grid2:DbSetMap( "border", "debuff-Disease", 60)
	end elseif class=="DRUID" then Grid2.MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-Rejuvenation-mine", {type = "buff", spellName = 774, mine = true, color1 = {r=1,g=0,b=.6,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Regrowth-mine", {type = "buff", spellName = 8936, mine = true, color1 = {r=.5,g=1,b=0,a=1}})
		Grid2:DbSetMap( "corner-top-left", "buff-Rejuvenation-mine", 99)
		Grid2:DbSetMap( "corner-top-right", "buff-Regrowth-mine", 99)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 90)
		Grid2:DbSetMap( "border", "debuff-Poison" , 80)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 70)
		Grid2:DbSetMap( "border", "debuff-Disease", 60)
	end elseif class=="PALADIN" then Grid2.MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-BlessingOfKings",           {type = "buff", spellName = 20217, color1 = {r=.7,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BlessingOfKings(greater)",  {type = "buff", spellName = 25898, color1 = {r=.7,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BlessingOfMight",           {type = "buff", spellName = 25291, color1 = {r=.7,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BlessingOfMight(greater)",  {type = "buff", spellName = 25916, color1 = {r=.7,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BlessingOfWisdom",          {type = "buff", spellName = 25290, color1 = {r=.7,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BlessingOfWisdom(greater)", {type = "buff", spellName = 25918, color1 = {r=.7,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "debuff-Forbearance", {type = "debuff", spellName = 25771, color1 = {r=1,g=0,b=0,a=1}})
		Grid2:DbSetMap( "border", "debuff-Disease", 90)
		Grid2:DbSetMap( "border", "debuff-Poison" , 80)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 70)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 60)
	end elseif class=="PRIEST" then Grid2.MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-PowerWordShield", {type = "buff", spellName = 10901, color1 = {r=0,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Renew-mine", {type = "buff", spellName = 25315, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-SpiritOfRedemption", {type = "buff", spellName = 27827, blinkThreshold = 3, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "debuff-WeakenedSoul", {type = "debuff", spellName = 6788, color1 = {r=0,g=.2,b=.9,a=1}})
		Grid2:DbSetMap( "corner-top-left", "buff-Renew-mine", 99)
		Grid2:DbSetMap( "corner-top-right", "buff-PowerWordShield", 99)
		Grid2:DbSetMap( "corner-top-right", "debuff-WeakenedSoul", 89)
		Grid2:DbSetMap( "border", "debuff-Disease", 90)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 80)
		Grid2:DbSetMap( "border", "debuff-Poison" , 70)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 60)
	end elseif class=="MAGE" then Grid2.MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses", "buff-IceArmor-mine", {type = "buff", spellName = 10220, mine = true, missing = true, color1 = {r=.2,g=.4,b=.4,a=1}})
		Grid2:DbSetValue( "statuses", "buff-IceBarrier-mine", {type = "buff", spellName = 11426, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end elseif class=="ROGUE" then Grid2.MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-Evasion-mine", {type = "buff", spellName = 5277, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetMap( "side-bottom", "buff-Evasion-mine", 99)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end elseif class=="WARLOCK" then Grid2.MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses", "buff-ShadowWard-mine", {type = "buff", spellName = 28610, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses", "buff-SoulLink-mine", {type = "buff", spellName = 19028, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses", "buff-DemonSkin-mine", {type = "buff", spellName = 687, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetMap( "corner-bottom-right", "buff-ShadowWard-mine", 99)
		Grid2:DbSetMap( "corner-bottom-right", "buff-SoulLink-mine", 99)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end elseif class=="WARRIOR" then Grid2.MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-BattleShout", {type = "buff", spellName = 6673, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-ShieldWall", {type = "buff", spellName = 871, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-LastStand", {type = "buff", spellName = 12975, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetMap( "side-bottom", "buff-BattleShout", 89)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end else Grid2.MakeDefaultsClass= function() end end
end
