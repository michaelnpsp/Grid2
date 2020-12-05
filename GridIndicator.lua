--[[
Created by Grid2 original authors, modified by Michael
--]]

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local next = next
local tinsert = table.insert
local tremove = table.remove
local tdelete = Grid2.TableRemoveByValue
local isWoW90 = Grid2.isWoW90

Grid2.indicators = {}
Grid2.indicatorSorted = {}
Grid2.indicatorEnabled = {}
Grid2.indicatorTypes = {}
Grid2.indicatorPrototype = {}

local indicator = Grid2.indicatorPrototype
indicator.__index = indicator

function indicator:new(name)
	local e = setmetatable({}, self)
	local p = {}
	e.sortStatuses = function (a,b) return p[a] > p[b]	end
	e.priorities = p
	e.name = name
	e.statuses = {}
	e.prototype = self
	return e
end

function indicator:CreateFrame(type, parent, template)
	local f = parent[self.name]
	if not (f and f:GetObjectType()==type and f.__template == template) then
		f = CreateFrame(type, nil, parent, (isWoW90 or template~="BackdropTemplate") and template or nil)
		f.__template = template
		parent[self.name] = f
	end
	f:Hide()
	return f
end

function indicator:Update(parent, unit)
	self:OnUpdate(parent, unit, self:GetCurrentStatus(unit) )
end

function indicator:UpdateDB()
	if self.LoadDB then self:LoadDB() end
end

function indicator:RegisterStatus(status, priority)
	if self.priorities[status] then return end
	self.statuses[#self.statuses + 1] = status
	self:SetStatusPriority(status, priority)
	if not Grid2.suspendedIndicators[self.name] then
		status:RegisterIndicator(self)
	end
end

function indicator:UnregisterStatus(status)
	if not self.priorities[status] then return end
	self.priorities[status] = nil
	tremove(self.statuses, self:GetStatusIndex(status))
	self:SortStatuses()
	status:UnregisterIndicator(self)
end

function indicator:GetStatusIndex(status)
	for i, s in ipairs(self.statuses) do
		if s == status then
			return i
		end
	end
end

function indicator:SortStatuses()
	table.sort(self.statuses, self.sortStatuses)
end

function indicator:SetStatusPriority(status, priority)
	self.priorities[status] = priority
	self:SortStatuses()
end

function indicator:GetStatusPriority(status)
	return self.priorities[status]
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

function Grid2:WakeUpIndicator(indicator)
	local statuses = indicator.statuses
	for i=1,#statuses do
		statuses[i]:RegisterIndicator(indicator)
	end
	tinsert(self.indicatorEnabled, indicator)
	if indicator.UpdateDB then
		indicator:UpdateDB()
	end
	indicator.suspended = nil
	if indicator.sideKick then
		self:WakeUpIndicator(indicator.sideKick)
	end
	if indicator.childName then
		self:WakeUpIndicator(self.indicators[indicator.childName])
	end
	if indicator.OnWakeUp then
		indicator:OnWakeUp()
	end
end

function Grid2:SuspendIndicator(indicator)
	if indicator.childName then
		self:SuspendIndicator(self.indicators[indicator.childName])
	end
	if indicator.sideKick then
		self:SuspendIndicator(indicator.sideKick)
	end
	local statuses = indicator.statuses
	for i=1,#statuses do
		statuses[i]:UnregisterIndicator(indicator)
	end
	tdelete(self.indicatorEnabled, indicator)
	if indicator.Disable then
		Grid2Frame:WithAllFrames(indicator, "Disable")
	end
	indicator.suspended = true
	if indicator.OnSuspend then
		indicator:OnSuspend()
	end
end

function Grid2:RegisterIndicator(indicator, types)
	local name = indicator.name
	self.indicators[name]  = indicator
	tinsert(self.indicatorSorted,indicator)
	tinsert(self.indicatorEnabled,indicator)
	for _, type in ipairs(types) do
		local t = self.indicatorTypes[type]
		if not t then
			t = {}
			self.indicatorTypes[type] = t
		end
		t[name] = indicator
	end
	indicator:UpdateDB()
end

function Grid2:UnregisterIndicator(indicator)
	local statuses = indicator.statuses
	while #statuses>0 do
		indicator:UnregisterStatus(statuses[#statuses])
	end
	if indicator.Disable then
		Grid2Frame:WithAllFrames(indicator, "Disable")
	end
	local name = indicator.name
	self.indicators[name] = nil
	for type, t in pairs(self.indicatorTypes) do
		t[name] = nil
	end
	tdelete(self.indicatorSorted,  indicator)
	tdelete(self.indicatorEnabled, indicator)
	indicator.suspended = nil
	if indicator.sideKick then
		Grid2:UnregisterIndicator(indicator.sideKick)
		indicator.sideKick = nil
	end
end

function Grid2:GetIndicatorByName(name)
	return name and Grid2.indicators[name]
end

function Grid2:GetIndicatorsEnabled()
	return self.indicatorEnabled
end

function Grid2:GetIndicatorsSorted()
	return self.indicatorSorted
end

function Grid2:IterateIndicators(type)
	return next, type and self.indicatorTypes[type] or self.indicators
end
