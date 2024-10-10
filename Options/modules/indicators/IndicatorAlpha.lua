local Grid2Options = Grid2Options

local L = Grid2Options.L

local function GetAvailableIndicatorValues()
	local t = { [0] = L['Unit Frame'] }
	for name, indicator in Grid2:IterateIndicators() do
		if indicator.dbx.type=='multibar' or indicator.dbx.type=='bar' then
			local option = Grid2Options.indicatorsOptions[name]
			if option then t[name] = string.format("|T%s:0|t%s", option.icon, option.name) end
		end
	end
	return t
end

Grid2Options:RegisterIndicatorOptions("alpha",  false, function(self, indicator)
	local options, statuses, filter = {}, {}, {}
	self:MakeIndicatorAlphaOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:MakeIndicatorLoadOptions(indicator,filter)
	self:AddIndicatorOptions(indicator, statuses, options, nil, filter)
end)

function Grid2Options:MakeIndicatorAlphaOptions(indicator,options)
	options.header0 = { type = "header", order = 1, name = L["General"] }
	options.indicator = {
		type = "select",
		name = L["Apply alpha to"],
		desc = L["Optionally you can choose to change the transparency of a specific indicator instead of the whole unit frame. Only bar style indicators are supported."],
		order = 5,
		get = function() return indicator.dbx.anchorTo or 0 end,
		set = function(_,v)
			for _,f in next, Grid2Frame.registeredFrames do
				indicator:GetFrame(f):SetAlpha(1)
			end
			indicator.dbx.anchorTo = (v~=0) and v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
		values = GetAvailableIndicatorValues,
	}
	options.header1 = { type = "header", order = 10, name = L["Active Alpha"] }
	options.alpha = {
		type = "range",
		order = 20,
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
	options.alphaMode = {
		type = "toggle",
		name = L["Use Status Alpha"],
		desc = L["Check this option to use the alpha value provided by the active status."],
		order = 30,
		width = 1.25,
		tristate = false,
		get = function () return indicator.dbx.alpha==nil end,
		set = function (_, v)
			indicator.dbx.alpha = (not v) and 0.4 or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.header2 = { type = "header", order = 40, name = L["Default Alpha"] }
	options.defaultAlpha = {
		type = "range",
		order = 50,
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
end
