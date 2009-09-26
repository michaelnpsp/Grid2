Grid2.categories = {}

local category = {}

function category:init(name, displayName, priorities)
	self.statuses = {}
	self.priorities = priorities
	self.sortStatuses = function (a, b)
		if (a == b) then
			Grid2:Print(string.format("WARNING ! Status %s double registered", a.name))
		end
		return priorities[a.name] > priorities[b.name]
	end
	self.name = name
end

function category:RegisterStatus(status, priority)
	self.statuses[#self.statuses + 1] = status
	table.sort(self.statuses, self.sortStatuses)
end

function category:UnregisterStatus(status)
	if (not self.priorities[status.name]) then
		return
	end
	for i, s in ipairs(self.statuses) do
		if s == status then
			table.remove(self.statuses, i)
			break
		end
	end
end

function category:SetStatusPriority(status, priority)
	if not self.priorities[status] then return end
	self.priorities[status] = priority
	table.sort(self.statuses, self.sortStatuses)
end

function category:GetStatusPriority(status)
	return self.priorities[status]
end


Grid2.categoryPrototype = {
	__index = category,
	new = function (self, ...)
		local e = setmetatable({}, self)
		e:init(...)
		return e
	end,
}

function Grid2:RegisterCategory(categoryKey, category)
	assert(not self.categories[categoryKey])
	self.categories[categoryKey] = category
end

function Grid2:CreateCategory(categoryKey, displayName, priorities)
	local category = self.categoryPrototype:new(categoryKey, displayName, priorities)
	self:RegisterCategory(categoryKey, category)
	return category
end

function Grid2:IterateCategories()
	return next, self.categories
end
