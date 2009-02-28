function Grid2:MakeDefaultSetup(setup)
	local class = select(2, UnitClass("player"))

	if (not setup) then
		setup = {}
	end

	if (not setup.locations) then
		self:SetupDefaultLocations(setup, class)
	end
	if (not setup.indicatorLocations) then
		self:SetupDefaultIndicatorLocations(setup, class)
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

	return setup
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
		["center-left"] = {relIndicator = "center", point = "RIGHT", relPoint = "LEFT", x = 2, y = 0, name = "center-left"},
		["center-right"] = {relIndicator = "center", point = "LEFT", relPoint = "RIGHT", x = -2, y = 0, name = "center-right"},
		["center-top"] = {relIndicator = "center", point = "BOTTOM", relPoint = "TOP", x = 0, y = 2, name = "center-top"},
		["center-bottom"] = {relIndicator = "center", point = "TOP", relPoint = "BOTTOM", x = 0, y = -2, name = "center-bottom"},
	}
end

function Grid2:SetupDefaultIndicatorLocations(setup, class)
	setup.indicatorLocations = {
		["corner-topleft"] = "corner-top-left",
		["corner-topright"] = "corner-top-right",
		["corner-bottomleft"] = "corner-bottom-left",
		["corner-bottomright"] = "corner-bottom-right",
		["corner-side-bottom"] = "side-bottom",
	}
end

