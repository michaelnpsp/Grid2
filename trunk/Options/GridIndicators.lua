--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local media = LibStub("LibSharedMedia-3.0", true)

local Grid2Options = Grid2Options

-- List of indicator types that can be created
local newIndicatorTypes = {}

local pointMap = {
	TOPLEFT = "1",
	LEFT = "2",
	BOTTOMLEFT = "3",
	TOP = "4",
	CENTER = "5",
	BOTTOM = "6",
	TOPRIGHT = "7",
	RIGHT = "8",
	BOTTOMRIGHT = "9",
	["1"] = "TOPLEFT",
	["2"] = "LEFT",
	["3"] = "BOTTOMLEFT",
	["4"] = "TOP",
	["5"] = "CENTER",
	["6"] = "BOTTOM",
	["7"] = "TOPRIGHT",
	["8"] = "RIGHT",
	["9"] = "BOTTOMRIGHT",
}

local pointMapText = {
	LEFTTOP = "1",
	LEFTMIDDLE = "2",
	LEFTBOTTOM = "3",
	CENTERTOP = "4",
	CENTERMIDDLE = "5",
	CENTERBOTTOM = "6",
	RIGHTTOP = "7",
	RIGHTMIDDLE = "8",
	RIGHTBOTTOM = "9",
	["1"] = { "LEFT", "TOP" },
	["2"] = { "LEFT", "MIDDLE" },
	["3"] = { "LEFT", "BOTTOM" },
	["4"] = { "CENTER", "TOP" },
	["5"] = { "CENTER", "MIDDLE" },
	["6"] = {"CENTER", "BOTTOM" },
	["7"] = { "RIGHT", "TOP" },
	["8"] = { "RIGHT", "MIDDLE" }, 
	["9"] = { "RIGHT", "BOTTOM" },
}

local pointValueList = {
	["1"] = L["TOPLEFT"],
	["2"] = L["LEFT"],
	["3"] = L["BOTTOMLEFT"],
	["4"] = L["TOP"],
	["5"] = L["CENTER"],
	["6"] = L["BOTTOM"],
	["7"] = L["TOPRIGHT"],
	["8"] = L["RIGHT"],
	["9"] = L["BOTTOMRIGHT"],
}

function Grid2Options.GetNewIndicatorTypes()
	return newIndicatorTypes
end

function Grid2Options:GetNewStatusPriority(indicator)
	if #indicator.statuses>0 then
		return indicator.priorities[indicator.statuses[1]] + 1 
	else
		return 50
	end	
end

function Grid2Options:RegisterIndicatorStatus(indicator, status, newPriority)
	local baseKey = indicator.name
	local statusKey = status.name
	local priority = newPriority or Grid2Options:GetNewStatusPriority(indicator)
	
	if not Grid2.db.profile.statusMap[baseKey] then
		Grid2.db.profile.statusMap[baseKey]= {}
	end
    Grid2.db.profile.statusMap[baseKey][statusKey]= priority
	indicator:RegisterStatus(status, priority)
	-- Hackish to refresh correctly aura statuses, check if is aura type status before 
	if status.auraKey or status.auraKeys then Grid2:RefreshAuras() end	
end

function Grid2Options:UnregisterIndicatorStatus(indicator, status)
	local baseKey = indicator.name
	local statusKey = status.name
	
    Grid2.db.profile.statusMap[baseKey][statusKey]= nil
	indicator:UnregisterStatus(status)
end


-- Wrapper for indicator:SetStatusPriority that sets priority in setup as well
function Grid2Options:SetStatusPriority(indicator, status, priority)
	local baseKey = indicator.name
	local statusKey = status.name

    Grid2.db.profile.statusMap[baseKey][statusKey]= priority
	indicator:SetStatusPriority(status, priority)
end


