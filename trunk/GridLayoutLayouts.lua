--{{{ Libraries

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local DEFAULT_PET_GROUPFILTER = "HUNTER,DEATHKNIGHT,WARLOCK"
local DEFAULT_GROUP_ORDER = "WARRIOR,DEATHKNIGHT,ROGUE,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER"

--DEFAULT_PET_GROUPFILTER = nil -- for testing purpose
--}}}

Grid2Layout:AddLayout(L["None"], {
	meta = {
		hraid = true,
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
		hraid = true,
		raid = true,
		pvp = true,
	},
	defaults = {
		-- type = "raid", (can be "party", "partypet", "raid", "raidpet", "spacer")
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
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[4] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[5] = {
		groupFilter = "5",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[6] = {
		groupFilter = "6",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[7] = {
		groupFilter = "7",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[8] = {
		groupFilter = "8",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
})

Grid2Layout:AddLayout(L["By Group 25"], {
	meta = {
		hraid = true,
		raid = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[4] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[5] = {
		groupFilter = "5",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
})

Grid2Layout:AddLayout(L["By Class 25"], {
	meta = {
		hraid = true,
		raid = true,
		party = true,
		pvp = true,
		arena = true,
		solo = true,
	},
	[1] = {
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		unitsPerColumn = 5,
		maxColumns = 5,
	},
	[2] = {
		type = "raidpet",
		groupFilter = DEFAULT_PET_GROUPFILTER,
		unitsPerColumn = 5,
		maxColumns = 5,
		filterOnPet = true,
	},
})

Grid2Layout:AddLayout(L["By Group 25 w/Pets"], {
	meta = {
		hraid = true,
		raid = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[4] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[5] = {
		groupFilter = "5",
		groupingOrder = DEFAULT_GROUP_ORDER,
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
		hraid = true,
		raid = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[4] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
})

Grid2Layout:AddLayout(L["By Group 15"], {
	meta = {
		hraid = true,
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
})

Grid2Layout:AddLayout(L["By Group 15 w/Pets"], {
	meta = {
		hraid = true,
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
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
		hraid = true,
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
})

Grid2Layout:AddLayout(L["By Group 10 w/Pets"], {
	meta = {
		hraid = true,
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
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
		party = true,
		arena = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
})

Grid2Layout:AddLayout(L["By Group 5 w/Pets"], {
	meta = {
		party = true,
		arena = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
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
		hraid = true,
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "WARRIOR",
	},
	[2] = {
		groupFilter = "DEATHKNIGHT",
	},
	[3] = {
		groupFilter = "PALADIN",
	},
	[4] = {
		groupFilter = "DRUID",
	},
	[5] = {
		groupFilter = "ROGUE",
	},
	[6] = {
		groupFilter = "SHAMAN",
	},
	[7] = {
		groupFilter = "PRIEST",
	},
	[8] = {
		groupFilter = "MAGE",
	},
	[9] = {
		groupFilter = "WARLOCK",
	},
	[10] = {
		groupFilter = "HUNTER",
	},
})

Grid2Layout:AddLayout(L["By Class w/Pets"], {
	meta = {
		hraid = true,
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "WARRIOR",
	},
	[2] = {
		groupFilter = "DEATHKNIGHT",
	},
	[3] = {
		groupFilter = "PALADIN",
	},
	[4] = {
		groupFilter = "DRUID",
	},
	[5] = {
		groupFilter = "ROGUE",
	},
	[6] = {
		groupFilter = "SHAMAN",
	},
	[7] = {
		groupFilter = "PRIEST",
	},
	[8] = {
		groupFilter = "MAGE",
	},
	[9] = {
		groupFilter = "WARLOCK",
	},
	[10] = {
		groupFilter = "HUNTER",
	},
	[11] = {
		type = "raidpet",
		groupFilter = DEFAULT_PET_GROUPFILTER,
		filterOnPet = true,
	},
})

Grid2Layout:AddLayout(L["Onyxia"], {
	meta = {
		hraid = true,
		raid = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[3] = {
		groupFilter = "5",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[4] = {
		groupFilter = "7",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[5] = {
		type  = "spacer",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[6] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[7] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[8] = {
		groupFilter = "6",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[9] = {
		groupFilter = "8",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
})

Grid2Layout:AddLayout(L["By Group 25 w/tanks"], {
	meta = {
		hraid = true,
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
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[4] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[5] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[6] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[7] = {
		groupFilter = "5",
		groupingOrder = DEFAULT_GROUP_ORDER,
	}
})
