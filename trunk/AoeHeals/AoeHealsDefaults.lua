
local prev_UpdateDefaults= Grid2.UpdateDefaults
function Grid2:UpdateDefaults()
	prev_UpdateDefaults(self)
	local version= Grid2:DbGetValue("versions", "Grid2AoeHeals") or 0
	if version<2 then 
		local class = select(2, UnitClass("player"))
		if version<1 then
			if class=="SHAMAN" then
				Grid2:DbSetValue( "statuses",  "aoe-ChainHeal", {type = "aoe-heal", 
					healthDeficit = 10000, minPlayers = 4, maxSolutions = 5, radius = 12.5, keepPrevHeals = true,
					color1 = {r=0, g=1, b=0, a=1}, } )
			elseif class=="DRUID" then
				Grid2:DbSetValue( "statuses",  "aoe-WildGrowth", {type = "aoe-heal",
					hideOnCooldown= true, healthDeficit= 10000, minPlayers = 5,	maxSolutions = 1, radius = 30, keepPrevHeals = true,
					color1 = {r=0, g=1, b=0, a=1}, } )
			elseif class=="PRIEST" then
				Grid2:DbSetValue( "statuses",  "aoe-CircleOfHealing", {type = "aoe-heal", 
					hideOnCooldown= true, healthDeficit= 10000, minPlayers = 5, maxSolutions = 1, radius = 30, keepPrevHeals = true,
					color1 = {r=0, g=1, b=0, a=1}, } )
				Grid2:DbSetValue( "statuses",  "aoe-PrayerOfHealing", {type = "aoe-heal", 
					healthDeficit = 10000, minPlayers = 5, maxSolutions = 1, radius = 30,
					color1 = {r=0, g=1, b=0.5, a=1}, } )
			end	
			Grid2:DbSetValue( "statuses",  "aoe-neighbors", {type = "aoe-heal", radius = 12.5, minPlayers = 4, color1 = {r=0,g=0.5,b=1,a=1}, } )
			Grid2:DbSetValue( "statuses",  "aoe-highlighter", {type = "aoe-heal", highlightStatus = "aoe-neighbors", color1 = {r=0,g=0.5,b=1,a=1}, } )
		end	
		if version<2 and class=="SHAMAN" then
			Grid2:DbSetValue( "statuses",  "aoe-HealingRain", {type = "aoe-HealingRain", color1 = {r=0,g=0.8,b=1,a=1}, } )
		end		
		Grid2:DbSetValue("versions","Grid2AoeHeals",2)
	end	
end
