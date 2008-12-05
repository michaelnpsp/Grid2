function Grid2:MakeDefaultSetup()
	local setup = {
		buffs = {},
		debuffs = {},
		indicators = {},
		status = {},
	}

	local class = select(2, UnitClass("player"))
	self:SetupDefaultIndicators(config, class)
	self:SetupDefaultStatus(config, class)
	self:SetupDefaultAuras(config, class)
	self:SetupDebuffPriorities(config, class)

	return setup
end

function Grid2:SetupDefaultIndicators(config, class)
	config.indicators.Bars = {
		health = { "CENTER" },
		heals = { "CENTER" },
	}
	config.indicators.Corners = {
		bottomleft = { "BOTTOMLEFT", "BOTTOMLEFT", 1, 1 },
		bottomright = { "BOTTOMRIGHT", "BOTTOMRIGHT", -1, 1 },
		topright = { "TOPRIGHT", "TOPRIGHT", -1, -1 },
		topleft = { "TOPLEFT", "TOPLEFT", 1, -1 },
	}
	config.indicators.Icons = {
		center = { "CENTER" },
	}
	config.indicators.Texts = {
		up = { "BOTTOM", "CENTER", 0, 4, },
		down = { "TOP", "CENTER", 0, -4, },
	}
end

function Grid2:SetupDefaultStatus(config, class)
	config.status["text-up"] = { healthdeficit = 90, name = 80, }
	config.status["text-up-color"] = { classcolor = 99 }
	config.status["text-down"] = { death = 99, heals = 80 }
	config.status["text-down-color"] = { death = 99, heals = 80 }

	config.status["bar-health"] = { health = 99 }
	config.status["bar-health-color"] = { classcolor = 99 }
	config.status["bar-heals"] = { heals = 99 }
	config.status["bar-heals-color"] = { heals = 99 }

	config.status.border = {
		target = 99,
		voice = 80,
		lowmana = 70,
		lowhealth = 60,
	}

	config.status["corner-bottomleft"] = { aggro = 99 }
	config.status["corner-topright"] = { heals = 99 }

	config.status.alpha = { range = 99 }
end

function Grid2:SetupDefaultAuras(config, class)
	local auraCorner
	if class == "DRUID" then
		config.buffs.lifebloom = { 33763, 2, 0, .5, 0, 0, .7, 0, .2, 1, .2 }
		config.buffs.rejuv = { 774, true, 0, 0, 1, }
		config.buffs.regrowth = { 8936, true, 1, .5, .1, }
		auraCorner = {
			["buff-lifebloom"] = 99,
			["buff-rejuv"] = 89,
			["buff-regrowth"] = 79,
		}

		if select(5, GetTalentInfo(3, 26)) > 0 then
			config.buffs.wildgrowth = { 53248, true, .4, .9, .4, }
			auraCorner["buff-wildgrowth"] = 69
		end
	elseif class == "PRIEST" then
		config.buffs.renew = { 139, true, 1, 1, 1, }
		config.debuffs.weakened = { 6788, 1, 0, 0, }

		auraCorner = {
			["buff-renew"] = 99,
			["debuff-weakened"] = 89,
		}
	elseif class == "PALADIN" then
		config.debuffs.forbearance = { 25771, 1, 0, 0, }

		auraCorner = {
			["debuff-forbearance"] = 99,
		}
	end

	if auraCorner then
		config.status["corner-topleft"] = auraCorner
	end
end

function Grid2:SetupDebuffPriorities(config, class)
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
	config.status["corner-bottomright"] = debuffPriorities
	config.status["icon-center"] = debuffPriorities
end

function Grid2:SetupIndicators(config)
	for name, info in pairs(config.indicators.Bars) do
		self:CreateBarIndicator(name, unpack(info))
	end
	for name, info in pairs(config.indicators.Corners) do
		self:CreateCornerIndicator(name, unpack(info))
	end
	for name, info in pairs(config.indicators.Icons) do
		self:CreateIconIndicator(name, unpack(info))
	end
	for name, info in pairs(config.indicators.Texts) do
		self:CreateTextIndicator(name, unpack(info))
	end
end

function Grid2:SetupAuraStatus(config)
	for name, info in pairs(config.buffs) do
		local name, mine = info[1], info[2]
		local status = self:CreateBuffStatus(name, mine)
		status.name = "buff-"..name -- force name
		local color_count = (#info - 2) / 3
		if color_count <= 0 then
			self:Print("Invalid number of colors for buff %s", name)
			return
		end

		local handler = "return function (self, unit)"
		if color_count > 1 then
			handler = handler.." local count = self:GetCount(unit)"
			for i = 1, color_count - 1 do
				handler = handler.. ("if count == %d then return %s, %s, %s end"):format(unpack(info, i * 3, (i + 1) * 3 - 1))
			end
		end
		handler = handler..(" return %s, %s, %s end"):format(unpack(info, color_count * 3))
		status.GetColor = loadstring(handler)()
		self:RegisterStatus(status, { "color" })
	end
	for name, info in pairs(config.debuffs) do
		local name = info[1]
		local status = self:CreateDebuffStatus(name)
		status.name = "debuff-"..name -- force name
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

function Grid2:SetupStatus(config)
	for indicatorName, configs in pairs(config.status) do
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
	local setup = self.db.profile.setup
	if not setup then
		setup = self:MakeDefaultSetup()
		self.db.profile.setup = setup
	end
	self:SetupIndicators(setup)
	self:SetupAuraStatus(setup)
	self:SetupStatus(setup)
end
