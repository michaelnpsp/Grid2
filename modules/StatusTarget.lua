local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Target = Grid2.statusPrototype:new("target")

local UnitIsUnit= UnitIsUnit

function Target:OnEnable()
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function Target:PLAYER_TARGET_CHANGED(event)
	for unit, guid in Grid2:IterateRosterUnits() do
		self:UpdateIndicators(unit)
	end
end

function Target:OnDisable()
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
end

function Target:IsActive(unitid)
	return UnitIsUnit(unitid, "target")
end

function Target:GetColor(unitid)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

local text = L["target"]
function Target:GetText(unitid)
	return text
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Target, {"color", "text"}, baseKey, dbx)

	return Target
end

Grid2.setupFunc["target"] = Create
