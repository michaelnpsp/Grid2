local L = Grid2Options.L

--===========================================================================================

local options = Grid2Options.themesOptions

local themeModules = { layout = Grid2Layout, frame  = Grid2Frame }

local editedTheme = { db = Grid2.db.profile.themes, layout = Grid2Layout.db.profile, frame = Grid2Frame.db.profile, index = Grid2.currentTheme }

local themeCondCount = 0

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
			themeCondCount = themeCondCount - 1
		end
		Grid2:ReloadTheme()
	end

	local function ConfirmCondDelete(info,value)
		return value==999 and L["Are you sure do you want to delete this condition ?"] or false
	end

	local function ThemeCheckConditions(theme, fix)
		for k,index in pairs(editedTheme.db.enabled) do
			if index == theme then
				if fix then
					editedTheme.db.enabled[k] = 0
				else
					return true
				end
			end
		end
	end

	--=============================================================================

	local CONDITIONS_VALUES = {}
	local CONDITIONS_NAMES  = {}

	do
		-- groups & raids
		local CONDITIONS = {
			'solo', 'party', 'arena', 'raid', 'raid@pvp' ,'raid@lfr', 'raid@flex', 'raid@mythic',
			'10', '15', '20', '25', '30', '40',
			'TANK', 'HEALER', 'DAMAGER', 'NONE',
		}
		local CONDITIONS_DESC = {
			L['Solo'], L['Party'], L['Arena'], L['Raid'], L['Raid (PvP)'], L['Raid (LFR)'], L['Raid (N&H)'], L['Raid (Mythic)'],
			L['10 man'], L['15 man'], L['20 man'], L['25 man'], L['30 man'], L['40 man'],
			L['Tank (Role)'], L['Healer (Role)'], L['Damager (Role)'],	L['None (Role)'],
		}
		--
		for o,k in ipairs(CONDITIONS) do
			local key = string.format( "%03d;%s", o, k )
			CONDITIONS_VALUES[key] = CONDITIONS_DESC[o] -- Descriptions used in "Enable Theme for" dropdown list values
			CONDITIONS_NAMES[key]  = CONDITIONS_DESC[o] -- Description used as title in themes dropdown lists
		end
		-- current class
		local classLoc, class = UnitClass("player")
		local classKey = string.format("100;%s@0", class)
		local classDesc= string.format("%s (%s)", classLoc, L["Class"])
		CONDITIONS_VALUES[classKey] = classDesc
		CONDITIONS_NAMES[classKey]  = classDesc
		-- current class + specs
		if not Grid2.isClassic then
			local CONDITIONS_EXCLUDE = { TANK = true, HEALER = true, DAMAGER = true, NONE = true }
			local count = GetNumSpecializations()
			for i=1,count do
				local key = string.format("%d01;%s@%d",i, class, i)
				local _, name, _, icon = GetSpecializationInfo(i)
				if strlen(name)<12 then
					name = string.format("|T%s:0|t%s(%s)",icon, name, L['Spec'] )
				else
					name = string.format("|T%s:0|t%s",icon, name )
				end
				CONDITIONS_VALUES[key] = name
				CONDITIONS_NAMES[key] = name
				for o,k in ipairs(CONDITIONS) do
					if not CONDITIONS_EXCLUDE[k] then
						local key = string.format( "%d%02d;%s@%d@%s", i,o+1,class,i,k )
						CONDITIONS_VALUES[ key ] = string.format( '|T%s:0|t%s', icon, CONDITIONS_DESC[o] )
						CONDITIONS_NAMES[ key ]  = string.format( '%s & %s', name, CONDITIONS_DESC[o] )
					end
				end
			end
		end
	end

	local function RefreshConditionsOptions()
		themeCondCount = 0
		for k in pairs(CONDITIONS_VALUES) do
			local order, dbkey = strsplit(";",k)
			local opkey = 'k' .. dbkey
			local new = not not editedTheme.db.enabled[ dbkey ]
			local old = not not options[opkey]
			if new~=old then
				options[opkey] = new and {
					type    = "select",
					name    = CONDITIONS_NAMES[k],
					width   = "double",
					desc    = L["Select one of your currently available themes."],
					order   = 100+tonumber(order),
					get     = GetCondTheme,
					set     = SetCondTheme,
					values  = GetCondThemes,
					confirm = ConfirmCondDelete,
					arg     = dbkey,
				} or nil
			end
			if new then themeCondCount = themeCondCount + 1 end
		end
	end

	--=============================================================================

	local _options = {}

	Grid2Options:MakeTitleOptions( _options, L["Themes"], L["themes management"], nil, Grid2.isClassic and "Interface\\ICONS\\INV_Misc_Note_06" or "Interface\\ICONS\\INV_Misc_NotePicture2c" )

	_options.themeRefresh = { type = "header", order=0, name="", hidden = function() editedTheme.db = Grid2.db.profile.themes; return true end } -- Refresh profile if profile changes

	_options.themeDesc = {
		order = 9,
		type = "description",
		name = "\n" .. L["You can change the active theme, you can also assign different themes for each specialization, group type, raid type or instance size."] .. "\n"
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
			editedTheme.db.enabled[ select(2, strsplit(";",value) ) ] = Grid2.currentTheme
			RefreshConditionsOptions()
		end,
		values = CONDITIONS_VALUES,
	}

	_options.separator1 = { type = "header", order = 10.5, name = L["Additional Themes"], hidden = function() return themeCondCount<=0 end }

	--=============================================================================

	_options.separator3 = { type = "header", order = 949, name = L["Maintenance"] }

	_options.themeNew = {
		type  = "select",
		order = 950,
		name  = L["Create New Theme"],
		desc  = L["Select an existing theme to be used as template to create the new theme."],
		get   = false,
		set   = function(_, itemp)
			Grid2Options:ShowEditDialog( L["Type the name of the new Theme:"], '', function(name)
				local index = #editedTheme.db.names+1
				editedTheme.db.names[index] = name
				editedTheme.db.indicators[index] = {}
				for key,module in pairs(themeModules) do
					local db  = module.dba.profile
					db.extraThemes = db.extraThemes or {}
					db.extraThemes[index] = CopyTheme( itemp==0 and db or db.extraThemes[itemp] )
				end
				Grid2Options:MakeThemeOptions(index)
				Grid2Options:NotifyChange()
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
			Grid2Options:ShowEditDialog( L["Rename Theme:"], name, function(text)
				editedTheme.db.names[index] = text
				Grid2Options:NotifyChange()
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
			ThemeCheckConditions(index, true)
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
		confirm = function(info, value)
			return ThemeCheckConditions(value) and
			L["There are conditions referencing this theme. Are you sure you want to delete the selected theme ?"] or
			L["Are you sure you want to delete the selected theme?"]
		end,
		disabled = function() return not next(GetThemes(Grid2.currentTheme)) end,
	}

	function Grid2Options:MakeThemesManagementOptions()
		self:CopyOptionsTable( _options, options )
		RefreshConditionsOptions()
	end

end

--===========================================================================================

local function ThemesEnabled()
	return Grid2Frame.dba.profile.extraThemes ~= nil
end

local function GetThemeIndicators(index)
	local indicators = editedTheme.db.indicators[index]
	if not indicators then
		indicators = {}
		editedTheme.db.indicators[index] = indicators
	end
	return indicators
end

local function GetThemeName(info)
	local index = info.arg or 0
	local name = editedTheme.db.names[index] or (index==0 and L["Default"])
	if index == Grid2.currentTheme then
		return string.format( "%s|T%s:0|t", name, READY_CHECK_READY_TEXTURE )
	else
		return name
	end
end

local themeOptions = {
	header_hook = { type = "header", order=0, name="", hidden = function(info)
		Grid2Options:SetEditedTheme( tonumber(info[#info-1]) or 0 )
		return true
	end },
}

function Grid2Options:MakeThemeOptions( index )
	options[tostring(index)] = { type = "group", childGroups = "tab", order = index+300, name = GetThemeName, desc = "", arg = index, args = themeOptions }
end

Grid2:RegisterMessage("Grid_ThemeChanged", Grid2Options.NotifyChange)

--===========================================================================================

function Grid2Options:ThemesAreEnabled()
	return Grid2Frame.dba.profile.extraThemes ~= nil
end

function Grid2Options:ThemesAreDisabled()
	return Grid2Frame.dba.profile.extraThemes == nil
end

local order = 0
function Grid2Options:AddThemeOptions( key, name, options )
	order = order + 1
	-- add the options to Themes Section
	themeOptions[key] = { type = "group", childGroups = "tab", order = order, name = L[name], desc = L[name], args = options }
	-- add the options to General section too
	local group = self:AddGeneralOptions( name, nil, options )
	group.hidden = ThemesEnabled
end

function Grid2Options:SetEditedTheme(index)
	index = index or Grid2.currentTheme or 0
	editedTheme.db = Grid2.db.profile.themes
	editedTheme.index = index
	for key,module in pairs(themeModules) do
		local db = module.dba.profile
		editedTheme[key] = db.extraThemes and db.extraThemes[index] or db
	end
	editedTheme.indicators = GetThemeIndicators(index)
end

function Grid2Options:MakeThemesOptions(options)
	-- remove old options
	options = options or self.themesOptions
	wipe(options)
	-- make new options for themes
	if ThemesEnabled() then
		self:MakeThemesManagementOptions()
		for index=0,#editedTheme.db.names do
			self:MakeThemeOptions(index)
		end
	end
end

Grid2Options.editedTheme = editedTheme

--===========================================================================================
