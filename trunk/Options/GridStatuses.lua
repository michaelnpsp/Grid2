--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local Grid2Blink = Grid2:GetModule("Grid2Blink")

local Grid2Options= Grid2Options

local BuffSubTypes= {
	["Buff"] =  1,
	["Buffs Group"] =  {},
	["Buffs Group: Defensive Cooldowns"] = { 
			6940,  --Hand of Sacrifice
			31850, --Ardent Defender
			498,   --Divine Protection
			86657, --Ancient Guardian (It the buff channeled by the Guardian of the Ancient Kings)
			-- War
			2565, --Shield Block
			871, --Shield Wall
			12975, --Last Stand
			--Druid
			61336, --Survival Instincts
			22812, --Barkskin
			22842, --Frenzied Regeneration
			--Dk
			55233, --Vampiric Blood
			49028, --Dancing Rune Weapon
			48792, --Icebound Fortitude
			48707, --Anti-Magic Shell
			--Priest
			33206, --Pain Suppression
			47788, --Guardian Spirit
	},
}

local DebuffSubTypes= {
	["Debuff"] =  1,
	["Debuffs Group"] =  {},
	["Debuffs Group: Healing Prevented "] = { 
		82170, -- Corrupcion absoluta (Chogall)
		82890, -- Mortalidad (Chimaeron)
		85576, -- Vientos fulminadores (Alakir)
		92787, -- Oscuridad engullidora (Maloriak Hc)
		76903, -- Prision antimagia (Void Seeker/Hall of Originations)
	},
	["Debuffs Group: Healing Reduced"] = { 
		83908, -- Golpes malevolos (Halfus)
		76727, -- Golpe mortal (Grim Batol)
		22687, -- Velo de sombras (Nefarian)
		93956, -- Velo maldito (Baron Silverlain/Shadowfang Keep)
		93675, -- Herida mortal (Lord Godfrey/Shadowfang Keep)
		75571, -- Golpe hiriente (Rom'ogg Bonecrusher/BlackRock Caverns)
	},
}

local ColorCountValues = {1,2,3,4,5,6,7,8,9}
local ColorizeByValues= { L["Number of stacks"] , L["Remaining time"] }

local Categories= {
	["health"]= "health",
	["health-current"]= "health",
	["health-deficit"]= "health",
	["heals-incoming"]= "health",
	["health-low"]= "health",
	["shields"] = "health",
	
	["mana"]= "mana",
	["lowmana"]= "mana",
	["poweralt"]= "mana",
	["power"]= "mana",
	
	["target"]= "target",
	["range"]= "target",
	["raid-icon-player"]= "target",
	["raid-icon-target"]= "target",
	["direction"]= "target",
	
	["role"]= "role",
	["leader"]= "role",
	["raid-assistant"]= "role",
	["master-looter"]= "role",
	["dungeon-role"]= "role",
	
	["threat"]= "combat",
	["banzai"]= "combat",
	["banzai-threat"]= "combat",
	["death"]= "combat",
	["feign-death"]= "combat",
	["charmed"]= "combat",
	["resurrection"]= "combat",
}

local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE

local targetIconOptionParams = {
	color1 = RAID_TARGET_1,
	color2 = RAID_TARGET_2,
	color3 = RAID_TARGET_3,
	color4 = RAID_TARGET_4,
	color5 = RAID_TARGET_5,
	color6 = RAID_TARGET_6,
	color7 = RAID_TARGET_7,
	color8 = RAID_TARGET_8,
}

local fmt= string.format
local HexDigits= "0123456789ABCDEF"
local prefixes= { "color-", "buff-", "debuff-", "aoe-" }
local suffixes= { "-mine", "-not-mine" }
local prefixes_colors = { 
	["buff-"]   = "|cFF00ff00%s|r",
	["debuff-"] = "|cFFff0000%s|r",
	["aoe-"]    = "|cFF0080ff%s|r",
	["color-"]  = "|cFFffff00%s|r",	
}
function Grid2Options.LocalizeStatus(status, RemovePrefix)

		local function byteToHex(byte)
			local L= byte % 16 + 1
			local H= math.floor( byte / 16 ) + 1
			return HexDigits:sub(H,H) .. HexDigits:sub(L,L)  
		end
		
		local function rgbToHex(c)
			return  byteToHex(math.floor(c.r*255)) .. byteToHex(math.floor(c.g*255)) .. byteToHex(math.floor(c.b*255))
		end		
		
		local function SplitStatusName(name)
			local prefix= ""
			local suffix= ""
			local body
			for _, value in ipairs(prefixes) do
				if strsub(name,1,strlen(value))==value then 
					prefix= value
					break
				end
			end
			for _, value in ipairs(suffixes) do
				if strsub(name,-strlen(value))==value then 
					suffix= value
					break
				end
			end
			body= strsub( name, strlen(prefix)+1, strlen(name)-strlen(suffix) )
			return prefix,body,suffix
		end
		
	local name= status.name
	local prefix,body,suffix= SplitStatusName(name)
	if RemovePrefix then
		prefix= ""
	end	
	if prefix=="color-" then
		body= "|cFF" .. rgbToHex(status.dbx.color1) .. L[body] .. "|r" 
	else
		body= L[body]
	end
	if prefix~="" then
		prefix= fmt( prefixes_colors[prefix] or "%s", L[prefix])
	end
	if suffix~="" then
		suffix= L[suffix]
	end
	return prefix .. body .. suffix	
end	

local function DeleteStatus(info)
	local status = info.arg.status
	local group = info.arg.group
	local baseKey = status.name

	-- Remove from status db
	Grid2.db.profile.statuses[baseKey]= nil
	
	-- Remove mappings from db
	for indicatorKey, indicator in Grid2:IterateIndicators() do
		if status.indicators[indicator] then
			Grid2:DbSetMap(indicatorKey ,baseKey, nil)
		end	
	end

	-- Remove status from runtime
	Grid2:UnregisterStatus(status)
	
	Grid2Frame:UpdateIndicators()

	if (group) then
		Grid2Options:DeleteElementSubType("statuses", group, baseKey)
	else
		Grid2Options:DeleteElement("statuses", baseKey)
	end
end

function Grid2Options:MakeStatusDeleteOptions(status, options, optionParams)
	options = options or {}
	local group = optionParams and optionParams.group

	if (options.delete) then
		options.delete.arg.status = status
		options.delete.arg.group = group
	else
		options.deleteSpacer = {
			type = "header",
			order = 200,
			name = "",
		}
		options.delete = {
			type = "execute",
			order = 255,
			name = L["Delete"],
			func = DeleteStatus,
			disabled = function() return (next(status.indicators)~=nil)	end,
			arg = {status = status, group = group},
		}
	end

	return options
end

function Grid2Options.GetStatusOpacity(info)
	local status = info.arg
	return status.dbx.opacity
end

function Grid2Options.SetStatusOpacity(info, a)
	local status = info.arg
	local dbx = Grid2.db.profile.statuses[status.name]

	status.dbx.opacity = a
	dbx.opacity = a

	local colorCount = status.dbx.colorCount or 1
	for i = 1, colorCount, 1 do
		local colorKey = "color" .. i
		local c = status.dbx[colorKey]
		c.a = a
		c = dbx[colorKey]
		c.a = a
	end

	Grid2Frame:UpdateIndicators()
end

function Grid2Options:MakeStatusOpacityOptions(status, options, optionParams)
	options = options or {}

	local name = optionParams and optionParams.opacity or L["Opacity"]
	local desc = optionParams and optionParams.opacityDesc or L["Set the opacity."]

	if (options.opacity) then
		options.opacity.arg = status
		options.opacity.name = name
		options.opacity.desc = desc
	else
		options.opacity = {
			type = "range",
			order = 101,
			name = name,
			desc = desc,
			min = 0,
			max = 1,
			step = 0.01,
			bigStep = 0.05,
			get = Grid2Options.GetStatusOpacity,
			set = Grid2Options.SetStatusOpacity,
			arg = status,
		}
	end

	return options
end

function Grid2Options.GetStatusColor(info)
	local status = info.arg.status
	local colorKey = "color"

	local colorIndex = info.arg.colorIndex
	colorKey = colorKey .. colorIndex

	local c = status.dbx[colorKey]
	return c.r, c.g, c.b, c.a
end

function Grid2Options.SetStatusColor(info, r, g, b, a)
	local passValue = info.arg
	local status = passValue.status
	local dbx = Grid2.db.profile.statuses[status.name] 
	local colorKey = "color"

	local colorIndex = passValue.colorIndex
	colorKey = colorKey .. colorIndex

	local c = status.dbx[colorKey]
	c.r, c.g, c.b, c.a = r, g, b, a

	c = dbx[colorKey]
	c.r, c.g, c.b, c.a = r, g, b, a
	
	if status.UpdateDB then status:UpdateDB() end
	
	for unit, guid in Grid2:IterateRosterUnits() do
		status:UpdateIndicators(unit)
	end
end

function Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = options or {}

	local colorCount = status.dbx.colorCount or 1
	local name  = L["Color"]
	local desc  = L["Color for %s."]:format(status.name)
	local width = optionParams and optionParams.width or "half"
	for i = 1, colorCount, 1 do
		local colorKey = "color" .. i
		if (optionParams and optionParams[colorKey]) then
			name = optionParams[colorKey]
		elseif (colorCount > 1) then
			name = L["Color %d"]:format(i)
		end

		local colorDescKey = "colorDesc" .. i
		if (optionParams and optionParams[colorDescKey]) then
			desc = optionParams[colorDescKey]
		elseif (colorCount > 1) then
			desc = name
		end

		options[colorKey] = {
			type = "color",
			order = (10 + i),
			width = width,
			name = name,
			desc = desc,
			get = Grid2Options.GetStatusColor,
			set = Grid2Options.SetStatusColor,
			hasAlpha = true,
			arg = {status = status, colorIndex = i },
		}
	end

	return options
end

function Grid2Options:MakeStatusClassFilterOptions(status, options, optionParams)
	options = options or {}

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
				if status.UpdateDB then
					status:UpdateDB()
				end
				for unit, guid in Grid2:IterateRosterUnits() do
					status:UpdateIndicators(unit)
				end
			end,
		}
	end

	return options
