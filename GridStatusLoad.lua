-- Statuses Load filter management, by MiCHaEL
local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local next = next
local pairs = pairs
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitIsFriend = UnitIsFriend
local UnitGroupRolesAssigned = Grid2.UnitGroupRolesAssigned
local roster_types = Grid2.roster_types

-----------------------------------------------------------------------
-- General filters: class/spec/zone/group type
-- statuses are suspended&unregistered from indicators
-----------------------------------------------------------------------

local FilterG_RegisterStatus, FilterG_UnregisterStatus, FilterG_RefreshStatus
do
	-- local variables
	local indicators = {} -- indicators marked for update
	local registered = {} -- registered messages
	local statuses   = { playerClassSpec = {}, groupInstType = {}, instNameID = {} }

	-- local functions
	local function RegisterMessage(message, enabled)
		if not enabled ~= not registered[message] then
			registered[message] = not not enabled
			if enabled then
				Grid2:RegisterMessage(message)
			else
				Grid2:UnregisterMessage(message)
			end
		end
	end

	local function UpdateMessages(status, load)
		statuses.playerClassSpec[status] = load and load.playerClassSpec~=nil or nil
		statuses.instNameID[status] = load and load.instNameID~=nil or nil
		statuses.groupInstType[status] = load and (load.groupType~=nil or load.instType~=nil) or nil
		RegisterMessage( "Grid_GroupTypeChanged",  next(statuses.groupInstType) )
		RegisterMessage( "Grid_PlayerSpecChanged", next(statuses.playerClassSpec) )
		RegisterMessage( "Grid_ZoneChangedNewArea", next(statuses.instNameID) )
	end

	local function RegisterIndicators(self)
		local suspended = self.suspended
		local method = suspended and "UnregisterStatus" or "RegisterStatus"
		for indicator, priority in pairs(self.priorities) do -- register/unregister indicators
			indicator[method](indicator, self, priority)
			indicators[indicator] = true
		end
		if suspended then
			wipe(self.filtered).source = self.dbx.load
		elseif self.OnWakeUp then
			self:OnWakeUp() 
		end
	end

	local function UpdateIndicators()
		for frame, unit in next, Grid2Frame.activatedFrames do
			for indicator in next, indicators do
				indicator:Update(frame, unit)
			end
		end
		wipe(indicators)
	end

	local function CheckZoneFilter(filter)
		local instanceName,_,_,_,_,_,_,instanceID = GetInstanceInfo()
		return filter[instanceName] or filter[instanceID]
	end

	local function UpdateStatus(self)
		local prev = self.suspended
		local load = self.dbx.load
		if load then
			self.suspended =
				( load.disabled ) or
				( load.playerClass     and not load.playerClass[ Grid2.playerClass ]         ) or
				( load.playerClassSpec and not load.playerClassSpec[ Grid2.playerClassSpec ] ) or
				( load.groupType       and not load.groupType[ Grid2.groupType ]             ) or
				( load.instType        and not load.instType[ Grid2.instType ]               ) or
				( load.instNameID      and not CheckZoneFilter(load.instNameID)              ) or nil
			return self.suspended ~= prev
		else
			self.suspended = nil
			return prev
		end
	end

	local function RefreshStatus(self)
		if UpdateStatus(self) then
			RegisterIndicators(self)
			UpdateIndicators()
			return true
		end
	end

	local function RefreshStatuses(filterType)
		local notify
		for status in pairs(statuses[filterType]) do
			if UpdateStatus(status) then
				RegisterIndicators(status)
				notify = true
			end
		end
		UpdateIndicators()
		if notify then
			Grid2:SendMessage("Grid_StatusLoadChanged")
		end
	end

	-- message events
	function Grid2:Grid_GroupTypeChanged()
		RefreshStatuses('groupInstType')
	end

	function Grid2:Grid_PlayerSpecChanged()
		RefreshStatuses('playerClassSpec')
	end

	function Grid2:Grid_ZoneChangedNewArea()
		RefreshStatuses('instNameID')
	end
	
	-- public 
	function FilterG_RegisterStatus(self, load)
		UpdateMessages(self, load)
		UpdateStatus(self)
	end

	function FilterG_UnregisterStatus(self)
		UpdateMessages(self, nil)
	end

	function FilterG_RefreshStatus(self, load)
		UpdateMessages(self, load)
		return RefreshStatus(self)
	end

end

-----------------------------------------------------------------------
-- Unit filters: type/class/role/reaction
-- code check in :IsActive() method is necessary 
-----------------------------------------------------------------------

local FilterU_RegisterStatus, FilterU_UnregisterStatus, FilterU_RefreshStatus
do
	local statuses = {}
	
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
			if not r and load.unitReaction then
				r = not UnitIsFriend('player',u)
				if load.unitReaction.hostile then r = not r end
			end
			t[u] = r
			return r
		end
		t[u] = true
		return true
	end }

	local function ClearUnitFilters(_, unit)
		for status in next, statuses do
			status.filtered[unit] = nil
		end
	end	
	
	function Grid2:RefreshStatusesFilter(filterName) -- Called from GridCore.lua PLAYER_ROLES_ASSIGNED event
		for status, filtered in next, statuses.unitFilter do
			local load = filtered.source
			if load[filterName] then
				wipe(filtered).source = load
				status:UpdateAllUnits()
			end	
		end
	end

	-- public
	function FilterU_RegisterStatus(self, load)
		if load.unitType or load.unitReaction or load.unitClass or load.unitRole then
			if self.filtered then
				wipe(self.filtered).source = load
			else
				self.filtered = setmetatable({source = load}, filter_mt)
			end
			if not next(statuses) then
				Grid2.RegisterMessage( statuses, "Grid_UnitUpdated", ClearUnitFilters )
			end	
			statuses[self] = self.filtered
		else
			self.filtered = nil
		end
	end
	
	function FilterU_UnregisterStatus(self)
		if self.filtered then
			statuses[self] = nil
			if not next(statuses) then
				Grid2.UnregisterMessage( statuses, "Grid_UnitUpdated" )
			end
			self.filtered = nil
		end
	end

	function FilterU_RefreshStatus(self, load)
		FilterU_RegisterStatus(self, load)
		self:UpdateAllUnits()
	end
	
end

-----------------------------------------------------------------------
-- status methods
-----------------------------------------------------------------------

local status = Grid2.statusPrototype

function status:RegisterLoad() -- this is called from status:RegisterIndicator()
	local load = self.dbx and self.dbx.load
	if load then
		FilterG_RegisterStatus(self, load)
		FilterU_RegisterStatus(self, load)
	end
end

function status:UnregisterLoad() -- this is called from status:UnregisterIndicator()
	local load = self.dbx and self.dbx.load
	if load then
		FilterG_UnregisterStatus(self)
		FilterU_UnregisterStatus(self)
	end
end

function status:RefreshLoad() -- used by options
	local load = self.dbx and self.dbx.load
	FilterG_RefreshStatus(self, load)
	FilterU_RefreshStatus(self, load)
end
