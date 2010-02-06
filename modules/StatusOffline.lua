local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

function Offline:Grid_UnitJoined(_, unit)
	self:UpdateIndicators(unit)
end

function Offline:OnEnable()
	self:RegisterMessage("Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitChanged", "Grid_UnitJoined")
	self:RegisterEvent("UNIT_FLAGS", "Grid_UnitJoined")
end

function Offline:OnDisable()
	self:UnregisterMessage("Grid_UnitJoined")
	self:UnregisterMessage("Grid_UnitChanged")
	self:UnregisterEvent("UNIT_FLAGS")
end

function Offline:IsActive(unitid)
	return not UnitIsConnected(unitid)
end

function Offline:GetColor(unitid)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function Offline:GetPercent(unitid)
	return (not UnitIsConnected(unitid)) and self.dbx.color1.a
end

function Offline:GetText(unitid)
	if (UnitIsConnected(unitid)) then
		return nil
	else
		return L["Offline"]
	end
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Offline, {"color", "percent", "text"}, baseKey, dbx)

	return Offline
end

Grid2.setupFunc["offline"] = Create
