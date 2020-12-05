local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("portrait", true, function(self, indicator)
	local layout = {}
	self:MakeIndicatorLevelOptions(indicator, layout)
	self:MakeIndicatorLocationOptions(indicator, layout)
	self:MakeIndicatorPortraitOptions(indicator, layout)
	self:AddIndicatorOptions(indicator, nil, layout )
end)

function Grid2Options:MakeIndicatorPortraitOptions(indicator, options)
	self:MakeHeaderOptions( options, "General" )
	options.type = {
		type   = "select",
		order  = 1.91,
		name   = L["Portrait Type"],
		desc   = L["Select the portrait to display."],
		get    = function () return indicator.dbx.portraitType or "2D" end,
		set    = function(_,v)
			indicator.dbx.portraitType = v
			self:RefreshIndicator(indicator, "Create")
		end,
		values = { ['2D'] = L['2D Model'], ['3D'] = L['3D Model'], ['class'] = L['Class Icon'] },
	}
	self:MakeHeaderOptions( options, "Appearance" )
	options.width = {
		type = "range",
		order = 11,
		name = L["Width"],
		desc = L["Adjust the width of the indicator."],
		min = 0,
		softMax = 100,
		step = 1,
		get = function () return indicator.dbx.width end,
		set = function (_, v)
			indicator.dbx.width = v>0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.height = {
		type = "range",
		order = 12,
		name = L["Height"],
		desc = L["Adjust the height of the indicator."],
		min = 0,
		softMax = 100,
		step = 1,
		get = function () return indicator.dbx.height end,
		set = function (_, v)
			indicator.dbx.height = v>0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.backEnabled = {
		type = "toggle",
		name = L["Enable Background"],
		desc = L["Enable Background"],
		order = 45,
		get = function () return indicator.dbx.backColor~=nil end,
		set = function (_, v)
			indicator.dbx.backColor = v and { r=0,g=0,b=0,a=1 } or nil
			self:RefreshIndicator(indicator, "Create")
		end,	
	}
	options.backColor = {
		type = "color",
		order = 46,
		name = L["Background Color"],
		desc = L["Background Color"],
		hasAlpha = true,
		get = function() return self:UnpackColor( indicator.dbx.backColor, "BLACK" ) end,
		set = function(info,r,g,b,a)
			self:PackColor( r,g,b,a, indicator.dbx, "backColor" )
			self:RefreshIndicator(indicator, "Create")
		end,
		hidden = function() return not indicator.dbx.backColor end
	}
	options.innerBorder= {
		type = "range",
		order = 47,
		name = L["Inner Border"],
		desc = L["Inner Border"],
		min = 0,
		max = 75,
		step = 1,
		get = function ()
			return indicator.dbx.innerBorder or 0
		end,
		set = function (_, v)
			indicator.dbx.innerBorder = v>0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return not indicator.dbx.backColor end
	}	
end
