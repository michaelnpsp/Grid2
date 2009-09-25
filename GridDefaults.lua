function Grid2:SetupIndicators(setup)
	for indicatorKey, info in pairs(setup.indicators.bar) do
		self:CreateBarIndicator(indicatorKey, unpack(info))
	end
	local locationKey, location
	for indicatorKey, info in pairs(setup.indicators.square) do
		locationKey = setup.indicatorLocations[indicatorKey]
		location = setup.locations[locationKey]
		if (location) then
			info[2], info[3], info[4], info[5] = location.point, location.relPoint, location.x, location.y
		end

		self:CreateSquareIndicator(indicatorKey, unpack(info))
	end
	for indicatorKey, info in pairs(setup.indicators.icon) do
		locationKey = setup.indicatorLocations[indicatorKey]
		location = setup.locations[locationKey]
		if (location) then
			info[2], info[3], info[4], info[5] = location.point, location.relPoint, location.x, location.y
		end

		self:CreateIconIndicator(indicatorKey, unpack(info))
	end
	for indicatorKey, info in pairs(setup.indicators.text) do
		locationKey = setup.indicatorLocations[indicatorKey]
		location = setup.locations[locationKey]
		if (location) then
			info[2], info[3], info[4], info[5] = location.point, location.relPoint, location.x, location.y
		end

		self:CreateTextIndicator(indicatorKey, unpack(info))
	end
end


local handlerArray = {}
function Grid2:MakeBuffColorHandler(status)
	local profile = status.db.profile
	local colorCount = profile.colorCount or 1

	wipe(handlerArray)
	handlerArray[1] = "return function (self, unit)"
	local index = 2
	local color
	if (colorCount > 1) then
		handlerArray[index] = " local count = self:GetCount(unit)"
		index = index + 1
		for i = 1, colorCount - 1 do
			color = status.db.profile["color" .. i]
			handlerArray[index] = (" if count == %d then return %s, %s, %s, %s end"):format(i, color.r, color.g, color.b, color.a)
			index = index + 1
		end
	end

	color = status.db.profile[("color" .. colorCount)]
--print("UpdateColorHandler", status.name, "color" .. colorCount, color.r, color.g, color.b)
	handlerArray[index] = (" return %s, %s, %s, %s end"):format(color.r, color.g, color.b, color.a)

	local handler = table.concat(handlerArray)
	status.GetColor = assert(loadstring(handler))()
	return handler
end

function Grid2:MakeDebuffColorHandler(status, info)
	local colorCount = (#info - 1) / 3
	if (colorCount <= 0) then
		local name = info[1]
		self:Print("Invalid number of colors for debuff %s", name)
		return
	end

	wipe(handlerArray)
	handlerArray[1] = "return function (self, unit)"
	local index = 2
	if (colorCount > 1) then
		handlerArray[index] = " local count = self:GetCount(unit)"
		index = index + 1
		for i = 1, colorCount - 1 do
			handlerArray[index] = ("if count == %d then return %s, %s, %s end"):format(unpack(info, i * 3 - 1, (i + 1) * 3 - 2))
			index = index + 1
		end
	end
	handlerArray[index] = (" return %s, %s, %s end"):format(unpack(info, colorCount * 3 - 1))

	local handler = table.concat(handlerArray)
	status.GetColor = assert(loadstring(handler))()
	return handler
end

function Grid2:SetupBuffStatus(statusKey, info)
	local status = self:CreateBuffStatus(unpack(info))
	status.name = statusKey -- force name

	self:RegisterStatus(status, { "color", "icon", "percent", "duration" })
	self:MakeBuffColorHandler(status)
	status:UpdateProfileData()
	return status
end

function Grid2:SetupDebuffStatus(statusKey, info)
	local status = self:CreateDebuffStatus(unpack(info))
	status.name = statusKey -- force name

	self:MakeDebuffColorHandler(status, info)
	self:RegisterStatus(status, { "color", "icon", "percent" })
	status:UpdateProfileData()
	return status
end

function Grid2:SetupAuraStatus(setup)
	for statusKey, info in pairs(setup.buffs) do
		self:SetupBuffStatus(statusKey, info)
	end
	for statusKey, info in pairs(setup.debuffs) do
		self:SetupDebuffStatus(statusKey, info)
	end
end

function Grid2:RegisterIndicatorStatuses(setup)
	for indicatorKey, statusPriorities in pairs(setup.status) do
		local indicator = self.indicators[indicatorKey]
		if (indicator) then
			for statusKey, priority in pairs(statusPriorities) do
				local status = self.statuses[statusKey]
				if (status and tonumber(priority)) then
					indicator:RegisterStatus(status, priority)
				end
			end
		end
	end
end

function Grid2:CreateCategories(categories)
	for categoryKey, categoryInfo in pairs(categories) do
		self:CreateCategory(categoryKey, categoryInfo.name, categoryInfo.priorities)
	end
end

function Grid2:RegisterCategoryStatuses(categories)
	for categoryKey, categoryInfo in pairs(categories) do
		local category = self.categories[categoryKey]
		if (category) then
			for statusKey, priority in pairs(categoryInfo.priorities) do
				local status = self.statuses[statusKey]
				if (status) then
					category:RegisterStatus(status, priority)
				end
			end
		end
	end
end

function Grid2:Setup()
	local setup = self.db.profile.setup
	if not setup then
		self:LoadOptions()
		local _, class = UnitClass("player")
		setup = Grid2Options:MakeDefaultSetup(class)
		self.db.profile.setup = setup
		Grid2Options:InitializeSetup()
	end

	self:SetupIndicators(setup)
	self:SetupAuraStatus(setup)
	self:RegisterIndicatorStatuses(setup)

	local categories = self.db.global.categories
	self:CreateCategories(categories)
	self:RegisterCategoryStatuses(categories)
end

--[[
/dump Grid2.db.profile.setup.status.alpha
/dump Grid2.db.profile.setup.buffs
/dump Grid2.db.profile.setup.auraGroupDebuffs
/dump Grid2.db.account
/dump Grid2.statuses["buff-ArcaneIntellect"]
--]]
