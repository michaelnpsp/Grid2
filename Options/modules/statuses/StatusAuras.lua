if Grid2.versionCli<120100 then return end

local L = Grid2Options.L

local tcontains = tContains
local tinsert = table.insert
local tconcat = table.concat
local tdelete = Grid2.TableRemoveByValue
local GetSpellInfo = Grid2.API.GetSpellInfo

--==============================================
--
--==============================================

local AuraFilters ={
	["filter;PLAYER"] = 'Casted by me',
	["filter;RAID_IN_COMBAT"] = "Relevant for your Class",
	["filter;!PLAYER"] = 'Not Casted by me',
	["filter;!RAID_IN_COMBAT"] = "Not Relevant for your Class",
	["filter;BIG_DEFENSIVE"] = "Big Defensive",
	["filter;EXTERNAL_DEFENSIVE"] = "External Defensive",
	["filter;!BIG_DEFENSIVE"] = "Not Big Defensive",
	["filter;!EXTERNAL_DEFENSIVE"] = "Not External Defensive",
	["filter;DISPELLABLE"] = "Dispellable",
	["filter;!DISPELLABLE"] = "Not Dispellable",
	["filter;RAID_PLAYER_DISPELLABLE"] = "Dispellable be Me",
	["filter;!RAID_PLAYER_DISPELLABLE"] = "Not Dispellable be Me",
	["filter;CROWD_CONTROL"] = "Crown Control",
	["filter;!CROWD_CONTROL"] = "Not Crown Control",
	["filter;IMPORTANT"] = "Important",
	["filter;!IMPORTANT"] = "Not Important",
	["includeDispelTypes;Magic"] = "Magic",
	["includeDispelTypes;Curse"] = "Curse",
	["includeDispelTypes;Poison"] = "Poison",
	["includeDispelTypes;Disease"] = "Disease",
	["excludeDispelTypes;Magic"] = "Not Magic",
	["excludeDispelTypes;Curse"] = "Not Curse",
	["excludeDispelTypes;Poison"] = "Not Poison",
	["excludeDispelTypes;Disease"] = "Not Disease",
	["candidateFilters;canApplyAura"] = "Can Apply Aura",
	["candidateFilters;isFromPlayerOrPlayerPet"] = "Is From Player or Pet",
	["candidateFilters;isStealable"] = "Is Stealable",
	["candidateFilters;isPriorityAura"] = "Is Priority Aura",
	["candidateFilters;isBossAura"] = "Is Boss Aura",
	["candidateFilters;isRoleAura"] = "Is Role Aura",
	["candidateFilters;isBossOrRoleAura"] = "Is Boss or Role Aura",
	["spells;includeSpellIDs"] = "List of Spell IDs to Display",
	["spells;excludeSpellIDs"] = "List of Spell IDs to Ignore",
}

local AuraFiltersNegate = {
	["filter;PLAYER"] = "filter;!PLAYER",
	["filter;!PLAYER"] = "filter;PLAYER",
	["filter;RAID_IN_COMBAT"] = "filter;!RAID_IN_COMBAT",
	["filter;!RAID_IN_COMBAT"] = "filter;RAID_IN_COMBAT",
	["filter;BIG_DEFENSIVE"] = "filter;!BIG_DEFENSIVE",
	["filter;!BIG_DEFENSIVE"] = "filter;BIG_DEFENSIVE",
	["filter;EXTERNAL_DEFENSIVE"] = "filter;!EXTERNAL_DEFENSIVE",
	["filter;!EXTERNAL_DEFENSIVE"] = "filter;EXTERNAL_DEFENSIVE",
	["filter;RAID_PLAYER_DISPELLABLE"] = "filter;!RAID_PLAYER_DISPELLABLE",
	["filter;!RAID_PLAYER_DISPELLABLE"] = "filter;RAID_PLAYER_DISPELLABLE",
	["filter;DISPELLABLE"] = "filter;!DISPELLABLE",
	["filter;!DISPELLABLE"] = "filter;DISPELLABLE",
	["filter;CROWD_CONTROL"] = "filter;!CROWD_CONTROL",
	["filter;!CROWD_CONTROL"] = "filter;CROWD_CONTROL",
	["includeDispelTypes;Magic"] = "excludeDispelTypes;Magic",
	["includeDispelTypes;Curse"] = "excludeDispelTypes;Curse",
	["includeDispelTypes;Poison"] = "excludeDispelTypes;Poison",
	["includeDispelTypes;Disease"] = "excludeDispelTypes;Disease",
	["excludeDispelTypes;Magic"] = "includeDispelTypes;Magic",
	["excludeDispelTypes;Curse"] = "includeDispelTypes;Curse",
	["excludeDispelTypes;Poison"] = "includeDispelTypes;Poison",
	["excludeDispelTypes;Disease"] = "includeDispelTypes;Disease",
	["spells;includeSpellIDs"] = "spells;excludeSpellIDs",
	["spells;excludeSpellIDs"] = "spells;includeSpellIDs",
}

