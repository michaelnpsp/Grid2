local L = Grid2Options.L

local FILTERS = { 'filterDispelDebuffs', 'filterTyped', 'filterBossDebuffs', 'filterPermaDebuffs', 'filterLongDebuffs', 'filterCaster', 'filterRelevant' }
local MT = {
	['nil']   = { [1] = true, [2] = false }, -- nil   setting
	['false'] = { [1] = true, [2] = nil   }, -- false setting
	['true']  = { [1] = nil , [2] = false }, -- true  setting
	[1]       = { [true] = 1, [false] = 2 }, -- Key=1 left  toggle / true  = non-lazy filter
	[2]       = { [true] = 2, [false] = 1 }, -- key=2 right toggle / false = lazy filter
}

function Grid2Options:MakeStatusDebuffsFilterOptions(status, options, optionParams)
	local order = 82
	local IsHidden = function () return status.dbx.useWhiteList end
	local function MakeCondition(key, invert, text1, desc1, text2, desc2)
		options[key..'1'] = {
			type = "toggle",
			order = order + (invert and 0.1 or 0),
			name = L[text1],
			desc = L[desc1],
			get = function ()
				return status.dbx[key]==false or (not status.dbx.lazyFiltering and status.dbx[key]==nil)
			end,
			set = function (_, v)
				status.dbx[key] = MT[ tostring(status.dbx[key]) ][ MT[1][not status.dbx.lazyFiltering] ]
				status:Refresh()
			end,
			hidden = IsHidden,
		}
		options[key..'2'] = {
			type = "toggle",
			order = order + (invert and 0 or 0.1),
			name = L[text2],
			desc = L[desc2],
			get = function ()
				return status.dbx[key]==true or (not status.dbx.lazyFiltering and status.dbx[key]==nil)
			end,
			set = function (_, v)
				status.dbx[key] = MT[ tostring(status.dbx[key]) ][ MT[2][not status.dbx.lazyFiltering] ]
				status:Refresh()
			end,
			hidden = IsHidden,
		}
		options[key..'3'] = { type = "description", name = "", order = order + 0.2, hidden = IsHidden }
		order = order + 1
	end
	self:MakeHeaderOptions( options, "Display" )
	options.strictFiltering = {
		type = "toggle",
		width = "full",
		name = '|cFFffff00' .. L["Use strict filtering (all conditions must be met)."],
		desc = L[""],
		order = 81,
		get = function() return not status.dbx.lazyFiltering end,
		set = function(_,v)
			status.dbx.lazyFiltering = (not v) or nil
			status:Refresh()
		end,
		hidden = IsHidden,
	}
	MakeCondition('filterDispelDebuffs', true,
		"Non Dispellable by Me",
		"Display debuffs i can not dispell",
		"Dispellable by Me",
		"Display debuffs i can dispell"
	)
	MakeCondition('filterTyped', false,
		"Typed Debuffs",
		"Display Magic, Curse, Poison or Disease type debuffs.",
		"Untyped Debuffs",
		"Display debuffs with no type."
	)
	MakeCondition('filterBossDebuffs', false,
		"Boss Debuffs",
		"Display debuffs direct casted by Bosses",
		"Non Boss Debuffs",
		"Display debuffs not casted by Bosses"
	)
	MakeCondition('filterRelevant', false,
		"Relevant Debuffs",
		"Display debuffs marked as relevant by blizzard developers.",
		"Non-Relevant Debuffs",
		"Display debuffs marked as non-relevant by blizzard developers."
	)
	MakeCondition('filterPermaDebuffs', false,
		"Permanent Debuffs",
		"Display debuffs with no duration.",
		"Temporary Debuffs",
		"Display debuffs with a duration."
	)
	MakeCondition('filterLongDebuffs', false,
		"Long Duration",
		"Display debuffs with duration above 5 minutes.",
		"Short Duration",
		"Display debuffs with duration below 5 minutes."
	)
	MakeCondition('filterCaster', false,
		"Self Casted",
		"Display self debuffs",
		"Non Self Casted",
		"Display non self debuffs"
	)
	options.useWhiteList = {
		type = "toggle",
		name = L["Whitelist"],
		desc = L["Display only debuffs contained in a user defined list."],
		order = order + 0.1,
		get = function () return status.dbx.useWhiteList and status.dbx.auras~=nil end,
		set = function (_, v)
			for _,key in ipairs(FILTERS) do	status.dbx[key] = nil end
			if v then
				status.dbx.auras = status.dbx.auras or status.dbx.aurasBak or {}
				status.dbx.aurasBak = nil
				status.dbx.useWhiteList = true
			else
				status.dbx.aurasBak = status.dbx.auras
				status.dbx.auras = nil
				status.dbx.useWhiteList = nil
			end
			status:Refresh()
			self:MakeStatusOptions(status)
		end,
	}
	options.useBlackList = {
		type = "toggle",
		name = L["Blacklist"],
		desc = L["Ignore debuffs contained in a user defined list. This condition is always strict."],
		order = order + 0.2,
		get = function () return (not status.dbx.useWhiteList) and status.dbx.auras~=nil end,
		set = function (_, v)
			if v then
				status.dbx.auras = status.dbx.auras or status.dbx.aurasBak or {}
				status.dbx.aurasBak = nil
			else
				status.dbx.aurasBak = status.dbx.auras
				status.dbx.auras = nil
			end
			status.dbx.useWhiteList = nil
			status:Refresh()
			self:MakeStatusOptions(status)
		end,
	}
end

function Grid2Options:MakeStatusDebuffsGeneralOptions(status, options, optionParams)
	self:MakeStatusAuraColorsOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusDebuffsFilterOptions(status, options, optionParams)
	self:MakeStatusAuraCombineStacksOptions(status, options, optionParams)
	self:MakeStatusAuraTextOptions(status, options, optionParams)
	return options
end

Grid2Options:RegisterStatusOptions("debuffs", "debuff", function(self, status, options, optionParams)
	self:MakeStatusTitleOptions(status, options, optionParams)
	options.settings   = {
		type = "group", order = 10, name = L['General'],
		args = self:MakeStatusDebuffsGeneralOptions(status,{}, optionParams),
	}
	options.debuffslist = {
		type = "group", order = 20, name = L[ status.dbx.useWhiteList and 'Whitelist' or 'Blacklist'],
		desc = L["Type a list of debuffs, one debuff per line."],
		args = self:MakeStatusAuraListOptions(status,{}, optionParams), hidden = function() return status.dbx.auras==nil end
	}
	options.load = {
		type = "group", order = 30, name = L['Load'],
		args = self:MakeStatusLoadOptions( status, {}, optionParams )
	}
	options.indicators = {
		type = "group", order = 40, name = L['indicators'],
		args = self:MakeStatusIndicatorsOptions(status,{}, optionParams)
	}
end,{
	groupOrder = 20, hideTitle = true, isDeletable = true,
	titleIcon = "Interface\\Icons\\Spell_deathknight_strangulate",
})
