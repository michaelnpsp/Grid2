-- bar indicator options

local Grid2Options = Grid2Options
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("multibar", true, function(self, indicator)
	local layout, bars  = {}, {}
	self:MakeIndicatorTypeLevelOptions(indicator,layout)
	self:MakeIndicatorLocationOptions(indicator,layout)
	self:MakeIndicatorMultiBarAppearanceOptions(indicator,layout)
	self:MakeIndicatorMultiBarTexturesOptions(indicator,bars)
	local options = Grid2Options.indicatorsOptions[indicator.name].args; wipe(options)
	self:MakeIndicatorTitleOptions(options, indicator)
	options["bars"]   = { type = "group", order = 10, name = L["Bars"], args = bars }
	options["layout"] = { type = "group", order = 30, name = L["Layout"], args = layout }
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

-- Grid2Options:MakeIndicatorMultiBarTextures()
do
	local ANCHOR_VALUES = { L["Previous Bar"], L["Topmost Bar"], L["Prev. Bar & Reverse"] }
    local BANCHOR_VALUES =	{ [0]= L["Whole Background"], [1]= L["Main Bar"], [2]= L["Topmost Bar"] }
	local DIRECTION_VALUES = { L['Normal'], L['Reverse'] }
	local MAINBAR_COLOR_SOURCES  = { L["Status Color"], L["Custom Color"] }
	local EXTRABAR_COLOR_SOURCES = { L["Main Bar Color"], L["Custom Color"] }

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
		local indicator = info.arg.indicator
		local index     = info.arg.index
		local newStatus = Grid2:GetStatusByName(statusKey)
		local oldStatus = indicator.statuses[index]
		local oldIndex  = indicator.priorities[newStatus]
		if oldStatus and oldIndex then
			SetIndicatorStatusPriority(indicator, oldStatus, oldIndex)
			SetIndicatorStatusPriority(indicator, newStatus, index)
		else
			UnregisterIndicatorStatus(indicator, oldStatus)
			RegisterIndicatorStatus(indicator, newStatus , index)
		end
		Grid2Options:RefreshIndicator(indicator, "Layout")
	end
	local function GetAvailableStatusValues(info)
		local indicator = info.arg.indicator
		local index     = info.arg.index
		local list      = {}
		for statusKey, status in Grid2:IterateStatuses() do
			if Grid2Options:IsCompatiblePair(indicator, status) and status.name~="test" and
			  ( (not indicator.priorities[status]) or indicator.statuses[index] ) then
				list[statusKey] = Grid2Options.LocalizeStatus(status)
			end
		end
		return list
	end

	function Grid2Options:MakeIndicatorMultiBarTexturesOptions(indicator, options)
		options.barSep = { type = "header", order = 50,  name = L["Main Bar"] }
		options.barMainStatus = {
			type = "select",
			order = 50.5,
			width = 0.9,
			name = L["Status"],
			desc = function()
				local status = indicator.statuses[1]
				return status and self.LocalizeStatus(status)
			end,
			get = function ()
				local status = indicator.statuses[1]
				return status and status.name or nil
			end,
			set = SetIndicatorStatus,
			values = GetAvailableStatusValues,
			arg = { indicator = indicator, index = 1 }
		}
		options.barMainDirection = {
			type = "select",
			order = 50.7,
			width = 0.9,
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
		}
		options.barMainTexture = {
			type = "select", dialogControl = "LSM30_Statusbar",
			order = 51,
			width = 0.9,
			name = L["Texture"],
			desc = L["Select bar texture."],
			get = function (info) return indicator.dbx.texture or self.MEDIA_VALUE_DEFAULT end,
			set = function (info, v)
				indicator.dbx.texture = v~=self.MEDIA_VALUE_DEFAULT and v or nil
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = self.GetStatusBarValues,
			disabled = function() return indicator.dbx.reverseMainBar end
		}
		options.barMainColorSource = {
			type = "select",
			order = 51.5,
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
		}
		options.barMainOpacity = {
			type = "range",
			order = 51.7,
			width = 0.9,
			name = L["Opacity"],
			desc = L["Set the opacity."],
			min = 0,
			max = 1,
			step = 0.01,
			bigStep = 0.05,
			get = function () return indicator.dbx.textureColor.a end,
			set = function (_, v)
				indicator.dbx.textureColor.a = v
				self:RefreshIndicator(indicator, "Layout")
			end,
		}
		options.barMainColor = {
			type = "color",
			hasAlpha = true,
			order = 52,
			width = 0.4,
			name = L["Color"],
			desc = L["Bar color"],
			hasAlpha = true,
			get = function()
				local c = indicator.dbx.textureColor
				if c.r then	return c.r, c.g, c.b, c.a end
			end,
			set = function(info,r,g,b,a)
				local c = indicator.dbx.textureColor
				c.r, c.g, c.b, c.a = r, g, b, a
				self:RefreshIndicator(indicator, "Layout")
			end,
			disabled = function() return indicator.dbx.textureColor.r == nil end
		}
		options.invertMainColor= {
			type = "toggle",
			name = L["Invert"],
			desc = L["Swap foreground/background colors on main bar."],
			width = 0.4,
			order = 53,
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
		}
		for i=1,#indicator.dbx do
			options["barSep"..i] = { type = "header", order = 50+i*5,  name = L["Extra Bar"] .. " "..i }
			options["Status"..i] = {
				type = "select",
				order = 50+i*5+1.0,
				width = 0.9,
				name = L["Status"],
				desc = function()
					local status = indicator.statuses[i+1]
					return status and self.LocalizeStatus(status)
				end,
				get = function ()
					local status = indicator.statuses[i+1]
					return status and status.name or nil
				end,
				set = SetIndicatorStatus,
				values = GetAvailableStatusValues,
				disabled = function() return not indicator.statuses[i] end,
				arg = { indicator = indicator, index = i+1},
			}
			options["barAnchorTo"..i] = {
				type = "select",
				order = 50+i*5+1.1,
				width = 0.9,
				name = L["Anchor & Direction"],
				desc = L["Select where to anchor the bar and optional you can reverse the grow direction."],
				get = function()
					local bar = indicator.dbx[i]
					return (bar.reverse and 3) or (bar.noOverlap and 2) or 1
				end,
				set = function(_, v)
					indicator.dbx[i].reverse = (v==3) or nil
					indicator.dbx[i].noOverlap = (v==2) or nil
					self:RefreshIndicator(indicator, "Layout")
				end,
				values = ANCHOR_VALUES,
			}
			options["barTexture"..i] = {
				type = "select", dialogControl = "LSM30_Statusbar",
				order = 50+i*5+1.2,
				width = 0.9,
				name = L["Texture"],
				desc = L["Select bar texture."],
				get = function (info) return indicator.dbx[i].texture or indicator.dbx.texture or self.MEDIA_VALUE_DEFAULT end,
				set = function (info, v)
					indicator.dbx[i].texture = (v~=indicator.dbx.texture and v~=self.MEDIA_VALUE_DEFAULT) and v or nil
					self:RefreshIndicator(indicator, "Layout")
				end,
				values = self.GetStatusBarValues,
			}
			options["barColorSource"..i] = {
				type = "select",
				order = 50+i*5+1.3,
				width = 0.9,
				name = L["Color Source"],
				desc = L["Select howto colorize the bar."],
				get = function() return indicator.dbx[i].color.r and 2 or 1; end,
				set = function(_, v)
					local c = indicator.dbx[i].color
					if v==2 then -- Custom color
						c.r, c.g, c.b = 0, 0, 0
					else -- Main Bar Color
						c.r, c.g, c.b = nil, nil, nil
					end
					self:RefreshIndicator(indicator, "Layout" )
				end,
				values = EXTRABAR_COLOR_SOURCES,
			}
			options["barOpacity"..i] = {
				type = "range",
				order = 50+i*5+1.5,
				width = 0.9,
				name = L["Opacity"],
				desc = L["Set the opacity."],
				min = 0,
				max = 1,
				step = 0.01,
				bigStep = 0.05,
				get = function() return indicator.dbx[i].color.a or 1; end,
				set = function(_, v)
					indicator.dbx[i].color.a = v
					self:RefreshIndicator(indicator, "Layout")
				end,
			}
			options["barColor"..i] = {
				type = "color",
				hasAlpha = true,
				order = 50+i*5+1.6,
				width = 0.9,
				name = L["Color"],
				desc = L["Select bar color"],
				get = function()
					local c = indicator.dbx[i].color.r and indicator.dbx[i].color or indicator.dbx.textureColor
					return c.r or 0, c.g or 0, c.b or 0, c.a or 0
				end,
				set = function( info, r,g,b,a )
					local c = indicator.dbx[i].color
					c.r, c.g, c.b, c.a = r, g, b, a
					self:RefreshIndicator(indicator, "Layout")
				end,
				disabled = function() return not indicator.dbx[i].color.r end,
			}
		end
		if indicator.dbx.backColor then
			options.barSepBack = { type = "header", order = 100,  name = L["Background"] }
			options.backTexture = {
				type = "select", dialogControl = "LSM30_Statusbar",
				order = 101,
				width = 0.9,
				name = L["Texture"],
				desc = L["Adjust the background texture."],
				get = function (info) return indicator.dbx.backTexture or indicator.dbx.texture or self.MEDIA_VALUE_DEFAULT end,
				set = function (info, v)
					indicator.dbx.backTexture = v~=self.MEDIA_VALUE_DEFAULT and v or nil
					self:RefreshIndicator(indicator, "Layout")
				end,
				values = self.GetStatusBarValues,
				hidden = function() return not indicator.dbx.backColor end
			}
			options.backAnchor = {
				type = "select",
				order = 101.5,
				width = 0.9,
				name = L["Anchor"],
				desc = L["Select howto anchor the background bar."],
				get = function ()
					return indicator.dbx.backAnchor or 0
				end,
				set = function (_, v)
					indicator.dbx.backAnchor = v>0 and v or nil
					self:RefreshIndicator(indicator, "Layout")
				end,
				values = BANCHOR_VALUES,
			}
			options.backColor = {
				type = "color",
				order = 102,
				width = 0.9,
				name = L["Color"],
				desc = L["Background Color"],
				hasAlpha = true,
				get = function() return self:UnpackColor( indicator.dbx.backColor ) end,
				set = function(info,r,g,b,a)
					self:PackColor( r,g,b,a, indicator.dbx, "backColor" )
					self:RefreshIndicator(indicator, "Layout")
				end,
				hidden = function() return not indicator.dbx.backColor end
			}
		end
		options.changeBarSep = { type = "header", order = 150, name = "" }
		options.addBar = {
			type = "execute",
			order = 151,
			name = L["Add Bar"],
			width = 0.9,
			desc = L["Add a new bar"],
			func = function(info)
				indicator.dbx[#indicator.dbx+1] = { color = {a=1} }
				self:RefreshIndicator(indicator, "Layout")
				self:MakeIndicatorOptions(indicator)
			end,
			disabled = function() return #indicator.dbx>=5 end
		}
		options.delBar = {
			type = "execute",
			order = 152,
			name = L["Delete Bar"],
			width = 0.9,
			desc = L["Delete last bar"],
			func = function(info)
				local index = #indicator.dbx
				UnregisterIndicatorStatus(indicator, indicator.statuses[index+1])
				if index>0 then
					table.remove(indicator.dbx, index)
				end
				self:RefreshIndicator(indicator, "Layout")
				self:MakeIndicatorOptions(indicator)
			end,
			disabled = function() return #indicator.dbx>0 and indicator.statuses[1]==nil end,
			confirm = function() return L["This action cannot be undone. Are you sure?"] end,
		}
		options.enableBack = {
			type = "execute",
			name = indicator.dbx.backColor and L["Del Background"] or L["Add Background"],
			desc = L["Enable or disable the background texture"],
			width = 0.9,
			order = 153,
			func = function(info)
				indicator.dbx.invertColor = nil
				indicator.dbx.backTexture = nil
				indicator.dbx.backAnchor  = nil
				indicator.dbx.backColor   = not indicator.dbx.backColor and { r=0,g=0,b=0,a=1 } or nil
				self:RefreshIndicator(indicator, "Layout")
				self:MakeIndicatorOptions(indicator)
			end,
			confirm = function() return indicator.dbx.backColor~=nil and L["This action cannot be undone. Are you sure?"] end,
		}
	end

end
