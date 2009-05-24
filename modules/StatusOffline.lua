local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

Offline.defaultDB = {
	profile = {
		color1 = { r = 1, g = 1, b = 1, a = 1 },
	}
}

function Offline:RAID_ROSTER_UPDATE(event, unitid)
	self:UpdateIndicators(unitid)
end

function Offline:OnEnable()
	self:RegisterEvent("RAID_ROSTER_UPDATE", "RAID_ROSTER_UPDATE")
end

function Offline:OnDisable()
	self:UnregisterEvent("RAID_ROSTER_UPDATE")
end

function Offline:IsActive(unitid)
	return not UnitIsConnected(unitid)
end

function Offline:GetColor(unitid)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

function Offline:GetPercent(unitid)
	return (not UnitIsConnected(unitid)) and self.db.profile.color1.a
end

function Offline:GetText(unitid)
	if (UnitIsConnected(unitid)) then
		return nil
	else
		return L["Offline"]
	end
end

Grid2:RegisterStatus(Offline, { "color", "percent", "text" })
