local L = Grid2Options.L

local MonitorizeValues = { [0]= L["NONE"], [1] = L["Value1"], [2] = L["Value2"], [3] = L["Value3"] }
local DurationValues = { [1] = L['Automatic'], [2] = L['Custom'] }
local TextValues1 = { [1] = L['Value Tracked'], [2] = L['Aura Name'], [3] = L['Custom Text'] }
local TextValues2 = { [2] = L['Aura Name'], [3] = L['Custom Text'] }
local ColorCountValues = {1,2,3,4,5,6,7,8,9}
local ColorizeByValues1= { [1] = L["Single Color"], [5] = L["Number of stacks"], [6] = L["Remaining time"], [7] = L["Elapsed time"] }
local ColorizeByValues2= { [1] = L["Single Color"], [5] = L["Number of stacks"], [6] = L["Remaining time"], [7] = L["Elapsed time"], [8] = L["Value"] }
local ColorizeByValues3= { [1] = L["Single Color"], [5] = L["Number of stacks"], [6] = L["Remaining time"], [7] = L["Elapsed time"], [2] = L["Debuff Type"] }

--{{ colors for aura statuses
local function StatusAuraUpdateColors(status, newCount)
	local oldCount = status.dbx.colorCount or 1
	for i=oldCount+1,newCount do
		status.dbx["color"..i] = { r=1, g=1, b=1, a=1 }
	end
	for i=newCount+1,oldCount do
		status.dbx["color"..i] = nil
	end
	status.dbx.colorCount = newCount>1 and newCount or nil
end

local function StatusAuraUpdateColorsThreshold(status, create)
	if status.dbx.colorCount and create then
		local newCount = status.dbx.colorCount - 1
		local thresholds = status.dbx.colorThreshold or {}
		local oldCount = #thresholds
		for i=oldCount+1,newCount do
			thresholds[i] = 0
		end
		for i=oldCount,newCount+1,-1 do
			table.remove(thresholds)
		end
		status.dbx.colorThreshold = thresholds
		status.dbx.blinkThreshold = nil
	else
		status.dbx.colorThreshold = nil
		status.dbx.colorThresholdValue = nil
		status.dbx.colorThresholdElapsed = nil
	end
end

function Grid2Options:MakeStatusAuraColorsSelectionOptions(status, options, optionParams)
	self:MakeHeaderOptions(options, "Colors")
	self:MakeStatusColorOptions(status, options, optionParams)
	if status.dbx.missing then return end
	options.colorizeBy = {
		type = "select",
		order = 10.1,
		width ="normal",
		name = L["Coloring based on"],
		desc = L["Coloring based on"],
		get = function()
			return	(status.dbx.debuffTypeColorize    and 2) or -- debuff type
					(status.dbx.colorThresholdValue   and 8) or -- aura value
					(status.dbx.colorThresholdElapsed and 7) or -- elapsed time
					(status.dbx.colorThreshold        and 6) or -- remaining time
					(status.dbx.colorCount            and 5) or -- number of stacks
					1                                           -- single color
		end,
		set = function( _, v)
			status.dbx.debuffTypeColorize = (v==2) or nil
			status.dbx.colorThresholdValue = (v==8) or nil
			status.dbx.colorThresholdElapsed = (v==7) or nil
			StatusAuraUpdateColors(status, v>=5 and (status.dbx.colorCount or 2) or 1)
			StatusAuraUpdateColorsThreshold(status, v>5)
			status:UpdateDB()
			self:MakeStatusOptions(status)
		end,
		values = (status.dbx.type=='debuffs' and ColorizeByValues3) or (status.dbx.valueIndex and ColorizeByValues2) or ColorizeByValues1,
	}
	if not status.dbx.colorCount then return end
	options.colorCount = {
		type = "select",
		order = 10.2,
		name = L["Color count"],
		desc = L["Select how many colors the status must provide."],
		get = function() return status.dbx.colorCount or 1 end,
		set = function(_,v)
			StatusAuraUpdateColors(status, v)
			StatusAuraUpdateColorsThreshold(status, status.dbx.colorThreshold~=nil)
			status:UpdateDB()
			self:MakeStatusOptions(status)
		end,
		values = ColorCountValues,
	}
	options.colorsSep = {  type = "description", order = 10.3, name = '' }
end

function Grid2Options:MakeStatusAuraColorsThresholdOptions(status, options, optionParams)
	local thresholds = status.dbx.colorThreshold
	if thresholds then
		self:MakeHeaderOptions(options, "Thresholds")
		local colorKey = L["Color"]
		local maxValue = status.dbx.colorThresholdValue and 200000 or 30
		local step     = status.dbx.colorThresholdValue and 50 or 0.1
		for i=1,#thresholds do
			options[ "colorThreshold" .. i ] = {
				type = "range",
				order = 50+i,
				name = colorKey .. (i+1),
				desc = L["Threshold to activate Color"] .. (i+1),
				min = 0,
				max = maxValue * 10,
				softMin = 0,
				softMax = maxValue,
				step = step,
				bigStep = step*10,
				get = function () return status.dbx.colorThreshold[i] end,
				set = function (_, v)
					local min,max
					if status.dbx.colorThresholdElapsed then
						min = status.dbx.colorThreshold[i-1] or 0
						max = status.dbx.colorThreshold[i+1] or maxValue
					else
						min = status.dbx.colorThreshold[i+1] or 0
						max = status.dbx.colorThreshold[i-1] or maxValue
					end
					if v>=min and v<=max then
						status.dbx.colorThreshold[i] = v
						status:UpdateDB()
					end
				end,
			}
		end
	end
end

function Grid2Options:MakeStatusAuraColorsOptions(status, options, optionParams)
	self:MakeStatusAuraColorsSelectionOptions(status, options, optionParams)
	self:MakeStatusAuraColorsThresholdOptions(status, options, optionParams)
end
--}}

