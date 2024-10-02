local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("background", false, function(self, indicator)
	local statuses, options = {}, {}
	self:MakeIndicatorBackgroundOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options)
end)

function Grid2Options:MakeIndicatorBackgroundOptions(indicator,options)
	options.headerback = {
			type = "header",
			order = 21,
			name = L["Background Indicator"],
	}
	options.backTexture = {
			type = "select", dialogControl = "LSM30_Statusbar",
			order = 22,
			name = L["Background Texture"],
			desc = L["Select the frame background texture."],
			get = function (info) return Grid2Frame.db.profile.frameTexture or "Gradient" end,
			set = function (info, v)
				Grid2Frame.db.profile.frameTexture = v
				Grid2Options:LayoutFrames()
			end,
			values = AceGUIWidgetLSMlists.statusbar,
	}
	options.backColor = {
		type = "color",
		hasAlpha = true,
		order = 23,
		name = L["Background Color"],
		desc = L["Sets the background color to use when no status is active."],
		get = function() return self:UnpackColor( Grid2Frame.db.profile.frameContentColor ) end,
		set = function( info, r,g,b,a )
			self:PackColor( r,g,b,a, Grid2Frame.db.profile, "frameContentColor" )
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.separation = {
		type = "description",
		order = 24,
		name = "\n",
	}
	options.headeback2 = {
			type = "header",
			order = 25,
			name = L["Secondary Background"],
	}
	options.back2Texture = {
			type = "select", dialogControl = "LSM30_Statusbar",
			order = 26,
			name = L["Background Texture"],
			get = function (info) return "Grid2 Flat" end,
			set = false,
			values = { ['Grid2 Flat'] =  "Interface\\Addons\\Grid2\\media\\white16x16" },
	}
	options.back2Color = {
			type = "color",
			order = 27,
			name = L["Background Color"],
			desc = L["Sets the color of the secondary background of each unit frame."],
			get = function()
				local c= Grid2Frame.db.profile.frameColor
				return c.r, c.g, c.b, c.a
			end,
			set = function(info,r,g,b,a)
				local c= Grid2Frame.db.profile.frameColor
				c.r, c.g, c.b, c.a = r, g, b, a
				Grid2Options:LayoutFrames()
			 end,
			hasAlpha = true,
	}
	options.message = {
		type = "description",
		order = 100,
		name = L['|cFFe0e000\nThese options are applied to the active theme, if you want to change the settings for another theme go to the Appearance tab inside the Themes section.'],
		hidden = self.ThemesAreDisabled,
	}
	return options
end
