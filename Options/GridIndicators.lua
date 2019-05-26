--[[
	Indicators options
--]]

local Grid2Options = Grid2Options
local L = Grid2Options.L

-- Path to indicator icons
Grid2Options.indicatorIconPath = "Interface\\Addons\\Grid2Options\\media\\indicator-"

-- Creatable indicators list
Grid2Options.indicatorTypes = {}

-- Indicators sort order
Grid2Options.indicatorTypesOrder= { tooltip = 1, alpha = 2, border = 3, multibar = 4, bar = 5, text = 6, square = 7, icon = 8, icons = 9, portrait = 10 }

do
	-- ban these indicator names
	local indicator_name_blacklist = {
		["0"] = true,
		["UnwrapScript"] = true,
		["Execute"] = true,
		["CreateIndicators"] = true,
		["SetFrameRef"] = true,
		["WrapScript"] = true,
		["UpdateIndicators"] = true,
		["Layout"] = true,
		["menu"] = true,
		["container"] = true,
	}

	-- Default values for new or morphed indicators
	Grid2Options.indicatorDefaultValues = {
		icon   = { size = 16, fontSize = 8 },
		square = { size = 5 },
		text   = { duration = true, stack= false, textlength = 12, fontSize = 11, font = "Friz Quadrata TT" },
	}

	-- new values
	local newIndicatorValues = { name = "", type = "square", relPoint = "TOPLEFT" }

	local function NewIndicator()
		local newIndicatorName = Grid2Options:GetValidatedName(newIndicatorValues.name)
		if (newIndicatorName and newIndicatorName ~= "") then
			-- save indicator in database
			local defaults = Grid2Options.indicatorDefaultValues
			local dbx= { type = newIndicatorValues.type }
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
				-- dbx.font= defaults.text.font
				Grid2:DbSetIndicator( newIndicatorName.."-color" , { type="text-color" })
			elseif (newIndicatorValues.type == "bar") then
				dbx.level = 3
				local point= newIndicatorValues.relPoint
				if point=="LEFT" or point=="RIGHT" then
					dbx.width= 4
					dbx.orientation= "VERTICAL"
				elseif point~="CENTER" then
					dbx.height= 4
					dbx.orientation= "HORIZONTAL"
				end
				Grid2:DbSetIndicator( newIndicatorName.."-color" , { type="bar-color" })
			elseif (newIndicatorValues.type == "multibar") then
				dbx.level = 3
				dbx.textureColor = { r=0, g=0, b=0, a=1 }
				local point= newIndicatorValues.relPoint
				if point=="LEFT" or point=="RIGHT" then
					dbx.width= 4
					dbx.orientation= "VERTICAL"
				elseif point~="CENTER" then
					dbx.height= 4
					dbx.orientation= "HORIZONTAL"
				end
				Grid2:DbSetIndicator( newIndicatorName.."-color" , { type="multibar-color" })
			elseif (newIndicatorValues.type == "icons") then
				dbx.level = 8
			elseif (newIndicatorValues.type == "portrait") then
				dbx.level = 4
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
			newIndicatorValues.name = ""
			Grid2Options:MakeIndicatorOptions(indicator)
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
				else
					return indicator_name_blacklist[name] == true
				end
			end
		end
		return true
	end

	local workTable = {}
	local function GetCreatableIndicatorsValues()
		wipe(workTable)
		local indicators = Grid2.db.profile.indicators
		for name,option in pairs(Grid2Options.indicatorsOptions) do
			if option.order and option.order<25 then
				local indicator = Grid2.indicators[name]
				if indicator and Grid2Options.indicatorTypes[indicator.dbx.type] then
					workTable[name] = string.format("|T%s:0|t%s", option.icon, option.name)
				end
			end
		end
		return workTable	
	end

	local function RenameIndicator(info, name)
		Grid2Options:ShowEditDialog( "Rename Indicator:", Grid2Options.LI[name] or L[name], function(text)
			local len = strlen(text)
			if len>2 or len==0 then
				Grid2Options.LI[name] = len>2 and text or nil
				Grid2Options:MakeIndicatorOptions(Grid2.indicators[name])
				LibStub("AceConfigRegistry-3.0"):NotifyChange("Grid2")
			end	
		end)
	end

	local function DeleteIndicator(info, name)
		local indicator = Grid2.indicators[name]
		if not indicator or #indicator.statuses>0 or (indicator.sideKick and #indicator.sideKick.statuses>0) or indicator.parentName or indicator.childName then
			Grid2Options:MessageDialog( L["The selected indicator cannot be deleted because is in use. Uncheck the statuses linked to the indicator first."] ) 
			return
		end
		Grid2Options.LI[indicator.name] = nil
		Grid2Frame:WithAllFrames(indicator, "Disable")
		Grid2:DbSetIndicator(indicator.name,nil)
		if indicator.dbx.sideKick then
			Grid2:DbSetIndicator(indicator.dbx.sideKick.name, nil)
		end
		for _,t in pairs(Grid2.db.profile.themes.indicators) do
			t[name] = nil
		end	
		Grid2:UnregisterIndicator(indicator)
		Grid2Frame:UpdateIndicators()
		Grid2Options:DeleteIndicatorOptions(indicator)
	end

	-- function ToggleTestMode()
	local ToggleTestMode
	do
		local Test -- Test indicator
		local TestIcons = {}
		local TestAuras = {	tex = {}, cnt = {}, exp = {}, dur = {}, col = {} }
		local Exclude = { bar = true, multibar = true, alpha = true }
		ToggleTestMode = function()
			for _, category in pairs(Grid2Options.categories) do
				if category.icon then TestIcons[#TestIcons+1] = category.icon end
			end
			for _, params in pairs(Grid2Options.optionParams) do
				if params.titleIcon then TestIcons[#TestIcons+1] = params.titleIcon end
			end
			local time, color = GetTime(), { r=1,g=1,b=1,a=0.6 }
			for i=1,#TestIcons do
				TestAuras.tex[i] = TestIcons[i]
				TestAuras.cnt[i] = math.random(1,3)
				TestAuras.exp[i] = time+math.random(10,60)
				TestAuras.dur[i] = math.random(30) + 3
				TestAuras.col[i] = color
			end
			-- create test status
			Test = Grid2.statusPrototype:new("test",false)
			function Test:IsActive()    return true end
			function Test:GetText()     return "99" end
			function Test:GetColor()    return math.random(0,1),math.random(0,1),math.random(0,1),1 end
			function Test:GetPercent()	return math.random() end
			function Test:GetIcon()	    return TestIcons[ math.random(#TestIcons) ]	end
			function Test:GetIcons() 	return #TestIcons, TestAuras.tex, TestAuras.cnt, TestAuras.exp, TestAuras.dur, TestAuras.col end
			Test.dbx = TestIcons -- Asigned to TestIcons to avoid creating a new table
			Grid2:RegisterStatus( Test, {"text","color", "percent", "icon"}, "test" )
			ToggleTestMode = function()
				local method = Test.enabled and 'UnregisterStatus' or 'RegisterStatus'
				for _, indicator in Grid2:IterateIndicators() do
					if not Exclude[indicator.dbx.type] then
						indicator[method](indicator, Test, 1)
					end
				end
				Grid2Frame:UpdateIndicators()
			end
			ToggleTestMode()
		end
	end

	--========================================================================================================================
	-- Indicators management options
	--========================================================================================================================

	local options = {}

	Grid2Options:MakeTitleOptions( options, L["indicators"], L["indicators management"], nil, "Interface\\ICONS\\INV_Misc_EngGizmos_26") 

	options.newIndicatorName = {
		type = "input",
		order = 100,
		width = "full",
		name = L["Create new indicator"],
		desc = L["Name of the new indicator"],
		usage = L["<CharacterOnlyString>"],
		get = function()  return newIndicatorValues.name end,
		set = function(_,v)	newIndicatorValues.name= v  end,
	}

	options.newIndicatorType = {
		type = 'select',
		order = 110,
		name = L["Type"],
		desc = L["Type of indicator to create"],
		values = Grid2Options.indicatorTypes,
		get = function() return newIndicatorValues.type end,
		set = function(_,v)
			newIndicatorValues.type= v
			if v=="icon" or v=="text" then
				newIndicatorValues.relPoint= "CENTER"
			elseif v=="bar" or v=="multibar" then
				newIndicatorValues.relPoint= "BOTTOM"
			elseif v=="icons" then
				newIndicatorValues.relPoint= "BOTTOMLEFT"
			else
				newIndicatorValues.relPoint= "TOPLEFT"
			end
		end,
	}

	options.newIndicatorLocation= {
		type = 'select',
		order = 120,
		name = L["Location"],
		desc = L["Align my align point relative to"],
		values = Grid2Options.pointValueList,
		get = function() return Grid2Options.pointMap[newIndicatorValues.relPoint] end,
		set = function(_, v) newIndicatorValues.relPoint= Grid2Options.pointMap[v] end,
	}

	options.newIndicator = {
		type = "execute",
		order = 130,
		width = "half",
		name = L["Create"],
		desc = L["Create a new indicator."],
		func = NewIndicator,
		disabled = NewIndicatorDisabled,
	}
	options.spacerMaintenance = {
		type = "header",
		order = 140,
		name = L["Maintenance"],
	}

	options.deleteIndicator = {
		type    = "select",
		name    = L['Delete Indicator'],
		desc    = L["Delete the selected indicator."],
		order   = 150,
		get     = false,
		set     = DeleteIndicator,
		confirm = true,
		confirmText = L["Are you sure you want to delete the selected indicator?"],
		values  = GetCreatableIndicatorsValues,
	}

	options.renameIndicator = {
		type   = "select",
		name   = L['Rename Indicator'],
		desc   = L["Select a indicator to rename."],
		order  = 160,
		get    = false,
		set    = RenameIndicator,
		values = GetCreatableIndicatorsValues,
	}

	options.testMode = {
		type = "execute",
		order = 170,
		name = L["Test"],
		width = "half",
		desc = L["Toggle test mode for indicators"],
		func = function() ToggleTestMode() end,
	}
	
	function Grid2Options:MakeIndicatorsManagementOptions()
		self:CopyOptionsTable(options, self.indicatorsOptions )
	end
end

--=============================================================================================================
-- Public methods
--=============================================================================================================

-- Register indicator options
function Grid2Options:RegisterIndicatorOptions(type, isCreatable, funcMakeOptions, optionParams)
	self.typeMakeOptions[type] = funcMakeOptions
	self.optionParams[type] = optionParams
	if isCreatable then
		self.indicatorTypes[type] = L[type]
	end
end

-- Insert options of a indicator in AceConfigTable
function Grid2Options:AddIndicatorOptions(indicator, statusOptions, layoutOptions, colorOptions)
	local options = self.indicatorsOptions[indicator.name].args; wipe(options)
	if statusOptions then options["statuses"] = { type = "group", order = 10, name = L["statuses"], args = statusOptions } end
	if colorOptions  then options["colors"]   = { type = "group", order = 20, name = L["Colors"],	args = colorOptions  } end
	if layoutOptions then options["layout"]   = { type = "group", order = 30, name = L["Layout"],	args = layoutOptions } end
end

-- Don't remove options param (openmanager hooks this function and needs this parameter)
function Grid2Options:MakeIndicatorChildOptions(indicator, options)
	local funcMakeOptions = self.typeMakeOptions[ indicator.dbx.type ]
	if funcMakeOptions then
		funcMakeOptions(self, indicator)
	end
end

-- Insert indicator group option in AceConfigTable
function Grid2Options:MakeIndicatorOptions(indicator)
	local type, options = indicator.dbx.type, {}
	self.indicatorsOptions[indicator.name] = {
		type = "group",
		childGroups = "tab",
		icon  = self.indicatorIconPath .. (self.indicatorTypesOrder[type] and type or "default"),
		order = self.indicatorTypesOrder[type] or nil,
		name  = self.LI[indicator.name] or L[indicator.name],
		desc  = L["Options for %s."]:format(indicator.name),
		args  = options,
	}
	self:MakeIndicatorChildOptions(indicator, options)
end

-- Remove indicator options from AceConfigTable
function Grid2Options:DeleteIndicatorOptions(indicator)
	self.indicatorsOptions[indicator.name] = nil
end

--Refresh indicator options
function Grid2Options:RefreshIndicatorOptions(indicator)
	local options = self.indicatorsOptions[indicator.name] 
	if not options and indicator.parentName then
		options   = self.indicatorsOptions[indicator.parentName]
		indicator = Grid2.indicators[indicator.parentName]
	end
	if indicator and options and not options.args._openmanager_ then
		self:MakeIndicatorOptions( indicator )
	end	
end

-- Create all indicators options (dont remove options param, is used by openmanager)
function Grid2Options:MakeIndicatorsOptions(options)
	-- remove old options
	options = options or self.indicatorsOptions
	wipe(options)
	-- make indicators options
	self:MakeIndicatorsManagementOptions()
    local indicators = Grid2.db.profile.indicators
	for baseKey,dbx in pairs(indicators) do
		if self.typeMakeOptions[dbx.type] then -- filter bar-color&text-color indicators
			local indicator = Grid2.indicators[baseKey]
			if indicator then
				self:MakeIndicatorOptions(indicator)
			end
		end
	end
end
