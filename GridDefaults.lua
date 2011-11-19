--[[
Created by Michael, based on Grid2Options\GridDefaults.lua from original Grid2 authors
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local Grid2= Grid2

local defaultFont = "Friz Quadrata TT"

-- Database manipulation functions

function Grid2:DbSetValue(section, name, value)
  self.db.profile[section][name]= value
end

function Grid2:DbSetMissingValue(section, name, value)
	if not self.db.profile[section][name] then
		self.db.profile[section][name]= value
		return true
	end	
end

function Grid2:DbGetValue(section, name)
  return self.db.profile[section][name]
end;

function Grid2:DbSetMap(indicatorName, statusName, priority)
	local map= self.db.profile.statusMap
	if priority then
		if not map[indicatorName] then
			map[indicatorName] =  {}
		end
		map[indicatorName][statusName] =  priority
	else
		if map[indicatorName] and map[indicatorName][statusName] then
			map[indicatorName][statusName] = nil
		end		
	end	
end

function Grid2:DbGetIndicator(name)
    return self.db.profile.indicators[name]
end

function Grid2:DbSetIndicator(name, value)
	if value==nil then
		local map= Grid2.db.profile.statusMap
		if map[name] then 
			map[name]= nil
		end	
	end
    self.db.profile.indicators[name]= value
end

---

function Grid2.CreateLocation(a,b,c,d)
    local p = a or "TOPLEFT"
	if type(b)=="string" then
		return { relPoint = p, point = b, x = c or 0, y = d or 0 }
	else
		return { relPoint = p, point = p, x = b or 0, y = c or 0 }
	end
end
local Location= Grid2.CreateLocation

-- Default configurations

function MakeDefaultsCommon()
	-- Indicators
	Grid2:DbSetValue( "indicators",  "alpha", {type = "alpha", color1 = {r=0,g=0,b=0,a=1}})
	Grid2:DbSetMap( "alpha", "range", 99)
	Grid2:DbSetMap( "alpha", "death", 98)
	Grid2:DbSetMap( "alpha", "offline", 97)

	Grid2:DbSetValue( "indicators",  "border", {type = "border", color1 = {r=0,g=0,b=0,a=0}})
	Grid2:DbSetMap( "border", "health-low", 55)
	Grid2:DbSetMap( "border", "target", 50)

	Grid2:DbSetValue( "indicators",  "health", {type = "bar", childBar = "heals", level = 2, location= Location("CENTER"), texture = "Gradient", color1 = {r=0,g=0,b=0,a=1}})
	Grid2:DbSetMap( "health", "health-current", 99)

	Grid2:DbSetValue( "indicators",  "health-color", {type = "bar-color"})
	Grid2:DbSetMap( "health-color", "classcolor", 99)

	Grid2:DbSetValue( "indicators",  "heals", {type = "bar", parentBar = "health", level = 1, location = Location("CENTER"), texture = "Gradient", opacity=0.25, color1 = {r=0,g=0,b=0,a=0}})
	Grid2:DbSetMap( "heals", "heals-incoming", 99)

	Grid2:DbSetValue( "indicators",  "heals-color", {type = "bar-color"})
	Grid2:DbSetMap( "heals-color", "classcolor", 99)

	Grid2:DbSetValue( "indicators",  "corner-bottom-left", {type = "square", level = 5, location = Location("BOTTOMLEFT"), size = 5, color1 = {r=1,g=1,b=1,a=1},})
	Grid2:DbSetMap( "corner-bottom-left", "threat", 99)

	Grid2:DbSetValue( "indicators",  "icon-center", {type = "icon", level = 8, location = Location("CENTER"), size = 14, fontSize = 8,})
	Grid2:DbSetMap( "icon-center", "death", 155)
	Grid2:DbSetMap( "icon-center", "ready-check", 150)

	Grid2:DbSetValue( "indicators",  "icon-left", {type = "icon", level = 8, location = Location("LEFT",-2), size = 12, fontSize = 8,})
	Grid2:DbSetMap( "icon-left", "raid-icon-player", 155)

	Grid2:DbSetValue( "indicators",  "icon-right", {type = "icon", level = 8, location = Location("RIGHT",2), size = 12, fontSize = 8,})
	--Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	
	Grid2:DbSetValue( "indicators",  "text-up", {type = "text", level = 7, location = Location("TOP",0,-8) , textlength = 6, fontSize = 8, font = defaultFont,})
	Grid2:DbSetMap( "text-up", "health-deficit", 50)
	Grid2:DbSetMap( "text-up", "feign-death", 96)
	Grid2:DbSetMap( "text-up", "death", 95)
	Grid2:DbSetMap( "text-up", "offline", 93)
	Grid2:DbSetMap( "text-up", "vehicle", 70)
	Grid2:DbSetMap( "text-up", "charmed", 65)
	Grid2:DbSetValue( "indicators",  "text-up-color", {type = "text-color"})
	Grid2:DbSetMap( "text-up-color", "health-deficit", 50)
	Grid2:DbSetMap( "text-up-color", "feign-death", 96)
	Grid2:DbSetMap( "text-up-color", "death", 95)
	Grid2:DbSetMap( "text-up-color", "offline", 93)
	Grid2:DbSetMap( "text-up-color", "vehicle", 70)
	Grid2:DbSetMap( "text-up-color", "charmed", 65)

	Grid2:DbSetValue( "indicators",  "text-down", {type = "text", level = 6, location = Location("BOTTOM",0,4) , textlength = 6, fontSize = 8, font = defaultFont,})
	Grid2:DbSetMap( "text-down", "name", 99)
	Grid2:DbSetValue( "indicators",  "text-down-color", {type = "text-color"})
	Grid2:DbSetMap( "text-down-color", "classcolor", 99)	

	--- Statuses
	local colors = {
		HOSTILE = { r = 1, g = 0.1, b = 0.1, a = 1 },
		UNKNOWN_UNIT = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
		UNKNOWN_PET = { r = 0, g = 1, b = 0, a = 1 },
		[L["Beast"]] = { r = 0.94, g = 0.76, b = 0.28, a = 1 },
		[L["Demon"]] = { r = 0.54, g = 0.25, b = 0.69, a = 1 },
		[L["Humanoid"]] = { r = 0.92, g = 0.67, b = 0.85, a = 1 },
		[L["Elemental"]] = { r = 0.1, g = 0.3, b = 0.9, a = 1 },
	}
	for class, color in pairs(RAID_CLASS_COLORS) do
		if (not colors[class]) then
			colors[class] = { r = color.r, g = color.g, b = color.b, a = 1 }
		end
	end
	Grid2:DbSetValue( "statuses",  "afk", {type = "afk",  color1= {r=1,g=0,b=0,a=1} } )
	Grid2:DbSetValue( "statuses",  "classcolor", {type = "classcolor", colorHostile = true, colors = colors})
	Grid2:DbSetValue( "statuses",  "charmed", {type = "charmed", color1 = {r=1,g=.1,b=.1,a=1}})
	Grid2:DbSetValue( "statuses",  "death", {type = "death", color1 = {r=1,g=1,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "feign-death", {type = "feign-death", color1 = {r=1,g=.5,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "health-current", {type = "health-current", color1 = {r=0,g=1,b=0,a=1}, deadAsFullHealth = nil})
	Grid2:DbSetValue( "statuses",  "health-deficit", {type = "health-deficit", color1 = {r=1,g=1,b=1,a=1}, threshold = 0.05})
	Grid2:DbSetValue( "statuses",  "health-low", {type = "health-low", threshold = 0.4, color1 = {r=1,g=0,b=0,a=1}})
	Grid2:DbSetValue( "statuses",  "heals-incoming", {type = "heals-incoming", includePlayerHeals = false, flags = 0, color1 = {r=0,g=1,b=0,a=1}})
	Grid2:DbSetValue( "statuses",  "lowmana", {type = "lowmana", threshold = 0.75, color1 = {r=0.5,g=0,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "mana", {type = "mana", color1= {r=0,g=0,b=1,a=1}} )
	Grid2:DbSetValue( "statuses",  "poweralt", {type = "poweralt", color1= {r=1,g=0,b=0.5,a=1}} )
	Grid2:DbSetValue( "statuses",  "name", {type = "name"})
	Grid2:DbSetValue( "statuses",  "offline", {type = "offline", color1 = {r=1,g=1,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "pvp", {type = "pvp", color1 = {r=0,g=1,b=1,a=.75}})
	Grid2:DbSetValue( "statuses",  "range", {type = "range", range= 38, default = 0.25, elapsed = 0.5})
	Grid2:DbSetValue( "statuses",  "ready-check", {type = "ready-check", threshold = 10, colorCount = 4, color1 = {r=1,g=1,b=0,a=1}, color2 = {r=0,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1}, color4 = {r=1,g=0,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "role", {type = "role", colorCount = 2, color1 = {r=1,g=1,b=.5,a=1}, color2 = {r=.5,g=1,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "target", {type = "target", color1 = {r=.8,g=.8,b=.8,a=.75}})
	Grid2:DbSetValue( "statuses",  "threat", {type = "threat", colorCount = 3, color1 = {r=1,g=0,b=0,a=1}, color2 = {r=.5,g=1,b=1,a=1}, color3 = {r=1,g=1,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "vehicle", {type = "vehicle", color1 = {r=0,g=1,b=1,a=.75}})
	Grid2:DbSetValue( "statuses",  "voice", {type = "voice", color1 = {r=1,g=1,b=0,a=1}})
	Grid2:DbSetValue( "statuses",  "debuff-Magic", {type = "debuffType", subType = "Magic", color1 = {r=.2,g=.6,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "debuff-Poison", {type = "debuffType", subType = "Poison", color1 = {r=0,g=.6,b=0,a=1}})
	Grid2:DbSetValue( "statuses",  "debuff-Curse", {type = "debuffType", subType = "Curse", color1 = {r=.6,g=0,b=1,a=1}})
	Grid2:DbSetValue( "statuses",  "debuff-Disease", {type = "debuffType", subType = "Disease", color1 = {r=.6,g=.4,b=0,a=1}})
	Grid2:DbSetValue( "statuses", "raid-icon-player", {type = "raid-icon-player", colorCount = 8,
			color1 = {r = 1.0, g = 0.92, b = 0, a = 1},     -- Yellow Star
			color2 = {r = 0.98, g = 0.57, b = 0, a = 1},    -- Orange Circle
			color3 = {r = 0.83, g = 0.22, b = 0.9, a = 1},  -- Purple Diamond
			color4 = {r = 0.04, g = 0.95, b = 0, a = 1},    -- Green Triangle
			color5 = {r = 0.7, g = 0.82, b = 0.875, a = 1}, -- White Crescent Moon
			color6 = {r = 0, g = 0.71, b = 1, a = 1},       -- Blue Square
			color7 = {r = 1.0, g = 0.24, b = 0.168, a = 1}, -- Red 'X' Cross
			color8 = {r = 0.98, g = 0.98, b = 0.98, a = 1},  -- White Skull
			opacity = 1, --alpha setting
	})
	Grid2:DbSetValue( "statuses", "raid-icon-target", {type = "raid-icon-target", colorCount = 8,
			color1 = {r = 1.0, g = 0.92, b = 0, a = 1},     -- Yellow Star
			color2 = {r = 0.98, g = 0.57, b = 0, a = 1},    -- Orange Circle
			color3 = {r = 0.83, g = 0.22, b = 0.9, a = 1},  -- Purple Diamond
			color4 = {r = 0.04, g = 0.95, b = 0, a = 1},    -- Green Triangle
			color5 = {r = 0.7, g = 0.82, b = 0.875, a = 1}, -- White Crescent Moon
			color6 = {r = 0, g = 0.71, b = 1, a = 1},       -- Blue Square
			color7 = {r = 1.0, g = 0.24, b = 0.168, a = 1}, -- Red 'X' Cross
			color8 = {r = 0.98, g = 0.98, b = 0.98, a = 1},  -- White Skull
			opacity = 0.5, --alpha setting
	})
end


local MakeDefaultsClass
do 
	local class= select(2, UnitClass("player"))
	if class=="SHAMAN" then MakeDefaultsClass= function()
		-- statuses
		Grid2:DbSetValue( "statuses",  "buff-Riptide-mine", {type = "buff", spellName = 61295, mine = true, color1 = {r=.8,g=.6,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Earthliving", {type = "buff", spellName = 51945, mine= true, color1 = {r=.8,g=1,b=.5,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-EarthShield", {type = "buff", spellName = 974, color1 = {r=.8,g=.8,b=.2,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-EarthShield-mine", {type = "buff", spellName = 974, mine = true, colorCount = 2, color1 = {r=.9,g=.9,b=.4,a=1}, color2 = {r=.9,g=.9,b=.4,a=1} })
		-- indicators
		Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "square", level = 9, location = Location("TOPLEFT"), size = 5,})
		Grid2:DbSetMap( "corner-top-left", "buff-Riptide-mine", 99)
		Grid2:DbSetValue( "indicators",  "side-top", {type = "square", level = 9, location= Location("TOP"), size = 5,})
		Grid2:DbSetMap( "side-top", "buff-Earthliving", 89)
		Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "square", level = 9, location= Location("TOPRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-top-right", "buff-EarthShield-mine", 99)
		Grid2:DbSetMap( "corner-top-right", "buff-EarthShield", 89)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 90)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 80)
		Grid2:DbSetMap( "border", "debuff-Poison" , 70)
		Grid2:DbSetMap( "border", "debuff-Disease", 60)
	end elseif class=="DRUID" then MakeDefaultsClass= function()
		-- statuses
		Grid2:DbSetValue( "statuses",  "buff-Lifebloom-mine", {type = "buff", spellName = 33763, mine = true, colorCount = 3, color1 = {r=.2,g=.7,b=.2,a=1}, color2 = {r=.6,g=.9,b=.6,a=1}, color3 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Rejuvenation-mine", {type = "buff", spellName = 774, mine = true, color1 = {r=1,g=0,b=.6,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Regrowth-mine", {type = "buff", spellName = 8936, mine = true, color1 = {r=.5,g=1,b=0,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-WildGrowth-mine", {type = "buff", spellName = 48438, mine = true, color1 = {r=0.2,g=.9,b=.2,a=1}})
		-- indicators
		Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "text", level = 9, location = Location("TOPLEFT"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "corner-top-left", "buff-Lifebloom-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-left-color", {type = "text-color"})
		Grid2:DbSetMap( "corner-top-left-color", "buff-Lifebloom-mine", 99)
		Grid2:DbSetValue( "indicators",  "side-top", {type = "text", level = 9, location = Location("TOP"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "side-top", "buff-Regrowth-mine", 99)
		Grid2:DbSetValue( "indicators",  "side-top-color", {type = "text-color"})
		Grid2:DbSetMap( "side-top-color", "buff-Regrowth-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "text", level = 9, location = Location("TOPRIGHT"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "corner-top-right", "buff-Rejuvenation-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-right-color", {type = "text-color"})
		Grid2:DbSetMap( "corner-top-right-color", "buff-Rejuvenation-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "square", level = 9, location = Location("BOTTOMRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-bottom-right", "buff-WildGrowth-mine", 99)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 90)
		Grid2:DbSetMap( "border", "debuff-Poison" , 80)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 70)
		Grid2:DbSetMap( "border", "debuff-Disease", 60)
	end elseif class=="PALADIN" then MakeDefaultsClass= function()
		-- statuses
		Grid2:DbSetValue( "statuses",  "buff-BeaconOfLight", {type = "buff", spellName = 53563, color1 = {r=.7,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BeaconOfLight-mine", {type = "buff", spellName = 53563, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-DivineShield-mine", {type = "buff", spellName = 642, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-DivineProtection-mine", {type = "buff", spellName = 498, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-HandOfProtection-mine", {type = "buff", spellName = 1022, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-HandOfSalvation", {type = "buff", spellName = 1038, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-HandOfSalvation-mine", {type = "buff", spellName = 1038, mine = true, color1 = {r=.8,g=.8,b=.7,a=1}})
		Grid2:DbSetValue( "statuses",  "debuff-Forbearance", {type = "debuff", spellName = 25771, color1 = {r=1,g=0,b=0,a=1}})
		-- indicators
		Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "text", level = 9, location = Location("TOPLEFT"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "corner-top-left", "buff-BeaconOfLight", 99)
		Grid2:DbSetMap( "corner-top-left", "buff-BeaconOfLight-mine", 89)
		Grid2:DbSetValue( "indicators",  "corner-top-left-color", {type = "text-color"})
		Grid2:DbSetMap( "corner-top-left-color", "buff-BeaconOfLight", 99)
		Grid2:DbSetMap( "corner-top-left-color", "buff-BeaconOfLight-mine", 89)
		Grid2:DbSetValue( "indicators",  "side-top", {type = "text", level = 9, location = Location("TOP"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "side-top", "buff-FlashOfLight-mine", 99)
		Grid2:DbSetValue( "indicators",  "side-top-color", {type = "text-color"})
		Grid2:DbSetMap( "side-top-color", "buff-FlashOfLight-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "text", level = 9, location = Location("TOPRIGHT"), textlength = 12, fontSize = 8, font = defaultFont, duration = true})
		Grid2:DbSetMap( "corner-top-right", "buff-DivineShield-mine", 97)
		Grid2:DbSetMap( "corner-top-right", "buff-DivineProtection-mine", 95)
		Grid2:DbSetMap( "corner-top-right", "buff-HandOfProtection-mine", 93)
		Grid2:DbSetValue( "indicators",  "corner-top-right-color", {type = "text-color"})
		Grid2:DbSetMap( "corner-top-right-color", "buff-DivineShield-mine", 97)
		Grid2:DbSetMap( "corner-top-right-color", "buff-DivineProtection-mine", 95)
		Grid2:DbSetMap( "corner-top-right-color", "buff-HandOfProtection-mine", 93)
		Grid2:DbSetValue( "indicators",  "corner-bottom-left", {type = "square", level = 5, location = Location("BOTTOMLEFT"), size = 5, color1 = {r=1,g=1,b=1,a=1},})
		Grid2:DbSetMap( "corner-bottom-left", "buff-HandOfSalvation", 101)
		Grid2:DbSetMap( "corner-bottom-left", "buff-HandOfSalvation-mine", 100)
		Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "icon", level = 8, location = Location("BOTTOMRIGHT"), size = 12, fontSize = 8,})
		Grid2:DbSetMap( "corner-bottom-right", "debuff-Forbearance", 99)
		Grid2:DbSetMap( "border", "debuff-Disease", 90)
		Grid2:DbSetMap( "border", "debuff-Poison" , 80)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 70)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 60)
	end elseif class=="PRIEST" then MakeDefaultsClass= function()
		--statuses
		Grid2:DbSetValue( "statuses",  "buff-DivineAegis", {type = "buff", spellName = 47509, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-InnerFire", {type = "buff", spellName = 588, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-PowerWordShield", {type = "buff", spellName = 17, color1 = {r=0,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Renew-mine", {type = "buff", spellName = 139, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-SpiritOfRedemption", {type = "buff", spellName = 27827, blinkThreshold = 3, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-Grace-mine", {type = "buff", spellName = 47516, mine = true,
						colorCount = 3, color1 = {r=.6,g=.6,b=.6,a=1}, color2 = {r=.8,g=.8,b=.8,a=1}, color3 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-PrayerOfMending-mine", {type = "buff", spellName = 33076, mine = true,
						colorCount = 5, color1 = {r=1,g=.2,b=.2,a=1}, color2 = {r=1,g=1,b=.4,a=.4}, 
						color3 = {r=1,g=.6,b=.6,a=1}, color4 = {r=1,g=.8,b=.8,a=1}, color5 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "debuff-WeakenedSoul", {type = "debuff", spellName = 6788, color1 = {r=0,g=.2,b=.9,a=1}})
		-- indicators
		Grid2:DbSetValue( "indicators",  "center-left", {type = "icon", level = 9, location = Location("LEFT"), size = 16, fontSize = 8,})
		Grid2:DbSetMap( "center-left", "debuff-Disease", 10)
		Grid2:DbSetValue( "indicators",  "center-right", {type = "icon", level = 9, location = Location("RIGHT"), size = 16, fontSize = 8,})
		Grid2:DbSetMap( "center-right", "debuff-Magic", 40)
		Grid2:DbSetValue( "indicators",  "corner-top-left", {type = "square", level = 9, location = Location("TOPLEFT"), size = 5,})
		Grid2:DbSetMap( "corner-top-left", "buff-Renew-mine", 99)
		Grid2:DbSetMap( "corner-top-right", "buff-PowerWordShield", 99)
		Grid2:DbSetValue( "indicators",  "side-right", {type = "icon", level = 9, location = Location("RIGHT"), size = 16, fontSize = 8,})
		Grid2:DbSetMap( "side-right", "buff-PrayerOfMending-mine", 99)
		Grid2:DbSetValue( "indicators",  "corner-top-right", {type = "square", level = 9, location = Location("TOPRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-top-right", "debuff-WeakenedSoul", 89)
		Grid2:DbSetValue( "indicators",  "side-bottom", {type = "square", level = 9, location = Location("BOTTOM"), size = 5,})
		Grid2:DbSetMap( "side-bottom", "buff-DivineAegis", 79)
		Grid2:DbSetMap( "side-bottom", "buff-InnerFire", 79)
		Grid2:DbSetMap( "border", "debuff-Disease", 90)
		Grid2:DbSetMap( "border", "debuff-Magic"  , 80)
		Grid2:DbSetMap( "border", "debuff-Poison" , 70)
		Grid2:DbSetMap( "border", "debuff-Curse"  , 60)
	end elseif class=="MAGE" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-FocusMagic", {type = "buff", spellName = 54646, color1 = {r=.11,g=.22,b=.33,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-IceArmor-mine", {type = "buff", spellName = 7302, mine = true, missing = true, color1 = {r=.2,g=.4,b=.4,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-IceBarrier-mine", {type = "buff", spellName = 11426, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "square", level = 5, location = Location("BOTTOMRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-bottom-right", "buff-FocusMagic", 99)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
		Grid2:DbSetMap( "border", "debuff-Curse", 30)
	end elseif class=="ROGUE" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-Evasion-mine", {type = "buff", spellName = 5277, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetMap( "side-bottom", "buff-Evasion-mine", 99)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end elseif class=="WARLOCK" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "square", level = 5, location = Location("BOTTOMRIGHT"), size = 5,})
		Grid2:DbSetValue( "statuses",  "buff-ShadowWard-mine", {type = "buff", spellName = 6229, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-SoulLink-mine", {type = "buff", spellName = 19028, mine = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-DemonArmor-mine", {type = "buff", spellName = 687, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-FelArmor-mine", {type = "buff", spellName = 28176, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
		Grid2:DbSetMap( "corner-bottom-right", "buff-ShadowWard-mine", 99)
		Grid2:DbSetMap( "corner-bottom-right", "buff-SoulLink-mine", 99)
		Grid2:DbSetMap( "corner-bottom-right", "buff-FelArmor-mine", 99)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end elseif class=="WARRIOR" then MakeDefaultsClass= function()
		Grid2:DbSetValue( "statuses",  "buff-Vigilance", {type = "buff", spellName = 50720, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-BattleShout", {type = "buff", spellName = 6673, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-ShieldWall", {type = "buff", spellName = 871, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-LastStand", {type = "buff", spellName = 12975, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "statuses",  "buff-CommandingShout", {type = "buff", spellName = 469, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
		Grid2:DbSetValue( "indicators",  "corner-bottom-right", {type = "square", level = 5, location = Location("BOTTOMRIGHT"), size = 5,})
		Grid2:DbSetMap( "corner-bottom-right", "buff-Vigilance", 99)
		Grid2:DbSetValue( "indicators",  "side-bottom", {type = "square", level = 9, location = Location("BOTTOM"), size = 5,})
		Grid2:DbSetMap( "side-bottom", "buff-BattleShout", 89)
		Grid2:DbSetMap( "side-bottom", "buff-CommandingShout", 79)
		Grid2:DbSetMap( "corner-bottom-right", "buff-LastStand", 99)
		Grid2:DbSetMap( "corner-bottom-right", "buff-ShieldWall", 89)
		Grid2:DbSetMap( "icon-right", "raid-icon-target", 90)
	end else MakeDefaultsClass= function() end end
end

-- Plugins: Must hook this function to initialize default values in database
function Grid2:UpdateDefaults()

	local version= Grid2:DbGetValue("versions","Grid2") or 0
	if version>=2 then return end
	if version==0 then
		MakeDefaultsCommon()
		MakeDefaultsClass()
	end	
	Grid2:DbSetMissingValue( "statuses", "banzai", { type = "banzai", color1 = {r=1,g=0,b=1,a=1} })
	Grid2:DbSetMissingValue( "statuses", "banzai-threat", { type = "banzai-threat", color1 = {r=1,g=0,b=0,a=1} })
	Grid2:DbSetMissingValue( "statuses", "direction", { type = "direction", color1 = { r= 0, g= 1, b= 0, a=1 } })
	Grid2:DbSetMissingValue( "statuses", "dungeon-role", {	type = "dungeon-role", colorCount = 3,	
		color1 = { r = 0.75, g = 0, b = 0 }, --dps
		color2 = { r = 0, g = 0.75, b = 0 }, --heal
		color3 = { r = 0, g = 0, b = 0.75 }, --tank
		opacity = 0.75 
	})
	Grid2:DbSetMissingValue( "statuses", "creaturecolor", { type = "creaturecolor", colorHostile = true, colors= {
		HOSTILE = { r = 1, g = 0.1, b = 0.1, a = 1 },
		UNKNOWN_UNIT = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
		[L["Beast"]] = { r = 0.94, g = 0.75, b = 0.28, a = 1 },
		[L["Demon"]] = { r = 0.5, g = 0.25, b = 0.69, a = 1 },
		[L["Humanoid"]] = { r = 0.92, g = 0.67, b = 0.85, a = 1 },
		[L["Elemental"]] = { r = 0.1, g = 0.3, b = 0.9, a = 1 }, }
	})
	Grid2:DbSetMissingValue( "statuses", "friendcolor", { type = "friendcolor",	
		colorCount = 3,	
		color1 = { r = 0, g = 1, b = 0, a=1 },    --player 
		color2 = { r = 0, g = 1, b = 0, a=0.75 }, --pet 
		color3 = { r = 1, g = 0, b = 0, a=1 },    --hostile
	})
	Grid2:DbSetMissingValue("statuses", "leader", { type = "leader", color1 = {r=0,g=.7,b=1,a=1}})
	Grid2:DbSetMissingValue("statuses", "raid-assistant", { type = "raid-assistant", color1 = {r=1,g=.25,b=.2,a=1}})
	Grid2:DbSetMissingValue("statuses", "master-looter", { type = "master-looter", color1 = {r=1,g=.5,b=0,a=1}})
	Grid2:DbSetMissingValue( "statuses",  "power", {type = "power", colorCount = 5, 
		color1 = {r=0,g=0.5,b=1  ,a=1},   -- mana
		color2 = {r=1,g=0  ,b=0  ,a=1},   -- rage
		color3 = {r=1,g=0.5,b=0  ,a=1},   -- focus
		color4 = {r=1,g=1  ,b=0  ,a=1},   -- energy
		color5 = {r=0,g=0.8,b=0.8,a=1},   -- runic power
	})  
	Grid2:DbSetMissingValue( "statuses",  "shields", { type = "shields", color1 = {r=0,g=1,b=0,a=1} })
	if Grid2:DbSetMissingValue( "statuses", "resurrection", { type = "resurrection", colorCount = 2,	
		color1 = { r = 0, g = 1, b = 0, a=1 },    
		color2 = { r = 1, g = 1, b = 0, a=0.75 }, }) 
	then
		Grid2:DbSetMap( "icon-center", "resurrection", 160)
	end	
	-- Upgrade health&heals indicator
	local health = Grid2:DbGetValue("indicators", "health")
	local heals  = Grid2:DbGetValue("indicators", "heals")
	if health and heals then
		health.childBar = "heals"
		heals.parentBar = "health"
	end
	-- Set database version
	Grid2:DbSetValue("versions","Grid2",2)	
	
end