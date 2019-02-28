--[[
Created by Grid2 original authors, modified by Michael
--]]

local type = type
local next = next
local ipairs = ipairs
local tostring = tostring
local fmt = string.format

-- Initialization
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

Grid2.tooltipFunc = {}

-- AceDB defaults
Grid2.defaults = {
	profile = {
	    versions = {},
		indicators = {},
		statuses = {},
		statusMap =  {},
		themes = { names = {}, indicators = {}, enabled = {} },
	}
}

-- Type setup functions for non-unique objects: "buff" statuses / "icon" indicators / etc.
Grid2.setupFunc = {} 

-- Module prototype
local modulePrototype = {}
modulePrototype.core = Grid2
modulePrototype.Debug = Grid2.Debug

function modulePrototype:OnInitialize()
	if not self.db then
		self.db = self.core.db:RegisterNamespace(self.moduleName or self.name, self.defaultDB or {} )
	end
	self.debugFrame = Grid2.debugFrame
	self.debugging = self.db.global.debug
	if self.OnModuleInitialize then 
		self:OnModuleInitialize() 
		self.OnModuleInitialize = nil
	end
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

--  Modules management
function Grid2:EnableModules()
	for _,module in ipairs(self.orderedModules) do
		module:OnEnable()
	end
end

function Grid2:DisableModules()
	for _,module in ipairs(self.orderedModules) do
		module:OnDisable()
	end
end

function Grid2:UpdateModules()
	for _,module in ipairs(self.orderedModules) do
		module:OnUpdate()
	end
end

-- Start code
function Grid2:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("Grid2DB", self.defaults)

	self.profiles = self.db:RegisterNamespace('LibDualSpec-1.0') -- Using "LibDualSpec-1.0" namespace for backward compatibility

	self.debugging = self.db.global.debug

	self.playerClass = select(2, UnitClass("player"))
	
	local media = LibStub("LibSharedMedia-3.0", true)
	media:Register("statusbar", "Gradient", "Interface\\Addons\\Grid2\\media\\gradient32x32")
	media:Register("statusbar", "Grid2 Flat", "Interface\\Addons\\Grid2\\media\\white16x16")
	media:Register("border", "Grid2 Flat", "Interface\\Addons\\Grid2\\media\\white16x16")
	media:Register("background", "Blizzard Quest Title Highlight", "Interface\\QuestFrame\\UI-QuestTitleHighlight")
	media:Register("background", "Blizzard ChatFrame Background", "Interface\\ChatFrame\\ChatFrameBackground")
	
	self:InitializeOptions()

	self.OnInitialize = nil
end

function Grid2:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "GroupChanged")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "GroupChanged")
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("UNIT_PET")
	
	self.db.RegisterCallback(self, "OnProfileShutdown", "ProfileShutdown")
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
	self:SetupTheme()
	self:Setup()
end

-- Profiles
function Grid2:ProfileShutdown()
	self:Debug("Shutdown profile (", self.db:GetCurrentProfile(),")")
	self:SetupShutdown()
end

function Grid2:ProfileChanged()
	self:Debug("Loaded profile (", self.db:GetCurrentProfile(),")")
	self:LoadConfig()
	self:UpdateModules()
	self:RefreshOptions()
end

function Grid2:ReloadProfile()
	local db = Grid2.profiles.char
	if db.enabled then
		local pro = db[GetSpecialization() or 0] or db
		if type(pro)=="string" and pro~=Grid2.db:GetCurrentProfile() then
			if not self:RunSecure(1, self, "ReloadProfile") then
				Grid2.db:SetProfile(pro)
			end	
			return true
		end
	end	
end

function Grid2:PLAYER_SPECIALIZATION_CHANGED(_,unit)
	if unit=='player' then
		if not Grid2:ReloadProfile() then
			Grid2:ReloadTheme()
			self:SendMessage("Grid_PlayerSpecChanged") -- Send message only if profile has not changed
		end
	end
end