function Grid2Options:MakeStatusAuraEnableStacksOptions(status, options, optionParams)
	self:MakeHeaderOptions(options, "Activation")
	if status.dbx.missing then return end
	options.enableStacks = {
		type = "range",
		order = 5,
		name = L["Activation Stacks"],
		desc = L["Select the minimum number of aura stacks to activate the status."],
		min = 1, softMax = 30, step = 1,
		get = function ()
			return status.dbx.enableStacks or 1
		end,
		set = function (_, v)
			status.dbx.enableStacks = v~=1 and v or nil
			status:Refresh()
		end,
	}
end

function Grid2Options:MakeStatusAuraMissingOptions(status, options, optionParams)
	options.showMissing = {
		type = "toggle",
		name = L["Show if missing"],
		desc = L["Display status only if the buff is not active."],
		order = 8,
		get = function () return status.dbx.missing end,
		set = function (_, v)
			status.dbx.missing = v or nil
			status.dbx.missingPets = nil
			status.dbx.strictFilter = nil
			if v then
				StatusAuraUpdateColors(status,1)
				status.dbx.colorThreshold = nil
				status.dbx.valueIndex = nil
				status.dbx.enableStacks = nil
			end
			status:Refresh()
			self:MakeStatusOptions(status)
		end,
	}
	options.missingPets = {
		type = "toggle",
		name = L["Hide on pets"],
		desc = L["Never display this status on pets."],
		order = 9,
		get = function () return not status.dbx.missingPets end,
		set = function (_, v)
			status.dbx.missingPets = not v or nil
			status:Refresh()
		end,
		hidden = function() return not status.dbx.missing end,
	}
end

-- Grid2Options:MakeStatusAuraMaxDurationOptions()
function Grid2Options:MakeStatusAuraMaxDurationOptions(status, options, optionParams)
	if not status.dbx.missing then
		self:MakeHeaderOptions(options, "Duration")
		options.MaxDurationSelect = {
			type = "select",
			order = 106,
			width ="normal",
			name = L["Max Duration"],
			desc = L["Max Duration"],
			get = function() return	status.dbx.maxDuration and 2 or 1 end,
			set = function( _, v)
				status.dbx.maxDuration = v==2 and 12 or nil
				status:Refresh()
			end,
			values = DurationValues,
		}
		options.maxDurationValue = {
			type = "input",
			order = 107,
			name = L["Type Max Duration"],
			desc = L["Type the maximum duration for the aura in seconds."],
			width = "normal",
			get = function () return tostring(status.dbx.maxDuration) end,
			set = function (_, v)
				status.dbx.maxDuration = tonumber(v) or 12
				status:Refresh()
			end,
			hidden = function() return status.dbx.maxDuration==nil end,
		}
	end
end

