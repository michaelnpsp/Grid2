--[[
	Debug options
--]]

local L = Grid2Options.L

local function AddModuleDebugMenu(name, module, options)
	options[name]= {
		type = "toggle",
		order = 3,
		name = name,
		desc = L["Toggle debugging for %s."]:format(name),
		get = function () return module.db.global.debug end,
		set = function ()
			local v = not module.db.global.debug
			module.db.global.debug = v or nil
			module.debugging = v
		end,
	}
end

local options = {

	modules = {
		type = "group",
		order = 10,
		name = L["Modules"],
		inline = true,
		args = {},
	},

	resetpos = {
		type = "execute",
		order = 260,
		name = L["Reset Position"],
		desc = L["Resets the Grid2 main window position and anchor."],
		func = function () Grid2Layout:ResetPosition() end,
	}

}

do
	local options = options.modules.args
	AddModuleDebugMenu("Grid2", Grid2, options )
	for name, module in Grid2:IterateModules() do
		AddModuleDebugMenu(name, module, options)
	end
end

-- options.separator2 = { type = "header", order = 100, name = "Maintenance" }


Grid2Options:AddGeneralOptions( "Debug", nil,  options )
