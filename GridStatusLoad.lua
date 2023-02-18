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

-------------------------------------------------------------------------
-- Register/Unregister filtered statuses
-------------------------------------------------------------------------

local statuses = { playerClassSpec = {}, groupInstType = {}, instNameID = {}, unitFilter = {}, unitRole = {} }

local function RegisterFilter(status, filterType, message, func, enabled)
	local registered = statuses[filterType]
	if not enabled ~= not registered[status] then
		if enabled then
			if not next(registered) then Grid2.RegisterMessage(statuses, message, func) end
			registered[status] = enabled
		else
			registered[status] = nil
			if not next(registered) then Grid2.UnregisterMessage(statuses, message) end
		end
	end
end

-------------------------------------------------------------------------
-- General filters: class/spec/zone/group type
-- statuses are suspended&unregistered from indicators
-------------------------------------------------------------------------

local FilterG_RegisterStatus, FilterG_UnregisterStatus, FilterG_RefreshStatus
do
	local indicators = {} -- indicators marked for update

	local function RegisterIndicators(self)
		local method = self.suspended and "UnregisterStatus" or "RegisterStatus"
		for indicator, priority in pairs(self.priorities) do -- register/unregister indicators
			indicator[method](indicator, self, priority)
			indicators[indicator] = true
		end
	end

	local function UpdateMarkedIndicators()
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

	local function SuspendStatus(self)
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

	local function RefreshStatuses(filterType)
		local notify
		for status in pairs(statuses[filterType]) do
			if SuspendStatus(status) then
				RegisterIndicators(status)
				notify = true
			end
		end
		UpdateMarkedIndicators()
		if notify then
			Grid2:SendMessage("Grid_StatusLoadChanged")
		end
	end

	-- message events
	local function GroupTypeEvent()
		RefreshStatuses('groupInstType')
	end

	local function PlayerSpecEvent()
		RefreshStatuses('playerClassSpec')
	end

	local function ZoneChangedEvent()
		RefreshStatuses('instNameID')
	end

	local function RegisterFilters(status, load)
		RegisterFilter( status, "instNameID",      "Grid_ZoneChangedNewArea", ZoneChangedEvent, load and load.instNameID~=nil )
		RegisterFilter( status, "playerClassSpec", "Grid_PlayerSpecChanged",  PlayerSpecEvent,  load and load.playerClassSpec~=nil )
		RegisterFilter( status, "groupInstType",   "Grid_GroupTypeChanged",   GroupTypeEvent,   load and (load.groupType~=nil or load.instType~=nil) )
	end
	
	-- public 
	function FilterG_RegisterStatus(self, load)
		RegisterFilters(self, load)
		SuspendStatus(self)
	end

	function FilterG_UnregisterStatus(self)
		RegisterFilters(self, nil)
	end

	function FilterG_RefreshStatus(self)
		if SuspendStatus(self) then
			RegisterIndicators(self)
			UpdateMarkedIndicators()
		end
	end

end

-------------------------------------------------------------------------
-- Unit filters: type/class/role/reaction
-- self.filtered[unit] check inside status:IsActive() method is necessary 
-------------------------------------------------------------------------

local FilterU_UpdateLoad, FilterU_RegisterStatus, FilterU_UnregisterStatus, FilterU_RefreshStatus
do
	local filter_mt = {	__index = function(t,u)
		if UnitExists(u) then
			local load, r = t.source
			if load.unitType then
				r = not load.unitType[ roster_types[u] ]
			end
			if not r then
				if load.unitRole then
					r = not load.unitRole[ UnitGroupRolesAssigned(u) ]
				end
				if not r then
					if load.unitClass then
						local _,class = UnitClass(u)
						r = not load.unitClass[class]
					end
					if not r then
						if load.unitReaction then
							r = not UnitIsFriend('player',u)
							if load.unitReaction.hostile then r = not r end
						end
					end
				end
			end
			t[u] = r
			return r
		end
		t[u] = true
		return true
	end }

	local function ClearUnitFilters(_, unit)
		for status, filtered in next, statuses.unitFilter do
			filtered[unit] = nil
		end
	end	
	
	local function RefreshRoleFilter() 
		for status, filtered in next, statuses.roleFilter do
			wipe(filtered).source = status.dbx.load
			status:UpdateAllUnits()
		end
	end

	-- public
	function FilterU_UpdateLoad(self)
		local load = self.dbx.load
		if load and (load.unitType or load.unitReaction or load.unitClass or load.unitRole) then
			if self.filtered then
				wipe(self.filtered).source = load
			else
				self.filtered = setmetatable({source = load}, filter_mt)
			end
		else
			self.filtered = nil
		end
	end

	function FilterU_RegisterStatus(self, load)
		local filtered = self.filtered
		if filtered then
			RegisterFilter( self, "unitFilter", "Grid_UnitUpdated",         ClearUnitFilters,  filtered )
			RegisterFilter( self, "unitRole",   "Grid_PlayerRolesAssigned", RefreshRoleFilter, load.unitRole and filtered )
		end
	end

	function FilterU_UnregisterStatus(self, load)
		local filtered = self.filtered
		if filtered then
			RegisterFilter( self, "unitFilter", "Grid_UnitUpdated" )
			RegisterFilter( self, "unitRole",   "Grid_PlayerRolesAssigned" )
			wipe(filtered).source = load
		end
	end

	function FilterU_RefreshStatus(self, load)
		self:UpdateLoad()
		self:UpdateDB()
		if self.enabled then
			FilterU_RegisterStatus(self, load)
			self:UpdateAllUnits()
		end
	end
	
end

-----------------------------------------------------------------------
-- status methods
-----------------------------------------------------------------------

local status = Grid2.statusPrototype

status.UpdateLoad = FilterU_UpdateLoad -- called from Grid2:RegisterStatus()

function status:RegisterLoad() -- called from status:RegisterIndicator()
	local load = self.dbx.load
	if load then
		FilterG_RegisterStatus(self, load)
		FilterU_RegisterStatus(self, load)
	end
end

function status:UnregisterLoad() -- called from status:UnregisterIndicator()
	local load = self.dbx.load
	if load then
		FilterG_UnregisterStatus(self, load)
		FilterU_UnregisterStatus(self, load)
	end
end

function status:RefreshLoad() -- used by Grid2Options
	local load = self.dbx.load
	FilterG_RefreshStatus(self, load)
	FilterU_RefreshStatus(self, load)
end	