end

function Grid2Options:MakeStatusStandardOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)

	return options
end

function Grid2Options:MakeStatusThresholdOptions(status, options, optionParams, min, max, step)
	options = options or {}

	min = min or 0
	max = max or 1
	step = step or 0.01
	local name = optionParams and optionParams.threshold or L["Threshold"]
	local desc = optionParams and optionParams.thresholdDesc or L["Threshold at which to activate the status."]
	options.threshold = {
		type = "range",
		order = 20,
		name = name,
		desc = desc,
		min = min,
		max = max,
		step = step,
		get = function ()
			return status.dbx.threshold
		end,
		set = function (_, v)
			status.dbx.threshold = v
			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
	}
	return options
end

function Grid2Options:MakeStatusColorThresholdOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusThresholdOptions(status, options, optionParams)

	return options
end

function Grid2Options:MakeStatusHealthDeficitOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusThresholdOptions(status, options, optionParams)

	return options, "health"
end

function Grid2Options:MakeStatusRangeOptions(status, options, optionParams)
	options = options or {}

	local function GetAvailableRangeList()
		local result = {}
		local ranges = status.GetRanges()
		for range in pairs(ranges) do
			result[range] = fmt( L["%d yards"], tonumber(range) )
		end
		return result
	end

	options.default = {
		type = "range",
		order = 10,
		name = L["Default alpha"],
		desc = L["Default alpha value when units are way out of range."],
		min = 0,
		max = 1,
		step = 0.01,
		get = function () return status.dbx.default	end,
		set = function (_, v) status.dbx.default = v; status:UpdateDB()	end,
	}
	options.update = {
		type = "range",
		order = 20,
		name = L["Update rate"],
		desc = L["Rate at which the status gets updated"],
		min = 0,
		max = 5,
		step = 0.05,
		bigStep = 0.1,
		get = function () return status.dbx.elapsed	end,
		set = function (_, v) status.dbx.elapsed = v; status:UpdateDB()	end,
	}
	options.range = {
		type = "select",
		order = 30,
		name = L["Range"],
		desc = L["Range in yards beyond which the status will be lost."],
		get = function () return status.dbx.range and tostring(status.dbx.range) or "38" end,
		set = function (_, v) status.dbx.range = v; status:UpdateDB() end,
		values = GetAvailableRangeList,
	}
	return options, "target"
end

