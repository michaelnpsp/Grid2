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
		name = L["Border Color"],
		desc = L["Sets the color for the border when no status is active."],
		hasAlpha = true,
		get = function() return self:UnpackColor( Grid2Frame.db.profile.frameBorderColor, 'TRANSPARENT' ) end,
		set = function( info, r,g,b,a )
			self:PackColor( r,g,b,a, Grid2Frame.db.profile, "frameBorderColor" )
			self:RefreshIndicator(indicator, "Update")
		end,
	}
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
	options.borderTexture = {
		type = "select", dialogControl = "LSM30_Border",
		order = 50,
		name = L["Border Texture"],
		desc = L["Adjust the border texture."],
		get = function (info) return Grid2Frame.db.profile.frameBorderTexture or "Grid2 Flat" end,
		set = function (info, v)
			Grid2Frame.db.profile.frameBorderTexture = v
			Grid2Frame:LayoutFrames(true)
		end,
		values = AceGUIWidgetLSMlists.border,
	}
	options.innerBordercolor = {
		type = "color",
		order = 40,
		name = L["Inner Border Color"],
		desc = L["Sets the color of the inner border of each unit frame"],
		get = function() return self:UnpackColor( Grid2Frame.db.profile.frameColor ) end,
		set = function( info, r,g,b,a )
			self:PackColor( r,g,b,a, Grid2Frame.db.profile, "frameColor" )
			Grid2Frame:LayoutFrames(true)
		 end,
		hasAlpha = true,
	}
	options.innerBorderDistance= {
		type = "range",
		order = 45,
		name = L["Inner Border Size"],
		desc = L["Sets the size of the inner border of each unit frame"],
		min = -16,
		max = 16,
		step = 1,
		get = function ()
			return Grid2Frame.db.profile.frameBorderDistance
		end,
		set = function (_, v)
			Grid2Frame.db.profile.frameBorderDistance = v
			Grid2Frame:LayoutFrames(true)
		end,
	}
	options.message = {
		type = "description",
		order = 100,
		name = L['|cFFe0e000\nThese options are applied to the active theme, if you want to change the settings for another theme go to the Appearance tab inside the Themes section.'],
		hidden = self.ThemesAreDisabled,
	}
end

