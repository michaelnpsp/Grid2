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
Grid2Options.indicatorTypesOrder= { tooltip = 1, alpha = 2, background = 3, border = 4, glowborder = 5, multibar = 6, bar = 7, text = 8, square = 9, shape = 10, icon = 11, privateaura = 12, icons = 13, privateauras = 14, portrait = 15 }

Grid2Options.indicatorTitleIconsOptions = {
	size = 24, offsetx = -4, offsety = -3, anchor = 'TOPRIGHT', spacing = 5,
	{ image = "Interface\\AddOns\\Grid2Options\\media\\delete", tooltip = L["Delete Indicator"],    func = function(info) Grid2Options:DeleteIndicatorConfirm( info.option.arg.indicator )  end },
	{ image = "Interface\\AddOns\\Grid2Options\\media\\rename", tooltip = L["Rename Indicator"],    func = function(info) Grid2Options:RenameIndicatorConfirm( info.option.arg.indicator )  end },
	{ image = "Interface\\AddOns\\Grid2Options\\media\\test",   tooltip = L["Highlight Indicator"], func = function(info) Grid2Options:ToggleIndicatorTestMode( info.option.arg.indicator ) end },
}

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
		["currentBackdrop"] = true,
		["backdropInfo"] = true,
		["Center"] = true,
		["TopEdge"] = true,
		["BottomEdge"] = true,
		["LeftEdge"] = true,
		["RightEdge"] = true,
		["TopLeftCorner"] = true,
		["TopRightCorner"] = true,
		["BottomLeftCorner"] = true,
		["BottomRightCorner"] = true,
		["bar"] = true,
	}
	Grid2Options.indicatorBlacklistNames = indicator_name_blacklist

	-- Default values for new or morphed indicators
	Grid2Options.indicatorDefaultValues = {
		icon   = { size = 16, fontSize = 8 },
		square = { size = 5 },
		shape  = { size = 5 },
		text   = { duration = true, stack= false, textlength = 12, fontSize = 11, font = "Friz Quadrata TT" },
	}

	-- Deletes the specific indicator
	local function DeleteIndicatorReal(indicator)
		local name = indicator.name
		Grid2Options.LI[name] = nil
		Grid2:DbSetIndicator(name,nil)
		if indicator.dbx.sideKick then
			Grid2:DbSetIndicator(indicator.dbx.sideKick.name, nil)
		end
		for _,t in pairs(Grid2.db.profile.themes.indicators) do
			t[name] = nil
		end
		Grid2:UnregisterIndicator(indicator)
		Grid2Frame:UpdateIndicators()
		Grid2Options:DeleteIndicatorOptions(indicator)
		Grid2Options:SelectGroup('indicators')
	end

	-- Published because is used outside indicators management panel too
	function Grid2Options:DeleteIndicatorConfirm(indicator)
		if self:IndicatorIsInUse(indicator) then
			self:MessageDialog( L["This indicator cannot be deleted because is in use. Uncheck the statuses linked to the indicator first."] )
		else
			self:ConfirmDialog( L["Are you sure you want to delete this indicator ?"], function() DeleteIndicatorReal(indicator) end )
		end
	end

	local function DeleteIndicator(info, name)
		Grid2Options:DeleteIndicatorConfirm( Grid2.indicators[name] )
	end

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
			elseif (newIndicatorValues.type == "shape") then
				dbx.level = 6
				dbx.size = defaults.shape.size
			elseif (newIndicatorValues.type == "privateaura") then
				dbx.level = 8
				dbx.load = { unitType = { self = true, player = true } }
			elseif (newIndicatorValues.type == "privateauras") then
				dbx.level = 8
				dbx.maxIcons = 2
				dbx.load = { unitType = { self = true, player = true } }
			end
			Grid2:DbSetIndicator(newIndicatorName,dbx)
			-- Create runtime indicator
			local setupFunc = Grid2.setupFunc[dbx.type]
			local indicator = setupFunc(newIndicatorName, dbx)
			Grid2Options:CreateIndicatorFrames(indicator)
			Grid2Frame:UpdateIndicators()
			-- Create indicator options
			newIndicatorValues.name = ""
			Grid2Options:MakeIndicatorOptions(indicator)
		end
	end

	local function NewIndicatorDisabled(name_table)
		local name = Grid2Options:GetValidatedName( type(name_table)=='string' and name_table or newIndicatorValues.name )
		if name and name ~= "" and not Grid2.indicators[name] then
			local _,frame = next(Grid2Frame.registeredFrames)
			if frame then -- Check if the name is in use by any unit frame child object
				for key,value in pairs(frame) do
					if name==key and type(value)~="table" then
						return true
					end
				end
			end
			return indicator_name_blacklist[name] == true
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

	local function RenameIndicatorReal(old_name, new_name)
		local db = Grid2.db.profile
		new_name = Grid2Options:GetValidatedName(new_name)
		if not new_name then return end
		-- destroy old indicator
		local old_indicator = Grid2.indicators[old_name]
		local old_sideKick  = old_indicator.sideKick
		Grid2:UnregisterIndicator(old_indicator)
		-- rename database stuff
		db.indicators[new_name] = db.indicators[old_name]
		db.indicators[old_name] = nil
		db.statusMap[new_name]  = db.statusMap[old_name]
		db.statusMap[old_name]  = nil
		-- rename possible disabled indicator from themes
		for _,t in pairs(Grid2.db.profile.themes.indicators) do
			if t[old_name] then
				t[new_name] = t[old_name]
				t[old_name] = nil
			end
		end
		-- create new indicator
		local setupFunc = Grid2.setupFunc[old_indicator.dbx.type]
		local new_indicator = setupFunc(new_name, old_indicator.dbx)
		-- rename sidekick database stuff
		if old_sideKick then
			db.statusMap[new_indicator.sideKick.name] = db.statusMap[old_sideKick.name]
			db.statusMap[old_sideKick.name]  = nil
		end
		-- register statuses from database
		Grid2Options:RegisterIndicatorStatuses(new_indicator)
		Grid2Options:RegisterIndicatorStatuses(new_indicator.sideKick)
		-- recreate indicators in frame units
		Grid2Options:CreateIndicatorFrames(new_indicator)
		Grid2Frame:UpdateIndicators()
		-- refresh options
		Grid2Options:DeleteIndicatorOptions(old_indicator)
		Grid2Options:MakeIndicatorOptions(new_indicator)
		Grid2Options:SelectGroup('indicators')
	end

	local function RenameIndicator(info, name)
		if Grid2Options:IndicatorIsInUse(name) then
			Grid2Options:MessageDialog( L["This indicator cannot be renamed because is anchored to another indicator."] )
		else
			Grid2Options:ShowEditDialog( "Rename Indicator:", Grid2Options.LI[name] or L[name], function(text)
				local len = strlen(text)
				if len>2 or len==0 then
					Grid2Options.LI[name] = nil -- remove status name from old faked rename table
					if not NewIndicatorDisabled(text) then
						RenameIndicatorReal(name, text)
					end
				end
			end)
		end
	end

	function Grid2Options:RenameIndicatorConfirm(indicator)
		RenameIndicator(nil, indicator.name)
	end

	-- function ToggleTestMode()
	do
		local LCG = LibStub("LibCustomGlow-1.0")
		local Test -- Test indicator
		local TestIcons = {}
		local TestAuras = {	tex = {}, cnt = {}, exp = {}, dur = {}, col = {}, idx = {} }
		local Exclude = { bar = true, multibar = true, alpha = true }
		local ExcludeHigh = { glowborder = true, text = true }
		local COLOR ={1,1,0,1}
		local InitTestMode, testIndicator, highIndicator
		local function HighlightStop()
			if highIndicator then
				for parent in next, Grid2Frame.activatedFrames do
					local frame = highIndicator:GetFrame(parent)
					if frame then
						LCG.ButtonGlow_Stop(frame)
						LCG.PixelGlow_Stop( frame, 'Grid2IndicatorHighlight' )
					end
				end
				highIndicator = nil
			end
		end
		local function HighlightIndicator(indicator)
			if indicator and not indicator.suspended then
				if ExcludeHigh[indicator.dbx.type] then testIndicator = indicator; return true end
				local active
				for parent in next, Grid2Frame.activatedFrames do
					local frame = indicator:GetFrame(parent)
					if frame then
						if indicator.dbx.type == 'icon' then
							LCG.ButtonGlow_Start(frame, COLOR, 0.12)
						else
							LCG.PixelGlow_Start(frame, COLOR, 8, .3, nil, 1, 0,0, false, 'Grid2IndicatorHighlight')
						end
					end
					active = active or frame
				end
				if active then
					testIndicator, highIndicator = indicator, indicator
					C_Timer.After(.7, HighlightStop)
					return true
				end
			end
		end
		local function RegisterIndicator(indicator)
			if not Exclude[indicator.dbx.type] then
				indicator:RegisterStatus(Test, 10000)
			end
		end
		local function RegisterIndicators()
			for _, indicator in Grid2:IterateIndicators() do
				RegisterIndicator(indicator)
			end
		end
		local function UnregisterIndicators()
			for indicator in pairs(Test.indicators) do
				indicator:UnregisterStatus(Test)
			end
			testIndicator = nil
		end
		function InitTestMode()
			local time, color = GetTime(), { r=1,g=1,b=1,a=0.6 }
			for _, category in pairs(Grid2Options.categories) do
				if category.icon then TestIcons[#TestIcons+1] = category.icon end
			end
			for i=1,#TestIcons do
				TestAuras.tex[i] = TestIcons[i]
				TestAuras.cnt[i] = math.random(1,3)
				TestAuras.exp[i] = time+math.random(10,60)
				TestAuras.dur[i] = math.random(30) + 3
				TestAuras.col[i] = color
			end
			-- create test status
			Test = Grid2.statusPrototype:new("/@@@test@@@/",false)
			function Test:IsActive()    return true end
			function Test:GetText()     return "99999" end
			function Test:GetColor()    return math.random(0,1),math.random(0,1),math.random(0,1),1 end
			function Test:GetPercent()	return math.random() end
			function Test:GetDuration() return 60 end
			function Test:GetExpirationTime() return GetTime() + 60 end
			function Test:GetIcon()	    return TestIcons[ math.random(#TestIcons) ]	end
			function Test:GetIcons(_,m) return math.min(m,#TestIcons), TestAuras.tex, TestAuras.cnt, TestAuras.exp, TestAuras.dur, TestAuras.col, TestAuras.idx end
			function Test:GetBorder()	return 0 end
			function Test:GetTooltip()  return end
			Test.dbx = TestIcons -- Asigned to TestIcons to avoid creating a new table
			Grid2:RegisterStatus( Test, {"text","color", "percent", "icon"}, "test" )
			InitTestMode = Grid2.Dummy
		end
		-- public test function
		function Grid2Options:ToggleTestMode()
			InitTestMode()
			if Test.enabled then
				UnregisterIndicators()
			else
				RegisterIndicators()
			end
			Grid2Frame:UpdateIndicators()
		end
		function Grid2Options:ToggleIndicatorTestMode(indicator)
			local enable = indicator~=testIndicator
			InitTestMode()
			HighlightStop()
			UnregisterIndicators()
			if enable then
				RegisterIndicator(indicator)
				if not HighlightIndicator(indicator) then
					Grid2Options:MessageDialog(L["This indicator cannot be highlighted because is disabled for the current theme or layout."])
				end
			end
			Grid2Frame:UpdateIndicators()
		end
	end

	--========================================================================================================================
	-- Indicators management options
	--========================================================================================================================

	local options = {}

	Grid2Options:MakeTitleOptions( options, L["indicators"], L["indicators management"], nil, Grid2.isClassic and "Interface\\ICONS\\INV_Misc_Rune_07" or "Interface\\ICONS\\INV_Misc_EngGizmos_26")

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
		func = function() Grid2Options:ToggleTestMode() end,
	}

	function Grid2Options:MakeIndicatorsManagementOptions()
		self:CopyOptionsTable(options, self.indicatorsOptions )
	end
end

--=============================================================================================================
-- Public methods
--=============================================================================================================

-- Creates a title
function Grid2Options:MakeIndicatorTitleOptions(options, indicator)
	local isDeletable = self.indicatorTypes[indicator.dbx.type]
	self:MakeTitleOptions( options,
		self.LI[indicator.name] or L[indicator.name],
		string.format( "%s: %s", L['indicator'], L[indicator.dbx.type] ),
		nil,
		self:GetIndicatorTypeIcon(indicator.dbx.type),
		nil,
		isDeletable and { indicator = indicator, icons = Grid2Options.indicatorTitleIconsOptions }
		)
end

--Check if the indicator is in use (and can not be safetly deleted).
function Grid2Options:IndicatorIsInUse(indicator)
	indicator = type(indicator)~='string' and indicator or Grid2.indicators[indicator]
	return indicator==nil or indicator.parentName or indicator.childName
end

-- Calculate icon type path
function Grid2Options:GetIndicatorTypeIcon(type)
	return self.indicatorIconPath .. (self.indicatorTypesOrder[type] and type or "default")
end

-- Register indicator options
function Grid2Options:RegisterIndicatorOptions(type, isCreatable, funcMakeOptions, optionParams)
	self.typeMakeOptions[type] = funcMakeOptions
	self.optionParams[type] = optionParams
	if isCreatable then
		self.indicatorTypes[type] = L[type]
	end
end

-- Insert options of a indicator in AceConfigTable
function Grid2Options:AddIndicatorOptions(indicator, statusOptions, layoutOptions, colorOptions, loadOptions)
	local options = self.indicatorsOptions[indicator.name].args; wipe(options)
	self:MakeIndicatorTitleOptions(options, indicator)
	if statusOptions then options.statuses = { type = "group", order = 10, name = L["statuses"], args = statusOptions } end
	if colorOptions  then options.colors   = { type = "group", order = 20, name = L["Colors"],	 args = colorOptions  } end
	if layoutOptions then options.layout   = { type = "group", order = 40, name = L["Layout"],	 args = layoutOptions } end
	if loadOptions   then options.load     = { type = "group", order = 30, name = L["Load"],     args = loadOptions   } end
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
		icon  = self:GetIndicatorTypeIcon(type),
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
