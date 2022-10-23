local media = LibStub("LibSharedMedia-3.0", true)
local L = Grid2Options.L

local SHAPES_VALUES = {
	[0] = L["Square"],
	[1] = L["Rounded Square"],
	[2] = L["Circle"],
	[3] = L["Diamond"],
	[4] = L["Triangle"],
	[5] = L["Right Triangle"],
	[6] = L["Semi Circle"],
	[7] = L["Quarter Circle"],
}

local SHAPE_ANGLE = { [0] = L["0 degrees"], [1] = L["90 degrees"], [2] = L["180 degrees"], [3] = L["270 degrees"] }

Grid2Options:RegisterIndicatorOptions("shape", true, function(self, indicator)
	local statuses, options =  {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator, options)
	self:MakeIndicatorLocationOptions(indicator, options)
	self:MakeIndicatorHighlightEffectOptions(indicator, options)
	self:MakeIndicatorShapeCustomOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options )
end)

function Grid2Options:MakeIndicatorShapeCustomOptions(indicator, options)
	self:MakeHeaderOptions( options, "Shape" )
	options.shapeType = {
		type = "select",
		order = 11,
		name = L["Shape"],
		desc = L["Select the shape to display"],
		get = function (info) return indicator.dbx.iconIndex or 0 end,
		set = function (info, v)
			indicator.dbx.iconIndex = v~=0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = SHAPES_VALUES,
	}
	options.shapeRotation = {
		type = "select",
		order = 12,
		name = L["Rotation"],
		desc = L["Select the shape angle"],
		get = function (info) return indicator.dbx.iconRotation or 0 end,
		set = function (info, v)
			indicator.dbx.iconRotation = v~=0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = SHAPE_ANGLE,
	}
	options.shapeSize = {
		type = "range",
		order = 13,
		name = L["Size"],
		desc = L["Adjust the size of the shape, select zero to use the theme default icon size."],
		min = 0,
		softMax = 50,
		step = 1,
		get = function ()
			return indicator.dbx.size
		end,
		set = function (_, v)
			indicator.dbx.size = v>0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	self:MakeHeaderOptions( options, "Shadow" )
	options.shadowEnabled = {
		type = "toggle",
		name = L["Enable Shadow"],
		desc = L["Display a Shadow under the Shape."],
		order = 31,
		tristate = false,
		get = function () return indicator.dbx.shadowEnabled end,
		set = function (_, v)
			indicator.dbx.shadowEnabled = v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.shadowSize = {
		type = "range",
		order = 32,
		name = L["Extra Size"],
		desc = L["Extra size of the shadow shape."],
		min = 0,
		softMax = 20,
		step = 1,
		get = function () return indicator.dbx.shadowSize or 0 end,
		set = function (_, v)
			indicator.dbx.shadowSize = v>0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.shadowEnabled==nil end,
	}
	options.shadowX = {
		type = "range",
		order = 33,
		name = L["X Offset"],
		desc = L["X - Horizontal Offset"],
		softMin = -50, softMax = 50, step = 1, bigStep = 1,
		get = function() return indicator.dbx.shadowX or 0 end,
		set = function(_, v)
			indicator.dbx.shadowX = v~=0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.shadowEnabled==nil end,
	}
	options.shadowY = {
		type = "range",
		order = 34,
		name = L["Y Offset"],
		desc = L["Y - Vertical Offset"],
		softMin = -50, softMax = 50, step = 1, bigStep = 1,
		get = function() return indicator.dbx.shadowY end,
		set = function(_, v)
			indicator.dbx.shadowY = v~=0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.shadowEnabled==nil end,
	}
	options.shadowColor = {
		type = "color",
		order = 35,
		name = L["Color"],
		desc = L["Color"],
		get = function() return self:UnpackColor( indicator.dbx.shadowColor, "BLACK" ) end,
		set = function( info, r,g,b,a )
			self:PackColor( r,g,b,a, indicator.dbx, "shadowColor" )
			self:RefreshIndicator(indicator, "Layout")
		 end,
		hasAlpha = true,
		hidden = function() return indicator.dbx.shadowEnabled==nil end,
	}
end
