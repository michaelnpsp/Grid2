local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")
local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

local DBL = LibStub:GetLibrary("LibDBLayers-1.0")

local Grid2Options = {
	options = {
		Auras = {
			type = "group",
			name = "Auras",
			desc = L["Options for %s."]:format("Auras"),
			args = {},
		},
	},
	plugins = {},
	typeMakeOptions = {},
	optionParams = {},
}

Grid2Options.versionstring = "Grid2 v"..GetAddOnMetadata("Grid2", "Version")

function Grid2Options:AddOptionHandler(typeKey, funcMakeOptions, optionParams)
	Grid2Options.typeMakeOptions[typeKey] = funcMakeOptions
	Grid2Options.optionParams[typeKey] = optionParams
end

function Grid2Options:AddModule(parent, name, module, extraOptions)
	extraOptions = extraOptions or module.extraOptions
	module.extraOptions = nil
	if not extraOptions then return end

	local options = {
		type = "group",
		order = module.menuOrder or 400,
		name = (module.menuName or module.name),
		desc = L["Options for %s."]:format(module.name),
		args = {},
	}

	for name, option in pairs(extraOptions) do
		options.args[name] = option
	end

	local parent_options = parent and self.options[parent]
	if parent_options then
		parent_options.args[name] = options
	end
	self.options[name] = options

	self:AddModuleDebugMenu(name, module)
end

