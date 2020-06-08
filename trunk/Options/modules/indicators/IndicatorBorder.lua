local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("border", false, function(self, indicator)
	local statuses, options = {}, {}
	self:MakeIndicatorBorderCustomOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options )
end)

function Grid2Options:MakeIndicatorBorderCustomOptions(indicator,options)
	options.borderColor = {
		type = "color",
		order = 10,
		name = L["Default Border Color"],
		desc = L["Sets the color for the border when no status is active."],
		hasAlpha = true,
		get = function()
			c = Grid2:MakeColor( Grid2Frame.db.profile.frameBorderColor, 'TRANSPARENT' )
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c = Grid2Frame.db.profile.frameBorderColor or {}
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Frame.db.profile.frameBorderColor = c
			Grid2Frame:UpdateIndicators()
		end,
	}
	options.sepColor = { order = 11, type = "description", name = "" }
	options.borderSize = {
		type = "range",
		order = 20,
		name = L["Border Size"],
		desc = L["Adjust the border of each unit's frame."],
		min = 1,
		max = 20,
		step = 1,
		get = function () return Grid2Frame.db.profile.frameBorder end,
		set = function (_, frameBorder)
			Grid2Frame.db.profile.frameBorder = frameBorder
			Grid2Frame:LayoutFrames(true)
		end,
		disabled = InCombatLockdown,
	}
	options.sepSize = { order = 21, type = "description", name = "" }
	options.borderTexture = {
		type = "select", dialogControl = "LSM30_Border",
		order = 30,
		name = L["Border Texture"],
		desc = L["Adjust the border texture."],
		get = function (info) return Grid2Frame.db.profile.frameBorderTexture or "Grid2 Flat" end,
		set = function (info, v)
			Grid2Frame.db.profile.frameBorderTexture = v
			Grid2Frame:LayoutFrames(true)
		end,
		values = AceGUIWidgetLSMlists.border,
	}
	options.message = {
		type = "description",
		order = 100,
		name = L['|cFFe0e000\nWarning: These options are applied to the active theme, if you want to change the settings for another theme go to the Appearance tab inside the Themes section.'],
		hidden = self.ThemesAreDisabled,
	}
end

