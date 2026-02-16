local L = Grid2Options.L

function Grid2Options:MakeStatusHealthFormatOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 100)
	options.displayRawNumbers = {
		type = "toggle",
		tristate = false,
		width = "full",
		order = 200,
		name = L["Abreviate Large Numbers"],
		get = function () return not status.dbx.displayRawNumbers end,
		set = function (_, v)
			status.dbx.displayRawNumbers = not v or nil
			status.dbx.truncateWhenZero = nil
			status:Refresh()
		end,
	}
	options.truncateWhenZero = {
		type = "toggle",
		tristate = false,
		width = "full",
		order = 210,
		name = L["Truncate when zero"],
		get = function () return status.dbx.truncateWhenZero end,
		set = function (_, v)
			status.dbx.truncateWhenZero = v or nil
			status:Refresh()
		end,
		disabled = function() return not status.dbx.displayRawNumbers end,
	}
end

Grid2Options:RegisterStatusOptions("health-current", "health", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	options.deadAsFullHealth = {
		type = "toggle",
		tristate = false,
		width = "full",
		order = 110,
		name = L["Show dead as having Full Health"],
		get = function () return status.dbx.deadAsFullHealth end,
		set = function (_, v)
			status.dbx.deadAsFullHealth = v or nil
			status:Refresh()
		end,
	}
	self:MakeStatusHealthFormatOptions(status, options, optionParams)
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
	self:MakeStatusHealthFormatOptions(status, options, optionParams)
end, {
	titleIcon = "Interface\\Icons\\Spell_Holy_DivineProvidence"
})

Grid2Options:RegisterStatusOptions("my-heals-incoming", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	self:MakeStatusHealthFormatOptions(status, options, optionParams)
end, {
	titleIcon = "Interface\\Icons\\Spell_Holy_DivineProvidence"
})

Grid2Options:RegisterStatusOptions("health-deficit", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	self:MakeStatusHealthFormatOptions(status, options, optionParams)
end, {
	titleIcon = "Interface\\Icons\\Spell_shadow_lifedrain"
})

Grid2Options:RegisterStatusOptions( "death", "combat", Grid2Options.MakeStatusColorOptions,{
	titleIcon = "Interface\\ICONS\\Ability_creature_cursed_05",
} )

Grid2Options:RegisterStatusOptions( "feign-death", "combat", Grid2Options.MakeStatusColorOptions,{
	titleIcon = "Interface\\ICONS\\Ability_fiegndead"
} )
