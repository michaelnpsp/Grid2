local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

function Grid2Options.GetStatusColor(info)
	local status = info.arg.status
	local colorKey = "color"

	local colorIndex = info.arg.colorIndex
	colorKey = colorKey .. colorIndex

	local c = status.db.profile[colorKey]
	return c.r, c.g, c.b, c.a
end

function Grid2Options.SetStatusColor(info, r, g, b, a)
	local status = info.arg.status
	local colorKey = "color"

	local colorIndex = info.arg.colorIndex
	colorKey = colorKey .. colorIndex

	local c = status.db.profile[colorKey]
	c.r, c.g, c.b, c.a = r, g, b, a

	Grid2:UpdateColorHandler(status)
	for guid, unitid in Grid2:IterateRoster() do
		status:UpdateIndicators(unitid)
	end
end

function Grid2Options:MakeStatusColorOption(status, options)
	local profile = status.db.profile
	local colorCount = profile.colorCount or 1
	options = options or {}

--print("MakeStatusColorOption", status.name, colorCount)

	local name = L["Color"]
	for i = 1, colorCount, 1 do
		if (colorCount > 1) then
			name = L["Color %d"]:format(i)
		end
		options["color" .. i] = {
			type = "color",
			order = (10 + i),
			width = "half",
			name = name,
			desc = L["Color for %s."]:format(status.name),
			get = Grid2Options.GetStatusColor,
			set = Grid2Options.SetStatusColor,
			hasAlpha = true,
			arg = {status = status, colorIndex = i},
		}
	end
	return options
end

function Grid2Options:MakeStatusClassFilterOption(status, options)
	options = options or {}
	options.classFilter = {
		type = "group",
		order = 20,
		name = L["Class Filter"],
		desc = L["Threshold at which to activate the status."],
		args = {},
	}

	local profile = status.db.profile
	for _, type in ipairs{
		"DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN",
		"PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
	} do
		options.classFilter.args[type] = {
			type = "toggle",
			name = L[type],
			desc = (L["Show on %s."]):format(L[type]),
			get = function ()
				return not (profile.classFilter and profile.classFilter[type])
			end,
			set = function (_, value)
				local on = not value
				if (on) then
					if (not profile.classFilter) then
						profile.classFilter = {}
					end
					profile.classFilter[type] = true
				else
					profile.classFilter[type] = nil
					if (not next(profile.classFilter)) then
						profile.classFilter = nil
					end
				end
				for guid, unitid in Grid2:IterateRoster() do
					status:UpdateIndicators(unitid)
				end
			end,
		}
	end
	return options
end


function Grid2Options:MakeStatusThresholdOption(status, options, min, max, step)
	min = min or 0
	max = max or 1
	step = step or 0.01

	options = options or {}
	options.threshold = {
		type = "range",
		order = 20,
		name = L["Threshold"],
		desc = L["Threshold at which to activate the status."],
		min = min,
		max = max,
		step = step,
		get = function ()
			return status.db.profile.threshold
		end,
		set = function (_, v)
			status.db.profile.threshold = v
			for guid, unitid in Grid2:IterateRoster() do
				status:UpdateIndicators(unitid)
			end
		end,
	}
	return options
end


function Grid2Options:MakeStatusMissingOption(status, options)
	options = options or {}
	options.threshold = {
		type = "toggle",
		name = L["Show if missing"],
		desc = L["Display status only if the buff is not active."],
		order = 110,
		get = function ()
			return status.db.profile.missing
		end,
		set = function (_, v)
			status.db.profile.missing = v
			for guid, unitid in Grid2:IterateRoster() do
				status:UpdateIndicators(unitid)
			end
		end,
	}
	return options
end


function Grid2Options:MakeStatusBlinkThresholdOption(status, options)
	options = options or {}
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
			return status.db.profile.blinkThreshold or 0
		end,
		set = function (_, v)
			if (v == 0) then
				v = nil
			end
			status.db.profile.blinkThreshold = v
			status:UpdateBlinkThreshold()
		end,
	}
	return options
end


