local Target = Grid2.statusPrototype:new("target")

Target.defaultDB = {
	profile = {
		color1 = { r = .8, g = .8, b = .8, a = 1 },
	}
}

function Target:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("Grid_UnitJoined")
	self:RegisterEvent("Grid_UnitChanged")
end

function Target:PLAYER_TARGET_CHANGED(event)
	for guid, unitid in Grid2:IterateRoster() do
		self:UpdateIndicators(unitid)
	end
end

function Target:Grid_UnitJoined(_, unitid, guid)
	return self:UpdateIndicators(unitid)
end

function Target:Grid_UnitChanged(_, unitid, guid)
	return self:UpdateIndicators(unitid)
end

function Target:OnDisable()
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	self:UnregisterEvent("Grid_UnitJoined")
	self:UnregisterEvent("Grid_UnitChanged")
end

function Target:IsActive(unit)
--print("Target:IsActive", unit, UnitIsUnit(unit, "target"))
	return UnitIsUnit(unit, "target")
end

function Target:GetText(unit)
	return "target"
end

function Target:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

Grid2:RegisterStatus(Target, { "color", "text" })
