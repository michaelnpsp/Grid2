-- Library of common/shared methods

local L = Grid2Options.L

-- Grid2Options:MakeStatusLoadOptions(status, options, optionParams)
do
	local UNIT_REACTIONS = {
		friendly = L['Friendly'],
		hostile  = L['Hostile'],
	}

	local GROUP_TYPES = {
		solo = L['Solo'],
		party = L['Party'],
		arena = L["Arena"],
		raid = L["Raid"],
	}

	local INSTANCE_TYPES = {
		none   = L["None"],
		pvp    = L["pvp"],
		lfr    = L["lfr"],
		flex   = L["flex"],
		mythic = L["mythic"],
		other  = L["other"],
	}

	local PLAYER_FACTIONS = {
		Alliance = L["Alliance"],
		Horde = L["Horde"],
		Neutral = L["Neutral"],
	}

	local PLAYER_CLASSES = {}
	for class, translation in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		local coord = CLASS_ICON_TCOORDS[class]
		PLAYER_CLASSES[class] =	string.format("|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:0:0:0:0:256:256:%f:%f:%f:%f:0|t%s",coord[1]*256,coord[2]*256,coord[3]*256,coord[4]*256,translation)
	end

	local CLASSES_SPECS = {}
	for classID = 1, 30 do
	  local info = C_CreatureInfo.GetClassInfo(classID)
	  if info then
		local class = info.classFile
		local coord = CLASS_ICON_TCOORDS[class]
		for index=GetNumSpecializationsForClassID(classID), 1,-1 do
			local _, specName, _, specIcon = GetSpecializationInfoForClassID(classID, index)
			CLASSES_SPECS[class..index] = string.format("|TInterface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES:0:0:0:0:256:256:%f:%f:%f:%f:0|t|T%s:0|t%s",coord[1]*256,coord[2]*256,coord[3]*256,coord[4]*256,specIcon,specName)
		end
	  end
	end

	local function RefreshStatusOptions(status)
		local name = Grid2Options.LocalizeStatus(status, true)
		local group = Grid2Options:GetStatusGroup(status)
		if status.suspended then
			group.order = group.order - 500
			group.name  = string.format('|cFF808080%s|r',name)
		else
			group.order = group.order + 500
			group.name  = name
		end
	end

	local function RefreshStatus(status)
		if status:RefreshLoad() then
			RefreshStatusOptions(status)
		end
	end

	local function SetFilterOptions( status, options, order, key, values, defValue, name, desc )
		local dbx    = status.dbx
		local filter = dbx.load and dbx.load[key]
		local multi  = filter and next(filter, next(filter))~=nil
		options[key] = {
			type = "toggle",
			name = name,
			desc = desc or name,
			order = order,
			get = function(info) return filter end,
			set = function(info)
				if multi then
					multi, filter, dbx.load[key] = nil, nil, nil
					if not next(dbx.load) then dbx.load = nil end
				elseif filter then
					multi = true
				elseif dbx.load then
					filter = { [defValue] = true }; dbx.load[key] = filter
				else
					filter = { [defValue] = true }; dbx.load = { [key] = filter }
				end
				RefreshStatus(status)
			end,
			disabled = function() return dbx.load and dbx.load.disabled end,
		}
		options[key..'1'] = {
			type = "select",
			name = name,
			desc = desc or name,
			order = order+1,
			get = function() return filter and next(filter) end,
			set = function(_,v)
				wipe(filter)[v] = true
				RefreshStatus(status)
			end,
			disabled = function() return not filter or dbx.load.disabled end,
			hidden   = function() return multi end,
			values   = values,

		}
		options[key..'2'] = {
			type = "multiselect",
			order = order+2,
			name = name,
			get = function(info, value) return filter[value] end,
			set = function(info, value)
				filter[value] = (not filter[value]) or nil
				RefreshStatus(status)
			end,
			hidden = function() return not multi end,
			disabled = function() return dbx.load and dbx.load.disabled end,
			values = values,
		}
		options[key.."3"] = {
			type = "description",
			name = "",
			order = order+3,
		}
	end

	function Grid2Options:MakeStatusLoadOptions(status, options, optionParams)
		options.Never = {
			type = "toggle",
			width = "full",
			name = L["Never"],
			desc = L["Never load this status"],
			order = 1,
			get = function(info) return status.dbx.load and status.dbx.load.disabled end,
			set = function(info, value)
				if value then
					if status.dbx.load==nil then status.dbx.load = {} end
					status.dbx.load.disabled = true
				else
					status.dbx.load.disabled = nil
					if not next(status.dbx.load) then status.dbx.load = nil end
				end
				RefreshStatus(status)
			end,
		}
		SetFilterOptions( status, options, 10,
			'playerClass',
			PLAYER_CLASSES,
			select(2,UnitClass('player')),
			L["Player Class"],
			L["Load the status only if your toon belong to the specified class."]
		)
		if not Grid2.isClassic then
			SetFilterOptions( status, options, 20,
				'playerClassSpec',
				CLASSES_SPECS,
				Grid2.playerClass..GetSpecialization(),
				L["Player Class&Spec"],
				L["Load the status only if your toon has the specified class and specialization."]
			)
		end
		SetFilterOptions( status, options, 30,
			'playerFaction',
			PLAYER_FACTIONS,
			(UnitFactionGroup('player')),
			L["Player Faction"],
			L["Load the status only if your toon belong to the specified faction."]
		)
		SetFilterOptions( status, options, 40,
			'groupType',
			GROUP_TYPES,
			'solo',
			L["Group Type"],
			L["Load the status only if you are in the specified group type."]
		)
		SetFilterOptions( status, options, 50,
			'instType',
			INSTANCE_TYPES,
			'none',
			L["Instance Type"],
			L["Load the status only if you are in the specified instance type."]
		)
		if status.handlerType then -- hackish to detect buff/debuff type statuses
			SetFilterOptions( status, options, 60,
				'unitReaction',
				UNIT_REACTIONS,
				'friendly',
				L["Unit Reaction"],
				L["Load the status only if the unit frame has the specified reaction towards the player."]
			)
			SetFilterOptions( status, options, 70,
				'unitClass',
				PLAYER_CLASSES,
				select(2,UnitClass('player')),
				L["Unit Class"],
				L["Load the status only if the unit frame belong to the specified class."]
			)
		end
	end
