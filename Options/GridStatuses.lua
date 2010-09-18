local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local DBL = LibStub:GetLibrary("LibDBLayers-1.0")

local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE


local layerValues
Grid2Options.statusLayers = {}
function Grid2Options.GetStatusLayerValues()
	if (not layerValues) then
		layerValues = {}
		for layer, index in pairs(DBL:GetLayerOrder(Grid2.dblData, "statuses")) do
			local name = L[layer] or layer
			layerValues[index] = name
			Grid2Options.statusLayers[index] = layer
		end
	end
	return layerValues
end

function Grid2Options:MakeStatusLayerOptions(status, options)
	options = options or {}

	local baseKey = status.name
	options.layer = {
	    type = 'select',
		order = 5,
		name = L["Layer"],
		desc = L["Layer level.  Higher layers (like Class or Spec) supercede lower ones like Account."],
	    values = Grid2Options.GetStatusLayerValues,
		get = function ()
			local layer = DBL:GetObjectLayer(Grid2.dblData, "statuses", baseKey)
			local layerIndex = DBL:GetLayerOrder(Grid2.dblData, "statuses")[layer]
			return layerIndex
		end,
		set = function (info, value)
			local dblData = Grid2.dblData
			local newLayer
			for layer, index in pairs(DBL:GetLayerOrder(dblData, "statuses")) do
				if (index == value) then
					newLayer = layer
				end
			end
			DBL:SetObjectLayer(dblData, "statuses", baseKey, newLayer, status.dbx)
			DBL:FlattenSetupType(dblData, "statuses")

			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
	}
	options.layerSpacer = {
		type = "header",
		order = 6,
		name = "",
	}

	return options
end




local function DeleteStatus(info)
	local status = info.arg.status
	local group = info.arg.group
	local baseKey = status.name
	local dblData = Grid2.dblData

	-- Remove from options
	local layer = DBL:GetObjectLayer(Grid2.dblData, "statuses", baseKey)
	DBL:DeleteLayerObject(dblData, "statuses", layer, baseKey)
	DBL:FlattenSetupType(dblData, "statuses")

	-- Remove mappings
	for indicatorKey, indicator in Grid2:IterateIndicators() do
		Grid2Options:UnregisterIndicatorStatus(indicator, status)
	end

	Grid2Frame:ResetAllFrames()
	Grid2Frame:UpdateAllFrames()

	if (group) then
		Grid2Options:DeleteElementSubType("status", group, baseKey)
	else
		Grid2Options:DeleteElement("status", baseKey)
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
			order = 201,
			name = L["Delete"],
			func = DeleteStatus,
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
	local dbx = DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name)

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

	Grid2Frame:UpdateAllFrames()
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
	local dbx = DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name)
	local colorKey = "color"

	local colorIndex = passValue.colorIndex
	colorKey = colorKey .. colorIndex

	local c = status.dbx[colorKey]
	c.r, c.g, c.b, c.a = r, g, b, a

	c = dbx[colorKey]
	c.r, c.g, c.b, c.a = r, g, b, a

	local privateColorHandler = passValue.privateColorHandler
	if (not privateColorHandler) then
		Grid2:MakeBuffColorHandler(status)
	end
	for unit, guid in Grid2:IterateRosterUnits() do
		status:UpdateIndicators(unit)
	end
end

function Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = options or {}

--print("MakeStatusColorOption", status.name, colorCount)
	local colorCount = status.dbx.colorCount or 1
	local name = L["Color"]
	local desc = L["Color for %s."]:format(status.name)
	local privateColorHandler = optionParams and optionParams.privateColorHandler
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
			width = "half",
			name = name,
			desc = desc,
			get = Grid2Options.GetStatusColor,
			set = Grid2Options.SetStatusColor,
			hasAlpha = true,
			arg = {status = status, colorIndex = i, privateColorHandler = privateColorHandler},
		}
	end

	return options
end

