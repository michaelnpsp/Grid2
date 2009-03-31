local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")

function Grid2Options:GetCategory(categoryKey)
	local category = Grid2.db.profile.setup.categories[categoryKey]
	return category
end

function Grid2Options:RegisterIndicatorCategory(indicatorKey, categoryKey)
	Grid2.db.profile.setup.indicatorCategories[indicatorKey] = categoryKey
end

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

--print("AddCategoryOptions", categoryKey, category.name)
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
--/dump Grid2.db.profile.setup.categories

