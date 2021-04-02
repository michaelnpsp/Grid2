local Role = Grid2.statusPrototype:new("role")
local Leader = Grid2.statusPrototype:new("leader")
local Assistant = Grid2.statusPrototype:new("raid-assistant")
local MasterLooter = Grid2.statusPrototype:new("master-looter")
local DungeonRole = Grid2.statusPrototype:new("dungeon-role")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local IsInRaid = IsInRaid
local UnitExists = UnitExists
local UnitIsGroupLeader = UnitIsGroupLeader
local GetRaidRosterInfo = GetRaidRosterInfo
local GetPartyAssignment = GetPartyAssignment
local UnitGroupRolesAssigned= UnitGroupRolesAssigned or (function() return 'NONE' end)
local GetTexCoordsForRoleSmallCircle= GetTexCoordsForRoleSmallCircle
local UnitIsUnit = UnitIsUnit
local MAIN_TANK = MAIN_TANK
local MAIN_ASSIST = MAIN_ASSIST
local raid_indexes = Grid2.raid_indexes
local party_indexes = Grid2.party_indexes
local next, select = next, select

-- Code to disable statuses in combat
local SetHideInCombat
do
	local statuses, frame
	local function CombatEvent(_, event)
		local inCombat = (event == "PLAYER_REGEN_DISABLED")
		local Dummy    = Grid2.Dummy
		for status in next,statuses do
			status.IsActive = inCombat and Dummy or status.IsActiveB
			status:UpdateActiveUnits()
		end
	end
	function SetHideInCombat(status,value)
		if value then
			if not frame then
				statuses, frame = {}, CreateFrame("Frame")
				frame:SetScript("OnEvent", CombatEvent)
			end
			if not next(statuses) then
				frame:RegisterEvent("PLAYER_REGEN_ENABLED")
				frame:RegisterEvent("PLAYER_REGEN_DISABLED")
			end
			status.IsActiveB = status.IsActive
			statuses[status] = true
		elseif statuses and statuses[status] then
			statuses[status] = nil
			if not next(statuses) then
				frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
				frame:UnregisterEvent("PLAYER_REGEN_DISABLED")
			end
		end
	end
end

-- Role (maintank/mainassist) status

local role_cache = {}

Role.SetHideInCombat = SetHideInCombat

function Role:UpdateActiveUnits()
	for unit in next, role_cache do
		self:UpdateIndicators(unit)
	end
end

function Role:Grid_RosterUpdate(event)
	for unit in Grid2:IterateGroupedPlayers() do
		local index, role = raid_indexes[unit]
		if index then
			role = select(10,GetRaidRosterInfo(index))
		elseif party_indexes[unit] then
			role = (GetPartyAssignment("MAINTANK",unit) and "MAINTANK") or (GetPartyAssignment("MAINASSIST",unit) and "MAINASSIST")
		end
		if role ~= role_cache[unit] then
			role_cache[unit] = role
			if event then self:UpdateIndicators(unit) end
		end
	end
end

function Role:Grid_UnitLeft(_, unit)
	role_cache[unit] = nil
end

function Role:OnEnable()
	self:SetHideInCombat(self.dbx.hideInCombat)
	self:RegisterMessage("Grid_RosterUpdate")
	self:RegisterMessage("Grid_UnitLeft")
	self:Grid_RosterUpdate()
end

function Role:OnDisable()
	self:SetHideInCombat()
	self:UnregisterMessage("Grid_RosterUpdate")
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
		return 0,0,0,0
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

function Assistant:UpdateActiveUnits()
	for unit in next, assis_cache do
		self:UpdateIndicators(unit)
	end
end

function Assistant:Grid_RosterUpdate(event)
	if IsInRaid() then
		for unit in Grid2:IterateGroupedPlayers() do
			local index = raid_indexes[unit]
			if index then
				local name, rank = GetRaidRosterInfo(index)
				local assis = rank==1 or nil
				if assis ~= assis_cache[unit] then
					assis_cache[unit] = assis
					if event then self:UpdateIndicators(unit) end
				end
			end
		end
	end
