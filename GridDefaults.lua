Grid2.healers = {
	DRUID = true,
	PALADIN = true,
	PRIEST = true,
	SHAMAN = true,
}

function Grid2:MakeDefaultSetup(setup, class)
	if (not setup) then
		setup = {}
	end

	if (not setup.locations) then
		self:SetupDefaultLocations(setup, class)
	end

	if (not self.db.account) then
		self.db.account = {}
	end
	if (not self.db.account.categories) then
		self.db.account.categories = {}
		self:SetupDefaultCategories(self.db.account.categories, class)
	end
	if (not setup.indicators) then
		setup.indicators = {}
		self:SetupDefaultIndicators(setup, class)
	end
	if (not setup.status) then
		setup.status = {}
		self:SetupDefaultStatus(setup, class)
	end
	if (not setup.buffs) then
		setup.buffs = {}
		setup.debuffs = {}
		self:SetupDefaultAuras(setup, class)
		self:SetupDebuffPriorities(setup, class)
	end

	return setup, class
end


local function SetupDefaultCategory(categories, categoryKey, categoryDefault)
	if (not categories[categoryKey]) then
		categories[categoryKey] = {priorities = {}}
	end
	local categoryInfo = categories[categoryKey]
	categoryInfo.name = categoryDefault.name
	local priorities = categoryInfo.priorities
	wipe(priorities)
	for statusKey, priority in pairs(categoryDefault.priorities) do
		priorities[statusKey] = priority
	end
end

-- Create the categories if necessary, otherwise reset the default ones only to their default values
function Grid2:SetupDefaultCategories(categories, class)
	SetupDefaultCategory(categories, "healing-impossible", {name = "healing-impossible", priorities = {death = 95, offline = 75}})
	SetupDefaultCategory(categories, "healing-prevented", {name = "healing-prevented", priorities = {charmed = 65}})
	SetupDefaultCategory(categories, "healing-reduced", {name = "healing-reduced", priorities = {}})
end

function Grid2:SetupDefaultLocations(setup, class)
	setup.locations = {
		["corner-top-left"] = {relIndicator = nil, point = "TOPLEFT", relPoint = "TOPLEFT", x = 1, y = -1, name = "corner-top-left"},
		["corner-top-right"] = {relIndicator = nil, point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -1, y = -1, name = "corner-top-right"},
		["corner-bottom-left"] = {relIndicator = nil, point = "BOTTOMLEFT", relPoint = "BOTTOMLEFT", x = 1, y = 1, name = "corner-bottom-left"},
		["corner-bottom-right"] = {relIndicator = nil, point = "BOTTOMRIGHT", relPoint = "BOTTOMRIGHT", x = -1, y = 1, name = "corner-bottom-right"},
		["side-left"] = {relIndicator = nil, point = "LEFT", relPoint = "LEFT", x = 1, y = 0, name = "side-left"},
		["side-right"] = {relIndicator = nil, point = "RIGHT", relPoint = "RIGHT", x = -1, y = 0, name = "side-right"},
		["side-top"] = {relIndicator = nil, point = "TOP", relPoint = "TOP", x = 0, y = -1, name = "side-top"},
		["side-bottom"] = {relIndicator = nil, point = "BOTTOM", relPoint = "BOTTOM", x = 0, y = 1, name = "side-bottom"},
		["center"] = {relIndicator = nil, point = "CENTER", relPoint = "CENTER", x = 0, y = 0, name = "center"},
		["center-left"] = {relIndicator = "center", point = "RIGHT", relPoint = "CENTER", x = 1, y = 0, name = "center-left"},
		["center-right"] = {relIndicator = "center", point = "LEFT", relPoint = "CENTER", x = -1, y = 0, name = "center-right"},
		["center-top"] = {relIndicator = "center", point = "BOTTOM", relPoint = "CENTER", x = 0, y = 4, name = "center-top"},
		["center-bottom"] = {relIndicator = "center", point = "TOP", relPoint = "CENTER", x = 0, y = -4, name = "center-bottom"},
	}
end