-- Themes
function Grid2:GetCurrentTheme()
	local index  = self.currentTheme or 0
	local themes = self.db.profile.themes
	return index, themes.names[index] or 'Default', themes.indicators[index] or {}
end

function Grid2:SetupTheme()
	self.currentTheme, self.suspendedIndicators = self:CheckTheme()
	self:UpdateTheme()
end

function Grid2:CheckTheme()
	local themes  = self.db.profile.themes
	local enabled = themes.enabled
	local theme   = enabled.default or 0
	local spec    = GetSpecialization() or 0
	local groupType, instType, maxPlayers = self:GetGroupType()
	local kM   = tostring(maxPlayers)
	local kS   = fmt("%s@%d",    self.playerClass, spec)   
	local kSM  = fmt("%s@%d",    kS, maxPlayers)
	local kSGI = fmt("%s@%s@%s", kS, groupType, instType)
	local kSG  = fmt("%s@%s",    kS, groupType)
	local kGI  = fmt("%s@%s",    groupType, instType)
	theme = enabled[kSM] or enabled[kSGI] or enabled[kSG] or enabled[kS] or enabled[kM] or enabled[kGI] or enabled[groupType] or theme
	theme = themes.names[theme] and theme or 0
	return theme, themes.indicators[theme] or {}
end

function Grid2:UpdateTheme()
	for _,module in ipairs(self.orderedModules) do
		if module.UpdateTheme then module:UpdateTheme()	end
	end
end

function Grid2:RefreshTheme()
	for _,module in ipairs(self.orderedModules) do
		if module.RefreshTheme then module:RefreshTheme() end
	end
end

function Grid2:ReloadTheme(force)
	local theme = self:CheckTheme()
	if theme ~= self.currentTheme or force then
		if not self:RunSecure(2, self, "ReloadTheme") then
			self.currentTheme = theme
			self:UpdateTheme()
			self:RefreshTheme()
			self:SendMessage("Grid_ThemeChanged", theme)
			self:Debug("ReloadTheme", theme)
		end
		return true
	end
end

-- Options
function Grid2:InitializeOptions()
	self:RegisterChatCommand("grid2", "OnChatCommand")
	self:RegisterChatCommand("gr2", "OnChatCommand")
	local optionsFrame = CreateFrame( "Frame", nil, UIParent )
	optionsFrame.name = "Grid2"
	local button = CreateFrame("BUTTON", nil, optionsFrame, "UIPanelButtonTemplate")
	button:SetText("Open Grid2 Options")
	button:SetSize(200,32)
	button:SetPoint('TOPLEFT', optionsFrame, 'TOPLEFT', 20, -20)
	button:SetScript("OnClick", function(self) 
		HideUIPanel(InterfaceOptionsFrame) 
		HideUIPanel(GameMenuFrame) 
		Grid2:OnChatCommand()
	end)
	InterfaceOptions_AddCategory(optionsFrame)
	self.optionsFrame = optionsFrame
	self.InitializeOptions = nil
end

function Grid2:LoadGrid2Options()
	if not IsAddOnLoaded("Grid2Options") then
		if InCombatLockdown() then
			Grid2:Print("Grid2Options cannot be loaded in combat.")
			return
		end
		LoadAddOn("Grid2Options")
	end
	if Grid2Options then
		self:LoadOptions()
		self.LoadGrid2Options = function() return true end
		return true
	end
	Grid2:Print("You need Grid2Options addon enabled to be able to configure Grid2.")
end

function Grid2:RefreshOptions()
	if Grid2Options then
		Grid2Options:MakeOptions()
	end	
end

function Grid2:OnChatCommand(input)
	if Grid2:LoadGrid2Options() then
		Grid2Options:OnChatCommand(input)
	end	
end

-- Hook this to load any options addon (see RaidDebuffs & AoeHeals modules)
function Grid2:LoadOptions() 
	Grid2Options:Initialize()
	Grid2.LoadOptions = nil
end
