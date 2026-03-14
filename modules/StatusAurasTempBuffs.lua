-- Group of Buffs status
local Grid2 = Grid2
local myUnits = Grid2.roster_my_units
local canaccessvalue = Grid2.canaccessvalue
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

-- all buffs
local textures = {}
local slots = {}
local color = {}
local colors = {color, color, color, color, color, color, color, color, color, color, color, color}

-- normal buffs
local counts = {}
local expirations = {}
local durations = {}

-- missing buffs
local mcounts = {1}
local mexpirations = {0}
local mdurations = mexpirations

-- buffs group status
local function status_GetIcons(self, unit, max)
	local i, j, spells, filter = 1, 1, self.spells, self.isMine
	repeat
		local a = GetAuraDataByIndex(unit, i)
		if a==nil then break end
		if canaccessvalue(a.spellId) and (spells[a.name] or spells[a.spellId]) and (filter==false or filter==myUnits[a.sourceUnit]) then
			textures[j] = a.icon
			counts[j] = a.applications
			durations[j] = a.duration
			expirations[j] = a.expirationTime
			slots[j] = a.auraInstanceID
			j = j + 1
		end
		i = i + 1
	until j>max
	if j>1 then
		color.r, color.g, color.b, color.a = self:GetColor(unit)
	end
	return j-1, textures, counts, expirations, durations, colors, slots
end

local function status_GetIconsMissing(self, unit)
	if self:IsActive(unit) then
		color.r, color.g, color.b, color.a = self:GetColor(unit)
		textures[1], slots[1] = self.missingTexture, 0
		return 1, textures, mcounts, mexpirations, mdurations, colors, slots
	end
	return 0
end

local function status_Update(self, dbx)
	self.GetIcons = dbx.missing and status_GetIconsMissing or status_GetIcons
end

local statusTypes = { "color", "icon", "icons", "percent", "text" }
local function status_Create(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	if dbx.spellName then dbx.spellName = nil end -- fix possible wrong data in old database
	status.OnUpdate = status_Update
	return Grid2.CreateStatusAura( status, basekey, dbx, 'buff', statusTypes )
end

-- Registration
Grid2.setupFunc["buffs"] = status_Create

--[[ status database configuration
	type = "buffs"
	subType = 'blizzard' | nil
	auras = { "Riptide", 12323, "Earth Shield", ... }
	colorThresholdElapsed = true | nil 	-- true = color by elapsed time; nil= color by remaining time
	colorThreshold = { 10, 4, 2 } 	    -- thresholds in seconds to change the color
	colorCount = number
	color1 = { r=1,g=1,b=1,a=1 }
	color2 = { r=1,g=1,b=0,a=1 }
--]]