function Grid2Options.GetIndicatorStatus(info, statusKey)
	local indicator = info.arg
	statusKey = statusKey or info[# info]

	for key, status in Grid2:IterateStatuses() do
		if (key == statusKey) then
			return status.indicators[indicator]
		end
	end

	return false
end

function GetParentOption(info, objectKey)
	local settings= info.options.args.indicators.args[objectKey].args
	return settings.statusesCurrent or settings.statuses.args.statusesCurrent
end

function Grid2Options.SetIndicatorStatusCurrent(info, value)
	local indicator = info.arg
	local statusKey = info[# info]

	for key, status in Grid2:IterateStatuses() do
		if (key == statusKey) then
			if (value) then
				Grid2Options:RegisterIndicatorStatus(indicator, status)
			else
				Grid2Options:UnregisterIndicatorStatus(indicator, status)
			end
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			Grid2Frame:UpdateIndicators()

			local parentOption = GetParentOption(info, indicator.name)
			wipe(parentOption.args)
			Grid2Options:AddIndicatorCurrentStatusOptions(indicator, parentOption.args)
		end
	end
end
--/dump Grid2Options.options.Grid2.args.indicator.args.alpha

function Grid2Options.SetIndicatorStatus(info, statusKey, value)
	local indicator = info.arg

	for key, status in Grid2:IterateStatuses() do
		if (key == statusKey) then
			if (value) then
				Grid2Options:RegisterIndicatorStatus(indicator, status)
			else
				Grid2Options:UnregisterIndicatorStatus(indicator, status)
			end
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			Grid2Frame:UpdateIndicators()

			local parentOption = GetParentOption(info, indicator.name)
			wipe(parentOption.args)
			Grid2Options:AddIndicatorCurrentStatusOptions(indicator, parentOption.args)
		end
	end
end

local function StatusSwapPriorities(indicator, index1, index2)
	local status1 = indicator.statuses[index1]
	local status2 = indicator.statuses[index2]
	local priority1 = indicator:GetStatusPriority(status1)
	local priority2 = indicator:GetStatusPriority(status2)
	Grid2Options:SetStatusPriority(indicator, status1, priority2)
	Grid2Options:SetStatusPriority(indicator, status2, priority1)
end

local function StatusShiftUp(info, indicator, lowerStatus)
	local index= indicator:GetStatusIndex(lowerStatus)
	if index then
		local newIndex = index>1 and index - 1 or #indicator.statuses
		StatusSwapPriorities(indicator, index, newIndex)
		local parentOption = GetParentOption(info, indicator.name)
		wipe(parentOption.args)
		Grid2Options:AddIndicatorCurrentStatusOptions(indicator, parentOption.args)
	end
end

local function StatusShiftDown(info, indicator, higherStatus)
	local index= indicator:GetStatusIndex(higherStatus)
	if index then
		local newIndex = index<#indicator.statuses and index+1 or 1
		StatusSwapPriorities(indicator, index, newIndex)
		local parentOption = GetParentOption(info, indicator.name)
		wipe(parentOption.args)
		Grid2Options:AddIndicatorCurrentStatusOptions(indicator, parentOption.args)
	end
end

function Grid2Options:AddIndicatorCurrentStatusOptions(indicator, options)
	if indicator.statuses then
		local more= #indicator.statuses>1
		for index, status in ipairs(indicator.statuses) do
			local statusKey = status.name
			local order = 5 * index
			local passValue = {indicator = indicator, status = status}
			options[statusKey] = {
				type = "toggle",
				order = order,
				name =  Grid2Options.LocalizeStatus(status),
				desc = L["Select statuses to display with the indicator"],
				get = Grid2Options.GetIndicatorStatus,
				set = Grid2Options.SetIndicatorStatusCurrent,
				arg = indicator,
			}
			if more then
				options[statusKey .. "U"] = {
					type = "execute",
					order = order + 1,
					width = "half",
					image = "Interface\\Addons\\Grid2Options\\textures\\arrow-up",
					imageWidth= 16,
					imageHeight= 14,
					name= "",
					desc = L["Move the status higher in priority"],
					func = function (info)
						StatusShiftUp(info, indicator, status)
					end,
					arg = indicator,
				}
				options[statusKey .. "D"] = {
					type = "execute",
					order = order + 2,
					width = "half",
					image = "Interface\\Addons\\Grid2Options\\textures\\arrow-down",
					imageWidth= 16,
					imageHeight= 14,
					name= "",
					desc = L["Move the status lower in priority"],
					func = function (info)
						StatusShiftDown(info, indicator, status)
					end,
					arg = indicator,
				}
				options[statusKey .."S"] = {
				  type= "description",
				  name= "",
				  order= order + 3
				}
			end	
		end
	end
end

function Grid2Options:AddIndicatorStatusOptions(indicator, options)
	options.statusesCurrent = {
		type = "group",
		order = 100,
		inline = true,
		name = L["Current Statuses"],
		desc = L["Current statuses in order of priority"],
		args = {},
	}
	Grid2Options:AddIndicatorCurrentStatusOptions(indicator, options.statusesCurrent.args)

	options.statusesAvailable = {
	    type = "multiselect",
		order = 200,
		name = L["Available Statuses"],
		desc = L["Available statuses you may add"],
		values = function (info)
			local statusAvailable = Grid2Options:GetAvailableStatusValues(indicator)
			return statusAvailable
		end,
		get = Grid2Options.GetIndicatorStatus,
		set = Grid2Options.SetIndicatorStatus,
		arg = indicator,
	}
end


local function DeleteIndicator(indicator)
	-- Disable indicator on visible unit frames 
	Grid2Frame:WithAllFrames(function (f) indicator:Disable(f) end)
	-- Remove indicator and its stasuses from runtime	
	Grid2:UnregisterIndicator(indicator) 
	-- Remove indicator from database	
	local baseKey = indicator.name
	Grid2:DbSetIndicator(baseKey,nil)
 	Grid2Options:DeleteElement("indicators", baseKey)
	-- Remove linked color indicator if exists
	baseKey = baseKey .. '-color'
	if Grid2:DbGetIndicator(baseKey) then
		Grid2:DbSetIndicator(baseKey, nil)
	end	
	Grid2Options:DeleteElement("indicators", baseKey)
	Grid2Frame:UpdateIndicators()
end

function Grid2Options:MakeIndicatorSizeOptions(indicator, options, optionParams)
	options = options or {}
	local baseKey = indicator.name

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
			indicator:UpdateDB()
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end,
	}

	return options
end

function Grid2Options:MakeIndicatorSquareSizeOptions(indicator, options, optionParams)
	options = options or {}
	local baseKey = indicator.name

	options.size = {
		type = "range",
		order = 10,
		name = L["Size"],
		desc = L["Adjust the size of the indicator."],
		min = 0,
		max = 50,
		step = 1,
		get = function () return indicator.dbx.size	end,
		set = function (_, v)
			indicator.dbx.size = v
			indicator:UpdateDB()
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end,
		hidden = function() return not indicator.dbx.size end
	}
	options.width = {
		type = "range",
		order = 11,
		name = L["Width"],
		desc = L["Adjust the width of the indicator."],
		min = 0,
		max = 50,
		step = 1,
		get = function () return indicator.dbx.width end,
		set = function (_, v)
			indicator.dbx.width = v
			indicator:UpdateDB()
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end,
		hidden = function() return indicator.dbx.size end
	}
	options.height = {
		type = "range",
		order = 12,
		name = L["Height"],
		desc = L["Adjust the height of the indicator."],
		min = 0,
		max = 50,
		step = 1,
		get = function () return indicator.dbx.height end,
		set = function (_, v)
			indicator.dbx.height = v
			indicator:UpdateDB()
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end,
		hidden = function() return indicator.dbx.size end
	}
	options.sizeToggle = {
		type = "toggle",
		name = L["Rectangle"],
		desc = L["Allows to independently adjust width and height."],
		order = 13,
		tristate = false,
		get = function () return not indicator.dbx.size end,
		set = function (_, v)
			if v then
				indicator.dbx.width= indicator.dbx.size or 5
				indicator.dbx.height= indicator.dbx.size or 5
				indicator.dbx.size= nil
			else
				indicator.dbx.size= indicator.dbx.width
				indicator.dbx.width= nil
				indicator.dbx.height= nil
			end
			indicator:UpdateDB()
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end,
	}
	
	return options
end


function Grid2Options:MakeIndicatorBorderSizeOptions(indicator, options, optionParams)
	options = options or {}
	local baseKey = indicator.name

	local name = L["Border"]
	local desc = L["Adjust the border size of the indicator."]
	options.borderSize = {
		type = "range",
		order = 20,
		name = name,
		desc = desc,
		min = 0,
		max = 20,
		step = 1,
		get = function () return indicator.dbx.borderSize or 0 end,
		set = function (_, v)
			if v == 0 then v = nil end
			indicator.dbx.borderSize = v
			indicator:UpdateDB()
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			Grid2Frame:UpdateIndicators()
		end,
	}

	return options
end


function Grid2Options:MakeIndicatorTextureOptions(indicator, options, optionParams)
	options = options or {}
	local baseKey = indicator.name

	if Grid2Options.AddMediaOption then
		local textureOption = {
			type = "select",
			order = 9,
			name = L["Frame Texture"],
			desc = L["Adjust the texture of the indicator."],
			get = function (info)
				local v = indicator.dbx.texture or "Grid2 Flat"
				for i, t in ipairs(info.option.values) do
					if v == t then return i end
				end
			end,
			set = function (info, v)
				indicator.dbx.texture = info.option.values[v]
				indicator:UpdateDB()
				Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			end,
		}
		Grid2Options:AddMediaOption("statusbar", textureOption)
		options.texture = textureOption
	end
	return options
end

function Grid2Options:MakeIndicatorBorderOptions(indicator, options, optionParams)
	options = options or {}
	optionParams = optionParams or {}
	optionParams.color1 = L["Border"]
	optionParams.colorDesc1 = L["Adjust border color and alpha."]
	optionParams.typeKey = "indicators"

	Grid2Options:MakeIndicatorColorOptions(indicator, options, optionParams)
	Grid2Options:MakeIndicatorBorderSizeOptions(indicator, options, optionParams)
	
	return options
end

function Grid2Options:AddIndicatorDeleteOptions(indicator, options)
	options.deleteHeader = {
			type = "header",
			order = 151,
			name = "",
		}
	options.delete = {
	    type = "execute",
		order = 152,
	    name = L["Delete"],
	    func = function (info)
		  DeleteIndicator(indicator)
		end,
		arg = indicator,
	}
end

function Grid2Options.GetIndicatorColor(info)
	local passValue = info.arg
	local indicator = passValue.indicator
	local colorKey = "color"

	local colorIndex = passValue.colorIndex
	colorKey = colorKey .. colorIndex

	local c = indicator.dbx[colorKey]
	if (c) then
		return c.r, c.g, c.b, c.a
	else
		return 0, 0, 0, 0
	end
end

function Grid2Options.SetIndicatorColor(info, r, g, b, a)
	local passValue = info.arg
	local indicator = passValue.indicator
	local typeKey = passValue.typeKey
	local dbx = indicator.dbx
	local colorKey = "color"

	local colorIndex = passValue.colorIndex
	colorKey = colorKey .. colorIndex

	local c = indicator.dbx[colorKey]
	if (not c) then
		c = {}
		indicator.dbx[colorKey] = c
	end
	c.r, c.g, c.b, c.a = r, g, b, a

	c = dbx[colorKey]
	if (not c) then
		c = {}
		dbx[colorKey] = c
	end
	c.r, c.g, c.b, c.a = r, g, b, a

	if indicator.UpdateDB then indicator:UpdateDB() end
	
	Grid2Frame:UpdateIndicators()
end

function Grid2Options:MakeIndicatorColorOptions(indicator, options, optionParams)
	options = options or {}

	local colorCount = indicator.dbx.colorCount or 1
	local name = L["Color"]
	local desc = L["Color for %s."]:format(indicator.name)
	local typeKey = optionParams and optionParams.typeKey or "indicators"
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
			get = Grid2Options.GetIndicatorColor,
			set = Grid2Options.SetIndicatorColor,
			hasAlpha = true,
			arg = {indicator = indicator, colorIndex = i, typeKey = typeKey},
		}
	end

	return options
