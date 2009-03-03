local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")


local function MakeStatusColorOption(status, options)
	options = options or {}
	options.color = {
		type = "color",
		order = 10,
		name = L["Color"],
		desc = L["Color for %s."]:format(status.name),
		get = function ()
			local c = status.db.profile.color
			return c.r, c.g, c.b, c.a
		end,
		set = function (_, r, g, b, a)
			local c = status.db.profile.color
			c.r, c.g, c.b, c.a = r, g, b, a
			local info = {
				status.name,
				true,
				r, g, b,
			}
			Grid2:SetupAuraBuffColorHandler(status, info)
			for unit in Grid2:IterateRoster(true) do
				status:UpdateIndicators(unit)
			end
		end,
		hasAlpha = true
	}
	return options
end


local function MakeStatusThresholdOption(status, options)
	options = options or {}
	options.threshold = {
		type = "range",
		order = 20,
		name = L["Threshold"],
		desc = L["Threshold at which to activate the status."],
		min = 0,
		max = 1,
		step = 0.01,
		get = function ()
			return status.db.profile.threshold
		end,
		set = function (_, v)
			status.db.profile.threshold = v
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
						for unit in Grid2:IterateRoster(true) do
							status:UpdateIndicators(unit)
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
						for unit in Grid2:IterateRoster(true) do
							status:UpdateIndicators(unit)
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
						for unit in Grid2:IterateRoster(true) do
							status:UpdateIndicators(unit)
						end
					end,
				},
			},
		},
	}
	for _, type in ipairs{
		LG["Beast"], LG["Demon"], LG["Humanoid"], LG["Elemental"],
		"DRUID", "PALADIN", "MAGE",
		"WARLOCK", "WARRIOR", "PRIEST",
		"SHAMAN", "ROGUE", "HUNTER",
	} do
		options.colors.args[type] = {
			type = "color",
			name = (L["%s Color"]):format(type),
			get = function ()
				local c = profile.colors[type]
				return c.r, c.g, c.b, c.a
			end,
			set = function (_, r, g, b, a)
				local c = profile.colors[type]
				c.r, c.g, c.b, c.a = r, g, b, a
				for unit in Grid2:IterateRoster(true) do
					status:UpdateIndicators(unit)
				end
			end,
		}
	end

	return options
end



function Grid2Options:GetStatusValues(indicator)
	local statusValues = {}

	for statusKey, status in Grid2:IterateStatuses() do
		if (Grid2:IsCompatiblePair(indicator, status)) then
			statusValues[statusKey] = status.name
		end
	end

	return statusValues
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



local newStatusName = ""

local function getNewStatusNameValue()
	return newStatusName
end

local function setNewStatusNameValue(info, customName)
	customName = Grid2Options:GetValidatedName(customName)
	newStatusName = customName
end

local function NewStatus()
	newStatusName = Grid2Options:GetValidatedName(newStatusName)
	if (newStatusName and newStatusName ~= "") then
---		local status = {relIndicator = nil, point = "TOPLEFT", relPoint = "TOPLEFT", x = 0, y = 0, name = newIndicatorName}
--		Grid2.db.profile.setup.indicators[newIndicatorName] = indicator
--		AddIndicatorOptions(newIndicatorName, indicator)
	end
end

local function NewStatusDisabled()
	newStatusName = Grid2Options:GetValidatedName(newStatusName)
	if (newStatusName and newStatusName ~= "") then
--		local statuses = Grid2.db.profile.setup.indicators
		if (not statuses[newStatusName]) then
			return false
		end
	end
	return true
end

function ResetStatuses()
	local setup = Grid2.db.profile.setup
	Grid2:SetupDefaultStatus(setup)
	Grid2Frame:UpdateAllFrames()
	Grid2Options:AddSetupStatusesOptions(setup, true)
end

local function AddStatusesGroup(reset)
	local options = {
		name = {
			type = "input",
			order = 1,
			width = "full",
			name = L["Name"],
			usage = L["<CharacterOnlyString>"],
			get = getNewStatusNameValue,
			set = setNewStatusNameValue,
		},
		newStatus = {
			type = "execute",
			order = 2,
			name = L["New Status"],
			desc = L["Create a new status."],
			func = NewStatus,
			disabled = NewStatusDisabled,
		},
		resetStatusesHeader = {
			type = "header",
			order = 10,
			name = "",
		},
		resetStatuses = {
			type = "execute",
			order = 11,
			name = L["Reset Statuses"],
			desc = L["Reset statuses to defaults."],
			func = ResetStatuses,
		},
	}
	Grid2Options:AddElementGroup("status", options, reset)
end

function Grid2Options:AddSetupStatusesOptions(setup, reset)
	AddStatusesGroup(reset)
	local status, options

	for _, name in ipairs{
		"aggro", "heals", "lowmana", "target", "voice",
		"debuff-Magic", "debuff-Curse", "debuff-Disease", "debuff-Poison",
	} do
		status = Grid2.statuses[name]
		if status then
			Grid2Options:AddElement("status", status, MakeStatusColorOption(status))
		end
	end

	status = Grid2.statuses.lowhealth
	options = MakeStatusColorOption(status)
	options = MakeStatusThresholdOption(status, options)
	Grid2Options:AddElement("status",  status, options)

	status = Grid2.statuses.healthdeficit
	options = MakeStatusThresholdOption(status)
	Grid2Options:AddElement("status",  status, options)

	status = Grid2.statuses.classcolor
	options = MakeStatusClassColorOptions()
	Grid2Options:AddElement("status",  status, options)

	for statusName, info in pairs(setup.buffs) do
		local status = Grid2.statuses["buff-"..statusName] -- TODO: fix names more better.  Type should not get baked in.
		if status then
			Grid2Options:AddElement("status", status, MakeStatusColorOption(status))
		end
	end
	for statusName, info in pairs(setup.debuffs) do
		local status = Grid2.statuses["debuff-"..statusName] -- TODO: fix names more better.  Type should not get baked in.
		if status then
			Grid2Options:AddElement("status", status, MakeStatusColorOption(status))
		end
	end

	Grid2Options:AddElement("status",  Grid2.statuses.health, {
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

	Grid2Options:AddElement("status",  Grid2.statuses.range, {
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
