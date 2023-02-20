local Threat = Grid2.statusPrototype:new("threat")

local Grid2 = Grid2
local UnitExists = UnitExists
local UnitThreatSituation = UnitThreatSituation

local unit_is_valid = Grid2.roster_guids

local colors
local activeValue

function Threat:UpdateUnit(_, unit)
	if unit_is_valid[unit or 0] then -- unit can be nil which is so wtf
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

function Threat:UpdateDB()
	colors      = { self.dbx.color1, self.dbx.color2, self.dbx.color3 }
	activeValue = self.dbx.blinkThreshold and "blink" or true
end

-- 1 = not tanking, higher threat than tank
-- 2 = insecurely tanking.
-- 3 = securely tanking something
function Threat:IsActive(unit)
	local threat = UnitExists(unit) and UnitThreatSituation(unit) or 0 -- hack thanks Potje
	if threat > 0 then
		return activeValue
	end
end

function Threat:GetColor(unit)
	local color = colors[ UnitThreatSituation(unit) ]
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

Grid2:DbSetStatusDefaultValue( "threat", {type = "threat", blinkThreshold = true, colorCount = 3, color1 = {r=1,g=0,b=0,a=1}, color2 = {r=.5,g=1,b=1,a=1}, color3 = {r=1,g=1,b=1,a=1}} )
