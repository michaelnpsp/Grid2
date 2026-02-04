local L = Grid2Options.L

--==============================================
--
--==============================================

local tdelete = Grid2.TableRemoveByValue
local tinsert = table.insert
local tconcat = table.concat
local tcontains = tContains

local SORT_VALUES = {
	[0] = L["Unsorted"],
	[1] = L["Default"],
	[2] = L["Big Defensive"],
	[3] = L["Expiration"],
	[4] = L["Expiration Only"],
	[5] = L["Name"],
	[6] = L["Name Only"],
}

local function refresh_aura_status(status)
	if status.Refresh then
		status:Refresh()
	end
end

local function filter_get_value(status, key, subkey, default)
	local t = status.dbx[key]
	local v =  (type(t)=='table' and t or {})[subkey]
	if v==nil then
		return default
	else
		return v
	end
end

local function filter_set_value(status, key, subkey, value, default)
	local t = status.dbx[key]
	status.dbx[key] = type(t)=='table' and t or {}
	if value~=default then
		status.dbx[key][subkey] = value
	else
		status.dbx[key][subkey] = nil
	end
	if subkey=='filter' then
		status.dbx[key].blizFilter = nil
	end
	refresh_aura_status(status)
end

local function filter_toggle_substring(status, key, subkey, value, default)
	local filter = filter_get_value(status, key, subkey, default or '')
	local t = { strsplit('|', filter) }
	if tcontains(t,value) then
		tdelete(t,value)
	else
		tinsert(t,value)
	end
	filter = tconcat(t, '|')
	filter_set_value(status, key, subkey, filter, default)
end

local function filter_exists_substring(status, key, subkey, value)
	local filter = filter_get_value(status, key, subkey, default or '')
	return tcontains( { strsplit('|', filter) }, value)
end

local function get_new_aura_status_key(data)
	if data.name then
		local key = data.name:gsub("[ %.\"]", "")
		if key~="" then
			key = string.format("%s-%s", data.prefix, key)
			return Grid2.statuses[key]==nil and key or nil
		end
	end
end

local function reset_aura_status(data)
	data.name = nil
	data.dbx.aura_filter = nil -- TODO
end

local function create_aura_status(data)
	local key = get_new_aura_status_key(data)
	if key then
		local dbx = Grid2.CopyTable(data.dbx)
		Grid2.db.profile.statuses[key]= dbx
		local status = Grid2.setupFunc[dbx.type](key, dbx)
		Grid2Options:MakeStatusOptions(status)
		Grid2Options:SelectGroup('statuses', Grid2Options:GetStatusCategory(status), status.name)
		reset_aura_status(data)
	end
end

local function make_colortype_option(status, options, key, order, defColor, params)
	if order then
		options[key] = {
			type = "color",
			width = params and params.width or "full",
			order = order,
			name = L[key],
			get = function()
				status.dbx.colors = status.dbx.colors or {}
				local c = status.dbx.colors[key] or defColor
				return c.r, c.g, c.b, c.a
			end,
			set = function(info, r, g, b, a)
				local c = status.dbx.colors[key] or {}
				c.r, c.g, c.b, c.a = r, g, b, a
				status.dbx.colors[key] = c
				refresh_aura_status(status)
			end,
		}
	end
end

local function make_color_option(status, options, key, order, name, params)
	options[key] = {
		type = "color",
		hasAlpha = true,
		width = params and params.width or "full",
		order = order,
		name = L[name or "Color"],
		get = function()
			local c = status.dbx[key]
			return c.r, c.g, c.b, c.a
		end,
		set = function(info, r, g, b, a)
			local c = status.dbx[key]
			c.r, c.g, c.b, c.a = r, g, b, a
			status.dbx[key] = c
			refresh_aura_status(status)
		end,
	}
end

local function make_colortype_option(status, options, key, order, defColor, params)
	if order then
		options[key] = {
			type = "color",
			hasAlpha = true,
			width = params and params.width or "full",
			order = order,
			name = L[key],
			get = function()
				status.dbx.colors = status.dbx.colors or {}
				local c = status.dbx.colors[key] or defColor
				return c.r, c.g, c.b, c.a
			end,
			set = function(info, r, g, b, a)
				local c = status.dbx.colors[key] or {}
				c.r, c.g, c.b, c.a = r, g, b, a
				status.dbx.colors[key] = c
				refresh_aura_status(status)
			end,
		}
	end
end

