-- Statuses Load filter management, by MiCHaEL
local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local pairs = pairs
local next = next

-- local variables
local indicators = {} -- indicators marked for update
local registered = {} -- registered messages
local statuses   = { playerClassSpec = {}, groupInstType = {}, instNameID = {}, unitFilter = {} }

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
	local method = self.suspended and "UnregisterStatus" or "RegisterStatus"
	for indicator, priority in pairs(self.priorities) do -- register/unregister indicators
		indicator[method](indicator, self, priority)
		indicators[indicator] = true
	end
	if not self.suspended then
		self:Refresh() -- needed by aura statuses, to fill status cache with units aura info
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

-- status methods
local status = Grid2.statusPrototype

function status:RegisterLoad()
	local load = self.dbx and self.dbx.load
	if load then
		UpdateMessages(self, load)
		UpdateStatus(self)
	end
end

function status:UnregisterLoad()
	if self.dbx and self.dbx.load then
		UpdateMessages(self)
	end
end

function status:RefreshLoad() -- used by options
	UpdateMessages(self, self.dbx and self.dbx.load)
	return RefreshStatus(self)
end

-----------------------------------------------------
-- Unit filters management: type/class/role/reaction
-----------------------------------------------------
do
	local UnitClass = UnitClass
	local UnitExists = UnitExists
	local UnitIsFriend = UnitIsFriend
	local UnitGroupRolesAssigned = Grid2.UnitGroupRolesAssigned
	local roster_types = Grid2.roster_types
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
		for status in next, statuses.unitFilter do
			status.filtered[unit] = nil
		end
	end	
	
	function status:MakeUnitFilter() -- should be called from status:UpdateDB()
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
	
	function status:EnableUnitFilter() -- should be called from status:OnEnable()
		local filtered = self.filtered
		if filtered then
			local list = statuses.unitFilter
			if not next(list) then
				Grid2.RegisterMessage( list, "Grid_UnitUpdated", ClearUnitFilters )
			end	
			list[self] = filtered
		end
	end

	function status:DisableUnitFilter() -- should be called from status:OnDisable()
		local filtered = self.filtered
		if filtered then
			local list = statuses.unitFilter
			list[self] = nil
			if not next(list) then
				Grid2.UnregisterMessage( list, "Grid_UnitUpdated" )
			end	
		end	
	end
	
	function status:Refresh(full)
		if full then self:UpdateDB() end
		if self.filtered then wipe(self.filtered).source = self.dbx.load end
		if full then self:UpdateAllUnits() end
	end	
	
	function Grid2:RefreshStatusesFilter(filterName) -- Called from GridCore.lua PLAYER_ROLES_ASSIGNED event
		for status, filtered in next, statuses.unitFilter do
			local load = filtered.source
			wipe(filtered).source = load
			status:UpdateAllUnits()
		end
	end
	
end