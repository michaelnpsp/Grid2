local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

local Grid2Options = {
	options = {}
}

function Grid2Options:AddModule(parent, name, module, extraOptions)
	extraOptions = extraOptions or module.extraOptions
	module.extraOptions = nil
	if not extraOptions then return end

	local options = {
		type = "group",
		name = (module.menuName or module.name),
		desc = string.format(L["Options for %s."], module.name),
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
			name = type,
			desc = string.format(L["Options for %s."], type),
			args = {},
		}
		self.options.Grid2.args[type] = group
	end
	local options = {}
	group.args[element.name] = {
		type = "group",
		name = element.name,
		desc = string.format(L["Options for %s."], type),
		args = options,
	}
	for name, option in pairs(extraOptions) do
		options[name] = option
	end
end

function Grid2Options:AddModuleDebugMenu(name, module)
	self.options.Grid2.args.debug.args[name] = {
		type = "toggle",
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
	InitializeModuleOptions(Grid2)
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

_G.Grid2Options = Grid2Options