end

function Assistant:Grid_UnitLeft(_, unit)
	assis_cache[unit] = nil
end

function Assistant:OnEnable()
	self:SetHideInCombat(self.dbx.hideInCombat)
	self:RegisterMessage("Grid_RosterUpdate")
	self:RegisterMessage("Grid_UnitLeft")
end

function Assistant:OnDisable()
	self:SetHideInCombat()
	self:UnregisterMessage("Grid_RosterUpdate")
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
Assistant.SetHideInCombat = SetHideInCombat

local function CreateAssistant(baseKey, dbx)
	Grid2:RegisterStatus(Assistant, {"color", "icon", "text"}, baseKey, dbx)
	return Assistant
end

Grid2.setupFunc["raid-assistant"] = CreateAssistant

Grid2:DbSetStatusDefaultValue( "raid-assistant", { type = "raid-assistant", color1 = {r=1,g=.25,b=.2,a=1}} )

-- Party/Raid Leader status

local raidLeader

function Leader:UpdateActiveUnits()
	if raidLeader then
		self:UpdateIndicators(raidLeader)
	end
end

function Leader:UpdateLeader(event)
	if not (raidLeader and UnitIsGroupLeader(raidLeader) and Grid2:IsUnitInRaid(raidLeader)) then
		local prevLeader = raidLeader
		raidLeader = self:CalculateLeader()
		if raidLeader ~= prevLeader then
			if prevLeader then self:UpdateIndicators(prevLeader) end
			if raidLeader then self:UpdateIndicators(raidLeader) end
		end
	end
end

function Leader:CalculateLeader()
	for unit in Grid2:IterateGroupedPlayers() do
		if UnitIsGroupLeader(unit) then
			return unit
		end
	end
end

function Leader:OnEnable()
	self:SetHideInCombat(self.dbx.hideInCombat)
	self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateLeader")
	self:RegisterMessage("Grid_RosterUpdate", "UpdateLeader")
	raidLeader = self:CalculateLeader()
end

function Leader:OnDisable()
	self:SetHideInCombat()
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterMessage("Grid_RosterUpdate")
	raidLeader = nil
end

function Leader:IsActive(unit)
	return raidLeader and UnitIsUnit( unit, raidLeader )
end

function Leader:GetIcon(unit)
	return "Interface\\GroupFrame\\UI-Group-LeaderIcon"
end

local leaderText= L["RL"]
function Leader:GetText(unit)
	return leaderText
end

Leader.GetColor = Grid2.statusLibrary.GetColor
Leader.SetHideInCombat = SetHideInCombat

local function CreateLeader(baseKey, dbx)
	Grid2:RegisterStatus(Leader, {"color", "icon", "text"}, baseKey, dbx)
	return Leader
end

Grid2.setupFunc["leader"] = CreateLeader

Grid2:DbSetStatusDefaultValue( "leader", { type = "leader", color1 = {r=0,g=.7,b=1,a=1}} )

-- Master looter status

local masterLooter

function MasterLooter:UpdateActiveUnits()
	if masterLooter then
		self:UpdateIndicators(masterLooter)
	end
end

function MasterLooter:UpdateMasterLooter()
	local prevMaster = masterLooter
	masterLooter = self:CalculateMasterLooter()
	if masterLooter ~= prevMaster then
		if prevMaster   then self:UpdateIndicators(prevMaster) end
		if masterLooter then self:UpdateIndicators(masterLooter) end
	end
end

function MasterLooter:CalculateMasterLooter()
	local method, partyID, raidID = GetLootMethod()
	if method=='master' then
		if raidID then
			return 'raid'..raidID
		elseif partyID then
			return partyID==0 and 'player' or 'party'..partyID
		end
	end
end

