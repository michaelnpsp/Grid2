--[[
Created by Grid2 original authors, modified by Michael
--]]

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local next = next
local wipe = wipe
local tinsert = table.insert
local tremove = table.remove
local setmetatable = setmetatable
local tdelete = Grid2.TableRemoveByValue
local BackdropTemplateMixin = BackdropTemplateMixin

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
		f = CreateFrame(type, nil, parent, (BackdropTemplateMixin or template~="BackdropTemplate") and template or nil)
		f.__template = template
		parent[self.name] = f
	end
	f:Hide()
	return f
end

function indicator:CanCreate(parent)
	if self.parentName then return parent[self.parentName]~=nil end
	local filtered = self.filtered
	return not (filtered and filtered[parent]==0)
end

function indicator:GetMainFrame(parent)
	return parent[self.name]
end

function indicator:DisableAllFrames()
	local Disable = self.Disable
	if Disable then
		local GetMainFrame = self.GetMainFrame
		for _, frame in next, Grid2Frame.registeredFrames do
			if GetMainFrame(self, frame) then
				Disable(self, frame)
			end
		end
	end
end

function indicator:Update(parent, unit)
	self:OnUpdate(parent, unit, self:GetCurrentStatus(unit, parent) )
end

function indicator:UpdateAllFrames()
	for _, frame in next, Grid2Frame.registeredFrames do
		local unit = frame.unit
		if unit then self:Update(frame, unit) end
	end
end

function indicator:UpdateDB()
end

function indicator:RegisterStatus(status, priority)
	if not self.priorities[status] then
		if not status.suspended then
			self.statuses[#self.statuses + 1] = status
			self.priorities[status] = priority
			self:SortStatuses()
			self:UpdateHighlight(status)
		end
		status:RegisterIndicator( self, priority, Grid2.suspendedIndicators[self.name] )
	end
end

function indicator:UnregisterStatus(status, priority)
	if not self.priorities[status] then return end
	self.priorities[status] = nil
	tremove(self.statuses, self:GetStatusIndex(status))
	self:SortStatuses()
	status:UnregisterIndicator(self, priority)
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
	if not status.suspended then
		self.priorities[status] = priority
		self:SortStatuses()
	end
	status.priorities[self] = priority
end

function indicator:GetStatusPriority(status)
	return status.priorities[self]
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
	indicator:UpdateDB()
	indicator:WakeUpFilter()
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
	indicator:DisableAllFrames()
	indicator:SuspendFilter()
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
	indicator.Update = indicator.UpdateOverride or indicator.prototype.Update
	indicator:UpdateDB()
	indicator:UpdateFilter()
end

function Grid2:UnregisterIndicator(indicator)
	local statuses = indicator.statuses
	while #statuses>0 do
		indicator:UnregisterStatus(statuses[#statuses])
	end
	indicator:DisableAllFrames()
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