local function make_colors_reset_option(status, options, newline)
	if newline then
		options.reset_header = { type = "description", width = "full", order = 499, name = "" }
	end
	options.reset_colors = {
		type = "execute",
		order = 500,
		name = L["Reset"],
		desc = L["Reset colors to the default values."],
		func = function () 	wipe(status.dbx.colors); refresh_aura_status(status) end,
		confirm = true,
	}
end

--==============================================
--
--==============================================

local NewBuffsOptions
do
	local status = {
		prefix = 'buffs',
		dbx = { type = "mbuffs", color1 = {r=0, g=1, b=0, a=1} },
	}
	NewBuffsOptions = {
		name = {
			type = "input",
			order = 5,
			width = "full",
			name = L["New Buffs Group Name"],
			desc = L["Type a descriptive text for your group of buffs."],
			get = function() return status.name or '' end,
			set = function(_,v) status.name = v end,
		},
		create = {
			type = "execute",
			order = 500,
			name = L["Create"],
			desc = L["Create a new status."],
			func = function()
				create_aura_status(status)
			end,
			disabled = function()
				return not get_new_aura_status_key(status)
			end,
		},
		arg = status
	}
end

local function MakeBuffsOptions(status, options)
	options.filter_header = {
		type = "header",
		order = 10,
		name = L["Buffs to display:"],
	}
	options.filter_all = {
		type = "toggle",
		order = 20,
		width = "full",
		name = L["Display all buffs"],
		get = function(info)
			return filter_get_value(status, 'aura_filter', 'filter', 'HELPFUL')=='HELPFUL' and filter_get_value(status, 'aura_filter', 'blizFilter')==nil
		end,
		set = function(info, v)
			if v then
				filter_set_value(status, 'aura_filter', 'filter',  (not v) and 'HELPFUL|PLAYER|RAID' or nil)
			end
		end,
	}
	options.filter_player = {
		type = "toggle",
		order = 30,
		width = "full",
		name = L["Buffs applied by me"],
		get = function(info)
			return filter_exists_substring( status, 'aura_filter', 'filter', 'PLAYER' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'PLAYER', 'HELPFUL' )
		end,
	}
	options.filter_raid_combat = {
		type = "toggle",
		order = 40,
		width = "full",
		name = L["Buffs relevant for your class"],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', 'RAID_IN_COMBAT' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'RAID_IN_COMBAT', 'HELPFUL' )
		end,
		hidden = function() return Grid2.versionCli<=120000 end,
	}
	options.filter_raid = {
		type = "toggle",
		order = 43,
		width = "full",
		name = L["Buffs relevant for your class (light version)"],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', 'RAID' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'RAID', 'HELPFUL' )
		end,
	}
	options.filter_defensive = {
		type = "toggle",
		order = 45,
		width = "full",
		name = L["Big defensive buff"],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', 'BIG_DEFENSIVE' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'BIG_DEFENSIVE', 'HELPFUL' )
		end,
	}
	options.filter_external_defensives = {
		type = "toggle",
		order = 50,
		width = "full",
		name = L["External defensive buffs"],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', 'EXTERNAL_DEFENSIVE' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'EXTERNAL_DEFENSIVE', 'HELPFUL' )
		end,
	}
	options.filter_bliz_buffs = {
		type = "toggle",
		order = 60,
		width = "full",
		name = L["Buffs from Blizzard Unit Frames"],
		desc = L["Show the same buffs displayed by the Blizzard unit frames"],
		get = function()
			return filter_get_value(status, 'aura_filter', 'blizFilter')=='HELPFUL|RAID'
		end,
		set = function(_, v)
			filter_set_value(status, 'aura_filter', 'filter', nil)
			filter_set_value(status, 'aura_filter', 'blizFilter', v and 'HELPFUL|RAID' or nil)
		end,
	}
	options.filter_bliz_defensive = {
		type = "toggle",
		order = 70,
		width = "full",
		name = L["Defensive Buff from Blizzard Unit Frames"],
		desc = L["Show the same defensive buff displayed by the Blizzard unit frames"],
		get = function()
			return filter_get_value(status, 'aura_filter', 'blizFilter')=='HELPFUL|EXTERNAL_DEFENSIVE'
		end,
		set = function(_, v)
			filter_set_value(status, 'aura_filter', 'filter', nil)
			filter_set_value(status, 'aura_filter', 'blizFilter', v and 'HELPFUL|EXTERNAL_DEFENSIVE' or nil)
		end,
	}
	options.sort_rule = {
		type = "select",
		order = 100,
		name = "Sorting",
		desc = L["Choose how to sort the auras."],
		get = function()
			return filter_get_value( status, 'aura_filter', 'sortRule', 0 )
		end,
		set = function(_, v)
			filter_set_value( status, 'aura_filter', 'sortRule', v, 0 )
		end,
		values = SORT_VALUES,
	}
	options.sort_dir = {
		type = "toggle",
		order = 110,
		name = L["Reverse Sorting"],
		get = function()
			return filter_get_value( status, 'aura_filter', 'sortDir' ) == 1
		end,
		set = function(_, v)
			filter_set_value( status, 'aura_filter', 'sortDir', v and 1 or nil )
		end,
	}
