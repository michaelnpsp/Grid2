Grid2.locations = {}

local location = {}

function location:init(name)
	self.name = name
end

Grid2.locationPrototype = {
	__index = location,
	new = function (self, ...)
		local e = setmetatable({}, self)
		e:init(...)
		return e
	end,
}

function Grid2:RegisterLocation(location)
	assert(not self.locations[location.name])
	self.locations[location.name] = location
	if self.db then
		self:InitializeElement("location", location)
	end
end

function Grid2:IterateLocations()
	return next, self.locations
end