local function MakeStatusClassColorOptions()
	local status = Grid2.statuses.classcolor
	local profile = status.db.profile
	local options = {
		hostile = {
			type = "toggle",
			name = L["Color Charmed Unit"],
			desc = L["Color Units that are charmed."],
			order = 1,
			get = function ()
				return profile.colorHostile
			end,
			set = function (_, v)
				profile.colorHostile = v
			end,
		},
		colors = {
			type = "group",
			name = L["Unit Colors"],
			args = {
				hostile = {
					type = "color",
					name = L["Charmed unit Color"],
					get = function ()
						local c = profile.colors.HOSTILE
						return c.r, c.g, c.b, c.a
					end,
					set = function (_, r, g, b, a)
						local c = profile.colors.HOSTILE
						c.r, c.g, c.b, c.a = r, g, b, a
						for guid, unitid in Grid2:IterateRoster() do
							status:UpdateIndicators(unitid)
						end
					end,
				},
				defunit = {
					type = "color",
					name = L["Default unit Color"],
					get = function ()
						local c = profile.colors.UNKNOWN_UNIT
						return c.r, c.g, c.b, c.a
					end,
					set = function (_, r, g, b, a)
						local c = profile.colors.UNKNOWN_UNIT
						c.r, c.g, c.b, c.a = r, g, b, a
						for guid, unitid in Grid2:IterateRoster() do
							status:UpdateIndicators(unitid)
						end
					end,
				},
				defpet = {
					type = "color",
					name = L["Default pet Color"],
					get = function ()
						local c = profile.colors.UNKNOWN_PET
						return c.r, c.g, c.b, c.a
					end,
					set = function (_, r, g, b, a)
						local c = profile.colors.UNKNOWN_PET
						c.r, c.g, c.b, c.a = r, g, b, a
						for guid, unitid in Grid2:IterateRoster() do
							status:UpdateIndicators(unitid)
						end
					end,
				},
			},
		},
	}
	for _, type in ipairs{
		"Beast", "Demon", "Humanoid", "Elemental",
		"DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN",
		"PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR",
	} do
		local translation = L[type]
		options.colors.args[type] = {
			type = "color",
			name = (L["%s Color"]):format(translation),
			get = function ()
				local c = profile.colors[translation]
				return c.r, c.g, c.b, c.a
			end,
			set = function (_, r, g, b, a)
				local c = profile.colors[translation]
				c.r, c.g, c.b, c.a = r, g, b, a
				for guid, unitid in Grid2:IterateRoster() do
					status:UpdateIndicators(unitid)
				end
			end,
		}
	end

	return options
end


-- For a given indicator fill in and return
-- statusAvailable - available statuses that are not currently used
-- create or recycle as needed
function Grid2Options:GetAvailableStatusValues(indicator, statusAvailable)
	statusAvailable = statusAvailable or {}
	wipe(statusAvailable)

	for statusKey, status in Grid2:IterateStatuses() do
		if (Grid2:IsCompatiblePair(indicator, status)) then
			statusAvailable[statusKey] = status.name
		end
	end

	local statusKey
	for _, status in ipairs(indicator.statuses) do
		statusKey = status.name
		statusAvailable[statusKey] = nil
	end

	return statusAvailable
end

function Grid2Options:RegisterIndicatorStatus(indicator, status)
	local indicators = Grid2.db.profile.setup.status
	if (not indicators[indicator.name]) then
		indicators[indicator.name] = {}
	end

	local indicatorStatuses = indicators[indicator.name]
	if (indicatorStatuses[status.name]) then
		Grid2:Print(string.format("WARNING ! Indicator %s already registered with status %s", indicator.name, status.name))
		return
	else
		indicatorStatuses[status.name] = 99
	end
end

function Grid2Options:UnregisterIndicatorStatus(indicator, status)
	local indicators = Grid2.db.profile.setup.status
	if (indicators[indicator.name]) then
		local indicatorStatuses = indicators[indicator.name]

		indicatorStatuses[status.name] = nil
	end
end



local function getBuffKey(name, mine)
	name = Grid2Options:GetValidatedName(name)
	if (name and name ~= "") then
		return "buff-" .. name .. (mine and "-mine" or "")
	else
		return nil
	end
end

local newStatusBuffName = ""
local function getNewStatusBuffNameValue()
	return newStatusBuffName
end
local function setNewStatusBuffNameValue(info, buffName)
	newStatusBuffName = buffName
end


local newStatusBuffMine = true
local function getNewStatusBuffMine()
	return newStatusBuffMine
end
local function setNewStatusBuffMine(info, mine)
	newStatusBuffMine = mine
end


