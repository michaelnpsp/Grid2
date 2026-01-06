if not Grid2.secretsEnabled then return end

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Health = Grid2.statusPrototype:new("health-current")
local Heals = Grid2.statusPrototype:new("heals-incoming")
local MyHeals = Grid2.statusPrototype:new("my-heals-incoming")
local Death = Grid2.statusPrototype:new("death")
local FeignDeath = Grid2.statusPrototype:new("feign-death")

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthPercent = UnitHealthPercent
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitGetIncomingHeals = UnitGetIncomingHeals
local AbbreviateLargeNumbers = AbbreviateLargeNumbers
local unit_is_valid = Grid2.roster_guids
local format = string.format
local fmtPercent = "%.0f%%"
local ScaleTo100 = CurveConstants.ScaleTo100

-- health-current status
local deadAsFullHealth

Health.colorCurve = C_CurveUtil.CreateColorCurve()
Health.IsActive = Grid2.statusLibrary.IsActive
Health.GetColor  = Grid2.statusLibrary.GetColor

local function HealthChangedEvent(_, unit)
	if unit_is_valid[unit] then
		Health:UpdateIndicators(unit)
	end
end

function Health:OnEnable()
	self:RegisterEvent("UNIT_MAXHEALTH", HealthChangedEvent)
	self:RegisterEvent("UNIT_HEALTH", HealthChangedEvent)
end

function Health:OnDisable()
	self:UnregisterEvent("UNIT_MAXHEALTH")
	self:UnregisterEvent("UNIT_HEALTH")
end

function Health:GetText(unit)
	return UnitExists(unit) and AbbreviateLargeNumbers( UnitHealth(unit) ) or ''
end

function Health:GetPercentText(unit)
	return format( fmtPercent, (deadAsFullHealth and UnitIsDeadOrGhost(unit) and 100) or UnitHealthPercent(unit, true, ScaleTo100) )
end

function Health:GetPercent(unit)
	if deadAsFullHealth and UnitIsDeadOrGhost(unit) then return 1 end
	return UnitHealthPercent(unit, true)
end

function Health:GetColor(unit)
	return UnitHealthPercent(unit, true, self.colorCurve):GetRGB()
end

function Health:UpdateDB()
	fmtPercent = Grid2.db.profile.formatting.percentFormat
	deadAsFullHealth = self.dbx.deadAsFullHealth
    self.colorCurve:ClearPoints()
	self.colorCurve:SetType(Enum.LuaCurveType.Linear)
	self.colorCurve:AddPoint( 0  , self.dbx.color3 )
	self.colorCurve:AddPoint( 0.5, self.dbx.color2 )
	self.colorCurve:AddPoint( 1  , self.dbx.color1 )
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Health, {"percent", "text", "color"}, baseKey, dbx)
	return Health
end

Grid2.setupFunc["health-current"] = Create

Grid2:DbSetStatusDefaultValue( "health-current", {type = "health-current", colorCount=3, color1 = {r=0,g=1,b=0,a=1}, color2 = {r=1,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1} } )

-- heals-incoming status
local HealsCalculator = CreateUnitHealPredictionCalculator()
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction
local GetIncomingHealsForUnit = UnitGetIncomingHeals

local function UnitGetIncomingHealsNoPlayer(unit)
	UnitGetDetailedHealPrediction(unit, "player", HealsCalculator)
	local _, _, incomingHealsFromOthers = HealsCalculator:GetIncomingHeals()
	return incomingHealsFromOthers
end

Heals.IsActive = Grid2.statusLibrary.IsActive
Heals.GetColor = Grid2.statusLibrary.GetColor

function Heals:UNIT_HEAL_PREDICTION(_, unit)
	if unit_is_valid[unit] then
		self:UpdateIndicators(unit)
	end
end

function Heals:OnEnable()
	self:RegisterEvent("UNIT_HEAL_PREDICTION")
end

function Heals:OnDisable()
	self:UnregisterEvent("UNIT_HEAL_PREDICTION")
end

function Heals:GetValueMinMax(unit)
	return GetIncomingHealsForUnit(unit) or 0, 0, UnitHealthMax(unit)
end

function Heals:GetText(unit)
	return AbbreviateLargeNumbers( GetIncomingHealsForUnit(unit) or 0 )
end

function Heals:IsActive(unit)
	return true
end

function Heals:UpdateDB()
	HealsCalculator:SetHealAbsorbMode(self.dbx.includeHealAbsorbs and 0 or 1)
	GetIncomingHealsForUnit = self.dbx.includePlayerHeals and UnitGetIncomingHeals or UnitGetIncomingHealsNoPlayer