function MasterLooter:OnEnable()
	self:SetHideInCombat(self.dbx.hideInCombat)
	self:RegisterEvent("PARTY_LOOT_METHOD_CHANGED", "UpdateMasterLooter")
	self:RegisterMessage("Grid_RosterUpdate", "UpdateMasterLooter")
	masterLooter = self:CalculateMasterLooter()
end

function MasterLooter:OnDisable()
	self:SetHideInCombat()
	self:UnregisterEvent("PARTY_LOOT_METHOD_CHANGED")
	self:UnregisterMessage("Grid_RosterUpdate")
	masterLooter = nil
end

function MasterLooter:IsActive(unit)
	return masterLooter and UnitIsUnit( unit, masterLooter )
end

function MasterLooter:GetIcon(unit)
	return "Interface\\GroupFrame\\UI-Group-MasterLooter"
end

local looterText = L["ML"]
function MasterLooter:GetText(unit)
	return looterText
end

MasterLooter.GetColor = Grid2.statusLibrary.GetColor
MasterLooter.SetHideInCombat = SetHideInCombat

local function CreateMasterLooter(baseKey, dbx)
	Grid2:RegisterStatus(MasterLooter, {"color", "icon", "text"}, baseKey, dbx)
	return MasterLooter
end

Grid2.setupFunc["master-looter"] = CreateMasterLooter

Grid2:DbSetStatusDefaultValue( "master-looter", { type = "master-looter", color1 = {r=1,g=.5,b=0,a=1}})

-- dungeon-role status

if Grid2.isClassic then return end

local isValidRole = { TANK = true, HEALER = true, DAMAGER = true }
local roleTexture = "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
local TexCoordfunc = GetTexCoordsForRoleSmallCircle

DungeonRole.UpdateActiveUnits = Grid2.statusLibrary.UpdateAllUnits
DungeonRole.SetHideInCombat = SetHideInCombat

function DungeonRole:OnEnable()
	self:SetHideInCombat(self.dbx.hideInCombat)
	self:UpdateDB()
	self:RegisterMessage("Grid_RosterUpdate", "UpdateAllUnits")
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "UpdateAllUnits")
end

function DungeonRole:OnDisable()
	self:SetHideInCombat()
	self:UnregisterMessage("Grid_RosterUpdate")
	self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
end

function DungeonRole:IsActive(unit)
	local role = UnitGroupRolesAssigned(unit)
    return role and isValidRole[role]
end

function DungeonRole:GetColor(unit)
	local c
	local role = UnitGroupRolesAssigned(unit)
	if role=="DAMAGER" then
		c = self.dbx.color1
	elseif role=="HEALER" then
		c = self.dbx.color2
	elseif role=="TANK" then
		c = self.dbx.color3
	else
		return 0,0,0,0
	end
	return c.r, c.g, c.b, c.a
end

function DungeonRole:GetIcon(unit)
	return roleTexture
end

function DungeonRole:GetTexCoord(unit)
	return TexCoordfunc(UnitGroupRolesAssigned(unit))
end

function DungeonRole:GetText(unit)
	return L[UnitGroupRolesAssigned(unit) or ""]
end

function DungeonRole:UpdateDB()
	isValidRole["DAMAGER"] = (not self.dbx.hideDamagers) or nil
	roleTexture = self.dbx.useAlternateIcons and "Interface\\LFGFrame\\LFGROLE" or "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
	TexCoordfunc = self.dbx.useAlternateIcons and GetTexCoordsForRoleSmall or GetTexCoordsForRoleSmallCircle
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(DungeonRole, {"color", "text", "icon"}, baseKey, dbx)

	return DungeonRole
end

Grid2.setupFunc["dungeon-role"] = Create

Grid2:DbSetStatusDefaultValue( "dungeon-role", { type = "dungeon-role", colorCount = 3,
	color1 = { r = 0.75, g = 0, b = 0 }, --dps
	color2 = { r = 0, g = 0.75, b = 0 }, --heal
	color3 = { r = 0, g = 0, b = 0.75 }, --tank
	opacity = 0.75
})
