if Grid2.isClassic then return end

-- Shields absorb status, created by Michael

local Grid2 = Grid2
local min   = math.min
local fmt   = string.format
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitHealthMax = UnitHealthMax

-- Shields

local Shields = Grid2.statusPrototype:new("shields")

function Shields:OnEnable()
	self:UpdateDB()
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
end

function Shields:OnDisable()
	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
end

function Shields:UNIT_ABSORB_AMOUNT_CHANGED(_,unit)
	self:UpdateIndicators(unit)
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
local unit_is_valid = Grid2.unit_is_valid

Overflow.GetColor = Grid2.statusLibrary.GetColor

function Overflow:OnEnable()
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateUnit")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
	if not Grid2.isWoW90 then self:RegisterEvent("UNIT_HEALTH_FREQUENT", "UpdateUnit") end
	self:RegisterMessage("Grid_UnitUpdated", "UpdateUnit")
end

function Overflow:OnDisable()
	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:UnregisterEvent("UNIT_MAXHEALTH")
	self:UnregisterEvent("UNIT_HEALTH")
	if not Grid2.isWoW90 then self:UnregisterEvent("UNIT_HEALTH_FREQUENT") end
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
