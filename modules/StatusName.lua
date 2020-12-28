local Name = Grid2.statusPrototype:new("name")

local unit_names = { target = 'target', focus = 'focus', boss1= 'boss1', boss2= 'boss2', boss3= 'boss3', boss4= 'boss4', boss5= 'boss5', party1 = 'party1', party2= 'party2', party3= 'party3', party4= 'party5' }

local UnitName = UnitName

Name.IsActive = Grid2.statusLibrary.IsActive

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
	return UnitName(unit) or unit_names[unit]
end

function Name:GetTooltip(unit,tip)
	tip:SetUnit(unit)
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Name, {"text","tooltip"}, baseKey, dbx)

	return Name
end

Grid2.setupFunc["name"] = Create

Grid2:DbSetStatusDefaultValue( "name", {type = "name"})
