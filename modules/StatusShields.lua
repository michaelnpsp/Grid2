if not Grid2.secretsEnabled then return end -- only midnight

-- Shields absorb status, created by Michael

local Grid2 = Grid2
local min   = math.min
local fmt   = string.format
local tostring = tostring
local UnitHealthMax = UnitHealthMax
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local AbbreviateLargeNumbers = AbbreviateLargeNumbers
local TruncateWhenZero = C_StringUtil.TruncateWhenZero
local unit_is_valid = Grid2.roster_guids

-- Shields
local Shields = Grid2.statusPrototype:new("shields")

Shields.GetColor = Grid2.statusLibrary.GetColor

function Shields:OnEnable()
	self:RegisterRosterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.UpdateIndicatorsFromEvent)
	self:RegisterRosterUnitEvent("UNIT_MAXHEALTH", self.UpdateIndicatorsFromEvent)
end

function Shields:OnDisable()
	self:UnregisterRosterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:UnregisterRosterUnitEvent("UNIT_MAXHEALTH")
end

function Shields:GetText1(unit)
	return AbbreviateLargeNumbers( UnitGetTotalAbsorbs(unit) or 0 )
end

function Shields:GetText2(unit)
	return tostring( UnitGetTotalAbsorbs(unit) or 0 )
end

function Shields:GetText3(unit)
	return TruncateWhenZero( UnitGetTotalAbsorbs(unit) or 0 )
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
	self.GetText = self.dbx.displayRawNumbers and (self.dbx.truncateWhenZero and self.GetText3 or self.GetText2) or self.GetText1
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
