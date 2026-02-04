local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("health-current", "health", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.deadAsFullHealth = {
		type = "toggle",
		tristate = false,
		width = "full",
		order = 70,
		name = L["Show dead as having Full Health"],
		get = function () return status.dbx.deadAsFullHealth end,
		set = function (_, v)
			status.dbx.deadAsFullHealth = v or nil
			status:Refresh()
		end,
	}
end, {
	width = "full",
	color1 = L["Full Health"],
	color2 = L["Medium Health"],
	color3 = L["Low Health"],
	titleIcon = "Interface\\Icons\\Inv_potion_51",
})

Grid2Options:RegisterStatusOptions("heals-incoming", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	options.includePlayerHeals = {
		type = "toggle",
		order = 110,
		name = L["Include player heals"],
		desc = L["Include heals casted by me, if unchecked only other players heals are displayed."],
		tristate = false,
		get = function () return status.dbx.includePlayerHeals end,
		set = function (_, v)
			status.dbx.includePlayerHeals = v or nil
			status:Refresh()
			local overhealing = Grid2:GetStatusByName('overhealing')
			if overhealing then overhealing:Refresh() end
		end,
	}
end, {
	titleIcon = "Interface\\Icons\\Spell_Holy_DivineProvidence"
})

Grid2Options:RegisterStatusOptions("my-heals-incoming", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
end, {
	titleIcon = "Interface\\Icons\\Spell_Holy_DivineProvidence"
})

Grid2Options:RegisterStatusOptions("overhealing", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	options.minimumOver = {
		type = "input",
		order = 120,
		width = "full",
		name = L["Minimum value"],
		desc = L["Incoming overheals below the specified value will not be shown."],
		get = function ()
			return tostring(status.dbx.minimum or 0)
		end,
		set = function (_, v)
			v = tonumber(v) or 0
			status.dbx.minimum = v>0 and v or nil
			status:Refresh()
		end,
	}
end, {
	title = L["display heals above max hp"],
	titleIcon = "Interface\\Icons\\Spell_Holy_DivineProvidence"
})

Grid2Options:RegisterStatusOptions("health-deficit", "health", Grid2Options.MakeStatusColorOptions, {
	titleIcon = "Interface\\Icons\\Spell_shadow_lifedrain"
})

Grid2Options:RegisterStatusOptions( "death", "combat", Grid2Options.MakeStatusColorOptions,{
	titleIcon = "Interface\\ICONS\\Ability_creature_cursed_05",
} )

Grid2Options:RegisterStatusOptions( "feign-death", "combat", Grid2Options.MakeStatusColorOptions,{
	titleIcon = "Interface\\ICONS\\Ability_fiegndead"
} )
