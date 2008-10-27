local HealComm = LibStub:GetLibrary("LibHealComm-3.0", true)
if not HealComm then return end
local next = next
local select = select

local playerName = UnitName"player"

local playerHealingTargetNames = {}
local playerHealingSize

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
	if healerName == playerName then
		if event == 'HealComm_DirectHealStart' then
			playerHealingSize = healSize > 0 and healSize
			wipe(playerHealingTargetNames)
			for i = 1, select("#", ...) do
				playerHealingTargetNames[select(i, ...)] = true
			end
		else
			playerHealingSize = nil
		end
	end

	for i = 1, select("#", ...) do
		local name = select(i, ...)
		local unit = invRosterCache[name]
		self:UpdateIndicators(unit)
	end
end

function Heals:IsActive(unit)
	local name = rosterCache[unit]
	if playerHealingSize and playerHealingTargetNames[name] then return true end
	local heal = HealComm:UnitIncomingHealGet(name, GetTime() + 100)
	return heal and heal > 0
end

function Heals:GetHealingOnUnit(unit)
	local name = rosterCache[unit]

	local heal
	if playerHealingSize and playerHealingTargetNames[name] then
		heal = playerHealingSize
	else
		heal = 0
	end

	otherHeals = HealComm:UnitIncomingHealGet(name, GetTime() + 100)
	if otherHeals then heal = heal + otherHeals end
	heal = heal * HealComm:UnitHealModifierGet(name)
	return heal
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
	return Grid2:GetShortNumber(self:GetHealingOnUnit(unit), true)
end

function Heals:GetPercent(unit)
	-- @FIXME: I don't like +UnitHealth here
	return (self:GetHealingOnUnit(unit) + UnitHealth(unit)) / UnitHealthMax(unit)
end

Grid2:RegisterStatus(Heals, { "color", "text", "percent" })
