local L = Grid2Options.L

local ColorCountValues = {1,2,3,4,5,6,7,8,9}

local ColorizeByValues= { L["Number of stacks"] , L["Remaining time"] }

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
		local newCount   =  status.dbx.colorCount - 1
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

function Grid2Options:MakeStatusClassFilterOptions(status, options, optionParams)
	options.classFilter = {
		type = "group",
		order = 205,
		inline= true,
		name = L["Class Filter"],
		desc = L["Threshold at which to activate the status."],
		args = {},
	}
	for classType, className in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		options.classFilter.args[classType] = {
			type = "toggle",
			name = className,
			desc = (L["Show on %s."]):format(className),
			tristate = false,
			get = function ()
				return not (status.dbx.classFilter and status.dbx.classFilter[classType])
			end,
			set = function (_, value)
				local on = not value
				local dbx = status.dbx
				if (on) then
					if (not dbx.classFilter) then
						dbx.classFilter = {}
					end
					dbx.classFilter[classType] = true
				else
					if dbx.classFilter then
						dbx.classFilter[classType] = nil
						if (not next(dbx.classFilter)) then
							dbx.classFilter = nil
						end
					end	
				end
				status:UpdateDB()
				status:UpdateAllIndicators()
			end,
		}
	end
end

function Grid2Options:MakeStatusAuraListOptions(status, options, optionParams)
	if not status.dbx.auras then return end
	options.auras = {
		type = "input",
		order = 1,
		width = "full",
		name = L["Auras"],
		multiline= math.min(8,#status.dbx.auras),
		get = function()
				local auras= {}
				for _,aura in pairs(status.dbx.auras) do
					auras[#auras+1]= (type(aura)=="number") and GetSpellInfo(aura) or aura
				end
				return table.concat( auras, "\n" )
		end,
		set = function(_, v)
			wipe(status.dbx.auras)
			local auras= { strsplit("\n,", v) }
			for _,v in pairs(auras) do
				local aura= strtrim(v)
				if #aura>0 then
					table.insert(status.dbx.auras, tonumber(aura) or aura )
				end
			end	
			status:UpdateDB()
			status:UpdateAllIndicators()
		end,
	}
	self:MakeSpacerOptions(options, 10)  -- ORDER = 2
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
			end
			status:UpdateDB()
			status:UpdateAllIndicators()
			self:MakeStatusOptions(status)
		end,
	}
end

function Grid2Options:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	if not tonumber(status.dbx.spellName) then return end
	self:MakeHeaderOptions(options, "Misc")
	options.useSpellId = {
		type = "toggle",
		name = L["Track by SpellId"], 
		desc = string.format( "%s (%d) ", L["Track by spellId instead of aura name"], status.dbx.spellName ),
		order = 105,
		get = function () return status.dbx.useSpellId end,
		set = function (_, v)
			status.dbx.useSpellId = v or nil
			status:UpdateDB()
		end,
	}
end

function Grid2Options:MakeStatusAuraCommonOptions(status, options, optionParams)
	if not status.dbx.missing then
		options.colorCount = {
			type = "select",
			order = 5,
			width ="half",
			name = L["Color count"],
			desc = L["Select how many colors the status must provide."],
			get = function() return status.dbx.colorCount or 1 end,
			set = function(_,v) 
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
				order = 6,
				width ="normal",
				name = L["Coloring based on"],
				desc = L["Coloring based on"],
				get = function() return status.dbx.colorThreshold and 2 or 1 end,
				set = function( _, v) 
						if v == 1 then
							status.dbx.colorThreshold = nil
						else
							StatusAuraGenerateColorThreshold(status)
						end
						status:UpdateDB()
						self:MakeStatusOptions(status)
				end,
				values = ColorizeByValues, 
			}
		end	
	end
	self:MakeHeaderOptions(options, "Colors")
end

function Grid2Options:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	local thresholds = status.dbx.colorThreshold
	if thresholds then 
		self:MakeHeaderOptions(options, "Thresholds")
		local colorKey = L["Color"]
		for i=1,#thresholds do
			options[ "colorThreshold" .. i ] = {
				type = "range",
				order = 50+i,
				name = colorKey .. (i+1),
				desc = L["Threshold to activate Color"] .. (i+1),
				min = 0,
				max = 30,
				step = 0.1,
				bigStep = 1,
				get = function () return status.dbx.colorThreshold[i] end,
				set = function (_, v)
					local min = status.dbx.colorThreshold[i+1] or 0
					local max = status.dbx.colorThreshold[i-1] or 30
					if v>=min and v<=max then
						status.dbx.colorThreshold[i] = v
						status:UpdateDB()
					end	
				end,
			}
		end
	end
end

function Grid2Options:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)
	self:MakeSpacerOptions( options, 50 )
	options.debuffFilter = {
		type = "input",
		order = 50.5,
		width = "full",
		name = L["Filtered debuffs"],
		desc = L["Listed debuffs will be ignored."],
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
			status:UpdateAllIndicators()
		end,
	}
end

-- {{ Register
Grid2Options:RegisterStatusOptions("buff", "buff", function(self, status, options, optionParams)
	self:MakeStatusAuraListOptions(status, options, optionParams)
    self:MakeStatusAuraCommonOptions(status, options, optionParams)	
	self:MakeStatusAuraMissingOptions(status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusClassFilterOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)
end )

Grid2Options:RegisterStatusOptions("debuff", "debuff", function(self, status, options, optionParams)
	self:MakeStatusAuraListOptions(status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusClassFilterOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)
end )

Grid2Options:RegisterStatusOptions("debuffType", "debuff", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)
end,{
	groupOrder = 10
} )
-- }}
