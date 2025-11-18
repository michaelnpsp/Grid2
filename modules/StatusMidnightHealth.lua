if not Grid2.secretsEnabled then return end

local Health = Grid2.statusPrototype:new("health-current")

local AbbreviateLargeNumbers = AbbreviateLargeNumbers
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthPercent = UnitHealthPercent
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

Health.IsActive = Grid2.statusLibrary.IsActive
Health.GetColor  = Grid2.statusLibrary.GetColor

local function HealthChangedEvent(_, unit)
	Health:UpdateIndicators(unit)
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
	return AbbreviateLargeNumbers( UnitHealth(unit) )
end

local function HealthCurrent_GetPercentDFH(self, unit)
	if UnitIsDeadOrGhost(unit) then return 1 end
	return UnitHealthPercent(unit, false, false)
end

local function HealthCurrent_GetPercentSTD(self, unit)
	return UnitHealthPercent(unit, false, false)
end

function Health:UpdateDB()
	self.GetPercent = self.dbx.deadAsFullHealth and HealthCurrent_GetPercentDFH or HealthCurrent_GetPercentSTD
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Health, {"percent", "text", "color"}, baseKey, dbx)
	return Health
end

Grid2.setupFunc["health-current"] = Create

Grid2:DbSetStatusDefaultValue( "health-current", {type = "health-current", color1 = {r=0,g=1,b=0,a=1} } )