function Grid2Options:MakeStatusBanzaiOptions(status, options, optionParams)
	options = options or {}
	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options.update = {
		type = "range",
		order = 20,
		name = L["Update rate"],
		desc = L["Rate at which the status gets updated"],
		min = 0,
		max = 5,
		step = 0.05,
		bigStep = 0.1,
		get = function () return status.dbx.updateRate or 0.2 end,
		set = function (_, v) status:SetUpdateRate(v) end,
	}
	return options
end

function Grid2Options:MakeStatusShieldsOptions(status, options, optionParams)

	options = options or {}
	options = Grid2Options:MakeStatusColorOptions(status, options, {
		color1 = L["Normal"], colorDesc1 = L["Normal shield color"],
		color2 = L["Medium"], colorDesc2 = L["Medium shield color"],
		color3 = L["Low"],    colorDesc3 = L["Low shield color"],
	})
	options.spacer1 = { type = "header", order = 28, name = "", }	
	options.maxShieldAmount = {
		type = "range",
		order = 30,
		name = L["Maximum shield amount"],
		desc = L["Maximum shield amount value. Only used by bar indicators."],
		min = 0,
		softMax = 100000,
		bigStep = 100,
		step = 1,
		get = function () return status.dbx.maxShieldAmount or 30000 end,
		set = function (_, v) 
			status.dbx.maxShieldAmount = v  
			status:UpdateDB() 
		end,
	}
	options.thresholdMedium = {
		type = "range",
		order = 32,
		name = L["Medium shield threshold"],
		desc = L["The value below which a shield is considered medium."],
		min = 0,
		softMax = 100000,
		bigStep = 100,
		step = 1,
		get = function () return status.dbx.thresholdMedium end,
		set = function (_, v)
			   if status.dbx.thresholdLow > v then v = status.dbx.thresholdLow end
			   status.dbx.thresholdMedium = v  
			   status:UpdateDB()
		end,
	}
	options.thresholdLow = {
		type = "range",
		order = 34,
		name = L["Low shield threshold"],
		desc = L["The value below which a shield is considered low."],
		min = 0,
		softMax = 100000,
		bigStep = 100,
		step = 1,
		get = function () return status.dbx.thresholdLow end,
		set = function (_, v)
			   if status.dbx.thresholdMedium < v then v = status.dbx.thresholdMedium end
			   status.dbx.thresholdLow = v  
			   status:UpdateDB()
		end,
	}	
	if Grid2Blink.db.profile.type ~= "None" then
		options.blinkThreshold = {
			type = "range",
			order = 35,
			name = L["Blink Threshold"],
			desc = L["Blink Threshold at which to start blinking the status."],
			min = 0,
			softMax = 100000,
			bigStep = 100,
			step = 1,
			get = function () return status.dbx.blinkThreshold or 0	end,
			set = function (_, v)
				if v == 0 then v = nil end
				status.dbx.blinkThreshold = v
				status:UpdateDB()
			end,
		}
	end
	options.filter = {
		type = "group",
		order = 40,
		inline= true,
		name = L["shields"],
		args = {},
	}
	local dbx = status.dbx
	local shields = status:GetAvailableShields()
	for _,spellId in pairs(shields) do
		options.filter.args["shield"..spellId] = {
			type = "toggle",
			width = "normal",
			name = GetSpellInfo(spellId),
			get = function () return not (dbx.filtered and dbx.filtered[spellId]) end,
			set = function (_, value)
				if value then
					if dbx.filtered then
						dbx.filtered[spellId] = nil
						if not next(dbx.filtered) then dbx.filtered = nil end
					end	
				else
					if not dbx.filtered then dbx.filtered = {} end
					dbx.filtered[spellId] = true
				end
				status:UpdateDB()
			end,
		}
	end
	options.customShields = {
		type = "input",
		order = 120,
		width = "full",
		name = L["Custom Shields"], 
		desc = L["Type shield names separated by commas."],
		get = function () return status.dbx.customShields end,
		set = function (_, v)
			local shields = { strsplit( ",", strtrim(v, ", ")  ) }
			for i=1,#shields do
				local str  = strtrim(shields[i])
				shields[i] = tonumber(str) and GetSpellInfo(str) or str
			end
			status.dbx.customShields = table.concat(shields,",")
			status:UpdateDB()
		end,
	}

	return options
end

function Grid2Options:MakeStatusReadyCheckOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusThresholdOptions(status, options, optionParams, 1, 20, 1)

	return options
end

function Grid2Options:MakeStatusMissingOptions(status, options, optionParams)
	options = options or {}

	options.threshold = {
		type = "toggle",
		name = L["Show if missing"],
		desc = L["Display status only if the buff is not active."],
		order = 110,
		tristate = false,
		get = function ()return status.dbx.missing end,
		set = function (_, v)
			status.dbx.missing = v or nil
			if status.UpdateDB then status:UpdateDB() end
			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
	}

	return options
end

function Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	options = options or {}
	if Grid2Blink.db.profile.type ~= "None" and (not status.dbx.colorThreshold) then
		options.blinkThresholdSpacer = {
			type = "header",
			order = 30,
			name = "",
		}
		options.blinkThreshold = {
			type = "range",
			order = 31,
			width = "full",
			name = L["Blink Threshold"],
			desc = L["Blink Threshold at which to start blinking the status."],
			min = 0,
			max = 30,
			step = 0.1,
			get = function ()
				return status.dbx.blinkThreshold or 0
			end,
			set = function (_, v)
				if v == 0 then v = nil end
				status.dbx.blinkThreshold = v
				if status.UpdateDB then status:UpdateDB() end
			end,
		}
	end
	return options
end

local function MakeClassColorOption(status, options, type, translation)
	options.colors.args[type] = {
		type = "color",
		name = (L["%s Color"]):format(translation),
		get = function ()
			local c = status.dbx.colors[type] or status.dbx.colors[translation] or {r=1,g=1,b=1,a=1}
			return c.r, c.g, c.b, c.a
		end,
		set = function (_, r, g, b, a)
			local colorKey= status.dbx.colors[type] and type or translation
			local c = status.dbx.colors[colorKey] 
			c.r, c.g, c.b, c.a = r, g, b, a
			c = Grid2.db.profile.statuses[status.name].colors[colorKey]
			c.r, c.g, c.b, c.a = r, g, b, a
			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
	}
end