end

local function MakeBuffsColorOptions( status, options, optionParams )
	options.cheader = { type = "header", order = 199, name = L["Buffs Color"] }
	make_color_option(status, options, "color1", 200)
end

-- Grid2Options:MakeMidnightBuffsOptions(NewBuffsOptions.arg, NewBuffsOptions)

Grid2Options:RegisterStatusCategoryOptions("buff", NewBuffsOptions)

Grid2Options:RegisterStatusOptions("mbuffs", "buff", function(self, status, options, optionParams)
	MakeBuffsOptions(status, options, optionParams)
	MakeBuffsColorOptions(status, options, optionParams)
end,{
	groupOrder = 10, isDeletable = true,
	titleIcon = "Interface\\Icons\\Inv_enchant_shardbrilliantsmall",
})

--==============================================
--
--==============================================

local NewDebuffsOptions
do
	local status = {
		prefix = 'debuffs',
		dbx = { type = "mdebuffs", color1 = {r=1, g=0, b=0, a=1} },
	}
	NewDebuffsOptions = {
		name = {
			type = "input",
			order = 1,
			width = "full",
			name = L["New Debuffs Group Name"],
			desc = L["Type a descriptive text for your group of debuffs."],
			get = function(info) return status.name or '' end,
			set = function(info,v) status.name = v end,

		},
		create = {
			type = "execute",
			order = 500,
			name = L["Create"],
			desc = L["Create a new status."],
			func = function()
				create_aura_status(status)
			end,
			disabled = function()
				return not get_new_aura_status_key(status)
			end,
		},
		arg = status,
	}
end