-- Grid2Options:MakeStatusBlinkThresholdOptions()
do
	local VALUES = { L["Never"], L["Always"], L["Threshold"] }
	local function RefreshIndicatorsHighlight(status)
		for indicator in next, status.indicators do
			indicator:UpdateHighlight()
		end
	end
	function Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
		if not status.dbx.colorThreshold then
			self:MakeHeaderOptions(options, "Highlights")
			options.blinkEnabled = {
				type = "select",
				order = 111,
				name = L["Highlight"],
				desc = L["Select when to highlight the status. Linked indicators must have a hightlight effect configured."],
				get = function()
					return (status.dbx.blinkThreshold==nil and 1) or (status.dbx.blinkThreshold==0 and 2) or 3
				end,
				set = function(_,v)
					status.dbx.blinkThreshold = (v==3 and 1) or (v==2 and 0) or nil
					RefreshIndicatorsHighlight(status)
					status:Refresh()
					self:MakeStatusOptions(status)
				end,
				values = VALUES,
			}
			options.blinkThreshold = {
				type = "range",
				order = 112,
				name = L["Remaining seconds"],
				desc = L["Threshold in remaining seconds at which to highlight the status. The status will blink or glow depending of the linked indicator configuration."],
				min = 1,
				softMax = 30,
				step = 0.1,
				bigStep  = 1,
				get = function ()
					return status.dbx.blinkThreshold
				end,
				set = function (_, v)
					status.dbx.blinkThreshold = v
					status:Refresh()
				end,
				hidden = function() return (status.dbx.blinkThreshold or 0)<=0 end,
			}
		end
	end
end

function Grid2Options:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	options.changeSpell = {
		type = "input",
		order = 4,
		name = L["Aura Name or Spell ID"],
		desc = L["Change Buff/Debuff Name or Spell ID."],
		width = "normal",
		get = function() return tostring(status.dbx.spellName) end,
		set = function(info,text)
			text = tonumber(text) or text
			if strlen(text)>0 and text~=status.dbx.spellName then
				status.dbx.spellName = text
				status.dbx.useSpellId = (type(text)=="number") or nil
				status:UpdateDB()
				Grid2Options:MakeStatusOptions(status)
				Grid2Options:NotifyChange()
			end
		end,
	}
	options.useSpellId = {
		type = "toggle",
		name = L["Track by SpellId"],
		width = "normal",
		desc = string.format( "%s (%d) ", L["Track by spellId instead of aura name"], status.dbx.spellName ),
		order = 4.1,
		get = function () return status.dbx.useSpellId end,
		set = function (_, v)
			status.dbx.useSpellId = v or nil
			status:UpdateDB()
		end,
		hidden = function() return not tonumber(status.dbx.spellName) end,
	}
end

function Grid2Options:MakeStatusAuraCombineStacksOptions(status, options, optionParams)
	self:MakeHeaderOptions(options, "Combine")
	options.combineStacks = {
		type = "toggle",
		name = L["Combine Stacks"],
		width = "normal",
		desc = L["Multiple instances of the same debuff will be treated as multiple stacks of the same debuff."],
		order = 89.95,
		get = function () return status.dbx.combineStacks end,
		set = function (_, v)
			status.dbx.combineStacks = v or nil
			status:UpdateDB()
		end,
	}
end

function Grid2Options:MakeStatusAuraValueOptions(status, options, optionParams)
	if status.dbx.auras or status.dbx.missing then return end
	self:MakeHeaderOptions( options, "Value" )
	options.trackValue = {
		type = "select",
		order = 91,
		name = L["Value"],
		desc = L["AURAVALUE_DESC"],
		get = function() return status.dbx.valueIndex or 0 end,
		set = function( _, v)
				if v==0 then
					status.dbx.valueIndex = nil
					status.dbx.colorThresholdValue = nil
					status.dbx.text = (status.dbx.text~=1) and status.dbx.text or nil
				else
					status.dbx.valueIndex = v
				end
				status:UpdateDB()
				self:MakeStatusOptions(status)
		end,
		values = MonitorizeValues,
	}
	options.valueMax = {
		type = "range",
		order = 92,
		name = L["Maximum Value"],
		desc = L["Value used by bar indicators. Select zero to use players Maximum Health."],
		min = 0,
		softMax = 200000,
		bigStep = 1000,
		step = 1,
		get = function () return status.dbx.valueMax or 0 end,
		set = function (_, v)
			status.dbx.valueMax = v>0 and v or nil
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
		hidden = function() return not status.dbx.valueIndex end
	}
end

