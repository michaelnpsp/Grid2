-- Implements indicator load filter

local Grid2 = Grid2
local setmetatable = setmetatable
local roster_types = Grid2.roster_types
local indicatorPrototype = Grid2.indicatorPrototype

local filter_mt = {	__index = function(t,u)
	local r = not t.source[ roster_types[u] ]
	t[u] = r
	return r
end }

-- Replaces indicator:GetcurrentStatus() method defined in GridIndicator.lua
local function GetCurrentStatus(self, unit)
	if unit then
		local filtered = self.filtered
		if filtered and filtered[unit] then return false end
		local statuses= self.statuses
		for i=1,#statuses do
			local status= statuses[i]
			local state = status:IsActive(unit)
			if state then
				return status, state
			end
		end
	end
end

-- Called from Grid2:RegisterIndicator() function in GridIndicator.lua
function indicatorPrototype:UpdateFilter()
	if self.parentName then return end
	local load = self.dbx and self.dbx.load
	if load and load.unitType then
		if self.filtered then
			wipe(self.filtered).source = load.unitType
		else
			self.filtered = setmetatable({source = load.unitType}, filter_mt)
			self.GetCurrentStatus = GetCurrentStatus
		end
	elseif self.filtered then
		self.filtered = nil
	end
end
