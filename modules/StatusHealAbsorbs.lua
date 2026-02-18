if not Grid2.secretsEnabled then return end

-- Heals absorb status, created by Michael
if Grid2.versionCli<50000 or not UnitGetTotalHealAbsorbs then return end -- only MoP or retail

local Shields = Grid2.statusPrototype:new("heal-absorbs")

local Grid2 = Grid2
local tostring = tostring
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local AbbreviateLargeNumbers = AbbreviateLargeNumbers
local TruncateWhenZero = C_StringUtil.TruncateWhenZero

Shields.GetColor = Grid2.statusLibrary.GetColor

function Shields:OnEnable()
	self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
end

function Shields:OnDisable()
	self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
end

function Shields:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(_,unit)
	self:UpdateIndicators(unit)
end

function Shields:GetText1(unit)
	return AbbreviateLargeNumbers( UnitGetTotalHealAbsorbs(unit) or 0 )
end

function Shields:GetText2(unit)
	return tostring( UnitGetTotalHealAbsorbs(unit) or 0 )
end

function Shields:GetText3(unit)
	return TruncateWhenZero( UnitGetTotalHealAbsorbs(unit) or 0 )
end

function Shields:GetValueMinMaxCustom(unit)
	return UnitGetTotalHealAbsorbs(unit) or 0, 0, self.maxShieldValue
end

function Shields:GetValueMinMaxHealth(unit)
	return UnitGetTotalHealAbsorbs(unit) or 0, 0, UnitHealthMax(unit)
end

function Shields:IsActive(unit)
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

Grid2.setupFunc["heal-absorbs"] = Create

Grid2:DbSetStatusDefaultValue( "heal-absorbs", {type = "heal-absorbs", color1 = {r=1,g=0,b=0,a=1} })
