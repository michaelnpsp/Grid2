-- Group of Buffs status
local Grid2 = Grid2
local wipe = wipe
local myUnits = Grid2.roster_my_units
local canaccessvalue = Grid2.canaccessvalue
local GetAuraDuration = C_UnitAuras.GetAuraDuration
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex

--
local auras_tmp = {}
local empty_table = {}

-- buffs group status
local function status_GetIcons(self, unit, max)
	wipe(auras_tmp)
	local i, j, spells, filter = 1, 1, self.spells, self.isMine
	repeat
		local a = GetAuraDataByIndex(unit, i)
		if a==nil then break end
		if canaccessvalue(a.spellId) and (spells[a.name] or spells[a.spellId]) and (filter==false or filter==myUnits[a.sourceUnit]) then
			a.color = self.color
			a.durationObject = GetAuraDuration(unit, a.auraInstanceID)
			auras_tmp[j] = a
			j = j + 1
		end
		i = i + 1
	until j>max
	return auras_tmp
end

local function status_GetIconsMissing(self, unit)
	if self:IsActive() then
		return self.aurasMissing
	else
		return empty_table
	end
end

local function status_Update(self, dbx)
	self.color = dbx.color1
	if dbx.missing then
		self.aurasMissing = self.aurasMissing or {{}}
		local data = self.dataMissing[1]
		data.icon = self.missingTexture
		data.color = self.color
		data.applications = 0
		data.expirationTime = 0
		data.duration = 0
		self.GetIcons = status_GetIconsMissing
	else
		self.GetIcons = status_GetIcons
	end
end

local statusTypes = { "color", "icon", "icons", "percent", "text" }
local function status_Create(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	if dbx.spellName then dbx.spellName = nil end -- fix possible wrong data in old database
	status.OnUpdate = status_Update -- called from status:UpdateDB()
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