local function NewStatusBuff()
	local statusKey = getBuffKey(newStatusBuffName, newStatusBuffMine)
	if (statusKey) then
		local data = {newStatusBuffName, newStatusBuffMine, nil, 1, 1, 1, 1}

		local buffs = Grid2.db.profile.setup.buffs
		buffs[statusKey] = data

		local status = Grid2:SetupStatusAuraBuff(statusKey, data)
		Grid2Options:AddAura("Buff", statusKey, unpack(data))
		Grid2Options:AddElementSubType("status", "buff", status, Grid2Options:MakeStatusStandardBuffOptions(status))
	end
end

local function NewStatusBuffDisabled()
	local statusKey = getBuffKey(newStatusBuffName, newStatusBuffMine)
	if (statusKey) then
		local buffs = Grid2.db.profile.setup.buffs
		if (not buffs[statusKey]) then
			return false
		end
	end
	return true
end

local function MakeStatusBuffCreateOptions(reset)
	local options = {
		newStatusBuffName = {
			type = "input",
			order = 1,
			width = "full",
			name = L["Name"],
			usage = L["<CharacterOnlyString>"],
			get = getNewStatusBuffNameValue,
			set = setNewStatusBuffNameValue,
		},
		newStatusBuffMine = {
			type = "toggle",
			order = 2,
			name = L["Show if mine"],
			desc = L["Display status only if the buff was cast by you."],
			get = getNewStatusBuffMine,
			set = setNewStatusBuffMine,
		},
		newStatusBuff = {
			type = "execute",
			order = 5,
			name = L["New Status"],
			desc = L["Create a new status."],
			func = NewStatusBuff,
			disabled = NewStatusBuffDisabled,
		},
	}
	return options
end



local newStatusDebuffName = ""

local function getDebuffKey(name)
	name = Grid2Options:GetValidatedName(name)
	if (name and name ~= "") then
		return "debuff-" .. name
	else
		return nil
	end
end

local function getNewStatusDebuffNameValue()
	return newStatusDebuffName
end

local function setNewStatusDebuffNameValue(info, debuffName)
	newStatusDebuffName = debuffName
end

local function NewStatusDebuff()
	local statusKey = getDebuffKey(newStatusDebuffName)
	if (statusKey) then
		local data = {newStatusDebuffName, 1, 0.1, 0.1, 1}

		local debuffs = Grid2.db.profile.setup.debuffs
		debuffs[statusKey] = data

		local status = Grid2:SetupAuraStatusDebuff(statusKey, data)
		Grid2Options:AddAura("Debuff", statusKey, unpack(data))
		Grid2Options:AddElementSubType("status", "debuff", status, Grid2Options:MakeStatusStandardDebuffOptions(status))
	end
end

local function NewStatusDebuffDisabled()
	local statusKey = getDebuffKey(newStatusDebuffName)
	if (statusKey) then
		local debuffs = Grid2.db.profile.setup.debuffs
		if (not debuffs[statusKey]) then
			return false
		end
	end
	return true
end

local function MakeStatusDebuffCreateOptions(reset)
	local options = {
		newStatusDebuffName = {
			type = "input",
			order = 1,
			width = "full",
			name = L["Name"],
			usage = L["<CharacterOnlyString>"],
			get = getNewStatusDebuffNameValue,
			set = setNewStatusDebuffNameValue,
		},
		newStatusDebuff = {
			type = "execute",
			order = 2,
			name = L["New Status"],
			desc = L["Create a new status."],
			func = NewStatusDebuff,
			disabled = NewStatusDebuffDisabled,
		},
	}
	return options
end



function ResetStatuses()
	local setup = Grid2.db.profile.setup
	Grid2:SetupDefaultStatus(setup)
	Grid2Frame:UpdateAllFrames()
	Grid2Options:AddSetupStatusesOptions(setup, true)
end

local function AddStatusesGroup(reset)
	local options = {
		resetStatuses = {
			type = "execute",
			order = 11,
			name = L["Reset Statuses"],
			desc = L["Reset statuses to defaults."],
			func = ResetStatuses,
		},
	}
	Grid2Options:AddElementGroup("status", options, 60, reset)
end


