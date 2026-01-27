if not Grid2.secretsEnabled then return end -- only midnight

-- Shields absorb status, created by Michael

local Grid2 = Grid2
local min   = math.min
local fmt   = string.format
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local AbbreviateLargeNumbers = AbbreviateLargeNumbers
local unit_is_valid = Grid2.roster_guids

-- Shields
local Shields = Grid2.statusPrototype:new("shields")

Shields.GetColor = Grid2.statusLibrary.GetColor

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

function Shields:GetText(unit)
	return AbbreviateLargeNumbers( UnitGetTotalAbsorbs(unit) or 0 )
end

function Shields:GetValueMinMaxCustom(unit)
	return UnitGetTotalAbsorbs(unit) or 0, 0, self.maxShieldValue
end

function Shields:GetValueMinMaxHealth(unit)
	return UnitGetTotalAbsorbs(unit) or 0, 0, UnitHealthMax(unit)
end

function Shields:IsActive()
	return true
end

function Shields:UpdateDB()
	self.maxShieldValue = self.dbx.maxShieldValue
	self.GetValueMinMax = self.maxShieldValue and self.GetValueMinMaxCustom or self.GetValueMinMaxHealth
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Shields, { "color", "percent", "text" }, baseKey, dbx)
	return Shields
end

Grid2.setupFunc["shields"] = Create

Grid2:DbSetStatusDefaultValue( "shields", { type = "shields", color1 = { r=0, g=1, b=0, a=1} } )

-- Shields Overflow
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction
local OverflowCalculator = CreateUnitHealPredictionCalculator()
OverflowCalculator:SetDamageAbsorbClampMode(1) -- missing health

local Overflow = Grid2.statusPrototype:new("shields-overflow")

Overflow.GetColor = Grid2.statusLibrary.GetColor

function Overflow:OnEnable()
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED", "UpdateUnit")
end

function Overflow:OnDisable()
	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:UnregisterEvent("UNIT_MAXHEALTH")
	self:UnregisterEvent("UNIT_HEALTH")
end

function Overflow:UpdateUnit(_, unit)
	if unit_is_valid[unit] then
		self:UpdateIndicators(unit)
	end
end

function Overflow:IsActiveSecret(unit) -- hackish, only used by multibar indicator
	UnitGetDetailedHealPrediction(unit, "player", OverflowCalculator)
	local _, excess = OverflowCalculator:GetDamageAbsorbs()
	return excess
end

function Overflow:IsActive(unit) -- this is wrong, but due to game restrictions we cannot check if overflow exists or not
	return false
end


local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Overflow, { "secret" }, baseKey, dbx)
	return Overflow
end

Grid2.setupFunc["shields-overflow"] = Create

Grid2:DbSetStatusDefaultValue( "shields-overflow", { type = "shields-overflow", color1 = {r=1, g=1, b=1, a=1} } )
