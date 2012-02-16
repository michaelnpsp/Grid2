local spells
local class = select(2, UnitClass("player"))

if class=="SHAMAN" then
	spells = { 1064, 73921 }
	Grid2:DbSetStatusDefaultValue( "aoe-ChainHeal", {type = "aoe-heal", 
		healthDeficit = 10000, minPlayers = 4, maxSolutions = 5, radius = 12.5, keepPrevHeals = true,
		color1 = {r=0, g=1, b=0, a=1}, } )
elseif class=="DRUID" then
	Grid2:DbSetStatusDefaultValue( "aoe-WildGrowth", {type = "aoe-heal",
		hideOnCooldown= true, healthDeficit= 10000, minPlayers = 5,	maxSolutions = 1, radius = 30, keepPrevHeals = true,
		color1 = {r=0, g=1, b=0, a=1}, } )
elseif class=="PRIEST" then
	spells = { 34861, 64844, 15237 }
	Grid2:DbSetStatusDefaultValue( "aoe-CircleOfHealing", {type = "aoe-heal", 
		hideOnCooldown= true, healthDeficit= 10000, minPlayers = 5, maxSolutions = 1, radius = 30, keepPrevHeals = true,
		color1 = {r=0, g=1, b=0, a=1}, } )
	Grid2:DbSetStatusDefaultValue( "aoe-PrayerOfHealing", {type = "aoe-heal", 
		healthDeficit = 10000, minPlayers = 5, maxSolutions = 1, radius = 30,
		color1 = {r=0, g=1, b=0.5, a=1}, } )
elseif class=="PALADIN" then		
	spells = { 85222 }
end	

Grid2:DbSetStatusDefaultValue( "aoe-neighbors", {type = "aoe-heal", radius = 12.5, minPlayers = 4, color1 = {r=0,g=0.5,b=1,a=1}, } )
Grid2:DbSetStatusDefaultValue( "aoe-highlighter", {type = "aoe-heal", highlightStatus = "aoe-neighbors", color1 = {r=0,g=0.5,b=1,a=1}, } )

if spells then
	Grid2:DbSetStatusDefaultValue( "aoe-OutgoingHeals", {type = "aoe-OutgoingHeals", spells= spells, activeTime= 2, color1 = {r=0,g=0.8,b=1,a=1} } )
end	
