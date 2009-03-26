local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")

function Grid2Options:GetCategory(categoryKey)
	local category = Grid2.db.profile.setup.categories[categoryKey]
	return category
end

function Grid2Options:RegisterIndicatorCategory(indicatorKey, categoryKey)
	Grid2.db.profile.setup.indicatorCategories[indicatorKey] = categoryKey
end

local categoryValues = {}
function Grid2Options.GetCategoryValues(info)
	local categories = Grid2.db.profile.setup.categories
	wipe(categoryValues)

	for categoryKey, category in pairs(categories) do
		local name = L[category.name] or category.name
		categoryValues[categoryKey] = name
	end

	return categoryValues
end

function Grid2Options.GetIndicatorCategory(info)
	local indicatorKey = info.arg
	local categoryKey = Grid2.db.profile.setup.indicatorCategories[indicatorKey]
	return categoryKey
end

function Grid2Options.SetIndicatorCategory(info, value)
	local indicatorKey = info.arg
	Grid2Options:RegisterIndicatorCategory(indicatorKey, value)
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

local function getCategoryValue(info)
	local categoryKey = info.arg.categoryKey
	local category = info.arg.category
	return category[info[# info]]
end

local function setCategoryValue(info, value)
	local categoryKey = info.arg.categoryKey
	local category = info.arg.category
	category[info[# info]] = value
	Grid2Frame:UpdateAllFrames()
end

local function getCategoryNameValue(info)
	local categoryKey = info.arg.categoryKey
	local category = info.arg.category
	local defaultName = L[categoryKey]
	local customName = category[info[# info]]
	if (not customName and defaultName) then
		return defaultName
	else
		return customName
	end
end

local function setCategoryNameValue(info, customName)
	local categoryKey = info.arg.categoryKey
	local category = info.arg.category
	local defaultName = L[categoryKey]
	customName = Grid2Options:GetValidatedName(customName)
	if (not defaultName or defaultName ~= customName) then
		category[info[# info]] = customName
	end
	Grid2Frame:UpdateAllFrames()
end

local function getCategoryPointValue(info)
	local categoryKey = info.arg.categoryKey
	local category = info.arg.category
	local point = category[info[# info]]
	return pointMap[point]
end

local function setCategoryPointValue(info, value)
	local categoryKey = info.arg.categoryKey
	local category = info.arg.category
	local point = pointMap[value]
	category[info[# info]] = point
	Grid2Frame:UpdateAllFrames()
end

local function DeleteCategory(info)
	local categoryKey = info.arg.categoryKey
	local categories = Grid2.db.profile.setup.categories
	categories[categoryKey] = nil

	Grid2Frame:UpdateAllFrames()
	local setup = Grid2.db.profile.setup
	Grid2Options:AddSetupCategoryOptions(setup, true)
end

local function AddCategoryOptions(categoryKey, category)
	local passValue = {categoryKey = categoryKey, category = category}
	local options = {
		name = {
			type = "input",
			order = 71,
			width = "full",
			name = L["Name"],
			usage = L["<CharacterOnlyString>"],
			get = getCategoryValue,
			set = setCategoryValue,
			arg = passValue,
		},
		point = {
		    type = 'select',
			order = 73,
			name = L["Align Point"],
			desc = L["Align this point on the indicator"],
		    values = pointValueList,
			get = getCategoryPointValue,
			set = setCategoryPointValue,
			arg = passValue,
		},
		relPoint = {
		    type = 'select',
			order = 75,
			name = L["Align relative to"],
			desc = L["Align my align point relative to"],
		    values = pointValueList,
			get = getCategoryPointValue,
			set = setCategoryPointValue,
			arg = passValue,
		},
		x = {
			type = "range",
			order = 77,
			name = L["X Offset"],
			desc = L["X - Horizontal Offset"],
			min = -50, max = 50, step = 1, bigStep = 1,
			get = getCategoryValue,
			set = setCategoryValue,
			arg = passValue,
		},
		y = {
			type = "range",
			order = 79,
			name = L["Y Offset"],
			desc = L["Y - Vertical Offset"],
			min = -50, max = 50, step = 1, bigStep = 1,
			get = getCategoryValue,
			set = setCategoryValue,
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
		    func = DeleteCategory,
			arg = passValue,
		}
	}

	Grid2Options:AddElement("category", category, options)
end


local newCategoryName = ""

local function getNewCategoryNameValue()
	return newCategoryName
end

local function setNewCategoryNameValue(info, customName)
	customName = Grid2Options:GetValidatedName(customName)
	newCategoryName = customName
end

local function NewCategory()
	newCategoryName = Grid2Options:GetValidatedName(newCategoryName)
	if (newCategoryName and newCategoryName ~= "") then
		local category = {relIndicator = nil, point = "TOPLEFT", relPoint = "TOPLEFT", x = 0, y = 0, name = newCategoryName}
		Grid2.db.profile.setup.categories[newCategoryName] = category
		AddCategoryOptions(newCategoryName, category)
	end
end

local function NewCategoryDisabled()
	newCategoryName = Grid2Options:GetValidatedName(newCategoryName)
	if (newCategoryName and newCategoryName ~= "") then
		local categories = Grid2.db.profile.setup.categories
		if (not categories[newCategoryName]) then
			return false
		end
	end
	return true
end

function ResetCategories()
	local setup = Grid2.db.profile.setup
	Grid2:SetupDefaultCategories(setup)
	Grid2Frame:UpdateAllFrames()
	Grid2Options:AddSetupCategoryOptions(setup, true)
end

local function AddCategoryGroup(reset)
	local options = {
		name = {
			type = "input",
			order = 1,
			width = "full",
			name = L["Name"],
			usage = L["<CharacterOnlyString>"],
			get = getNewCategoryNameValue,
			set = setNewCategoryNameValue,
		},
		newCategory = {
			type = "execute",
			order = 2,
			name = L["New Category"],
			desc = L["Create a new category of statuses."],
			func = NewCategory,
			disabled = NewCategoryDisabled,
		},
		resetCategoriesSpacer = {
			type = "header",
			order = 10,
			name = "",
		},
		resetCategories = {
			type = "execute",
			order = 11,
			name = L["Reset Categories"],
			desc = L["Reset categories to the default list."],
			func = ResetCategories,
		},
	}
	Grid2Options:AddElementGroup("category", options, reset)
end


function Grid2Options:AddSetupCategoryOptions(setup, reset)
	AddCategoryGroup(reset)

	local categories = setup.categories
	for key, category in pairs(categories) do
		AddCategoryOptions(key, category)
	end
end

Grid2Options:AddSetupCategoryOptions(Grid2.db.profile.setup)

