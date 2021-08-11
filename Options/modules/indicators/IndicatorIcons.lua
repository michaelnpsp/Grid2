local media = LibStub("LibSharedMedia-3.0", true)
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("icons", true, function(self, indicator)
	local statuses, options =  {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator,options)
	self:MakeIndicatorAuraIconsLocationOptions(indicator, options)
	self:MakeIndicatorAuraIconsSizeOptions(indicator, options)
	self:MakeIndicatorAuraIconsBorderOptions(indicator, options)
	self:MakeIndicatorAuraIconsCustomOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options )
end)


function Grid2Options:MakeIndicatorAuraIconsBorderOptions(indicator, options, optionParams)
	self:MakeIndicatorBorderOptions(indicator, options)
	options.color1.hidden = function() return indicator.dbx.useStatusColor end
	options.borderOpacity = {
		type = "range",
		order = 20.5,
		name = L["Opacity"],
		desc = L["Set the opacity."],
		min = 0,
		max = 1,
		step = 0.01,
		bigStep = 0.05,
		get = function () return indicator.dbx.borderOpacity or 1 end,
		set = function (_, v)
			indicator.dbx.borderOpacity = v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.useStatusColor = {
		type = "toggle",
		name = L["Use Status Color"],
		desc = L["Always use the status color for the border"],
		order = 25,
		tristate = false,
		get = function () return indicator.dbx.useStatusColor end,
		set = function (_, v)
			indicator.dbx.useStatusColor = v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end


function Grid2Options:MakeIndicatorAuraIconsSizeOptions(indicator, options, optionParams)
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
	options.maxIcons = {
		type = "range",
		order = 16,
		name = L["Max Icons"],
		desc = L["Select maximum number of icons to display."],
		min = 1,
		max = 6,
		step = 1,
		get = function () return indicator.dbx.maxIcons or 3 end,
		set = function (_, v)
			indicator.dbx.maxIcons= v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.maxIconsPerRow = {
		type = "range",
		order = 17,
		name = L["Icons per row"],
		desc = L["Select the number of icons per row."],
		min = 1,
		max = 6,
		step = 1,
		get = function () return indicator.dbx.maxIconsPerRow or 3 end,
		set = function (_, v)
			indicator.dbx.maxIconsPerRow= v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.disableIcons = {
		type = "toggle",
		name = L["Display Squares"],
		desc = L["Display flat square textures instead of the icons provided by the statuses."],
		order = 18,
		tristate = false,
		get = function () return indicator.dbx.disableIcons end,
		set = function (_, v)
			indicator.dbx.disableIcons = v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end

function Grid2Options:MakeIndicatorAuraIconsLocationOptions(indicator, options)
	self:MakeIndicatorLocationOptions(indicator, options)
	options.point = nil
end

function Grid2Options:MakeIndicatorAuraIconsCustomOptions(indicator, options)
	self:MakeHeaderOptions( options, "Appearance"  )
	self:MakeHeaderOptions( options, "StackText" )
	options.fontJustify = {
		type = 'select',
		order = 101,
		name = L["Text Location"],
		desc = L["Text Location"],
		values = Grid2Options.pointValueListExtra,
		get = function()
			if not indicator.dbx.disableStack then
				local JustifyH = indicator.dbx.fontJustifyH or "CENTER"
				local JustifyV = indicator.dbx.fontJustifyV or "MIDDLE"
				return self.pointMapText[ JustifyH..JustifyV ]
			end
			return "0"
		end,
		set = function(_, v)
			local dbx = indicator.dbx
			if v ~= "0" then
				local justify =  self.pointMapText[v]
				dbx.fontJustifyH = justify[1]
				dbx.fontJustifyV = justify[2]
				dbx.disableStack = nil
			else
				dbx.disableStack = true
			end
			self:RefreshIndicator( indicator, "Layout")
		end,
	}
	options.font = {
		type = "select", dialogControl = "LSM30_Font",
		order = 102,
		name = L["Font"],
		desc = L["Adjust the font settings"],
		get = function (info) return indicator.dbx.font or self.MEDIA_VALUE_DEFAULT end,
		set = function (info, v)
			indicator.dbx.font = self.MEDIA_VALUE_DEFAULT~=v and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = self.GetFontValues,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontFlags = {
		type = "select",
		order = 103,
		name = L["Font Border"],
		desc = L["Set the font border type."],
		get = function ()
			local flags = indicator.dbx.fontFlags
			return (flags == nil and "OUTLINE") or (flags == "" and "NONE") or flags
		end,
		set = function (_, v)
			indicator.dbx.fontFlags =  v ~= "NONE" and v or ""
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = Grid2Options.fontFlagsValues,
		hidden = function() return indicator.dbx.disableStack end,
	}
	options.fontsize = {
		type = "range",
		order = 104,
		name = L["Font Size"],
		desc = L["Adjust the font size."],
		min = 6,
		max = 24,
		step = 1,
		get = function () return indicator.dbx.fontSize	or 9 end,
		set = function (_, v)
			indicator.dbx.fontSize = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontOffsetX = {
		type = "range",
		order = 105,
		name = L["X Offset"],
		desc = L["Adjust the horizontal offset of the text"],
		softMin  = -50,
		softMax = 50,
		step = 1,
		get = function () return indicator.dbx.fontOffsetX or 0	end,
		set = function (_, v)
			indicator.dbx.fontOffsetX = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontOffsetY = {
		type = "range",
		order = 106,
		name = L["Y Offset"],
		desc = L["Adjust the vertical offset of the text"],
		softMin  = -50,
		softMax = 50,
		step = 1,
		get = function () return indicator.dbx.fontOffsetY or 0	end,
		set = function (_, v)
			indicator.dbx.fontOffsetY = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontColor = {
		type = "color",
		order = 110,
		name = L["Color"],
		desc = L["Color"],
		hasAlpha = true,
		get = function() return self:UnpackColor( indicator.dbx.colorStack, "WHITE" ) end,
		set = function( info, r,g,b,a )
			self:PackColor( r,g,b,a, indicator.dbx, "colorStack" )
			self:RefreshIndicator(indicator, "Layout" )
		 end,
		hidden= function() return indicator.dbx.disableStack end,
	}
	self:MakeHeaderOptions( options, "Cooldown" )
	options.disableCooldown = {
		type = "toggle",
		order = 130,
		name = L["Disable Cooldown"],
		desc = L["Disable the Cooldown Frame"],
		tristate = false,
		get = function () return indicator.dbx.disableCooldown end,
		set = function (_, v)
			indicator.dbx.disableCooldown = v or nil
			self:RefreshIndicator(indicator, "Layout" )
		end,
	}
	options.reverseCooldown = {
		type = "toggle",
		order = 135,
		name = L["Reverse Cooldown"],
		desc = L["Set cooldown to become darker over time instead of lighter."],
		tristate = false,
		get = function () return indicator.dbx.reverseCooldown end,
		set = function (_, v)
			indicator.dbx.reverseCooldown = v or nil
			self:RefreshIndicator(indicator, "Layout" )
		end,
		hidden= function() return indicator.dbx.disableCooldown end,
	}
	options.disableOmniCC = {
		type = "toggle",
		order = 140,
		name = L["Disable OmniCC"],
		desc = L["Disable OmniCC"],
		tristate = false,
		get = function () return indicator.dbx.disableOmniCC end,
		set = function (_, v)
			indicator.dbx.disableOmniCC = v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden= function() return indicator.dbx.disableCooldown end,
	}
end
