-- bar for auras indicator options

local Grid2Options = Grid2Options
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("baraura", true, function(self, indicator)
	local options, statuses, filter  = {}, {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator,options)
	self:MakeIndicatorLocationOptions(indicator,options)
	self:MakeIndicatorBarAuraAppearanceOptions(indicator, options)
	self:MakeIndicatorBarAuraMiscOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:MakeIndicatorLoadOptions(indicator, filter)
	self:AddIndicatorOptions(indicator, statuses, options, nil, filter)
end)

-- Grid2Options:MakeIndicatorBarDisplayOptions()
function Grid2Options:MakeIndicatorBarAuraAppearanceOptions(indicator,options)
	self:MakeHeaderOptions( options, "Appearance" )
	options.orientation = {
		type = "select",
		order = 15,
		name = L["Orientation of the Bar"],
		desc = L["Set status bar orientation."],
		get = function ()
			return indicator.dbx.orientation or "DEFAULT"
		end,
		set = function (_, v)
			if v=="DEFAULT" then v= nil	end
			indicator:SetOrientation(v)
			self:RefreshIndicator(indicator, "Layout")
			if indicator.childName then
				self:RefreshIndicator( Grid2.indicators[indicator.childName], "Layout" )
			end
		end,
		values={ ["DEFAULT"]= L["DEFAULT"], ["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
	}
	options.barWidth= {
		type = "range",
		order = 30,
		name = L["Bar Width"],
		desc = L["Choose zero to set the bar to the same width as parent frame"],
		min = 0,
		softMax = 75,
		step = 1,
		get = function ()
			return indicator.dbx.width
		end,
		set = function (_, v)
			if v==0 then v= nil end
			indicator.dbx.width = v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.barHeight= {
		type = "range",
		order = 40,
		name = L["Bar Height"],
		desc = L["Choose zero to set the bar to the same height as parent frame"],
		min = 0,
		softMax = 75,
		step = 1,
		get = function ()
			return indicator.dbx.height
		end,
		set = function (_, v)
			if v==0 then v= nil end
			indicator.dbx.height = v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.reverseFill= {
		type = "toggle",
		name = L["Reverse Fill"],
		desc = L["Fill the bar in reverse."],
		order = 44,
		tristate = false,
		get = function () return indicator.dbx.reverseFill end,
		set = function (_, v)
			indicator.dbx.reverseFill = v or nil
			self:RefreshIndicator(indicator, "Layout")
			if indicator.childName then
				self:RefreshIndicator( Grid2.indicators[indicator.childName], "Layout" )
			end
		end,
	}
	options.interpol= {
		type = "toggle",
		name = L["Smooth animation"],
		desc = L["Animate bar changes."],
		order = 45,
		tristate = false,
		get = function () return indicator.dbx.interpolation~=nil end,
		set = function (_, v)
			indicator.dbx.interpolation = v and 1 or nil
			self:RefreshIndicator(indicator, "Create")
		end,
	}
	options.barColor = {
		type = "color",
		order = 47,
		name = L["Color"],
		desc = L["Color of the bar"],
		hasAlpha = true,
		get = function() return self:UnpackColor( indicator.dbx.barColor, "WHITE" ) end,
		set = function(info,r,g,b,a)
			self:PackColor( r,g,b,a, indicator.dbx, "barColor" )
			self:RefreshIndicator(indicator, "Layout")
		end,
		disabled = function() return indicator.dbx.barColor==nil end,
	}
	options.useStatusColor = {
		type = "toggle",
		name = L["Use Status Color"],
		desc = L["Use the default status color for the bar."],
		order = 46,
		tristate = false,
		get = function () return indicator.dbx.barColor==nil end,
		set = function (_, v)
			indicator.dbx.barColor = (not v) and {r=1, g=1, b=1, a=1} or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	self:MakeHeaderOptions( options, "Background" )
	options.enableBack = {
		type = "toggle",
		name = L["Enable Background"],
		desc = L["Enable Background"],
		order = 61,
		get = function () return indicator.dbx.backColor~=nil end,
		set = function (_, v)
			if v then
				indicator.dbx.backColor = { r=0,g=0,b=0,a=1 }
			else
				indicator.dbx.backColor, indicator.dbx.backTexture = nil, nil
			end
			self:RefreshIndicator(indicator, "Create")
		end,
	}
	options.backColor = {
		type = "color",
		order = 63,
		name = L["Background Color"],
		desc = L["Background Color"],
		hasAlpha = true,
		get = function() return self:UnpackColor( indicator.dbx.backColor, "BLACK" ) end,
		set = function(info,r,g,b,a)
			self:PackColor( r,g,b,a, indicator.dbx, "backColor" )
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return not indicator.dbx.backColor end,
	}
	options.backTexture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 64,
		name = L["Background Texture"],
		desc = L["Adjust the background texture."],
		get = function (info) return indicator.dbx.backTexture or self.MEDIA_VALUE_DEFAULT end,
		set = function (info, v)
			indicator.dbx.backTexture = v~=self.MEDIA_VALUE_DEFAULT and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = self.GetStatusBarValues,
		hidden = function() return not indicator.dbx.backColor end,
	}
end

-- Grid2Options:MakeIndicatorBarMiscOptions()
function Grid2Options:MakeIndicatorBarAuraMiscOptions(indicator, options)
	options.texture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 20,
		name = L["Frame Texture"],
		desc = L["Adjust the frame texture."],
		get = function (info) return indicator.dbx.texture or self.MEDIA_VALUE_DEFAULT end,
		set = function (info, v)
			indicator.dbx.texture = v~=self.MEDIA_VALUE_DEFAULT and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = self.GetStatusBarValues,
	}
	self:MakeHeaderOptions( options, "Display" )
	options.remaining = {
		type = "toggle",
		name = L["Remaining time"],
		desc = L["Show the remaining time."],
		order = 81,
		tristate = false,
		get = function () return not indicator.dbx.elapsed end,
		set = function (_, v)
			indicator.dbx.elapsed = not v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.elapsed = {
		type = "toggle",
		name = L["Elapsed time"],
		desc = L["Show the elapsed time."],
		order = 82,
		tristate = false,
		get = function () return indicator.dbx.elapsed end,
		set = function (_, v)
			indicator.dbx.elapsed = v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end
