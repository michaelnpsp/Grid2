local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options", true)
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")
local DBL = LibStub:GetLibrary("LibDBLayers-1.0")

function Grid2Options:GetLocation(locationKey)
	local locations = Grid2.locations
	local location = locations[locationKey]
	return location
end

function Grid2Options:UpdateLocation(locationKey)
	for _, indicator in Grid2:IterateIndicators() do
		if (indicator.dbx.location == locationKey) then
			Grid2Options:UpdateIndicator(indicator)
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end
	end
end

local layerValues
Grid2Options.locationLayers = {}
function Grid2Options.GetLocationLayerValues()
	if (not layerValues) then
		layerValues = {}
		for layer, index in pairs(DBL:GetLayerOrder(Grid2.dblData, "locations")) do
			local name = L[layer] or layer
			layerValues[index] = name
			Grid2Options.locationLayers[index] = layer
		end
	end
	return layerValues
end

-- Translate db <--> dropdown menu
local pointMap = {
	TOPLEFT = "1",
	LEFT = "2",
	BOTTOMLEFT = "3",
	TOP = "4",
	CENTER = "5",
	BOTTOM = "6",
	TOPRIGHT = "7",
	RIGHT = "8",
	BOTTOMRIGHT = "9",
	["1"] = "TOPLEFT",
	["2"] = "LEFT",
	["3"] = "BOTTOMLEFT",
	["4"] = "TOP",
	["5"] = "CENTER",
	["6"] = "BOTTOM",
	["7"] = "TOPRIGHT",
	["8"] = "RIGHT",
	["9"] = "BOTTOMRIGHT",
}

local pointValueList = {
	["1"] = L["TOPLEFT"],
	["2"] = L["LEFT"],
	["3"] = L["BOTTOMLEFT"],
	["4"] = L["TOP"],
	["5"] = L["CENTER"],
	["6"] = L["BOTTOM"],
	["7"] = L["TOPRIGHT"],
	["8"] = L["RIGHT"],
	["9"] = L["BOTTOMRIGHT"],
}

