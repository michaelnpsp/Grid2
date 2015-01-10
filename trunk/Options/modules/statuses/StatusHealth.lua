local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("health-current", "health", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.healthUpdate = {
		type  = "select",
		order = 35,
		name  = L["Update frequency"],
		desc  = L["Select the health update frequency."],
		get   = function () 
			return  (status.dbx.quickHealth and "q") or
					(status.dbx.frequentHealth and "p") or
					"n"
		end,
		set   = function (_, v)
			status.dbx.frequentHealth = (v=="p") or nil
			status.dbx.quickHealth = (v=="q") or nil
			status:UpdateDB()
			status:UpdateAllIndicators()
		end,
		values= { n = L["Normal"],  p = L["Fast"], q = L["Instant"] },
	}	
	self:MakeStatusToggleOptions(status, options, optionParams, "deadAsFullHealth")
end, {
	deadAsFullHealth = L["Show dead as having Full Health"],
	quickHealth = L["Instant Updates"],
	frequentHealth = L["Frequent Updates"],
	color1 = L["Full Health"],
	color2 = L["Medium Health"],
	color3 = L["Low Health"],
	width = "full",
	titleIcon = "Interface\\Icons\\Inv_potion_51"
})

Grid2Options:RegisterStatusOptions("heals-incoming", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	options.includePlayerHeals = {
		type = "toggle",
		order = 110,
		name = L["Include player heals"],
		desc = L["Display status for the player's heals."],
		tristate = false,
		get = function () return status.dbx.includePlayerHeals end,
		set = function (_, v)
			status.dbx.includePlayerHeals = v or nil
			status:UpdateDB()
		end,
	}
	options.healTypes = {
		type = "input",
		order = 120,
		width = "full",
		name = L["Minimum value"], 
		desc = L["Incoming heals below the specified value will not be shown."],
		get = function ()
			return tostring(status.dbx.flags or 0)
		end,
		set = function (_, v)
			status.dbx.flags = tonumber(v) or nil
			status:UpdateDB()
		end,
	}
	options.multiplier = {
		type = "range",
		order = 130,
		name = L["Heals multiplier"],
		desc = L["Apply this multiplier value to incoming heals."],
		min = 1,
		max = 10,
		step = 0.01,
		bigStep = 0.1,
		get = function () return status.dbx.multiplier	end,
		set = function (_, v)
			status.dbx.multiplier = tonumber(v) or 1
			status:UpdateDB()
		end,
	}	
end, {
	titleIcon ="Interface\\Icons\\Spell_Holy_DivineProvidence"
})

Grid2Options:RegisterStatusOptions("health-low", "health", function(self, status, options, optionParams)
	local min,max,step
	if status.dbx.threshold>10 then
		min,max,step = 1000, 250000, 500
	end
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusThresholdOptions(status, options, optionParams, min, max, step)
	options.useAbsoluteHealth = {
		type = "toggle",
		order = 110,
		name = L["Use Health Percent"],
		desc = L["Use Health Percent"],
		tristate = false,
		get = function () return status.dbx.threshold<10 end,
		set = function (_, v)
			status.dbx.threshold = v and 0.4 or 10000
			status:UpdateDB()
			self:MakeStatusOptions(status)
		end,
	}
end, {
	titleIcon = "Interface\\Icons\\Ability_rogue_bloodyeye"
})

Grid2Options:RegisterStatusOptions("health-deficit", "health", Grid2Options.MakeStatusColorThresholdOptions, {
	titleIcon = "Interface\\Icons\\Spell_shadow_lifedrain"
})

Grid2Options:RegisterStatusOptions( "death", "combat", Grid2Options.MakeStatusColorOptions,{
	titleIcon = "Interface\\ICONS\\Ability_creature_cursed_05.png",
} )

Grid2Options:RegisterStatusOptions( "feign-death", "combat", Grid2Options.MakeStatusColorOptions,{
	titleIcon = "Interface\\ICONS\\Ability_fiegndead"
} )
