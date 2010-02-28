local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")

function Grid2Options:RegisterIndicatorCategory(indicatorKey, categoryKey)
	Grid2.db.profile.setup.indicatorCategories[indicatorKey][categoryKey] = true
	-- ToDo: replicate the statuses
end

function Grid2Options:UnregisterIndicatorCategory(indicatorKey, categoryKey)
	Grid2.db.profile.setup.indicatorCategories[indicatorKey][categoryKey] = nil
	-- ToDo: remove the statuses
end

local function getCategoryNameValue(info)
	local category = info.arg
	local name = L[categoryKey.name] or categoryKey.name
	return name
end

local function setCategoryNameValue(info, customName)
	local category = info.arg
	local name = L[categoryKey.name] or categoryKey.name
	customName = Grid2Options:GetValidatedName(customName)
	if (not name or name ~= customName) then
		category.name = customName
	end
	Grid2Frame:UpdateAllFrames()
end

local function getCategoryValue(info)
	local category = info.arg
	return category[info[# info]]
end

local function setCategoryValue(info, value)
	local category = info.arg
	category[info[# info]] = value
	Grid2Frame:UpdateAllFrames()
end

local function DeleteCategory(info)
	local category = info.arg
	local categoryKey = category.name
	local categories = Grid2.db.account.categories
	categories[categoryKey] = nil

	Grid2Frame:UpdateAllFrames()
	local setup = Grid2.db.profile.setup
	Grid2Options:AddSetupCategoryOptions(setup, true)
end

local function GetAvailableStatusValues(category, statusAvailable)
	statusAvailable = statusAvailable or {}
	wipe(statusAvailable)

	for statusKey, status in Grid2:IterateStatuses() do
		statusAvailable[statusKey] = status.name
	end

	local statusKey
	for _, status in ipairs(category.statuses) do
		statusKey = status.name
		statusAvailable[statusKey] = nil
	end

	return statusAvailable
end

function Grid2Options.GetCategoryStatus(info, statusKey)
	local category = info.arg

	return category.priorities[statusKey]
end

function Grid2Options:RegisterCategoryStatus(category, status, priority)
	category.priorities[status.name] = priority
	category:RegisterStatus(status, priority)
end

function Grid2Options:UnregisterCategoryStatus(category, status)
	category:UnregisterStatus(status)
	category.priorities[status.name] = nil
end

function Grid2Options.SetCategoryStatusCurrent(info, value)
	local category = info.arg
	local statusKey = info[# info]

	for key, status in Grid2:IterateStatuses() do
		if (key == statusKey) then
			Grid2Options:UnregisterCategoryStatus(category, status)
			Grid2Frame:ResetAllFrames()
			Grid2Frame:UpdateAllFrames()

			local parentOption = info.options.args.category.args[category.name].args.statusesCurrent
			wipe(parentOption.args)
			Grid2Options:AddCategoryCurrentStatusOptions(category, parentOption.args)
		end
	end
end

function Grid2Options.SetCategoryStatus(info, statusKey, value)
	local category = info.arg

	for key, status in Grid2:IterateStatuses() do
		if (key == statusKey) then
			Grid2Options:RegisterCategoryStatus(category, status, 99)
			Grid2Frame:ResetAllFrames()
			Grid2Frame:UpdateAllFrames()

			local parentOption = info.options.args.category.args[category.name].args.statusesCurrent
			wipe(parentOption.args)
			Grid2Options:AddCategoryCurrentStatusOptions(category, parentOption.args)
		end
	end
end

local function StatusShiftUp(object, lowerStatus)
	for index, status in ipairs(object.statuses) do
		if (lowerStatus == status) then
			local newIndex = index - 1
			if (newIndex > 0) then
				local higherStatus = object.statuses[newIndex]
				local higherPriority = object:GetStatusPriority(higherStatus)
				local lowerPriority = object:GetStatusPriority(lowerStatus)
--print("StatusShiftUp", lowerPriority, higherPriority, lowerStatus.name, higherStatus.name)
				if (higherPriority == lowerPriority) then
					if (higherPriority == 99) then
						lowerPriority = lowerPriority - 1
					else
						higherPriority = higherPriority + 1
					end
				end
--print("StatusShiftUp", lowerPriority, higherPriority, lowerStatus.name, higherStatus.name)
				Grid2Options:SetStatusPriority(object, higherStatus, lowerPriority)
				Grid2Options:SetStatusPriority(object, lowerStatus, higherPriority)
				return true
			end
		end
	end
end

local function StatusShiftDown(object, higherStatus)
	for index, status in ipairs(object.statuses) do
		if (higherStatus == status) then
			local newIndex = index + 1
			if (newIndex <= # object.statuses) then
				local lowerStatus = object.statuses[newIndex]
				local higherPriority = object:GetStatusPriority(higherStatus)
				local lowerPriority = object:GetStatusPriority(lowerStatus)
				if (higherPriority == lowerPriority) then
					if (lowerPriority > 1) then
						lowerPriority = lowerPriority - 1
					else
						higherPriority = higherPriority + 1
					end
				end
--print("StatusShiftDown", lowerPriority, higherPriority, lowerStatus.name, higherStatus.name)
				Grid2Options:SetStatusPriority(object, higherStatus, lowerPriority)
				Grid2Options:SetStatusPriority(object, lowerStatus, higherPriority)
				return true
			end
		end
	end
end

function Grid2Options:AddCategoryCurrentStatusOptions(category, options)
	local statusKey, order
	for index, status in ipairs(category.statuses) do
		statusKey = status.name
		order = 4 * index
		options[statusKey] = {
			type = "toggle",
			order = order,
			name = status.name,
			desc = L["Select statuses to display with the indicator"],
			get = Grid2Options.GetCategoryStatus,
			set = Grid2Options.SetCategoryStatusCurrent,
			arg = category,
		}
		options[statusKey .. "U"] = {
		    type = "execute",
			order = order + 1,
			width = "half",
		    name = L["+"],
		    desc = L["Move the status higher in priority"],
			icon = "Interface\\Buttons\\UI-MicroButton-Spellbook-Up",
		    func = function (info)
		    	if (StatusShiftUp(category, status)) then
					local parentOption = info.options.args.category.args[category.name].args.statusesCurrent
					wipe(parentOption.args)
					Grid2Options:AddCategoryCurrentStatusOptions(category, parentOption.args)
				end
			end,
			arg = category,
		}
		options[statusKey .. "D"] = {
		    type = "execute",
			order = order + 2,
			width = "half",
		    name = L["-"],
		    desc = L["Move the status lower in priority"],
			icon = "Interface\\Buttons\\UI-MicroButton-Spellbook-Down",
		    func = function (info)
		    	if (StatusShiftDown(category, status)) then
					local parentOption = info.options.args.category.args[category.name].args.statusesCurrent
					wipe(parentOption.args)
					Grid2Options:AddCategoryCurrentStatusOptions(category, parentOption.args)
				end
			end,
			arg = category,
		}
		options[statusKey .. "S"] = {
			type = "header",
			order = order + 3,
			name = "",
		}
	end
end

local function AddCategoryOptions(category)
	local passValue = category
	local options = {
		name = {
			type = "input",
			order = 71,
			--width = "full",
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
		},
		statusesCurrent = {
			type = "group",
			order = 100,
			inline = true,
			name = L["Current Statuses"],
			desc = L["Current statuses in order of priority"],
			args = {},
		},
		statusesAvailable = {
		    type = "multiselect",
			order = 200,
			name = L["Available Statuses"],
			desc = L["Available statuses you may add"],
			values = function (info)
				local statusAvailable = GetAvailableStatusValues(category)
				return statusAvailable
			end,
			get = Grid2Options.GetCategoryStatus,
			set = Grid2Options.SetCategoryStatus,
			arg = category,
		}
	}
	Grid2Options:AddCategoryCurrentStatusOptions(category, options.statusesCurrent.args)

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
		local categoryInfo = {name = newCategoryName, priorities = {}}
		Grid2.db.account.categories[newCategoryName] = categoryInfo
		local category = Grid2:CreateCategory(newCategoryName, categoryInfo.name, categoryInfo.priorities)
		AddCategoryOptions(category)
	end
end

local function NewCategoryDisabled()
	newCategoryName = Grid2Options:GetValidatedName(newCategoryName)
	if (newCategoryName and newCategoryName ~= "") then
		local categories = Grid2.db.account.categories
		if (not categories[newCategoryName]) then
			return false
		end
	end
	return true
end

function ResetCategories()
	local setup = Grid2.db.profile.setup
	Grid2:SetupDefaultCategories(Grid2.db.account)
	Grid2Frame:UpdateAllFrames()
	Grid2Options:AddSetupCategoryOptions(setup, true)
end

local function AddCategoryGroup(reset)
	local options = {
		name = {
			type = "input",
			order = 1,
			--width = "full",
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
	Grid2Options:AddElementGroup("category", options, 80, reset)
end


function Grid2Options:AddSetupCategoryOptions(setup, reset)
	AddCategoryGroup(reset)

	for key, category in Grid2:IterateCategories() do
		AddCategoryOptions(category)
	end
end

--[[
/dump Grid2.db.account.categories
--]]

