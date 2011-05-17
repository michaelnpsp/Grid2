-- Created by Michael inspired by Grid2StatusDungeonRole created by Gaff3 

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local DungeonRole = Grid2.statusPrototype:new("dungeon-role")

local Grid2= Grid2
local UnitGroupRolesAssigned= UnitGroupRolesAssigned
local GetTexCoordsForRoleSmallCircle= GetTexCoordsForRoleSmallCircle

function DungeonRole:UpdateAllUnits(event)
	for unit, guid in Grid2:IterateRosterUnits() do
		self:UpdateIndicators(unit)
	end
end

function DungeonRole:OnEnable()
	self:RegisterEvent("PLAYER_ROLES_ASSIGNED", "UpdateAllUnits")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "UpdateAllUnits")
end

function DungeonRole:OnDisable()
	self:UnregisterEvent("PLAYER_ROLES_ASSIGNED")
	self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
end

function DungeonRole:IsActive(unit)
	local role= UnitGroupRolesAssigned(unit)
    return role and role~="NONE"
end

function DungeonRole:GetColor(unit)
	local c
	local role = UnitGroupRolesAssigned(unit)
	if role=="DAMAGER" then
		c = self.dbx.color1
	elseif role=="HEALER" then
		c = self.dbx.color2
	elseif role=="TANK" then
		c = self.dbx.color2 
	else 
		c = { r=0, g=0, b=0, a=0 }
	end
	return c.r, c.g, c.b, c.a
end

function DungeonRole:GetIcon(unit)
	return "Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES"
end

function DungeonRole:GetTexCoord(unit)
	return GetTexCoordsForRoleSmallCircle(UnitGroupRolesAssigned(unit))
end

function DungeonRole:GetText(unit)
	return L[UnitGroupRolesAssigned(unit) or ""]
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(DungeonRole, {"color", "text", "icon"}, baseKey, dbx)

	return DungeonRole
end

Grid2.setupFunc["dungeon-role"] = Create

