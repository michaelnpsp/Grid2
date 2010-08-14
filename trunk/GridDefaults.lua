local DBL = LibStub:GetLibrary("LibDBLayers-1.0")

function Grid2:SetupLocations(setup, objects)
	local locations = Grid2.locations
	for baseKey, layer in pairs(setup) do
		local dbx = objects[layer][baseKey]
--print("SetupLocations:", layer, baseKey, dbx)
		locations[baseKey] = dbx
	end
end

function Grid2:SetupIndicators(setup, objects)
	for baseKey, layer in pairs(setup) do
		local dbx = objects[layer][baseKey]
		local setupFunc = self.setupFunc[dbx.type]
--print("SetupIndicators:", layer, baseKey, dbx.type, dbx.location, self.setupFunc[dbx.type])
		if (setupFunc) then
			setupFunc(baseKey, dbx)
		else
print("      *Could not find setupFunc for indicator", baseKey)
		end
	end
end

function Grid2:SetupStatuses(setup, objects)
	for baseKey, layer in pairs(setup) do
		local dbx = objects[layer][baseKey]
--print("SetupStatuses:", layer, baseKey, dbx.type, self.setupFunc[dbx.type])
		if (dbx.object) then
			local object = self.objectMap[dbx.object]
			if (object) then
				if (object.UpdateDB) then
					object.UpdateDB(dbx)
					print("SetupStatuses UpdateDB -->", baseKey)
				end
			else
				print("SetupStatuses did not find", dbx.object)
			end
		else
--print("SetupStatuses:", baseKey, dbx.type, self.setupFunc[dbx.type])
			self.setupFunc[dbx.type](baseKey, dbx)
		end
	end
end

function Grid2:SetupStatusMap(setup, objects)
	for baseKey, layer in pairs(setup) do
		local map = objects[layer][baseKey]
		local indicator = self.indicators[baseKey]
--print("SetupStatusMap:", layer, baseKey, indicator)
		if (indicator) then
			for statusKey, priority in pairs(map) do
				local status = self.statuses[statusKey]
				if (status and tonumber(priority)) then
					indicator:RegisterStatus(status, priority)
				else
print("      ***failed mapping:", statusKey, "status:", status, "priority:", priority, "layer:", layer, "indicator:", baseKey)
				end
			end
		else
print("      ***Could not find mapped indicator baseKey:", baseKey, "layerKey:", layer)
		end
	end
end
--[[
/dump Grid2.statuses["soulstone"]
--]]

-- Plugins can override this to set up additional object types
function Grid2:SetupCustom(setup, objects, profileCurrentKey)
end


local handlerArray = {}
function Grid2:MakeBuffColorHandler(status)
	assert(status.GetCount)
	local dbx = status.dbx
	local colorCount = dbx.colorCount or 1

	wipe(handlerArray)
	handlerArray[1] = "return function (self, unit)"
	local index = 2
	local color
	if (colorCount > 1) then
		handlerArray[index] = " local count = self:GetCount(unit)"
		index = index + 1
		for i = 1, colorCount - 1 do
			color = dbx["color" .. i]
			handlerArray[index] = (" if count == %d then return %s, %s, %s, %s end"):format(i, color.r, color.g, color.b, color.a)
			index = index + 1
		end
	end

	color = dbx[("color" .. colorCount)]
	handlerArray[index] = (" return %s, %s, %s, %s end"):format(color.r, color.g, color.b, color.a)

	local handler = table.concat(handlerArray)
	status.GetColor = assert(loadstring(handler))()
	return handler
end

function Grid2:MakeDebuffColorHandler(status)
	assert(status.GetCount)
	local dbx = status.dbx
	local colorCount = dbx.colorCount or 1
	if (colorCount <= 0) then
		self:Print("Invalid number of colors for debuff %s", status.name)
		return
	end

	wipe(handlerArray)
	handlerArray[1] = "return function (self, unit)"
	local index = 2
	local color
	if (colorCount > 1) then
		handlerArray[index] = " local count = self:GetCount(unit)"
		index = index + 1
		for i = 1, colorCount - 1 do
			color = dbx["color" .. i]
			handlerArray[index] = ("if count == %d then return %s, %s, %s, %s end"):format(i, color.r, color.g, color.b, color.a)
			index = index + 1
		end
	end
	color = dbx[("color" .. colorCount)]
	handlerArray[index] = (" return %s, %s, %s, %s end"):format(color.r, color.g, color.b, color.a)

	local handler = table.concat(handlerArray)
	status.GetColor = assert(loadstring(handler))()
	return handler
end

function Grid2:MakeTextHandler(status)
	status.GetText = status.GetTextDefault
	assert(status.GetText, "nil GetTextDefault")
	return status.GetText
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


local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey
local _, classKey = UnitClass("player")

local dblData

-- Plugins hook this to check if they need to call their options side to update their defaults.
function Grid2:UpgradeDefaults(dblData)
	local flatten
	
	if (Grid2Options) then
		flatten = DBL:UpgradeDefaults("Grid2Options", dblData, Grid2Options.UpgradeDefaults, "account", 1, dblData.classKey, 1) or flatten
	end

	return flatten
end

function Grid2:GetSetupObjects()
	local Grid2DB = Grid2DB or {}
	local dblData = DBL:InitializeRuntime("Grid2", Grid2DB)
	self.dblData = dblData

	-- Load options for old versions (defaults versions to 0)
-- print("Grid2:GetSetupObjects")
	local upgrade = self:LoadOptions(dblData)
-- print("Grid2:GetSetupObjects upgrade", upgrade)

	if (upgrade) then
		-- Upgrade defaults for those old versions
		local flatten = self:UpgradeDefaults(dblData)
-- print("Grid2:GetSetupObjects flatten", flatten)

		-- Flatten and move the defaults from Grid2OptionsDB to Grid2DB
		if (flatten) then
			Grid2Options:FlattenDefaults(dblData)
-- print("Grid2:GetSetupObjects flattened")
		end
	end

	-- Local Grid2DB objects are up to date and ready for use
	local profileCurrentKey = dblData.profileCurrentKey
	local setup = Grid2DB["setup-flat"]
	local objects = Grid2DB["objects"]

	assert(setup, "nil setup")
	assert(objects, "nil objects")
	return setup, objects, profileCurrentKey
end

function Grid2:Setup()
-- New Setup
	local setup, objects, profileCurrentKey = self:GetSetupObjects()
	self:SetupLocations(setup.locations[profileCurrentKey], objects.locations)
	self:SetupIndicators(setup.indicators[profileCurrentKey], objects.indicators)
	self:SetupStatuses(setup.statuses[profileCurrentKey], objects.statuses)

--[[
local categories = self.dbx.categories
self:CreateCategories(categories)
self:RegisterCategoryStatuses(categories)
--]]
	self:SetupStatusMap(setup.statusMap[profileCurrentKey], objects.statusMap)

	--Hook Opportunity for plugin types
	self:SetupCustom(setup, objects, profileCurrentKey)
end

--[[
/dump Grid2.statuses["death"]
/dump Grid2.statuses["buff-ArcaneIntellect"]
--]]
