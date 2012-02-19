local Role = Grid2.statusPrototype:new("role")
local Leader = Grid2.statusPrototype:new("leader")
local Assistant = Grid2.statusPrototype:new("raid-assistant")
local MasterLooter = Grid2.statusPrototype:new("master-looter")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local UnitExists = UnitExists
local GetRaidRosterInfo = GetRaidRosterInfo
local GetPartyAssignment = GetPartyAssignment
local UnitIsPartyLeader = UnitIsPartyLeader
local MAIN_TANK = MAIN_TANK
local MAIN_ASSIST = MAIN_ASSIST

-- Role (maintank/mainassist) status

local role_cache = {}

function Role:UpdatePartyUnits(event)
	for i=1,5 do
		local unit = Grid2.party_units[i]
		if not UnitExists(unit) then break end
		local role = (GetPartyAssignment("MAINTANK", unit)   and "MAINTANK")   or
					 (GetPartyAssignment("MAINASSIST", unit) and "MAINASSIST") or nil
		if role ~= role_cache[unit] then
			role_cache[unit] = role
			if event then self:UpdateIndicators(unit) end
		end
	end
end

function Role:UpdateRaidUnits(event)
	local units = Grid2.raid_units
	for i=1,40 do
		local name,_,_,_,_,_,_,_,_,role = GetRaidRosterInfo(i)
		if not name then break end
		local unit = units[i]
		if role ~= role_cache[unit] then
			role_cache[unit] = role
			if event then self:UpdateIndicators(unit) end
		end
	end
end

function Role:UpdateAllUnits(event)
	if GetNumRaidMembers()==0 then
		self:UpdatePartyUnits(event)
	else
		self:UpdateRaidUnits(event)
	end
end

function Role:Grid_UnitLeft(_, unit)
	role_cache[unit] = nil
end

function Role:OnEnable()
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateAllUnits")
	self:RegisterMessage("Grid_UnitLeft")
	self:UpdateAllUnits()
end

function Role:OnDisable()
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	self:UnregisterMessage("Grid_UnitLeft")
	wipe(role_cache)
end

function Role:IsActive(unit)
	return role_cache[unit]
end

function Role:GetColor(unit)
	local c
	local role = role_cache[unit]
	if role == "MAINASSIST" then
		c = self.dbx.color1
	elseif role == "MAINTANK" then
		c = self.dbx.color2
	else
		return
	end
	return c.r, c.g, c.b, c.a
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

local function CreateRole(baseKey, dbx)
	Grid2:RegisterStatus(Role, {"color", "icon", "text"}, baseKey, dbx)
	return Role
end

Grid2.setupFunc["role"] = CreateRole

Grid2:DbSetStatusDefaultValue( "role", {type = "role", colorCount = 2, color1 = {r=1,g=1,b=.5,a=1}, color2 = {r=.5,g=1,b=1,a=1}})

-- Assistant status

local assis_cache = {}

function Assistant:UpdateAllUnits(event)
	if GetNumRaidMembers() == 0 then return end
	local units = Grid2.raid_units
	for i=1,40 do
		local name,rank = GetRaidRosterInfo(i)
		if not name then break end
		local assis = rank==1 or nil
		local unit  = units[i]
		if assis ~= assis_cache[unit] then
			assis_cache[unit] = assis
			if event then self:UpdateIndicators(unit) end
		end
	end
end

function Assistant:Grid_UnitLeft(_, unit)
	assis_cache[unit] = nil
end

function Assistant:OnEnable()
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateAllUnits")
	self:RegisterMessage("Grid_UnitLeft")
	self:UpdateAllUnits()
end

function Assistant:OnDisable()
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	self:UnregisterMessage("Grid_UnitLeft")
	wipe(assis_cache)
end

function Assistant:IsActive(unit)
	return assis_cache[unit]
end

function Assistant:GetIcon(unit)
	return "Interface\\GroupFrame\\UI-Group-AssistantIcon"
end

local assistantText = L["RA"]
function Assistant:GetText(unit)
	return assistantText
end

Assistant.GetColor = Grid2.statusLibrary.GetColor

local function CreateAssistant(baseKey, dbx)
	Grid2:RegisterStatus(Assistant, {"color", "icon", "text"}, baseKey, dbx)
	return Assistant
end

Grid2.setupFunc["raid-assistant"] = CreateAssistant

Grid2:DbSetStatusDefaultValue( "raid-assistant", { type = "raid-assistant", color1 = {r=1,g=.25,b=.2,a=1}} )

-- Party/Raid Leader status

local raidLeader

function Leader:UpdateLeader()
	local prevLeader = raidLeader
	self:CalculateLeader()
	if raidLeader ~= prevLeader then
		if prevLeader  then self:UpdateIndicators(prevLeader) end
		if raidLeader  then self:UpdateIndicators(raidLeader) end
	end
end

function Leader:CalculateLeader()
	for unit in Grid2:IterateRosterUnits() do
		if UnitIsPartyLeader(unit) then
			raidLeader = unit
			return
		end
	end
	raidLeader = nil
end

function Leader:OnEnable()
	self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateLeader")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateLeader")
	self:CalculateLeader()
end

function Leader:OnDisable()
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	raidLeader = nil
end

function Leader:IsActive(unit)
	return unit == raidLeader
end

function Leader:GetIcon(unit)
	return "Interface\\GroupFrame\\UI-Group-LeaderIcon"
end

local leaderText= L["RL"]
function Leader:GetText(unit)
	return leaderText
end

Leader.GetColor = Grid2.statusLibrary.GetColor

local function CreateLeader(baseKey, dbx)
	Grid2:RegisterStatus(Leader, {"color", "icon", "text"}, baseKey, dbx)
	return Leader
end

Grid2.setupFunc["leader"] = CreateLeader

Grid2:DbSetStatusDefaultValue( "leader", { type = "leader", color1 = {r=0,g=.7,b=1,a=1}} )

-- Master looter status

local masterLooter

function MasterLooter:UpdateMasterLooter()
	local prevMaster = masterLooter
	self:CalculateMasterLooter()
	if masterLooter ~= prevMaster then
		if prevMaster   then self:UpdateIndicators(prevMaster) end
		if masterLooter then self:UpdateIndicators(masterLooter) end
	end
end

function MasterLooter:CalculateMasterLooter()
	local method, party, raid = GetLootMethod()
	if method == "master" then
		if raid then
			masterLooter = Grid2.raid_units[raid]
		elseif party then
			masterLooter = Grid2.party_units[party+1]
		end	
	else
		masterLooter = nil
	end 
end

function MasterLooter:OnEnable()
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", "UpdateMasterLooter")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "UpdateMasterLooter")
	self:CalculateMasterLooter()
end

function MasterLooter:OnDisable()
	self:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED")
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	masterLooter = nil
end

function MasterLooter:IsActive(unit)
	return unit == masterLooter
end

function MasterLooter:GetIcon(unit)
	return "Interface\\GroupFrame\\UI-Group-MasterLooter"
end

local looterText = L["ML"]
function MasterLooter:GetText(unit)
	return looterText
end

MasterLooter.GetColor = Grid2.statusLibrary.GetColor

local function CreateMasterLooter(baseKey, dbx)
	Grid2:RegisterStatus(MasterLooter, {"color", "icon", "text"}, baseKey, dbx)
	return MasterLooter
end

Grid2.setupFunc["master-looter"] = CreateMasterLooter

Grid2:DbSetStatusDefaultValue( "master-looter", { type = "master-looter", color1 = {r=1,g=.5,b=0,a=1}})
