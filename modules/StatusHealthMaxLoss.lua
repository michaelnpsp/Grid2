-- Health Max loss status, created by Michael

local HealthMaxLoss = Grid2.statusPrototype:new("health-max-loss")

local Grid2 = Grid2
local GetUnitTotalModifiedMaxHealthPercent = GetUnitTotalModifiedMaxHealthPercent

HealthMaxLoss.GetColor = Grid2.statusLibrary.GetColor

function HealthMaxLoss:OnEnable()
	self:RegisterRosterUnitEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED", self.UpdateIndicatorsFromEvent)
end

function HealthMaxLoss:OnDisable()
	self:UnregisterRosterUnitEvent("UNIT_MAX_HEALTH_MODIFIERS_CHANGED")
end

function HealthMaxLoss:GetPercent(unit)
	return GetUnitTotalModifiedMaxHealthPercent(unit)
end

function HealthMaxLoss:IsActive(unit)
	return true
end

function HealthMaxLoss:UpdateDB()
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(HealthMaxLoss, {"percent"}, baseKey, dbx)
	return HealthMaxLoss
end

Grid2.setupFunc["health-max-loss"] = Create

Grid2:DbSetStatusDefaultValue( "health-max-loss", {type = "health-max-loss", color1 = {r=1,g=0,b=0,a=1} })
