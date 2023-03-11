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
			status:Refresh()
		end,
		hidden = function() return status.dbx.auras==nil end
	}
	return options
end

function Grid2Options:MakeStatusDebuffsFilterOptions(status, options, optionParams)
	self:MakeHeaderOptions( options, "Display" )
	options.strictFiltering = {
		type = "toggle",
		width = "full",
		name = '|cFFffff00' .. L["Use strict filtering (all conditions must be met)."],
		desc = L[""],
		order = 80.5,
		get = function() return not status.dbx.lazyFiltering end,
		set = function(_,v)
			status.dbx.lazyFiltering = (not v) or nil
			status:Refresh()
		end,
		hidden = function() return status.dbx.useWhiteList end,
	}
	options.showDispelDebuffs = {
		type = "toggle",
		name = L["Dispellable by Me"],
		desc = L["Display debuffs i can dispell"],
		order = 81,
		get = function () return status.dbx.filterDispelDebuffs~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterDispelDebuffs = nil
			else
				status.dbx.filterDispelDebuffs = false
			end
			if v~=nil and status.dbx.auras then
				status.dbx.aurasBak = status.dbx.auras
				status.dbx.auras = nil
			end
			status:Refresh()			
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.showNonDispelDebuffs = {
		type = "toggle",
		name = L["Non Dispellable by Me"],
		desc = L["Display debuffs i can not dispell"],
		order = 81.5,
		get = function () return status.dbx.filterDispelDebuffs~=true end,
		set = function (_, v)
			status.dbx.filterDispelDebuffs = not v or nil
			if v~=nil and status.dbx.auras then
				status.dbx.aurasBak = status.dbx.auras
				status.dbx.auras = nil
			end
			status:Refresh()			
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.filterSep00 = { type = "description", name = "", order = 81.9 }
	options.showTypedDebuffs = {
		type = "toggle",
		name = L["Typed Debuffs"],
		desc = L["Display Magic, Curse, Poison or Disease type debuffs."],
		order = 82,
		get = function () return status.dbx.filterTyped~=true end,
		set = function (_, v)
			status.dbx.filterTyped = (not v) or nil
			status:Refresh()
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.showUntypedDebuffs = {
		type = "toggle",
		name = L["Untyped Debuffs"],
		desc = L["Display debuffs with no type."],
		order = 83,
		get = function () return status.dbx.filterTyped~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterTyped = nil
			else
				status.dbx.filterTyped = false
			end
			status:Refresh()
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.filterSep0 = { type = "description", name = "", order = 83.5 }
	options.showNonBossDebuffs = {
		type = "toggle",
		name = L["Non Boss Debuffs"],
		desc = L["Display debuffs not casted by Bosses"],
		order = 84,
		get = function () return status.dbx.filterBossDebuffs~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterBossDebuffs = nil
			else
				status.dbx.filterBossDebuffs = false
			end
			status:Refresh()			
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.showBossDebuffs = {
		type = "toggle",
		name = L["Boss Debuffs"],
		desc = L["Display debuffs direct casted by Bosses"],
		order = 85,
		get = function () return status.dbx.filterBossDebuffs~=true end,
		set = function (_, v)
			status.dbx.filterBossDebuffs = (not v) or nil
			status:Refresh()			
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.filterSep1 = { type = "description", name = "", order = 85.5 }
	options.showShortDebuffs = {
		type = "toggle",
		name = L["Short Duration"],
		desc = L["Display debuffs with duration below 5 minutes."],
		order = 86,
		get = function () return status.dbx.filterLongDebuffs~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterLongDebuffs = nil
			else
				status.dbx.filterLongDebuffs = false
			end
			status:Refresh()			
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.showLongDebuffs = {
		type = "toggle",
		name = L["Long Duration"],
		desc = L["Display debuffs with duration above 5 minutes."],
		order = 87,
		get = function () return status.dbx.filterLongDebuffs~=true end,
		set = function (_, v)
			status.dbx.filterLongDebuffs = (not v) and true or nil
			status:Refresh()			
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.filterSep2 = { type = "description", name = "", order = 87.5 }
	options.showNonSelfDebuffs = {
		type = "toggle",
		name = L["Non Self Casted"],
		desc = L["Display non self debuffs"],
		order = 88,
		get = function () return status.dbx.filterCaster~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterCaster = nil
			else
				status.dbx.filterCaster = false
			end
			status:Refresh()			
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.showSelfDebuffs = {
		type = "toggle",
		name = L["Self Casted"],
		desc = L["Display self debuffs"],
		order = 89,
		get = function () return status.dbx.filterCaster~=true end,
		set = function (_, v)
			status.dbx.filterCaster = (not v) and true or nil
			status:Refresh()			
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.filterSep3 = { type = "description", name = "", order = 89.5 }
	options.useWhiteList = {
		type = "toggle",
		name = L["Whitelist"],
		desc = L["Display only debuffs contained in a user defined list."],
		order = 90,
		get = function () return status.dbx.useWhiteList and status.dbx.auras~=nil end,
		set = function (_, v)
			status.dbx.filterDispelDebuffs = nil
			status.dbx.filterLongDebuffs = nil
			status.dbx.filterBossDebuffs = nil
			status.dbx.filterCaster = nil
			status.dbx.filterTyped = nil
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
		order = 91,
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
	self:MakeStatusAuraCommonOptions(status, options, optionParams)
	self:MakeStatusAuraTextOptions(status, options, optionParams)
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
	options.debuffslist = {
		type = "group", order = 20, name = L[ status.dbx.useWhiteList and 'Whitelist' or 'Blacklist'],
		desc = L["Type a list of debuffs, one debuff per line."],
		args = self:MakeStatusDebuffsListOptions(status,{}, optionParams), hidden = function() return status.dbx.auras==nil end
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
})