end

Grid2Options.typeMorphValues = {
	icon = {icon = L["icon"], square = L["square"], text = L["text"]},
	square = {square = L["square"], text = L["text"],icon = L["icon"]},
	text = {square = L["square"], text = L["text"],icon = L["icon"]},
}

function Grid2Options.GetIndicatorTypeValues(info)
	local indicator = info.arg
	local typeKey = indicator.dbx.type
	local typeMorphValues = Grid2Options.typeMorphValues
	
	if (not typeMorphValues[typeKey]) then
		typeMorphValues[typeKey] = {}
		typeMorphValues[typeKey][typeKey] = L[typeKey]
	end
	
	return Grid2Options.typeMorphValues[typeKey]
end

function Grid2Options.GetIndicatorType(info)
	local indicator = info.arg
	return indicator.dbx.type
end

local defaultFont = "Friz Quadrata TT"

Grid2Options.typeDefaultValues = {
	icon = {size = 16, fontSize = 8,},
	square = {size = 5,},
	text = { duration = true, stack= false, textlength = 12, fontSize = 8, font = defaultFont,},
}

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

function Grid2Options.SetIndicatorType(info, value)
	local indicator = info.arg
	local baseKey = indicator.name
	local dbx = indicator.dbx
	local colorKey = baseKey.."-color"
	local oldType = dbx.type

	if  dbx.type == value then return end
	
	-- Set new fields width defaults values
	dbx.type = value
	for k, v in pairs(Grid2Options.typeDefaultValues[value]) do
		if (not dbx[k]) then
			indicator.dbx[k] = v
			dbx[k] = v
		end
	end
	-- Remove old indicator
	Grid2Frame:WithAllFrames(function (f) indicator:Disable(f) end)
	Grid2:UnregisterIndicator(indicator)
	-- Create new indicator
	local setupFunc = Grid2.setupFunc[dbx.type]
	local newIndicator = setupFunc(baseKey, dbx)
	-- Remove incompatible statuses from database
	local map= Grid2:DbGetValue("statusMap", baseKey)
	for statusKey, priority in pairs(map) do
		local status = Grid2.statuses[statusKey]
    	if (not status) or (not Grid2:IsCompatiblePair(newIndicator, status)) then
			map[statusKey]= nil
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
		Grid2:DbSetIndicator( colorKey , { type="text-color" })
	end
	-- Delete old indicator options
	Grid2Options:DeleteElement("indicators", baseKey)
	Grid2Options:DeleteElement("indicators", baseKey.."-color")
	-- Create new indicator options
	local funcMakeOptions = Grid2Options.typeMakeOptions[dbx.type]
	if (funcMakeOptions) then
		funcMakeOptions(newIndicator)
	end

	Grid2Frame:UpdateIndicators()
