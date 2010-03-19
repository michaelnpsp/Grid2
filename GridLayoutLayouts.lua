--{{{ Libraries

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local DEFAULT_GROUP_ORDER = "WARRIOR,DEATHKNIGHT,ROGUE,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER"
local DEFAULT_PET_ORDER = "HUNTER,WARLOCK,DEATHKNIGHT,PRIEST,MAGE,DRUID,SHAMAN,WARRIOR,ROGUE,PALADIN"

--}}}

-- nameList = [STRING] -- a comma separated list of player names (not used if 'groupFilter' is set)
-- groupFilter = [1-8, STRING] -- a comma seperated list of raid group numbers and/or uppercase class names and/or uppercase roles
-- strictFiltering = [BOOLEAN] - if true, then characters must match both a group and a class from the groupFilter list
-- groupBy = [nil, "GROUP", "CLASS", "ROLE"] - specifies a "grouping" type to apply before regular sorting (Default: nil)
-- groupingOrder = [STRING] - specifies the order of the groupings (ie. "1,2,3,4,5,6,7,8")

-- useOwnerUnit = [BOOLEAN] - if true, then the owner's unit string is set on managed's frames "unit" attribute (instead of pet's)
-- filterOnPet = [BOOLEAN] - if true, then pet names are used when sorting/filtering the list

Grid2Layout:AddLayout(L["None"], {
	meta = {
		raid40 = true,
		raid25 = true,
		raid20 = true,
		raid15 = true,
		raid10 = true,
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
		arena = true,
	},
	[1] = {
		type = "party",
		groupingOrder = DEFAULT_GROUP_ORDER,
		showPlayer = true,
		showSolo = true,
		allowVehicleTarget = true,
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout(L["Solo w/Pet"], {
	meta = {
		solo = true,
		party = true,
		arena = true,
	},
	[1] = {
		type = "party",
		groupingOrder = DEFAULT_GROUP_ORDER,
		showPlayer = true,
		showSolo = true,
		allowVehicleTarget = true,
	},
	[2] = {
		type = "partypet",
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
		showSolo = true,
		allowVehicleTarget = true,
	}
})

Grid2Layout:AddLayout(L["By Group 5"], {
	meta = {
		party = true,
		arena = true,
	},
	[1] = {
		showPlayer = true,
		showParty = true,
		showRaid = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout(L["By Group 5 w/Pets"], {
	meta = {
		party = true,
		arena = true,
	},
	defaults = {
		showPlayer = true,
		showParty = true,
        allowVehicleTarget = true,
	},
	[1] = {
		groupingOrder = DEFAULT_GROUP_ORDER,
		allowVehicleTarget = true,
	},
	[2] = {
		type = "partypet",
		groupingOrder = DEFAULT_PET_ORDER,
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
	},
})

Grid2Layout:AddLayout(L["By Group 10"], {
	meta = {
		raid10 = true,
		pvp = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
		showPlayer = true,
		showParty = true,
		showRaid = true,
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
		raid10 = true,
		pvp = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		showPlayer = true,
		showParty = true,
		showRaid = true,
	},
	[1] = {
		groupFilter = "1",
	},
	[2] = {
		groupFilter = "2",
	},
	[3] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		unitsPerColumn = 5,
		maxColumns = 5,
	},
})

Grid2Layout:AddLayout(L["By Group 15"], {
	meta = {
		raid15 = true,
		raid10 = true,
		pvp = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
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
		raid15 = true,
		raid10 = true,
		pvp = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
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
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
	},
 })

Grid2Layout:AddLayout(L["By Group 25"], {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		pvp = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
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
		raid25 = true,
		raid15 = true,
		raid10 = true,
		pvp = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
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
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
	},
})

Grid2Layout:AddLayout(L["By Class 25"], {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		party = true,
		pvp = true,
		arena = true,
		solo = true,
	},
	[1] = {
		showSolo = true,
		showPlayer = true,
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
	},
	[2] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
	},
})

Grid2Layout:AddLayout(L["By Role 25"], {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		party = true,
		pvp = true,
		arena = true,
		solo = true,
	},
	defaults = {
		showSolo = true,
		showParty = true,
		showRaid = true,
        allowVehicleTarget = true,
	},
	[1] = {
		groupFilter = "1,2,3,4,5",
		groupBy = "ROLE",
		groupFilter = "MAINTANK,MAINASSIST", 
		groupingOrder = "MAINTANK,MAINASSIST", 
		unitsPerColumn = 5,
		maxColumns = 1,
	},
	[2] = {
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER, 
		unitsPerColumn = 5,
		maxColumns = 5,
	},
	[3] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		unitsPerColumn = 5,
		maxColumns = 5,
	},
})

Grid2Layout:AddLayout(L["By Class 1 x 25 Wide"], {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		party = true,
		solo = true,
		pvp = true,
		arena = true,
	},
	defaults = {
		showSolo = true,
		showParty = true,
		showRaid = true,
        allowVehicleTarget = true,
	},
	[1] = {
		groupingOrder = DEFAULT_GROUP_ORDER,
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
		unitsPerColumn = 25,
		maxColumns = 1,
	},
	[2] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		unitsPerColumn = 25,
		maxColumns = 1,
	},
})

