function Grid2:MakeDefaultSetup(setup, class)
	if (not setup) then
		setup = {}
	end

	if (not setup.locations) then
		self:SetupDefaultLocations(setup, class)
	end
	if (not setup.indicatorLocations) then
		self:SetupDefaultIndicatorLocations(setup, class)
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
		["center-top"] = {relIndicator = "center", point = "BOTTOM", relPoint = "CENTER", x = 0, y = 1, name = "center-top"},
		["center-bottom"] = {relIndicator = "center", point = "TOP", relPoint = "CENTER", x = 0, y = -1, name = "center-bottom"},
	}
end

function Grid2:SetupDefaultIndicatorLocations(setup, class)
	setup.indicatorLocations = {
		["corner-top-left"] = "corner-top-left",
		["corner-top-right"] = "corner-top-right",
		["corner-bottom-left"] = "corner-bottom-left",
		["corner-bottom-right"] = "corner-bottom-right",
		["side-bottom"] = "side-bottom",
	}
	if (class == "DRUID") then
		setup.indicatorLocations["regrowth"] = "side-top"
	end
end

function Grid2:SetupDefaultIndicators(setup, class)
	setup.indicators.Bars = {
		["bar-health"] = { 1, "CENTER" },
		["bar-heals"] = { 2, "CENTER" },
	}
	setup.indicators.square = {
		["corner-bottom-left"] = { 5, "BOTTOMLEFT", "BOTTOMLEFT", 1, 1 },
		["corner-bottom-right"] = { 5, "BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1 },
		["corner-top-right"] = { 5, "TOPRIGHT", "TOPRIGHT", -1, -1 },
		["corner-top-left"] = { 5, "TOPLEFT", "TOPLEFT", 1, -1 },
		["side-bottom"] = { 5, "BOTTOM", "BOTTOM", 0, 1 },
	}
	setup.indicators.icon = {
		["icon-center"] = { 4, "CENTER" },
	}
	setup.indicators.text = {
		["name"] = { 3, "BOTTOM", "CENTER", 0, 4, },
		["text-down"] = { 3, "TOP", "CENTER", 0, -4, },
	}

	if (class == "DRUID") then
		setup.indicators.square["regrowth"] = { 5, "TOP", "TOP", 0, -1 }
	end
end

function Grid2:SetupDefaultStatus(setup, class)
	local setupIndicator = setup.status
	setup.status["name"] = { healthdeficit = 90, name = 80, }
	setup.status["name-color"] = { classcolor = 99 }
	setup.status["text-down"] = { death = 95, offline = 75, charmed = 65, heals = 50 }
	setup.status["text-down-color"] = { death = 99, heals = 80, offline = 75, charmed = 65 }

	setup.status["bar-health"] = { health = 99 }
	setup.status["bar-health-color"] = { classcolor = 90 }
	setup.status["bar-heals"] = { heals = 99 }
	setup.status["bar-heals-color"] = { heals = 89 }

	setup.status.border = {
		target = 99,
		voice = 80,
		lowmana = 70,
		lowhealth = 60,
	}

	setup.status["corner-bottom-left"] = { aggro = 99 }

	self:SetupIndicatorStatus(setupIndicator, "alpha", "death", 99)
	self:SetupIndicatorStatus(setupIndicator, "alpha", "range", 98)
	self:SetupIndicatorStatus(setupIndicator, "alpha", "offline", 97)
end

function Grid2:SetupIndicatorStatus(setupIndicator, indicatorKey, statusKey, priority)
	local statuses = setupIndicator[indicatorKey]
	if (not statuses) then
		statuses = {}
		setupIndicator[indicatorKey] = statuses
	end
	statuses[statusKey] = priority
end

function Grid2:SetupDefaultAuras(setup, class)
	local setupIndicator = setup.status
	if (class == "DEATHKNIGHT") then
		setup.buffs["buff-HornOfWinter"] = {57330, true, 0.1, 0.1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-HornOfWinter", 99)
	elseif (class == "DRUID") then
		setup.buffs["buff-AbolishPoison"] = {2893, true, 1, .5, .1, 1}
		setup.buffs["buff-Lifebloom"] = {33763, 2, 0, .5, 0, 1, 0, .7, 0, 1, .2, 1, .2, 1}
		setup.buffs["buff-Rejuv"] = {774, 2, 1, .2, 1, 1}
		setup.buffs["buff-Regrowth"] = {8936, 2, .2, 1, .2, 1}
		setup.buffs["buff-Thorns"] = {467, false, .2, 1, .2, 1}
		setup.buffs["buff-WildGrowth"] = {53248, true, .4, .9, .4, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-Lifebloom", 99)
		self:SetupIndicatorStatus(setupIndicator, "regrowth", "buff-Regrowth", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-Rejuv", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-AbolishPoison", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-WildGrowth", 69)
	elseif (class == "MAGE") then
		setup.buffs["buff-AmplifyMagic"] = {33946, false, 1, 1, 1, 1}
		setup.buffs["buff-DampenMagic"] = {33944, false, 1, 1, 1, 1}
		setup.buffs["buff-FocusMagic"] = {54646, false, .11, .22, .33, 1}
		setup.buffs["buff-IceArmor"] = {7302, true, 1, 1, 1, 1}
		setup.buffs["buff-IceBarrier"] = {11426, true, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-AmplifyMagic", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-DampenMagic", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-FocusMagic", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-IceArmor", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-IceBarrier", 89)
	elseif (class == "PALADIN") then
		setup.buffs["buff-BeaconOfLight"] = {53654, true, 1, 1, 1, 1}
		setup.buffs["buff-BlessingOfProtection"] = {41450, true, 1, 1, 1, 1}
		setup.buffs["buff-DivineIntervention"] = {19752, true, 1, 1, 1, 1}
		setup.buffs["buff-LightsBeacon"] = {53651, true, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-BeaconOfLight", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-BlessingOfProtection", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-DivineIntervention", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-LightsBeacon", 99)

		setup.debuffs["debuff-Forbearance"] = {25771, false, 1, 0, 0, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "debuff-Forbearance", 99)
	elseif (class == "PRIEST") then
		setup.buffs["buff-Grace"] = {47516, true, 1, 1, 1, 1}
		setup.buffs["buff-DivineAegis"] = {47509, false, 1, 1, 1, 1}
		setup.buffs["buff-InnerFire"] = {588, false, 1, 1, 1, 1}
		setup.buffs["buff-PrayerOfMending"] = {33076, true, 1, 1, 1, 1}
		setup.buffs["buff-PowerWordShield"] = {17, false, 1, 1, 1, 1}
		setup.buffs["buff-Renew"] = {139, true, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-top-left", "buff-Renew", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-top-right", "buff-PrayerOfMending", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-PowerWordShield", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-DivineAegis", 79)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-InnerFire", 79)

		setup.debuffs["debuff-WeakenedSoul"] = {6788, false, 1, 0, 0, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "debuff-WeakenedSoul", 89)
	elseif (class == "ROGUE") then
		setup.buffs["buff-Evasion"] = {5277, true, 0.1, 0.1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-Evasion", 99)
	elseif (class == "SHAMAN") then
		setup.buffs["buff-Riptide"] = {61295, true, 1, 1, 1, 1}
		setup.buffs["buff-Earthliving"] = {51945, false, 1, 1, 1, 1}
		setup.buffs["buff-EarthShield"] = {974, false, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-Riptide", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-Earthliving", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-EarthShield", 99)
	elseif (class == "WARLOCK") then
		setup.buffs["buff-ShadowWard"] = {6229, true, 1, 1, 1, 1}
		setup.buffs["buff-SoulLink"] = {19028, true, 1, 1, 1, 1}
		setup.buffs["buff-DemonArmor"] = {706, true, 1, 1, 1, 1}
		setup.buffs["buff-DemonSkin"] = {696, true, 1, 1, 1, 1}
		setup.buffs["buff-FelArmor"] = {28189, true, 1, 1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-ShadowWard", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-SoulLink", 99)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-FelArmor", 99)
	elseif (class == "WARRIOR") then
		setup.buffs["buff-BattleShout"] = {2048, true, 0.1, 0.1, 1, 1}
		setup.buffs["buff-CommandingShout"] = {469, true, 0.1, 0.1, 1, 1}
		setup.buffs["buff-LastStand"] = {12975, true, 0.1, 0.1, 1, 1}
		setup.buffs["buff-ShieldWall"] = {871, true, 0.1, 0.1, 1, 1}
		setup.buffs["buff-Vigilance"] = {50720, true, 0.1, 0.1, 1, 1}

		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-BattleShout", 89)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-CommandingShout", 79)
		self:SetupIndicatorStatus(setupIndicator, "side-bottom", "buff-Vigilance", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-LastStand", 99)
		self:SetupIndicatorStatus(setupIndicator, "corner-bottom-right", "buff-ShieldWall", 89)
	end
end

function Grid2:SetupDebuffPriorities(setup, class)
	local debuffPriorities
	if class == "DRUID" then
		debuffPriorities = {
			["debuff-Curse"] = 90,
			["debuff-Poison"] = 80,
		}
	elseif class == "MAGE" then
		debuffPriorities = {
			["debuff-Curse"] = 90,
			["debuff-Disease"] = 40,
			["debuff-Magic"] = 30,
			["debuff-Poison"] = 20,
		}
	elseif class == "PALADIN" then
		debuffPriorities = {
			["debuff-Disease"] = 90,
			["debuff-Magic"] = 80,
			["debuff-Poison"] = 70,
			["debuff-Curse"] = 40,
		}
	elseif class == "PRIEST" then
		debuffPriorities = {
			["debuff-Disease"] = 90,
			["debuff-Magic"] = 80,
		}
	elseif class == "SHAMAN" then
		debuffPriorities = {
			["debuff-Poison"] = 90,
			["debuff-Disease"] = 80,
			["debuff-Curse"] = 50,
			["debuff-Magic"] = 30,
		}
	else
		debuffPriorities = {
			["debuff-Magic"] = 40,
			["debuff-Poison"] = 30,
			["debuff-Curse"] = 20,
			["debuff-Disease"] = 10,
		}
	end
	setup.status["corner-bottom-right"] = debuffPriorities

	if (debuffPriorities) then
		local setupIndicator = setup.status
		for statusKey, priority in pairs(debuffPriorities) do
			self:SetupIndicatorStatus(setupIndicator, "icon-center", statusKey, priority)
		end
	end
end

function Grid2:SetupIndicators(setup)
	for indicatorKey, info in pairs(setup.indicators.Bars) do
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
			handlerArray[index] = (" if count == %d then return %s, %s, %s end"):format(i, color.r, color.g, color.b)
			index = index + 1
		end
	end

	color = status.db.profile[("color" .. colorCount)]
--print("UpdateColorHandler", status.name, "color" .. colorCount, color.r, color.g, color.b)
	handlerArray[index] = (" return %s, %s, %s end"):format(color.r, color.g, color.b)

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

	self:RegisterStatus(status, { "color", "icon", "percent" })
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
