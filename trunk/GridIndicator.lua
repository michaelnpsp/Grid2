--[[
Created by Grid2 original authors, modified by Michael
--]]

Grid2.indicators = {}
Grid2.indicatorTypes = {}

local indicator = {}

function indicator:init(name)
	self.statuses = {}
	local priorities = {}
	self.sortStatuses = function (a, b)
		return priorities[a] > priorities[b]
	end
	self.priorities = priorities
	self.name = name
end

function indicator:CreateFrame(type, parent)
	local f = parent[self.name]
	if not (f and f:GetObjectType()==type) then
		f= CreateFrame(type, nil, parent)
		parent[self.name]= f
	end
	return f
end

function indicator:RegisterStatus(status, priority)
	if self.priorities[status] then
		Grid2:Print(string.format("WARNING ! Status %s already registered with indicator %s", status.name, self.name))
		return true
	end
	if (Grid2:IsCompatiblePair(self, status)) then
		self.priorities[status] = priority
		self.statuses[#self.statuses + 1] = status
		table.sort(self.statuses, self.sortStatuses)
		status:RegisterIndicator(self)
		return true
	end
	return false
end

function indicator:UnregisterStatus(status)
	if not self.priorities[status] then return end
	self.priorities[status] = nil
	for i, s in ipairs(self.statuses) do
		if s == status then
			table.remove(self.statuses, i)
			break
		end
	end
	status:UnregisterIndicator(self)
end

function indicator:SetStatusPriority(status, priority)
	if not self.priorities[status] then 
		print( "Bad SetStatusPriority: "..self.name.." "..status.name )
		return 
	end
	self.priorities[status] = priority
	table.sort(self.statuses, self.sortStatuses)
end

function indicator:GetStatusPriority(status)
	return self.priorities[status]
end

function indicator:GetStatusIndex(status)
	local statuses= self.statuses
	for i=1,#statuses do
		if status == statuses[i] then
			return i
		end	
	end
end

function indicator:GetCurrentStatus(unit)
	if unit then
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

--{{ Update functions  

local Grid2Blink = Grid2:GetModule("Grid2Blink")
local blinking= Grid2Blink.registry

local function UpdateBlink(self, parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	local frame= self.GetBlinkFrame  
	if frame then 
		frame= frame(self,parent)
		if blinking[frame] then
			if state~="blink" then Grid2Blink:Remove(frame) end	
		else
			if state=="blink" then Grid2Blink:Add(frame) end
		end
	end 
	self:OnUpdate(parent, unit, status)
end

local function UpdateNoBlink(self, parent, unit)
	self:OnUpdate(parent, unit, self:GetCurrentStatus(unit) )
end

indicator.Update= UpdateBlink

--}}

Grid2.indicatorPrototype = {
	__index = indicator,
	new = function (self, ...)
		local e = setmetatable({}, self)
		e:init(...)
		return e
	end,
}

function Grid2:RegisterIndicator(indicator, types)
	local name = indicator.name
	self.indicators[name] = indicator
	for _, type in ipairs(types) do
		local t = self.indicatorTypes[type]
		if not t then
			t = {}
			self.indicatorTypes[type] = t
		end
		t[name] = indicator
	end
end

function Grid2:UnregisterIndicator(indicator)
	-- unregister statuses linked to this indicator
	local statuses= indicator.statuses
	while (#statuses>0) do
		indicator:UnregisterStatus(statuses[#statuses])
	end
	-- Hide indicator from created frame units
	if indicator.Disable then
		Grid2Frame:WithAllFrames(function (f) indicator:Disable(f) end)
	end
	-- unregister indicator
	local name = indicator.name
	self.indicators[name] = nil
	for type, t in pairs(self.indicatorTypes) do
		t[name] = nil
	end
	-- unregister asociated indicator if exists
	if (indicator.sideKick) then
		Grid2:UnregisterIndicator(indicator.sideKick)
		indicator.sideKick = nil
	end
end

-- We can choose which update function we want to use. UpdateNoBlink is faster 
function Grid2:IndicatorsBlinkEnabled( enabled )
  	indicator.Update= enabled and UpdateBlink or UpdateNoBlink
end

function Grid2:IsCompatiblePair(indicator, status)
	-- we check that the status provides at least
	-- one of the required indicator types
	for type, list in pairs(self.indicatorTypes) do
		if list[indicator.name] then
			for _, s in self:IterateStatuses(type) do
				if s == status then
					return type
				end
			end
		end
	end
end

function Grid2:IterateIndicators(type)
	return next, type and self.indicatorTypes[type] or self.indicators
end

