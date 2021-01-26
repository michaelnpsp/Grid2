local L = Grid2Options.L

local options = {}

Grid2Options:MakeTitleOptions( options, Grid2.versionstring, L["GRID2_WELCOME"], nil, "Interface\\Addons\\Grid2\\media\\icon" )

options.description = { type = "description", order = 1, fontSize = "medium", name = "\n" .. L["GRID2_DESC"] .. "\n" }

options.debug = { type = "header", order = 2, name = L["Debug"] }
do
	local function AddModuleDebugMenu(name, module, options)
		options[name]= {
			type = "toggle",
			order = 10,
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
	AddModuleDebugMenu("Grid2", Grid2, options )
	for name, module in Grid2:IterateModules() do
		AddModuleDebugMenu(name, module, options)
	end
end

options.separator = { type = "description", order = 100, name = "" }
options.resetpost = {
	type = "execute",
	order = 110,
	name = L["Reset Position"],
	desc = L["Resets the Grid2 main window position and anchor."],
	func = function () Grid2Layout:ResetPosition() end,
}

Grid2Options:AddGeneralOptions( "About", nil, options, 500 )
