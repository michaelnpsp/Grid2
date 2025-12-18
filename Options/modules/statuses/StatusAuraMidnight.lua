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

local function filter_toggle(filter, value, default)
	default = default or ''
	local t = { strsplit('|', filter or default) }
	if tcontains(t,value) then
		tdelete(t,value)
	else
		tinsert(t,value)
	end
	filter = tconcat(t, '|')
	return filter~=default and filter or nil
end

local function filter_exists(filter, value)
	return strfind(filter or '', value)~=nil
end

local function refresh_aura_status(status)
	if status.Refresh then
		status:Refresh()
	end
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
			return (status.dbx.aura_filter or 'HELPFUL') == 'HELPFUL'
		end,
		set = function()
			status.dbx.aura_filter = not status.dbx.aura_filter and 'HELPFUL|PLAYER|RAID' or nil
			refresh_aura_status(status)
		end,
	}
	options.filter_player = {
		type = "toggle",
		order = 30,
		width = "full",
		name = L["Only buffs applied by me"],
		get = function(info)
			return filter_exists( status.dbx.aura_filter, 'PLAYER' )
		end,
		set = function()
			status.dbx.aura_filter = filter_toggle( status.dbx.aura_filter, 'PLAYER', 'HELPFUL' )
			refresh_aura_status(status)
		end,
	}
	options.filter_raid = {
		type = "toggle",
		order = 40,
		width = "full",
		name = L["Only buffs that are relevant for your player class"],
		get = function()
			return filter_exists( status.dbx.aura_filter, 'RAID' )
		end,
		set = function()
			status.dbx.aura_filter = filter_toggle( status.dbx.aura_filter, 'RAID', 'HELPFUL' )
			refresh_aura_status(status)
		end,
	}
	options.sort_rule = {
		type = "select",
		order = 50,
		name = "Sorting",
		desc = L["Choose how to sort the auras."],
		get = function()
			return status.dbx.aura_sortRule or 0
		end,
		set = function(_, v)
			status.dbx.aura_sortRule = (v~=0) and v or nil
			refresh_aura_status(status)
		end,
		values = SORT_VALUES,
	}
	options.sort_dir = {
		type = "toggle",
		order = 60,
		width = "full",
		name = L["Reverse Sorting"],
		get = function()
			return status.dbx.aura_sortDir == 1
		end,
		set = function(_, v)
			status.dbx.aura_sortDir = v and 1 or nil
			refresh_aura_status(status)
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
			return (status.dbx.aura_filter or 'HARMFUL') == 'HARMFUL'
		end,
		set = function()
			status.dbx.aura_filter = not status.dbx.aura_filter and 'HARMFUL|PLAYER|RAID' or nil
			refresh_aura_status(status)
		end,
	}
	options.filter_player = {
		type = "toggle",
		order = 30,
		width = "full",
		name = L["Only debuffs applied by me"],
		get = function(info)
			return filter_exists( status.dbx.aura_filter, 'PLAYER' )
		end,
		set = function()
			status.dbx.aura_filter = filter_toggle( status.dbx.aura_filter, 'PLAYER', 'HARMFUL' )
			refresh_aura_status(status)
		end,
	}
	options.filter_raid = {
		type = "toggle",
		order = 40,
		width = "full",
		name = L["Only debuffs that are relevant in combat or raid"],
		get = function()
			return filter_exists( status.dbx.aura_filter, 'RAID' )
		end,
		set = function()
			status.dbx.aura_filter = filter_toggle( status.dbx.aura_filter, 'RAID', 'HARMFUL' )
			refresh_aura_status(status)
		end,
	}
	options.sort_rule = {
		type = "select",
		order = 50,
		name = "Sorting",
		desc = L["Choose how to sort the auras."],
		get = function()
			return status.dbx.aura_sortRule or 0
		end,
		set = function(_, v)
			status.dbx.aura_sortRule = (v~=0) and v or nil
			refresh_aura_status(status)
		end,
		values = SORT_VALUES,
	}
	options.sort_dir = {
		type = "toggle",
		order = 60,
		width = "full",
		name = L["Reverse Sorting"],
		get = function()
			return status.dbx.aura_sortDir == 1
		end,
		set = function(_, v)
			status.dbx.aura_sortDir = v and 1 or nil
			refresh_aura_status(status)
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
