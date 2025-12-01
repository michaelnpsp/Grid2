if not Grid2.secretsEnabled then return end

local Health = Grid2.statusPrototype:new("health-current")
local Heals = Grid2.statusPrototype:new("heals-incoming")
local MyHeals = Grid2.statusPrototype:new("my-heals-incoming")
local Death = Grid2.statusPrototype:new("death")

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitHealthPercent = UnitHealthPercent
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitGetIncomingHeals = UnitGetIncomingHeals
local AbbreviateLargeNumbers = AbbreviateLargeNumbers
local unit_is_valid = Grid2.roster_guids
local format = string.format
local fmtPercent = "%.0f%%"

-- hackish way to check if a secret value>1
local alphaFrame, alphaSet, pcall = Grid2:GetAlphaFrame()

-- health-current status
local deadAsFullHealth

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
	return format( fmtPercent, (deadAsFullHealth and UnitIsDeadOrGhost(unit) and 100) or UnitHealthPercent(unit, true, true) )
end

function Health:GetPercent(unit)
	if deadAsFullHealth and UnitIsDeadOrGhost(unit) then return 1 end
	return UnitHealthPercent(unit, true, false)
end

function Health:UpdateDB()
	fmtPercent = Grid2.db.profile.formatting.percentFormat
	deadAsFullHealth = self.dbx.deadAsFullHealth
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Health, {"percent", "text", "color"}, baseKey, dbx)
	return Health
end

Grid2.setupFunc["health-current"] = Create

Grid2:DbSetStatusDefaultValue( "health-current", {type = "health-current", color1 = {r=0,g=1,b=0,a=1} } )

-- heals-incoming status
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
	return UnitGetIncomingHeals(unit) or 0, 0, UnitHealthMax(unit)
end

function Heals:GetText(unit)
	return AbbreviateLargeNumbers( UnitGetIncomingHeals(unit) or 0 )
end

function Heals:IsActive(unit)
	return not pcall(alphaSet, alphaFrame, UnitGetIncomingHeals(unit) or 0)
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
	return UnitGetIncomingHeals(unit) or 0, 0, UnitHealthMax(unit)
end

function MyHeals:GetText(unit)
	return AbbreviateLargeNumbers( UnitGetIncomingHeals(unit,'player') or 0 )
end

function MyHeals:IsActive(unit)
	return not pcall(alphaSet, alphaFrame, UnitGetIncomingHeals(unit,'player') or 0)
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
