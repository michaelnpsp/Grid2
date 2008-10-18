--{{{ Libraries

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local DEFAULT_PET_GROUPFILTER = "WARLOCK,HUNTER"

DEFAULT_PET_GROUPFILTER = nil -- for testing purpose
--}}}

Grid2Layout:AddLayout(L["None"], {
	meta = {
		raid = true,
		party = true,
		pvp = true,
		arena = true,
		solo = true,
	},
})

Grid2Layout:AddLayout(L["Solo"], {
	meta = {
		solo = true,
		party = true,
	},
	[1] = {
		type = "party",
		showPlayer = true,
		showSolo = true,
	},
})

Grid2Layout:AddLayout(L["Solo w/Pet"], {
	meta = {
		solo = true,
		party = true,
	},
	[1] = {
		type = "party",
		showPlayer = true,
		showSolo = true,
	},
	[2] = {
		type = "partypet",
		groupFilter = DEFAULT_PET_GROUPFILTER,
		showPlayer = true,
		showSolo = true,
	}
})



Grid2Layout:AddLayout(L["By Group 40"], {
	meta = {
		raid = true,
		pvp = true,
	},
	defaults = {
		-- type = "raid", (can be "party", "partypet", "raid" or "raidpet")
		-- nameList = "",
		-- groupFilter = "",
		-- sortMethod = "INDEX", -- or "NAME"
		-- sortDir = "ASC", -- or "DESC"
		-- strictFiltering = false,
		-- unitsPerColumn = 5, -- treated specifically to do the right thing when available
		-- maxColumns = 5, -- mandatory if unitsPerColumn is set, or defaults to 1
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "2",
	},
	[3] = {
		groupFilter = "3",
	},
	[4] = {
		groupFilter = "4",
	},
	[5] = {
		groupFilter = "5",
	},
	[6] = {
		groupFilter = "6",
	},
	[7] = {
		groupFilter = "7",
	},
	[8] = {
		groupFilter = "8",
	},
})

Grid2Layout:AddLayout(L["By Group 25"], {
	meta = {
		raid = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "2",
	},
	[3] = {
		groupFilter = "3",
	},
	[4] = {
		groupFilter = "4",
	},
	[5] = {
		groupFilter = "5",
	},
})

Grid2Layout:AddLayout(L["By Group 25 w/Pets"], {
	meta = {
		raid = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "2",
	},
	[3] = {
		groupFilter = "3",
	},
	[4] = {
		groupFilter = "4",
	},
	[5] = {
		groupFilter = "5",
	},
	[6] = {
		type = "raidpet",
		groupFilter = DEFAULT_PET_GROUPFILTER,
		unitsPerColumn = 5,
		maxColumns = 5,
		filterOnPet = true,
	},
})

Grid2Layout:AddLayout(L["By Group 20"], {
	meta = {
		raid = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "2",
	},
	[3] = {
		groupFilter = "3",
	},
	[4] = {
		groupFilter = "4",
	},
})

Grid2Layout:AddLayout(L["By Group 15"], {
	meta = {
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "2",
	},
	[3] = {
		groupFilter = "3",
	},
})

Grid2Layout:AddLayout(L["By Group 15 w/Pets"], {
	meta = {
		raid = true,
		pvp = true,
	},
	 [1] = {
		 groupFilter = "1",
	 },
	 [2] = {
		 groupFilter = "2",
	 },
	 [3] = {
		 groupFilter = "3",
	 },
	 [4] = {
		type = "raidpet",
		groupFilter = DEFAULT_PET_GROUPFILTER,
		unitsPerColumn = 5,
		maxColumns = 5,
		filterOnPet = true,
	 },
 })

Grid2Layout:AddLayout(L["By Group 10"], {
	meta = {
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "2",
	},
})

Grid2Layout:AddLayout(L["By Group 10 w/Pets"], {
	meta = {
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "2",
	},
	[3] = {
		type = "raidpet",
		groupFilter = DEFAULT_PET_GROUPFILTER,
		unitsPerColumn = 5,
		maxColumns = 5,
		filterOnPet = true,
	},
})

Grid2Layout:AddLayout(L["By Group 5"], {
	meta = {
		raid = true,
		arena = true,
	},
	[1] = {
		groupFilter = "1",
	},
})

Grid2Layout:AddLayout(L["By Group 5 w/Pets"], {
	meta = {
		raid = true,
		arena = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		type = "raidpet",
		groupFilter = DEFAULT_PET_GROUPFILTER,
		unitsPerColumn = 5,
		maxColumns = 5,
		filterOnPet = true,
	},
})

Grid2Layout:AddLayout(L["By Class"], {
	meta = {
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "WARRIOR",
	},
	[2] = {
		groupFilter = "PRIEST",
	},
	[3] = {
		groupFilter = "DRUID",
	},
	[4] = {
		groupFilter = "PALADIN",
	},
	[5] = {
		groupFilter = "SHAMAN",
	},
	[6] = {
		groupFilter = "MAGE",
	},
	[7] = {
		groupFilter = "WARLOCK",
	},
	[8] = {
		groupFilter = "HUNTER",
	},
	[9] = {
		groupFilter = "ROGUE",
	},
})

Grid2Layout:AddLayout(L["By Class w/Pets"], {
	meta = {
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "WARRIOR",
	},
	[2] = {
		groupFilter = "PRIEST",
	},
	[3] = {
		groupFilter = "DRUID",
	},
	[4] = {
		groupFilter = "PALADIN",
	},
	[5] = {
		groupFilter = "SHAMAN",
	},
	[6] = {
		groupFilter = "MAGE",
	},
	[7] = {
		groupFilter = "WARLOCK",
	},
	[8] = {
		groupFilter = "HUNTER",
	},
	[9] = {
		groupFilter = "ROGUE",
	},
	[10] = {
		type = "raidpet",
		groupFilter = DEFAULT_PET_GROUPFILTER,
		filterOnPet = true,
	},
})

Grid2Layout:AddLayout(L["Onyxia"], {
	meta = {
		raid = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "3",
	},
	[3] = {
		groupFilter = "5",
	},
	[4] = {
		groupFilter = "7",
	},
	[5] = {
		type  = "spacer",
	},
	[6] = {
		groupFilter = "2",
	},
	[7] = {
		groupFilter = "4",
	},
	[8] = {
		groupFilter = "6",
	},
	[9] = {
		groupFilter = "8",
	},
})

Grid2Layout:AddLayout(L["By Group 25 w/tanks"], {
	meta = {
		raid = true,
	},
	[1] = {
		groupFilter = "MAINTANK,MAINASSIST",
		groupingOrder = "MAINTANK,MAINASSIST",
	},
	[2] = {
		type  = "spacer",
	},
	[3] = {
		groupFilter = "1",
	},
	[4] = {
		groupFilter = "2",
	},
	[5] = {
		groupFilter = "3",
	},
	[6] = {
		groupFilter = "4",
	},
	[7] = {
		groupFilter = "5",
	}
})
