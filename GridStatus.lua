--[[
Created by Grid2 original authors, modified by Michael
--]]

Grid2.statuses = {}
Grid2.statusTypes = {}

local status = {}

function status:init(name, embed)
	if embed ~= false then
		LibStub("AceEvent-3.0"):Embed(self)
	end
	self.indicators = {}
	self.name = name
end

function status:RegisterIndicator(indicator)
	if self.indicators[indicator] then
		Grid2:Print(string.format("WARNING ! Indicator %s already registered with status %s", indicator.name, self.name))
		return
	end
	local enabled = next(self.indicators)
	self.indicators[indicator] = true
	if not enabled then
		self.enabled = true
		self:OnEnable()
	end
end

function status:UnregisterIndicator(indicator)
	if not self.indicators[indicator] then return end
	self.indicators[indicator] = nil
	local enabled = next(self.indicators)
	if not enabled then
		self.enabled = nil
		self:OnDisable()
	end
end

function status:UpdateIndicators(unit)
	for parent in next, Grid2:GetUnitFrames(unit) do
		for indicator in pairs(self.indicators) do
			indicator:Update(parent, unit)
		end
	end
end

function status:UpdateDB(dbx)
	if (dbx) then
		self.dbx = dbx
	end
end

Grid2.statusPrototype = {
	__index = status,
	new = function (self, ...)
		local e = setmetatable({}, self)
		e:init(...)
		return e
	end,
}

function Grid2:RegisterStatus(status, types, baseKey, dbx)
	local name = status.name
	if (baseKey and baseKey ~= name) then
		self.statuses[name] = nil
		status.name = baseKey
	else
		self.statuses[name] = status
		for _, type in ipairs(types) do
			local t = self.statusTypes[type]
			if not t then
				t = {}
				self.statusTypes[type] = t
			end
			t[#t+1] = status
		end
	end
	status.dbx = dbx
end


function Grid2:UnregisterStatus(status)
    for _, indicator in Grid2:IterateIndicators() do
		if self.indicators[indicator] then
			indicator:UnregisterStatus(status)
		end
	end
	if status.Destroy then status:Destroy() end
	local name = status.name
	self.statuses[name] = nil
	for type, t in pairs(self.statusTypes) do
		for i=1,#t do
			if t[i]==status then
				table.remove(t,i)
				break
			end
		end
	end
end

function Grid2:IterateStatuses(type)
	return next, type and self.statusTypes[type] or self.statuses
end
