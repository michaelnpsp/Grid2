-- bar indicator options

local Grid2Options = Grid2Options
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("multibar", true, function(self, indicator)
	local layout, filter = {}, {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator,layout)
	self:MakeIndicatorLocationOptions(indicator,layout)
	self:MakeIndicatorMultiBarAppearanceOptions(indicator,layout)
	self:MakeIndicatorLoadOptions(indicator, filter)
	local options = Grid2Options.indicatorsOptions[indicator.name].args; wipe(options)
	self:MakeIndicatorTitleOptions(options, indicator)
	options.bars   = { type = "group", order = 10, name = L["Bars"],   args = self:GetIndicatorMultiBarTexturesOptions(), childGroups = "tab" }
	options.load   = { type = "group", order = 30, name = L["Load"],   args = filter }
	options.layout = { type = "group", order = 40, name = L["Layout"], args = layout }
	if indicator.dbx.textureColor.r==nil then
		local colors = {}
		self:MakeIndicatorStatusOptions(indicator.sideKick, colors)
		options["colors"] = { type = "group", order = 20, name = L["Colors"], args = colors  }
	end
end)

-- Grid2Options:MakeIndicatorBarDisplayOptions()
function Grid2Options:MakeIndicatorMultiBarAppearanceOptions(indicator,options)
	self:MakeHeaderOptions( options, "Appearance" )
	options.barWidth= {
		type = "range",
		order = 20,
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
		order = 30,
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
	options.orientation = {
		type = "select",
		order = 40,
		name = L["Orientation of the Bar"],
		desc = L["Set status bar orientation."],
		get = function ()
			return indicator.dbx.orientation or "DEFAULT"
		end,
		set = function (_, v)
			if v=="DEFAULT" then v= nil	end
			indicator:SetOrientation(v)
			self:RefreshIndicator(indicator, "Layout")
		end,
		values={ ["DEFAULT"]= L["DEFAULT"], ["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
	}
	options.reverseFill= {
		type = "toggle",
		name = L["Reverse Fill"],
		desc = L["Fill the bar in reverse."],
		order = 50,
		tristate = false,
		get = function () return indicator.dbx.reverseFill end,
		set = function (_, v)
			indicator.dbx.reverseFill = v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end

-- Grid2Options:GetIndicatorMultiBarTextures()
do
	local ANCHOR_VALUES = { L["Previous Bar"], L["Topmost Bar"], L["Prev. Bar & Reverse"] }
    local BANCHOR_VALUES =	{ [0]= L["Whole Background"], [1]= L["Main Bar"], [2]= L["Topmost Bar"] }
	local DIRECTION_VALUES = { L['Normal'], L['Reverse'] }
	local MAINBAR_COLOR_SOURCES  = { L["Status Color"], L["Custom Color"] }
	local EXTRABAR_COLOR_SOURCES = { L["Main Bar Color"], L["Custom Color"] }
	local TILE_VALUES = { [-2] = L["None"], [0] = L["Horizontal&Vertical"], [-1] = L["Horizontal"], [1] = L["Vertical"] }
	local WRAP_VALUES = { L["Default"], L["Stretch"], L["Tile Repeat"], L["Tile Mirror"] }
	
	-- edited indicator & bar
	
	local self = Grid2Options
	local indicator, barIndex, barDbx

	-- support functions

	local function SelectTab( key )
		self:SelectGroup('indicators', indicator.name, 'bars', tostring(key) )
	end	

	local function RegisterIndicatorStatus(indicator, status, index)
		if status then
			Grid2:DbSetMap(indicator.name, status.name, index)
			indicator:RegisterStatus(status, index)
		end
	end
	
	local function UnregisterIndicatorStatus(indicator, status)
		if status then
			Grid2:DbSetMap(indicator.name, status.name, nil)
			indicator:UnregisterStatus(status)
		end
	end
	
	local function SetIndicatorStatusPriority(indicator, status, priority)
		Grid2:DbSetMap( indicator.name, status.name, priority)
		indicator:SetStatusPriority(status, priority)
	end
	
	local function UnregisterAllStatuses(indicator)
		local statuses = indicator.statuses
		while #statuses>0 do
			UnregisterIndicatorStatus(indicator,statuses[#statuses])
		end
	end
	
	local function SetIndicatorStatus(info, statusKey)
		local statusIndex = barIndex + 1
		local newStatus = Grid2:GetStatusByName(statusKey)
		local oldStatus = indicator.statuses[statusIndex]
		local oldIndex  = indicator.priorities[newStatus]
		if oldStatus and oldIndex then
			SetIndicatorStatusPriority(indicator, oldStatus, oldIndex)
			SetIndicatorStatusPriority(indicator, newStatus, statusIndex)
		else
			UnregisterIndicatorStatus(indicator, oldStatus)
			RegisterIndicatorStatus(indicator, newStatus , statusIndex)
		end
		self:RefreshIndicator(indicator, "Layout")
	end
	
	local function GetAvailableStatusValues(info)
		local list = {}
		for statusKey, status in Grid2:IterateStatuses() do
			if Grid2Options:IsCompatiblePair(indicator, status) and status.name~="test" and
			  ( (not indicator.priorities[status]) or indicator.statuses[barIndex+1] ) then
				list[statusKey] = Grid2Options.LocalizeStatus(status)
			end
		end
		return list
	end
	
	-- bar settings
	
	local barOptions = {

		__load = { type = "header", order = 0, name = "", hidden = function(info)
				barIndex  = tonumber( info[#info-1] )
				barDbx    = indicator.dbx[barIndex] or indicator.dbx
				return true
		end },

		-------------------------------------------------------------------------
	
		headerMain = { type = "header", order = 1,  name = function(info)
			return (barIndex and barIndex>0) and L["Extra Bar "]..barIndex or L["Main Bar"]
		end },
	
		barStatus = {
			type = "select",
			order = 2,
			width = 1.6,
			name = L["Status"],
			desc = function()
				local status = indicator.statuses[barIndex+1]
				return status and self.LocalizeStatus(status)
			end,
			get = function ()
				local status = indicator.statuses[barIndex+1]
				return status and status.name
			end,
			set = SetIndicatorStatus,
			values = GetAvailableStatusValues,
			disabled = function() return barIndex>0 and not indicator.statuses[barIndex] end,
			hidden = false,
		},
		
		barMainDirection = {
			type = "select",
			order = 3,
			width = 1,
			name = L["Direction"],
			desc = L["Select the direction of the main bar."],
			get = function ()
				return indicator.dbx.reverseMainBar and 2 or 1
			end,
			set = function (_, v)
				indicator.dbx.reverseMainBar = (v==2) or nil
				self:RefreshIndicator(indicator, "Layout" )
			end,
			values = DIRECTION_VALUES,
			hidden = function() return barIndex~=0 end,
		},

		barExtraDirection = {
			type = "select",
			order = 3,
			width = 1,
			name = L["Anchor & Direction"],
			desc = L["Select where to anchor the bar and optional you can reverse the grow direction."],
			get = function()
				return (barDbx.reverse and 3) or (barDbx.noOverlap and 2) or 1
			end,
			set = function(_, v)
				barDbx.reverse = (v==3) or nil
				barDbx.noOverlap = (v==2) or nil
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = ANCHOR_VALUES,
			hidden = function() return barIndex==0 end,
		},
		
		-------------------------------------------------------------------------
		
	    headerColor = { type = "header", order = 4,  name = L["Color"] },

		barMainColorSource = {
			type = "select",
			order = 5,
			width = 0.9,
			name = L["Color Source"],
			desc = L["Select howto colorize the main bar."],
			get = function ()
				return indicator.dbx.textureColor.r and 2 or 1
			end,
			set = function (_, v)
				local color = indicator.dbx.textureColor
				if v==1 then -- (1) colors from statuses
					color.r, color.g, color.b = nil, nil, nil
					RegisterIndicatorStatus(indicator.sideKick, Grid2:GetStatusByName('classcolor'), 50)
				else -- (2) custom color
					color.r, color.g, color.b = 0, 0, 0
					UnregisterAllStatuses(indicator.sideKick)
				end
				self:RefreshIndicator(indicator, "Layout" )
				self:MakeIndicatorOptions(indicator)
			end,
			values = MAINBAR_COLOR_SOURCES,
			hidden = function() return barIndex~=0 end,
		},

		barExtraColorSource = {
			type = "select",
			order = 5,
			width = 0.9,
			name = L["Color Source"],
			desc = L["Select howto colorize the bar."],
			get = function() return barDbx.color.r and 2 or 1; end,
			set = function(_, v)
				local c = barDbx.color
				if v==2 then -- Custom color
					c.r, c.g, c.b = 0, 0, 0
				else -- Main Bar Color
					c.r, c.g, c.b = nil, nil, nil
				end
				self:RefreshIndicator(indicator, "Layout" )
			end,
			values = EXTRABAR_COLOR_SOURCES,
			hidden = function() return barIndex==0 end,
		},

		barOpacity = {
			type = "range",
			order = 6,
			width = 0.9,
			name = L["Opacity"],
			desc = L["Set the opacity."],
			min = 0,
			max = 1,
			step = 0.01,
			bigStep = 0.05,
			get = function() 
				return (barDbx.textureColor or barDbx.color).a or 1
			end,
			set = function(_, v)
				(barDbx.textureColor or barDbx.color).a = v
				self:RefreshIndicator(indicator, "Layout")
			end,
			hidden = false,			
		},

		barColor = {
			type = "color",
			hasAlpha = true,
			order = 7,
			width = 0.4,
			name = L["Color"],
			desc = L["Select bar color"],
			get = function()
				local c = (barIndex>0 and barDbx.color.r and barDbx.color) or indicator.dbx.textureColor
				return c.r or 0, c.g or 0, c.b or 0, c.a or 0
			end,
			set = function( info, r,g,b,a )
				local c = barDbx.color or barDbx.textureColor
				c.r, c.g, c.b, c.a = r, g, b, a
				self:RefreshIndicator(indicator, "Layout")
			end,
			disabled = function() return (barDbx.textureColor or barDbx.color).r == nil end,
			hidden = false,			
		},

		mainBarColorInvert = {
			type = "toggle",
			name = L["Invert"],
			desc = L["Swap foreground/background colors on main bar."],
			width = 0.4,
			order = 8,
			tristate = false,
			get = function() return indicator.dbx.invertColor end,
			set = function(_, v)
				indicator.dbx.invertColor = v or nil
				indicator.dbx.textureColor.a = math.min( indicator.dbx.textureColor.a, 0.8 )
				if v then
					for _,bar in ipairs(indicator.dbx) do
						bar.color.a = math.min(bar.color.a, 0.8)
					end
				end
				if v and not indicator.dbx.backColor then
					indicator.dbx.backColor = { r=0, g=0, b=0, a=1 }
					self:MakeIndicatorOptions(indicator)
				end
				self:RefreshIndicator(indicator, "Layout")
			end,
			hidden = function() return barIndex~=0 end,
		},

		-------------------------------------------------------------------------

	    headerTexture = { type = "header", order = 10,  name = L["Texture"] },

		barTexture = {
			type = "select", dialogControl = "LSM30_Statusbar",
			order = 11,
			width = 1.2,
			name = L["Texture"],
			desc = L["Select bar texture."],
			get = function (info) return barDbx.texture or indicator.dbx.texture or self.MEDIA_VALUE_DEFAULT end,
			set = function (info, v)
				barDbx.texture = (v~=indicator.dbx.texture and v~=self.MEDIA_VALUE_DEFAULT) and v or nil
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = self.GetStatusBarValues,
			disabled = function() return barIndex==0 and indicator.dbx.reverseMainBar end,
			hidden = false,			
		},

		barWrapHor = {
			type = "select",
			order = 12,
			width = 0.7,
			name = L["Horizontal Wrap"],
			desc = L["Select howto adjust the texture horizontally."],
			get = function()
				
			end,
			set = function(_, v)
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = WRAP_VALUES,
			hidden = false,
		},
		
		barWrapVer = {
			type = "select",
			order = 13,
			width = 0.7,
			name = L["Vertical Wrap"],
			desc = L["Select howto adjust the texture vertically."],
			get = function()
				
			end,
			set = function(_, v)
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = WRAP_VALUES,
			hidden = false,
		},

--[[
		barTile = {
			type = "select",
			order = 13,
			width = 0.9,
			name = L["Tile"],
			desc = L["Select if you want to tile the bar texture vertically or horizontally."],
			get = function()
				return barDbx.tileTex or -2
			end,
			set = function(_, v)
				barDbx.tileTex = (v>=-1) and v or nil
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = TILE_VALUES,
			hidden = false,
		},
--]]	
	
		-------------------------------------------------------------------------

		headerButtons = { type = "header", order = 150, name = "" },
		
		addBar = {
			type = "execute",
			order = 151,
			name = L["Add Bar"],
			width = 0.9,
			desc = L["Add a new bar"],
			func = function(info)
				indicator.dbx[#indicator.dbx+1] = { color = {a=1} }
				self:RefreshIndicator(indicator, "Layout")
				SelectTab( #indicator.dbx )
			end,
			disabled = function() return #indicator.dbx>=5 end,
			hidden = false,			
		},
		
		delBar = {
			type = "execute",
			order = 152,
			name = L["Delete Bar"],
			width = 0.9,
			desc = L["Delete this bar"],
			func = function(info)
				UnregisterIndicatorStatus(indicator, indicator.statuses[barIndex+1])
				table.remove(indicator.dbx, barIndex)
				self:RefreshIndicator(indicator, "Layout")
				SelectTab( barIndex-1 )
			end,
			disabled = function() return barIndex==0 end,
			confirm = function() return L["This action cannot be undone. Are you sure?"] end,
			hidden = false,			
		},
		
		enableBack = {
			type = "execute",
			name = function() return indicator.dbx.backColor and L["Del Background"] or L["Add Background"] end,
			desc = L["Enable or disable the background texture"],
			width = 0.9,
			order = 153,
			func = function(info)
				indicator.dbx.invertColor = nil
				indicator.dbx.backTexture = nil
				indicator.dbx.backAnchor  = nil
				indicator.dbx.backColor   = not indicator.dbx.backColor and { r=0,g=0,b=0,a=1 } or nil
				self:RefreshIndicator(indicator, "Layout")
				SelectTab(indicator.dbx.backColor and 'background' or 0)
			end,
			confirm = function() return indicator.dbx.backColor~=nil and L["This action cannot be undone. Are you sure?"] end,
			hidden = false,
		},
		
	}

	-- background settings
	
	local backOptions = {
	
		backHeader = { type = "header", order = 1,  name = L["Background"] },
		
		backTexture = {
			type = "select", dialogControl = "LSM30_Statusbar",
			order = 2,
			width = 1.2,
			name = L["Texture"],
			desc = L["Adjust the background texture."],
			get = function (info) return indicator.dbx.backTexture or indicator.dbx.texture or self.MEDIA_VALUE_DEFAULT end,
			set = function (info, v)
				indicator.dbx.backTexture = v~=self.MEDIA_VALUE_DEFAULT and v or nil
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = self.GetStatusBarValues,
			hidden = false,
		},
		
		backAnchor = {
			type = "select",
			order = 3,
			width = 0.9,
			name = L["Anchor"],
			desc = L["Select howto anchor the background texture."],
			get = function ()
				return indicator.dbx.backAnchor or 0
			end,
			set = function (_, v)
				indicator.dbx.backAnchor = v>0 and v or nil
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = BANCHOR_VALUES,
			hidden = false,			
		},
		
		backColor = {
			type = "color",
			order = 4,
			width = 0.9,
			name = L["Color"],
			desc = L["Background Color"],
			hasAlpha = true,
			get = function() return self:UnpackColor( indicator.dbx.backColor ) end,
			set = function(info,r,g,b,a)
				self:PackColor( r,g,b,a, indicator.dbx, "backColor" )
				self:RefreshIndicator(indicator, "Layout")
			end,
			hidden = false,
		},

		headerButtons = { type = "header", order = 99, name = "" },

		backRemove = {
			type = "execute",
			name = L["Delete Background"],
			desc = L["Delete Background"],
			width = 'full',
			order = 100,
			func = function(info)
				indicator.dbx.invertColor = nil
				indicator.dbx.backTexture = nil
				indicator.dbx.backAnchor  = nil
				indicator.dbx.backColor   =  nil
				self:RefreshIndicator(indicator, "Layout")
				SelectTab(0)
			end,
			confirm = function() return L["This action cannot be undone. Are you sure?"] end,
			hidden = false,
		},
		
	}

	-- options/tabs for all bars

	local options = {
		__load = { type = "header", order = 0, name = "", hidden = function(info)
				indicator = Grid2:GetIndicatorByName( info[#info-2] )
				return true
		end },
	}	

	-- add 5 extra bars tabs
	local function isBarHidden(info)
		local barIndex = tonumber(info[#info]) or 0
		return barIndex>0 and not (indicator and indicator.dbx[barIndex])
	end
	
	for i=0,6 do
		options[tostring(i)] = {
			type   = "group",
			order  = i,
			name   = i==0 and L['Main Bar'] or L['Bar']..i,
			desc = "",
			args   = barOptions,
			hidden = isBarHidden, 
		}
	end

	-- add background tab
	options.background = {
		type   = "group",
		order  = 100,
		name   = L["Back"],
		desc = "",
		args   = backOptions,
		hidden = function() return indicator.dbx.backColor==nil end,
	}

	-- published return bars options
	
	function Grid2Options:GetIndicatorMultiBarTexturesOptions()
		return options
	end

end
