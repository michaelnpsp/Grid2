local Name = Grid2.statusPrototype:new("name")

local UnitName   = UnitName
local strCyr2Lat = Grid2.strCyr2Lat

Name.IsActive = Grid2.statusLibrary.IsActive

local defaultName

local function GetText1(self, unit)
	return UnitName(unit) or (defaultName==1 and unit) or defaultName
end

local function GetText2(self, unit)
	local name = UnitName(unit)
	return (name and strCyr2Lat(name)) or (defaultName==1 and unit) or defaultName
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
	defaultName = self.dbx.defaultName
	Name.GetText = self.dbx.enableTransliterate and GetText2 or GetText1
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Name, {"text","tooltip"}, baseKey, dbx)
	Name:UpdateDB()
	return Name
end

Grid2.setupFunc["name"] = Create

Grid2:DbSetStatusDefaultValue( "name", {type = "name"})