Grid2Options.RAID_CLASS_COLORS = RAID_CLASS_COLORS
function Grid2Options:MakeStatusClassColorOptions(status, options, optionParams)
	options = options or {}

	options.hostile = {
		type = "toggle",
		name = L["Color Charmed Unit"],
		desc = L["Color Units that are charmed."],
		width="full",
		order = 7,
		tristate = false,
		get = function () return status.dbx.colorHostile end,
		set = function (_, v) status.dbx.colorHostile = v or nil end,
	}
	options.colors = {
		type = "group",
		inline=true,
		name = L["Unit Colors"],
		args = {
			hostile = {
				type = "color",
				name = L["Charmed unit Color"],
				get = function ()
					local c = status.dbx.colors.HOSTILE
					return c.r, c.g, c.b, c.a
				end,
				set = function (_, r, g, b, a)
					local c = status.dbx.colors.HOSTILE
					c.r, c.g, c.b, c.a = r, g, b, a
					c = Grid2.db.profile.statuses[status.name].colors.HOSTILE
					c.r, c.g, c.b, c.a = r, g, b, a

					for unit, guid in Grid2:IterateRosterUnits() do
						status:UpdateIndicators(unit)
					end
				end,
			},
			defunit = {
				type = "color",
				name = L["Default unit Color"],
				get = function ()
					local c = status.dbx.colors.UNKNOWN_UNIT
					return c.r, c.g, c.b, c.a
				end,
				set = function (_, r, g, b, a)
					local c = status.dbx.colors.UNKNOWN_UNIT
					c.r, c.g, c.b, c.a = r, g, b, a
					c = Grid2.db.profile.statuses[status.name].colors.UNKNOWN_UNIT
					c.r, c.g, c.b, c.a = r, g, b, a

					for unit, guid in Grid2:IterateRosterUnits() do
						status:UpdateIndicators(unit)
					end
				end,
			},
			defpet = {
				type = "color",
				name = L["Default pet Color"],
				get = function ()
					local c = status.dbx.colors.UNKNOWN_PET
					return c.r, c.g, c.b, c.a
				end,
				set = function (_, r, g, b, a)
					local c = status.dbx.colors.UNKNOWN_PET
					c.r, c.g, c.b, c.a = r, g, b, a
					c = Grid2.db.profile.statuses[status.name].colors.UNKNOWN_PET
					c.r, c.g, c.b, c.a = r, g, b, a

					for unit, guid in Grid2:IterateRosterUnits() do
						status:UpdateIndicators(unit)
					end
				end,
			},
		},
	}

	for _, class in ipairs{"Beast", "Demon", "Humanoid", "Elemental"} do
		local translation = L[class]
		MakeClassColorOption(status, options, class, translation)
	end

	for class, translation in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		MakeClassColorOption(status, options, class, translation)
	end

	return options, "color"
end


function Grid2Options:MakeStatusCreatureColorOptions(status, options, optionParams)
	options = options or {}

	options.hostile = {
		type = "toggle",
		name = L["Color Charmed Unit"],
		desc = L["Color Units that are charmed."],
		width="full",
		order = 7,
		tristate = false,
		get = function () return status.dbx.colorHostile end,
		set = function (_, v) status.dbx.colorHostile = v or nil end,
	}
	options.colors = {
		type = "group",
		inline=true,
		name = L["Unit Colors"],
		args = {
			hostile = {
				type = "color",
				name = L["Charmed unit Color"],
				get = function ()
					local c = status.dbx.colors.HOSTILE
					return c.r, c.g, c.b, c.a
				end,
				set = function (_, r, g, b, a)
					local c = status.dbx.colors.HOSTILE
					c.r, c.g, c.b, c.a = r, g, b, a
					c = Grid2.db.profile.statuses[status.name].colors.HOSTILE
					c.r, c.g, c.b, c.a = r, g, b, a
					for unit, guid in Grid2:IterateRosterUnits() do
						status:UpdateIndicators(unit)
					end
				end,
			},
			defunit = {
				type = "color",
				name = L["Default unit Color"],
				get = function ()
					local c = status.dbx.colors.UNKNOWN_UNIT
					return c.r, c.g, c.b, c.a
				end,
				set = function (_, r, g, b, a)
					local c = status.dbx.colors.UNKNOWN_UNIT
					c.r, c.g, c.b, c.a = r, g, b, a
					c = Grid2.db.profile.statuses[status.name].colors.UNKNOWN_UNIT
					c.r, c.g, c.b, c.a = r, g, b, a

					for unit, guid in Grid2:IterateRosterUnits() do
						status:UpdateIndicators(unit)
					end
				end,
			},
		},
	}

	for _, class in ipairs{"Beast", "Demon", "Humanoid", "Elemental"} do
		local translation = L[class]
		MakeClassColorOption(status, options, class, translation)
	end

	return options, "color"
end

function Grid2Options:MakeStatusFriendColorOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)

	options.hostile = {
		type = "toggle",
		name = L["Color Charmed Unit"],
		desc = L["Color Units that are charmed."],
		width="full",
		order = 5,
		tristate = false,
		get = function () return status.dbx.colorHostile end,
		set = function (_, v) status.dbx.colorHostile = v or nil end,
	}
	return options, "color"
end

-- For a given indicator fill in and return
-- statusAvailable - available statuses that are not currently used
-- create or recycle as needed
function Grid2Options:GetAvailableStatusValues(indicator, statusAvailable)
	statusAvailable = statusAvailable or {}
	wipe(statusAvailable)
	
	for statusKey, status in Grid2:IterateStatuses() do
		if (Grid2:IsCompatiblePair(indicator, status) and status.name~="test") then
			statusAvailable[statusKey] = self.LocalizeStatus(status)
		end
	end
	
	for _, status in ipairs(indicator.statuses) do
		statusAvailable[status.name] = nil
	end

	return statusAvailable
end

local NewAuraUsageDescription= L["You can include a descriptive prefix using separators \"@#>\""] 
							   .. " ".. 
							   L["examples: Druid@Regrowth Chimaeron>Low Health"]	

