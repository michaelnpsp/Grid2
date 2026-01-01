if not Grid2.secretsEnabled then return end

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
	return strfind(filter, value)~=nil
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

function Grid2Options:MakeMidnightBuffsOptions(status, options)
	options.filter_header = {
		type = "header",
		order = 10,
		name = L["Select which buffs must be displayed:"],
	}
	options.filter_all = {
		type = "toggle",
		order = 20,
		width = "full",
		name = L["Display all buffs"],
		get = function(info)
			return filter_get_value(status, 'aura_filter', 'filter', 'HELPFUL') == 'HELPFUL'
		end,
		set = function(info, v)
			filter_set_value(status, 'aura_filter', 'filter',  (not v) and 'HELPFUL|PLAYER|RAID' or nil)
		end,
	}
	options.filter_player = {
		type = "toggle",
		order = 30,
		width = "full",
		name = L["Only buffs applied by me"],
		get = function(info)
			return filter_exists_substring( status, 'aura_filter', 'filter', 'PLAYER' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'PLAYER', 'HELPFUL' )
		end,
	}
	options.filter_raid = {
		type = "toggle",
		order = 40,
		width = "full",
		name = L["Only buffs that are relevant for your player class"],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', 'RAID' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'RAID', 'HELPFUL' )
		end,
	}
	options.sort_rule = {
		type = "select",
		order = 50,
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
		order = 60,
		name = L["Reverse Sorting"],
		get = function()
			return filter_get_value( status, 'aura_filter', 'sortDir' ) == 1
		end,
		set = function(_, v)
			filter_set_value( status, 'aura_filter', 'sortDir', v and 1 or nil )
		end,
	}
end

Grid2Options:MakeMidnightBuffsOptions(NewBuffsOptions.arg, NewBuffsOptions)

Grid2Options:RegisterStatusCategoryOptions("buff", NewBuffsOptions)

Grid2Options:RegisterStatusOptions("mbuffs", "buff", function(self, status, options, optionParams)
	self:MakeMidnightBuffsOptions(status, options, optionParams)
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

function Grid2Options:MakeMidnightDebuffsOptions(status, options)
	options.filter_header = {
		type = "header",
		order = 10,
		name = L["Select which debuffs must be displayed:"],
	}
	options.filter_all = {
		type = "toggle",
		order = 20,
		width = "full",
		name = L["Display all debuffs"],
		get = function(info)
			return filter_get_value(status, 'aura_filter', 'filter', 'HARMFUL') == 'HARMFUL' and filter_get_value(status, 'aura_filter', 'typed')==nil
		end,
		set = function(info, v)
			filter_set_value(status, 'aura_filter', 'filter',  (not v) and 'HARMFUL|PLAYER|RAID' or nil)
			filter_set_value(status, 'aura_filter', 'typed', nil)
		end,
	}
	options.filter_player = {
		type = "toggle",
		order = 30,
		width = "full",
		name = L["Only debuffs applied by me"],
		get = function(info)
			return filter_exists_substring( status, 'aura_filter', 'filter', 'PLAYER' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'PLAYER', 'HARMFUL' )
		end,
	}
	options.filter_raid = {
		type = "toggle",
		order = 40,
		width = "full",
		name = L["Only debuffs that i can dispel"],
		get = function()
			return filter_exists_substring( status, 'aura_filter', 'filter', 'RAID' )
		end,
		set = function()
			filter_toggle_substring( status, 'aura_filter', 'filter', 'RAID', 'HARMFUL' )
		end,
	}
	options.debuffs_typed = {
		type = "toggle",
		order = 50,
		width = "full",
		name = L["Only typed debuffs"],
		desc = L["Display only Magic, Curse, Poison, Disease or Bleed Debuffs."],
		get = function()
			return filter_get_value(status, 'aura_filter', 'typed')==true
		end,
		set = function(info, v)
			filter_set_value( status, 'aura_filter', 'typed', v, false)
		end,
	}
	options.debuffs_typeless = {
		type = "toggle",
		order = 60,
		width = "full",
		name = L["Only typeless debuffs"],
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
	options.sort_rule = {
		type = "select",
		order = 70,
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
		order = 80,
		name = L["Reverse Sorting"],
		get = function()
			return filter_get_value( status, 'aura_filter', 'sortDir' ) == 1
		end,
		set = function(_, v)
			filter_set_value( status, 'aura_filter', 'sortDir', v and 1 or nil )
		end,
	}
end

Grid2Options:MakeMidnightDebuffsOptions(NewDebuffsOptions.arg, NewDebuffsOptions)

Grid2Options:RegisterStatusCategoryOptions("debuff", NewDebuffsOptions)

Grid2Options:RegisterStatusOptions("mdebuffs", "debuff", function(self, status, options, optionParams)
	self:MakeMidnightDebuffsOptions(status, options, optionParams)
end,{
	groupOrder = 10, isDeletable = true,
	titleIcon = "Interface\\Icons\\Spell_deathknight_strangulate",
})

--==============================================
--
--==============================================

Grid2Options:RegisterStatusOptions("mdebuffType", "debuff", function(self, status, options, optionParams)

end,{
	groupOrder = 5,
})
