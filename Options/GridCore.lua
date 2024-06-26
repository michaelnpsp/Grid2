--[[
Created by Grid2 original authors, modified by Michael
--]]

local L  = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local LG = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local Grid2Options = {
	options = {
		name = "Grid2",
		type = "group",
		handler = Grid2,
		args = {
			general = {
				order = 10,
				type = "group",
				name = L["General"],
				desc = L["General"],
				childGroups = "tab",
				args = {},
			},
			themes = {
				order = 30,
				type = "group",
				name = L["Themes"],
				desc = L["Themes"],
				args = {},
				hidden = function() return not Grid2Frame.dba.profile.extraThemes end,
			},
			indicators = {
				order = 40,
				type = "group",
				name = L["indicators"],
				desc = L["indicators"],
				args = {},

			},
			statuses = {
				order = 50,
				type = "group",
				name = L["statuses"],
				desc = L["statuses"],
				args = {},
			},
		},
	},
	typeMakeOptions = {},
	optionParams = {},
	L  = L,
	LG = LG,
	SpellEditDialogControl = type(LibStub("AceGUI-3.0").WidgetVersions["Aura_EditBox"]) == "number" and "Aura_EditBox" or nil,
}

-- AceDB defaults
Grid2Options.defaults = {
	profile = {
		L = {
			indicators = {},
		}
	}
}

-- Declare some variables for fast access to main sections options.
-- generalOptions, themesOptions, indicatorsOptions, statusesOptions
for k,o in pairs(Grid2Options.options.args) do
	Grid2Options[k..'Options'] = o.args
end

-- Initialize
function Grid2Options:Initialize()
	self.db = Grid2.db:RegisterNamespace("Grid2Options", self.defaults)
	self:EnableLoadOnDemand(true) -- (not Grid2.db.global.LoadOnDemandDisabled)
	self:MakeOptions()
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Grid2", self.options, true)
	LibStub("AceConfigDialog-3.0"):SetDefaultSize("Grid2", 735, 585)
	self.Initialize = nil
end

-- Called from Grid2 core if profile changes
function Grid2Options:MakeOptions()
	self.LI = self.db.profile.L.indicators
	self:SetEditedTheme()
	self:MakeThemesOptions(self.themesOptions)
	self:MakeStatusesOptions(self.statusesOptions)
	self:MakeIndicatorsOptions(self.indicatorsOptions)
	collectgarbage("collect")
end

function Grid2Options:OnChatCommand()
	if self.optionsFrame then
		self.optionsFrame:Hide()
	else
		self.optionsFrame = LibStub("AceGUI-3.0"):Create('Grid2OptionsFrame')
		self.optionsFrame:SetCallback("OnClose", function(f)
			LibStub("AceGUI-3.0"):Release(f)
			self.optionsFrame = nil
		end)
		LibStub("AceConfigDialog-3.0"):Open("Grid2", self.optionsFrame)
	end
end

--{{
_G.Grid2Options = Grid2Options
--}}
