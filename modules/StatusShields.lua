if Grid2.versionCli<40000 then return end -- only cataclysm or retail

-- Shields absorb status, created by Michael

local Grid2 = Grid2
local min   = math.min
local fmt   = string.format
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local unit_is_valid = Grid2.roster_guids

-- Shields
local Shields = Grid2.statusPrototype:new("shields")

function Shields:OnEnable()
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateUnit")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
end

function Shields:OnDisable()
	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:UnregisterEvent("UNIT_MAXHEALTH")
end

function Shields:UpdateUnit(_,unit)
	if unit_is_valid[unit] then
		self:UpdateIndicators(unit)
	end
end

function Shields:GetColor(unit)
	local c
	local amount = UnitGetTotalAbsorbs(unit) or 0
	local dbx = self.dbx
	if amount > dbx.thresholdMedium then
		c = dbx.color1
	elseif amount > dbx.thresholdLow then
		c = dbx.color2
	else
		c = dbx.color3
	end
	return c.r, c.g, c.b, c.a
end

function Shields:GetText(unit)
	return fmt("%.1fk", (UnitGetTotalAbsorbs(unit) or 0) / 1000 )
end

-- Using a user defined max shield value (used by bar indicators)
local function GetPercentCustomMax(self, unit)
	return (UnitGetTotalAbsorbs(unit) or 0) / self.maxShieldValue
end
-- Use unit maximum health as max shield value (used by bar indicators)
local function GetPercentHealthMax(_, unit)
	local m = UnitHealthMax(unit)
	return m>0 and (UnitGetTotalAbsorbs(unit) or 0) / m  or 0
end

local function IsActiveNormal(_, unit)
	return (UnitGetTotalAbsorbs(unit) or 0)>0
end

local function IsActiveBLink(self, unit)
	local value = UnitGetTotalAbsorbs(unit) or 0
	if value>0 then
		if value>self.blinkThreshold then
			return true
		else
			return "blink"
		end
	end
end

function Shields:UpdateDB()
	self.maxShieldValue = self.dbx.maxShieldValue
	self.blinkThreshold = self.dbx.blinkThreshold
	self.GetPercent     = self.maxShieldValue and GetPercentCustomMax or GetPercentHealthMax
	self.IsActive       = self.blinkThreshold and IsActiveBLink or IsActiveNormal
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Shields, { "color", "percent", "text" }, baseKey, dbx)
	return Shields
end

Grid2.setupFunc["shields"] = Create

Grid2:DbSetStatusDefaultValue( "shields", { type = "shields", thresholdMedium = 50000, thresholdLow = 25000,  colorCount = 3,
	color1 = { r = 0, g = 1,   b = 0, a=1 },
	color2 = { r = 1, g = 0.5, b = 0, a=1 },
	color3 = { r = 1, g = 1,   b = 0, a=1 },
} )

-- Shields Overflow

local Overflow = Grid2.statusPrototype:new("shields-overflow")

local overflow_cache = {}

Overflow.GetColor = Grid2.statusLibrary.GetColor

function Overflow:OnEnable()
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateUnit")
	self:RegisterMessage("Grid_UnitUpdated", "UpdateUnit")
end

function Overflow:OnDisable()
	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:UnregisterEvent("UNIT_MAXHEALTH")
	self:UnregisterEvent("UNIT_HEALTH")
	self:UnregisterMessage("Grid_UnitUpdated")
end

function Overflow:UpdateUnit(event, unit)
	if unit_is_valid[unit] then
		local v = UnitHealth(unit) + (UnitGetTotalAbsorbs(unit) or 0)
		local m = UnitHealthMax(unit)
		overflow_cache[unit] = v>m and (v-m)/m or nil
		if event~='Grid_UnitUpdated' then self:UpdateIndicators(unit) end
	end
end

function Overflow:GetPercent(unit)
	return overflow_cache[unit]
end

function Overflow:IsActive(unit)
	return overflow_cache[unit]~=nil
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Overflow, { "color", "percent" }, baseKey, dbx)
	return Overflow
end

Grid2.setupFunc["shields-overflow"] = Create

Grid2:DbSetStatusDefaultValue( "shields-overflow", { type = "shields-overflow", color1 = {r=1, g=1, b=1, a=1} } )

-- Cataclysm classic, implementation of missing UnitGetTotalAbsorbs()
if not Grid2.isCata then return end

local next  = next
local CalcUnitShield
local FireEvent = Grid2.Health_FireEvent
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local shield_units = Grid2.roster_guids
local shield_statuses = {}
local shield_cache = setmetatable( {}, { __index = function(t,u) t[u]=CalcUnitShield(u); return t[u]; end } )
local shield_spells = {
	[1463]  = 1, -- Mana Shield (Mage)
	[11426] = 1, -- Ice Barrier (Mage)
	[17]    = 1, -- Power Word: Shield (Priest)
	[47753] = 1, -- Divine Aegis (Priest)
	[86273] = 1, -- Iluminated Healing (Paladin)
	-- [77535] = 1, -- Blood Shield (DK)
}

function UnitGetTotalAbsorbs(unit) -- overriding UnitGetTotalAbsorbs() function
	return shield_cache[unit]
end
Grid2.Health_RegisterAbsorbsFunction(UnitGetTotalAbsorbs) -- Needed by health-current status

function CalcUnitShield(unit)
	local shield_value = 0
	for i=1,40 do
		local data = GetAuraDataByIndex(unit, i, 'HELPFUL')
		if not data then break end
		if shield_spells[data.spellId] then shield_value = shield_value + data.points[1] end
	end
	return shield_value
end

function Shields:UNIT_AURA(_, unit)
	if shield_units[unit] then
		local shield_value = CalcUnitShield(unit)
		if shield_value~=shield_cache[unit] then
			shield_cache[unit] = shield_value
			if Shields.enabled then
				Shields:UpdateIndicators(unit)
			end
			if Overflow.enabled then
				Overflow:UpdateUnit(nil, unit)
			end
			FireEvent('UNIT_ABSORB_AMOUNT_CHANGED',unit)
		end
	end
end

function Shields:ClearUnit(_,unit)
	shield_cache[unit] = nil
end

function Shields:OnEnable()
	if not next(shield_statuses) then -- do not change, must be Shields: (not self)
		Shields:RegisterEvent("UNIT_AURA")
		Shields:RegisterMessage("Grid_UnitUpdated", "ClearUnit")
	end
	shield_statuses[self] = true
	self:RegisterEvent("UNIT_MAXHEALTH","UpdateUnit")
end

function Shields:OnDisable()
	shield_statuses[self] = nil
	if not next(shield_statuses) then -- do not change, must be Shields: (not self)
		Shields:UnregisterEvent("UNIT_AURA")
		Shields:UnregisterMessage("ClearUnit")
		wipe(shield_cache)
	end
	self:UnregisterEvent("UNIT_MAXHEALTH")
end

function Overflow:OnEnable()
	Shields.OnEnable(self)
	self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_HEALTH_FREQUENT", "UpdateUnit")
	self:RegisterMessage("Grid_UnitUpdated", "UpdateUnit")
end

function Overflow:OnDisable()
	Shields.OnDisable(self)
	self:UnregisterEvent("UNIT_HEALTH")
	self:UnregisterEvent("UNIT_HEALTH_FREQUENT")
	self:UnregisterMessage("Grid_UnitUpdated")
end
