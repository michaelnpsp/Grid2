-- Group of Buffs status
local Grid2 = Grid2
local UnitBuff = UnitBuff
local myUnits = Grid2.roster_my_units

local textures = {}
local counts = {}
local expirations = {}
local durations = {}
local colors = {}
local color = {}

local function status_GetIcons(self, unit)
	color.r, color.g, color.b, color.a = self:GetColor(unit)
	local i, j, spells, filter, name, caster = 1, 1, self.spells, self.isMine
	while true do
		name, textures[j], counts[j], _, durations[j], expirations[j], caster = UnitBuff(unit, i)
		if not name then return j-1, textures, counts, expirations, durations, colors end
		if spells[name] and (filter==false or filter==myUnits[caster]) then 
			colors[j] = color
			j = j + 1 
		end	
		i = i + 1
	end
end

-- Registration
do
	local statusTypes = { "color", "icon", "icons", "percent", "text" }
	Grid2.setupFunc["buffs"] = function(baseKey, dbx)
		local status = Grid2.statusPrototype:new(baseKey, false)
		status.GetIcons = status_GetIcons
		return Grid2.CreateStatusAura( status, basekey, dbx, 'buff', statusTypes )
	end
end

--[[ status database configuration
	type = "buffs"
	auras = { "Riptide", 12323, "Earth Shield", ... }
	colorThresholdElapsed = true | nil 	-- true = color by elapsed time; nil= color by remaining time
	colorThreshold = { 10, 4, 2 } 	    -- thresholds in seconds to change the color
	colorCount = number
	color1 = { r=1,g=1,b=1,a=1 }
	color2 = { r=1,g=1,b=0,a=1 }
--]]
