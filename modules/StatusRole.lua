local Role = Grid2.statusPrototype:new("role")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")


Role.defaultDB = {
	profile = {
		color1 = { r = 1, g = 1, b = .5, a = 1 },
		color2 = { r = .5, g = 1, b = 1, a = 1 },
	}
}

function Role:UpdateAllUnits(event)
	for guid, unitid in Grid2:IterateRoster() do
		if (UnitExists(unitid)) then
			self:UpdateIndicators(unitid)
		end
	end
end

function Role:UpdateUnit(event, unitid)
	self:UpdateIndicators(unitid)
end

function Role:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllUnits")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateUnit")
	self:RegisterMessage("Grid_UnitJoined", "UpdateUnit")
end

function Role:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	self:UnregisterMessage("Grid_UnitJoined")
end

function Role:IsActive(unitid)
	if (UnitExists(unitid) and not Grid2:UnitIsPet(unitid)) then
		return GetPartyAssignment("MAINASSIST", unitid) or GetPartyAssignment("MAINTANK", unitid)
	end
end

function Role:GetBorder(unitid)
	return 0
end

function Role:GetColor(unitid)
--	if (not Grid2:UnitIsPet(unitid)) then
		local color
		if (GetPartyAssignment("MAINASSIST", unitid)) then
			color = self.db.profile.color1
		elseif (GetPartyAssignment("MAINTANK", unitid)) then
			color = self.db.profile.color2
		else
			return nil
		end
		return color.r, color.g, color.b, color.a
--	end
end


local assistIcon = "Interface\\GroupFrame\\UI-Group-MainAssistIcon"
local tankIcon = "Interface\\GroupFrame\\UI-Group-MainTankIcon"

function Role:GetIcon(unitid)
--	if (UnitExists(unitid)) then
		if (GetPartyAssignment("MAINASSIST", unitid)) then
			return assistIcon
		elseif (GetPartyAssignment("MAINTANK", unitid)) then
			return tankIcon
		else
			return nil
		end
--	end
end


local assistString = MAIN_ASSIST
local tankString = MAIN_TANK
function Role:GetText(unitid)
--	if (UnitExists(unitid)) then
		if (GetPartyAssignment("MAINASSIST", unitid)) then
			return assistString
		elseif (GetPartyAssignment("MAINTANK", unitid)) then
			return tankString
		else
			return nil
		end
--	end
end

Grid2:RegisterStatus(Role, { "color", "icon", "text" })