end

-- Grid2Options:MakeStatusDeleteOptions()
do
	local function DeleteStatus(info)
		local status   = info.arg.status
		local category = Grid2Options:GetStatusCategory(status)
		Grid2.db.profile.statuses[status.name] = nil
		Grid2:UnregisterStatus(status)
		Grid2Frame:UpdateIndicators()
		Grid2Options:DeleteStatusOptions(category, status)
		Grid2Options:SelectGroup('statuses', category)
	end
	function Grid2Options:MakeStatusDeleteOptions(status, options, optionParams)
		self:MakeHeaderOptions( options, "Delete")
		options.delete = {
			type = "execute",
			order = 500,
			width = "half",
			name = L["Delete"],
			desc = L["Delete this element"],
			func = DeleteStatus,
			confirm = function() return L["Are you sure you want to delete this status ?"] end,
			disabled = function() return next(status.indicators)~=nil or status:IsSuspended() end,
			arg = { status = status },
		}
		options.deletemsg = {
			type = "description", order = 510, fontSize = "small", width = "double", name = L["There are indicators linked to this status or the status is not enabled for this character."],
			hidden = function() return next(status.indicators)==nil and not status:IsSuspended() end,
		}
	end
end

-- Grid2Options:MakeStatusColorOptions()
do
	local function GetStatusColor(info)
		local c = info.arg.status.dbx["color"..(info.arg.colorIndex)]
		return c.r, c.g, c.b, c.a
	end
	local function SetStatusColor(info, r, g, b, a)
		local status = info.arg.status
		local c = status.dbx["color"..(info.arg.colorIndex)]
		c.r, c.g, c.b, c.a = r, g, b, a
		status:UpdateDB()
		status:UpdateAllUnits()
	end
	function Grid2Options:MakeStatusColorOptions(status, options, optionParams)
		local colorCount = status.dbx.colorCount or 1
		local name  = L["Color"]
		local desc  = L["Color for %s."]:format(status.name)
		local width = optionParams and optionParams.width or "half"
		for i = 1, colorCount do
			local colorKey = "color" .. i
			if optionParams and optionParams[colorKey] then
				name = optionParams[colorKey]
			elseif colorCount > 1 then
				name = L["Color %d"]:format(i)
			end
			local colorDescKey = "colorDesc" .. i
			if optionParams and optionParams[colorDescKey] then
				desc = optionParams[colorDescKey]
			elseif colorCount > 1 then
				desc = name
			end
			options[optionParams and optionParams.optionKey or colorKey] = {
				type = "color",
				order = (10 + i),
				width = width,
				name = name,
				desc = desc,
				get = GetStatusColor,
				set = SetStatusColor,
				hasAlpha = true,
				arg = {status = status, colorIndex = i },
			}
		end
	end
end

-- Grid2Options:MakeStatusColorThresholdOptions()
function Grid2Options:MakeStatusColorThresholdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusThresholdOptions(status, options, optionParams, nil, nil, nil, true)
end

-- Grid2Options:MakeStatusThresholdOptions()
function Grid2Options:MakeStatusThresholdOptions(status, options, optionParams, min, max, step, percent)
	options.threshold = {
		type = "range",
		order = 20,
		name = optionParams and optionParams.threshold or L["Threshold"],
		desc = optionParams and optionParams.thresholdDesc or L["Threshold at which to activate the status."],
		min = min or 0,
		max = max or 1,
		step = step or 0.01,
		isPercent = percent or nil,
		get = function ()
			return status.dbx.threshold
		end,
		set = function (_, v)
			status.dbx.threshold = v
			status:UpdateAllUnits()
		end,
	}
end

-- Grid2Options:MakeStatusToggleOptions()
function Grid2Options:MakeStatusToggleOptions(status, options, optionParams, toggleKey)
	local name = optionParams and optionParams[toggleKey] or L[toggleKey] or toggleKey
	options[toggleKey] = {
		type = "toggle",
		name = name,
		tristate = false,
		width = optionParams and optionParams.width or nil,
		get = function () return status.dbx[toggleKey] end,
		set = function (_, v)
			status.dbx[toggleKey] = v or nil
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}
end

-- Grid2Options:MakeStatusStandardOptions()
Grid2Options.MakeStatusStandardOptions = Grid2Options.MakeStatusColorOptions
