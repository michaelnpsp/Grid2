local Target = Grid2.statusPrototype:new("target")

Target.defaultDB = {
	profile = {
		color1 = { r = .8, g = .8, b = .8, a = 1 },
	}
}

function Target:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function Target:PLAYER_TARGET_CHANGED(_, unit)
	-- potentially costly. May need to use a cache here.
	for guid, unitid in Grid2:IterateRoster() do
		self:UpdateIndicators(unitid)
	end
end

function Target:OnDisable()
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
end

function Target:IsActive(unit)
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