end

function Grid2Options:MakeIndicatorTypeOptions(indicator, options, optionParams)
	local baseKey = indicator.name
	options.type = {
	    type = 'select',
		order = 3,
		name = L["Type"],
		desc = L["Type of indicator"],
	    values = Grid2Options.GetIndicatorTypeValues,
	    get = Grid2Options.GetIndicatorType,
	    set = Grid2Options.SetIndicatorType,
		arg = indicator,
	}
end

function Grid2Options:AddIndicatorLocationOptions(indicator, options)
	local baseKey   = indicator.name
	local location  = indicator.dbx.location
	options.locationSeparator1 = {
			type = "header",
			order = 3,
			name = L["Location"],
	}
	options.relPoint = {
		    type = 'select',
			order = 4,
			name = L["Location"],
			desc = L["Align my align point relative to"],
		    values = pointValueList,
			get = function() return pointMap[location.relPoint] end,
			set = function(_, v)
					location.relPoint= pointMap[v]
					indicator.anchorRel = location.relPoint
					location.point= location.relPoint
					indicator.anchor= location.relPoint
					Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			end,
		}
	options.point = {
		    type = 'select',
			order = 5,
			name = L["Align Point"],
			desc = L["Align this point on the indicator"],
		    values = pointValueList,
			get = function() return pointMap[location.point] end,
			set = function(_, v)
					location.point = pointMap[v] 
					indicator.anchor = location.point
					Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			end,
		}
	options.x = {
			type = "range",
			order = 6,
			name = L["X Offset"],
			desc = L["X - Horizontal Offset"],
			min = -50, max = 50, step = 1, bigStep = 1,
			get = function() return location.x end,
			set = function(_, v)
					location.x = v 
					indicator.offsetx = v
					Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			end,
		}
	options.y = {
			type = "range",
			order = 7,
			name = L["Y Offset"],
			desc = L["Y - Vertical Offset"],
			min = -50, max = 50, step = 1, bigStep = 1,
			get = function() return location.y end,
			set = function(_, v)
					location.y = v
			        indicator.offsety = v
					Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			end,
		}
	options.frameLevel = {
		type = "select",
		order = 8,
		name = L["Frame Level"],
		desc = L["Bars with higher numbers always show up on top of lower numbers."],
		get = function ()
			return indicator.dbx.level or 1
		end,
		set = function (_, v)
			indicator.frameLevel = v
			indicator.dbx.level = v
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end,
		values={ 1,2,3,4,5,6,7,8,9 }
	}
	options.locationSeparator2 = {
			type = "header",
			order = 9,
			name = L["Appearance"],
		}		

end

local function MakeTextIndicatorOptions(indicator)
	local baseKey = indicator.name
	local statuses= {}
	local options = {
		textlength = {
			type = "range",
			order = 10,
			name = L["Text Length"],
			desc = L["Maximum number of characters to show."],
			min = 0,
			max = 20,
			step = 1,
			get = function () return indicator.dbx.textlength end,
			set = function (_, v)
				indicator.dbx.textlength = v
				indicator:UpdateDB()
				Grid2Frame:UpdateIndicators()
			end,
		},
		fontsize = {
			type = "range",
			order = 20,
			name = L["Font Size"],
			desc = L["Adjust the font size."],
			min = 6,
			max = 24,
			step = 1,
			get = function ()
				return indicator.dbx.fontSize
			end,
			set = function (_, v)
				indicator.dbx.fontSize = v
				local font = media and media:Fetch('font', indicator.dbx.font) or STANDARD_TEXT_FONT
				Grid2Frame:WithAllFrames(function (f) indicator:SetTextFont(f, font, v) end)
			end,
		},
		durationHeader = {
				type = "header",
				order = 80,
				name = L["Display"],
		},
		duration = {
			type = "toggle",
			name = L["Show duration"],
			desc = L["Show the time remaining."],
			order = 83,
			tristate = true,
			get = function ()
				return indicator.dbx.duration
			end,
			set = function (_, v)
				indicator.dbx.duration = v
				indicator.dbx.elapsed = nil
				indicator:UpdateDB()
				Grid2Frame:UpdateIndicators()
			end,
		},
		elapsed = {
			type = "toggle",
			name = L["Show elapsed time"],
			desc = L["Show the elapsed time."],
			order = 84,
			tristate = true,
			get = function ()
				return indicator.dbx.elapsed
			end,
			set = function (_, v)
				indicator.dbx.elapsed = v
				indicator.dbx.duration = nil
				indicator:UpdateDB()
				Grid2Frame:UpdateIndicators()
			end,
		},
		stack = {
			type = "toggle",
			name = L["Show stack"],
			desc = L["Show the number of stacks."],
			order = 85,
			tristate = true,
			get = function ()
				return indicator.dbx.stack
			end,
			set = function (_, v)
				indicator.dbx.stack = v
				indicator:UpdateDB()
				Grid2Frame:UpdateIndicators()
			end,
		},
		percent = {
			type = "toggle",
			name = L["Show percent"],
			desc = L["Show percent value"],
			order = 87,
			tristate = true,
			get = function ()
				return indicator.dbx.percent
			end,
			set = function (_, v)
				indicator.dbx.percent = v
				indicator:UpdateDB()
				Grid2Frame:UpdateIndicators()
			end,
		},
	}
	if Grid2Options.AddMediaOption then
		options.fontFlags = {
			type = "select",
			order = 75,
			name = L["Font Border"],
			desc = L["Set the font border type."],
			get = function () return indicator.dbx.fontFlags or "DEFAULT" end,
			set = function (_, v)
				if v=="DEFAULT" then v= nil	end
				indicator.dbx.fontFlags = v
				local font = media and media:Fetch('font', indicator.dbx.font) or STANDARD_TEXT_FONT
				Grid2Frame:WithAllFrames(function (f) indicator:SetTextFont(f, font, indicator.dbx.fontSize) end)
			end,
			values={ ["DEFAULT"]= L["None"], ["OUTLINE"] = L["Thin"], ["THICKOUTLINE"] = L["Thick"]}
		}
		local fontOption = {
			type = "select",
			order = 70,
			name = L["Font"],
			desc = L["Adjust the font settings"],
		}
		Grid2Options:AddMediaOption("font", fontOption)
		local values = fontOption.values
		fontOption.get = function ()
			local fontIndex
			for index, handle in ipairs(values) do
				if (indicator.dbx.font == handle) then
					fontIndex = index
					break
				end
			end
			return fontIndex
		end
		fontOption.set = function (_, v)
			local fontHandle = values[v]
			indicator.dbx.font = fontHandle
			local font = media:Fetch("font", fontHandle)
			local fontsize = indicator.dbx.fontSize
			Grid2Frame:WithAllFrames(function (f) indicator:SetTextFont(f, font, fontsize) end)
		end
		options.font = fontOption
	end
	Grid2Options:MakeIndicatorTypeOptions(indicator, options)
	Grid2Options:AddIndicatorLocationOptions(indicator, options)
	Grid2Options:AddIndicatorDeleteOptions(indicator, options)

	Grid2Options:AddIndicatorStatusOptions(indicator, statuses)

	Grid2Options:AddIndicatorElement(indicator, options, statuses)

	local TextColor = Grid2.indicators[indicator.name .. "-color"]
	if TextColor then	
		options = {}
		Grid2Options:AddIndicatorStatusOptions(TextColor, options)
		Grid2Options:AddIndicatorElement(TextColor, options)	
	end