function Grid2Options:MakeStatusClassFilterOptions(status, options, optionParams)
	options = options or {}

	options.classFilter = {
		type = "group",
		order = 20,
		name = L["Class Filter"],
		desc = L["Threshold at which to activate the status."],
		args = {},
	}

	for classType, className in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		options.classFilter.args[classType] = {
			type = "toggle",
			name = className,
			desc = (L["Show on %s."]):format(className),
			tristate = true,
			get = function ()
				return not (status.dbx.classFilter and status.dbx.classFilter[classType])
			end,
			set = function (_, value)
				local on = not value
				local dbx = DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name)
				if (on) then
					if (not status.dbx.classFilter) then
						status.dbx.classFilter = {}
					end
					status.dbx.classFilter[classType] = true

					if (not dbx.classFilter) then
						dbx.classFilter = {}
					end
					dbx.classFilter[classType] = true
				else
					status.dbx.classFilter[classType] = nil
					if (not next(status.dbx.classFilter)) then
						status.dbx.classFilter = nil
					end

					dbx.classFilter[classType] = nil
					if (not next(dbx.classFilter)) then
						dbx.classFilter = nil
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
	options = Grid2Options:MakeStatusLayerOptions(status, options, optionParams)

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
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).threshold = v
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
	options = Grid2Options:MakeStatusLayerOptions(status, options, optionParams)

	return options
end

function Grid2Options:MakeStatusHealthDeficitOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusThresholdOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusLayerOptions(status, options, optionParams)

	return options
end

function Grid2Options:MakeStatusRangeOptions(status, options, optionParams)
	options = options or {}

	local function GetAvailableRangeList()
		local rangelist = {}
		for r in GridRange:AvailableRangeIterator() do
			rangelist[r] = L["%d yards"]:format(r)
		end
		return rangelist
	end

	options.default = {
		type = "range",
		order = 10,
		name = L["Default alpha"],
		desc = L["Default alpha value when units are way out of range."],
		min = 0,
		max = 1,
		step = 0.01,
		get = function ()
			return status.dbx.default
		end,
		set = function (_, v)
			status.dbx.default = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).default = v
		end,
	}
	options.update = {
		type = "range",
		order = 20,
		name = L["Update rate"],
		desc = L["Rate at which the range gets updated"],
		min = 0,
		max = 5,
		step = 0.1,
		get = function ()
			return status.dbx.elapsed
		end,
		set = function (_, v)
			status.dbx.elapsed = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).elapsed = v
		end,
	}
	options.range = {
		type = "select",
		order = 30,
		name = L["Range"],
		desc = L["Range in yards beyond which the status will be lost."],
		get = function ()
			return status.dbx.range
		end,
		set = function (_, v)
			status.dbx.range = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).range = v
			status:Grid_RangesUpdated()
			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
		values = GetAvailableRangeList(),
	}
	Grid2.RegisterMessage(options, "Grid_RangesUpdated", function () options.range.values = GetAvailableRangeList() end)

	return options
end

function Grid2Options:MakeStatusReadyCheckOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusThresholdOptions(status, options, optionParams, 1, 20, 1)
	options = Grid2Options:MakeStatusLayerOptions(status, options, optionParams)

	return options
end

function Grid2Options:MakeStatusMissingOptions(status, options, optionParams)
	options = options or {}

	options.threshold = {
		type = "toggle",
		name = L["Show if missing"],
		desc = L["Display status only if the buff is not active."],
		order = 110,
		tristate = true,
		get = function ()
			return status.dbx.missing
		end,
		set = function (_, v)
			status.dbx.missing = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).missing = v
			if status.UpdateDB then
				status:UpdateDB()
			end
			for unit, guid in Grid2:IterateRosterUnits() do
				status:UpdateIndicators(unit)
			end
		end,
	}

	return options
end


function Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
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
			return status.dbx.blinkThreshold or 0
		end,
		set = function (_, v)
			if (v == 0) then
				v = nil
			end
			status.dbx.blinkThreshold = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).blinkThreshold = v
			if (status.UpdateDB) then
				status:UpdateDB()
			end
		end,
	}

	return options
end

local function MakeClassColorOption(status, options, type, translation)
	options.colors.args[type] = {
		type = "color",
		name = (L["%s Color"]):format(translation),
		get = function ()
			local c = status.dbx.colors[type]
			return c.r, c.g, c.b, c.a
		end,
		set = function (_, r, g, b, a)
			local c = status.dbx.colors[type]
			c.r, c.g, c.b, c.a = r, g, b, a
			c = DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).colors[type]
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

	options = Grid2Options:MakeStatusLayerOptions(status, options, optionParams)

	options.hostile = {
		type = "toggle",
		name = L["Color Charmed Unit"],
		desc = L["Color Units that are charmed."],
		order = 7,
		tristate = true,
		get = function ()
			return status.dbx.colorHostile
		end,
		set = function (_, v)
			status.dbx.colorHostile = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).colorHostile = v
		end,
	}
	options.colors = {
		type = "group",
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
					c = DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).colors.HOSTILE
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
					c = DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).colors.UNKNOWN_UNIT
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
					c = DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).colors.UNKNOWN_PET
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
		MakeClassColorOption(status, options, translation, translation)
	end

	for class, translation in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		MakeClassColorOption(status, options, class, translation)
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