local Filters = {}

Filters.buffs = {
	"filter;PLAYER",
	"filter;RAID_IN_COMBAT",
	"filter;DISPELLABLE",
	"filter;RAID_PLAYER_DISPELLABLE",
	"filter;BIG_DEFENSIVE",
	"filter;EXTERNAL_DEFENSIVE",
	"filter;!PLAYER",
	"filter;!RAID_IN_COMBAT",
	"filter;!DISPELLABLE",
	"filter;!RAID_PLAYER_DISPELLABLE",
	"filter;!BIG_DEFENSIVE",
	"filter;!EXTERNAL_DEFENSIVE",
	"candidateFilters;canApplyAura",
	"candidateFilters;isFromPlayerOrPlayerPet",
	"candidateFilters;isStealable",
	"spells;includeSpellIDs",
	"spells;excludeSpellIDs",
}

Filters.mbuff = {
	"filter;PLAYER",
	"filter;!PLAYER",
}

Filters.mbuffs = {
	"filter;PLAYER",
	"filter;RAID_IN_COMBAT",
	"filter;DISPELLABLE",
	"filter;RAID_PLAYER_DISPELLABLE",
	"filter;IMPORTANT",
	"filter;BIG_DEFENSIVE",
	"filter;EXTERNAL_DEFENSIVE",
	"filter;!PLAYER",
	"filter;!RAID_IN_COMBAT",
	"filter;!DISPELLABLE",
	"filter;!RAID_PLAYER_DISPELLABLE",
	"filter;!IMPORTANT",
	"filter;!BIG_DEFENSIVE",
	"filter;!EXTERNAL_DEFENSIVE",
	"candidateFilters;canApplyAura",
	"candidateFilters;isFromPlayerOrPlayerPet",
	"candidateFilters;isStealable",
	"spells;includeSpellIDs",
	"spells;excludeSpellIDs",
}

Filters.mdebuffs ={
	"filter;PLAYER",
	"filter;RAID_IN_COMBAT",
	"filter;RAID_PLAYER_DISPELLABLE",
	"filter;CROWD_CONTROL",
	"includeDispelTypes;Magic",
	"includeDispelTypes;Curse",
	"includeDispelTypes;Poison",
	"includeDispelTypes;Disease",
	"candidateFilters;canApplyAura",
	"candidateFilters;isFromPlayerOrPlayerPet",
	"candidateFilters;isStealable",
	"candidateFilters;isPriorityAura",
	"candidateFilters;isBossAura",
	"candidateFilters;isRoleAura",
	"candidateFilters;isBossOrRoleAura",
	"filter;!PLAYER",
	"filter;!RAID_IN_COMBAT",
	"filter;!CROWD_CONTROL",
	"excludeDispelTypes;Magic",
	"excludeDispelTypes;Curse",
	"excludeDispelTypes;Poison",
	"excludeDispelTypes;Disease",
}