local function MakeDebuffsFilterOptions(status, options)
	options.filter_header = {
		type = "header",
		order = 10,
		name = L["Debuffs to display:"],
	}
	options.filter_all = {
		type = "toggle",
		order = 20,
		width = "full",
		name = L["Display all debuffs"],
		get = function(info)
			return filter_get_value(status, 'aura_filter', 'filter', 'HARMFUL') == 'HARMFUL' and
					filter_get_value(status, 'aura_filter', 'typed')==nil and
					filter_get_value(status, 'aura_filter', 'blizFilter')==nil
		end,
		set = function(info, v)
			if v then
				filter_set_value(status, 'aura_filter', 'filter',  (not v) and 'HARMFUL|PLAYER|RAID' or nil)
				filter_set_value(status, 'aura_filter', 'typed', nil)
			end
		end,
	}
	options.filter_player = {
		type = "toggle",
		order = 30,
		width = "full",
		name = L["Debuffs applied by me"],
		get = function(info)
			return filter_exists_substring( status, 'aura_filter', 'filter', 'PLAYER' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'PLAYER', 'HARMFUL' )
		end,
	}
	options.filter_raid_dispel = {
		type = "toggle",
		order = 40,
		width = "full",
		name = L["Debuffs that i can dispel"],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', Grid2.versionCli<=120000 and 'RAID' or 'RAID_PLAYER_DISPELLABLE' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', Grid2.versionCli<=120000 and 'RAID' or 'RAID_PLAYER_DISPELLABLE', 'HARMFUL' )
		end,
	}
	options.filter_nameplate = {
		type = "toggle",
		order = 50,
		width = "full",
		name = L["Debuffs that should be shown on nameplates"],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', 'INCLUDE_NAME_PLATE_ONLY' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'INCLUDE_NAME_PLATE_ONLY', 'HARMFUL' )
		end,
	}
	options.filter_typed = {
		type = "toggle",
		order = 60,
		width = "full",
		name = L["Typed debuffs"],
		desc = L["Display only Magic, Curse, Poison, Disease or Bleed Debuffs."],
		get = function()
			return filter_get_value(status, 'aura_filter', 'typed')==true
		end,
		set = function(info, v)
			filter_set_value( status, 'aura_filter', 'typed', v, false)
		end,
	}
	options.filter_typeless = {
		type = "toggle",
		order = 70,
		width = "full",
		name = L["Typeless debuffs"],
		desc = L["Display only debuffs with no dispell type."],
		get = function()
			return filter_get_value(status, 'aura_filter', 'typed')==false
		end,
		set = function(info, v)
			if v then
				v = false
			else
				v = nil
			end
			filter_set_value( status, 'aura_filter', 'typed', v)
		end,
	}
	options.filter_control = {
		type = "toggle",
		order = 75,
		width = "full",
		name = L["Crowd control debuffs"],
		desc = L["Display only debuffs that limit mobility or actions."],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', 'CROWD_CONTROL' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'CROWD_CONTROL', 'HARMFUL' )
		end,
		hidden = function() return Grid2.versionCli<=120000 end, -- available only on midnight beta
	}
	options.filter_bliz_debuffs = {
		type = "toggle",
		order = 80,
		width = "full",
		name = L["Debuffs from Blizzard Unit Frames"],
		desc = L["Show the same debuffs displayed by the Blizzard unit frames"],
		get = function()
			return filter_get_value(status, 'aura_filter', 'blizFilter')=='HARMFUL'
		end,
		set = function(_, v)
			filter_set_value(status, 'aura_filter', 'filter',  nil)
			filter_set_value(status, 'aura_filter', 'blizFilter', v and 'HARMFUL' or nil)
		end,
	}
	options.sort_rule = {
		type = "select",
		order = 100,
		name = "Sorting",
		desc = L["Choose how to sort the auras."],
		get = function()
			return filter_get_value( status, 'aura_filter', 'sortRule', 0 )
		end,
		set = function(_, v)
			filter_set_value( status, 'aura_filter', 'sortRule', v, 0 )
		end,
		values = SORT_VALUES,
	}
	options.sort_dir = {
		type = "toggle",
		order = 110,
		name = L["Reverse Sorting"],
		get = function()
			return filter_get_value( status, 'aura_filter', 'sortDir' ) == 1
		end,
		set = function(_, v)
			filter_set_value( status, 'aura_filter', 'sortDir', v and 1 or nil )
		end,
	}
end

local function MakeDebuffsColorsOptions( status, options, optionParams)
	options.cheader = { type = "header", order = 199, name = L["Debuff Type Colors"] }
	for typ,v in pairs(Grid2.DispelCurveDefaults) do
		local idx, color = unpack(v)
		make_colortype_option(status, options, typ, idx==0 and 299 or idx+200, color, optionParams)
	end
	make_colors_reset_option(status, options, true)
end

-- Grid2Options:MakeMidnightDebuffsOptions(NewDebuffsOptions.arg, NewDebuffsOptions)

Grid2Options:RegisterStatusCategoryOptions("debuff", NewDebuffsOptions)

Grid2Options:RegisterStatusOptions("mdebuffs", "debuff", function(self, status, options, optionParams)
	MakeDebuffsFilterOptions( status, options)
	MakeDebuffsColorsOptions( status, options, {width = 0.65} )
end,{
	groupOrder = 10, isDeletable = true,
	titleIcon = "Interface\\Icons\\Spell_deathknight_strangulate",
})

--==============================================
--
--==============================================

function Grid2Options:MakeMidnightDispellableByMeOptions(status, options)
	options.bliz_filter = {
		type = "toggle",
		order = 1,
		width = "full",
		name = L["Get Dispellable debuffs from Blizzard Unit Frames"],
		get = function() return status.dbx.blizFilter~=nil end,
		set = function(_, v)
			status.dbx.blizFilter = v and "HARMFUL|RAID_PLAYER_DISPELLABLE" or nil
			refresh_aura_status(status)
		end,
	}
	options.colors_header = {
		type = "header",
		order = 2,
		name = L["Debuff Type Colors"],
	}
	for typ,v in pairs(Grid2.DispelCurveDefaults) do
		local idx, color = unpack(v)
		make_colortype_option(status, options, typ, idx~=0 and idx+100, color)
	end
	make_colors_reset_option(status, options)
end

Grid2Options:RegisterStatusOptions("mdebuffType", "debuff", function(self, status, options, optionParams)
	self:MakeMidnightDispellableByMeOptions(status, options, optionParams)
end,{
	groupOrder = 5,
})