local NewAuraHandlerMT = {
	Init = function (self)
		self.name = ""
		self.mine = 1
		self.layer = 1
	end,
	GetKey = function (self)
		local name = Grid2Options:GetValidatedName(self.name)
		if name == "" then return end
		local mine = self.mine
		if mine == 2 then
			mine = "-not-mine"
		elseif mine then
			mine = "-mine"
		else
			mine = ""
		end
		return self.type.."-"..name..mine
	end,
	GetName = function (self)
		return self.name
	end,
	SetName = function (self, info, value)
		self.name = value
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
	GetLayer = function (self)
		return self.layer
	end,
	SetLayer = function (self, info, value)
		self.layer = value
	end,
	Create = function (self)
		local baseKey = self:GetKey()
		if baseKey then
			--Add to options and runtime db
			local dblData = Grid2.dblData
			local dbx = {type = self.type, spellName = self.name, mine = self.mine, color1 = self.color}
			local layer = Grid2Options.statusLayers[self.layer]

			-- print("NewStatusBuff", layer, baseKey)
			DBL:SetupLayerObject(dblData, "statuses", layer, baseKey, dbx)
			DBL:FlattenSetupType(dblData, "statuses")

			--Create the status
			dbx = DBL:GetRuntimeDbx(dblData, "statuses", baseKey)
			local status = Grid2.setupFunc[dbx.type](baseKey, dbx)

			--Create the status options
			local funcMakeOptions = Grid2Options.typeMakeOptions[dbx.type]
			local optionParams = Grid2Options.optionParams[dbx.type]
			local options, subType = funcMakeOptions(self, status, options, optionParams)--, nil, baseKey, statuses)
			if subType then
				Grid2Options:AddElementSubType("status", subType, status, options)
			elseif options then
				Grid2Options:AddElement("status", status, options)
			end
			self:Init()
		end
	end,
	IsDisabled = function (self)
		local key = self:GetKey()
		if key then
			local statuses = DBL:GetRuntimeSetup(Grid2.dblData, "statuses")
			return not not statuses[key]
		end
		return true
	end,
}
NewAuraHandlerMT.__index = NewAuraHandlerMT

local NewBuffHandler = setmetatable({type = "buff", color = {r=1,g=1,b=1,a=1}}, NewAuraHandlerMT)

