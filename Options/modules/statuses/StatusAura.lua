local L = Grid2Options.L

local ColorCountValues = {1,2,3,4,5,6,7,8,9}
local ColorizeByValues1= { L["Number of stacks"] , L["Remaining time"], L["Elapsed time"] }
local ColorizeByValues2= { L["Number of stacks"] , L["Remaining time"], L["Elapsed time"], L["Value"] }
local MonitorizeValues = { [0]= L["NONE"], [1] = L["Value1"], [2] = L["Value2"], [3] = L["Value3"] }
local TextValues1 = { [1] = L['Value Tracked'], [2] = L['Aura Name'], [3] = L['Custom Text'] }
local TextValues2 = { [2] = L['Aura Name'], [3] = L['Custom Text'] }

local function StatusAuraGenerateColors(status, newCount)
	local oldCount = status.dbx.colorCount or 1
	for i=oldCount+1,newCount do
		status.dbx["color"..i] = { r=1, g=1, b=1, a=1 }
	end
	for i=newCount+1,oldCount do
		status.dbx["color"..i] = nil
	end
	status.dbx.colorCount = newCount>1 and newCount or nil
end

local function StatusAuraGenerateColorThreshold(status)
	if status.dbx.colorCount then
		local newCount   = status.dbx.colorCount - 1
		local thresholds = status.dbx.colorThreshold or {}
		local oldCount   = #thresholds
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
	end
end

function Grid2Options:MakeStatusAuraEnableStacksOptions(status, options, optionParams)
	if not status.dbx.missing then
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
				status:Refresh(true)
			end,
		}
	end
end

function Grid2Options:MakeStatusAuraMissingOptions(status, options, optionParams)
	options.threshold = {
		type = "toggle",
		name = L["Show if missing"],
		desc = L["Display status only if the buff is not active."],
		order = 8,
		get = function () return status.dbx.missing end,
		set = function (_, v)
			status.dbx.missing = v or nil
			if v then
				StatusAuraGenerateColors(status,1)
				status.dbx.colorThreshold = nil
				status.dbx.valueIndex = nil
				status.dbx.enableStacks = nil
			end
			status:Refresh(true)
			self:MakeStatusOptions(status)
		end,
	}
end

-- Grid2Options:MakeStatusBlinkThresholdOptions()
function Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	if Grid2Frame.db.profile.blinkType ~= "None" and (not status.dbx.colorThreshold) then
		self:MakeHeaderOptions(options, "Thresholds")
		options.blinkThreshold = {
			type = "range",
			order = 51,
			name = L["Blink"],
			desc = L["Blink Threshold at which to start blinking the status."],
			min = 0,
			max = 30,
			step = 0.1,
			bigStep  = 1,
			get = function ()
				return status.dbx.blinkThreshold or 0
			end,
			set = function (_, v)
				if v == 0 then v = nil end
				status.dbx.blinkThreshold = v
				status:UpdateDB()
			end,
		}
	end
end

function Grid2Options:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeHeaderOptions(options, "Misc")
	options.useSpellId = {
		type = "toggle",
		name = L["Track by SpellId"],
		width = "normal",
		desc = string.format( "%s (%d) ", L["Track by spellId instead of aura name"], status.dbx.spellName ),
		order = 115,
		get = function () return status.dbx.useSpellId end,
		set = function (_, v)
			status.dbx.useSpellId = v or nil
			status:UpdateDB()
		end,
		hidden = function() return not tonumber(status.dbx.spellName) end,
	}
	options.changeSpell = {
		type = "input",
		order = 110,
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
end

function Grid2Options:MakeStatusAuraCommonOptions(status, options, optionParams)
	self:MakeHeaderOptions(options, "Colors")
	if not status.dbx.missing then
		options.colorCount = {
			type = "select",
			order = 10.1,
			width ="half",
			name = L["Color count"],
			desc = L["Select how many colors the status must provide."],
			get = function() return status.dbx.colorCount or 1 end,
			set = function(_,v)
				status.dbx.debuffTypeColorize = nil
				StatusAuraGenerateColors(status, v)
				if status.dbx.colorThreshold then
					StatusAuraGenerateColorThreshold(status)
				end
				status:UpdateDB()
				self:MakeStatusOptions(status)
			end,
			values = ColorCountValues,
		}
		if status.dbx.colorCount then
			options.colorizeBy = {
				type = "select",
				order = 10.2,
				width ="normal",
				name = L["Coloring based on"],
				desc = L["Coloring based on"],
				get = function()
					if status.dbx.colorThreshold then
						return  (status.dbx.colorThresholdValue and 4)   or
								(status.dbx.colorThresholdElapsed and 3) or 2
					else
						return 1
					end
				end,
				set = function( _, v)
						status.dbx.colorThreshold = nil
						status.dbx.colorThresholdElapsed = (v==3) and true or nil
						status.dbx.colorThresholdValue   = (v==4) and true or nil
						if v ~= 1 then StatusAuraGenerateColorThreshold(status) end
						status:UpdateDB()
						self:MakeStatusOptions(status)
				end,
				values = status.dbx.valueIndex and ColorizeByValues2 or ColorizeByValues1,
			}
			options.colorsSep = {  type = "description", order = 10.3, name = '' }
		elseif status.dbx.type == "debuffs" then
			options.debuffTypeColor = {
				type = "toggle",
				name = L["Use debuff Type color"],
				desc = L["Use the debuff Type color first. The specified color will be applied only if the debuff has no type."],
				order = 19,
				get = function () return status.dbx.debuffTypeColorize end,
				set = function (_, v)
					status.dbx.debuffTypeColorize = v or nil
					status:UpdateDB()
					status:UpdateAllUnits()
				end,
			}
		end
	end
end

function Grid2Options:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
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

function Grid2Options:MakeStatusAuraDescriptionOptions(status, options, optionParams)
	if status.dbx.auras or true then return end
	local spellID = tonumber(status.dbx.spellName)
	if not spellID then return end
	local tip = Grid2Options.Tooltip
	tip:ClearLines()
	tip:SetHyperlink("spell:"..spellID)
	local numLines = tip:NumLines()
	if numLines>1 and numLines<=10 then
		options.titleDesc = {
			type        = "description",
			order       = 1.2,
			fontSize    = "small",
			name        = tip[numLines]:GetText(),
		}
	end
end

function Grid2Options:MakeStatusAuraValueOptions(status, options, optionParams)
	if status.dbx.auras or status.dbx.missing then return end
	self:MakeHeaderOptions( options, "Value" )
	options.trackValue = {
		type = "select",
		order = 91,
		width ="half",
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

-- {{ Register
Grid2Options:RegisterStatusOptions("buff", "buff", function(self, status, options, optionParams)
	self:MakeStatusAuraDescriptionOptions(status, options)
	self:MakeStatusAuraCommonOptions(status, options, optionParams)
	self:MakeStatusAuraEnableStacksOptions(status, options, optionParams)
	self:MakeStatusAuraMissingOptions(status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusAuraValueOptions(status, options, optionParams)
	self:MakeStatusAuraTextOptions(status, options, optionParams)
end,{
	groupOrder = 10, isDeletable = true
})

Grid2Options:RegisterStatusOptions("debuff", "debuff", function(self, status, options, optionParams)
	self:MakeStatusAuraEnableStacksOptions(status, options, optionParams)
	self:MakeStatusAuraDescriptionOptions(status, options, optionParams)
	self:MakeStatusAuraCommonOptions(status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
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
	groupOrder = function(status) return status.name=='debuff-Typeless' and 15 or 10; end
} )

-- }}
