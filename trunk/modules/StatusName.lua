local Name = Grid2.statusPrototype:new("name")

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

function Name:GetTextDefault(unit)
	return UnitName(unit)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Name, {"text"}, baseKey, dbx)
	Grid2:MakeTextHandler(Name)

	return Name
end

Grid2.setupFunc["name"] = Create