end

local function MakeAlphaIndicatorOptions(indicator)
	local options = {}
	Grid2Options:AddIndicatorStatusOptions(indicator, options)
	Grid2Options:AddIndicatorElement(indicator, options)
end

local function MakeBarColorIndicatorOptions(indicator)
	local baseKey = indicator.name
	local options = {}
	local statuses= {}
	options.inverColor= {
		type = "toggle",
		name = L["Invert Bar Color"],
		desc = L["Swap foreground/background colors on bars."],
		order = 10,
		tristate = true,
		get = function ()
			return indicator.dbx.invertColor
		end,
		set = function (_, v)
			indicator.dbx.invertColor = v
			indicator:UpdateDB()
			if not v then
			    local c= Grid2Frame.db.profile.frameContentColor
				Grid2Frame:WithAllFrames(function (f) f.container:SetVertexColor(c.r, c.g, c.b, c.a) end)
			end	
			Grid2Frame:UpdateIndicators()
		end,
	}	
	options.barOpacity = {
		type = "range",
		order = 20,
		name = L["Opacity"],
		desc = L["Set the opacity."],
		min = 0,
		max = 1,
		step = 0.01,
		bigStep = 0.05,
		get = function () return indicator.dbx.opacity or 1	end,
		set = function (_, v)
			indicator.dbx.opacity = v
			indicator:UpdateDB()
			Grid2Frame:UpdateIndicators()
		end,
		disabled= function() return indicator.dbx.invertColor end,
	}
	Grid2Options:AddIndicatorStatusOptions(indicator, statuses)
	Grid2Options:AddIndicatorElement(indicator, options, statuses)
end

