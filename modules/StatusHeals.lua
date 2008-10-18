local HealComm = LibStub:GetLibrary("LibHealComm-3.0", true)
if not HealComm then return end
local next = next
local select = select

local Heals = Grid2.statusPrototype:new("heals")

local rosterCache = setmetatable({}, { __index = function (self, unit)
	local name, realm = UnitName(unit)
	if realm and realm ~= "" then
		name = name .. "-" .. realm
	end
	self[unit] = name
	return name
end})

local invRosterCache = setmetatable({}, { __index = function (self, name)
	for unit in Grid2:IterateRoster(true) do
		local n = rosterCache[unit]
		if not n then return end
		self[n] = unit
		if name == n then return unit end
	end
end})

function Heals:Grid_RosterUpdated()
	while true do
		local unit = next(rosterCache)
		if not unit then break end
		rosterCache[unit] = nil
	end
	while true do
		local name = next(invRosterCache)
		if not name then break end
		invRosterCache[name] = nil
	end
end

function Heals:Grid_PetChanged(pet)
	local name = rawget(rosterCache, pet)
	if name then
		rosterCache[pet] = nil
		invRosterCache[name] = nil
	end
end

function Heals:OnEnable()
	HealComm.RegisterCallback(self, "HealComm_DirectHealStart", "Update")
	HealComm.RegisterCallback(self, "HealComm_DirectHealStop", "Update")
	HealComm.RegisterCallback(self, "HealComm_DirectHealDelayed", "Update")
	HealComm.RegisterCallback(self, "HealComm_HealModifierUpdate", "Update")

	self:RegisterMessage("Grid_RosterUpdated")
	self:RegisterMessage("Grid_PetChanged")
end

function Heals:OnDisable()
	HealComm.UnregisterCallback(self, "HealComm_DirectHealStart")
	HealComm.UnregisterCallback(self, "HealComm_DirectHealStop")
	HealComm.UnregisterCallback(self, "HealComm_DirectHealDelayed")
	HealComm.UnregisterCallback(self, "HealComm_HealModifierUpdate")
	
	self:UnregisterMessage("Grid_RosterUpdated")
	self:UnregisterMessage("Grid_PetChanged")
end

function Heals:Update(event, healerName, healSize, endTime, ...)
	-- @FIXME: fix self heals.
	for i = 1, select("#", ...) do
		local name = select(i, ...)
		local unit = invRosterCache[name]
		self:UpdateIndicators(unit)
	end
end

function Heals:IsActive(unit)
	local heal = HealComm:UnitIncomingHealGet(rosterCache[unit], GetTime() + 100)
	return heal and heal > 0
end

Heals.defaultDB = {
	profile = {
		color = { r = 0, g = 1, b = 0, a = 1 },
	}
}

function Heals:GetColor(unit)
	local color = self.db.profile.color
	return color.r, color.g, color.b, color.a
end

function Heals:GetText(unit)
	local name = rosterCache[unit]
	local heal = HealComm:UnitIncomingHealGet(name, GetTime() + 100)
	heal = heal * HealComm:UnitHealModifierGet(name)
	return Grid2:GetShortNumber(heal, true)
end

Grid2:RegisterStatus(Heals, { "color", "text" })