NewBuffHandler.options = {
	newStatusBuffName = {
		type = "input",
		order = 1,
		width = "full",
		name = L["Name"],
		usage = L["<CharacterOnlyString>"],
		get = "GetName",
		set = "SetName",
		handler = NewBuffHandler,
	},
	newStatusBuffMine = {
		type = "toggle",
		order = 2,
		name = L["Show if mine"],
		desc = L["Display status only if the buff was cast by you."],
		get = "GetMine",
		set = "SetMine",
		disabled = "GetNotMine",
		handler = NewBuffHandler,
	},
	newStatusBuffNotMine = {
		type = "toggle",
		order = 3,
		name = L["Show if not mine"],
		desc = L["Display status only if the buff was not cast by you."],
		get = "GetNotMine",
		set = "SetNotMine",
		disabled = "GetMine",
		handler = NewBuffHandler,
	},
	newBuffLayer = {
		type = 'select',
		order = 5,
		name = L["Layer"],
		desc = L["Layer level.  Higher layers (like Class or Spec) supercede lower ones like Account."],
		values = Grid2Options.GetStatusLayerValues,
		get = "GetLayer",
		set = "SetLayer",
		handler = NewBuffHandler,
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

local NewDebuffHandler = setmetatable({type = "debuff", color = {r=1,g=.2,b=.2,a=1}}, NewAuraHandlerMT)

NewDebuffHandler.options = {
	newStatusDebuffName = {
		type = "input",
		order = 1,
		width = "full",
		name = L["Name"],
		usage = L["<CharacterOnlyString>"],
		get = "GetName",
		set = "SetName",
		handler = NewDebuffHandler,
	},
	newDebuffLayer = {
		type = 'select',
		order = 5,
		name = L["Layer"],
		desc = L["Layer level.  Higher layers (like Class or Spec) supercede lower ones like Account."],
		values = Grid2Options.GetStatusLayerValues,
		get = "GetLayer",
		set = "SetLayer",
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

function ResetStatuses()
	local setup = Grid2.db.profile.setup
	Grid2:SetupDefaultStatus(setup)
	Grid2Frame:UpdateAllFrames()
	Grid2Options:MakeStatusOptions(setup, true)
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
function Grid2Options:MakeStatusToggleOptions(status, options, optionParams, toggleKey)
	options = options or {}

	local name = optionParams and optionParams[toggleKey] or L[toggleKey] or toggleKey
	options[toggleKey] = {
		type = "toggle",
		name = name,
		tristate = true,
		get = function ()
			return status.dbx[toggleKey]
		end,
		set = function (_, v)
			status.dbx[toggleKey] = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name)[toggleKey] = v

			Grid2Frame:UpdateAllFrames()
		end,
	}

	return options
end

--Package a standard set of options for buffs
function Grid2Options:MakeStatusHealthCurrentOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusLayerOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusToggleOptions(status, options, optionParams, "deadAsFullHealth")

	return options
end

--Package a standard set of options for buffs
function Grid2Options:MakeStatusStandardBuffOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusMissingOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusClassFilterOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusLayerOptions(status, options, optionParams)

	optionParams = optionParams or {}
	optionParams.group = optionParams.group or "buff"
	options = Grid2Options:MakeStatusDeleteOptions(status, options, optionParams)

	--Add as a subtype.
	return options, "buff"
end

--Package a standard set of options for debuffs
function Grid2Options:MakeStatusStandardDebuffOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusColorOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusClassFilterOptions(status, options, optionParams)
	options = Grid2Options:MakeStatusLayerOptions(status, options, optionParams)

	optionParams = optionParams or {}
	optionParams.group = optionParams.group or "debuff"
	options = Grid2Options:MakeStatusDeleteOptions(status, options, optionParams)

	--Add as a subtype.
	return options, "debuff"
end

function Grid2Options:MakeStatusHealsIncomingOptions(status, options, optionParams)
	options = options or {}

	options = Grid2Options:MakeStatusStandardOptions(status, options, optionParams)

	options.includePlayerHeals = {
		type = "toggle",
		order = 110,
		name = L["Include player heals"],
		desc = L["Display status for the player's heals."],
		tristate = true,
		get = function ()
			return status.dbx.includePlayerHeals
		end,
		set = function (_, v)
			status.dbx.includePlayerHeals = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", status.name).includePlayerHeals = v
			status:UpdateDB()
		end,
	}

	local HealComm = LibStub:GetLibrary("LibHealComm-4.0") -- we know it's available at this point

	options.healTypes = {
		type = "select",
		order = 120,
		width = "double",
		name = L["Type of Heals taken into account"],
		desc = L["Select the type of healing spell taken into account for the amount of incoming heals calculated."],
		get = function ()
			return status.dbx.flags
		end,
		set = function (_, v)
			local baseKey = status.name
			status.dbx.flags = v
			DBL:GetOptionsDbx(Grid2.dblData, "statuses", baseKey).flags = v
			if v == HealComm.ALL_HEALS then
				status.dbx.timeFrame = 4
				DBL:GetOptionsDbx(Grid2.dblData, "statuses", baseKey).timeFrame = 4
			else
				status.dbx.timeFrame = nil
				DBL:GetOptionsDbx(Grid2.dblData, "statuses", baseKey).timeFrame = nil
			end
			status:UpdateDB()
		end,
		values = {
			[HealComm.CASTED_HEALS] = L["Casted heals, both direct and channeled"],
			[HealComm.DIRECT_HEALS] = L["Direct heals only."],
			[HealComm.ALL_HEALS] = L["All heals, including casted and HoTs"],
		},
	}

	return options
end
			-- [HealComm.CASTED_HEALS] = L["Casted: Direct and Channeled"],
			-- [HealComm.DIRECT_HEALS] = L["Direct heals only."],
			-- [HealComm.ALL_HEALS] = L["All: Casted and HoTs"],


--No options for the status
function Grid2Options:MakeStatusNoOptions(status, options, optionParams)
end


function Grid2Options:MakeStatusHandlers(dblData, reset)
	self:AddOptionHandler("charmed", Grid2Options.MakeStatusStandardOptions)
	self:AddOptionHandler("classcolor", Grid2Options.MakeStatusClassColorOptions)

	self:AddOptionHandler("buff", Grid2Options.MakeStatusStandardBuffOptions)
	self:AddOptionHandler("debuff", Grid2Options.MakeStatusStandardDebuffOptions)
	self:AddOptionHandler("debuffType", Grid2Options.MakeStatusStandardDebuffOptions)

	self:AddOptionHandler("death", Grid2Options.MakeStatusStandardOptions)
	self:AddOptionHandler("feign-death", Grid2Options.MakeStatusStandardOptions)
	self:AddOptionHandler("health-current", Grid2Options.MakeStatusHealthCurrentOptions, {
			deadAsFullHealth = L["Show dead as having Full Health"],
	})
	self:AddOptionHandler("health-deficit", Grid2Options.MakeStatusHealthDeficitOptions)
	self:AddOptionHandler("heals-incoming", Grid2Options.MakeStatusHealsIncomingOptions)
	self:AddOptionHandler("health-low", Grid2Options.MakeStatusColorThresholdOptions)

	self:AddOptionHandler("lowmana", Grid2Options.MakeStatusColorThresholdOptions)
	self:AddOptionHandler("mana", Grid2Options.MakeStatusNoOptions)
	self:AddOptionHandler("name", Grid2Options.MakeStatusNoOptions)
	self:AddOptionHandler("offline", Grid2Options.MakeStatusStandardOptions)
	self:AddOptionHandler("pvp", Grid2Options.MakeStatusStandardOptions)
	self:AddOptionHandler("range", Grid2Options.MakeStatusRangeOptions)
	self:AddOptionHandler("ready-check", Grid2Options.MakeStatusReadyCheckOptions, {
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
	self:AddOptionHandler("role", Grid2Options.MakeStatusStandardOptions, {
			color1 = L["MAIN_ASSIST"],
			color2 = L["MAIN_TANK"],
	})
	self:AddOptionHandler("threat", Grid2Options.MakeStatusStandardOptions, {
			color1 = L["Not Tanking"],
			colorDesc1 = L["Higher threat than tank."],
			color2 = L["Insecurely Tanking"],
			colorDesc2 = L["Tanking without having highest threat."],
			color3 = L["Securely Tanking"],
			colorDesc3 = L["Tanking with highest threat."],
	})
	self:AddOptionHandler("target", Grid2Options.MakeStatusStandardOptions, {
			color1 = L["Your Target"],
	})
	self:AddOptionHandler("vehicle", Grid2Options.MakeStatusStandardOptions)
	self:AddOptionHandler("voice", Grid2Options.MakeStatusStandardOptions, {
			color1 = L["Voice Chat"],
			colorDesc1 = L["Voice Chat"],
	})

	Grid2Options:AddElementSubTypeGroup("status", "buff", NewBuffHandler.options, reset)
	Grid2Options:AddElementSubTypeGroup("status", "debuff", NewDebuffHandler.options, reset)
end

function Grid2Options:MakeStatusOptions(dblData, reset)
	AddStatusesGroup(reset)

	if(dblData==nil) then return end

	self:MakeStatusHandlers(dblData, reset)

--print("Grid2Options:MakeStatusOptions")
	local setup = DBL:GetRuntimeSetup(dblData, "statuses")
	local objects = DBL:GetOptionsObjects(dblData, "statuses")
	local statuses = DBL:GetOptionsSetup(dblData, "statuses")
	for baseKey, layer in pairs(setup) do
		local status = Grid2.statuses[baseKey]
		local dbx = objects[layer][baseKey]
--print("    Grid2Options:MakeStatusOptions", baseKey, layer, "type:", dbx.type)
		if (dbx and status) then
			local funcMakeOptions = Grid2Options.typeMakeOptions[dbx.type]
			if (funcMakeOptions) then
				local optionParams = Grid2Options.optionParams[dbx.type]
				local options, subType = funcMakeOptions(self, status, options, optionParams)--, nil, baseKey, statuses)
				if (subType) then
					Grid2Options:AddElementSubType("status", subType, status, options)
				elseif (options) then
					Grid2Options:AddElement("status", status, options)
				end
			else
print("    ***No Options function", baseKey, layer, "type:", dbx.type)
			end
		else
print("    ***No dbx / status:", baseKey, layer, "dbx:", dbx, "status:", status)
		end
	end
end

