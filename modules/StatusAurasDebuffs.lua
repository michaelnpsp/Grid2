-- Group of Debuffs status
local Grid2 = Grid2
local UnitAura = UnitAura
local myUnits = Grid2.roster_my_units
local typeColors = Grid2.debuffTypeColors
local dispelTypes = Grid2.debuffDispelTypes
local playerDispelTypes = Grid2.debuffPlayerDispelTypes

local emptyTable = {}
local textures = {}
local counts = {}
local expirations = {}
local durations = {}
local colors = {}

-- Called from StatusAura.lua to filter auras

-- Compile a filter function
local function CompileUpdateStateFilter(status)
	local t = {}
	if next(status.spells)      then t[#t+1] = string.format( "not self.spells[name]" ) end
	if status.filterLong  ~=nil then t[#t+1] = string.format( "%s (duration>=300)", status.filterLong and 'not' or '') end
	if status.filterBoss  ~=nil then t[#t+1] = string.format( "%s boss",          status.filterBoss and 'not' or '') end
	if status.filterCaster~=nil then t[#t+1] = string.format( "%s (caster=='player' or caster=='pet' or caster=='vehicle')", status.filterCaster and 'not' or '') end
	if status.filterTypes ~=nil then t[#t+1] = string.format( "%s (type=='Typeless')",  status.filterTypes and 'not' or '') end
	local source = "return function(self, unit, name, duration, caster, boss, typ) return " .. table.concat(t,' and ') .. ' end'
	return assert(loadstring(source))()
end

-- All debuffs + white list
local function status_UpdateStateWhiteList(self, unit, name)
	return self.spells[name]
end

-- All debuffs + black list
local function status_UpdateStateBlackList(self, unit, name)
	return not self.spells[name]
end

-- Dispellable by Player debuffs
local function status_UpdateStateDispel(self, _, _, _, _, _, typ)
	return typ and playerDispelTypes[typ]
end
local function status_UpdateStateDispelBlackList (self, _, name, _, _, _, typ)
	return typ and playerDispelTypes[typ] and (not self.spells[name])
end

-- Non Dispellable by Player debuffs
local function status_UpdateStateNonDispel(self, _, _, _, _, _, typ)
	return not (typ and playerDispelTypes[typ])
end
local function status_UpdateStateNonDispelBlackList (self, _, name, _, _, _, typ)
	return not (typ and playerDispelTypes[typ]) and (not self.spells[name])
end

-- Called by "icons" indicator
local function status_GetIconsWhiteList(self, unit, max)
	local i, j, spells, name, debuffType = 1, 1, self.spells
	repeat
		name, textures[j], counts[j], debuffType, durations[j], expirations[j] = UnitAura(unit, i, 'HARMFUL')
		if not name then break end
		if spells[name] then
			colors[j] = typeColors[debuffType] or self.color
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors
end

local function status_GetIconsBlackList(self, unit, max)
	local i, j, spells, name, debuffType = 1, 1, self.spells
	repeat
		name, textures[j], counts[j], debuffType, durations[j], expirations[j] = UnitAura(unit, i, 'HARMFUL')
		if not name then break end
		if not spells[name] then
			colors[j] = typeColors[debuffType] or self.color
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors
end

local function status_GetIconsFilter(self, unit, max)
	local filterLong, filterBoss, filterCaster, filterTyped, spells = self.filterLong, self.filterBoss, self.filterCaster, self.filterTyped, self.spells
	local i, j, name, debuffType, caster, isBossDebuff, _ = 1, 1
	repeat
		name, textures[j], counts[j], debuffType, durations[j], expirations[j], caster, _, _, _, _, isBossDebuff = UnitAura(unit, i, 'HARMFUL')
		if not name then break end
		local filtered = spells[name] or (filterLong~=nil and (durations[j]>=300)==filterLong) or (filterBoss~=nil and filterBoss==isBossDebuff) or (filterCaster~=nil and filterCaster==(caster==unit or myUnits[caster]==true)) or (filterTyped~=nil and filterTyped~=not debuffType )
		if not filtered then
			colors[j] = typeColors[debuffType] or self.color
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors
end

local function status_GetIconsDispel(self, unit, max)
	local i, j, spells, name, debuffType = 1, 1, self.spells
	repeat
		name, textures[j], counts[j], debuffType, durations[j], expirations[j] = UnitAura(unit, i, "RAID|HARMFUL")
		if not name then break end
		if not spells[name] then
			colors[j] = typeColors[debuffType] or self.color
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors
end

local function status_GetIconsNonDispel(self, unit, max)
	local i, j, spells, name, debuffType = 1, 1, self.spells
	repeat
		name, textures[j], counts[j], debuffType, durations[j], expirations[j] = UnitAura(unit, i, "HARMFUL")
		if not name then break end
		if not (debuffType and playerDispelTypes[debuffType]) and not spells[name] then
			colors[j] = typeColors[debuffType] or self.color
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors
end

local function status_GetTooltipDispel(self, unit, tip)
	local index = self.idx[unit]
	if index then
		tip:SetUnitDebuff(unit, index, "RAID")
	end
end

local function status_GetTooltipNonDispel(self, unit, tip)
	local index = self.idx[unit]
	if index then
		tip:SetUnitDebuff(unit, index)
	end
end

-- Called by status:UpdateDB()
local function status_Update(self, dbx)
	self.spells = self.spells or emptyTable
	self.color  = dbx.color1
	if dbx.filterDispelDebuffs==true then
		self.GetIcons     = status_GetIconsDispel
		self.GetTooltip   = status_GetTooltipDispel
		self.UpdateState  = dbx.auras and status_UpdateStateDispelBlackList or status_UpdateStateDispel
	elseif dbx.filterDispelDebuffs==false then
		self.GetIcons     = status_GetIconsNonDispel
		self.GetTooltip   = status_GetTooltipNonDispel
		self.UpdateState  = dbx.auras and status_UpdateStateNonDispelBlackList or status_UpdateStateNonDispel
	elseif dbx.useWhiteList then
		self.GetIcons 	  = status_GetIconsWhiteList
		self.UpdateState  = status_UpdateStateWhiteList
	else
		self.filterLong   = dbx.filterLongDebuffs
		self.filterBoss   = dbx.filterBossDebuffs
		self.filterCaster = dbx.filterCaster
		self.filterTyped  = dbx.filterTyped
		if self.filterLong == nil and self.filterBoss == nil and self.filterTyped ==nil and self.filterCaster == nil then
			self.UpdateState  = status_UpdateStateBlackList
			self.GetIcons     = status_GetIconsBlackList
		else
			self.UpdateState = CompileUpdateStateFilter(self)
			self.GetIcons    = status_GetIconsFilter
		end
	end
end

-- Registration
do
	local statusTypes = { "color", "icon", "icons", "percent", "text", "tooltip" }
	Grid2.setupFunc["debuffs"] = function(baseKey, dbx)
		if Grid2.classicDurations then
			UnitAura = LibStub("LibClassicDurations").UnitAuraDirect
		end
		if dbx.spellName then -- fix possible wrong data in old database
			dbx.spellName = nil
		end
		local status = Grid2.statusPrototype:new(baseKey, false)
		status.OnUpdate = status_Update
		return Grid2.CreateStatusAura(status, basekey, dbx, 'debuff', statusTypes)
	end
end

--[[ status database configuration
	type = "debuffs"
	auras = { "Riptide", 12323, "Earth Shield", ... }
	useWhiteList = true | nil  				-- auras is a whitelist or blacklist
	-- nil=no filter; true=apply filter; false=apply inverted filter
	filterLong   = nil | true | false       -- long debuffs (>5min)
	filterBoss   = nil | true | false       -- boss debuffs
	filterCaster = nil | true | false       -- self casted or casted by me
	-- colors
	debuffTypeColorize = true | nil		-- return the color of the debuffType
	colorThresholdElapsed = true | nil 	-- true = color by elapsed time; nil= color by remaining time
	colorThreshold = { 10, 4, 2 } 	    -- thresholds in seconds to change the color
	colorCount = number
	color1 = { r=1,g=1,b=1,a=1 }
	color2 = { r=1,g=1,b=0,a=1 }
--]]