local SORT_VALUES = {
	[0] = L["Unsorted"],
	[1] = L["Default"],
	[2] = L["Big Defensive"],
	[3] = L["Expiration"],
	[4] = L["Expiration Only"],
	[5] = L["Name"],
	[6] = L["Name Only"],
}

local MAX_AURAS_VALUES = { [100] = "Unlimited" }
for i=1,16 do MAX_AURAS_VALUES[i] = tostring(i) end

local function refresh_aura_status(status)
	status:UpdateDB()
	Grid2Options:RefreshStatusIndicators(status, "Layout")
end

-- aura_filter management

local function filter_get_value(status, key, subkey, default)
	local t = status.dbx[key]
	local v =  (type(t)=='table' and t or {})[subkey]
	if v==nil or v=='' then
		return default
	else
		return v
	end
end

local function filter_set_value(status, key, subkey, value, default)
	local t = status.dbx[key]
	status.dbx[key] = type(t)=='table' and t or {}
	if value~='' and value~=default then
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
	return tcontains( { strsplit('|', filter) }, value)
end

local function filter_add_substring(status, key, subkey, value, default)
	if not filter_exists_substring(status, key, subkey, value) then
		filter_toggle_substring(status, key, subkey, value, default)
	end
end

local function filter_remove_substring(status, key, subkey, value, default)
	if filter_exists_substring(status, key, subkey, value) then
		filter_toggle_substring(status, key, subkey, value, default)
	end
end

-- aura & candidate filters management

local function mfilter_get_tree_value(status, ...)
	local dbx = status.dbx
	for i=1,select("#",...) do
		dbx = dbx[ select(i,...) ]
		if dbx==nil then return nil end
	end
	return dbx
end

local function mfilter_set_tree_value(status, value, ...)
	local function set(tree, fields)
		local field = table.remove(fields,1)
		if #fields==0 then
			tree[field] = value
		else
			tree[field] = set( tree[field] or {}, fields )
		end
		return next(tree) and tree or nil
	end
	set( status.dbx, {...} )
end

local function mfilter_set_disabled(status, filter, default, negated)
	if filter==nil then return end
	local typ, field = strsplit(";",filter)
	if typ == 'filter' then
		filter_remove_substring(status, 'aura_filter', 'filter', field, default)
	elseif typ == 'spells' then
		status.dbx.auras = negated and status.dbx.auras or nil
		mfilter_set_tree_value(status, nil, 'aura_filter', 'candidateFilters', field)
	elseif typ == 'candidateFilters' then
		mfilter_set_tree_value(status, nil, 'aura_filter', 'candidateFilters', field)
	else
		mfilter_set_tree_value(status, nil, 'aura_filter', 'candidateFilters', typ, field)
	end
	refresh_aura_status(status)
end

local function mfilter_set_enabled(status, filter, default)
	if filter==nil then return end
	mfilter_set_disabled(status, AuraFiltersNegate[filter], default, true)
	local typ, field = strsplit(";",filter)
	if typ == 'filter' then
		filter_add_substring(status, 'aura_filter', 'filter', field, default)
	elseif typ == 'spells' then
		status.dbx.auras = status.dbx.auras or {}
		mfilter_set_tree_value(status, true, 'aura_filter', 'candidateFilters', field)
	elseif typ == 'candidateFilters' then
		mfilter_set_tree_value(status, true, 'aura_filter', 'candidateFilters', field)
	else
		mfilter_set_tree_value(status, true, 'aura_filter', 'candidateFilters', typ, field)
	end
	refresh_aura_status(status)
end

local function mfilter_is_enabled(status, filter)
	local typ, field = strsplit(";",filter)
	if typ == 'filter' then
		return filter_exists_substring(status, 'aura_filter', 'filter', field)
	elseif typ == 'candidateFilters' or typ == 'spells' then
		return mfilter_get_tree_value(status, 'aura_filter', 'candidateFilters', field)~=nil
	else
		return mfilter_get_tree_value(status, 'aura_filter', 'candidateFilters', typ, field)~=nil
	end
end

-- color options

