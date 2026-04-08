-- Heals absorb status, created by Michael

local Shields = Grid2.statusPrototype:new("heal-absorbs")

local Grid2 = Grid2
local tostring = tostring
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local AbbreviateLargeNumbers = AbbreviateLargeNumbers
local TruncateWhenZero = C_StringUtil.TruncateWhenZero

local ShieldsFormat
local ShieldsTruncate
local ShieldsValueMax

Shields.GetColor = Grid2.statusLibrary.GetColor

function Shields:OnEnable()
	self:RegisterRosterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", self.UpdateIndicatorsFromEvent)
end

function Shields:OnDisable()
	self:UnregisterRosterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
end

function Shields:GetText(unit)
	local value = UnitGetTotalHealAbsorbs(unit) or 0
	return ShieldsFormat(value), ShieldsTruncate and value or nil
end

function Shields:GetValueMinMaxCustom(unit)
	return UnitGetTotalHealAbsorbs(unit) or 0, 0, ShieldsValueMax
end

function Shields:GetValueMinMaxHealth(unit)
	return UnitGetTotalHealAbsorbs(unit) or 0, 0, UnitHealthMax(unit)
end

function Shields:IsActive(unit)
	return true
end

function Shields:UpdateDB()
	ShieldsFormat = self.dbx.displayRawNumbers and tostring or AbbreviateLargeNumbers
	ShieldsTruncate = self.dbx.truncateWhenZero
	ShieldsValueMax = self.dbx.maxShieldValue
	self.GetValueMinMax = self.dbx.maxShieldValue and self.GetValueMinMaxCustom or self.GetValueMinMaxHealth
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Shields, { "color", "percent", "text" }, baseKey, dbx)
	return Shields
end

Grid2.setupFunc["heal-absorbs"] = Create

Grid2:DbSetStatusDefaultValue( "heal-absorbs", {type = "heal-absorbs", color1 = {r=1,g=0,b=0,a=1} })
