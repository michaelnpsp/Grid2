local Threat = Grid2.statusPrototype:new("threat")


Threat.defaultDB = {
	profile = {
		color1 = { r = 1, g = 0, b = 0, a = 1 },
		color2 = { r = .5, g = 1, b = 1, a = 1 },
		color3 = { r = 1, g = 1, b = 1, a = 1 },
	}
}

function Threat:UpdateUnit(event, unitid)
	-- unitid can be nil which is so wtf
	if (unitid) then
		self:UpdateIndicators(unitid)
	end
end

function Threat:UpdateAllUnits()
	for guid, unitid in Grid2:IterateRoster() do
		self:UpdateIndicators(unitid)
	end
end

function Threat:OnEnable()
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", "UpdateUnit")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateAllUnits")
end

function Threat:OnDisable()
	self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end

-- 1 = not tanking, higher threat than tank
-- 2 = insecurely tanking.
-- 3 = securely tanking something
function Threat:IsActive(unitid)
	local threat = unitid and UnitThreatSituation(unitid)
	if (threat and threat > 0) then
		return "blink"
	end
end

function Threat:GetColor(unitid)
	local color
	local threat = UnitThreatSituation(unitid)
--	return (GetThreatStatusColor(threat))
---[[
	if (threat == 1) then
		color = self.db.profile.color1
	elseif (threat == 2) then
		color = self.db.profile.color2
	elseif (threat == 3) then
		color = self.db.profile.color3
	end

	return color.r, color.g, color.b, color.a
--]]
end

function Threat:GetIcon(unitid)
	return [[Interface\RaidFrame\UI-RaidFrame-Threat]]
end

Grid2:RegisterStatus(Threat, { "color", "icon" })
