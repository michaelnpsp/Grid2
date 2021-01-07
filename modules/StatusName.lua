local Name = Grid2.statusPrototype:new("name")

local UnitName = UnitName

Name.IsActive = Grid2.statusLibrary.IsActive

local defaultName

function Name:UNIT_NAME_UPDATE(_, unit)
	self:UpdateIndicators(unit)
end

function Name:OnEnable()
	self:RegisterEvent("UNIT_NAME_UPDATE")
end

function Name:OnDisable()
	self:UnregisterEvent("UNIT_NAME_UPDATE")
end

function Name:GetText(unit)
	return UnitName(unit) or (defaultName==1 and unit) or defaultName or ''
end

function Name:GetTooltip(unit,tip)
	tip:SetUnit(unit)
end

function Name:UpdateDB()
	defaultName = self.dbx.defaultName
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Name, {"text","tooltip"}, baseKey, dbx)
	Name:UpdateDB()
	return Name
end

Grid2.setupFunc["name"] = Create

Grid2:DbSetStatusDefaultValue( "name", {type = "name"})
