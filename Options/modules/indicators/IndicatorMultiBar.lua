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
	local emptyTable, tmpTable = {}, {}
	local ANCHOR_VALUES = { L["Previous Bar"], L["Topmost Bar"], L["Prev. Bar & Reverse"] }
    local BANCHOR_VALUES =	{ [0]= L["Whole Background"], [1]= L["Main Bar"], [2]= L["Topmost Bar"] }
	local DIRECTION_VALUES = { L['Normal'], L['Reverse'] }
	local MAINBAR_COLOR_SOURCES = { L["Status Color"], L["Custom Color"] }
	local EXTRABAR_COLOR_SOURCES = { L["Main Bar Color"], L["Custom Color"] }
	local TILE_MAIN_VALUES = { [1] = L["Fill"], [3] = L["Tile Repeat"] }
	local TILE_EXTRA_VALUES = { [0] = L["Fill"], [1] = L["Stretch"], [3] = L["Tile Repeat"], [4] = L["Tile Mirror"] }
	local TILE_BACK_VALUES = { [1] = L["Stretch"], [3] = L["Tile Repeat"] }	
	local tileTranslate = { [0] = 'CLAMP', [1] = nil,  [3] = 'REPEAT', [4] = 'MIRROR', CLAMP = 0, REPEAT = 3, MIRROR = 4 }
	
	-- edited indicator & bar

	local self, indicator, barIndex, barDbx = Grid2Options

	-- support functions

	local function SelectTab( key )
		self:SelectGroup('indicators', indicator.name, 'bars', tostring(key) )
	end	

	local function GetIndicatorStatusMap(indicator)
		return Grid2:DbGetValue('statusMap',indicator.name) or emptyTable
	end

	local function RegisterIndicatorStatus(indicator, statusName, priority)
		if statusName then
			assert( type(priority)=='number' )
			Grid2:DbSetMap(indicator.name, statusName, priority)
			local status = Grid2:GetStatusByName(statusName)
			if status then indicator:RegisterStatus(status, priority) end
		end
	end
	
	local function UnregisterIndicatorStatus(indicator, statusName)
		if statusName then
			Grid2:DbSetMap(indicator.name, statusName, nil)
			local status = Grid2:GetStatusByName(statusName)
			if status then indicator:UnregisterStatus(status) end
		end
	end

	local function UnregisterIndicatorAllStatuses(indicator)
		for statusName in next, GetIndicatorStatusMap(indicator) do
			UnregisterIndicatorStatus(indicator, statusName)
		end	
	end
	
	local function SetIndicatorStatusPriority(indicator, statusName, priority)
		assert( type(priority)=='number' )
		Grid2:DbSetMap( indicator.name, statusName, priority)
		local status = Grid2:GetStatusByName(statusName)
		if status then indicator:SetStatusPriority(status, priority) end
	end
	
	local function GetIndicatorStatusPriority(indicator, statusName)
		if statusName then
			local map = Grid2:DbGetValue('statusMap', indicator.name)
			return map and map[statusName]
		end	
	end
	
	local function GetIndicatorStatusName(indicator, priority)
		for name, index in next, GetIndicatorStatusMap(indicator) do
			if priority==index then
				return name
			end	
		end
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
			desc = L["Select the status to display in this bar."],
			get = function()
				return GetIndicatorStatusName(indicator, barIndex+1)
			end,
			set = function(_, newStatusName)
				local newStatusIndex = barIndex + 1
				local oldStatusName  = GetIndicatorStatusName(indicator, newStatusIndex)
				local oldStatusIndex = GetIndicatorStatusPriority(indicator, newStatusName)
				if oldStatusName and oldStatusIndex then
					SetIndicatorStatusPriority(indicator, oldStatusName, oldStatusIndex)
					SetIndicatorStatusPriority(indicator, newStatusName, newStatusIndex)
				else
					UnregisterIndicatorStatus(indicator, oldStatusName)
					RegisterIndicatorStatus(indicator, newStatusName , newStatusIndex)
				end
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = function()
				wipe(tmpTable)
				local curStatusName = GetIndicatorStatusName(indicator, barIndex+1)
				local usedStatuses  = GetIndicatorStatusMap(indicator)
				for statusKey, status in Grid2:IterateStatuses() do
					if self:IsCompatiblePair(indicator, status) and (curStatusName or not usedStatuses[statusKey])  then
						tmpTable[statusKey] = self.LocalizeStatus(status)
					end
				end
				return tmpTable
			end,
			disabled = function() return barIndex>0 and not GetIndicatorStatusName(indicator, barIndex) end,
			hidden = false,
		},
		
		barMainDirection = {
			type = "select",
			order = 3,
			width = 0.95,
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
			width = 0.95,
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
			width = 0.87,
			name = L["Color Source"],
			desc = L["Select howto colorize the main bar."],
			get = function ()
				return indicator.dbx.textureColor.r and 2 or 1
			end,
			set = function (_, v)
				local color = indicator.dbx.textureColor
				if v==1 then -- (1) colors from statuses
					RegisterIndicatorStatus(indicator.sideKick, 'classcolor', 50)
					color.r, color.g, color.b = nil, nil, nil										
				else -- (2) custom color
					UnregisterIndicatorAllStatuses(indicator.sideKick)
					color.r, color.g, color.b = 0, 0, 0					
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
			width = 0.87,
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
			disabled = function() return barIndex~=0 end,
		},

		-------------------------------------------------------------------------

	    headerTexture = { type = "header", order = 10,  name = L["Texture"] },

		barTexture = {
			type = "select", dialogControl = "LSM30_Statusbar",
			order = 11,
			width = 1.15,
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

		barHorTile= {
			type = "select",
			order = 12,
			width = 0.7,
			name = L["Horizontal Fit"],
			desc = L["Select howto adjust the texture horizontally."],
			get = function()
				return tileTranslate[barDbx.horTile] or 1
			end,
			set = function(_, v)
				barDbx.horTile = tileTranslate[v]
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = function() return barIndex==0 and TILE_MAIN_VALUES or TILE_EXTRA_VALUES end,			
			hidden = false,
		},
		
		barVerTile = {
			type = "select",
			order = 13,
			width = 0.7,
			name = L["Vertical Fit"],
			desc = L["Select howto adjust the texture vertically."],
			get = function()
				return tileTranslate[barDbx.verTile] or 1
			end,
			set = function(_, v)
				barDbx.verTile = tileTranslate[v]
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = function() return barIndex==0 and TILE_MAIN_VALUES or TILE_EXTRA_VALUES end,						
			hidden = false,
		},

		-------------------------------------------------------------------------

		headerButtons = { type = "header", order = 150, name = "" },
		
		addBar = {
			type = "execute",
			order = 151,
			name = L["Add Bar"],
			width = 0.85,
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
			width = 0.85,
			desc = L["Delete this bar"],
			func = function(info)
				if barIndex>0 and barIndex<=#indicator.dbx then
					local priority = barIndex+1
					UnregisterIndicatorStatus( indicator, GetIndicatorStatusName(indicator, priority) )
					table.remove(indicator.dbx, barIndex)
					for statusName, index in next, GetIndicatorStatusMap(indicator) do
						if index>priority then
							SetIndicatorStatusPriority(indicator, statusName, index-1)
						end
					end
					self:RefreshIndicator(indicator, "Layout")
					SelectTab( barIndex<=#indicator.dbx and barIndex or barIndex-1 )
				end	
			end,
			disabled = function() return barIndex==0 end,
			confirm = function() return L["This action cannot be undone. Are you sure?"] end,
			hidden = false,			
		},
		
		enableBack = {
			type = "execute",
			name = function() return indicator.dbx.backColor and L["Del Background"] or L["Add Background"] end,
			desc = L["Enable or disable the background texture"],
			width = 0.85,
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
		
		backAnchor = {
			type = "select",
			order = 3,
			width = 1,
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
			width = 0.4,
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

	    headerTexture = { type = "header", order = 10,  name = L["Texture"] },

		backTexture = {
			type = "select", dialogControl = "LSM30_Statusbar",
			order = 11,
			width = 1.15,
			name = L["Texture"],
			desc = L["Adjust the background texture."],
			get = function (info) return indicator.dbx.backTexture or indicator.dbx.texture or self.MEDIA_VALUE_DEFAULT end,
			set = function (info, v)
				indicator.dbx.backTexture = (v~=indicator.dbx.texture and v~=self.MEDIA_VALUE_DEFAULT) and v or nil
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = self.GetStatusBarValues,
			hidden = false,
		},

		backHorTile = {
			type = "select",
			order = 12,
			width = 0.7,
			name = L["Horizontal Fit"],
			desc = L["Select howto adjust the texture horizontally."],
			get = function()
				return tileTranslate[indicator.dbx.backHorTile] or 1
			end,
			set = function(_, v)
				indicator.dbx.backHorTile = tileTranslate[v]
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = TILE_BACK_VALUES,
			hidden = false,
		},
		
		backVerTile = {
			type = "select",
			order = 13,
			width = 0.7,
			name = L["Vertical Fit"],
			desc = L["Select howto adjust the texture vertically."],
			get = function()
				return tileTranslate[indicator.dbx.backVerTile] or 1
			end,
			set = function(_, v)
				indicator.dbx.backVerTile = tileTranslate[v]
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = TILE_BACK_VALUES,			
			hidden = false,
		},

		headerButtons = { type = "header", order = 99, name = "" },

		backRemove = {
			type = "execute",
			name = L["Del Background"],
			desc = L["Del Background"],
			width = 'full',
			order = 100,
			func = function(info)
				indicator.dbx.invertColor = nil
				indicator.dbx.backTexture = nil
				indicator.dbx.backAnchor  = nil
				indicator.dbx.backColor   = nil
				indicator.dbx.backHorTile = nil
				indicator.dbx.backVerTile = nil
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