local NewAuraHandlerMT = {
	Init = function (self)
		self.name = ""
		self.mine = 1
		self.colorCount= 1
		self.spellName= nil
	end,
	GetKey = function (self)
		local name = self.name:gsub("[ %.\"]", "")
		if name == "" then return end
		if self.type == "debuff" then
			return self.type.."-"..name
		else
			local mine = self.mine
			if mine == 2 then
				mine = "-not-mine"
			elseif mine then
				mine = "-mine"
			else
				mine = ""
			end
			return self.type.."-"..name..mine
		end	
	end,
	GetName = function (self)
		return self.name
	end,
	SetName = function (self, info, value)
		local spellName
		local prefix, spell= string.match(value, "^(.-[@#>])(.*)$")
		if not spell then
			spell, prefix = value, ""
		end	
		spellName= tonumber(spell) or spell
		if type(spellName)=="number" then
			spell= GetSpellInfo(spellName)
			if spell==nil then
				spell,spellName= "", nil
			end
		end
		self.spellName = spellName	
		self.name = prefix .. spell
	end,
	GetMine = function (self)
		return self.mine == 1
	end,
	SetMine = function (self, info, value)
		self.mine = value and 1
	end,
	GetNotMine = function (self)
		return self.mine == 2
	end,
	SetNotMine = function (self, info, value)
		self.mine = value and 2
	end,
	GetColorCount = function (self)
		return self.colorCount
	end,
	SetColorCount = function (self, info, value)
		self.colorCount = value
	end,
	GetAvailableSubTypes = function(self)
		local result= {}
		for k in pairs(self.subTypes) do
			result[k]= L[k]
		end
	    return result
	end,
	GetSubType= function(self)
		return self.subType
	end,
	SetSubType= function(self,info,value)
		self.subType= value
	end,
	Create = function (self)
		local baseKey = self:GetKey()
		if baseKey then
			--Add to options and runtime db 
			local dbx	
			if self.type == "debuff" then
				dbx = {type = self.type, spellName = self.spellName, color1 = self.color}
			else
				dbx = {type = self.type, spellName = self.spellName, mine = self.mine, color1 = self.color}
				if self.colorCount>1 then
					dbx.colorCount= self.colorCount
					for i = 2, self.colorCount do
						dbx["color"..i]= {r=1,g=1,b=1,a=1}
					end
				end
			end
			local subType= self.subTypes[self.subType]
			if type(subType) == "table" then -- Buffs or Debuffs Group
				dbx.auras= {}
				for i,v in pairs(subType) do
					dbx.auras[i]= v
				end
			end				
			Grid2.db.profile.statuses[baseKey]= dbx
			--Create the status
			local status = Grid2.setupFunc[dbx.type](baseKey, dbx)
			--Create the status options
			local funcMakeOptions = Grid2Options.typeMakeOptions[dbx.type]
			local optionParams = Grid2Options.optionParams[dbx.type]
			local options, subType = funcMakeOptions(Grid2Options, status, options, optionParams)--, nil, baseKey, statuses)
			if subType then
				Grid2Options:AddElementSubType("statuses", subType, status, options)
			elseif options then
				Grid2Options:AddElement("statuses", status, options)
			end
			self:Init()
		end
	end,
	IsDisabled = function (self)
		local key = self:GetKey() 
		if key and self.spellName then
			return not not Grid2.statuses[key]
		end
		return true
	end,
}
NewAuraHandlerMT.__index = NewAuraHandlerMT

local NewBuffHandler = setmetatable({type = "buff", subType="Buff", subTypes= BuffSubTypes, color = {r=1,g=1,b=1,a=1}}, NewAuraHandlerMT)

NewBuffHandler.options = {
	newStatusBuffType = {
		type = "select",
		order = 1,
		width="full",
		name = L["Select Type"],
		desc = L["Select Type"],
		get = "GetSubType",
		set = "SetSubType",
		values = "GetAvailableSubTypes",
		handler = NewBuffHandler,
	},
	newStatusBuffName = {
		type = "input",
		order = 2,
		width = "full",
		name = L["Name"],
		usage = NewAuraUsageDescription,
		get = "GetName",
		set = "SetName",
		handler = NewBuffHandler,
	},
	newStatusBuffMine = {
		type = "toggle",
		order = 3,
		name = L["Show if mine"],
		desc = L["Display status only if the buff was cast by you."],
		get = "GetMine",
		set = "SetMine",
		disabled = "GetNotMine",
		handler = NewBuffHandler,
	},
	newStatusBuffNotMine = {
		type = "toggle",
		order = 4,
		name = L["Show if not mine"],
		desc = L["Display status only if the buff was not cast by you."],
		get = "GetNotMine",
		set = "SetNotMine",
		disabled = "GetMine",
		handler = NewBuffHandler,
	},
	newStatusColorCount = {
		type = "select",
		order = 5,
		width="half",
		name = L["Color count"],
		desc = L["Select how many colors the status must provide."],
		get = "GetColorCount",
		set = "SetColorCount",
		values = ColorCountValues,
		handler = NewBuffHandler,
	},
	newStatusBuffSpacer = {
		type = "header",
		order = 9,
		name = "",
	},
	newStatusBuff = {
		type = "execute",
		order = 10,
		name = L["New Status"],
		desc = L["Create a new status."],
		func = "Create",
		disabled = "IsDisabled",
		handler = NewBuffHandler,
	},
}
NewBuffHandler:Init()

local NewDebuffHandler = setmetatable({type = "debuff", subType="Debuff", subTypes= DebuffSubTypes, color = {r=1,g=.2,b=.2,a=1}}, NewAuraHandlerMT)

NewDebuffHandler.options = {
	newStatusDebuffType = {
		type = "select",
		order = 1,
		width="full",
		name = L["Select Type"],
		desc = L["Select Type"],
		get = "GetSubType",
		set = "SetSubType",
		values = "GetAvailableSubTypes",
		handler = NewDebuffHandler,
	},
	newStatusDebuffName = {
		type = "input",
		order = 2,
		width = "full",
		name = L["Name"],
		usage = NewAuraUsageDescription,
		get = "GetName",
		set = "SetName",
		handler = NewDebuffHandler,
	},
	newStatusDebuff = {
		type = "execute",
		order = 10,
		name = L["New Status"],
		desc = L["Create a new status."],
		func = "Create",
		disabled = "IsDisabled",
		handler = NewDebuffHandler,
	},
}
NewDebuffHandler:Init()

-- Color statuses management

