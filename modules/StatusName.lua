local Name = Grid2.statusPrototype:new("name")

function Name:OnEnable()
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterMessage("Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitChanged")
end

function Name:UNIT_NAME_UPDATE(_, unitid)
	return self:UpdateIndicators(unitid)
end

function Name:Grid_UnitJoined(_, unitid, guid)
	return self:UpdateIndicators(unitid)
end

function Name:Grid_UnitChanged(_, unitid, guid)
	return self:UpdateIndicators(unitid)
end

function Name:OnDisable()
	self:UnregisterEvent("UNIT_NAME_UPDATE")
	self:UnregisterMessage("Grid_UnitJoined")
	self:UnregisterMessage("Grid_UnitChanged")
end

function Name:IsActive(unit)
	return true
end

function Name:GetText(unit)
	return UnitName(unit)
end

Grid2:RegisterStatus(Name, { "text" })
