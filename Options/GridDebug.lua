--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

function Grid2Options:AddModuleDebugMenu(name, module)
	local option= {}
   	option[name]= {
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
	Grid2Options:AddModuleOptions( "Debug", nil,  option )
end

function Grid2Options:MakeDebugOptions(reset)
	self:AddModuleDebugMenu("Grid2", Grid2 )
	for name, module in Grid2:IterateModules() do
		self:AddModuleDebugMenu(name, module)
	end
end