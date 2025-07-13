local L = Grid2Options.L

local function ResetColors(status)
	local default = Grid2.defaults.profile.statuses[status.name]
	if default then
		wipe(status.dbx)
		Grid2.CopyTable(default, status.dbx)
		status:Refresh()
	end
end

local function MakeClassColorOption(status, options, type, translation)
	options.separator = options.separator or { type = "header", order = 1, name = "" }
	options['color-'..type] = {
		type = "color",
		name = (L["%s Color"]):format(L[translation]),
		order = options.separator.order,
		get = function ()
			local c = status.dbx.colors[type] or status.dbx.colors[translation] or Grid2.defaultColors.WHITE
			return c.r, c.g, c.b, c.a
		end,
		set = function (_, r, g, b, a)
			local colorKey = status.dbx.colors[type] and type or translation
			local c = status.dbx.colors[colorKey]
			c.r, c.g, c.b, c.a = r, g, b, a
			status:UpdateAllUnits()
		end,
	}
	options.separator.order = options.separator.order + 1
end

local function MakeCheckColorOption(status, options, key, option, nilable, invert)
	options[key] = option
	option.type  = "toggle"
	option.order = option.order or 100
	option.width = option.width or "full"
	option.name  = L[option.name]
	option.desc  = L[option.desc]
	option.get = function ()
		if invert then
			return not status.dbx[key]
		else
			return status.dbx[key]
		end
	end
	option.set = function (_, v)
		if invert then v = not v end
		if nilable then
			status.dbx[key] = v or nil
		else
			status.dbx[key] = v or false
		end
		status:Refresh()
	end
end

local function MakeResetColorsOption(status, options)
	options.resetsep = options.resetsep or { type = "header", order = 300, name = "" }
	options.resetcolors = {
		type = "execute",
		order = 310,
		name = L["Reset Colors"],
		desc = L["Reset status settings to the default values."],
		func = function () ResetColors(status) end,
		confirm = true,
	}
end

local function MakeSeparatorOption(options, order)
	options.separator = { type = "header", order = order or 99, name = "" }
end

Grid2Options:RegisterStatusOptions("classcolor", "color", function(self, status, options, optionParams)
	for class, translation in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		MakeClassColorOption(status, options, class, translation)
	end
	for _, class in ipairs{"Beast", "Demon", "Humanoid", "Elemental"} do
		MakeClassColorOption(status, options, class, L[class] )
	end
	MakeClassColorOption(status, options, "UNKNOWN_UNIT", "Default unit Color" )
	MakeClassColorOption(status, options, "UNKNOWN_PET",  "Default pet Color"  )
	MakeClassColorOption(status, options, "HOSTILE",      "Hostile unit Color" )
	MakeCheckColorOption(status, options, 'colorHostile', {
		name = "Color Hostile Units",
		desc = "Color Units that are hostile with the hostile color."
	})
	MakeResetColorsOption(status, options)
end)

Grid2Options:RegisterStatusOptions("reactioncolor", "color", function(self, status, options, optionParams)
	MakeClassColorOption(status, options, "hostile",  "Hostile unit"  )
	MakeClassColorOption(status, options, "neutral",  "Neutral unit"  )
	MakeClassColorOption(status, options, "friendly", "Friendly unit" )
	MakeClassColorOption(status, options, "tapped",   "Tapped unit"   )
	MakeCheckColorOption(status, options, 'disableGrouped', {
		name = "Disabled for grouped units",
		desc = "Disable the status for units in your group or raid.",
	}, true )
	MakeCheckColorOption(status, options, 'disablePlayers', {
		name = "Disabled for players",
		desc = "Disable the status for player characters.",
	}, true )
	MakeResetColorsOption(status, options)
end)

Grid2Options:RegisterStatusOptions("creaturecolor", "color", function(self, status, options, optionParams)
	for _, class in ipairs{"Beast", "Demon", "Humanoid", "Elemental"} do
		MakeClassColorOption(status, options, class, L[class])
	end
	MakeClassColorOption(status, options, "UNKNOWN_UNIT", "Default unit Color" )
	MakeClassColorOption(status, options, "HOSTILE",      "Charmed unit Color" )
	MakeCheckColorOption(status, options, 'colorHostile', {
		name = "Color Charmed Unit",
		desc = "Color Units that are charmed."
	})
	MakeResetColorsOption(status, options)
end)

Grid2Options:RegisterStatusOptions("friendcolor", "color", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	MakeSeparatorOption(options)
	MakeCheckColorOption(status, options, 'colorHostile', {
		order = 100,
		name = "Color Charmed Unit",
		desc = "Color Units that are charmed."
	})
	MakeCheckColorOption(status, options, 'disableHostile', {
		order = 110,
		name = "Disabled for hostile units",
		desc = "Disable the status for hostile units.",
	} )
	MakeResetColorsOption(status, options)
end, {
	color1= L["Player color"],
	color2= L["Pet color"],
	color3= L["Charmed unit Color"],
	width = "full",
})

Grid2Options:RegisterStatusOptions("hostilecolor", "color", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	MakeSeparatorOption(options)
	MakeCheckColorOption(status, options, 'enableFriendly', {
		name = "Disabled for non-hostile units",
		desc = "Disable the status for non-hostile units.",
	}, true, true )
	MakeResetColorsOption(status, options)
end)

Grid2Options:RegisterStatusOptions( "charmed", "combat", Grid2Options.MakeStatusColorOptions, {
	titleIcon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate",
} )

Grid2Options:RegisterStatusOptions( "color", "color", Grid2Options.MakeStatusColorOptions, {
	isDeletable = true
} )
