local Target = Grid2.statusPrototype:new("target")

Target.defaultDB = {
	profile = {
		color1 = { r = .8, g = .8, b = .8, a = 1 },
	}
}

function Target:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterMessage("Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitChanged")
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
	self:UnregisterMessage("Grid_UnitJoined")
	self:UnregisterMessage("Grid_UnitChanged")
end

function Target:IsActive(unitid)
--print("Target:IsActive", unitid, UnitIsUnit(unitid, "target"))
	return UnitIsUnit(unitid, "target")
end
--/dump UnitIsUnit("pet1", "target")

function Target:GetText(unitid)
	return "target"
end

function Target:GetColor(unitid)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

Grid2:RegisterStatus(Target, { "color", "text" })
