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

function indicator:RegisterStatus(status, priority)
	if self.priorities[status] then
		Grid2:Print(string.format("WARNING ! Status %s already registered with indicator %s", status.name, self.name))
		return
	end
	-- assert(Grid2:IsCompatiblePair(self, status), "InCompatiblePair " .. self.name .. " vs " .. status.name)
	-- ToDo: save these in case of a morph later?
	if (Grid2:IsCompatiblePair(self, status)) then
		self.priorities[status] = priority
		self.statuses[#self.statuses + 1] = status
		table.sort(self.statuses, self.sortStatuses)
		status:RegisterIndicator(self)
	end
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
	--print( "SetStatusPriority: "..self.name.." "..status.name.." now "..priority )
	table.sort(self.statuses, self.sortStatuses)
end

function indicator:GetStatusPriority(status)
	return self.priorities[status]
end

function indicator:GetCurrentStatus(unit)
	if unit then
		local range
		for _, status in ipairs(self.statuses) do
			local state = status:IsActive(unit)
			if state then
				if status:HasRange() then
					if not range then
						range = GridRange:GetUnitRange(unit)
					end
					if status:IsInRange(unit, range) then
						return status, state
					end
				else
					return status, state
				end
			end
		end
	end
end

local Grid2Blink = Grid2:GetModule("Grid2Blink")
function indicator:SetBlinkingState(frame, state)
	local blinking = self.blinking
	local current = blinking and blinking[frame] or false
	
	if current ~= state then
		if not blinking then
			blinking = {}
			self.blinking = blinking
		end
		blinking[frame] = state
		if state then
			Grid2Blink:Add(frame)
		else
			Grid2Blink:Remove(frame)
		end
	end
end

function indicator:Update(parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	local f = self.GetBlinkFrame and self:GetBlinkFrame(parent)
	if f then self:SetBlinkingState(f, state == "blink") end
	self:OnUpdate(parent, unit, status)
end

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
--	assert(name and not self.indicators[name])
-- TODO: add an unregister so assert does not get triggered and indicators can switch types
	self.indicators[name] = indicator
	for _, type in ipairs(types) do
		local t = self.indicatorTypes[type]
		if not t then
			t = {}
			self.indicatorTypes[type] = t
		end
		t[name] = indicator
	end
	if self.db then
		self:InitializeElement("indicator", indicator)
	end
end

function Grid2:UnregisterIndicator(indicator)
	local name = indicator.name
	self.indicators[name] = nil
	for type, t in pairs(self.indicatorTypes) do
		t[name] = nil
	end
	
	if (indicator.sideKick) then
		Grid2:UnregisterIndicator(indicator.sideKick)
		indicator.sideKick = nil
	end
end

function Grid2:IterateIndicators(type)
	return next, type and self.indicatorTypes[type] or self.indicators
end