local function getLocationValue(info)
	local baseKey = info.arg
	local location = Grid2.locations[baseKey]
	return location[info[# info]]
end

local function setLocationValue(info, value)
	local baseKey = info.arg
	local location = Grid2.locations[baseKey]
	local dbx = DBL:GetOptionsDbx(Grid2.dblData, "locations", baseKey)

	location[info[# info]] = value
	dbx[info[# info]] = value

	Grid2Options:UpdateLocation(baseKey)
end

local function getLocationNameValue(info)
	local baseKey = info.arg
	local location = Grid2.locations[baseKey]
	local defaultName = L[baseKey]
	local customName = location[info[# info]]

	if (not customName and defaultName) then
		return defaultName
	else
		return customName
	end
end

local function setLocationNameValue(info, customName)
	local baseKey = info.arg
	local location = Grid2.locations[baseKey]
	local dbx = DBL:GetOptionsDbx(Grid2.dblData, "locations", baseKey)
	local defaultName = L[baseKey]

	customName = Grid2Options:GetValidatedName(customName)
	if (not defaultName or defaultName ~= customName) then
		location[info[# info]] = customName
		dbx[info[# info]] = customName
	end

	Grid2Options:UpdateLocation(baseKey)
end

local function getLocationPointValue(info)
	local baseKey = info.arg
	local location = Grid2.locations[baseKey]
	local point = location[info[# info]]
	return pointMap[point]
end

local function setLocationPointValue(info, value)
	local baseKey = info.arg
	local location = Grid2.locations[baseKey]
	local dbx = DBL:GetOptionsDbx(Grid2.dblData, "locations", baseKey)
	local point = pointMap[value]
	local key = info[# info]

	location[key] = point
	dbx[key] = point

	Grid2Options:UpdateLocation(baseKey)
end

local function DeleteLocation(info)
	local baseKey = info.arg
	local location = Grid2.locations[baseKey]
	local dblData = Grid2.dblData

	-- Remove from options
	local layer = DBL:GetObjectLayer(dblData, "locations", baseKey)
	DBL:DeleteLayerObject(dblData, "locations", layer, baseKey)
	DBL:FlattenSetupType(dblData, "locations")
	
	-- Remove from runtime
	local dbx = DBL:GetRuntimeDbx(dblData, "locations", baseKey)
	Grid2.locations[baseKey] = nil
	
	Grid2Frame:ResetAllFrames()
	Grid2Frame:UpdateAllFrames()

	Grid2Options:DeleteElement("location", baseKey)
	Grid2Options:MakeLocationOptions(dblData)
end

local function AddLocationOptions(baseKey)
	local location = Grid2.locations[baseKey]
	assert(location, "nil location " .. baseKey)
	local dbx = DBL:GetOptionsDbx(Grid2.dblData, "locations", baseKey)
	local passValue = baseKey
	local options = {
		name = {
			type = "input",
			order = 71,
			width = "full",
			name = L["Name"],
			usage = L["<CharacterOnlyString>"],
			get = getLocationValue,
			set = setLocationValue,
			arg = passValue,
		},
		point = {
		    type = 'select',
			order = 73,
			name = L["Align Point"],
			desc = L["Align this point on the indicator"],
		    values = pointValueList,
			get = getLocationPointValue,
			set = setLocationPointValue,
			arg = passValue,
		},
		relPoint = {
		    type = 'select',
			order = 75,
			name = L["Align relative to"],
			desc = L["Align my align point relative to"],
		    values = pointValueList,
			get = getLocationPointValue,
			set = setLocationPointValue,
			arg = passValue,
		},
		x = {
			type = "range",
			order = 77,
			name = L["X Offset"],
			desc = L["X - Horizontal Offset"],
			min = -50, max = 50, step = 1, bigStep = 1,
			get = getLocationValue,
			set = setLocationValue,
			arg = passValue,
		},
		y = {
			type = "range",
			order = 79,
			name = L["Y Offset"],
			desc = L["Y - Vertical Offset"],
			min = -50, max = 50, step = 1, bigStep = 1,
			get = getLocationValue,
			set = setLocationValue,
			arg = passValue,
		},
		deleteHeader = {
			type = "header",
			order = 81,
			name = "",
		},
		delete = {
		    type = "execute",
			order = 83,
		    name = L["Delete"],
		    func = DeleteLocation,
			arg = passValue,
		}
	}

	Grid2Options:AddElement("location", location, options)
end


local newLocationName = ""

local function getNewLocationNameValue()
	return newLocationName
end

local function setNewLocationNameValue(info, customName)
	customName = Grid2Options:GetValidatedName(customName)
	newLocationName = customName
end

local newObjectLayerIndex = 1
local function getNewObjectLayer(info)
	return newObjectLayerIndex
end

local function setNewObjectLayer(info, index)
	newObjectLayerIndex = index
end


local function NewLocation()
	newLocationName = Grid2Options:GetValidatedName(newLocationName)
	if (newLocationName and newLocationName ~= "") then
		local baseKey = newLocationName
		local dblData = Grid2.dblData
		local layer = Grid2Options.locationLayers[newObjectLayerIndex]

		--Create default settings
		DBL:SetupLayerObject(dblData, "locations", layer, baseKey, {relIndicator = nil, point = "TOPLEFT", relPoint = "TOPLEFT", x = 0, y = 0, name = newLocationName})

		--Create the new object in options settings then flatten so it is copied to runtime settings
		DBL:FlattenSetupType(dblData, "locations")
		
		--Find the flattened dbx
		local dbx = DBL:GetRuntimeDbx(dblData, "locations", baseKey)
		Grid2.locations[baseKey] = dbx
		
		AddLocationOptions(baseKey)
	end
end
		
local function NewLocationDisabled()
	newLocationName = Grid2Options:GetValidatedName(newLocationName)
	if (newLocationName and newLocationName ~= "") then
		local locations = Grid2.dblData.setupSrc.locations
		if (not locations[newLocationName]) then
			return false
		end
	end
	return true
end

function ResetLocations()
	local setup = Grid2.db.profile.setup
	Grid2:SetupDefaultLocations(setup)
	Grid2Frame:UpdateAllFrames()
	Grid2Options:MakeLocationOptions(locations, objects, Grid2.dblData.layerOrder.locations, true)
end

local function AddLocationGroup(reset)
	local options = {
		newName = {
			type = "input",
			order = 1,
			--width = "full",
			name = L["Name"],
			usage = L["<CharacterOnlyString>"],
			get = getNewLocationNameValue,
			set = setNewLocationNameValue,
		},
		newObjectLayer = {
		    type = 'select',
			order = 5,
			name = L["Layer"],
			desc = L["Layer level.  Higher layers (like Class or Spec) supercede lower ones like Account."],
		    values = Grid2Options.GetLocationLayerValues,
			get = getNewObjectLayer,
			set = setNewObjectLayer,
		},
		newLocation = {
			type = "execute",
			order = 9,
			name = L["New Location"],
			desc = L["Create a new location for an indicator."],
			func = NewLocation,
			disabled = NewLocationDisabled,
		},
		resetLocationsSpacer = {
			type = "header",
			order = 10,
			name = "",
		},
--[[
		resetLocations = {
			type = "execute",
			order = 111,
			name = L["Reset Locations"],
			desc = L["Reset locations to the default list."],
			func = ResetLocations,
		},
--]]
	}
	Grid2Options:AddElementGroup("location", options, 70, reset)
end


function Grid2Options:MakeLocationOptions(dblData, reset)
	AddLocationGroup(reset)

	if dblData then
		for baseKey, location in pairs(Grid2.locations) do
			AddLocationOptions(baseKey)
		end
	end
end



