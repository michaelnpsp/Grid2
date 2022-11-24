-- Implements indicator load filter

local Grid2 = Grid2
local wipe = wipe
local next = next
local setmetatable = setmetatable
local UnitClass = UnitClass
local UnitExists = UnitExists
local indicatorPrototype = Grid2.indicatorPrototype
local UnitGroupRolesAssigned = Grid2.UnitGroupRolesAssigned
local roster_types = Grid2.roster_types

local indicators = {} -- indicators filtered by unitRole

local filter_mt = {	__index = function(t,u)
	if UnitExists(u) then
		local load, r = t.source
		if load.unitType then
			r = not load.unitType[ roster_types[u] ]
		end
		if not r and load.unitRole then
			r = not load.unitRole[ UnitGroupRolesAssigned(u) ]
		end
		if not r and load.unitClass then
			local _,class = UnitClass(u)
			r = not load.unitClass[class]
		end
		t[u] = r
		return r
	end
	t[u] = true
	return true
end }

-- Clear cached filter of modified units, called when a unit is added or updated
local function ClearFilter(_, unit)
	for _, filtered in next, indicators do
		filtered[unit] = nil
	end
	if unit=='player' then ClearFilter(nil,'PLAYER') end
end

-- Replaces indicator:GetCurrentStatus() method defined in GridIndicator.lua
-- To detect and filter special player frame InsecureGroupHeaders code assigns PLAYER to frame.filteredUnit
local function GetCurrentStatus(self, unit, frame)
	if unit then
		if self.filtered[frame.filteredUnit or unit] then return false end -- false instead of nil, needed by portrait status
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
	if load and (load.unitType or load.unitRole or load.unitClass) then
		self.GetCurrentStatus = GetCurrentStatus
		if self.filtered then
			wipe(self.filtered).source = load
		else
			self.filtered = setmetatable({source = load}, filter_mt)
		end
		if not next(indicators) then
			Grid2.RegisterMessage( indicators, "Grid_UnitLeft", ClearFilter )
			Grid2.RegisterMessage( indicators, "Grid_UnitUpdated", ClearFilter )
		end
		indicators[self] = self.filtered
	elseif self.filtered then
		self.GetCurrentStatus = indicatorPrototype.GetCurrentStatus
		self.filtered = nil
		indicators[self] = nil
		if not next(indicators) then
			Grid2.UnregisterMessage( indicators, "Grid_UnitLeft" )
			Grid2.UnregisterMessage( indicators, "Grid_UnitUpdated" )
		end
	end
end

-- Refresh indicators filter, currently only used to reset unitRole filter, see Grid2:PLAYER_ROLES_ASSIGNED()
function Grid2:RefreshIndicatorsFilter(filterName)
	for indicator, filtered in next, indicators do
		local load = filtered.source
		if load.unitRole then
			wipe(filtered).source = load
			indicator:UpdateAllFrames()
		end
	end
end
