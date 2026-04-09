-- Shields absorb status, created by Michael
local Grid2 = Grid2

-- Shields
local Shields = Grid2.statusPrototype:new("shields")

local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs

local ShieldsFormat
local ShieldsTruncate
local ShieldsValueMax

Shields.GetColor = Grid2.statusLibrary.GetColor

function Shields:OnEnable()
	self:RegisterRosterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.UpdateIndicatorsFromEvent)
	self:RegisterRosterUnitEvent("UNIT_MAXHEALTH", self.UpdateIndicatorsFromEvent)
end

function Shields:OnDisable()
	self:UnregisterRosterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:UnregisterRosterUnitEvent("UNIT_MAXHEALTH")
end

function Shields:GetText(unit)
	local value = UnitGetTotalAbsorbs(unit) or 0
	return ShieldsFormat(value), ShieldsTruncate and value or nil
end

function Shields:GetValueMinMaxCustom(unit)
	return UnitGetTotalAbsorbs(unit) or 0, 0, ShieldsValueMax
end

function Shields:GetValueMinMaxHealth(unit)
	return UnitGetTotalAbsorbs(unit) or 0, 0, UnitHealthMax(unit)
end

function Shields:IsActive()
	return true
end

function Shields:UpdateDB()
	self.maxShieldValue = self.dbx.maxShieldValue
	ShieldsFormat = self.dbx.displayRawNumbers and tostring or AbbreviateLargeNumbers
	ShieldsTruncate = self.dbx.truncateWhenZero
	ShieldsValueMax = self.dbx.maxShieldValue
	self.GetValueMinMax = self.dbx.maxShieldValue and self.GetValueMinMaxCustom or self.GetValueMinMaxHealth
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

function Overflow:GetPercent() -- to avoid crash on old profiles using overflow status linked to bars
	return 0
end

function Overflow:OnEnable()
	self:RegisterRosterUnitEvent("UNIT_HEALTH", self.UpdateIndicatorsFromEvent)
	self:RegisterRosterUnitEvent("UNIT_MAXHEALTH", self.UpdateIndicatorsFromEvent)
	self:RegisterRosterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.UpdateIndicatorsFromEvent)
end

function Overflow:OnDisable()
	self:UnregisterRosterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:UnregisterRosterUnitEvent("UNIT_MAXHEALTH")
	self:UnregisterRosterUnitEvent("UNIT_HEALTH")
end

function Overflow:IsActive(unit) -- hackish, only used by multibar indicator
	UnitGetDetailedHealPrediction(unit, "player", OverflowCalculator)
	local _, excess = OverflowCalculator:GetDamageAbsorbs()
	return excess
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Overflow, { "color" }, baseKey, dbx)
	return Overflow
end

Grid2.setupFunc["shields-overflow"] = Create

Grid2:DbSetStatusDefaultValue( "shields-overflow", { type = "shields-overflow", color1 = {r=1, g=1, b=1, a=1} } )