local function make_color_option(status, options, key, order, name, width)
	options[key] = {
		type = "color",
		hasAlpha = true,
		width = width or "full",
		order = order,
		name = L[name or "Color"],
		get = function()
			local c = status.dbx[key]
			if c then
				return c.r, c.g, c.b, c.a
			else
				return 0,0,0,1
			end
		end,
		set = function(info, r, g, b, a)
			local c = status.dbx[key] or {}
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
			width = params and params.width or 0.65,
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

--==============================================
--
--==============================================

function Grid2Options:MakeStatusAuraMiscOptions(status, options)
	options.max_auras = {
		type = "select",
		order = 20,
		width = 0.75,
		name = L["Max Auras"],
		desc = L["Select the maximum number of auras to display."],
		get = function ()
			return filter_get_value( status, 'aura_filter', 'maxAuras', 100)
		end,
		set = function (_, v)
			filter_set_value( status, 'aura_filter', 'maxAuras', v, 100 )
		end,
		values = MAX_AURAS_VALUES,
	}
	options.sort_rule = {
		type = "select",
		order = 30,
		width = 0.75,
		name = "Sorting",
		desc = L["Select the auras sort order."],
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
		order = 40,
		width = 0.75,
		name = L["Reverse sort"],
		desc = L["Reverse sort order."],
		get = function()
			return filter_get_value( status, 'aura_filter', 'sortDir' ) == 1
		end,
		set = function(_, v)
			filter_set_value( status, 'aura_filter', 'sortDir', v and 1 or nil )
		end,
	}
end

function Grid2Options:MakeStatusAuraListOptions(status, options)
	options.auraListAdd = {
		type = "input", dialogControl = (status.dbx.type=='mdebuffs') and "EditBoxGrid2Debuffs" or "EditBoxGrid2Buffs",
		order = 500,
		width = "full",
		name = L["Type Aura Name or SpellId"],
		desc = L["Type a name or spell identifier to add to the list below."],
		get = function() end,
		set = function(info, value)
			local _, spell = string.match(value, "^(.-[@#>])(.*)$")
			spell = strtrim(spell or value)
			if #spell>0 then
				table.insert(status.dbx.auras, tonumber(spell) or spell)
				status:Refresh()
			end
		end,
		hidden = function() return status.dbx.auras==nil end
	}
	options.auraList = {
		type = "input", dialogControl = "Grid2ExpandedEditBox",
		order = 520,
		width = "full",
		name = "",
		multiline = 16,
		get = function()
			local auras = {}
			for _,aura in pairs(status.dbx.auras) do
				auras[#auras+1] = type(aura)~='number' and aura or string.format("%s <%d>", GetSpellInfo(aura) or UNKNOWN or L["Unknown"], aura)
			end
			return table.concat( auras, "\n" )
		end,
		set = function(_, v)
			wipe(status.dbx.auras)
			local auras = { strsplit("\n", strtrim(v)) }
			for _,name in pairs(auras) do
				local prefix, links = string.match(name,"^(.-)(|c.*)")
				local aura = strtrim(prefix or name)
				if #aura>0 then
					table.insert( status.dbx.auras, tonumber(aura) or tonumber(strmatch(aura,'^.+<(%d+)')) or aura )
				end
				if links then -- check for spell links
					for aura in string.gmatch(links, "Hspell:(%d+):") do
						table.insert( status.dbx.auras, tonumber(aura) or aura )
					end
				end
			end
			status:Refresh()
		end,
		hidden = function() return status.dbx.auras==nil end
	}
	return options
end

function Grid2Options:MakeStatusAuraFilterOptions(status, options)
	local stype = status.dbx.type
	local bsingle = stype=='mbuff'
	local fwidth = not bsingle and "full" or nil
	local default = stype=='mdebuffs' and 'HARMFUL' or 'HELPFUL'
	local filters = Filters[stype]
	options.header_filter = { type = "header", order = 99, name = "Auras to Display" }
	options.select_filter = {
		type = "select",
		order = 100,
		width = "full",
		name = "",
		desc = L["Select which aura categories should be displayed."],
		get = function() return 0 end,
		set = function(_, v)
			mfilter_set_enabled(status, filters[v], default)
		end,
		values = function()
			local t = { [0] = "-- Select an aura filter --" }
			for i,filter in ipairs(filters) do
				if not mfilter_is_enabled(status, filter) then
					t[i] = AuraFilters[filter]
				end
			end
			return t
		end,
		hidden = function() return bsingle end,
	}
	for i,filter in ipairs(filters) do
		options['mfilter'..i] = {
			type = "toggle",
			order = i+100,
			width = fwidth,
			name = AuraFilters[filter] or "Unknow:".. filter,
			desc = L["Click to remove this filter"],
			get = function() return true end,
			set = (not bsingle) and function() mfilter_set_disabled(status, filter, default) end or nil,
			hidden= function() return not mfilter_is_enabled(status,filter) end,
			disabled = bsingle or nil,
		}
	end
end

-- Grid2Options:MakeMidnightBuffsOptions(NewBuffsOptions.arg, NewBuffsOptions)

Grid2Options:RegisterStatusOptions("mbuff", "buff", function(self, status, options, optionParams)
	make_color_option(status, options, "color1", 100.1, L["Color"], "half")
	self:MakeStatusAuraFilterOptions(status, options)
	self:MakeStatusAuraListOptions(status, options)
end,{
	groupOrder = 5, isDeletable = true,
	titleIcon = "Interface\\Icons\\Inv_enchant_shardbrilliantsmall",
})

Grid2Options:RegisterStatusOptions("mbuffs", "buff", function(self, status, options, optionParams)
	make_color_option(status, options, "color1", 90, L["Color"], "half")
	self:MakeStatusAuraFilterOptions(status, options)
	self:MakeStatusAuraMiscOptions(status, options)
	self:MakeStatusAuraListOptions(status, options)
end,{
	groupOrder = 10, isDeletable = true,
	titleIcon = "Interface\\Icons\\Inv_enchant_shardbrilliantsmall",
})

--==============================================
--
--==============================================

local function MakeDebuffTypesColorsOptions(status, options, optionParams)
	local order = optionParams and optionParams.order or 1
	local inone = optionParams and optionParams.ignore_none
	options.debuff_types_header = {
		type = "header",
		order = order,
		name = L["Debuff Type Colors"]
	}
	for typ,v in pairs(Grid2.DispelCurveDefaults) do
		local idx, color = unpack(v)
		if idx~=0 or not inone then
			make_colortype_option(status, options, typ, idx==0 and order+15 or order+idx, color, optionParams)
		end
	end
	options.dtype_reset_header = {
		type = "description",
		width = "full",
		order = order+18,
		name = ""
	}
	options.dtype_reset_colors = {
		type = "execute",
		order = order+19,
		width = "half",
		name = L["Reset"],
		desc = L["Reset colors to the default values."],
		func = function () 	wipe(status.dbx.colors); refresh_aura_status(status) end,
		confirm = true,
	}
end

-- Grid2Options:MakeMidnightDebuffsOptions(NewDebuffsOptions.arg, NewDebuffsOptions)

Grid2Options:RegisterStatusCategoryOptions("debuff", NewDebuffsOptions)

Grid2Options:RegisterStatusOptions("mdebuffs", "debuff", function(self, status, options, optionParams)
	self:MakeStatusAuraFilterOptions(status, options)
	self:MakeStatusAuraMiscOptions(status, options)
end,{
	groupOrder = 10, isDeletable = true,
	titleIcon = "Interface\\Icons\\Spell_deathknight_strangulate",
})

--==============================================
--
--==============================================

function Grid2Options:MakeMidnightDispellableByMeOptions(status, options)
	-- MakeDebuffTypesColorsOptions( status, options, {width=.75, ignore_none=true} )
end

Grid2Options:RegisterStatusOptions("mdebuffType", "debuff", function(self, status, options, optionParams)
	self:MakeMidnightDispellableByMeOptions(status, options, optionParams)
end,{
	groupOrder = 5,
})
