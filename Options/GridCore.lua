local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
--{{{ Grid2 AceOptions table

Grid2Options.options.Grid2 = {
	type = "group",
	handler = Grid2,
	args = {
--[[
		["DebugHeader"] = {
			type = "header",
			order = 104,
			name = L["Debug"],
		},
--]]
		["debug"] = {
			type = "group",
			name = L["Debugging"],
			desc = L["Module debugging menu."],
			order = 1005,
			args = {},
		},
	},
}


--}}}
