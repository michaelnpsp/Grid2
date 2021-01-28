local Grid2Options = Grid2Options
local L = Grid2Options.L

local theme = Grid2Options.editedTheme

local indicators = {}

Grid2Options:AddThemeOptions( "indicators", "indicators" , {

--=============================================================================

default = { type = "group", inline = true, order = 1, name = L["Default values"], desc = L["Default values"], args = {

orientation = {
		type = "select",
		order = 100,
		name = L["Default Orientation"],
		desc = L["Set default bars orientation."],
		get = function ()
			return theme.frame.orientation
		end,
		set = function (_, v)
			theme.frame.orientation = v
			Grid2Options:UpdateIndicators()
		end,
		values={["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
},

bartexture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 105,
		name = L["Default Texture"],
		desc = L["Select the default texture for bars indicators."],
		get = function (info) return theme.frame.barTexture or "Gradient" end,
		set = function (info, v)
			theme.frame.barTexture = v
			Grid2Options:UpdateIndicators()
		end,
		values = AceGUIWidgetLSMlists.statusbar,
},

font = {
		type = "select", dialogControl = "LSM30_Font",
		order = 110,
		name = L["Default Font"],
		desc = L["Select the default font for text indicators."],
		get = function(info) return theme.frame.font or Grid2Options.MEDIA_FONT_DEFAULT end,
		set = function(info,v)
			theme.frame.font = v
			Grid2Options:UpdateIndicators('text')
		end,
		values = AceGUIWidgetLSMlists.font,
},

fontFlagsShadow = {
		type = "select",
		order = 115,
		name = L["Default Font Border"],
		desc = L["Set the default border type for fonts."],
		get = function ()
			return (theme.frame.shadowDisabled and '0;' or '1;') .. (theme.frame.fontFlags or "NONE")
		end,
		set = function (_, v)
			local shadow, flags = strsplit(";",v)
			theme.frame.fontFlags =  flags ~= "NONE" and flags or nil
			theme.frame.shadowDisabled = (shadow=='0') or nil
			Grid2Options:UpdateIndicators('text')
		end,
		values = Grid2Options.fontFlagsShadowValues,
},

fontsize = {
		type = "range",
		order = 120,
		name = L["Font Size"],
		desc = L["Default font size for text indicators."],
		min = 6,
		max = 24,
		step = 1,
		get = function () return theme.frame.fontSize end,
		set = function (_, v)
			theme.frame.fontSize = v
			Grid2Options:UpdateIndicators()
		end,
},

iconsize = {
		type = "range",
		order = 130,
		name = L["Icon Size"],
		desc = L["Default size for icon indicators."],
		min = 5,
		max = 50,
		step = 1,
		get = function () return theme.frame.iconSize end,
		set = function (_, v)
			theme.frame.iconSize =v
			Grid2Options:UpdateIndicators()
		end,
},

} },

--=============================================================================

indicators = {
	type = "multiselect",
	order = 300,
	name = L["Enabled indicators"],
	desc = "",
	values = function()
		wipe(indicators)
		for baseKey,dbx in pairs(Grid2.db.profile.indicators) do
			if Grid2Options.typeMakeOptions[dbx.type] and not dbx.anchorTo then -- filter bar-color&text-color indicators
				local indicator = Grid2.indicators[baseKey]
				if indicator then
					indicators[baseKey] = Grid2Options:LocalizeIndicator( indicator, true )
				end
			end
		end
		return indicators
	end,
	get = function(info, key)
		return not (theme.indicators and theme.indicators[key])
	end,
	set = function(info, key,value)
		theme.indicators[key] = (not value) and true or nil
		Grid2:RefreshTheme()
	end,
},

} )

