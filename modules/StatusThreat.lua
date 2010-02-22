local Threat = Grid2.statusPrototype:new("threat")


function Threat:UpdateUnit(event, unit)
	-- unit can be nil which is so wtf
	if (unit) then
		self:UpdateIndicators(unit)
	end
end

function Threat:UpdateAllUnits()
	for unit, guid in Grid2:IterateRosterUnits() do
		self:UpdateIndicators(unit)
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
function Threat:IsActive(unit)
	local threat = unit and UnitThreatSituation(unit)
	if (threat and threat > 0) then
		return "blink"
	end
end

function Threat:GetColor(unit)
	local color
	local threat = UnitThreatSituation(unit)

	if (threat == 1) then
		color = self.dbx.color1
	elseif (threat == 2) then
		color = self.dbx.color2
	elseif (threat == 3) then
		color = self.dbx.color3
	end

	return color.r, color.g, color.b, color.a
end

function Threat:GetIcon(unit)
	return [[Interface\RaidFrame\UI-RaidFrame-Threat]]
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Threat, {"color", "icon"}, baseKey, dbx)

	return Threat
end

Grid2.setupFunc["threat"] = Create