local NewColorOptions
do 
	local NewColorValue= {r=1,g=1,b=1,a=1}
	local NewColorName
	local function NewColorCreateStatus()
		--Save status in database
		local baseKey= "color-"..NewColorName
		local dbx = {type = "color", color1 = { r=NewColorValue.r, g=NewColorValue.g, b=NewColorValue.b, a=NewColorValue.a } }
		Grid2.db.profile.statuses[baseKey]= dbx
		--Create the status
		local status = Grid2.setupFunc["color"](baseKey, dbx)
		--Create the status options
		local funcMakeOptions = Grid2Options.typeMakeOptions["color"]
		local optionParams = Grid2Options.optionParams["color"]
		local options, subType = funcMakeOptions(Grid2Options, status, options, optionParams)
		Grid2Options:AddElementSubType("statuses", subType, status, options)
		--
		NewColorName= ""
	end
	local function NewColorDisabled()
		return not (NewColorName and (not Grid2.statuses["color-"..NewColorName]) )
	end
	NewColorOptions= {
	  newColorName={
			type = "input",
			order = 10,
			name = L["Name"],
			get = function() return NewColorName end,
			set = function(info,value) NewColorName= value:gsub("[ %.\"]", "") end
	  },
	  newColor= {
			type = "color",
			order = 20,
			width = "half",
			name = "Color",
			desc = "Color",
			hasAlpha = true,
			get = function() return NewColorValue.r, NewColorValue.g, NewColorValue.b, NewColorValue.a end,
			set = function(info,r,g,b,a) NewColorValue.r=r  NewColorValue.g=g  NewColorValue.b=b  NewColorValue.a=a end
	  },
	  newColorExecute= {
			type = "execute",
			order = 30,
			name = L["New Color"],
			desc = L["Create a new status."],
			func = NewColorCreateStatus,
			disabled= NewColorDisabled
		},
	}
end

function Grid2Options:MakeStatusColorStatusOptions(status, options, optionParams)
	options = options or {}
	options = self:MakeStatusColorOptions(status, options, optionParams)
	optionParams = optionParams or {}
	optionParams.group = optionParams.group or "color"
	options = self:MakeStatusDeleteOptions(status, options, optionParams)
	--Add as a subtype.
	return options, "color"
end

--Package a standard set of options for buffs
function Grid2Options:MakeStatusToggleOptions(status, options, optionParams, toggleKey)
	options = options or {}

	local name = optionParams and optionParams[toggleKey] or L[toggleKey] or toggleKey
	options[toggleKey] = {
		type = "toggle",
		name = name,
		tristate = false,
		get = function () return status.dbx[toggleKey] end,
		set = function (_, v)
			status.dbx[toggleKey] = v or nil
			if status.UpdateDB then status:UpdateDB() end
			Grid2Frame:UpdateIndicators()
		end,
	}

	return options
end

--Package a standard set of options for buffs
function Grid2Options:MakeStatusHealthCurrentOptions(status, options, optionParams)
	-- Ugly hack to upgrade status config in ace database
	if not status.dbx.colorCount or status.dbx.colorCount<3 then status.dbx.colorCount= 3 end	
	if not status.dbx.color2 then status.dbx.color2= { r=1,g=0.35,b=0,a=1 } end
	if not status.dbx.color3 then status.dbx.color3= { r=1,g=0,b=0,a=1 } end
	
	options = options or {}
	
	options = self:MakeStatusColorOptions(status, options, optionParams)
	options.spacer = {	type = "header", order = 100, name = "", }
	options = self:MakeStatusToggleOptions(status, options, optionParams, "quickHealth")
	options = self:MakeStatusToggleOptions(status, options, optionParams, "deadAsFullHealth")

	return options, "health"
end

function Grid2Options:MakeStatusAuraListOptions(status, options, optionParams)
	options= options or {}
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
			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
	}
	options.aurasSpacer= {
		type = "header",
		order = 2,
		name = "",
	}
	return options
end

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

function Grid2Options:MakeStatusAuraMissingOptions(status, options, optionParams)
	options = options or {}
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
			if status.UpdateDB then	status:UpdateDB() end
			self:MakeThisStatusOptions(status)
			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
	}
	return options
end

function Grid2Options:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	options = options or {}
	if tonumber(status.dbx.spellName) then
		options.useSpellIdHeader = { 
			type = "header", 
			order = 100, 
			name = L["Misc"], 
		}
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
	return options
end


function Grid2Options:MakeStatusAuraCommonOptions(status, options, optionParams)
	options = options or {}
	if not status.dbx.missing then
		options.colorCount = {
			type = "select",
			order = 1,
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
				self:MakeThisStatusOptions(status)
			end,
			values = ColorCountValues,
		}
		if status.dbx.colorCount then
			options.colorizeBy = {
				type = "select",
				order = 2,
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
						self:MakeThisStatusOptions(status)
				end,
				values = ColorizeByValues, 
			}
		end	
	end	
	options.headerSpacer= {
		type = "header",
		order = 9,
		name = L["Colors"],
	}
	return options
end

function Grid2Options:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	options = options or {}
	local thresholds = status.dbx.colorThreshold
	if thresholds then 
		local colorKey = L["Color"]
		options.colorThresholdSpacer= {
			type = "header",
			order = 50,
			name = L["Thresholds"],
		}
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
	return options
end


--Package a standard set of options for buffs
function Grid2Options:MakeStatusStandardBuffOptions(status, options, optionParams)
	options = options or {}

	if status.dbx.auras then
		options = self:MakeStatusAuraListOptions(status, options, optionParams)
	end
	
    options = self:MakeStatusAuraCommonOptions(status, options, optionParams)	
	options = self:MakeStatusAuraMissingOptions(status, options, optionParams)
	options = self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	options = self:MakeStatusColorOptions(status, options, optionParams)
	options = self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	options = self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	options = self:MakeStatusClassFilterOptions(status, options, optionParams)

	optionParams = optionParams or {}
	optionParams.group = optionParams.group or "buff"
	options = self:MakeStatusDeleteOptions(status, options, optionParams)

	--Add as a subtype.
	return options, "buff"
end

--Package a standard set of options for debuffs
function Grid2Options:MakeStatusStandardDebuffOptions(status, options, optionParams)
	options = options or {}
	
	if status.dbx.auras then
		options = self:MakeStatusAuraListOptions(status, options, optionParams)
	end	
	options = self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	options = self:MakeStatusColorOptions(status, options, optionParams)
	options = self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	options = self:MakeStatusClassFilterOptions(status, options, optionParams)

	optionParams = optionParams or {}
	optionParams.group = optionParams.group or "debuff"
	-- Avoid deleting generic debuffs: Magic, Curse, etc.
	if not status.debuffType then
		options = self:MakeStatusDeleteOptions(status, options, optionParams)
	end
	--Add as a subtype.
	return options, "debuff"