--Package a standard set of options for buffs
function Grid2Options:MakeStatusStandardBuffOptions(status, options)
	options = options or {}
	options = Grid2Options:MakeStatusColorOption(status)
	options = Grid2Options:MakeStatusMissingOption(status, options)
	options = Grid2Options:MakeStatusBlinkThresholdOption(status, options)
	options = Grid2Options:MakeStatusClassFilterOption(status, options)
	return options
end

--Package a standard set of options for debuffs
function Grid2Options:MakeStatusStandardDebuffOptions(status, options)
	options = options or {}
	options = Grid2Options:MakeStatusColorOption(status)
	options = Grid2Options:MakeStatusBlinkThresholdOption(status, options)
	options = Grid2Options:MakeStatusClassFilterOption(status, options)
	return options
end


function Grid2Options:AddSetupStatusesOptions(setup, reset)
	AddStatusesGroup(reset)
	local status, options

	for _, name in ipairs{
		"threat", "heals-incoming", "target", "voice",
	} do
		status = Grid2.statuses[name]
		if status then
			Grid2Options:AddElement("status", status, Grid2Options:MakeStatusColorOption(status))
		end
	end

	for _, name in ipairs{
		"debuff-Magic", "debuff-Curse", "debuff-Disease", "debuff-Poison",
	} do
		status = Grid2.statuses[name]
		if status then
			Grid2Options:AddElement("status", status, Grid2Options:MakeStatusStandardDebuffOptions(status))
		end
	end

	status = Grid2.statuses.charmed
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses.death
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses.lowmana
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		options = Grid2Options:MakeStatusThresholdOption(status, options)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses["health-low"]
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		options = Grid2Options:MakeStatusThresholdOption(status, options)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses["health-deficit"]
	if (status) then
		options = Grid2Options:MakeStatusThresholdOption(status)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses.offline
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses.pvp
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses["ready-check"]
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		options = Grid2Options:MakeStatusThresholdOption(status, options, 1, 20, 1)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses.role
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses.vehicle
	if (status) then
		options = Grid2Options:MakeStatusColorOption(status)
		Grid2Options:AddElement("status", status, options)
	end

	status = Grid2.statuses.classcolor
	options = MakeStatusClassColorOptions()
	Grid2Options:AddElement("status", status, options)

	options = MakeStatusBuffCreateOptions()
	Grid2Options:AddElementSubTypeGroup("status", "buff", options, reset)
	for statusKey, info in pairs(setup.buffs) do
		local status = Grid2.statuses[statusKey] -- TODO: fix names more better.  Type should not get baked in.
		if (status) then
			options = Grid2Options:MakeStatusStandardBuffOptions(status)
			Grid2Options:AddElementSubType("status", "buff", status, options)
		end
	end

	options = MakeStatusDebuffCreateOptions()
	Grid2Options:AddElementSubTypeGroup("status", "debuff", options, reset)
	for statusKey, info in pairs(setup.debuffs) do
		local status = Grid2.statuses[statusKey] -- TODO: fix names more better.  Type should not get baked in.
		if (status) then
			options = Grid2Options:MakeStatusStandardDebuffOptions(status)
			Grid2Options:AddElementSubType("status", "debuff", status, options)
		end
	end

	Grid2Options:AddElement("status", Grid2.statuses.health, {
		deadAsFullHealth = {
			type = "toggle",
			name = L["Show dead as having Full Health"],
			get = function ()
				return Grid2.statuses.health.db.profile.deadAsFullHealth
			end,
			set = function (_, v)
				Grid2.statuses.health.db.profile.deadAsFullHealth = v
			end,
		},
	})

	Grid2Options:AddElement("status", Grid2.statuses.range, {
		default = {
			type = "range",
			name = L["Default alpha"],
			desc = L["Default alpha value when units are way out of range."],
			min = 0,
			max = 1,
			step = 0.01,
			get = function ()
				return Grid2.statuses.range.db.profile.default
			end,
			set = function (_, v)
				Grid2.statuses.range.db.profile.default = v
			end,
		},
		update = {
			type = "range",
			name = L["Update rate"],
			desc = L["Rate at which the range gets updated"],
			min = 0,
			max = 5,
			step = 0.1,
			get = function ()
				return Grid2.statuses.range.db.profile.elapsed
			end,
			set = function (_, v)
				Grid2.statuses.range.db.profile.elapsed = v
			end,
		},
	})

end

Grid2Options:AddSetupStatusesOptions(Grid2.db.profile.setup)
