local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("text",   true, function(self, indicator)
	local colors, statuses, options = {}, {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator, options)
	self:MakeIndicatorLocationOptions(indicator, options)
	self:MakeIndicatorTextCustomOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:MakeIndicatorStatusOptions(indicator.sideKick, colors)
	self:AddIndicatorOptions(indicator, statuses, options, colors)
end)

function Grid2Options:MakeIndicatorTextCustomOptions(indicator, options)
	self:MakeHeaderOptions( options, "Appearance" )
	options.textlength = {
		type = "range",
		order = 15,
		name = L["Text Length"],
		desc = L["Maximum number of characters to show."],
		min = 0,
		max = 20,
		step = 1,
		get = function () return indicator.dbx.textlength end,
		set = function (_, v)
			indicator.dbx.textlength = v
			self:RefreshIndicator(indicator, "Update")
		end,
	}
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
			indicator.dbx.fontFlags =  flags
			indicator.dbx.shadowDisabled = (shadow=='0') or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = self.fontFlagsShadowDefValues,
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
	self:MakeHeaderOptions( options, "Display" )
	options.duration = {
		type = "toggle",
		name = L["Show duration"],
		desc = L["Show the time remaining."],
		order = 83,
		tristate = false,
		get = function () return indicator.dbx.duration	end,
		set = function (_, v)
			indicator.dbx.duration = v or nil
			indicator.dbx.elapsed = nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.elapsed = {
		type = "toggle",
		name = L["Show elapsed time"],
		desc = L["Show the elapsed time."],
		order = 84,
		tristate = false,
		get = function () return indicator.dbx.elapsed end,
		set = function (_, v)
			indicator.dbx.elapsed = v or nil
			indicator.dbx.duration = nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.stack = {
		type = "toggle",
		name = L["Show stack"],
		desc = L["Show the number of stacks."],
		order = 85,
		tristate = false,
		get = function () return indicator.dbx.stack end,
		set = function (_, v)
			indicator.dbx.stack = v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.percent = {
		type = "toggle",
		name = L["Show percent"],
		desc = L["Show percent value"],
		order = 87,
		tristate = false,
		get = function () return indicator.dbx.percent end,
		set = function (_, v)
			indicator.dbx.percent = v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
end
