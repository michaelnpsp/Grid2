-- Statuses Load filter management
local Grid2 = Grid2
local Grid2Frame = Grid2Frame

-- misc functions
local registered = {} -- registered messages
local function SetRegisterMessage(enabled, message)
	if not enabled ~= not registered[message] then
		registered[message] = not not enabled
		if enabled then
			Grid2:RegisterMessage(message)
		else
			Grid2:UnregisterMessage(message)
		end
	end
end

local indicators = {} -- temporary table
local function UpdateMarkedIndicators()
	for _, frame in next, Grid2Frame.registeredFrames do
		local unit = frame.unit
		if unit then
			for indicator in next, indicators do
				indicator:Update(frame, unit)
			end
		end
	end
	wipe(indicators)
end

local function UpdateSuspended(self)
	local prev = self.suspended
	local load = self.dbx.load
	if load then
		self.suspended =
			( load.disabled ) or
			( load.playerClassSpec and not load.playerClassSpec[ Grid2.playerClassSpec ]    ) or
			( load.playerFaction   and not load.playerFaction[ Grid2.playerFaction ]        ) or
			( load.groupType       and not load.groupType[ Grid2.groupType ]                ) or
			( load.instType        and not load.instType[ Grid2.instType ]                  ) or nil
		return self.suspended ~= prev
	else
		self.suspended = nil
		return prev
	end
end

local function RefreshSuspended(self, update)
	if UpdateSuspended(self) then
		local method = self.suspended and "UnregisterStatus" or "RegisterStatus"
		for indicator, priority in pairs(self.priorities) do
			indicator[method](indicator, self, priority)
			indicators[indicator] = true
		end
		if not self.suspended then
			self:Refresh() -- needed by aura statuses
		end
		if update then
			UpdateMarkedIndicators()
		end
		return true
	end
end

local statuses = { playerSpec = {}, groupType = {}, instType = {} }
local function RefreshStatusesFilters(filterType)
	for status in pairs(statuses[filterType]) do
		RefreshSuspended(status)
	end
end

-- messages management
function Grid2:Grid_GroupTypeChanged()
	RefreshStatusesFilters('groupType')
	RefreshStatusesFilters('instType')
	UpdateMarkedIndicators()
end

function Grid2:Grid_PlayerSpecChanged()
	RefreshStatusesFilters('playerSpec')
	UpdateMarkedIndicators()
end

-- status methods
local status = Grid2.statusPrototype

function status:RegisterLoad(update)
	local load = self.dbx and self.dbx.load
	if load then
		statuses.playerSpec[self] = load.playerSpec~=nil or nil
		statuses.groupType[self]  = load.groupType ~=nil or nil
		statuses.instType[self]   = load.instType  ~=nil or nil
		if update then UpdateSuspended(self) end
	else
		statuses.playerSpec[self] = nil
		statuses.groupType[self]  = nil
		statuses.instType[self]   = nil
		if update then self.suspended = nil end
	end
	SetRegisterMessage( next(statuses.groupType) or next(statuses.instType),  "Grid_GroupTypeChanged" )
	SetRegisterMessage( next(statuses.playerSpec), "Grid_PlayerSpecChanged" )
end

function status:UnregisterLoad()
	if self.dbx.load then
		self.dbx = nil
		self:RegisterLoad()
	end
end

function status:RefreshLoad() -- used by options
	self:RegisterLoad(false)
	return RefreshSuspended(self, true)
end
