local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

local Grid2Options = {
	options = {
		Auras = {
			type = "group",
			name = "Auras",
			desc = L["Options for %s."]:format("Auras"),
			args = {},
		},
	}
}

function Grid2Options:AddModule(parent, name, module, extraOptions)
	extraOptions = extraOptions or module.extraOptions
	module.extraOptions = nil
	if not extraOptions then return end

	local options = {
		type = "group",
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

function Grid2Options:AddElement(type, element, extraOptions)
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
	local options = {}
	group.args[element.name] = {
		type = "group",
		name = element.name,
		desc = L["Options for %s."]:format(type),
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
-- If reset is true then discard the old options
function Grid2Options:AddElementGroup(type, extraOptions, reset)
	if not extraOptions then return end

	local group = self.options.Grid2.args[type]
	if (reset or not group) then
		group = {
			type = "group",
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
	self.options.Grid2.args.debug.args.reset = {
		type = "execute",
		order = 1,
		name = L["Reset"],
		desc = L["Reset and ReloadUI."],
		func = function ()
			Grid2DB = nil
			ReloadUI()
		end,
	}
	self.options.Grid2.args.debug.args.resetSpacer = {
		type = "header",
		order = 2,
		name = "",
	}
end

function Grid2Options:AddLayout(layoutName, layout)
	for type in pairs(layout.meta) do
		self.options.Grid2Layout.args.layouts.args[type].values[layoutName] = layoutName
	end
end

function Grid2Options:Initialize()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Grid2", self.options.Grid2)

	local function InitializeModuleOptions(parent)
		for name, module in parent:IterateModules() do
			Grid2Options:AddModule(parent.name, name, module)
			InitializeModuleOptions(module)
		end
	end
	self:AddModuleDebugMenu("Grid2", Grid2)
	self:AddResetDebugMenu()
	InitializeModuleOptions(Grid2)
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

	self.Initialize = nil
end

function Grid2Options:OnChatCommand(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(Grid2.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0").HandleCommand(Grid2, "grid2", "Grid2", input)
    end
end

function Grid2Options:GetValidatedName(name)
	name = name:gsub("%.", "")
	name = name:gsub("\"", "")
	name = name:gsub(" ", "")
	return name
end

_G.Grid2Options = Grid2Options