end


function Grid2Options:MakeStatusDebuffTypeOptions(status, options, optionParams)
	options = options or {}
	
	if status.dbx.auras then
		options = self:MakeStatusAuraListOptions(status, options, optionParams)
	end	
	options = self:MakeStatusColorOptions(status, options, optionParams)
	options = self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	options = self:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)

	optionParams = optionParams or {}
	optionParams.group = optionParams.group or "debuff"
	-- Avoid deleting generic debuffs: Magic, Curse, etc.
	if not status.debuffType then
		options = self:MakeStatusDeleteOptions(status, options, optionParams)
	end
	--Add as a subtype.
	return options, "debuff"
end

function Grid2Options:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)
	options= options or {}
	options.debuffFilter = {
		type = "input",
		order = 50,
		width = "full",
		name = L["Filtered debuffs"],
		desc = L["Listed debuffs will be ignored."],
		multiline= status.dbx.debuffFilter and math.max(#status.dbx.debuffFilter,3) or 3,
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
			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
	}
	options.aurasSpacer= {
		type = "header",
		order = 2,
		name = "",
	}
	return options
end

function Grid2Options:MakeStatusHealsIncomingOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusStandardOptions(status, options, optionParams)

	options.includePlayerHeals = {
		type = "toggle",
		order = 110,
		name = L["Include player heals"],
		desc = L["Display status for the player's heals."],
		tristate = false,
		get = function () return status.dbx.includePlayerHeals end,
		set = function (_, v)
			status.dbx.includePlayerHeals = v or nil
			Grid2.db.profile.statuses[status.name].includePlayerHeals = v
			status:UpdateDB()
		end,
	}

	options.healTypes = {
		type = "input",
		order = 120,
		width = "full",
		name = L["Minimum value"], 
		desc = L["Incoming heals below the specified value will not be shown."],
		get = function ()
			return tostring(status.dbx.flags or 0)
		end,
		set = function (_, v)
			status.dbx.flags = tonumber(v) or nil
			status:UpdateDB()
		end,
	}

	return options, "health"
end

function Grid2Options:MakeStatusTargetIconOptions(status, options, optionParams)
	options = options or {}

	options = self:MakeStatusStandardOptions(status, options, optionParams)
	if (options.opacity) then
		options.opacity.arg = status
	else
		options.opacity = {
			type = "range",
			order = 101,
			name = L["Opacity"],
			desc = L["Set the opacity / transparency of the status"],
			min = 0,
			max = 1,
			step = 0.01,
			get = function(info)
				local status = info.arg
				return status.dbx.opacity or false
			end,
			set = function(info, v) 
					local status = info.arg
					status.dbx.opacity = v
					Grid2.db.profile.statuses[status.name].opacity = v
					Grid2Frame:UpdateIndicators()
			end,
			arg = status,
		}
	end

	return options, "target"
end

function Grid2Options:MakeStatusDirectionOptions(status, options)
	options = options or {}
	options = self:MakeStatusStandardOptions(status, options)
	options.updateRate = {
		type = "range",
		order = 90,
		name = L["Update rate"],
		desc = L["Rate at which the status gets updated"],
		min = 0,
		max = 5,
		step = 0.1,
		get = function ()
			return status.dbx.updateRate or 0.2
		end,
		set = function (_, v)
			status.dbx.updateRate = v
			status:RestartTimer()
		end,
	}
	options.spacer = {
		type = "header",
		order = 99,
		name = L["Display"],
	}
	options.showOutOfRange = {
		type = "toggle",
		order = 100,
		name = L["Out of Range"],
		desc = L["Display status for units out of range."],
		tristate = false,
		get = function ()	return status.dbx.ShowOutOfRange end,
		set = function (_, v)
			status.dbx.ShowOutOfRange = v or nil
			status:UpdateDB()
		end,
	}
	options.showVisible = {
		type = "toggle",
		order = 110,
		name = L["Visible Units"],
		desc = L["Display status for units less than 100 yards away"],
		tristate = false,
		get = function () return status.dbx.ShowVisible end,
		set = function (_, v)
			status.dbx.ShowVisible = v or nil
			status:UpdateDB()
		end,
	}
	options.showDead = {
		type = "toggle",
		order = 120,
		name = L["Dead Units"],
		desc = L["Display status only for dead units"],
		tristate = false,
		get = function ()	return status.dbx.ShowDead end,
		set = function (_, v)
			status.dbx.ShowDead = v or nil
			status:UpdateDB()
		end,
	}
	return options, "target"
end

function Grid2Options:MakeStatusRaidDebuffsOptions(status, options, optionParams)
	options = options or {}
	options = self:MakeStatusStandardOptions(status, options, optionParams)
	options = self:MakeStatusMissingOptions(status, options, optionParams)
	options = self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	return options
end


function Grid2Options:MakeStatusThreatOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)

	options.separator= {
		type = "header",
		order = 25,
		name = "",
	}
	options.disableBlink= {
		type = "toggle",
		name = L["Disable Blink"],
		desc = L["Disable Blink"],
		width = "full",
		order = 30,
		get = function () return status.dbx.disableBlink end,
		set = function (_, v) 
			status.dbx.disableBlink = v or nil 
			status:UpdateDB()
		end,
	}
	
	return options
end

-- No options for the status
function Grid2Options:MakeStatusNoOptions(status, options, optionParams)
end

-- Create/Recreate optoins for the specified status
function Grid2Options:MakeThisStatusOptions(status, dbx )
	local type   = dbx and dbx.type or status.dbx.type
	local func   = self.typeMakeOptions[type] or self.MakeStatusStandardOptions 
	local params = self.optionParams[type]
	local options, subType = func(self, status, nil, params)
	if subType=="root" or Categories[status.name]=="root" then
		self:AddElement("statuses", status, options)
	else
		self:AddElementSubType("statuses", subType or Categories[status.name] or "misc", status, options)
	end	
end
			
-- General methods			
			