function Grid2Options:MakeStatusAuraTextOptions(status, options, optionParams)
	self:MakeHeaderOptions( options, "Text" )
	options.textType = {
		type = "select",
		order = 96,
		width ="normal",
		name = L["Text to Display"],
		desc = L['Text to display in Text Indicators.'],
		get = function() -- nil => aura name(2) / 1 => value(1) /  any text => custom text(3)
			local text = status.dbx.text or 2
			return type(text)=='number' and text or 3
		end,
		set = function( _, v)
			status.dbx.text = (v==3 and '') or (v~=2 and v) or nil
			status:UpdateDB()
		end,
		values = function() return status.dbx.valueIndex and TextValues1 or TextValues2 end,
	}
	options.textCustom = {
		type = "input",
		order = 97,
		name = L["Type Custom Text"],
		desc = L["Text to display in Text Indicators."],
		width = "normal",
		get = function() return status.dbx.text end,
		set = function(info,text)
			status.dbx.text = text
			status:UpdateDB()
		end,
		hidden = function() return type(status.dbx.text)~='string' end,
	}
end

function Grid2Options:MakeStatusDebuffTypeColorsOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
end

function Grid2Options:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)
	self:MakeHeaderOptions( options, "DebuffFilter" )
	options.debuffFilter = {
		type = "input", dialogControl = "Grid2ExpandedEditBox",
		order = 180,
		width = "full",
		name = "",
		multiline = status.dbx.debuffFilter and math.max(#status.dbx.debuffFilter,3) or 3,
		get = function()
				if status.dbx.debuffFilter then
					local debuffs= {}
					for name in next,status.dbx.debuffFilter do
						debuffs[#debuffs+1] = name
					end
					return table.concat( debuffs, "\n" )
				end
		end,
		set = function(_, v)
			local debuffs= { strsplit("\n,", v) }
			if next(debuffs) then
				if status.dbx.debuffFilter then
					wipe(status.dbx.debuffFilter)
				else
					status.dbx.debuffFilter = {}
				end
				for _,debuff in pairs(debuffs) do
					debuff = strtrim(debuff)
					if #debuff>0 then
						debuff = tonumber(debuff) and GetSpellInfo(debuff) or debuff
						status.dbx.debuffFilter[debuff] = true
					end
				end
			end
			if not next(status.dbx.debuffFilter) then
				status.dbx.debuffFilter = nil
			end
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}
end

function Grid2Options:MakeStatusAuraListOptions(status, options, optionParams)
	options.auraListAdd = {
		type = "input", dialogControl = (status.dbx.type=='buffs') and "EditBoxGrid2Buffs" or "EditBoxGrid2Debuffs",
		order = 500,
		width = 1.75,
		name = L["Name or SpellId"],
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
	}
	options.auraListUseSpellId = {
		type = "toggle",
		width = 0.75,
		name = L["Track by SpellId"],
		desc = L["If available use the spell identifier instead of the spell name to detect the auras."],
		order = 510,
		get = function() return status.dbx.useSpellId end,
		set = function(_,v)
			status.dbx.useSpellId = v or nil
			status:Refresh()
		end,
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

-- {{ Register
Grid2Options:RegisterStatusOptions("buff", "buff", function(self, status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusAuraColorsOptions(status, options, optionParams)
	self:MakeStatusAuraMissingOptions(status, options, optionParams)
	self:MakeStatusAuraEnableStacksOptions(status, options, optionParams)
	self:MakeStatusAuraMaxDurationOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusAuraValueOptions(status, options, optionParams)
	self:MakeStatusAuraTextOptions(status, options, optionParams)
end,{
	groupOrder = 10, isDeletable = true
})

Grid2Options:RegisterStatusOptions("debuff", "debuff", function(self, status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusAuraEnableStacksOptions(status, options, optionParams)
	self:MakeStatusAuraColorsOptions(status, options, optionParams)
	self:MakeStatusAuraCombineStacksOptions(status, options, optionParams)
	self:MakeStatusAuraMaxDurationOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusAuraValueOptions(status, options, optionParams)
	self:MakeStatusAuraTextOptions(status, options, optionParams)
end,{
	groupOrder = 30, isDeletable = true,
})

Grid2Options:RegisterStatusOptions("debuffType", "debuff", function(self, status, options, optionParams)
	self:MakeStatusDebuffTypeColorsOptions(status, options, optionParams)
	self:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)
end,{
	groupOrder = function(status) return (status.name=='debuff-Typeless' and 12) or (status.name=='debuff-Boss' and 10) or 11; end
} )

-- }}
