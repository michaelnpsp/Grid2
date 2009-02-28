local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")

function Grid2Options:GetLocation(locationKey)
	local location = Grid2.db.profile.setup.locations[locationKey]
	return location
end

local locationValues = {}
function Grid2Options.GetLocationValues(info)
	local locations = Grid2.db.profile.setup.locations
	wipe(locationValues)

	for locationKey, location in pairs(locations) do
		local name = L[location.name] or location.name
		locationValues[locationKey] = name
	end

	return locationValues
end

function Grid2Options.GetIndicatorLocation(info)
	local indicatorKey = info.arg
	local locationKey = Grid2.db.profile.setup.indicatorLocations[indicatorKey]
	return locationKey
end

function Grid2Options.SetIndicatorLocation(info, value)
	local indicatorKey = info.arg
	Grid2.db.profile.setup.indicatorLocations[indicatorKey] = value
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
	local locationKey = info.arg.locationKey
	local location = info.arg.location
	return location[info[# info]]
end

local function setLocationValue(info, value)
	local locationKey = info.arg.locationKey
	local location = info.arg.location
	location[info[# info]] = value
	Grid2Frame:UpdateAllFrames()
end

local function getLocationNameValue(info)
	local locationKey = info.arg.locationKey
	local location = info.arg.location
	local defaultName = L[locationKey]
	local customName = location[info[# info]]
	if (not customName and defaultName) then
		return defaultName
	else
		return customName
	end
end

local function setLocationNameValue(info, customName)
	local locationKey = info.arg.locationKey
	local location = info.arg.location
	local defaultName = L[locationKey]
	customName = Grid2Options:GetValidatedName(customName)
	if (not defaultName or defaultName ~= customName) then
		location[info[# info]] = customName
	end
	Grid2Frame:UpdateAllFrames()
end

local function getLocationPointValue(info)
	local locationKey = info.arg.locationKey
	local location = info.arg.location
	local point = location[info[# info]]
	return pointMap[point]
end

local function setLocationPointValue(info, value)
	local locationKey = info.arg.locationKey
	local location = info.arg.location
	local point = pointMap[value]
	location[info[# info]] = point
	Grid2Frame:UpdateAllFrames()
end

local function DeleteLocation(info)
	local locationKey = info.arg.locationKey
	local locations = Grid2.db.profile.setup.locations
	locations[locationKey] = nil

	Grid2Frame:UpdateAllFrames()
	local setup = Grid2.db.profile.setup
	Grid2Options:AddSetupLocationOptions(setup, true)
end

local function AddLocationOptions(locationKey, location)
	local passValue = {locationKey = locationKey, location = location}
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

local function NewLocation()
	newLocationName = Grid2Options:GetValidatedName(newLocationName)
	if (newLocationName and newLocationName ~= "") then
		local location = {relIndicator = nil, point = "TOPLEFT", relPoint = "TOPLEFT", x = 0, y = 0, name = newLocationName}
		Grid2.db.profile.setup.locations[newLocationName] = location
		AddLocationOptions(newLocationName, location)
	end
end

local function NewLocationDisabled()
	newLocationName = Grid2Options:GetValidatedName(newLocationName)
	if (newLocationName and newLocationName ~= "") then
		local locations = Grid2.db.profile.setup.locations
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
	Grid2Options:AddSetupLocationOptions(setup, true)
end

local function AddLocationGroup(reset)
	local options = {
		name = {
			type = "input",
			order = 1,
			width = "full",
			name = L["Name"],
			usage = L["<CharacterOnlyString>"],
			get = getNewLocationNameValue,
			set = setNewLocationNameValue,
		},
		newLocation = {
			type = "execute",
			order = 2,
			name = L["New Location"],
			desc = L["Create a new location for an indicator."],
			func = NewLocation,
			disabled = NewLocationDisabled,
		},
		resetLocationsHeader = {
			type = "header",
			order = 10,
			name = "",
		},
		resetLocations = {
			type = "execute",
			order = 11,
			name = L["Reset Locations"],
			desc = L["Reset locations to the default list."],
			func = ResetLocations,
		},
	}
	Grid2Options:AddElementGroup("location", options, reset)
end


function Grid2Options:AddSetupLocationOptions(setup, reset)
	AddLocationGroup(reset)

	local locations = setup.locations
	for key, location in pairs(locations) do
		AddLocationOptions(key, location)
	end
end

Grid2Options:AddSetupLocationOptions(Grid2.db.profile.setup)