function Grid2Options:AddElement(elementType, element, extraOptions)
	--Elementtype: a string representing the options
	--Element: The element itself
	--ExtraOptions: The aceconfig structure
	--
	--Adds options for this element to the main menu.
	--Will create a menu of type elementType if it doesn't already exist.
	--That in turn must be a group, with elements matching 'element'
	--
	--The OO here is a bit laboured :(
	
	extraOptions = extraOptions or element.extraOptions
	element.extraOptions = nil
	if not extraOptions then return end

	local group = self.options.Grid2.args[elementType]
	if not group then
		group = {
			type = "group",
			name = L[elementType] or elementType,
			desc = L["Options for %s."]:format(elementType),
			args = {},
		}
		self.options.Grid2.args[elementType] = group
	end
	local options = {}
	group.args[element.name] = {
		type = "group",
		name = element.name,
		desc = L["Options for %s."]:format(element.name),
		args = options,
	}
	for name, option in pairs(extraOptions) do
		options[name] = option
	end
end

function Grid2Options:DeleteElement(type, elementKey)
	local group = self.options.Grid2.args[type]
	if not group then
		return
	end
	group.args[elementKey] = nil
end

-- Adds meta options for the list of elements from AddElement
-- Order < 100 is reserved for Grid elements
-- If reset is true then discard the old options
function Grid2Options:AddElementGroup(type, extraOptions, order, reset)
	if not extraOptions then return end

	local group = self.options.Grid2.args[type]
	if (reset or not group) then
		group = {
			type = "group",
			order = order,
			name = L[type] or type,
			desc = L["Options for %s."]:format(type),
			args = {},
		}
		self.options.Grid2.args[type] = group
	end
	local options = group.args
	for name, option in pairs(extraOptions) do
		options[name] = option
	end
end

function Grid2Options:AddElementSubTypeGroup(type, subType, subTypeOptions, reset)
	local group = self.options.Grid2.args[type]
	if (not group) then
		group = {
			type = "group",
			name = L[type] or type,
			desc = L["Options for %s."]:format(type),
			args = {},
		}
		self.options.Grid2.args[type] = group
	end

	local subGroup = group.args[subType]
	local options = {}
	if (reset or not subGroup) then
		subGroup = {
			type = "group",
			name = L[subType] or subType,
			desc = L["Options for %s."]:format(subType),
			args = options,
		}
		group.args[subType] = subGroup
	end
	if (subTypeOptions) then
		for name, option in pairs(subTypeOptions) do
			options[name] = option
		end
	end
	return subGroup
end


function Grid2Options:AddElementSubType(type, subType, element, extraOptions)
	extraOptions = extraOptions or element.extraOptions
	element.extraOptions = nil
	if not extraOptions then return end

	local group = self.options.Grid2.args[type]
	if not group then
		group = {
			type = "group",
			name = L[type] or type,
			desc = L["Options for %s."]:format(type),
			args = {},
		}
		self.options.Grid2.args[type] = group
	end

	local subGroup = group.args[subType]
	if (not subGroup) then
		subGroup = self:AddElementSubTypeGroup(type, subType)
	end

	local options = {}
	subGroup.args[element.name] = {
		type = "group",
		name = element.name,
		desc = L["Options for %s."]:format(type),
		args = options,
	}
	for name, option in pairs(extraOptions) do
		options[name] = option
	end
end


function Grid2Options:AddAura(type, name, spell, owner, r, g, b, ...)
	local group = self.options.Auras.args[type]
	if not group then
		group = {
			type = "group",
			name = type,
			desc = L["Options for %s."]:format(type),
			args = {},
		}
		self.options.Auras.args[type] = group
	end
	group.args[name] = {
	}
end

function Grid2Options:AddModuleDebugMenu(name, module)
	self.options.Grid2.args.debug.args[name] = {
		type = "toggle",
		order = 3,
		name = name,
		desc = L["Toggle debugging for %s."]:format(name),
		get = function ()
			return module.db.profile.debug
		end,
		set = function ()
			local v = not module.db.profile.debug
			module.db.profile.debug = v
			module.debugging = v
		end,
	}
end

function Grid2Options:AddResetDebugMenu()
	local opt = self.options.Grid2.args.debug.args

	opt.reset = {
		type = "execute",
		order = 1,
		name = L["Reset"],
		desc = L["Reset and ReloadUI."],
		func = function ()
			Grid2DB = nil
			Grid2OptionsDB = nil
			ReloadUI()
		end,
	}
	opt.resetSetup = {
		type = "execute",
		order = 2,
		name = L["Reset Setup"],
		desc = L["Reset current setup and ReloadUI."],
		func = function ()
			Grid2.db.profile.setup = nil
			ReloadUI()
		end,
	}
	opt.resetSpacer = {
		type = "header",
		order = 3,
		name = "",
	}
end

function Grid2Options:AddLayout(layoutName, layout)
	for type in pairs(layout.meta) do
		self.options.Grid2Layout.args.layouts.args[type].values[layoutName] = layoutName
	end
end

function Grid2Options:Initialize()
	self = self or Grid2Options
	Grid2OptionsDB = Grid2OptionsDB or {}
	Grid2Options.dblData = DBL:InitializeOptions("Grid2", Grid2OptionsDB)
--print("Grid2Options:Initialize", Grid2.dblData, Grid2Options.dblData, Grid2Options.dblData.setupSrc)

--old
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Grid2", self.options.Grid2)
	Grid2:Print("Grid2Options Initializing...")


	local function InitializeModuleOptions(parent)
		for name, module in parent:IterateModules() do
			Grid2Options:AddModule(parent.name, name, module)
			InitializeModuleOptions(module)
		end
	end
	self:AddModuleDebugMenu("Grid2", Grid2)
	self:AddResetDebugMenu()

	InitializeModuleOptions(Grid2)

	--can't do this immediately :(
	--Grid2Options:MakeOptions(Grid2.db.profile.setup)
	--why? Well it looks like GridDefaults calls LoadOptions which causes this to run...
	--here's an example:
	
	--[[ --fixMe: Shoudl this every happen?
	Message: Interface\AddOns\Grid2Options\GridIndicators.lua:671: attempt to index local 'element' (a nil value)
Time: 01/05/10 23:50:28
Count: 1
Stack: Interface\AddOns\Grid2Options\GridIndicators.lua:671: in function `AddIndicatorElement'
Interface\AddOns\Grid2Options\GridIndicators.lua:416: in function <Interface\AddOns\Grid2Options\GridIndicators.lua:375>
Interface\AddOns\Grid2Options\GridIndicators.lua:698: in function `AddSetupIndicatorsOptions'
Interface\AddOns\Grid2Options\core.lua:311: in function `MakeOptions'
Interface\AddOns\Grid2Options\core.lua:262: in function `Initialize'
Interface\AddOns\Grid2\GridCore.lua:188: in function <Interface\AddOns\Grid2\GridCore.lua:183>
...ns\Grid2StatusRaidDebuffs\Grid2StatusRaidDebuffs.lua:375: in function <...ns\Grid2StatusRaidDebuffs\Grid2StatusRaidDebuffs.lua:374>
...dOns\Grid2StatusTargetIcon\Grid2StatusTargetIcon.lua:170: in function `LoadOptions'
...dOns\Grid2StatusTargetIcon\Grid2StatusTargetIcon.lua:186: in function `GetCurrentSetup'
Interface\AddOns\Grid2\GridDefaults.lua:176: in function `Setup'
Interface\AddOns\Grid2\GridCore.lua:216: in function <Interface\AddOns\Grid2\GridCore.lua:203>
(tail call): ?
[C]: ?
[string "safecall Dispatcher[1]"]:9: in function <[string "safecall Dispatcher[1]"]:5>
(tail call): ?
...face\AddOns\Grid2\Libs\AceAddon-3.0\AceAddon-3.0.lua:539: in function `EnableAddon
	]]

	--so feed in a dummy
	Grid2Options:MakeOptions()
	
	--which makes all this obsolete I think:
	for _, location in Grid2:IterateLocations() do
		self:AddElement("location", location)
	end
	for _, indicator in Grid2:IterateIndicators() do
		self:AddElement("indicator", indicator)
	end
	for _, status in Grid2:IterateStatuses() do
		self:AddElement("status", status)
	end

	for name, layout in pairs(Grid2Layout.layoutSettings) do
		self:AddLayout(name, layout)
	end

	--instead put through a quick empty call...
	--

	local ACD3 = LibStub("AceConfigDialog-3.0")
	--self.optionsFrame = ACD3:AddToBlizOptions("Grid2", Grid2.versionstring, nil, "General")
	for key, value in pairs(self.options.Grid2.args) do
		if (key ~= "General") then
			ACD3:AddToBlizOptions("Grid2", value.name, LG["Grid2"], key)
		end
	end

	self.Initialize = nil
end

-- This method gets called just before the options menu is shown
function Grid2Options:MakeOptions(dblData)
	self:MakeLocationOptions(dblData)
	self:MakeIndicatorOptions(dblData)
	self:MakeStatusOptions(dblData)
	-- self:AddSetupCategoryOptions(setup)
end


function Grid2Options:OnChatCommand(input)
	--This will have been called shortly before invokation.
	--Grid2Options:MakeOptions(Grid2.db.profile.setup)
    if (not input or input:trim() == "") then
        InterfaceOptionsFrame_OpenToCategory(Grid2.optionsFrame)
    else
--        LibStub("AceConfigCmd-3.0").HandleCommand(Grid2, "grid2", "Grid2", input)
		if (LibStub("AceConfigDialog-3.0").OpenFrames["Grid2"]) then
			LibStub("AceConfigDialog-3.0"):Close("Grid2")
		else
			LibStub("AceConfigDialog-3.0"):Open("Grid2")
		end
   end
end

function Grid2Options:GetValidatedName(name)
	name = name:gsub("%.", "")
	name = name:gsub("\"", "")
	name = name:gsub(" ", "")
	return name
end

_G.Grid2Options = Grid2Options
