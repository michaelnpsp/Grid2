local Vehicle = Grid2.statusPrototype:new("vehicle")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")


Vehicle.defaultDB = {
	profile = {
		color1 = { r = 0, g = 1, b = 1, a = .75 },
	}
}

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
	self:RegisterMessage("Grid_UnitJoined", "UNIT_ENTERED_VEHICLE")
end

function Vehicle:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
	self:UnregisterMessage("Grid_UnitJoined")
end

function Vehicle:IsActive(unitid)
	return UnitHasVehicleUI(unitid)
end

function Vehicle:GetColor(unitid)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

function Vehicle:GetIcon(unitid)
	return [[Interface\Vehicles\UI-Vehicles-Raid-Icon]]
end

function Vehicle:GetPercent(unitid)
	return UnitHasVehicleUI(unitid) and self.db.profile.color1.a
end

local vehicleString = L["vehicle"]
function Vehicle:GetText(unitid)
	return vehicleString
end

Grid2:RegisterStatus(Vehicle, { "color", "icon", "percent", "text" })










--[[
function GridStatusVehicle:UpdateUnit(unitid)
	local pet_unitid = GridRoster:GetPetUnitidByUnitid(unitid)
	if not pet_unitid then
		return
	end

	local guid = UnitGUID(pet_unitid)

	if UnitHasVehicleUI(unitid) then
		local settings = self.db.profile.alert_vehicleui

		self.core:SendStatusGained(
								   guid,
								   "alert_vehicleui",
								   settings.priority,
								   (settings.range and 40),
								   settings.color,
								   settings.text,
								   nil,
								   nil,
								   settings.icon
							   )
	else
		self.core:SendStatusLost(guid, "alert_vehicleui")
	end
end
--]]