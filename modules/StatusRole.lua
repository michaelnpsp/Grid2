local Role = Grid2.statusPrototype:new("role")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")


Role.defaultDB = {
	profile = {
		color1 = { r = 1, g = 1, b = .5, a = 1 },
		color2 = { r = .5, g = 1, b = 1, a = 1 },
	}
}

local raid_indexes = {}
for i = 1, 40 do
	raid_indexes["raid"..i] = i
end

local role_cache = {}
function Role:_GetUnitRole(unit)
	if not UnitExists(unit) then return end
	if Grid2:UnitIsParty(unit) then
		if GetPartyAssignment("MAINTANK", unit) then
			return "MAINTANK"
		elseif GetPartyAssignment("MAINASSIST", unit) then
			return "MAINASSIST"
		end
	else
		local index = raid_indexes[unit]
		if index then return select(10, GetRaidRosterInfo(index)) end
	end
end

function Role:UpdateAllUnits(event)
	for guid, unitid in Grid2:IterateRoster() do
		if (UnitExists(unitid)) then
			local prev = role_cache[unitid]
			local new = self:_GetUnitRole(unitid)
			if new ~= prev then
				role_cache[unitid] = new
				self:UpdateIndicators(unitid)
			end
		end
	end
end

function Role:Grid_UnitLeft(_, unitid)
	role_cache[unitid] = nil
end

function Role:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllUnits")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateAllUnits")
	self:RegisterMessage("Grid_UnitLeft")
end

function Role:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	self:UnregisterMessage("Grid_UnitLeft")
end

function Role:IsActive(unitid)
	return role_cache[unitid]
end

function Role:GetBorder(unitid)
	return 0
end

function Role:GetColor(unitid)
	local color
	local role = role_cache[unitid]
	if role == "MAINASSIST" then
		color = self.db.profile.color1
	elseif role == "MAINTANK" then
		color = self.db.profile.color2
	else
		return nil
	end
	return color.r, color.g, color.b, color.a
end

function Role:GetIcon(unitid)
	local role = role_cache[unitid]
	if role == "MAINASSIST" then
		return "Interface\\GroupFrame\\UI-Group-MainAssistIcon"
	elseif role == "MAINTANK" then
		return "Interface\\GroupFrame\\UI-Group-MainTankIcon"
	end
end

local assistString = MAIN_ASSIST
local tankString = MAIN_TANK
function Role:GetText(unitid)
	local role = role_cache[unitid]
	if role == "MAINASSIST" then
		return assistString
	elseif role == "MAINTANK" then
		return tankString
	end
end

Grid2:RegisterStatus(Role, { "color", "icon", "text" })
