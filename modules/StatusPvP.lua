local PvP = Grid2.statusPrototype:new("pvp")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")


PvP.defaultDB = {
	profile = {
		color1 = { r = 0, g = 1, b = 1, a = .75 },
	}
}

function PvP:RAID_ROSTER_UPDATE(event, unitid)
	self:UpdateIndicators(unitid)
end

function PvP:ZONE_CHANGED_NEW_AREA(event)
	for guid, unitid in Grid2:IterateRoster() do
		self:UpdateIndicators(unitid)
	end
end

function PvP:OnEnable()
	self:RegisterEvent("RAID_ROSTER_UPDATE", "RAID_ROSTER_UPDATE")
	self:RegisterEvent("UNIT_FACTION", "RAID_ROSTER_UPDATE")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ZONE_CHANGED_NEW_AREA")
--	self:RegisterMessage("Grid_UnitJoined", "RAID_ROSTER_UPDATE")
end

function PvP:OnDisable()
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
	self:UnregisterEvent("UNIT_FACTION")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
--	self:UnregisterMessage("Grid_UnitJoined")
end

function PvP:IsActive(unitid)
	local inInstance, instanceType = IsInInstance()
	if (inInstance) then
		return nil
	else
		return UnitIsPVP(unitid) or UnitIsPVPFreeForAll(unitid)
	end
end

function PvP:GetColor(unit)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

local factionTexture, ffaTexture
local factionTexCoord, ffaTexCoord
local factionText, ffaText
do
	local faction = UnitFactionGroup("player")
	if (faction == "Horde") then
		factionTexture = [[Interface\PVPFrame\PVP-Currency-Horde]]
--		factionTexCoord = {0.08, 0.58, 0.045, 0.545}
	else
		factionTexture = [[Interface\PVPFrame\PVP-Currency-Alliance]]
--		factionTexCoord = {0.07, 0.58, 0.06, 0.57}
	end
	factionText = L["PvP"]

	ffaTexture = [[Interface\TargetingFrame\UI-PVP-FFA]]
	--ToDo: add a TexCoord callback
	ffaTexCoord = {0.05, 0.605, 0.015, 0.57}
	ffaText = L["FFA"]
end

function PvP:GetIcon(unitid)
	if (UnitIsPVP(unitid)) then
		return factionTexture
	elseif (UnitIsPVPFreeForAll(unitid)) then
		return ffaTexture
	else
		return nil
	end
end

function PvP:GetPercent(unitid)
	return (UnitIsPVP(unitid) or UnitIsPVPFreeForAll(unitid)) and self.db.profile.color1.a
end

function PvP:GetText(unitid)
	if (UnitIsPVP(unitid)) then
		return factionText
	elseif (UnitIsPVPFreeForAll(unitid)) then
		return ffaText
	else
		return nil
	end
end

Grid2:RegisterStatus(PvP, { "color", "icon", "percent", "text" })
