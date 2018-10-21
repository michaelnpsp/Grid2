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

-- Declare some variables for fast access to main sections options.
for k,o in pairs(Grid2Options.options.args) do
	Grid2Options[k..'Options'] = o.args
end

-- Initialize
function Grid2Options:Initialize()
	self.db = Grid2.db:RegisterNamespace("Grid2Options",  { profile = { L = { indicators = {} } } } )
	self:EnableLoadOnDemand(not Grid2.db.global.LoadOnDemandDisabled)
	self:MakeOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Grid2", self.options)
	self.Initialize = nil
end

-- Called from Grid2 core if profile changes
function Grid2Options:MakeOptions()
	self.LI = self.db.profile.L.indicators
	self:MakeThemesOptions(self.themesOptions)
	self:MakeStatusesOptions(self.statusesOptions)
	self:MakeIndicatorsOptions(self.indicatorsOptions)
	collectgarbage("collect")
end

function Grid2Options:OnChatCommand(input)
	local dialog = LibStub("AceConfigDialog-3.0")
	if dialog.OpenFrames["Grid2"] then
		dialog:Close("Grid2")
	else
		dialog:Open("Grid2")
	end
end

--{{
_G.Grid2Options = Grid2Options
--}}