end

local function CreateHeals(baseKey, dbx)
	Grid2:RegisterStatus(Heals, {"color", "percent", "text"}, baseKey, dbx)
	return Heals
end

Grid2.setupFunc["heals-incoming"] = CreateHeals

Grid2:DbSetStatusDefaultValue( "heals-incoming", {type = "heals-incoming", color1 = {r=0,g=1,b=0,a=1}})

-- my-heals-incoming status
MyHeals.IsActive = Grid2.statusLibrary.IsActive
MyHeals.GetColor = Grid2.statusLibrary.GetColor

function MyHeals:UNIT_HEAL_PREDICTION(_, unit)
	if unit_is_valid[unit] then
		self:UpdateIndicators(unit)
	end
end

function MyHeals:OnEnable()
	self:RegisterEvent("UNIT_HEAL_PREDICTION")
end

function MyHeals:OnDisable()
	self:UnregisterEvent("UNIT_HEAL_PREDICTION")
end

function MyHeals:GetValueMinMax(unit)
	return UnitGetIncomingHeals(unit,'player') or 0, 0, UnitHealthMax(unit)
end

function MyHeals:GetText(unit)
	return AbbreviateLargeNumbers( UnitGetIncomingHeals(unit,'player') or 0 )
end

function MyHeals:IsActive(unit)
	return true
end

local function CreateMyHeals(baseKey, dbx)
	Grid2:RegisterStatus(MyHeals, {"color", "percent", "text"}, baseKey, dbx)
	return MyHeals
end

Grid2.setupFunc["my-heals-incoming"] = CreateMyHeals

Grid2:DbSetStatusDefaultValue( "my-heals-incoming", {type = "my-heals-incoming", color1 = {r=0,g=1,b=0,a=1}})

-- death status
local dead_cache = Grid2.roster_deads

Death.GetColor = Grid2.statusLibrary.GetColor

function Death:UNIT_HEALTH(_, unit)
	if unit_is_valid[unit] then
		local d = Grid2:UnitIsDeadOrGhost(unit)
		if d ~= dead_cache[unit] then
			dead_cache[unit] = d
			Grid2:SendMessage("Grid_UnitDeadUpdated", unit, d)
		end
	end
end

function Death:Grid_UnitDeadUpdated(_, unit)
	self:UpdateIndicators(unit)
end

function Death:OnEnable()
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterMessage("Grid_UnitDeadUpdated")
end

function Death:OnDisable()
	self:UnregisterEvent("UNIT_HEALTH")
	self:UnregisterMessage("Grid_UnitDeadUpdated")
end

function Death:IsActive(unit)
	if dead_cache[unit] then return true end
end

function Death:GetIcon()
	return [[Interface\TargetingFrame\UI-TargetingFrame-Skull]]
end

function Death:GetPercent(unit)
	return self.dbx.color1.a, dead_cache[unit]
end

function Death:GetText(unit)
	return dead_cache[unit]
end

local function CreateDeath(baseKey, dbx)
	Grid2:RegisterStatus(Death, {"color", "icon", "percent", "text"}, baseKey, dbx)
	return Death
end

Grid2.setupFunc["death"] = CreateDeath

Grid2:DbSetStatusDefaultValue( "death", {type = "death", color1 = {r=1,g=1,b=1,a=1}})

-- feign-death status
local feign_cache = {}

FeignDeath.GetColor = Grid2.statusLibrary.GetColor

function FeignDeath:UNIT_AURA(_, unit)
	if unit_is_valid[unit] then
		local feign = UnitIsFeignDeath(unit)
		if feign~=feign_cache[unit] then
			feign_cache[unit] = feign
			FeignDeath:UpdateIndicators(unit)
		end
	end
end

function FeignDeath:OnEnable()
	self:RegisterEvent("UNIT_AURA")
end

function FeignDeath:OnDisable()
	self:UnregisterEvent("UNIT_AURA")
	wipe(feign_cache)
end

function FeignDeath:IsActive(unit)
	return UnitIsFeignDeath(unit)
end

local feignText = L["FD"]
function FeignDeath:GetText(unit)
	return feignText
end

function FeignDeath:GetPercent(unit)
	return self.dbx.color1.a, feignText
end

local function CreateFeignDeath(baseKey, dbx)
	Grid2:RegisterStatus(FeignDeath, {"color", "percent", "text"}, baseKey, dbx)
	return FeignDeath
end

Grid2.setupFunc["feign-death"] = CreateFeignDeath

Grid2:DbSetStatusDefaultValue( "feign-death", {type = "feign-death", color1 = {r=1,g=.5,b=1,a=1}})