Grid2Layout:AddLayout(L["By Class 2 x 15 Wide"], {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		party = true,
		solo = true,
		pvp = true,
		arena = true,
	},
	defaults = {
		showSolo = true,
		showParty = true,
		showRaid = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
	},
	[1] = {
		groupFilter = "1,2,3,4,5,6",
		groupBy = "CLASS",
		unitsPerColumn = 15,
		maxColumns = 2,
	},
	[2] = {
		type = "raidpet",
		unitsPerColumn = 15,
		maxColumns = 2,
	},
})

Grid2Layout:AddLayout(L["By Group 4 x 10 Wide"], {
    meta = {
		raid40 = true,
		raid25 = true,
		raid15 = true,
		raid10 = true,
        party = true,
        solo = true,
        pvp = true,
        arena = true,
    },
 	defaults = {
		showSolo = true,
		showParty = true,
		showRaid = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
	},
   [1] = {
        groupFilter = "1,2",
        groupBy = "GROUP",
        unitsPerColumn = 10,
        maxColumns = 4,
    },
    [2] = {
        groupFilter = "3,4",
        groupBy = "GROUP",
        unitsPerColumn = 10,
        maxColumns = 4,
    },
    [3] = {
        groupFilter = "5,6",
        groupBy = "GROUP",
        unitsPerColumn = 10,
        maxColumns = 4,
    },
    [4] = {
        groupFilter = "7,8",
        groupBy = "GROUP",
        unitsPerColumn = 10,
        maxColumns = 4,
    },
    [5] = {
        type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
        unitsPerColumn = 10,
        maxColumns = 4,
    },

})

Grid2Layout:AddLayout(L["By Group 20"], {
	meta = {
		raid20 = true,
		raid15 = true,
		raid10 = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
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

Grid2Layout:AddLayout(L["By Class"], {
	meta = {
		raid40 = true,
		raid25 = true,
		raid15 = true,
		raid10 = true,
		pvp = true,
	},
	defaults = {
        allowVehicleTarget = true,
		toggleForVehicle = true,
		showParty = true,
		showRaid = true,
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
		raid40 = true,
		raid25 = true,
		raid15 = true,
		raid10 = true,
		pvp = true,
	},
	defaults = {
        allowVehicleTarget = true,
		showParty = true,
		showRaid = true,
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
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
	},
})

Grid2Layout:AddLayout(L["By Group 25 w/tanks"], {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		pvp = true,
	},
	defaults = {
		showParty = true,
		showRaid = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1] = {
		groupFilter = "MAINTANK,MAINASSIST",
		groupingOrder = "MAINTANK,MAINASSIST",
	},
	[2] = {
		type = "spacer",
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

Grid2Layout:AddLayout(L["By Group 40"], {
	meta = {
		raid40 = true,
		raid25 = true,
		raid15 = true,
		raid10 = true,
		pvp = true,
	},
	defaults = {
		showParty = true,
		showRaid = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
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

