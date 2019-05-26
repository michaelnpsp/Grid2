-- Library of common/shared methods

local Grid2Options = Grid2Options
local L = Grid2Options.L

-- Grid2Options:MakeIndicatorCurrentStatusOptions()
-- Grid2Options:MakeIndicatorStatusOptions()
-- Grid2Options:MakeStatusIndicatorOptions()
do
	local function GetIndicatorNewPriority(indicator)
		local priority = 50
		local map = Grid2:DbGetValue('statusMap', indicator.name)
		if map then
			for _,p in pairs(map) do
				p = tonumber(p)
				if p and p>=priority then
					priority = p+1
				end
			end
		end
		return priority
	end

	local function RegisterIndicatorStatus(indicator, status, value)
		if value then
			local priority = GetIndicatorNewPriority(indicator)
			Grid2:DbSetMap(indicator.name, status.name, priority)
			indicator:RegisterStatus(status, priority)
			status:Refresh()
		else
			Grid2:DbSetMap(indicator.name, status.name, nil)
			indicator:UnregisterStatus(status)
		end
		Grid2Options:RefreshIndicator(indicator, "Layout", "Update")
	end

	local function SetStatusPriority(indicator, status, priority)
		Grid2:DbSetMap( indicator.name, status.name, priority)
		indicator:SetStatusPriority(status, priority)
	end

	local function RefreshIndicatorCurrentStatusOptions(info)
		wipe(info.arg.options)
		Grid2Options:MakeIndicatorCurrentStatusOptions(info.arg.indicator, info.arg.options)
	end

	local function SetIndicatorStatus(info, statusKey, value)
		for key, status in Grid2:IterateStatuses() do
			if key == statusKey then
				RegisterIndicatorStatus(info.arg.indicator, status, value)
				RefreshIndicatorCurrentStatusOptions(info)
				return
			end
		end
	end

	local function SetIndicatorStatusCurrent(info, value)
		SetIndicatorStatus(info, info[#info], value)
	end

	local function StatusSwapPriorities(indicator, index1, index2)
		local status1 = indicator.statuses[index1]
		local status2 = indicator.statuses[index2]
		local priority1 = indicator:GetStatusPriority(status1)
		local priority2 = indicator:GetStatusPriority(status2)
		SetStatusPriority(indicator, status1, priority2)
		SetStatusPriority(indicator, status2, priority1)
	end

	local function StatusShiftUp(info, indicator, lowerStatus)
		local index = indicator:GetStatusIndex(lowerStatus)
		if index then
			local newIndex = index>1 and index - 1 or #indicator.statuses
			StatusSwapPriorities(indicator, index, newIndex)
			RefreshIndicatorCurrentStatusOptions(info)
			Grid2Options:RefreshIndicator(indicator, "Layout", "Update")
		end
	end

	local function StatusShiftDown(info, indicator, higherStatus)
		local index = indicator:GetStatusIndex(higherStatus)
		if index then
			local newIndex = index<#indicator.statuses and index+1 or 1
			StatusSwapPriorities(indicator, index, newIndex)
			RefreshIndicatorCurrentStatusOptions(info)
			Grid2Options:RefreshIndicator(indicator, "Layout", "Update")
		end
	end

	-- Grid2Options:MakeIndicatorCurrentStatusOptions(indicator, options)
	function Grid2Options:MakeIndicatorCurrentStatusOptions(indicator, options)
		if indicator.statuses then
			local arg  = { indicator = indicator, options = options }
			local more = #indicator.statuses>1
			for index, status in ipairs(indicator.statuses) do
				local statusKey = status.name
				local order = 5 * index
				local passValue = {indicator = indicator, status = status}
				options[statusKey] = {
					type = "toggle",
					order = order,
					width = 1.5,
					name =  Grid2Options.LocalizeStatus(status),
					desc = L["Select statuses to display with the indicator"],
					get = function() return true end,
					set = SetIndicatorStatusCurrent,
					arg = arg,
				}
				if more then
					options[statusKey .. "U"] = {
						type = "execute",
						order = order + 1,
						width = 0.15,
						image = "Interface\\Addons\\Grid2Options\\media\\arrow-up",
						imageWidth= 16,
						imageHeight= 14,
						name= "",
						desc = L["Move the status higher in priority"],
						func = function (info) StatusShiftUp(info, indicator, status) end,
						arg = arg,
					}
					options[statusKey .. "D"] = {
						type = "execute",
						order = order + 2,
						width = 0.15,
						image = "Interface\\Addons\\Grid2Options\\media\\arrow-down",
						imageWidth= 16,
						imageHeight= 14,
						name= "",
						desc = L["Move the status lower in priority"],
						func = function (info) StatusShiftDown(info, indicator, status) end,
						arg = arg,
					}
					options[statusKey .."S"] = {
					  type = "description",
					  name = "",
					  order = order + 3
					}
				end
			end
		end
	end

	-- Grid2Options:MakeIndicatorStatusOptions()
	function Grid2Options:MakeIndicatorStatusOptions(indicator, options)
		local curOptions = {}
		self:MakeIndicatorCurrentStatusOptions(indicator, curOptions)
		options.statusesCurrent = {
			type = "group",
			order = 100,
			inline = true,
			name = L["Current Statuses"],
			desc = L["Current statuses in order of priority"],
			args = curOptions
		}
		options.statusesAvailable = {
			type = "multiselect",
			order = 200,
			name = L["Available Statuses"],
			desc = L["Available statuses you may add"],
			values = function() return self:GetAvailableStatusValues(indicator) end,
			get = false,
			set = SetIndicatorStatus,
			arg = { indicator = indicator, options = curOptions },
		}
	end

	-- Grid2Options:MakeStatusIndicatorOptions()
	function Grid2Options:MakeStatusIndicatorsOptions( status, options )
		options.indicators = {
			type = "multiselect",
			order = 10,
			name = L['Assigned indicators'],
			values = function()
				return self:GetAvailableIndicatorValues(status)
			end,
			get = function(info,key)
				return Grid2.indicators[key]:GetStatusIndex(status)~=nil
			end,
			set = function(info,key,value)
				local indicator = Grid2.indicators[key]
				if indicator.dbx.type ~= 'multibar' then
					RegisterIndicatorStatus(indicator, status, value)
					self:RefreshIndicatorOptions(indicator) 
				end
			end,
			confirm = function(info,key)
				return Grid2.indicators[key].dbx.type == 'multibar' and L['This indicator cannot be changed from here: go to "indicators" section to assign/unassign statuses to this indicator.']
			end,
			disabled = function() return status:IsSuspended() end,
		}
	end
end

-- Grid2Options:MakeIndicatorTypeOptions()
do
	local typeMorphValue  = {}
	local typeMorphValues = { icon = L["icon"], square = L["square"], text = L["text"] }

	local function RegisterIndicatorStatusesFromDatabase(indicator)
		if indicator then
			local map= Grid2:DbGetValue("statusMap", indicator.name)
			if map then
				for statusKey, priority in pairs(map) do
					local status = Grid2.statuses[statusKey]
					if (status and tonumber(priority)) then
						indicator:RegisterStatus(status, priority)
					end
				end
			end
		end
	end

	local function GetIndicatorTypeValues(info)
		local typeKey = info.arg.dbx.type
		if not typeMorphValues[typeKey] then
			wipe(typeMorphValue)
			typeMorphValue[typeKey] = L[typeKey]
			return typeMorphValue
		end
		return typeMorphValues	
	end

	local function GetIndicatorTypeDisabled(info)
		return not typeMorphValues[info.arg.dbx.type]
	end

	local function GetIndicatorType(info)
		return info.arg.dbx.type
	end

	local function SetIndicatorType(info, value)
		local indicator = info.arg
		local baseKey = indicator.name
		local dbx = indicator.dbx
		local colorKey = baseKey.."-color"
		local oldType = dbx.type

		if dbx.type == value then return end

		-- Set new fields width defaults values
		dbx.type = value
		for k, v in pairs(Grid2Options.indicatorDefaultValues[value]) do
			if (not dbx[k]) then
				indicator.dbx[k] = v
				dbx[k] = v
			end
		end
		-- Remove old indicator
		Grid2:UnregisterIndicator(indicator)
		-- Create new indicator
		local setupFunc = Grid2.setupFunc[dbx.type]
		local newIndicator = setupFunc(baseKey, dbx)
		-- Remove incompatible statuses from database
		local map = Grid2:DbGetValue("statusMap", baseKey)
		if map then
			for statusKey, priority in pairs(map) do
				local status = Grid2.statuses[statusKey]
				if (not status) or (not Grid2Options:IsCompatiblePair(newIndicator, status)) then
					map[statusKey]= nil
				end
			end
		end
		-- Register indicator statuses from database
		RegisterIndicatorStatusesFromDatabase(newIndicator)
		RegisterIndicatorStatusesFromDatabase(newIndicator.sideKick)
		-- Recreate indicators in frame units
		Grid2Frame:WithAllFrames(function (f)
			newIndicator:Create(f)
			newIndicator:Layout(f)
		end)
		-- Delete or Create associated text-color indicator in database
		if oldType=="text" then
			Grid2:DbSetIndicator(colorKey, nil)
		elseif value=="text" then
			Grid2:DbSetIndicator(colorKey , { type="text-color" })
		end
		-- Update unit frames
		Grid2Frame:UpdateIndicators()
		-- Create new indicator options
		Grid2Options:MakeIndicatorOptions(newIndicator)
	end

	function Grid2Options:MakeIndicatorTypeOptions(indicator, options, optionParams)
		options.indicatorType = {
			type = 'select',
			order = 1.91,
			name = L["Indicator Type"],
			desc = L["Change the indicator type"],
			values = GetIndicatorTypeValues,
			get = GetIndicatorType,
			set = SetIndicatorType,
			confirm = true,
			confirmText = L["Are you sure do you want to convert the indicator to the new selected type?"],
			arg = indicator,
		}
	end
end
	
-- Grid2Options:MakeIndicatorLevelOptions()
do
	local levelValues = { 1,2,3,4,5,6,7,8,9 }
	function Grid2Options:MakeIndicatorLevelOptions(indicator, options)
		options.frameLevel = {
			type = "select",
			order = 1.99,
			name = L["Frame Level"],
			desc = L["Bars with higher numbers always show up on top of lower numbers."],
			get = function ()
				return indicator.dbx.level or 1
			end,
			set = function (_, v)
				indicator.dbx.level = v
				self:RefreshIndicator(indicator, "Layout", "Update" )
			end,
			values = levelValues,
		}
	end
end

-- Grid2Options:MakeIndicatorTypeLevelOptions()
function Grid2Options:MakeIndicatorTypeLevelOptions(indicator, options)
	self:MakeHeaderOptions( options, "General" )
	self:MakeIndicatorTypeOptions( indicator, options )
	self:MakeIndicatorLevelOptions( indicator, options )
end

-- Grid2Options:MakeIndicatorSizeOptions()
function Grid2Options:MakeIndicatorIconSizeOptions(indicator, options, optionParams)
	options.size = {
		type = "range",
		order = 10,
		name = L["Icon Size"],
		desc = L["Adjust the size of the icon, select zero to use the theme default icon size."],
		min = 0,
		max = 50,
		step = 1,
		get = function ()
			return indicator.dbx.size
		end,
		set = function (_, v)
			indicator.dbx.size = v>0 and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end

-- Grid2Options:MakeIndicatorSizeOptions()
function Grid2Options:MakeIndicatorSizeOptions(indicator, options, optionParams)
	options.size = {
		type = "range",
		order = 10,
		name = L["Size"],
		desc = L["Adjust the size of the indicator."],
		min = 5,
		max = 50,
		step = 1,
		get = function ()
			return indicator.dbx.size
		end,
		set = function (_, v)
			indicator.dbx.size = v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end

-- Grid2Options:MakeIndicatorBorderSizeOptions()
function Grid2Options:MakeIndicatorBorderSizeOptions(indicator, options, optionParams)
	options.borderSize = {
		type = "range",
		order = 20,
		name = L["Border Size"],
		desc = L["Adjust the border size of the indicator."],
		min = 0,
		max = 20,
		step = 1,
		get = function () return indicator.dbx.borderSize or 0 end,
		set = function (_, v)
			if v == 0 then v = nil end
			indicator.dbx.borderSize = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
end

-- Grid2Options:MakeIndicatorTextureOptions()
function Grid2Options:MakeIndicatorTextureOptions(indicator, options, optionParams)
	options.texture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 11,
		name = L["Frame Texture"],
		desc = L["Adjust the texture of the indicator."],
		get = function (info) return indicator.dbx.texture or "Grid2 Flat" end,
		set = function (info, v)
			indicator.dbx.texture = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = AceGUIWidgetLSMlists.statusbar,
	}
end

-- Grid2Options:MakeIndicatorBorderOptions()
function Grid2Options:MakeIndicatorBorderOptions(indicator, options, optionParams)
	optionParams = optionParams or {}
	optionParams.color1 = L["Border Color"]
	optionParams.colorDesc1 = L["Adjust border color and alpha."]
	self:MakeHeaderOptions( options, "Border" )
	self:MakeIndicatorBorderSizeOptions(indicator, options, optionParams)
	self:MakeIndicatorColorOptions(indicator, options, optionParams)
end

-- Grid2Options:MakeIndicatorColorOptions()
do
	local function GetIndicatorColor(info)
		local indicator = info.arg.indicator
		local colorKey  = "color" .. info.arg.colorIndex
		local c = indicator.dbx[ colorKey ]
		if c then return c.r, c.g, c.b, c.a end
		return 0, 0, 0, 0
	end
	local function SetIndicatorColor(info, r, g, b, a)
		local colorKey   = "color" .. info.arg.colorIndex
		local indicator  = info.arg.indicator
		local dbx = indicator.dbx
		local c = dbx[colorKey]
		if not c then c = {}; dbx[colorKey] = c end
		c.r, c.g, c.b, c.a = r, g, b, a
		Grid2Options:RefreshIndicator(indicator, "Layout", "Update")
	end
	function Grid2Options:MakeIndicatorColorOptions(indicator, options, optionParams)
		local colorCount = indicator.dbx.colorCount or 1
		local name = L["Color"]
		local desc = L["Color for %s."]:format(indicator.name)
		for i = 1, colorCount, 1 do
			local colorKey = "color" .. i
			if (optionParams and optionParams[colorKey]) then
				name = optionParams[colorKey]
			elseif (colorCount > 1) then
				name = L["Color %d"]:format(i)
			end
			local colorDescKey = "colorDesc" .. i
			if (optionParams and optionParams[colorDescKey]) then
				desc = optionParams[colorDescKey]
			elseif (colorCount > 1) then
				desc = name
			end
			options[colorKey] = {
				type = "color",
				order = (20 + i),
				name = name,
				desc = desc,
				get = GetIndicatorColor,
				set = SetIndicatorColor,
				hasAlpha = true,
				arg = {indicator = indicator, colorIndex = i},
			}
		end
	end
end

-- Grid2Options:MakeIndicatorLocationOptions()
function Grid2Options:MakeIndicatorLocationOptions(indicator, options)
	local location  = indicator.dbx.location
	self:MakeHeaderOptions( options, "Location" )
	options.relPoint = {
		type = 'select',
		order = 4,
		name = L["Location"],
		desc = L["Align my align point relative to"],
		values = self.pointValueList,
		get = function() return self.pointMap[location.relPoint] end,
		set = function(_, v)
			location.relPoint = self.pointMap[v]
			location.point = location.relPoint
			self:RefreshIndicator(indicator, "Layout", "Update" )
		end,
	}
	options.point = {
		type = 'select',
		order = 5,
		name = L["Align Point"],
		desc = L["Align this point on the indicator"],
		values = self.pointValueList,
		get = function() return self.pointMap[location.point] end,
		set = function(_, v)
			location.point = self.pointMap[v]
			self:RefreshIndicator(indicator, "Layout", "Update" )
		end,
	}
	options.x = {
		type = "range",
		order = 7,
		name = L["X Offset"],
		desc = L["X - Horizontal Offset"],
		softMin = -50, softMax = 50, step = 1, bigStep = 1,
		get = function() return location.x end,
		set = function(_, v)
			location.x = v
			self:RefreshIndicator(indicator, "Layout", "Update" )
		end,
	}
	options.y = {
		type = "range",
		order = 8,
		name = L["Y Offset"],
		desc = L["Y - Vertical Offset"],
		softMin = -50, softMax = 50, step = 1, bigStep = 1,
		get = function() return location.y end,
		set = function(_, v)
			location.y = v
			self:RefreshIndicator(indicator, "Layout", "Update" )
		end,
	}
end

