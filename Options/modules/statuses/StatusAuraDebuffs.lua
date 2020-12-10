local L = Grid2Options.L

function Grid2Options:MakeStatusDebuffsListOptions(status, options, optionParams)
	options.aurasList = {
		type = "input", dialogControl = "Grid2ExpandedEditBox",
		order = 155,
		width = "full",
		name = "",
		multiline = 16,
		get = function()
			local auras = {}
			for _,aura in pairs(status.dbx.auras) do
				auras[#auras+1]= (type(aura)=="number") and GetSpellInfo(aura) or aura
			end
			return table.concat( auras, "\n" )
		end,
		set = function(_, v)
			wipe(status.dbx.auras)
			local auras = { strsplit("\n,", strtrim(v)) }
			for _,name in pairs(auras) do
				local aura = strtrim(name)
				if #aura>0 then
					table.insert(status.dbx.auras, tonumber(aura) or aura )
				end
			end
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.auras==nil end
	}
	return options
end

function Grid2Options:MakeStatusDebuffsFilterOptions(status, options, optionParams)
	self:MakeHeaderOptions( options, "Display" )
	options.showDispelDebuffs = {
		type = "toggle",
		name = L["Dispellable by Me"],
		desc = L["Display only debuffs i can dispell"],
		order = 150.9,
		width = "full",
		get = function () return status.dbx.filterDispelDebuffs end,
		set = function (_, v)
			status.dbx.filterDispelDebuffs = v or nil
			if v and status.dbx.auras then
				status.dbx.aurasBak = status.dbx.auras
				status.dbx.auras = nil
			end
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.showTypedDebuffs = {
		type = "toggle",
		name = L["Typed Debuffs"],
		desc = L["Display Magic, Curse, Poison or Disease type debuffs."],
		order = 150.91,
		get = function () return status.dbx.filterTyped~=true end,
		set = function (_, v)
			status.dbx.filterTyped = (not v) and true or nil
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterDispelDebuffs or status.dbx.filterBossDebuffs==false end
	}
	options.showUntypedDebuffs = {
		type = "toggle",
		name = L["Untyped Debuffs"],
		desc = L["Display debuffs with no type."],
		order = 150.92,
		get = function () return status.dbx.filterTyped~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterTyped = nil
			else
				status.dbx.filterTyped = false
			end
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterDispelDebuffs or status.dbx.filterBossDebuffs==false end
	}
	options.filterSep0 = { type = "description", name = "", order = 150.93 }
	options.showBossDebuffs = {
		type = "toggle",
		name = L["Boss Debuffs"],
		desc = L["Display debuffs direct casted by Bosses"],
		order = 151.5,
		get = function () return status.dbx.filterBossDebuffs~=true end,
		set = function (_, v)
			status.dbx.filterBossDebuffs = (not v) and true or nil
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterDispelDebuffs end
	}
	options.showNonBossDebuffs = {
		type = "toggle",
		name = L["Non Boss Debuffs"],
		desc = L["Display debuffs not casted by Bosses"],
		order = 151,
		get = function () return status.dbx.filterBossDebuffs~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterBossDebuffs = nil
			else
				status.dbx.filterBossDebuffs = false
			end
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterDispelDebuffs end
	}
	options.filterSep1 = { type = "description", name = "", order = 151.9 }
	options.showLongDebuffs = {
		type = "toggle",
		name = L["Long Duration"],
		desc = L["Display debuffs with duration above 5 minutes."],
		order = 152.5,
		get = function () return status.dbx.filterLongDebuffs~=true end,
		set = function (_, v)
			status.dbx.filterLongDebuffs = (not v) and true or nil
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterDispelDebuffs or status.dbx.filterBossDebuffs==false end
	}
	options.showShortDebuffs = {
		type = "toggle",
		name = L["Short Duration"],
		desc = L["Display debuffs with duration below 5 minutes."],
		order = 152,
		get = function () return status.dbx.filterLongDebuffs~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterLongDebuffs = nil
			else
				status.dbx.filterLongDebuffs = false
			end
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterDispelDebuffs or status.dbx.filterBossDebuffs==false end
	}
	options.filterSep2 = { type = "description", name = "", order = 152.9 }
	options.showSelfDebuffs = {
		type = "toggle",
		name = L["Self Casted"],
		desc = L["Display self debuffs"],
		order = 153.5,
		get = function () return status.dbx.filterCaster~=true end,
		set = function (_, v)
			status.dbx.filterCaster = (not v) and true or nil
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterDispelDebuffs or status.dbx.filterBossDebuffs==false end
	}
	options.showNonSelfDebuffs = {
		type = "toggle",
		name = L["Non Self Casted"],
		desc = L["Display non self debuffs"],
		order = 153,
		get = function () return status.dbx.filterCaster~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterCaster = nil
			else
				status.dbx.filterCaster = false
			end
			status:Refresh(true)
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterDispelDebuffs or status.dbx.filterBossDebuffs==false end
	}
	options.filterSep3 = { type = "description", name = "", order = 153.9 }
	options.useWhiteList = {
		type = "toggle",
		name = L["Whitelist"],
		desc = L["Display only debuffs defined in a user defined list."],
		order = 154,
		get = function () return status.dbx.useWhiteList and status.dbx.auras~=nil end,
		set = function (_, v)
			if v then
				status.dbx.auras = status.dbx.auras or status.dbx.aurasBak or {}
				status.dbx.aurasBak = nil
				status.dbx.useWhiteList = true
			else
				status.dbx.aurasBak = status.dbx.auras
				status.dbx.auras = nil
				status.dbx.useWhiteList = nil
			end
			status:Refresh(true)
			self:MakeStatusOptions(status)
		end,
		hidden = function() return status.dbx.filterDispelDebuffs end,
	}
	options.useBlackList = {
		type = "toggle",
		name = L["Blacklist"],
		desc = L["Ignore debuffs defined in a user defined list."],
		order = 154.5,
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
			status:Refresh(true)
			self:MakeStatusOptions(status)
		end,
	}
end

function Grid2Options:MakeStatusDebuffsGeneralOptions(status, options, optionParams)
	self:MakeStatusEnabledOptions(status, options, optionParams, false)
	self:MakeStatusAuraDescriptionOptions(status, options, optionParams)
	self:MakeStatusAuraCommonOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusDebuffsFilterOptions(status, options, optionParams)
	return options
end

Grid2Options:RegisterStatusOptions("debuffs", "debuff", function(self, status, options, optionParams)
	self:MakeStatusTitleOptions(status, options, optionParams)
	options.settings   = {
		type = "group", order = 10, name = L['General'],
		args = self:MakeStatusDebuffsGeneralOptions(status,{}, optionParams),
	}
	options.indicators = { type = "group", order = 30, name = L['indicators'], args = self:MakeStatusIndicatorsOptions(status,{}, optionParams)     }
	options.filterlist = {
		type = "group", order = 20, name = L[ status.dbx.useWhiteList and 'Whitelist' or 'Blacklist'],
		desc = L["Type a list of debuffs, one debuff per line."],
		args = self:MakeStatusDebuffsListOptions(status,{}, optionParams), hidden = function() return status.dbx.auras==nil end
	}
end,{
	groupOrder = 20, hideTitle = true, isDeletable = true,
})
