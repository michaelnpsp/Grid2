local Name = Grid2.statusPrototype:new("name")

local UnitName   = UnitName
local UnitHasVehicleUI = UnitHasVehicleUI or Grid2.Dummy
local strCyr2Lat = Grid2.strCyr2Lat
local owner_of_unit = Grid2.owner_of_unit

Name.IsActive = Grid2.statusLibrary.IsActive

local defaultName
local displayPetOwner
local displayVehicleOwner
local GetTextNoPet

local function GetText1(self, unit)
	return UnitName(unit) or (defaultName==1 and unit) or defaultName
end

local function GetText2(self, unit)
	local name = UnitName(unit)
	return (name and strCyr2Lat(name)) or (defaultName==1 and unit) or defaultName
end

local function GetText3(self,unit)
	local owner = owner_of_unit[unit]
	if owner and (displayPetOwner or (displayVehicleOwner and UnitHasVehicleUI(owner))) then
		unit = owner
	end
	return GetTextNoPet(self,unit)
end

function Name:UNIT_NAME_UPDATE(_, unit)
	self:UpdateIndicators(unit)
end

function Name:OnEnable()
	self:RegisterEvent("UNIT_NAME_UPDATE")
end

function Name:OnDisable()
	self:UnregisterEvent("UNIT_NAME_UPDATE")
end

function Name:GetTooltip(unit,tip)
	tip:SetUnit(unit)
end

function Name:UpdateDB()
	local dbx = self.dbx
	defaultName = dbx.defaultName
	GetTextNoPet = dbx.enableTransliterate and GetText2 or GetText1
	displayPetOwner = dbx.displayPetOwner
	displayVehicleOwner = dbx.displayVehicleOwner
	Name.GetText = (displayPetOwner or displayVehicleOwner) and GetText3 or GetTextNoPet
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Name, {"text","tooltip"}, baseKey, dbx)
	return Name
end

Grid2.setupFunc["name"] = Create

Grid2:DbSetStatusDefaultValue( "name", {type = "name"})
