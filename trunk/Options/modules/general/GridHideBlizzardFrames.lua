--[[
	General -> Misc Tab -> Hide Raid Frames section
--]]

local L = Grid2Options.L

local addons = { "Blizzard_CompactRaidFrames", "Blizzard_CUFProfiles" }

Grid2Options:AddGeneralOptions( "Misc", "Blizzard Raid Frames", {
	hideBlizzardRaidFrames = {
		type = "toggle",
		name = L["Hide Blizzard Raid Frames."],
		desc = L["Hide Blizzard Raid Frames."],
		width = "full",
		order = 120,
		get = function () return not IsAddOnLoaded( addons[1] ) end,
		set = function (_, v)
			local func = v and DisableAddOn or EnableAddOn 
			for _, v in pairs(addons) do 
				func(v) 
			end 
			ReloadUI()
		end,
		confirm = function() return "UI will be reloaded. Are your sure ?" end,
	},
})
