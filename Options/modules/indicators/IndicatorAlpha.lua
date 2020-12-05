local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("alpha",  false, function(self, indicator)
	local options, statuses = {}, {}
	self:MakeIndicatorAlphaOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options)
end)

function Grid2Options:MakeIndicatorAlphaOptions(indicator,options)
	options.header1 = { type = "header", order = 5, name = L["Default Alpha"] }
	options.defaultAlpha = {
		type = "range",
		order = 10,
		width = "normal",
		name = L["Default Alpha Value"],
		desc = L["Alpha/opacity when the indicator is not activated.\n0 = full transparent\n1 = full opaque"],
		min = 0,
		max = 1,
		step = 0.01,
		get = function () return indicator.dbx.defaultAlpha or 1 end,
		set = function (_, v) 
			indicator.dbx.defaultAlpha = v<.999 and v or nil	
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.header2 = { type = "header", order = 15, name = L["Active Alpha"] }
	options.alphaMode = {
		type = "toggle",
		name = L["Use Status Alpha"],
		desc = L["Check this option to use the alpha value provided by the active status."],
		order = 40,
		width = "normal",
		tristate = false,
		get = function () return indicator.dbx.alpha==nil end,
		set = function (_, v)
			indicator.dbx.alpha = (not v) and 0.4 or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.alpha = {
		type = "range",
		order = 30,
		width = "normal",
		name = L["Active Alpha Value"],
		desc = L["Alpha/Opacity value to apply to the frame when the indicator is activated.\n0 = full transparent\n1 = full opaque"],
		min = 0,
		max = 1,
		step = 0.01,
		get = function () return indicator.dbx.alpha or 0 end,
		set = function (_, v) 
			indicator.dbx.alpha = v	
			self:RefreshIndicator(indicator, "Update")
		end,
		disabled = function() return indicator.dbx.alpha==nil end,
	}
end