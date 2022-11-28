-- Statuses Load filter management, by MiCHaEL
local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local pairs = pairs
local next = next

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
