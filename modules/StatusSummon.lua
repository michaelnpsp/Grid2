local status = Grid2.statusPrototype:new("summon")

local HasIncomingSummon = C_IncomingSummon.HasIncomingSummon
local IncomingSummonStatus = C_IncomingSummon.IncomingSummonStatus

function status:INCOMING_SUMMON_CHANGED(_, unit)
	self:UpdateIndicators(unit)
end

function status:OnEnable()
	self:RegisterEvent("INCOMING_SUMMON_CHANGED")
end

function status:OnDisable()
	self:UnregisterEvent("INCOMING_SUMMON_CHANGED")
end

function status:IsActive(unit)
	return HasIncomingSummon(unit)
end

function status:GetColor(unit)
	local state, color = IncomingSummonStatus(unit)
	if state == 3 then -- declined(3)
		color = self.dbx.color3
	elseif state == 2 then -- accepted(2)
		color = self.dbx.color2
	else -- pending(1)
		color = self.dbx.color1
	end
	return color.r, color.g, color.b, color.a
end

function status:GetIcon(unit)
	return "2470702"
end

function status:GetTexCoord(unit)
	local state = IncomingSummonStatus(unit)
	if state == 3 then -- declined(3)
		return 0.3234375, 0.4734375, 0.115625, 0.415625
	elseif state == 2 then -- accepted(2)
		return 0.0578125, 0.2078125, 0.115625,  0.415625 
	else -- pending(1)
		return 0.5890625, 0.7390625, 0.115625,  0.415625 		
	end
end

Grid2.setupFunc["summon"] = function(baseKey, dbx)
	Grid2:RegisterStatus(status, {"color", "icon"}, baseKey, dbx)
	return status
end

Grid2:DbSetStatusDefaultValue( "summon", {type = "summon", colorCount = 3, color1 = {r=1,g=1,b=0,a=1}, color2 = {r=0,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1} })