function Grid2:SetupDefaultIndicators(setup, class)
	setup.indicators.Bars = {
		health = { 1, "CENTER" },
		heals = { 2, "CENTER" },
	}
	setup.indicators.Corners = {
		bottomleft = { 5, "BOTTOMLEFT", "BOTTOMLEFT", 1, 1 },
		bottomright = { 5, "BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1 },
		topright = { 5, "TOPRIGHT", "TOPRIGHT", -1, -1 },
		topleft = { 5, "TOPLEFT", "TOPLEFT", 1, -1 },
		["side-bottom"] = { 5, "BOTTOM", "BOTTOM", 0, 1 },
	}
	setup.indicators.Icons = {
		center = { 4, "CENTER" },
	}
	setup.indicators.Texts = {
		up = { 3, "BOTTOM", "CENTER", 0, 4, },
		down = { 3, "TOP", "CENTER", 0, -4, },
	}
end

function Grid2:SetupDefaultStatus(setup, class)
	setup.status["text-up"] = { healthdeficit = 90, name = 80, }
	setup.status["text-up-color"] = { classcolor = 99 }
	setup.status["text-down"] = { death = 99, heals = 80 }
	setup.status["text-down-color"] = { death = 99, heals = 80 }

	setup.status["bar-health"] = { health = 99 }
	setup.status["bar-health-color"] = { classcolor = 99 }
	setup.status["bar-heals"] = { heals = 99 }
	setup.status["bar-heals-color"] = { heals = 99 }

	setup.status.border = {
		target = 99,
		voice = 80,
		lowmana = 70,
		lowhealth = 60,
	}

	setup.status["corner-bottomleft"] = { aggro = 99 }
	setup.status["corner-topright"] = { heals = 99 }

	setup.status.alpha = { range = 99 }
end

function Grid2:SetupDefaultAuras(setup, class)
	local auraSquare, buffSquare
	if (class == "DEATHKNIGHT") then
		setup.buffs.hornOfWinter = { 57330, true, 1, 1, 1, }

		buffSquare = {
			["buff-hornOfWinter"] = 99,
		}
	elseif (class == "DRUID") then
		setup.buffs.lifebloom = { 33763, 2, 0, .5, 0, 0, .7, 0, .2, 1, .2 }
		setup.buffs.rejuv = { 774, true, 0, 0, 1, }
		setup.buffs.regrowth = { 8936, true, 1, .5, .1, }
		auraSquare = {
			["buff-lifebloom"] = 99,
			["buff-rejuv"] = 89,
			["buff-regrowth"] = 79,
		}

		setup.buffs.wildgrowth = { 53248, true, .4, .9, .4, }
		auraSquare["buff-wildgrowth"] = 69
	elseif (class == "MAGE") then
		setup.buffs.iceArmor = { 7302, true, 1, 1, 1, }
		setup.buffs.iceBarrier = { 11426, true, 1, 1, 1, }

		buffSquare = {
			["buff-iceArmor"] = 99,
			["buff-iceBarrier"] = 89,
		}
	elseif (class == "PRIEST") then
		setup.buffs.renew = { 139, true, 1, 1, 1, }
		setup.debuffs.weakened = { 6788, 1, 0, 0, }

		auraSquare = {
			["buff-renew"] = 99,
			["debuff-weakened"] = 89,
		}
	elseif (class == "PALADIN") then
		setup.debuffs.forbearance = { 25771, 1, 0, 0, }

		auraSquare = {
			["debuff-forbearance"] = 99,
		}
	end

	if (auraSquare) then
		setup.status["corner-topleft"] = auraSquare
	end
	if (buffSquare) then
		setup.status["corner-side-bottom"] = buffSquare
	end
end

function Grid2:SetupDebuffPriorities(setup, class)
	local debuffPriorities
	if class == "DRUID" then
		debuffPriorities = {
			["debuff-Curse"] = 90,
			["debuff-Poison"] = 80,
			["debuff-Magic"] = 40,
			["debuff-Disease"] = 30,
		}
	elseif class == "PRIEST" then
		debuffPriorities = {
			["debuff-Disease"] = 90,
			["debuff-Magic"] = 80,
			["debuff-Curse"] = 40,
			["debuff-Poison"] = 30,
		}
	elseif class == "PALADIN" then
		debuffPriorities = {
			["debuff-Disease"] = 90,
			["debuff-Magic"] = 80,
			["debuff-Poison"] = 70,
			["debuff-Curse"] = 40,
		}
	elseif class == "SHAMAN" then
		debuffPriorities = {
			["debuff-Poison"] = 90,
			["debuff-Disease"] = 80,
			["debuff-Curse"] = 50,
			["debuff-Magic"] = 30,
		}
	elseif class == "MAGE" then
		debuffPriorities = {
			["debuff-Curse"] = 90,
			["debuff-Disease"] = 40,
			["debuff-Magic"] = 30,
			["debuff-Poison"] = 20,
		}
	else
		debuffPriorities = {
			["debuff-Magic"] = 40,
			["debuff-Poison"] = 30,
			["debuff-Curse"] = 20,
			["debuff-Disease"] = 10,
		}
	end
	setup.status["corner-bottomright"] = debuffPriorities
	setup.status["icon-center"] = debuffPriorities
end

function Grid2:SetupIndicators(setup)
	for name, info in pairs(setup.indicators.Bars) do
		self:CreateBarIndicator(name, unpack(info))
	end
	for name, info in pairs(setup.indicators.Corners) do
		self:CreateCornerIndicator(name, unpack(info))
	end
	for name, info in pairs(setup.indicators.Icons) do
		self:CreateIconIndicator(name, unpack(info))
	end
	for name, info in pairs(setup.indicators.Texts) do
		self:CreateTextIndicator(name, unpack(info))
	end
end

function Grid2:SetupAuraStatus(setup)
	for statusName, info in pairs(setup.buffs) do
		local name, mine = info[1], info[2]
		local status = self:CreateBuffStatus(name, mine)
		status.name = "buff-"..statusName -- force name
		local color_count = (#info - 2) / 3
		if color_count <= 0 or #info ~= color_count * 3 + 2 then
			self:Print("Invalid number of colors for buff %s", name)
			return
		end

		local handler = "return function (self, unit)"
		if color_count > 1 then
			handler = handler.." local count = self:GetCount(unit)"
			for i = 1, color_count - 1 do
				handler = handler..(" if count == %d then return %s, %s, %s end"):format(i, unpack(info, i * 3, (i + 1) * 3 - 1))
			end
		end
		handler = handler..(" return %s, %s, %s end"):format(unpack(info, color_count * 3))
		status.GetColor = assert(loadstring(handler))()
		self:RegisterStatus(status, { "color" })
	end
	for statusName, info in pairs(setup.debuffs) do
		local name = info[1]
		local status = self:CreateDebuffStatus(name)
		status.name = "debuff-"..statusName -- force name
		local color_count = (#info - 1) / 3
		if color_count <= 0 then
			self:Print("Invalid number of colors for debuff %s", name)
			return
		end

		local handler = "return function (self, unit)"
		if color_count > 1 then
			handler = handler.." local count = self:GetCount(unit)"
			for i = 1, color_count - 1 do
				handler = handler.. ("if count == %d then return %s, %s, %s end"):format(unpack(info, i * 3 - 1, (i + 1) * 3 - 2))
			end
		end
		handler = handler..(" return %s, %s, %s end"):format(unpack(info, color_count * 3 - 1))
		status.GetColor = loadstring(handler)()
		self:RegisterStatus(status, { "color" })
	end
end

function Grid2:SetupStatus(setup)
	for indicatorName, configs in pairs(setup.status) do
		local indicator = self.indicators[indicatorName]
		if indicator then
			for statusName, priority in pairs(configs) do
				local status = self.statuses[statusName]
				if status and tonumber(priority) then
					indicator:RegisterStatus(status, priority)
				end
			end
		end
	end
end

function Grid2:Setup()
	local setup = self:MakeDefaultSetup(self.db.profile.setup)
	self.db.profile.setup = setup

	self:SetupIndicators(setup)
	self:SetupAuraStatus(setup)
	self:SetupStatus(setup)
end
