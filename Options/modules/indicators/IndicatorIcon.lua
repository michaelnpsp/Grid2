local media = LibStub("LibSharedMedia-3.0", true)
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("icon", true, function(self, indicator)
	local statuses, options =  {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator, options)
	self:MakeIndicatorLocationOptions(indicator, options)
	self:MakeIndicatorIconSizeOptions(indicator, options)
	self:MakeIndicatorBorderOptions(indicator, options)
	self:MakeIndicatorCooldownOptions(indicator, options)
	self:MakeIndicatorAnimationOptions(indicator, options)
	self:MakeIndicatorIconCustomOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options )
end)

function Grid2Options:MakeIndicatorIconCustomOptions(indicator, options)
	self:MakeHeaderOptions( options, "Icon"  )
	options.disableIcon = {
		type = "toggle",
		name = L["Display Square"],
		desc = L["Display a flat square texture instead of the icon provided by the status."],
		order = 15,
		tristate = false,
		get = function () return indicator.dbx.disableIcon end,
		set = function (_, v)
			indicator.dbx.disableIcon = v or nil
			self:RefreshIndicator(indicator, "Update")
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
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	self:MakeHeaderOptions( options, "StackText" )
	options.fontOffsetX = {
		type = "range",
		order = 109.1,
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
		order = 109.2,
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
	options.fontJustify = {
		type = 'select',
		order = 106,
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
			local old = dbx.disableStack
			if v ~= "0" then
				local justify =  self.pointMapText[v]
				dbx.fontJustifyH = justify[1]
				dbx.fontJustifyV = justify[2]
				dbx.disableStack = nil
			else
				dbx.disableStack = true
			end
			self:RefreshIndicator( indicator, dbx.disableStack==old and "Layout" or "Create" )
		end,
	}
	options.font = {
		type = "select", dialogControl = "LSM30_Font",
		order = 107,
		name = L["Font"],
		desc = L["Adjust the font settings"],
		get = function (info) return indicator.dbx.font or Grid2Options.MEDIA_VALUE_DEFAULT end,
		set = function (info, v)
			indicator.dbx.font = Grid2Options.MEDIA_VALUE_DEFAULT~=v and v or nil
			self:RefreshIndicator(indicator, "Create")
		end,
		values = Grid2Options.GetFontValues,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontFlags = {
		type = "select",
		order = 108,
		name = L["Font Border"],
		desc = L["Set the font border type."],
		get = function ()
			local flags = indicator.dbx.fontFlags
			return (flags == nil and "OUTLINE") or (flags == "" and "NONE") or flags
		end,
		set = function (_, v)
			indicator.dbx.fontFlags =  v ~= "NONE" and v or ""
			self:RefreshIndicator(indicator, "Create")
		end,
		values = Grid2Options.fontFlagsValues,
		hidden = function() return indicator.dbx.disableStack end,
	}
	options.fontsize = {
		type = "range",
		order = 109,
		name = L["Font Size"],
		desc = L["Adjust the font size."],
		min = 6,
		max = 24,
		step = 1,
		get = function () return indicator.dbx.fontSize	end,
		set = function (_, v)
			indicator.dbx.fontSize = v
			self:RefreshIndicator(indicator, "Create")
		end,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontColor = {
		type = "color",
		order = 110,
		name = L["Color"],
		desc = L["Color"],
		hasAlpha = true,
		get = function() return self:UnpackColor( indicator.dbx.stackColor, "WHITE" ) end,
		set = function( info, r,g,b,a )
			self:PackColor( r,g,b,a, indicator.dbx, "stackColor" )
			self:RefreshIndicator(indicator, "Create")
		end,
		hidden= function() return indicator.dbx.disableStack end,
	}
end