function Grid2Options:MakeStatusHandlers(reset)

	self:AddOptionHandler("buff", self.MakeStatusStandardBuffOptions )
	self:AddOptionHandler("debuff", self.MakeStatusStandardDebuffOptions )
	self:AddOptionHandler("debuffType", self.MakeStatusDebuffTypeOptions)

	self:AddOptionHandler("color", self.MakeStatusColorStatusOptions)
	self:AddOptionHandler("classcolor", self.MakeStatusClassColorOptions)
	self:AddOptionHandler("creaturecolor", self.MakeStatusCreatureColorOptions)
	self:AddOptionHandler("friendcolor", self.MakeStatusFriendColorOptions, {
		color1= L["Player color"],
		color2= L["Pet color"],
		color3= L["Charmed unit Color"],
	})
	
	self:AddOptionHandler("health-current", self.MakeStatusHealthCurrentOptions, {
			deadAsFullHealth = L["Show dead as having Full Health"],
			quickHealth= L["Instant Updates"],
			color1= L["Full Health"],
			color2= L["Medium Health"],
			color3= L["Low Health"],
	})
	self:AddOptionHandler("health-deficit", self.MakeStatusHealthDeficitOptions)
	self:AddOptionHandler("heals-incoming", self.MakeStatusHealsIncomingOptions)
	self:AddOptionHandler("health-low", self.MakeStatusColorThresholdOptions)
	self:AddOptionHandler("lowmana", self.MakeStatusColorThresholdOptions)
	self:AddOptionHandler("mana", self.MakeStatusColorOptions)
	self:AddOptionHandler("poweralt", self.MakeStatusColorOptions)
	self:AddOptionHandler("power", self.MakeStatusColorOptions, {
			color1 = L["Mana"],
			colorDesc1 = L["Mana"],
			color2 = L["Rage"],
			colorDesc2 = L["Rage"],
			color3 = L["Focus"],
			colorDesc3 = L["Focus"],
			color4 = L["Energy"],
			colorDesc4 = L["Energy"],
			color5 = L["Runic Power"],
			colorDesc5 = L["Runic Power"],
	})
	self:AddOptionHandler("name", self.MakeStatusNoOptions)
	self:AddOptionHandler("range", self.MakeStatusRangeOptions)
	self:AddOptionHandler("ready-check", self.MakeStatusReadyCheckOptions, {
			color1 = L["Waiting color"],
			colorDesc1 = L["Color for Waiting."],
			color2 = L["Ready color"],
			colorDesc2 = L["Color for Ready."],
			color3 = L["Not Ready color"],
			colorDesc3 = L["Color for Not Ready."],
			color4 = L["AFK color"],
			colorDesc4 = L["Color for AFK."],
			threshold = L["Delay"],
			thresholdDesc = L["Set the delay until ready check results are cleared."],
	})
	self:AddOptionHandler("role", self.MakeStatusStandardOptions, {
			color1 = MAIN_ASSIST,
			color2 = MAIN_TANK,
			width = "full",
	})
	
	self:AddOptionHandler("threat", self.MakeStatusThreatOptions, {
			color1 = L["Not Tanking"],
			colorDesc1 = L["Higher threat than tank."],
			color2 = L["Insecurely Tanking"],
			colorDesc2 = L["Tanking without having highest threat."],
			color3 = L["Securely Tanking"],
			colorDesc3 = L["Tanking with highest threat."],
			width= "full",
	})
	self:AddOptionHandler("resurrection", self.MakeStatusStandardOptions, {
			color1 = L["Casting resurrection"],
			colorDesc1 = L["A resurrection spell is being casted on the unit"],
			color2 = L["Resurrected"],
			colorDesc2 = L["A resurrection spell has been casted on the unit"],
			width = "full",
	})
	self:AddOptionHandler("raid-icon-player", self.MakeStatusTargetIconOptions, targetIconOptionParams)
	self:AddOptionHandler("raid-icon-target", self.MakeStatusTargetIconOptions, targetIconOptionParams)

	self:AddOptionHandler("banzai", self.MakeStatusBanzaiOptions)
	self:AddOptionHandler("banzai-threat", self.MakeStatusBanzaiOptions)
	
	self:AddOptionHandler("direction", self.MakeStatusDirectionOptions)
	
	self:AddOptionHandler("dungeon-role", self.MakeStatusStandardOptions, {
			color1 = LG["DAMAGER"],
			color2 = LG["HEALER"],
			color3 = LG["TANK"],
	})

	self:AddOptionHandler("shields", self.MakeStatusShieldsOptions)

	if not self.typeMakeOptions["raid-debuffs"] then
		self:AddOptionHandler("raid-debuffs", self.MakeStatusRaidDebuffsOptions)
	end

end

function Grid2Options:MakeGroupsOptions(reset)
	self:AddElementSubTypeGroup("statuses", "buff", "Buffs",  NewBuffHandler.options, reset)
	self:AddElementSubTypeGroup("statuses", "debuff", "Debuffs",  NewDebuffHandler.options, reset)
	self:AddElementSubTypeGroup("statuses", "color", "Colors",  NewColorOptions, reset)
	self:AddElementSubTypeGroup("statuses", "health", "Health&Heals",  {}, reset)
	self:AddElementSubTypeGroup("statuses", "mana", "Mana&Power",  {}, reset)
	self:AddElementSubTypeGroup("statuses", "combat", "Combat",  {}, reset)
	self:AddElementSubTypeGroup("statuses", "target", "Targeting&Distances",  {}, reset)
	self:AddElementSubTypeGroup("statuses", "role", "Raid&Party Roles",  {}, reset)
	self:AddElementSubTypeGroup("statuses", "misc", "Miscellaneous",  {}, reset)
end

function Grid2Options:MakeStatusOptions(reset)
	self:DeleteElement("statuses")

	if self.Initialize then  -- Create handlers only on first run
		self:MakeStatusHandlers(reset) 
	end

	self:MakeGroupsOptions(reset)

	local statuses= Grid2.db.profile.statuses
	for baseKey, dbx in pairs(statuses) do
		local status = Grid2.statuses[baseKey]
		if (status) then
			local funcMakeOptions = self.typeMakeOptions[dbx.type] or self.MakeStatusStandardOptions 
			local optionParams = self.optionParams[dbx.type]
			local options, subType = funcMakeOptions(self, status, options, optionParams)
			if subType=="root" or Categories[status.name]=="root" then
				self:AddElement("statuses", status, options)
			else
				self:AddElementSubType("statuses", subType or Categories[status.name] or "misc", status, options)
			end	
		else
			--print("    ***No status:", baseKey, "dbx:", dbx, "status:", status)
		end
	end
end

--{{ Publish some tables for plugins
Grid2Options.Categories = Categories
Grid2Options.BuffSubTypes = BuffSubTypes
Grid2Options.DebuffSubTypes = DebuffSubTypes
--}}