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

function indicator:RegisterStatus(status, priority)
	if self.priorities[status] then return end
	self.priorities[status] = priority
	self.statuses[#self.statuses + 1] = status
	table.sort(self.statuses, self.sortStatuses)
	status:RegisterIndicator(self)
end

function indicator:UnregisterStatus(status)
	if not self.priorities[status] then return end
	self.priorities[status] = nil
	for i, s in ipairs(self.status) do
		if s == status then
			table.remove(self.status, i)
			break
		end
	end
	status:UnregisterIndicator(self)
end

function indicator:SetStatusPriority(status, priority)
	if not self.priorities[status] then return end
	self.priorities[status] = priority
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
						range = GridRange:GetUnitRange(unitid)
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
	if self.blinking ~= state then
		self.blinking = state
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
	assert(name and not self.indicators[name])
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

function Grid2:IterateIndicators(type)
	return next, type and self.indicatorTypes[type] or self.indicators
end