-- ToDo: choose between location & indicatorInfo specified location info.
-- ToDo: avoid duplicates, use existing one if under different type. Grid2.indicatorTypes

function Grid2:SetupIndicatorTypeLocation(setup, type, indicatorKey, locationKey, indicatorInfo)
	--link location if indicator does not have one yet.
	local indicatorLocations = setup.indicatorLocations
	if (not indicatorLocations) then
		indicatorLocations = {}
		setup.indicatorLocations = indicatorLocations
	end

	if (not indicatorLocations[indicatorKey]) then
		indicatorLocations[indicatorKey] = locationKey
	end

	--setup type
	if (not setup.indicators) then
		setup.indicators = {}
	end
	local indicatorType = setup.indicators[type]
	if (not indicatorType) then
		indicatorType = {}
		setup.indicators[type] = indicatorType
	end
	indicatorType[indicatorKey] = indicatorInfo
end

--[[
/dump Grid2.db.profile.setup.indicators.bar["bar-health"]
/dump Grid2.indicators["bar-health"].frameLevel
/script Grid2.db.profile.setup.indicators.bar["bar-health"][1] = 2; Grid2.db.profile.setup.indicators.bar["bar-heals"][1] = 1
--]]
function Grid2:SetupDefaultIndicators(setup, class)
	self:SetupIndicatorTypeLocation(setup, "bar", "bar-health", "center", {2, "CENTER"})
	self:SetupIndicatorTypeLocation(setup, "bar", "bar-heals", "center", {1, "CENTER"})

	self:SetupIndicatorTypeLocation(setup, "square", "corner-bottom-left", "corner-bottom-left", {7, "BOTTOMLEFT", "BOTTOMLEFT", 1, 1})
	self:SetupIndicatorTypeLocation(setup, "square", "corner-bottom-right", "corner-bottom-right", {7, "BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1})
	self:SetupIndicatorTypeLocation(setup, "square", "side-bottom", "side-bottom", {7, "BOTTOM", "BOTTOM", 0, 1})

	self:SetupIndicatorTypeLocation(setup, "icon", "icon-center", "center", {6, "CENTER"})

	self:SetupIndicatorTypeLocation(setup, "text", "name", "center-top", {5, "BOTTOM", "CENTER", 0, 4, nil})
	self:SetupIndicatorTypeLocation(setup, "text", "text-down", "center-bottom", {5, "TOP", "CENTER", 0, -4, nil})

	if (class == "DRUID") then
		self:SetupIndicatorTypeLocation(setup, "text", "regrowth", "side-top", {7, "TOP", "TOP", 0, -1, true})
		self:SetupIndicatorTypeLocation(setup, "text", "corner-top-left", "corner-top-left", {7, "TOPLEFT", "TOPLEFT", 1, -1, true})
		self:SetupIndicatorTypeLocation(setup, "text", "corner-top-right", "corner-top-right", {7, "TOPRIGHT", "TOPRIGHT", -1, -1, true})
		self:SetupIndicatorTypeLocation(setup, "icon", "icon-center-left", "center-left", {6, "CENTER"})
		self:SetupIndicatorTypeLocation(setup, "icon", "icon-center-right", "center-right", {6, "CENTER"})
	elseif (class == "PRIEST") then
		self:SetupIndicatorTypeLocation(setup, "square", "side-right", "side-right", {7, "RIGHT", "RIGHT", -1, 0})
		self:SetupIndicatorTypeLocation(setup, "square", "corner-top-left", "corner-top-left", {7, "TOPLEFT", "TOPLEFT", 1, -1})
		self:SetupIndicatorTypeLocation(setup, "square", "corner-top-right", "corner-top-right", {7, "TOPRIGHT", "TOPRIGHT", -1, -1})
	elseif (class == "SHAMAN") then
		self:SetupIndicatorTypeLocation(setup, "square", "side-left", "side-left", {7, "LEFT", "LEFT", 1, 0})
		self:SetupIndicatorTypeLocation(setup, "square", "corner-top-left", "corner-top-left", {7, "TOPLEFT", "TOPLEFT", 1, -1})
		self:SetupIndicatorTypeLocation(setup, "square", "corner-top-right", "corner-top-right", {7, "TOPRIGHT", "TOPRIGHT", -1, -1})
	else
		self:SetupIndicatorTypeLocation(setup, "square", "corner-top-left", "corner-top-left", {7, "TOPLEFT", "TOPLEFT", 1, -1})
		self:SetupIndicatorTypeLocation(setup, "square", "corner-top-right", "corner-top-right", {7, "TOPRIGHT", "TOPRIGHT", -1, -1})
	end
end


function Grid2:SetupIndicatorStatus(setupIndicator, indicatorKey, statusKey, priority)
	local statuses = setupIndicator[indicatorKey]
	if (not statuses) then
		statuses = {}
		setupIndicator[indicatorKey] = statuses
	end
	statuses[statusKey] = priority
end

function Grid2:SetupDefaultStatus(setup, class)
	local setupIndicator = setup.status

	self:SetupIndicatorStatus(setupIndicator, "name", "name", 99)
	self:SetupIndicatorStatus(setupIndicator, "name-color", "classcolor", 99)

	self:SetupIndicatorStatus(setupIndicator, "text-down", "feign-death", 96)
	self:SetupIndicatorStatus(setupIndicator, "text-down", "death", 95)
	self:SetupIndicatorStatus(setupIndicator, "text-down", "offline", 93)
	self:SetupIndicatorStatus(setupIndicator, "text-down", "charmed", 65)
	self:SetupIndicatorStatus(setupIndicator, "text-down", "heals-incoming", 55)
	self:SetupIndicatorStatus(setupIndicator, "text-down", "health-deficit", 50)
	self:SetupIndicatorStatus(setupIndicator, "text-down", "pvp", 45)

	self:SetupIndicatorStatus(setupIndicator, "text-down-color", "feign-death", 96)
	self:SetupIndicatorStatus(setupIndicator, "text-down-color", "death", 95)
	self:SetupIndicatorStatus(setupIndicator, "text-down-color", "offline", 93)
	self:SetupIndicatorStatus(setupIndicator, "text-down-color", "charmed", 65)
	self:SetupIndicatorStatus(setupIndicator, "text-down-color", "heals-incoming", 55)
	self:SetupIndicatorStatus(setupIndicator, "text-down-color", "pvp", 45)

	self:SetupIndicatorStatus(setupIndicator, "bar-health", "health", 99)
	self:SetupIndicatorStatus(setupIndicator, "bar-health-color", "classcolor", 99)
	self:SetupIndicatorStatus(setupIndicator, "bar-heals", "heals-incoming", 99)
	self:SetupIndicatorStatus(setupIndicator, "bar-heals-color", "heals-incoming", 99)

	self:SetupIndicatorStatus(setupIndicator, "border", "target", 99)
	self:SetupIndicatorStatus(setupIndicator, "border", "voice", 89)
	self:SetupIndicatorStatus(setupIndicator, "border", "lowmana", 79)
	self:SetupIndicatorStatus(setupIndicator, "border", "health-low", 69)
	self:SetupIndicatorStatus(setupIndicator, "border", "pvp", 45)

	self:SetupIndicatorStatus(setupIndicator, "corner-bottom-left", "aggro", 99)

	self:SetupIndicatorStatus(setupIndicator, "alpha", "death", 99)
	self:SetupIndicatorStatus(setupIndicator, "alpha", "range", 98)
	self:SetupIndicatorStatus(setupIndicator, "alpha", "offline", 97)
end

function Grid2:SetupDefaultAuras(setup, class)
	local setupIndicator = setup.status

	if (class == "DEATHKNIGHT") then
		setup.buffs["buff-HornOfWinter-mine"] = {57330, true, true, 0.1, 0.1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-HornOfWinter-mine", 99)
	elseif (class == "DRUID") then
		setup.buffs["buff-AbolishPoison-mine"] = {2893, true, nil, .9, 1, .6, 1}
		setup.buffs["buff-Lifebloom-mine"] = {33763, true, nil, .2, .7, .2, 1, .6, .9, .6, 1, 1, 1, 1, 1}
		setup.buffs["buff-Rejuv-mine"] = {774, true, nil, 1, 0, .6, 1}
		setup.buffs["buff-Regrowth-mine"] = {8936, true, nil, .5, 1, 0, 1}
		setup.buffs["buff-Thorns"] = {467, false, true, .2, .05, .05, 1}
		setup.buffs["buff-WildGrowth-mine"] = {53248, true, nil, .2, .9, .2, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-Lifebloom-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-left-color", "buff-Lifebloom-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "regrowth", "buff-Regrowth-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "regrowth-color", "buff-Regrowth-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-Rejuv-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right-color", "buff-Rejuv-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-AbolishPoison-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-WildGrowth-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-Thorns", 59)
	elseif (class == "MAGE") then
		setup.buffs["buff-AmplifyMagic"] = {33946, false, nil, 0, 0, 1, 1}
		setup.buffs["buff-DampenMagic"] = {33944, false, nil, .4, .2, 1, 1}
		setup.buffs["buff-FocusMagic"] = {54646, false, nil, .11, .22, .33, 1}
		setup.buffs["buff-IceArmor-mine"] = {7302, true, true, .2, .4, .4, 1}
		setup.buffs["buff-IceBarrier-mine"] = {11426, true, true, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-AmplifyMagic", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-DampenMagic", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-FocusMagic", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-IceArmor-mine", 79)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-IceBarrier-mine", 89)
	elseif (class == "PALADIN") then
		setup.buffs["buff-BeaconOfLight-mine"] = {53654, true, nil, 1, 1, 1, 1}
		setup.buffs["buff-DivineIntervention"] = {19752, false, nil, 1, 1, 1, 1}
		setup.buffs["buff-LightsBeacon-mine"] = {53651, true, nil, 1, 1, 1, 1}
		setup.buffs["buff-DivineShield-mine"] = {642, true, nil, 1, 1, 1, 1}
		setup.buffs["buff-DivineProtection-mine"] = {498, true, nil, 1, 1, 1, 1}
		setup.buffs["buff-HandOfProtection-mine"] = {1022, true, nil, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-BeaconOfLight-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-LightsBeacon-mine", 99)

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-DivineIntervention", 99)

		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-DivineIntervention", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-DivineShield-mine", 97)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-DivineProtection-mine", 95)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-HandOfProtection-mine", 93)

		setup.debuffs["debuff-Forbearance"] = {25771, false, 1, 0, 0, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "debuff-Forbearance", 89)
	elseif (class == "PRIEST") then
		setup.buffs["buff-Grace-mine"] = {47516, true, nil, .6, .6, .6, 1, .8, .8, .8, 1, 1, 1, 1, 1}
		setup.buffs["buff-DivineAegis"] = {47509, false, nil, 1, 1, 1, 1}
		setup.buffs["buff-InnerFire"] = {588, false, true, 1, 1, 1, 1}
		setup.buffs["buff-PrayerOfMending-mine"] = {33076, true, nil, 1, .2, .2, 1, 1, 1, .4, .4, 1, .6, .6, 1, 1, .8, .8, 1, 1, 1, 1, 1}
		setup.buffs["buff-PowerWordShield"] = {17, false, nil, 1, 1, 1, 1}
		setup.buffs["buff-Renew-mine"] = {139, true, nil, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-Renew-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-right", "buff-PrayerOfMending-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-PowerWordShield", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-DivineAegis", 79)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-InnerFire", 79)

		setup.debuffs["debuff-WeakenedSoul"] = {6788, false, 1, 0, 0, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "debuff-WeakenedSoul", 89)
	elseif (class == "ROGUE") then
		setup.buffs["buff-Evasion-mine"] = {5277, true, nil, 0.1, 0.1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-Evasion-mine", 99)
	elseif (class == "SHAMAN") then
		setup.buffs["buff-Riptide-mine"] = {61295, true, nil, .8, .6, 1, 1}
		setup.buffs["buff-Earthliving"] = {51945, false, nil, .8, 1, .5, 1}
		setup.buffs["buff-EarthShield"] = {974, false, nil, 0.8, 0.8, 0.2, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-Riptide-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-Earthliving", 89)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-EarthShield", 99)
	elseif (class == "WARLOCK") then
		setup.buffs["buff-ShadowWard-mine"] = {6229, true, nil, 1, 1, 1, 1}
		setup.buffs["buff-SoulLink-mine"] = {19028, true, nil, 1, 1, 1, 1}
		setup.buffs["buff-DemonArmor-mine"] = {706, true, nil, 1, 1, 1, 1}
		setup.buffs["buff-DemonSkin-mine"] = {696, true, nil, 1, 1, 1, 1}
		setup.buffs["buff-FelArmor-mine"] = {28189, true, nil, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-ShadowWard-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-SoulLink-mine", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-FelArmor-mine", 99)
	elseif (class == "WARRIOR") then
		setup.buffs["buff-BattleShout"] = {2048, true, nil, 0.1, 0.1, 1, 1}
		setup.buffs["buff-CommandingShout"] = {469, true, nil, 0.1, 0.1, 1, 1}
		setup.buffs["buff-LastStand"] = {12975, true, nil, 0.1, 0.1, 1, 1}
		setup.buffs["buff-ShieldWall"] = {871, true, nil, 0.1, 0.1, 1, 1}
		setup.buffs["buff-Vigilance"] = {50720, true, nil, 0.1, 0.1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-BattleShout", 89)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-CommandingShout", 79)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-Vigilance", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-LastStand", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-ShieldWall", 89)
	end
end

function Grid2:SetupDebuffPriorities(setup, class)
	local setupIndicator = setup.status

	if class == "DRUID" then
		self:SetupIndicatorStatus(setupIndicator, "icon-center-left", "debuff-Poison", 90)
		self:SetupIndicatorStatus(setupIndicator, "icon-center-right", "debuff-Curse", 90)
	elseif class == "MAGE" then
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Curse", 90)
	elseif class == "PALADIN" then
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Disease", 90)
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Magic", 80)
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Poison", 70)
	elseif class == "PRIEST" then
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Disease", 90)
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Magic", 80)
	elseif class == "SHAMAN" then
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Poison", 90)
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Disease", 80)
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Curse", 70)
	else
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Magic", 40)
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Poison", 30)
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Curse", 20)
		self:SetupIndicatorStatus(setupIndicator, "icon-center", "debuff-Disease", 10)
	end
end

function Grid2:SetupIndicators(setup)
	for indicatorKey, info in pairs(setup.indicators.bar) do
		self:CreateBarIndicator(indicatorKey, unpack(info))
	end
	local locationKey, location
	for indicatorKey, info in pairs(setup.indicators.square) do
		locationKey = setup.indicatorLocations[indicatorKey]
		location = setup.locations[locationKey]
		if (location) then
			info[2], info[3], info[4], info[5] = location.point, location.relPoint, location.x, location.y
		end

		self:CreateSquareIndicator(indicatorKey, unpack(info))
	end
	for indicatorKey, info in pairs(setup.indicators.icon) do
		locationKey = setup.indicatorLocations[indicatorKey]
		location = setup.locations[locationKey]
		if (location) then
			info[2], info[3], info[4], info[5] = location.point, location.relPoint, location.x, location.y
		end

		self:CreateIconIndicator(indicatorKey, unpack(info))
	end
	for indicatorKey, info in pairs(setup.indicators.text) do
		locationKey = setup.indicatorLocations[indicatorKey]
		location = setup.locations[locationKey]
		if (location) then
			info[2], info[3], info[4], info[5] = location.point, location.relPoint, location.x, location.y
		end

		self:CreateTextIndicator(indicatorKey, unpack(info))
	end
end


local handlerArray = {}
function Grid2:UpdateColorHandler(status)
	local profile = status.db.profile
	local colorCount = profile.colorCount or 1

	wipe(handlerArray)
	handlerArray[1] = "return function (self, unit)"
	local index = 2
	local color
	if (colorCount > 1) then
		handlerArray[index] = " local count = self:GetCount(unit)"
		index = index + 1
		for i = 1, colorCount - 1 do
			color = status.db.profile["color" .. i]
			handlerArray[index] = (" if count == %d then return %s, %s, %s, %s end"):format(i, color.r, color.g, color.b, color.a)
			index = index + 1
		end
	end

	color = status.db.profile[("color" .. colorCount)]
--print("UpdateColorHandler", status.name, "color" .. colorCount, color.r, color.g, color.b)
	handlerArray[index] = (" return %s, %s, %s, %s end"):format(color.r, color.g, color.b, color.a)

	local handler = table.concat(handlerArray)
	status.GetColor = assert(loadstring(handler))()
	return handler
end

function Grid2:SetupAuraDebuffColorHandler(status, info)
	local colorCount = (#info - 1) / 3
	if (colorCount <= 0) then
		local name = info[1]
		self:Print("Invalid number of colors for debuff %s", name)
		return
	end

	local handler = "return function (self, unit)"
	if (colorCount > 1) then
		handler = handler.." local count = self:GetCount(unit)"
		for i = 1, colorCount - 1 do
			handler = handler.. ("if count == %d then return %s, %s, %s end"):format(unpack(info, i * 3 - 1, (i + 1) * 3 - 2))
		end
	end
	handler = handler..(" return %s, %s, %s end"):format(unpack(info, colorCount * 3 - 1))
	status.GetColor = loadstring(handler)()
end

function Grid2:SetupStatusAuraBuff(statusKey, info)
	local status = self:CreateBuffStatus(unpack(info))
	status.name = statusKey -- force name

	self:RegisterStatus(status, { "color", "icon", "percent", "duration" })
	self:UpdateColorHandler(status)
	self:UpdateBlinkHandler(status)
	return status
end

function Grid2:SetupAuraStatusDebuff(statusKey, info)
	local status = self:CreateDebuffStatus(unpack(info))
	status.name = statusKey -- force name

	self:SetupAuraDebuffColorHandler(status, info)
	self:RegisterStatus(status, { "color", "icon", "percent" })
	return status
end

function Grid2:SetupAuraStatus(setup)
	for statusKey, info in pairs(setup.buffs) do
		self:SetupStatusAuraBuff(statusKey, info)
	end
	for statusKey, info in pairs(setup.debuffs) do
		self:SetupAuraStatusDebuff(statusKey, info)
	end
end

function Grid2:RegisterIndicatorStatuses(setup)
	for indicatorKey, statusPriorities in pairs(setup.status) do
		local indicator = self.indicators[indicatorKey]
		if (indicator) then
			for statusKey, priority in pairs(statusPriorities) do
				local status = self.statuses[statusKey]
				if (status and tonumber(priority)) then
					indicator:RegisterStatus(status, priority)
				end
			end
		end
	end
end


function Grid2:CreateCategories(categories)
	for categoryKey, categoryInfo in pairs(categories) do
		self:CreateCategory(categoryKey, categoryInfo.name, categoryInfo.priorities)
	end
end

function Grid2:RegisterCategoryStatuses(categories)
	for categoryKey, categoryInfo in pairs(categories) do
		local category = self.categories[categoryKey]
		if (category) then
			for statusKey, priority in pairs(categoryInfo.priorities) do
				local status = self.statuses[statusKey]
				if (status) then
					category:RegisterStatus(status, priority)
				end
			end
		end
	end
end

function Grid2:Setup()
	local setup, class = self:MakeDefaultSetup(self.db.profile.setup, select(2, UnitClass("player")))
	self.db.profile.setup = setup

	self:SetupIndicators(setup)
	self:SetupAuraStatus(setup)
	self:RegisterIndicatorStatuses(setup)

	local categories = self.db.account.categories
	self:CreateCategories(categories)
	self:RegisterCategoryStatuses(categories)
end

--[[
/dump Grid2.db.profile.setup.status.alpha
/dump Grid2.db.profile.setup.buffs
/dump Grid2.db.profile.setup.auraGroupDebuffs
/dump Grid2.db.account
/dump Grid2.statuses["buff-ArcaneIntellect"]
--]]
