-- GridCore.lua
-- insert boilerplate here

--{{{ Libraries

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

--}}}
--{{{ Grid2
--{{{  Initialization

Grid2 = LibStub("AceAddon-3.0"):NewAddon("Grid2", "AceEvent-3.0", "AceConsole-3.0")
Grid2.debugFrame = Grid2DebugFrame or ChatFrame1
function Grid2:Debug(s, ...)
	if self.debugging then
		if s:find("%", nil, true) then
			Grid2:Print(self.debugFrame, "DEBUG", self.name, s:format(...))
		else
			Grid2:Print(self.debugFrame, "DEBUG", self.name, s, ...)
		end
	end
end

--{{{ AceDB defaults

Grid2.defaults = {
	profile = {
		debug = false,
	}
}

--}}}
--{{{  Module prototype

local modulePrototype = {}
modulePrototype.core = Grid2

function modulePrototype:OnInitialize()
	if not self.db then
		self.db = self.core.db:RegisterNamespace(self.name, self.defaultDB)
	end
	self.debugFrame = Grid2.debugFrame
	self.debugging = self.db.profile.debug
	self:Debug("OnInitialize")
	self:RegisterModules()
end

function modulePrototype:OnEnable()
	self:EnableModules()
end

function modulePrototype:OnDisable()
	self:DisableModules()
end

function modulePrototype:Reset()
	self.debugging = self.db.profile.debug
	self:Debug("Reset")
	self:ResetModules()
end

function modulePrototype:RegisterModules()
	for name, module in self:IterateModules() do
		self:RegisterModule(name, module)
	end
end

function modulePrototype:RegisterModule(name, module)
	self:Debug("Registering ", name)

	if not module.db then
		module.db = self.core.db:RegisterNamespace(name, module.defaultDB)
	end

	if Grid2Options then
		Grid2Options:AddModule(self.name, name, module)
	end
end

function modulePrototype:EnableModules()
	for name,module in self:IterateModules() do
		self:SetEnabledState(module, true)
	end
end

function modulePrototype:DisableModules()
	for name,module in self:IterateModules() do
		self:SetEnabledState(module, false)
	end
end

function modulePrototype:ResetModules()
	for name,module in self:IterateModules() do
		module:Reset()
	end
end

modulePrototype.Debug = Grid2.Debug

Grid2:SetDefaultModulePrototype(modulePrototype)
Grid2:SetDefaultModuleLibraries("AceEvent-3.0")

--}}}

function Grid2:InitializeElement(type, element)
	if element.defaultDB and not element.db then
		element.db = self.db:RegisterNamespace(type.."-"..element.name, element.defaultDB)
	end
	if Grid2Options then
		Grid2Options:AddElement(type, element)
	end
end

function Grid2:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("Grid2DB", self.defaults, "profile")

	self:RegisterChatCommand("grid2", "OnChatCommand")
	self:RegisterChatCommand("gr2", "OnChatCommand")
	local optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Grid2", "Grid2")

	local prev_OnShow = optionsFrame:GetScript("OnShow")
	optionsFrame:SetScript("OnShow", function (self, ...)
		Grid2:LoadOptions()
		self:SetScript("OnShow", prev_OnShow)
		return prev_OnShow(self, ...)
	end)

	self.optionsFrame = optionsFrame
	self:RegisterModules()

	for _, indicator in self:IterateIndicators() do
		self:InitializeElement("indicator", indicator)
	end
	for _, status in self:IterateStatuses() do
		self:InitializeElement("status", status)
	end
end

function Grid2:LoadOptions()
	if Grid2Options then return end
	if not IsAddOnLoaded("Grid2Options") then
		LoadAddOn("Grid2Options")
		if Grid2Options then
			Grid2Options:Initialize()
		end
	end
end

function Grid2:OnChatCommand(input)
	self:LoadOptions()
	if Grid2Options then
		Grid2Options:OnChatCommand(input)
	else
		self:Print("You need the Grid2Options addon available to be able to configure Grid2.")
	end
end

function Grid2:OnEnable()
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RosterUpdated")
	self:RegisterEvent("RAID_ROSTER_UPDATED", "RosterUpdated")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self.db.RegisterCallback(self, "OnProfileChanged")

	self:SendMessage("Grid_Enabled")

	self:EnableModules()

	self:SetupIndicators()
end

local config = {
	-- @FIXME, this should be configurable
	["text-up"] = { healthdeficit = 90, name = 80, },
	["text-up-color"] = { classcolor = 99 },
	["text-down"] = { death = 99, heals = 80 },
	["text-down-color"] = { death = 99, heals = 80 },

	["bar-health"] = { health = 99 },
	["bar-health-color"] = { classcolor = 99 },
	["bar-heals"] = { heals = 99 },
	["bar-heals-color"] = { heals = 99 },

	border = {
		target = 99,
		voice = 80,
		lowmana = 70,
		lowhealth = 60,
	},

	["corner-bottomleft"] = { aggro = 99 },
	["corner-topright"] = { heals = 99 },

	alpha = { range = 99 },
}

function Grid2:SetupDebuffPriorities()
	local debuffPriorities

	local class = select(2, UnitClass("player"))
	if class == "DRUID" then
		debuffPriorities = {
			["debuff-Curse"] = 90,
			["debuff-Poison"] = 80,
			["debuff-Magic"] = 40,
			["debuff-Disease"] = 30,
		}
		local lifebloom = self:CreateBuffStatus(GetSpellInfo(33763), 2)
		function lifebloom:GetColor(unit)
			local count = self:GetCount(unit)
			if count == 3 then
				return .2, 1, .2
			elseif count == 2 then
				return 0, .7, 0
			else
				return 0, .5, 0
			end
		end
		self:RegisterStatus(lifebloom, { "color" })
		self.indicators["corner-topleft"]:RegisterStatus(lifebloom, 99)

		local rejuv = self:CreateBuffStatus(GetSpellInfo(774), true)
		function rejuv:GetColor()
			return 0, 0, 1
		end
		self:RegisterStatus(rejuv, { "color" })
		self.indicators["corner-topleft"]:RegisterStatus(rejuv, 89)

		local regrowth = self:CreateBuffStatus(GetSpellInfo(8936), true)
		function regrowth:GetColor()
			return 1, .5, .1
		end
		self:RegisterStatus(regrowth, { "color" })
		self.indicators["corner-topleft"]:RegisterStatus(regrowth, 79)

		if select(5, GetTalentInfo(3, 26)) > 0 then
			local wildgrowth = self:CreateBuffStatus(GetSpellInfo(53248), true)
			function wildgrowth:GetColor()
				return .4, .9, .4
			end
			self:RegisterStatus(wildgrowth, { "color" })
			self.indicators["corner-topleft"]:RegisterStatus(wildgrowth, 69)
		end

	elseif class == "PRIEST" then
		debuffPriorities = {
			["debuff-Disease"] = 90,
			["debuff-Magic"] = 80,
			["debuff-Curse"] = 40,
			["debuff-Poison"] = 30,
		}
		local renew = self:CreateBuffStatus(GetSpellInfo(139), true)
		function renew:GetColor()
			return 1, 1, 1
		end
		self:RegisterStatus(renew, { "color" })
		self.indicators["corner-topleft"]:RegisterStatus(renew, 50)

		local weakened = self:CreateDebuffStatus((GetSpellInfo(6788)))
		function weakened:GetColor()
			return 1, 0, 0
		end
		self:RegisterStatus(weakened, { "color" })
		self.indicators["corner-topleft"]:RegisterStatus(weakened, 99)
	elseif class == "PALADIN" then
		debuffPriorities = {
			["debuff-Disease"] = 90,
			["debuff-Magic"] = 80,
			["debuff-Poison"] = 70,
			["debuff-Curse"] = 40,
		}
		local forbearance = self:CreateDebuffStatus((GetSpellInfo(25771)))
		function forbearance:GetColor()
			return 1, 0, 0
		end
		self:RegisterStatus(forbearance, { "color" })
		self.indicators["corner-topleft"]:RegisterStatus(forbearance, 99)
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
	config["corner-bottomright"] = debuffPriorities
	config["icon-center"] = debuffPriorities
end

function Grid2:SetupIndicators()
	self:SetupDebuffPriorities()

	for indicatorName, configs in pairs(config) do
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

function Grid2:OnDisable()
	self:Debug("OnDisable")
	self:SendMessage("Grid_Disabled")
	self:DisableModules()
end

function Grid2:OnProfileChanged()
	self.debugging = self.db.profile.debug
	self:Debug("Loaded profile (", self:GetProfile(),")")
	self:ResetModules()
end

function Grid2:RegisterModule(name, module)
	self:Debug("Registering ", name)

	if not module.db then
		module.db = self.db:RegisterNamespace(name, module.defaultDB)
	end

	if Grid2Options then
		Grid2Options:AddModule(self.name, name, module)
	end
end

function Grid2:ResetModules()
	for name, module in self:IterateModules() do
		module.db = self.db:RegisterNamespace(name)
		module:Reset()
	end
end

Grid2.RegisterModules = modulePrototype.RegisterModules
Grid2.EnableModules = modulePrototype.EnableModules
Grid2.DisableModules = modulePrototype.DisableModules

--{{{ Event handlers

local groupType
function Grid2:PLAYER_ENTERING_WORLD()
	-- this is needed to trigger an update when switching from one BG directly to another
	groupType = nil
	return self:RosterUpdated()
end

function Grid2:RosterUpdated()
	local instType = select(2, IsInInstance())

	if instType == "none" then
		if GetNumRaidMembers() > 0 then
			instType = "raid"
		elseif GetNumPartyMembers() > 0 then
			instType = "party"
		else
			instType = "solo"
		end
	end

	self:Debug("RosterUpdated", groupType, "=>", instType)

	if groupType ~= instType then
		groupType = instType
		self:SendMessage("Grid_GroupTypeChanged", groupType)
	end

	self:UpdateRoster()
end

Grid2.framesByUnit = {}
function Grid2:SetFrameUnit(frame, unit)
	for key, value in pairs(self.framesByUnit) do
		if value == frame then
			self.framesByUnit[key] = nil
			break
		end
	end
	if unit then
		self.framesByUnit[unit] = frame
	end
end

function Grid2:GetUnitFrame(unit)
	return self.framesByUnit[unit]
end

--}}}
--}}}
