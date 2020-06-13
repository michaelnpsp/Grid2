local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("background", false, function(self, indicator)
	local statuses, options = {}, {}
	self:MakeIndicatorBackgroundOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options)
end)

function Grid2Options:MakeIndicatorBackgroundOptions(indicator,options)
	options.colorBackground = {
		type = "color",
		hasAlpha = true,
		order = 10,
		width = "full",
		name = L["Default Background Color"],
		desc = L["Sets the background color to use when no status is active."],
		get = function()
			local c= Grid2Frame.db.profile.frameContentColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c= Grid2Frame.db.profile.frameContentColor
			c.r, c.g, c.b, c.a = r, g, b, a
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.message = {
		type = "description",
		order = 100,
		name = L['|cFFe0e000\nWarning: These options are applied to the active theme, if you want to change the settings for another theme go to the Appearance tab inside the Themes section.'],
		hidden = self.ThemesAreDisabled,
	}
	return options
end
