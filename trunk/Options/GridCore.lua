local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
--{{{ Grid2 AceOptions table

Grid2Options.options.Grid2 = {
	type = "group",
	handler = Grid2,
	args = {
		["General"] = {
			order = 1,
			type = "group",
			name = L["General Settings"],
			desc = L["General Settings"],
			args = {
				version = {
					order = 10,
					type = "description",
					name = Grid2.versionstring,
				},
				intro = {
					order = 20,
					type = "description",
					name = L["GRID2_DESC"],
				},
			},
		},

		["debug"] = {
			type = "group",
			name = L["debugging"],
			desc = L["Module debugging menu."],
			order = 1005,
			args = {},
		},
	},
}

--}}}
