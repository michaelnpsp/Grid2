--[[
Created by Grid2 original authors, modified by Michael
--]]

--{{{ 

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")
local media = LibStub("LibSharedMedia-3.0", true)

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
	    versions = {},
		indicators = {},
		statuses = {},
		statusMap =  {},
	}
}

--}}}
--{{{ type

Grid2.setupFunc = {}	-- type setup functions for non-unique objects: "buff" statuses / "icon" indicators / etc.

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
modulePrototype.Debug = Grid2.Debug

function modulePrototype:OnInitialize()
	if not self.db then
		self.db = self.core.db:RegisterNamespace(self.moduleName or self.name, self.defaultDB or {} )
	end
	self.debugFrame = Grid2.debugFrame
	self.debugging = self.db.profile.debug
	if self.OnModuleInitialize then self:OnModuleInitialize() end
	self:Debug("OnInitialize")
end

function modulePrototype:OnEnable()
	if self.OnModuleEnable then self:OnModuleEnable() end
end

function modulePrototype:OnDisable()
	if self.OnModuleDisable then self:OnModuleDisable() end
end

function modulePrototype:OnUpdate()
	if self.OnModuleUpdate then self:OnModuleUpdate() end
end

Grid2:SetDefaultModulePrototype(modulePrototype)
Grid2:SetDefaultModuleLibraries("AceEvent-3.0")

--}}}
--{{{  Modules management

function Grid2:EnableModules()
	for _,module in self:IterateModules() do
		module:OnEnable()
	end
end

function Grid2:DisableModules()
	for _,module in self:IterateModules() do
		module:OnDisable()
	end
end

function Grid2:UpdateModules()
	for _,module in self:IterateModules() do
		module:OnUpdate()
	end
end

--}}}

function Grid2:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("Grid2DB", self.defaults)

	self.debugging = self.db.profile.debug

 	local LibDualSpec = LibStub('LibDualSpec-1.0')
	if LibDualSpec then
		LibDualSpec:EnhanceDatabase(self.db, "Grid2")
	end

	self:InitializeOptions()

	self.OnInitialize= nil
end

function Grid2:OnEnable()

	media:Register("statusbar", "Gradient", "Interface\\Addons\\Grid2\\gradient32x32")
	media:Register("statusbar", "Grid2 Flat", "Interface\\Addons\\Grid2\\white16x16")
	media:Register("border", "Grid2 Flat", "Interface\\Addons\\Grid2\\white16x16")
		
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "GroupChanged")
	self:RegisterEvent("RAID_ROSTER_UPDATE", "GroupChanged")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	
    self.db.RegisterCallback(self, "OnProfileChanged", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "ProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "ProfileChanged")

	self:LoadConfig()

	self:SendMessage("Grid_Enabled")
end

function Grid2:OnDisable()
	self:SendMessage("Grid_Disabled")
end

function Grid2:LoadConfig()
	self:UpdateDefaults()
	self:Setup()	
end

function Grid2:InitializeOptions()
	if Grid2DB["setup-flat"] then
		self.OnEnable= nil
		self.OnChatCommand= function() end
		print("|c00ff0000GRID2 ERROR: Old config detected. Grid2 cannot run. To remove old config type |cd0ff7d0a/script Grid2DB=nil|r |c00ff0000and restart WOW.")
	else
		self:RegisterChatCommand("grid2", "OnChatCommand")
		self:RegisterChatCommand("gr2", "OnChatCommand")
		local optionsFrame= CreateFrame( "Frame", nil, UIParent );
		optionsFrame.name = "Grid2"
		InterfaceOptions_AddCategory(optionsFrame)
		optionsFrame:SetScript("OnShow", function (self, ...)
			if not Grid2Options then Grid2:LoadGrid2Options() end
			self:SetScript("OnShow", nil)
		end)
		self.optionsFrame = optionsFrame
	end	
	self.InitializeOptions= nil
end

function Grid2:OnChatCommand(input)
    if not Grid2Options then
		Grid2:LoadGrid2Options()
	end		
	if Grid2Options then
		Grid2Options:OnChatCommand(input)
	end	
end

function Grid2:LoadGrid2Options()
	if not IsAddOnLoaded("Grid2Options") then
		LoadAddOn("Grid2Options")
	end
	if Grid2Options then
		self:LoadOptions()
		self.LoadGrid2Options= nil
	else
		Grid2:Print("You need the Grid2Options addon available to be able to configure Grid2.")
	end
end

-- Hook this to load any options addon (See RaidDebuffs)
function Grid2:LoadOptions()
	Grid2Options:Initialize()
end
--}}}

--{{ Media functions
function Grid2:MediaFetch(mediatype, key, def)
	return (key and media:Fetch(mediatype, key)) or (def and media:Fetch(mediatype, def))
end
--}}

-- Misc functions

function Grid2:HideBlizzardRaidFrames()
	CompactRaidFrameManager:UnregisterAllEvents()
	CompactRaidFrameManager:Hide()
	CompactRaidFrameContainer:UnregisterAllEvents()
	CompactRaidFrameContainer:Hide()
end

--{{{ Event handlers

function Grid2:ProfileChanged()
	self:Debug("Loaded profile (", self.db:GetCurrentProfile(),")")
	self:DisableModules()
	self:LoadConfig()
	self:UpdateModules()
	self:EnableModules()
	if Grid2Options then
		Grid2Options:MakeOptions()
	end	
end

local groupType
function Grid2:PLAYER_ENTERING_WORLD()
	-- this is needed to trigger an update when switching from one BG directly to another
	groupType = nil
	self:GroupChanged("PLAYER_ENTERING_WORLD")
	--
	if self.db.profile.hideBlizzardRaidFrames then
		Grid2:HideBlizzardRaidFrames()
	end
end

function Grid2:GroupChanged(event)
	local _, instType = IsInInstance()
	if instType == "none" then
		local raidMembers = GetNumRaidMembers()
		if     raidMembers>25 then			instType = "raid40"
		elseif raidMembers>10 then			instType = "raid25"
		elseif raidMembers>0  then			instType = "raid10"
		elseif GetNumPartyMembers()>0 then 	instType = "party"
		else								instType = "solo"
		end
	else
		if instType == "raid" then
			local dif = GetRaidDifficulty()
			instType= (dif == 2 or dif == 4) and "raid25" or "raid10"
		elseif instType == "pvp" then
			local raidMembers = GetNumRaidMembers()
			if raidMembers<11 then		instType = "raid10"
			elseif raidMembers<16 then	instType = "raid15"
			else						instType = "raid40"
			end
		else
			local raidMembers = GetNumRaidMembers()
			if raidMembers>25 then				instType = "raid40"
			elseif raidMembers>15 then			instType = "raid25"
			elseif raidMembers>10 then			instType = "raid15"
			elseif raidMembers>0 then			instType = "raid10"
			elseif GetNumPartyMembers()>0 then	instType = "party"
			else								instType = "solo"
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
