local L = Grid2Options.L

--===========================================================================================

local options = Grid2Options.themesOptions

local themeModules = { layout = Grid2Layout, frame  = Grid2Frame }

local editedTheme = { db = Grid2.db.profile.themes, layout = Grid2Layout.db.profile, frame = Grid2Frame.db.profile, index = Grid2.currentTheme }

-- Themes Management
do
	local ignoreKeys = { blinkType = true, blinkFrequency = true, minimapIcon = true, extraThemes = true }

	local function CopyTheme(src, dst)
		dst = dst or {}
		for k,v in pairs(src) do
			if not ignoreKeys[k] then
				dst[k] = type(v) == 'table' and CopyTheme(v) or v 
			end
		end
		return dst
	end

	local function ResetTheme(src, dst)
		for k,v in pairs(dst) do
			if not ignoreKeys[k] then
				dst[k] = nil
			end	
		end
		CopyTheme(src, dst)
	end

	local function RenumberThemes(index, db)
		db = db or editedTheme.db.enabled
		for k,v in pairs(db) do
			if index==v then
				index = 0
			elseif v>index then
				db[k] = v-1
			end
		end
	end

	local workTable = {}
	local function GetThemes(except)
		wipe(workTable)
		except = type(except)=="number" and except or nil
		for i,name in ipairs(editedTheme.db.names) do
			if i~=except then
				workTable[i] = name
			end	
		end
		if not except then
			workTable[0] = editedTheme.db.names[0] or L["Default"]
		end	
		return workTable
	end

	local function SetDefaultTheme(info, value)
		editedTheme.db.enabled.default = value
		Grid2:ReloadTheme()
	end

	local function GetCondThemes(info)
		local t = GetThemes(info)
		t[999] = string.format( "|cFFff0000%s|r",  L['Delete this condition'] )
		return t
	end

	local function GetCondTheme(info)
		return editedTheme.db.enabled[info.arg]
	end

	local function SetCondTheme(info, value)
		if value ~= 999 then
			editedTheme.db.enabled[info.arg] = value
		else
			editedTheme.db.enabled[info.arg] = nil
			options['k'..info.arg] = nil
		end
		Grid2:ReloadTheme()	
	end

	local function ConfirmCondDelete(info,value)
		return value==999 and L["Are you sure do you want to delete this condition ?"] or false
	end

	--=============================================================================

	local CONDITIONS_VALUES = {}
	local CONDITIONS_NAMES  = {}

	do
		local CONDITIONS = { 'solo', 'party', 'arena', 'raid', 'raid@pvp' ,'raid@lfr', 'raid@flex', 'raid@mythic', '10', '20', '25', '30', '40' } 
		local CONDITIONS_DESC = { L['Solo'], L['Party'], L['Arena'], L['Raid'], L['Raid (PvP)'], L['Raid (LFR)'], L['Raid (N&H)'], L['Raid (Mythic)'], L['10 man'], L['20 man'], L['25 man'], L['30 man'], L['40 man'] }
		for o,k in ipairs(CONDITIONS) do
			local key = string.format( "%03X;%s", o, k )
			CONDITIONS_VALUES[key] = CONDITIONS_DESC[o]
			CONDITIONS_NAMES[key]  = CONDITIONS_DESC[o]
		end
		local count = GetNumSpecializations()
		for i=1,count do
			local key = string.format("%d00;%d",i,i)
			local _, name, _, icon = GetSpecializationInfo(i)
			if strlen(name)<12 then
				name = string.format("|T%s:0|t%s(%s)",icon, name, L['Spec'] )
			else
				name = string.format("|T%s:0|t%s",icon, name )
			end
			CONDITIONS_VALUES[ key ] = name
			CONDITIONS_NAMES[ key ]  = name
			for o,k in ipairs(CONDITIONS) do
				local key = string.format( "%d%02X;%d@%s", i,o,i,k )
				CONDITIONS_VALUES[ key ] = string.format( '|T%s:0|t%s', icon, CONDITIONS_DESC[o] )
				CONDITIONS_NAMES[ key ]  = string.format( '%s & %s', name, CONDITIONS_DESC[o] )
			end
		end
	end

	-- key<10 => specID(integer); key>=10 => maxPlayers(string); key=not number => another key(string)
	local function GetDbKey(key)
		local dbkey = tonumber(key)
		if not dbkey or dbkey>=10 then
			return tostring(key)
		else
			return dbkey
		end
	end
	
	local function RefreshConditionsOptions()
		for k in pairs(CONDITIONS_VALUES) do
			local order, key = strsplit(";",k)
			local dbkey = GetDbKey(key)
			local opkey = 'k' .. key
			local new = not not editedTheme.db.enabled[ dbkey ]
			local old = not not options[opkey]
			if new~=old then
				options[opkey] = new and {
					type   = "select",
					name   = CONDITIONS_NAMES[k],
					width = "double",
					desc   = L["Select one of your currently available themes."],
					order  = 100+tonumber(order,16),
					get    = GetCondTheme,
					set    = SetCondTheme,
					values = GetCondThemes,
					confirm = ConfirmCondDelete,
					arg    = dbkey,
				} or nil
			end	
		end
	end

	--=============================================================================

	local _options = {}
	
	Grid2Options:MakeTitleOptions( _options, L["Themes"], L["themes management"], nil, "Interface\\ICONS\\INV_Misc_NotePicture2c" )

	_options.themeRefresh = { type = "header", order=0, name="", hidden = function() editedTheme.db = Grid2.db.profile.themes; return true end } -- Refresh profile if profile changes

	_options.themeDesc = {
		order = 9,
		type = "description",
		name = L["You can change the active theme, you can also assign different themes for each specialization, group type, raid type or instance size."] .. "\n"
	}	
		
	_options.themeDef = {
		type   = "select",
		name   = L["Default Theme"],
		desc   = L["Select one of your currently available themes."],
		order  = 10,
		get    = function() return editedTheme.db.enabled.default or 0 end,
		set    = SetDefaultTheme,
		values = GetThemes,
		arg    = 'default',
	}

	_options.themeCond = {
		type   = "select",
		name   = L["Enable Theme for:"],
		desc   = L["Select the condition that must be met to display a new theme."],
		order  = 10.05,
		get    = false,
		set    = function(info,value) 
			local _, key = strsplit(";",value)
			editedTheme.db.enabled[ GetDbKey(key) ] = Grid2.currentTheme
			RefreshConditionsOptions()
		end,
		values = CONDITIONS_VALUES,
	}

	_options.separator1 = { type = "header", order = 10.5, name = L["Additional Themes"], hidden = function() local t = editedTheme.db.enabled; return not next(t,next(t)); end }

	--=============================================================================

	_options.separator3 = { type = "header", order = 949, name = L["Maintenance"] }

	_options.themeNew = {
		type  = "select",
		order = 950,
		name  = L["Create New Theme"],
		desc  = L["Select an existing theme to be used as template to create the new theme."],
		get   = false,
		set   = function(_, itemp)
			Grid2Options:ShowEditDialog( "Type the name of the new Theme:", '', function(name)
				local index = #editedTheme.db.names+1
				editedTheme.db.names[index] = name
				editedTheme.db.indicators[index] = {}
				for key,module in pairs(themeModules) do
					local db  = module.dba.profile
					db.extraThemes = db.extraThemes or {}
					db.extraThemes[index] = CopyTheme( itemp==0 and db or db.extraThemes[itemp] )
				end
				Grid2Options:MakeThemeOptions(index)
				LibStub("AceConfigRegistry-3.0"):NotifyChange("Grid2")
			end)
		end,
		values = GetThemes,
	}

	_options.themeRen = {
		type   = "select",
		name   = L['Rename Theme'],
		desc   = L["Select a Theme to Rename"],
		order  = 951,
		get    = false,
		set    = function(_, index)
			local name = editedTheme.db.names[index] or L['Default']
			Grid2Options:ShowEditDialog( "Rename Theme:", name, function(text) 
				editedTheme.db.names[index] = text
				LibStub("AceConfigRegistry-3.0"):NotifyChange("Grid2")
			end)
		end,
		values = GetThemes,
	}

	_options.themeRes = {
		type   = "select",
		name   = L['Reset Theme'],
		desc   = L["Reset the selected theme back to the default values."],
		order  = 952,
		get    = false,
		set    = function(_, index)
			for key,module in pairs(themeModules) do
				local db = module.dba.profile
				ResetTheme( module.defaultDB.profile, index==0 and db or db.extraThemes[index] )
			end
			if Grid2:GetCurrentTheme() == index then
				Grid2:ReloadTheme(true)
			end
				
		end,
		values = GetThemes,
		confirm = true,
		confirmText = L["Are you sure you want to reset the selected theme?"],
	}

	_options.themeDel = {
		type   = "select",
		name   = L['Delete Theme'],
		desc   = L["Delete the selected theme from the database."],
		order  = 953,
		get    = false,
		set    = function(_, index)
			table.remove(editedTheme.db.names,index)
			table.remove(editedTheme.db.indicators,index)
			for key,module in pairs(themeModules) do
				local db = module.dba.profile.extraThemes
				if db and db[index] then
					table.remove(db,index)
				end
			end
			RenumberThemes(index)
			options[tostring(#editedTheme.db.names+1)] = nil
			Grid2:ReloadTheme()
		end,
		values = function() return GetThemes(Grid2.currentTheme) end,
		confirm = true,
		confirmText = L["Are you sure you want to delete the selected theme?"],
		disabled = function() return not next(GetThemes(Grid2.currentTheme)) end,
	}

	function Grid2Options:MakeThemesManagementOptions()
		self:CopyOptionsTable( _options, options )
		RefreshConditionsOptions()
	end	
	
end
	
--===========================================================================================

local themeOptions = {
	header_hook = { type = "header", order=0, name="", hidden = function(info)
		local index = tonumber(info[#info-1]) or 0
		editedTheme.index = index
		for key,module in pairs(themeModules) do
			local db = module.dba.profile
			editedTheme[key] = db.extraThemes and db.extraThemes[index] or db
		end
		local indicators = editedTheme.db.indicators[index] 
		if not indicators then
			indicators = {}; editedTheme.db.indicators[index] = indicators	
		end
		editedTheme.indicators = indicators
		return true
	end },
}

local function GetThemeName(info)
	local index = info.arg or 0
	local name = editedTheme.db.names[index] or (index==0 and L["Default"])
	if index == Grid2.currentTheme then
		return string.format( "%s|T%s:0|t", name, READY_CHECK_READY_TEXTURE ) 
	else
		return name
	end	
end

function Grid2Options:MakeThemeOptions( index )
	options[tostring(index)] = { type = "group", childGroups = "tab", order = index+300, name = GetThemeName, desc = "", arg = index, args = themeOptions }
end

Grid2:RegisterMessage("Grid_ThemeChanged", function() LibStub("AceConfigRegistry-3.0"):NotifyChange("Grid2") end)

--===========================================================================================

local order = 0
function Grid2Options:AddThemeOptions( key, name, options )
	order = order + 1
	themeOptions[key] = { type = "group", childGroups = "tab", order = order, name = L[name], desc = L[name], args = options }
end

function Grid2Options:MakeThemesOptions(options)
	-- reload themes db
	editedTheme.db = Grid2.db.profile.themes
	-- remove old options
	options = options or self.themesOptions
	wipe(options)
	-- make new options
	self:MakeThemesManagementOptions()
	for index=0,#editedTheme.db.names do
		self:MakeThemeOptions(index)
	end
end

Grid2Options.editedTheme = editedTheme

--===========================================================================================
