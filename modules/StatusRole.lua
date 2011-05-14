local Role = Grid2.statusPrototype:new("role")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2= Grid2
local GetRaidRosterInfo= GetRaidRosterInfo
local MAIN_TANK = MAIN_TANK
local MAIN_ASSIST = MAIN_ASSIST

local raid_indexes = {}
for i = 1, 40 do
	raid_indexes["raid"..i] = i
end

local role_cache = {}

local function GetRaidUnitRole(unit)
	local index = raid_indexes[unit]
	if index then 
		return select(10, GetRaidRosterInfo(index)) 
	end
end

local function GetPartyUnitRole(unit)
	if GetPartyAssignment("MAINTANK", unit) then
		return "MAINTANK"
	elseif GetPartyAssignment("MAINASSIST", unit) then
		return "MAINASSIST"
	end
end

function Role:UpdateAllUnits(event)
	local GetUnitRole= Grid2:UnitIsParty(Grid2:IterateRosterUnits()) and GetPartyUnitRole or GetRaidUnitRole
	for unit, _ in Grid2:IterateRosterUnits() do
		local prev = role_cache[unit]
		local new = GetUnitRole(unit)
		if new ~= prev then
			role_cache[unit] = new
			self:UpdateIndicators(unit)
		end
	end
end

function Role:Grid_UnitLeft(_, unit)
	role_cache[unit] = nil
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
		color = self.dbx.color1
	elseif role == "MAINTANK" then
		color = self.dbx.color2
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

function Role:GetText(unitid)
	local role = role_cache[unitid]
	if role == "MAINASSIST" then
		return MAIN_ASSIST
	elseif role == "MAINTANK" then
		return MAIN_TANK
	end
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Role, {"color", "icon", "text"}, baseKey, dbx)

	return Role
end

Grid2.setupFunc["role"] = Create
