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

local framePool = setmetatable( {}, {__index = function (t,k) local r = {}; t[k] = r; return r; end} )

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

function indicator:Acquire(type, parent, template)
	local f = tremove(framePool[self.dbx.type]) or CreateFrame(type, nil, parent, (BackdropTemplateMixin or template~="BackdropTemplate") and template or nil)
	f:SetParent(parent)
	f:Hide()
	parent[self.name] = f
	self.framesCreated = true
	return f
end

function indicator:Release(parent)
	local f = parent[self.name]
	if f then
		local Destroy = self.Destroy
		if Destroy then Destroy(self, parent, f) end
		f:SetParent(nil)
		f:ClearAllPoints()
		f:Hide()
		tinsert( framePool[self.dbx.type], f )
		parent[self.name] = nil
	end
end

function indicator:GetFrame(parent)
	return parent[self.name]
end

function indicator:ReleaseAllFrames()
	if self.framesCreated then
		local Release = self.Release
		for _, frame in next, Grid2Frame.registeredFrames do
			Release(self, frame)
		end
	end
end

function indicator:DisableAllFrames()
	local Disable = self.Disable
	if Disable then
		local GetFrame = self.GetFrame
		for _, frame in next, Grid2Frame.registeredFrames do
			if GetFrame(self, frame) then
				Disable(self, frame)
			end
		end
	end
end

function indicator:LayoutAllFrames()
	local Layout = self.Layout
	local GetFrame = self.GetFrame
	for _, frame in next, Grid2Frame.registeredFrames do
		if GetFrame(self,frame) then
			Layout(self, frame)
		end
	end
end

function indicator:UpdateAllFrames()
	for frame, unit in next, Grid2Frame.activatedFrames do
		self:Update(frame, unit)
	end
end

function indicator:Update(parent, unit)
	self:OnUpdate(parent, unit, self:GetCurrentStatus(unit, parent) )
end

function indicator:UpdateDB()
end

function indicator:RegisterStatus(status, priority)
	if not self.priorities[status] and not status.suspended then
		self.statuses[#self.statuses + 1] = status
		self.priorities[status] = priority
		self:SortStatuses()
		self:UpdateHighlight(status)
	end
	status:RegisterIndicator( self, priority, Grid2.suspendedIndicators[self.name] )
end

function indicator:UnregisterStatus(status, suspend)
	if self.priorities[status] then
		self.priorities[status] = nil
		tremove(self.statuses, self:GetStatusIndex(status))
		self:SortStatuses()
	end
	status:UnregisterIndicator(self, suspend)
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
	if status then
		if not status.suspended then
			self.priorities[status] = priority
			self:SortStatuses()
		end
		status.priorities[self] = priority
	end
end

function indicator:GetStatusPriority(status)
	return status and status.priorities[self]
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
	indicator:EnableTooltips()
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
	indicator.suspended = true
	if indicator.OnSuspend then
		indicator:OnSuspend()
	end
	indicator:DisableTooltips()
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
	indicator:UpdateFilter()
	indicator:EnableTooltips()
end

function Grid2:UnregisterIndicator(indicator)
	local statuses = indicator.statuses
	while #statuses>0 do
		indicator:UnregisterStatus(statuses[#statuses])
	end
	indicator:ReleaseAllFrames()
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
	indicator:DisableTooltips()
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
