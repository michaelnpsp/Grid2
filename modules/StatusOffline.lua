local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

function Offline:UNIT_FLAGS(_, unit)
	self:UpdateIndicators(unit)
end

function Offline:OnEnable()
	self:RegisterEvent("UNIT_FLAGS")
end

function Offline:OnDisable()
	self:UnregisterEvent("UNIT_FLAGS")
end

function Offline:IsActive(unit)
	return not UnitIsConnected(unit)
end

function Offline:GetColor(unit)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function Offline:GetPercent(unit)
	return (not UnitIsConnected(unit)) and self.dbx.color1.a
end

function Offline:GetText(unit)
	if (UnitIsConnected(unit)) then
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
