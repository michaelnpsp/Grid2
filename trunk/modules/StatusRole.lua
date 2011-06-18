local Role = Grid2.statusPrototype:new("role")
local Leader = Grid2.statusPrototype:new("leader")
local Assistant = Grid2.statusPrototype:new("raid-assistant")
local MasterLooter = Grid2.statusPrototype:new("master-looter")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2= Grid2
local GetRaidRosterInfo= GetRaidRosterInfo
local GetPartyAssignment= GetPartyAssignment
local UnitIsPartyLeader= UnitIsPartyLeader
local MAIN_TANK = MAIN_TANK
local MAIN_ASSIST = MAIN_ASSIST

local raid_indexes = {}
for i = 1, 40 do
	raid_indexes["raid"..i] = i
end

-- Role (maintank/mainassist) status

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

function Role:UpdateAllUnits()
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

local function CreateRole(baseKey, dbx)
	Grid2:RegisterStatus(Role, {"color", "icon", "text"}, baseKey, dbx)
	return Role
end

Grid2.setupFunc["role"] = CreateRole

-- Party/Raid Leader status

local raidLeader

function Leader:UpdateAllUnits()
	self:UpdateLeader()
	for unit,_ in Grid2:IterateRosterUnits() do
		self:UpdateIndicators(unit)
	end
end

function Leader:UpdateLeader()
	for unit,_ in Grid2:IterateRosterUnits() do
		if UnitIsPartyLeader(unit) then
			raidLeader= unit
			return
		end
	end
	raidLeader= ""
end

function Leader:OnEnable()
	self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateAllUnits")
end

function Leader:OnDisable()
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
end

function Leader:IsActive(unit)
	if not raidLeader then self:UpdateLeader() end
	self.IsActive= function(_,unit) return raidLeader==unit end
	return self:IsActive()
end

function Leader:GetColor(unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

function Leader:GetIcon(unit)
	return "Interface\\GroupFrame\\UI-Group-LeaderIcon"
end

local leaderText= L["RL"]
function Leader:GetText(unit)
	return leaderText
end

local function CreateLeader(baseKey, dbx)
	Grid2:RegisterStatus(Leader, {"color", "icon", "text"}, baseKey, dbx)
	return Leader
end

Grid2.setupFunc["leader"] = CreateLeader

-- Assistant status

local assis_cache

function Assistant:UpdateAllUnits()
	self:UpdateAssistants()
	for unit, _ in Grid2:IterateRosterUnits() do
		self:UpdateIndicators(unit)
	end
end

function Assistant:UpdateAssistants()
	if assis_cache then 
		wipe(assis_cache)
	else
		assis_cache={}
	end	
	if GetNumRaidMembers()>0 then
		for i=1,40 do
			local name,rank = GetRaidRosterInfo(i)
			if not name then break end
			if rank==1 then
				assis_cache["raid"..i]= true
			end
		end
	end
end

function Assistant:OnEnable()
	self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateAllUnits")
end

function Assistant:OnDisable()
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
end

function Assistant:IsActive(unit)
	if not assis_cache then	self:UpdateAssistants() end
	self.IsActive= function(_,unit) return assis_cache[unit] end
	return self:IsActive()
end

function Assistant:GetColor(unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

function Assistant:GetIcon(unit)
	return "Interface\\GroupFrame\\UI-Group-AssistantIcon"
end

local assistantText= L["RA"]
function Assistant:GetText(unit)
	return assistantText
end

local function CreateAssistant(baseKey, dbx)
	Grid2:RegisterStatus(Assistant, {"color", "icon", "text"}, baseKey, dbx)
	return Assistant
end

Grid2.setupFunc["raid-assistant"] = CreateAssistant

-- Master looter status

local masterLooter

function MasterLooter:UpdateAllUnits()
	self:UpdateMasterLooter()
	for unit, _ in Grid2:IterateRosterUnits() do
		self:UpdateIndicators(unit)
	end
end

function MasterLooter:UpdateMasterLooter()
  local method, party, raid = GetLootMethod()
  if method == "master" then
		if raid then
			masterLooter= "raid" .. raid
		elseif party then
			masterLooter= (party==0) and "player" or "party"..party
		end	
  else
		masterLooter= ""
  end 
  return masterLooter
end

function MasterLooter:OnEnable()
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", "UpdateAllUnits")
end

function MasterLooter:OnDisable()
	self:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED")
end

function MasterLooter:IsActive(unit)
	if not masterLooter then self:UpdateMasterLooter() end
	self.IsActive= function(_,unit) return masterLooter==unit end
	return self:IsActive()
end

function MasterLooter:GetColor(unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

function MasterLooter:GetIcon(unit)
	return "Interface\\GroupFrame\\UI-Group-MasterLooter"
end

local looterText= L["ML"]
function MasterLooter:GetText(unit)
	return looterText
end

local function CreateMasterLooter(baseKey, dbx)
	Grid2:RegisterStatus(MasterLooter, {"color", "icon", "text"}, baseKey, dbx)
	return MasterLooter
end

Grid2.setupFunc["master-looter"] = CreateMasterLooter
