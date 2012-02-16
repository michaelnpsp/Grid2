local Name = Grid2.statusPrototype:new("name")

local UnitName = UnitName

function Name:OnEnable()
	self:RegisterEvent("UNIT_NAME_UPDATE")
end

function Name:UNIT_NAME_UPDATE(_, unit)
	return self:UpdateIndicators(unit)
end

function Name:OnDisable()
	self:UnregisterEvent("UNIT_NAME_UPDATE")
end

function Name:IsActive(unit)
	return true
end

function Name:GetText(unit)
	return UnitName(unit)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Name, {"text"}, baseKey, dbx)

	return Name
end

Grid2.setupFunc["name"] = Create

Grid2:DbSetStatusDefaultValue( "name", {type = "name"})