local function MakeBarIndicatorOptions(indicator)
	local baseKey = indicator.name
	local options = {}
	local statuses= {}

	options.orientation = {
		type = "select",
		order = 10,
		name = L["Orientation of the Bar"],
		desc = L["Set status bar orientation."],
		get = function ()
			return indicator.dbx.orientation or "DEFAULT"
		end,
		set = function (_, v)
			if v=="DEFAULT" then v= nil	end
			indicator.orientation= v
			indicator.dbx.orientation = v
			Grid2Frame:WithAllFrames(function (f) indicator:SetOrientation(f,v) end)
		end,
		values={ ["DEFAULT"]= L["DEFAULT"], ["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
	}
	options.barWidth= {
		type = "range",
		order = 30,
		name = L["Bar Width"],
		desc = L["Choose zero to set the bar to the same width as parent frame"],
		min = 0,
		max = 75,
		step = 1,
		get = function ()
			return indicator.dbx.width
		end,
		set = function (_, v)
			if v==0 then v= nil end
			indicator.dbx.width = v
			indicator.width= v
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end,	
	
	}
	options.barHeight= {
		type = "range",
		order = 40,
		name = L["Bar Height"],
		desc = L["Choose zero to set the bar to the same height as parent frame"],
		min = 0,
		max = 75,
		step = 1,
		get = function ()
			return indicator.dbx.height
		end,
		set = function (_, v)
			if v==0 then v= nil end
			indicator.dbx.height = v
			indicator.height= v
			Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
		end,	
	}
	options.durationHeader = {
			type = "header",
			order = 45,
			name = L["Display"],
	}
	options.duration = {
		type = "toggle",
		name = L["Show duration"],
		desc = L["Show the time remaining."],
		order = 50,
		tristate = true,
		get = function ()
			return indicator.dbx.duration
		end,
		set = function (_, v)
			indicator.dbx.duration = v
			indicator:UpdateDB()
			Grid2Frame:UpdateIndicators()
		end,
	}
	options.stack = {
		type = "toggle",
		name = L["Show stack"],
		desc = L["Show the number of stacks."],
		order = 55,
		tristate = true,
		get = function ()
			return indicator.dbx.stack
		end,
		set = function (_, v)
			indicator.dbx.stack = v
			indicator:UpdateDB()
			Grid2Frame:UpdateIndicators()
		end,
	}
	if Grid2Options.AddMediaOption then
		local textureOption = {
			type = "select",
			order = 20,
			name = L["Frame Texture"],
			desc = L["Adjust the frame texture."],
			get = function (info)
				local v = indicator.dbx.texture
				for i, t in ipairs(info.option.values) do
					if v == t then return i end
				end
			end,
			set = function (info, v)
				indicator.dbx.texture = info.option.values[v]
				indicator:UpdateDB()
				Grid2Frame:WithAllFrames(function (f) indicator:Layout(f) end)
			end,
		}
		Grid2Options:AddMediaOption("statusbar", textureOption)
		options.texture = textureOption
	end
	Grid2Options:AddIndicatorLocationOptions(indicator, options)
	Grid2Options:AddIndicatorDeleteOptions(indicator, options)

	Grid2Options:AddIndicatorStatusOptions(indicator, statuses)

	Grid2Options:AddIndicatorElement(indicator, options, statuses)
	
	local BarColor = Grid2.indicators[indicator.name .. "-color"]
	if BarColor then
		MakeBarColorIndicatorOptions(BarColor)
	end	
end

local function MakeBorderIndicatorOptions(indicator)
	local statuses = {}
	Grid2Options:AddIndicatorStatusOptions(indicator, statuses)

	local layout= {
		borderSize = {
			type = "range",
			order = 10,
			name = L["Border Size"],
			desc = L["Adjust the border of each unit's frame."],
			min = 1,
			max = 20,
			step = 1,
			get = function ()
				return Grid2Frame.db.profile.frameBorder
			end,
			set = function (_, frameBorder)
				Grid2Frame.db.profile.frameBorder = frameBorder
				Grid2Frame:LayoutFrames()
			end,
			disabled = InCombatLockdown,
		},
		borderDistance= {
			type = "range",
			name = L["Border separation"],
			desc = L["Adjust the distance between the border and the frame content."],
			min = -16,
			max = 16,
			step = 1,
			order = 15,
			get = function ()
				return Grid2Frame.db.profile.frameBorderDistance
			end,
			set = function (_, v)
				Grid2Frame.db.profile.frameBorderDistance = v
				Grid2Frame:LayoutFrames()
			end,
		},		
	}
	if Grid2Options.AddMediaOption then
		local textureOption = {
			type = "select",
			order = 25,
			name = L["Border Texture"],
			desc = L["Adjust the border texture."],
			get = function (info)
				local v = Grid2Frame.db.profile.frameBorderTexture
				for i, t in ipairs(info.option.values) do
					if v == t then return i end
				end
			end,
			set = function (info, v)
				Grid2Frame.db.profile.frameBorderTexture = info.option.values[v]
				Grid2Frame:LayoutFrames()
			end,
		}
		Grid2Options:AddMediaOption("border", textureOption)
		layout.borderTexture = textureOption
	end
	
	local optionParams = {}
	optionParams.color1 = L["Border Background Color"]
	optionParams.colorDesc1 = L["Adjust border background color and alpha."]
	optionParams.typeKey = "indicators"
	Grid2Options:MakeIndicatorColorOptions(indicator, layout, optionParams)
	
	Grid2Options:AddIndicatorElement(indicator, layout, statuses)
end

local function MakeIconIndicatorOptions(indicator)
	local statuses= {}
	local options = {
		spacerCooldown = {
			type = "header",
			order = 125,
			name = L["Cooldown"],
		},
		disableCooldown = {
			type = "toggle",
			order = 130,
			name = L["Disable Cooldown"],
			desc = L["Disable the Cooldown Frame"],
			tristate = true,
			get = function ()
				return indicator.dbx.disableCooldown
			end,
			set = function (_, v)
				indicator.dbx.disableCooldown = v
				Grid2Frame:WithAllFrames(function (f) indicator:Disable(f) end)
				indicator:UpdateDB()
				Grid2Frame:WithAllFrames(function (f) indicator:Create(f) indicator:Layout(f) end)
				Grid2Frame:UpdateIndicators()
			end,
		},		
		reverseCooldown = {
			type = "toggle",
			order = 135,
			name = L["Reverse Cooldown"],
			desc = L["Set cooldown to become darker over time instead of lighter."],
			tristate = true,
			get = function ()
				return indicator.dbx.reverseCooldown
			end,
			set = function (_, v)
				indicator.dbx.reverseCooldown = v
				local indicatorKey = indicator.name
				Grid2Frame:WithAllFrames(function (f)
					f[indicatorKey].Cooldown:SetReverse(indicator.dbx.reverseCooldown)
				end)
			end,
			hidden= function() return indicator.dbx.disableCooldown end,
		},		
		disableOmniCC = {
			type = "toggle",
			order = 140,
			name = L["Disable OmniCC"],
			desc = L["Disable OmniCC"],
			tristate = true,
			get = function ()
				return indicator.dbx.disableOmniCC
			end,
			set = function (_, v)
				indicator.dbx.disableOmniCC = v
				local indicatorKey = indicator.name
				Grid2Frame:WithAllFrames(function (f) f[indicatorKey].Cooldown.noCooldownCount= v end)
			end,
			hidden= function() return indicator.dbx.disableCooldown end,
		},
		spacerText = {
			type = "header",
			order = 90,
			name = L["Stack Text"],
		},
		disableStacks = {
			type = "toggle",
			order = 95,
			name = L["Disable Stack Text"],
			desc = L["Disable Stack Text"],
			tristate = true,
			get = function ()
				return indicator.dbx.disableStack
			end,
			set = function (_, v)
				indicator.dbx.disableStack = v
				Grid2Frame:WithAllFrames(function (f) indicator:Disable(f) end)
				indicator:UpdateDB()
				Grid2Frame:WithAllFrames(function (f) indicator:Create(f) indicator:Layout(f) end)
				Grid2Frame:UpdateIndicators()
			end,
		},
		fontsize = {
			type = "range",
			order = 105,
			name = L["Font Size"],
			desc = L["Adjust the font size."],
			min = 6,
			max = 24,
			step = 1,
			get = function ()
				return indicator.dbx.fontSize
			end,
			set = function (_, v)
				indicator.dbx.fontSize = v
				local indicatorKey = indicator.name
				Grid2Frame:WithAllFrames(function (f)
					local text= f[indicatorKey].CooldownText
					text:SetFont( text:GetFont() , v)
				end)
			end,
			hidden= function() return indicator.dbx.disableStack end,
		},
		fontColor = {
			type = "color",
			order = 110,
			name = L["Color"],
			desc = L["Color"],
			get = function()
				local c= indicator.dbx.stackColor
				if c then 	return c.r, c.g, c.b, c.a
				else		return 1,1,1,1
				end
			end,
			set = function( info, r,g,b,a )
				local c= indicator.dbx.stackColor
				if c then c.r, c.g, c.b, c.a = r, g, b, a
				else	  indicator.dbx.stackColor= { r=r, g=g, b=b, a=a}
				end
				local indicatorKey = indicator.name
				Grid2Frame:WithAllFrames(function (f) 
					local text= f[indicatorKey].CooldownText
					if text then text:SetTextColor(r,g,b,a) end
				end)
			 end, 
			hasAlpha = true,
			hidden= function() return indicator.dbx.disableStack end,
		},		
		fontJustify = {
		    type = 'select',
			order = 100,
			name = L["Text Location"],
			desc = L["Text Location"],
		    values = pointValueList,
			get = function()
				local JustifyH= indicator.dbx.fontJustifyH or "CENTER"
				local JustifyV= indicator.dbx.fontJustifyV or "MIDDLE"
				return pointMapText[ JustifyH..JustifyV ]
			end,
			set = function(_, v)
				local justify=  pointMapText[v]
				indicator.dbx.fontJustifyH= justify[1] 
				indicator.dbx.fontJustifyV= justify[2]
				local indicatorKey = indicator.name
				Grid2Frame:WithAllFrames(function (f) 
					f[indicatorKey].CooldownText:SetJustifyH(justify[1])
					f[indicatorKey].CooldownText:SetJustifyV(justify[2])
				end)
			end,
			hidden= function() return indicator.dbx.disableStack end,
		},
	}
	if Grid2Options.AddMediaOption then
		local fontOption = {
			type = "select",
			order = 120,
			name = L["Font"],
			desc = L["Adjust the font settings"],
			hidden= function() return indicator.dbx.disableStack end,
		}
		Grid2Options:AddMediaOption("font", fontOption)
		local values = fontOption.values
		fontOption.get = function ()
			local fontIndex
			if indicator.dbx.font then
				for index, handle in ipairs(values) do
					if indicator.dbx.font == handle then
						fontIndex = index
						break
					end
				end
			end	
			return fontIndex
		end
		fontOption.set = function (_, v)
			local fontHandle = values[v]
			indicator.dbx.font = fontHandle
			local font = media:Fetch("font", fontHandle)
			local fontsize = indicator.dbx.fontSize
			local indicatorKey = indicator.name
			Grid2Frame:WithAllFrames(function (f) 
				local text= f[indicatorKey].CooldownText
				if text then text:SetFont(font,fontsize, "OUTLINE") end
			end)
		end
		options.font = fontOption
	end
	
	Grid2Options:MakeIndicatorSizeOptions(indicator, options)
	Grid2Options:MakeIndicatorTypeOptions(indicator, options)
	Grid2Options:AddIndicatorLocationOptions(indicator, options)
	Grid2Options:MakeIndicatorBorderOptions(indicator, options)
	Grid2Options:AddIndicatorDeleteOptions(indicator, options)
	Grid2Options:AddIndicatorStatusOptions(indicator, statuses)

	Grid2Options:AddIndicatorElement(indicator, options, statuses)
end

local function MakeSquareIndicatorOptions(indicator)
	local layout={}
	local statuses={}
	Grid2Options:MakeIndicatorTextureOptions(indicator, layout)
	Grid2Options:MakeIndicatorSquareSizeOptions(indicator, layout)
	Grid2Options:MakeIndicatorTypeOptions(indicator, layout)
	Grid2Options:AddIndicatorLocationOptions(indicator, layout)
	Grid2Options:MakeIndicatorBorderOptions(indicator, layout)
	Grid2Options:AddIndicatorDeleteOptions(indicator, layout)
	Grid2Options:AddIndicatorStatusOptions(indicator, statuses)	
	Grid2Options:AddIndicatorElement(indicator, layout, statuses)
end

-- 

local newIndicatorValues= { name="", type= "square", relPoint= "TOPLEFT" }

local function NewIndicator()
	local newIndicatorName = Grid2Options:GetValidatedName(newIndicatorValues.name)
	if (newIndicatorName and newIndicatorName ~= "") then
		-- save indicator in database
		local defaults= Grid2Options.typeDefaultValues
		local dbx= { type= newIndicatorValues.type }
		dbx.location= Grid2.CreateLocation(newIndicatorValues.relPoint)
		if (newIndicatorValues.type == "square") then
			dbx.level = 6
			dbx.size = defaults.square.size
		elseif (newIndicatorValues.type == "icon") then
			dbx.level = 8
			dbx.size = defaults.icon.size
			dbx.fontSize= defaults.icon.fontSize
		elseif (newIndicatorValues.type == "text") then
			dbx.level = 7
			dbx.textlength= defaults.text.textlength
			dbx.fontSize= defaults.text.fontSize
			dbx.font= defaults.text.font
			Grid2:DbSetIndicator( newIndicatorName.."-color" , { type="text-color" })
		elseif (newIndicatorValues.type == "bar") then
			dbx.level = 3
			dbx.texture= "Gradient"
			local point= newIndicatorValues.relPoint
			if point=="LEFT" or point=="RIGHT" then
				dbx.width= 4
				dbx.orientation= "VERTICAL"
			elseif point~="CENTER" then
				dbx.height= 4
				dbx.orientation= "HORIZONTAL"
			end
			Grid2:DbSetIndicator( newIndicatorName.."-color" , { type="bar-color" })
		end
		Grid2:DbSetIndicator(newIndicatorName,dbx)
		-- Create runtime indicator 
		local setupFunc = Grid2.setupFunc[dbx.type]
		local indicator = setupFunc(newIndicatorName, dbx)
		Grid2Frame:WithAllFrames(function (f)
			indicator:Create(f)
			indicator:Layout(f)
		end)
		-- Create indicator options
		local funcMakeOptions = Grid2Options.typeMakeOptions[dbx.type]
		if (funcMakeOptions) then
			funcMakeOptions(indicator)
		end
	end
end

local function NewIndicatorDisabled()
	local name = Grid2Options:GetValidatedName(newIndicatorValues.name)
	if name and name ~= "" then
		if not Grid2.indicators[name] then 
			local _,frame= next(Grid2Frame.registeredFrames)
			if frame then
				-- Check if the name is in use by any unit frame child object
				for key,value in pairs(frame) do
					if name==key and type(value)~="table" then
						return true
					end
				end
				return false
			end	
		end
	end
	return true
end

local function AddIndicatorsGroup(reset)
	local options = {
		newIndicatorName = {
			type = "input",
			order = 2,
			width = "full",
			name = L["Name"],
			desc = L["Name of the new indicator"],
			usage = L["<CharacterOnlyString>"],
			get = function()  return newIndicatorValues.name end,
			set = function(_,v)	newIndicatorValues.name= v  end,
		},
		newIndicatorType = {
			type = 'select',
			order = 3,
			name = L["Type"],
			desc = L["Type of indicator to create"],
			values = Grid2Options.GetNewIndicatorTypes,
			get = function() return newIndicatorValues.type end,
			set = function(_,v)	
				newIndicatorValues.type= v  
				if v=="icon" or v=="text" then
					newIndicatorValues.relPoint= "CENTER"
				elseif v=="bar" then
					newIndicatorValues.relPoint= "BOTTOM"
				else
					newIndicatorValues.relPoint= "TOPLEFT"
				end
			end,
		},
		newIndicatorLocation= {
		    type = 'select',
			order = 4,
			name = L["Location"],
			desc = L["Align my align point relative to"],
		    values = pointValueList,
			get = function() return pointMap[newIndicatorValues.relPoint] end,
			set = function(_, v) newIndicatorValues.relPoint= pointMap[v] end,
		},
		newIndicator = {
			type = "execute",
			order = 9,
			name = L["New Indicator"],
			desc = L["Create a new indicator."],
			func = NewIndicator,
			disabled = NewIndicatorDisabled,
		},
		resetIndicatorsSpacer = {
			type = "header",
			order = 12,
			name = "",
		},
		testMode = {
			type = "execute",
			order = 50,
			name = L["Enable Test Mode"],
			desc = L["Enable Test Mode"],
			func = function(info)
					local r= Grid2Options:IndicatorsTestMode()
					info.option.name= r and L["Disable Test Mode"] or L["Enable Test Mode"]
					info.option.desc= info.option.name
			end,
		},
	}

	Grid2Options:AddElementGroup("indicators", options, 60, reset)

end


local indicatorTypesOrder= { 
	["alpha"] = 10,
	["border"] = 11,
	["bar"] = 12,
	["text"] = 50,
	["square"] = 60,
	["icon"] = 70,
}

--/dump Grid2Options.options.Grid2.args.indicator
function Grid2Options:AddIndicatorElement(element, layoutOptions, statusOptions)
	local insertLayout
	local insertStatus
	local type= string.gsub(element.dbx.type, "-color", "")
	local options = {}
	local insertPoint =  self.options.args.indicators

	-- indicator name language translation	
	local name= string.gsub(element.name, "-color", "")
	local lname= L[name]
	if lname==name then
		lname= string.gsub(lname,"-"," ")
	end
	if name ~= element.name then
		lname= lname .. L["-color"]
	end

	-- calculate icon
	local icon
	if name == element.name then
		if indicatorTypesOrder[type] then
			icon= "Interface\\Addons\\Grid2Options\\textures\\indicator-" .. type 
		else
			icon= "Interface\\Addons\\Grid2Options\\textures\\indicator-default"  
		end
	else
		icon= "Interface\\Addons\\Grid2Options\\textures\\indicator-color"
	end
	
	insertPoint.args[element.name] = {
		type = "group",
		childGroups= "tab",
		icon= icon,
		order= indicatorTypesOrder[type] or 100,
		name = lname,
		desc = L["Options for %s."]:format(name),
		args = options,
	}
	
	if statusOptions then
		insertLayout= {}
		insertStatus= {}
		options["layout"]=  {
			type="group",
			order= 20,
			name = L["Layout"],
			args= insertLayout,
		}
		options["statuses"]= {
			type="group",
			order= 10,
			name = L["statuses"],
			args= insertStatus,
		}
		for name, option in pairs(statusOptions) do
			insertStatus[name] = option
		end
	else
		insertLayout= options
	end
	
	for name, option in pairs(layoutOptions) do
		insertLayout[name] = option
	end
	
end

function Grid2Options:DeleteIndicatorElement(objectKey)
	local insertionPoint = self.options.args.indicators
	insertionPoint.args[objectKey] = nil
end

--No options for the indicator
function Grid2Options:MakeNoIndicatorOptions()
end

function Grid2Options:AddCreatableOptionHandler(typeKey, name, funcMakeOptions, optionParams)
	newIndicatorTypes[typeKey] = name
	self:AddOptionHandler(typeKey, funcMakeOptions, optionParams)
end

function Grid2Options:MakeIndicatorOptions(reset)

	self:DeleteElement("indicators")

	AddIndicatorsGroup(reset)

	self:AddOptionHandler("alpha", MakeAlphaIndicatorOptions)
	self:AddOptionHandler("border", MakeBorderIndicatorOptions)

	self:AddCreatableOptionHandler("icon", L["icon"], MakeIconIndicatorOptions)
	self:AddCreatableOptionHandler("square", L["square"], MakeSquareIndicatorOptions)
	self:AddCreatableOptionHandler("text", L["text"], MakeTextIndicatorOptions)
	self:AddCreatableOptionHandler("bar", L["bar"], MakeBarIndicatorOptions)

	self:AddOptionHandler("bar-color", Grid2Options.MakeNoIndicatorOptions)
	self:AddOptionHandler("text-color", Grid2Options.MakeNoIndicatorOptions)
 
    local indicators= Grid2.db.profile.indicators
 	for baseKey, dbx in pairs(indicators) do
		local indicator = Grid2.indicators[baseKey]
		if indicator then
			local funcMakeOptions = Grid2Options.typeMakeOptions[dbx.type]
			if (funcMakeOptions) then
				funcMakeOptions(indicator)
			else
				print("    **MakeIndicatorOptions no funcMakeOptions for ", baseKey, dbx.type)
			end
		else
			print("    **MakeIndicatorOptions no runtime indicator for ", baseKey)
		end
	end
end

