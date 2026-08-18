local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("textaura", true, function(self, indicator)
	local statuses, options, filter = {}, {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator, options)
	self:MakeIndicatorLocationOptions(indicator, options)
	self:MakeIndicatorTextAuraCustomOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:MakeIndicatorLoadOptions(indicator, filter)
	self:AddIndicatorOptions(indicator, statuses, options, nil, filter)
end)

function Grid2Options:MakeIndicatorTextAuraCustomOptions(indicator, options)
	self:MakeHeaderOptions( options, "Appearance" )
	options.fontsize = {
		type = "range",
		order = 20,
		name = L["Font Size"],
		desc = L["Adjust the font size, select zero to use the theme default font size."],
		min = 0,
		max = 24,
		step = 1,
		get = function () return indicator.dbx.fontSize end,
		set = function (_, v)
			indicator.dbx.fontSize = v>0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.font = {
		type = "select", dialogControl = "LSM30_Font",
		order = 70,
		name = L["Font"],
		desc = L["Adjust the font settings"],
		get = function(info) return indicator.dbx.font or self.MEDIA_VALUE_DEFAULT end,
		set = function(info,v)
			indicator.dbx.font = self.MEDIA_VALUE_DEFAULT~=v and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = self.GetFontValues,
	}
	options.fontFlags = {
		type = "select",
		order = 75,
		name = L["Font Border"],
		desc = L["Set the font border type."],
		get = function ()
			if indicator.dbx.fontFlags then
				return (indicator.dbx.shadowDisabled and '0;' or '1;') .. indicator.dbx.fontFlags
			else
				return self.FONT_FLAGS_DEFAULT
			end
		end,
		set = function (_, v)
			local shadow, flags
			if v ~= self.FONT_FLAGS_DEFAULT then
				shadow, flags = strsplit(";",v)
			end
			indicator.dbx.fontFlags = flags
			indicator.dbx.shadowDisabled = (shadow=='0') or nil
			if indicator.dbx.shadowDisabled then
				indicator.dbx.shadowOffset = nil
			end
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = self.fontFlagsShadowDefValues,
	}
	options.shadowOffset = {
		type = "range",
		order = 76,
		softMin = 1,
		softMax = 8,
		step = 1,
		name = L["Shadow offset"],
		desc = L["Set the font shadow offset."],
		get = function () return indicator.dbx.shadowOffset or 1 end,
		set = function (_, v)
			indicator.dbx.shadowOffset = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.shadowDisabled end,
	}
	options.useStatusColor = {
		type = "toggle",
		name = L["Use Status Color"],
		desc = L["Use the default status color for the text."],
		order = 77,
		tristate = false,
		get = function () return indicator.dbx.textColor==nil end,
		set = function (_, v)
			indicator.dbx.textColor = (not v) and {r=1, g=1, b=1, a=1} or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.textColor = {
		type = "color",
		order = 78,
		name = L["Color"],
		desc = L["Text Color"],
		hasAlpha = true,
		get = function() return self:UnpackColor( indicator.dbx.textColor, "WHITE" ) end,
		set = function(info,r,g,b,a)
			self:PackColor( r,g,b,a, indicator.dbx, "textColor" )
			self:RefreshIndicator(indicator, "Layout")
		end,
		disabled = function() return indicator.dbx.textColor==nil end,
	}
	self:MakeHeaderOptions( options, "Display" )
	options.duration = {
		type = "toggle",
		width = "full",
		name = L["Show the time remaining."],
		desc = L["Show the time remaining."],
		order = 83,
		tristate = false,
		get = function () return true	end,
	}

end
