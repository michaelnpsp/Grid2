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

-- Role (maintank/mainassist) status

local role_cache = {}
local raid_indexes

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
	local GetUnitRole = Grid2:UnitIsParty(Grid2:IterateRosterUnits()) and GetPartyUnitRole or GetRaidUnitRole
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

function Role:Initialize()
	raid_indexes = {}
	for i = 1, 40 do
		raid_indexes["raid"..i] = i
	end
	self.Initialize = Grid2.Dummy
end

function Role:OnEnable()
	self:Initialize()
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

Grid2:DbSetStatusDefaultValue( "role", {type = "role", colorCount = 2, color1 = {r=1,g=1,b=.5,a=1}, color2 = {r=.5,g=1,b=1,a=1}})

-- Party/Raid Leader status

local raidLeader

function Leader:UpdateAllUnits()
	if raidLeader and raidLeader~="" then
		self:UpdateIndicators(raidLeader)
	end
	self:UpdateLeader()
	if raidLeader and raidLeader~="" then
		self:UpdateIndicators(raidLeader)
	end
end

function Leader:UpdateLeader()
	for unit,_ in Grid2:IterateRosterUnits() do
		if UnitIsPartyLeader(unit) then
			raidLeader= unit
			return raidLeader
		end
	end
	raidLeader= ""
	return raidLeader
end

function Leader:OnEnable()
	self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateAllUnits")
end

function Leader:OnDisable()
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	raidLeader= nil
end

function Leader:IsActive(unit)
	return raidLeader and raidLeader==unit or self:UpdateLeader()==unit
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

Grid2:DbSetStatusDefaultValue( "leader", { type = "leader", color1 = {r=0,g=.7,b=1,a=1}} )

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
	assis_cache= nil
end

function Assistant:IsActive(unit)
	if not assis_cache then	
		self:UpdateAssistants() 
	end
	return assis_cache[unit]
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

Grid2:DbSetStatusDefaultValue( "raid-assistant", { type = "raid-assistant", color1 = {r=1,g=.25,b=.2,a=1}} )

-- Master looter status

local masterLooter

function MasterLooter:UpdateAllUnits()
	if masterLooter and masterLooter~="" then
		self:UpdateIndicators(masterLooter)
	end
	self:UpdateMasterLooter()
	if masterLooter and masterLooter~="" then
		self:UpdateIndicators(masterLooter)
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
	masterLooter= nil
end

function MasterLooter:IsActive(unit)
	return masterLooter and masterLooter==unit or self:UpdateMasterLooter()==unit
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

Grid2:DbSetStatusDefaultValue( "master-looter", { type = "master-looter", color1 = {r=1,g=.5,b=0,a=1}})
