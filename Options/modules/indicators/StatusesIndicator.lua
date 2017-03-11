-- Grid2Options:MakeIndicatorStatusOptions()

local Grid2Options = Grid2Options
local L = Grid2Options.L

local function RegisterIndicatorStatus(indicator, status, value)
	if value then
		local priority = #indicator.statuses>0 and indicator.priorities[indicator.statuses[1]] + 1 or 50 
		Grid2:DbSetMap(indicator.name, status.name, priority)
		indicator:RegisterStatus(status, priority)
		-- special case for auras
		local type = status.dbx.type
		if type=="buff" or type=="debuff" or type=="debuffType" then
			Grid2:RefreshAuras() 
		end
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

local function GetIndicatorStatus(info, statusKey)
	local indicator = info.arg.indicator
	statusKey = statusKey or info[#info]
	for key, status in Grid2:IterateStatuses() do
		if (key == statusKey) then
			return status.indicators[indicator]
		end
	end
	return false
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

function Grid2Options:MakeIndicatorCurrentStatusOptions(indicator, options, callBack)
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
				name =  Grid2Options.LocalizeStatus(status),
				desc = L["Select statuses to display with the indicator"],
				get = GetIndicatorStatus,
				set = SetIndicatorStatusCurrent,
				arg = arg,
			}
			if more then
				options[statusKey .. "U"] = {
					type = "execute",
					order = order + 1,
					width = "half",
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
					width = "half",
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

-- Public method
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
		get = GetIndicatorStatus,
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
			return status.indicators[ Grid2.indicators[key] ] 
		end,
		set = function(info,key,value)
			local indicator = Grid2.indicators[key]
			if indicator.dbx.type ~= 'multibar' then
				RegisterIndicatorStatus(indicator, status, value)
			end	
		end,
		confirm = function(info,key)  
			return Grid2.indicators[key].dbx.type == 'multibar' and L['This indicator cannot be changed from here: go to "indicators" section to assign/unassign statuses to this indicator.']
		end,	
	}
end
