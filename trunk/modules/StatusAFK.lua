local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local AFK = Grid2.statusPrototype:new("afk")

function AFK:UpdateUnit(_, unitid)
	if unitid then
		self:UpdateIndicators(unitid)
	end
end

function AFK:UpdateAllUnits()
	for unit, guid in Grid2:IterateRosterUnits() do
		if (UnitExists(unit)) then
			self:UpdateIndicators(unit)
		end
	end
end

function AFK:OnEnable()
	self:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateAllUnits")
	self:RegisterEvent("READY_CHECK", "UpdateAllUnits")
	self:RegisterEvent("READY_CHECK_FINISHED", "UpdateAllUnits")
end

function AFK:OnDisable()
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_FINISHED")
end

function AFK:IsActive(unitid)
	return UnitIsAFK(unitid)
end

function AFK:GetColor(unitid)
        local color = self.dbx.color1
        return color.r, color.g, color.b, color.a
end

function AFK:GetText(unitid)
        return L["AFK"]
end

local function CreateStatusAFK(baseKey, dbx)
        Grid2:RegisterStatus(AFK, {"color", "text"}, baseKey, dbx)
        return AFK
end

Grid2.setupFunc["afk"] = CreateStatusAFK