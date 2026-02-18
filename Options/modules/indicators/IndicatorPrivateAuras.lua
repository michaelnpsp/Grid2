if not (C_UnitAuras and C_UnitAuras.AddPrivateAuraAnchor) then return end

local Grid2Options = Grid2Options
local L = Grid2Options.L
local indexValues = { 1, 2, 3, 4 }

Grid2Options:RegisterIndicatorOptions("privateauras", true, function(self, indicator)
	local options, filter = {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator,options)
	self:MakeIndicatorLocationOptions(indicator, options)
	self:MakeIndicatorPrivateAurasCustomOptions(indicator, options)
	self:MakeIndicatorLoadOptions(indicator, filter)
	self:AddIndicatorOptions(indicator, nil, options, nil, filter)
end)

function Grid2Options:MakeIndicatorPrivateAurasCustomOptions( indicator, options )
	options.auraIndex1 = {
		type = "select",
		order = 1.98,
		name = L["First Aura"],
		desc = L["Select the index of the first private aura to display."],
		get = function () return indicator.dbx.auraIndex or 1 end,
		set = function (_, v)
			indicator.dbx.auraIndex = v
			if v>(indicator.dbx.maxIcons or 2) then
				indicator.dbx.maxIcons = v
			end
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = indexValues,
	}
	options.auraIndex2 = {
		type = "select",
		order = 1.99,
		name = L["Last Aura"],
		desc = L["Select the index of the last private aura to display."],
		get = function () return indicator.dbx.maxIcons or 2 end,
		set = function (_, v)
			if v>=(indicator.dbx.auraIndex or 1) then
				indicator.dbx.maxIcons = v
				self:RefreshIndicator(indicator, "Layout")
			end
		end,
		values = indexValues,
	}
	self:MakeHeaderOptions( options, "Appearance"  )
	options.orientation = {
		type = "select",
		order = 11,
		name = L["Orientation"],
		desc = L["Set the icons orientation."],
		get = function () return indicator.dbx.orientation or "HORIZONTAL" end,
		set = function (_, v)
			indicator.dbx.orientation = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		values={ VERTICAL = L["VERTICAL"], HORIZONTAL = L["HORIZONTAL"] }
	}
	options.iconSpacing = {
		type = "range",
		order = 12,
		name = L["Icon Spacing"],
		desc = L["Adjust the space between icons."],
		softMin = 0,
		max = 50,
		step = 1,
		get = function () return indicator.dbx.iconSpacing or 1 end,
		set = function (_, v)
			indicator.dbx.iconSpacing = v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.iconSizeSource = {
		type = "select",
		order = 13,
		name = L["Icon Size"],
		desc = L["Default:\nUse the size specified by the active theme.\nPixels:\nUser defined size in pixels.\nPercent:\nUser defined size as percent of the frame height."],
		get = function (info) return (indicator.dbx.iconSize==nil and 1) or (indicator.dbx.iconSize>1 and 2) or 3 end,
		set = function (info, v)
			indicator.dbx.iconSize = (v==3 and .4) or (v==2 and 14) or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = { L["Default"], L["Pixels"], L["Percent"] },
	}
	options.iconSizeAbsolute = {
		type = "range",
		order = 14,
		name = L["Icon Size"],
		desc = L["Adjust the size of the icon."],
		min = 5,
		softMax = 50,
		step = 1,
		get = function ()
			return indicator.dbx.iconSize or Grid2Frame.db.profile.iconSize
		end,
		set = function (_, v)
			indicator.dbx.iconSize = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		disabled = function() return indicator.dbx.iconSize==nil end,
		hidden = function()	return (indicator.dbx.iconSize or Grid2Frame.db.profile.iconSize or 0)<=1 end,
	}
	options.iconSizeRelative = {
		type = "range",
		order = 15,
		name = L["Icon Size"],
		desc = L["Adjust the size of the icon."],
		min = 0.01,
		max = 1,
		step = 0.01,
		isPercent = true,
		get = function ()
			return indicator.dbx.iconSize or Grid2Frame.db.profile.iconSize
		end,
		set = function (_, v)
			indicator.dbx.iconSize = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		disabled = function() return indicator.dbx.iconSize==nil end,
		hidden = function() return (indicator.dbx.iconSize or Grid2Frame.db.profile.iconSize or 1)>1 end,
	}
	options.borderScale = {
		type = "range",
		order = 16,
		name = L["Border Scale"],
		desc = L["Sets the scale of the border. Select zero to automatic scale the border depending of the icon size."],
		softMin  = 0,
		softMax  = 10,
		step = 0.1,
		get = function () return indicator.dbx.borderScale or 0 end,
		set = function (_, v)
			indicator.dbx.borderScale = v~=0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	self:MakeHeaderOptions( options, "Cooldown" )
	options.enableCooldown = {
		type = "toggle",
		order = 130,
		name = L["Enable Cooldown"],
		desc = L["Display a cooldown animation."],
		get = function () return not indicator.dbx.disableCooldown end,
		set = function (_, v)
			indicator.dbx.disableCooldown = (not v) or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.enableNumbers = { -- "Show numbers for cooldowns" setting must be enabled in blizzard options.
		type = "toggle",
		order = 135,
		name = L["Enable Numbers"],
		desc = L["Display cooldown numbers."],
		get = function () return not indicator.dbx.disableCooldownNumbers end,
		set = function (_, v)
			indicator.dbx.disableCooldownNumbers = (not v) or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.disableCooldown end,
	}
	options.durationHeader ={ type = "header", order = 149, name = L["Duration"] }
	options.enableDuration = {
		type = "toggle",
		order = 150,
		name = L["Enable Duration Text"],
		desc = L["Display duration numbers."],
		width = "full",
		get = function () return indicator.dbx.durationAnchor~=nil end,
		set = function (_, v)
			indicator.dbx.durationAnchor = v and {point="TOP", relativePoint="BOTTOM", offsetX=0, offsetY=-1} or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.durationRelPoint = {
		type = 'select',
		order = 155,
		name = L["Location"],
		desc = L["Align my align point relative to"],
		values = self.pointValueList,
		get = function() return self.pointMap[indicator.dbx.durationAnchor.relativePoint] end,
		set = function(_, v)
			indicator.dbx.durationAnchor.relativePoint = self.pointMap[v]
			indicator.dbx.durationAnchor.point = self.pointMap[v]
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.durationAnchor==nil end,
	}
	options.durationPoint = {
		type = 'select',
		order = 160,
		name = L["Align Point"],
		desc = L["Align this point on the indicator"],
		values = self.pointValueList,
		get = function() return self.pointMap[indicator.dbx.durationAnchor.point] end,
		set = function(_, v)
			indicator.dbx.durationAnchor.point = self.pointMap[v]
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.durationAnchor==nil end,
	}
	options.durationX = {
		type = "range",
		order = 170,
		name = L["X Offset"],
		desc = L["X - Horizontal Offset"],
		softMin = -50, softMax = 50, step = 1, bigStep = 1,
		get = function() return indicator.dbx.durationAnchor.offsetX end,
		set = function(_, v)
			indicator.dbx.durationAnchor.offsetX = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.durationAnchor==nil end,
	}
	options.durationY = {
		type = "range",
		order = 180,
		name = L["Y Offset"],
		desc = L["Y - Vertical Offset"],
		softMin = -50, softMax = 50, step = 1, bigStep = 1,
		get = function() return indicator.dbx.durationAnchor.offsetY end,
		set = function(_, v)
			indicator.dbx.durationAnchor.offsetY = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.durationAnchor==nil end,
	}
	self:MakeHeaderOptions( options, "Tooltip" )
	options.tooltipEnabled = {
		type = "toggle",
		order = 255,
		name = L["Enable Tooltips"],
		desc = L["Display a tooltip when the mouse is over a private aura icon."],
		get = function () return not indicator.dbx.disableTooltip end,
		set = function (_, v)
			indicator.dbx.disableTooltip = (not v) or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end


