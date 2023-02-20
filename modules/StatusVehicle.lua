if Grid2.versionCli<30000 then return end

local Vehicle = Grid2.statusPrototype:new("vehicle")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local UnitName = UnitName
local UnitHasVehicleUI = UnitHasVehicleUI
local pet_of_unit = Grid2.pet_of_unit
local owner_of_unit = Grid2.owner_of_unit

local classcolors

function Vehicle:UpdateUnit(_, unit)
	self:UpdateIndicators(unit)
end

function Vehicle:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllUnits")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdateUnit")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdateUnit")
end

function Vehicle:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
end

function Vehicle:IsActive(unit)
	local owner = owner_of_unit[unit]
	if owner and UnitHasVehicleUI(owner) then
		return true
	else
		return UnitHasVehicleUI(unit)
	end
end

function Vehicle:GetIcon(unit)
	return [[Interface\Vehicles\UI-Vehicles-Raid-Icon]]
end

local text = L["vehicle"]
function Vehicle:GetText(unit)
	local owner = owner_of_unit[unit]
	if owner and UnitHasVehicleUI(owner) then
		return UnitName(owner)
	else
		return text
	end
end

function Vehicle:GetPercent(unit)
	return self.dbx.color1.a, text
end

function Vehicle:GetClassColor(unit)
	local _, class = UnitClass( owner_of_unit[unit] or pet_of_unit[unit] or unit )
	local c = classcolors[class or ''] or self.dbx.color1
	return c.r, c.g, c.b, c.a
end

function Vehicle:UpdateDB()
	classcolors = self.dbx.useClassColors and Grid2:GetStatusByName('classcolor').dbx.colors or nil
	self.GetColor =	classcolors and self.GetClassColor or Grid2.statusLibrary.GetColor
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Vehicle, {"color", "icon", "percent", "text"}, baseKey, dbx)
	return Vehicle
end

Grid2.setupFunc["vehicle"] = Create

Grid2:DbSetStatusDefaultValue( "vehicle", {type = "vehicle", color1 = {r=0,g=1,b=1,a=.75}})
