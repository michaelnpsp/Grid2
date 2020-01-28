-- Group of Debuffs status
local Grid2 = Grid2
local UnitAura = UnitAura
local myUnits = Grid2.roster_my_units
local typeColors = Grid2.debuffTypeColors
local dispelTypes = Grid2.debuffDispelTypes

local emptyTable = {}
local textures = {}
local counts = {}
local expirations = {}
local durations = {}
local colors = {}

-- Called from StatusAura.lua to filter auras

-- All debuffs + white list
local function status_UpdateStateWhiteList(self, unit, name)
	return self.spells[name]
end

-- All debuffs + black list
local function status_UpdateStateBlackList(self, unit, name)
	return not self.spells[name]
end

-- Boss Debuffs filter + black list
local function status_UpdateStateBoss(self, _, name, _, _, boss)
	return boss and (not self.spells[name])
end

-- Filter + black list
local function status_UpdateStateFilter(self, unit, name, duration, caster, boss)
	return ( not self.spells[name] ) and
		   ( self.filterLong  ==nil  or self.filterLong  ~= (duration>=300) ) and
		   ( self.filterBoss  ==nil  or self.filterBoss  ~= boss ) and
		   ( self.filterCaster==nil  or self.filterCaster~= (myUnits[caster]==true) )
end

-- Dispellable debuffs
local status_UpdateStateDispel, InitDispellData
if Grid2.isClassic then
	local dispellable
	InitDispellData = function()
		local class = select(2,UnitClass('player'))
		if class == 'DRUID' then
			dispellable = { Poison = IsPlayerSpell(2893) or IsPlayerSpell(8946), Curse = IsPlayerSpell(2782) }
		elseif class == 'PALADIN' then
			dispellable = { Poison = IsPlayerSpell(4987) or IsPlayerSpell(1152), Disease = IsPlayerSpell(4987) or IsPlayerSpell(1152), Magic = IsPlayerSpell(4987) }
		elseif class == 'PRIEST' then
			dispellable = { Magic = IsPlayerSpell(527), Disease = IsPlayerSpell(552) or IsPlayerSpell(528) }
		elseif class == 'SHAMAN' then
			dispellable = { Disease = IsPlayerSpell(2870), Poison = IsPlayerSpell(526) }
		elseif class == 'MAGE' then
			dispellable = { Curse = IsPlayerSpell(475) }
		elseif class == 'WARLOCK' then
			dispellable = { Magic = true }
		else
			dispellable = {}
		end
		InitDispellData = nil
	end
	status_UpdateStateDispel = function(self, _, _, _, _, _, typ)
		return typ and dispellable[typ]
	end
else
	status_UpdateStateDispel = function(self, unit)
		-- Dispeleable debuffs
		local name, texture, count, debuffType, duration, expiration = UnitAura(unit, 1, 'RAID|HARMFUL')
		if name and dispelTypes[debuffType] then
			if not self.spells[name] then -- check blacklist
				self.idx[unit] = 1
				self.tex[unit] = texture
				self.dur[unit] = duration
				self.exp[unit] = expiration
				self.cnt[unit] = count
				self.typ[unit] = debuffType
				self.tkr[unit] = 1
				self.seen = 1
			end
		elseif self.idx[unit] then
			self:Reset(unit)
			self.seen = 1  -- using 1 we force indicators update to clear the status, but avoiding more StatusAuras calls to this function to check next unit auras.
		else
			self.seen = -1 -- avoid indicators update, status was inactive and must continue inactive
		end
	end
end

-- Called by "icons" indicator
local function status_GetIconsWhiteList(self, unit)
	local i, j, spells = 1, 1, self.spells
	local name, debuffType
	while true do
		name, textures[j], counts[j], debuffType, durations[j], expirations[j] = UnitAura(unit, i, 'HARMFUL')
		if not name then return j-1, textures, counts, expirations, durations, colors end
		if spells[name] then
			colors[j] = typeColors[debuffType] or self.color
			j = j + 1
		end
		i = i + 1
	end
end

local function status_GetIconsBlackList(self, unit)
	local i, j, spells = 1, 1, self.spells
	local name, debuffType
	while true do
		name, textures[j], counts[j], debuffType, durations[j], expirations[j] = UnitAura(unit, i, 'HARMFUL')
		if not name then return j-1, textures, counts, expirations, durations, colors end
		if not spells[name] then
			colors[j] = typeColors[debuffType] or self.color
			j = j + 1
		end
		i = i + 1
	end
end

local function status_GetIconsFilter(self, unit)
	local i, j = 1, 1
	local filterLong, filterBoss, filterCaster, spells = self.filterLong, self.filterBoss, self.filterCaster, self.spells
	local name, debuffType, caster, isBossDebuff, _
	while true do
		name, textures[j], counts[j], debuffType, durations[j], expirations[j], caster, _, _, _, _, isBossDebuff = UnitAura(unit, i, 'HARMFUL')
		if not name then return j-1, textures, counts, expirations, durations, colors end
		local filtered = spells[name] or (filterLong and (durations[j]>=300)==filterLong) or (filterBoss~=nil and filterBoss==isBossDebuff) or (filterCaster~=nil and filterCaster==(caster==unit or myUnits[caster]==true))
		if not filtered then
			colors[j] = typeColors[debuffType] or self.color
			j = j + 1
		end
		i = i + 1
	end
end

local function status_GetIconsDispel(self, unit)
	local i, j, name, debuffType = 1, 1
	while true do
		name, textures[j], counts[j], debuffType, durations[j], expirations[j] = UnitAura(unit, i, "RAID|HARMFUL")
		if not name then return j-1, textures, counts, expirations, durations, colors end
		if dispelTypes[debuffType] then
			colors[j] = typeColors[debuffType]
			j = j + 1
		end
		i = i + 1
	end
end

-- Called by "tooltip" indicator
local function status_GetTooltipDispel(self, unit, tip)
	local index = self.idx[unit]
	if index then
		tip:SetUnitDebuff(unit, index, "RAID")
	end
end

-- Called by status:UpdateDB()
local function status_Update(self, dbx)
	if dbx.filterDispelDebuffs then
		self.GetIcons     = status_GetIconsDispel
		self.GetTooltip   = status_GetTooltipDispel
		self.UpdateState  = status_UpdateStateDispel
	elseif dbx.useWhiteList then
		self.GetIcons 	  = status_GetIconsWhiteList
		self.UpdateState  = status_UpdateStateWhiteList
	else
		self.filterLong   = dbx.filterLongDebuffs
		self.filterBoss   = dbx.filterBossDebuffs
		self.filterCaster = dbx.filterCaster
		if self.filterLong == nil and self.filterBoss == nil and self.filterCaster == nil then
			self.UpdateState  = status_UpdateStateBlackList
			self.GetIcons     = status_GetIconsBlackList
		elseif self.filterBoss==false then
			self.UpdateState  = status_UpdateStateBoss
			self.GetIcons     = status_GetIconsFilter
		else
			self.UpdateState  = status_UpdateStateFilter
			self.GetIcons     = status_GetIconsFilter
		end
	end
	self.spells = self.spells or emptyTable
	self.color  = dbx.color1
end

-- Registration
do
	local statusTypes = { "color", "icon", "icons", "percent", "text", "tooltip" }
	Grid2.setupFunc["debuffs"] = function(baseKey, dbx)
		if Grid2.classicDurations then
			UnitAura = LibStub("LibClassicDurations").UnitAuraDirect
		end
		if InitDispellData then -- dispell data for classic
			InitDispellData()
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
