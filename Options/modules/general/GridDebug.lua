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

local options = {}

options.separator1 = { type = "header", order = 1, name = "Modules" }

AddModuleDebugMenu("Grid2", Grid2, options )
for name, module in Grid2:IterateModules() do
	AddModuleDebugMenu(name, module, options)
end

options.separator2 = { type = "header", order = 100, name = "Maintenance" }

options.resetpos = {
	type = "execute",
	order = 260,
	name = L["Reset Position"],
	desc = L["Resets the Grid2 main window position and anchor."],
	func = function () Grid2Layout:ResetPosition() end,
}

Grid2Options:AddGeneralOptions( "Debug", nil,  options )
