-- GridCore.lua
-- insert boilerplate here

--{{{ Libraries

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")
local DBL = LibStub:GetLibrary("LibDBLayers-1.0")

--}}}
--{{{ Grid2
--{{{  Initialization

Grid2 = LibStub("AceAddon-3.0"):NewAddon("Grid2", "AceEvent-3.0", "AceConsole-3.0")
Grid2.versionstring = "Grid2 v"..GetAddOnMetadata("Grid2", "Version")
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
--{{{ type

Grid2.setupFunc = {}	-- type setup functions for non-unique objects: "buff" statuses / "icon" indicators / etc.
Grid2.objectMap = {}	-- map to unique objects: "debuff-Poison" / "name" / "border" / etc.

--}}}
--{{{ AceTimer-3.0, embedded upon use

function Grid2:ScheduleRepeatingTimer(...)
	LibStub("AceTimer-3.0"):Embed(Grid2)
	return self:ScheduleRepeatingTimer(...)
end

function Grid2:ScheduleTimer(...)
	LibStub("AceTimer-3.0"):Embed(Grid2)
	return self:ScheduleTimer(...)
end

function Grid2:CancelTimer(...)
	LibStub("AceTimer-3.0"):Embed(Grid2)
	return self:CancelTimer(...)
end

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
		local name = type .. "-" .. element.name
		if (self.db.children[name]) then
			-- Hack in "UnregisterNamespace"
			self.db.sv.namespaces[name] = nil
			self.db.children[name] = nil
		end
		element.db = self.db:RegisterNamespace(name, element.defaultDB)
	end
	if Grid2Options then
		Grid2Options:AddElement(type, element)
	end
end

function Grid2:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("Grid2DB", self.defaults, "profile")

	self:RegisterChatCommand("grid2", "OnChatCommand")
	self:RegisterChatCommand("gr2", "OnChatCommand")
	local optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Grid2", L["Grid2"], nil, "General")

	local prev_OnShow = optionsFrame:GetScript("OnShow")
	optionsFrame:SetScript("OnShow", function (self, ...)
		Grid2:LoadAllOptions()
		
		self:SetScript("OnShow", prev_OnShow)
		return prev_OnShow(self, ...)
	end)

	self.optionsFrame = optionsFrame
	self:RegisterModules()

	for _, location in self:IterateLocations() do
		self:InitializeElement("location", location)
	end
	for _, indicator in self:IterateIndicators() do
		self:InitializeElement("indicator", indicator)
	end
	for _, status in self:IterateStatuses() do
		self:InitializeElement("status", status)
	end
	for _, category in self:IterateCategories() do
		self:InitializeElement("category", category)
	end

	local media = LibStub("LibSharedMedia-3.0", true)
	if media then
		media:Register("statusbar", "Gradient", "Interface\\Addons\\Grid2\\gradient32x32")
	end
end

-- Do not hook
function Grid2:LoadGrid2Options()
	if (Grid2Options) then return end

	if (not IsAddOnLoaded("Grid2Options")) then
		LoadAddOn("Grid2Options")
	end
end

-- This function gets hooked
-- Loads only Options that need an upgrade
function Grid2:LoadOptions(dblData)
	local upgrade

	if (dblData) then
		upgrade = DBL:LoadOptions("Grid2Options", dblData, "InitializeOptions", "account", 1, dblData.classKey, 1, dblData.specKey, 1) or upgrade
	else
		Grid2:LoadGrid2Options()
		upgrade = true
	end

	return upgrade
end

-- Do not hook
-- Loads all options and initializes them
local allOptionsLoaded
function Grid2:LoadAllOptions()
	if (allOptionsLoaded) then return end

	allOptionsLoaded = true
	Grid2:LoadOptions()
	if (Grid2Options) then
		Grid2Options:Initialize()
	else
		Grid2:Print("You need the Grid2Options addon available to be able to configure Grid2.")
	end
end

function Grid2:OnChatCommand(input)
	Grid2:LoadAllOptions()
	if (Grid2Options) then
		Grid2Options:OnChatCommand(input)
	end
end

function Grid2:OnEnable()
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "GroupChanged")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "GroupChanged")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	-- roster
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_NAME_UPDATE")

	self.db.RegisterCallback(self, "OnProfileChanged")

	self:SendMessage("Grid_Enabled")

	self:EnableModules()

	self:Setup()
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
	self:GroupChanged("PLAYER_ENTERING_WORLD")
end

function Grid2:GroupChanged(event)
-- print("GroupChanged", event)
	local _, instType = IsInInstance()

	if instType == "none" then
		local raidMembers = GetNumRaidMembers()
		if raidMembers > 25 then
			instType = "raid40"
		elseif raidMembers > 10 then
			instType = "raid25"
		elseif raidMembers > 0 then
			instType = "raid10"
		elseif GetNumPartyMembers() > 0 then
			instType = "party"
		else
			instType = "solo"
		end
	else
		if instType == "raid" then
			local raidDifficulty = GetRaidDifficulty()
			if raidDifficulty == 2 or raidDifficulty == 4 then
				instType = "raid25"
			else
				instType = "raid10"
			end
		elseif (instType == "pvp") then
			local raidMembers = GetNumRaidMembers()
			if raidMembers < 11 then
				instType = "raid10"
			elseif raidMembers < 16 then
				instType = "raid15"
			else
				instType = "raid40"
			end
		else
			local raidMembers = GetNumRaidMembers()
			if raidMembers > 25 then
				instType = "raid40"
			elseif raidMembers > 15 then
				instType = "raid25"
			elseif raidMembers > 10 then
				instType = "raid15"
			elseif raidMembers > 0 then
				instType = "raid10"
			elseif GetNumPartyMembers() > 0 then
				instType = "party"
			else
				instType = "solo"
			end
		end
		if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
			instType = "solo"
		end
	end

	self:Debug("GroupChanged", groupType, "=>", instType)

	if groupType ~= instType then
		groupType = instType
		self:SendMessage("Grid_GroupTypeChanged", groupType)
	end

	self:UpdateRoster()
end

local frames_of_unit = setmetatable({}, { __index = function (self, key)
	local result = {}
	rawset(self, key, result)
	return result
end})

local unit_of_frame = {}
function Grid2:SetFrameUnit(frame, unit)
	local prev_unit = unit_of_frame[frame]
	if prev_unit then
		frames_of_unit[prev_unit][frame] = nil
	end
	if unit then
		frames_of_unit[unit][frame] = true
	end
	unit_of_frame[frame] = unit
end

function Grid2:GetUnitFrames(unit)
	return frames_of_unit[unit]
end

--}}}
--}}}
