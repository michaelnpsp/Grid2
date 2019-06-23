local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("alpha",  false, function(self, indicator)
	local options, statuses = {}, {}
	self:MakeIndicatorAlphaOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options)
end)

function Grid2Options:MakeIndicatorAlphaOptions(indicator,options)
	options.ignore = {
		type = "toggle",
		name = "|cffffd200".. L["Use Global Alpha"] .."|r",
		desc = L["Discard opacity value provided by the statuses and instead use a global user defined opacity."],
		order = 10,
		width = "normal",
		tristate = false,
		get = function () return indicator.dbx.alpha~=nil end,
		set = function (_, v)
			indicator.dbx.alpha = v and 0.25 or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.alpha = {
		type = "range",
		order = 20,
		width = "normal",
		name = L["Alpha Value"],
		desc = L["Alpha/Opacity value to apply to the frame when the indicator is enabled.\n0 = full transparent\n1 = full opaque"],
		min = 0,
		max = 1,
		step = 0.01,
		get = function () return indicator.dbx.alpha or 0 end,
		set = function (_, v) 
			indicator.dbx.alpha = v	
			self:RefreshIndicator(indicator, "Update")
		end,
		hidden = function() return not indicator.dbx.alpha end,
	}
end