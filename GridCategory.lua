Grid2.categories = {}

local category = {}

function category:init(name)
	self.name = name
end

Grid2.locationPrototype = {
	__index = category,
	new = function (self, ...)
		local e = setmetatable({}, self)
		e:init(...)
		return e
	end,
}

function Grid2:RegisterCategory(category)
	assert(not self.categories[category.name])
	self.categories[category.name] = category
	if self.db then
		self:InitializeElement("category", category)
	end
end

function Grid2:IterateCategories()
	return next, self.categories
end
