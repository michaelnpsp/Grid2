local Vehicle = Grid2.statusPrototype:new("vehicle")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")


function Vehicle:PLAYER_ENTERING_WORLD(event)
	for guid, unitid in Grid2:IterateRoster() do
		self:UpdateIndicators(unitid)
	end
end

function Vehicle:UNIT_ENTERED_VEHICLE(event, unitid)
	self:UpdateIndicators(unitid)
end

function Vehicle:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "UNIT_ENTERED_VEHICLE")
--	self:RegisterMessage("Grid_UnitJoined", "UNIT_ENTERED_VEHICLE")
end

function Vehicle:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
--	self:UnregisterMessage("Grid_UnitJoined")
end

function Vehicle:IsActive(unitid)
	return UnitHasVehicleUI(unitid)
end

function Vehicle:GetColor(unitid)
	local color = self.dbx.color1
	return color.r, color.g, color.b, color.a
end

function Vehicle:GetIcon(unitid)
	return [[Interface\Vehicles\UI-Vehicles-Raid-Icon]]
end

function Vehicle:GetPercent(unitid)
	return UnitHasVehicleUI(unitid) and self.dbx.color1.a
end

local vehicleString = L["vehicle"]
function Vehicle:GetText(unitid)
	return vehicleString
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Vehicle, {"color", "icon", "percent", "text"}, baseKey, dbx)

	return Vehicle
end

Grid2.setupFunc["vehicle"] = Create
