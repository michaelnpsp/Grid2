--{{{ Libraries

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local DEFAULT_GROUP_ORDER = "WARRIOR,DEATHKNIGHT,ROGUE,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER"

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
		arena = true,
	},
	[1] = {
		type = "party",
		showPlayer = true,
		showSolo = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
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
		showPlayer = true,
		showSolo = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		type = "partypet",
		showPlayer = true,
		showSolo = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
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
	[1] = {
		showPlayer = true,
		showParty = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		showPlayer = true,
		showParty = true,
		type = "partypet",
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
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
		showPlayer = true,
		showParty = true,
		showRaid = true,
		toggleForVehicle = true,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		toggleForVehicle = true,
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
		showPlayer = true,
		showParty = true,
		showRaid = true,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
		showPlayer = true,
		showParty = true,
		showRaid = true,
	},
	[3] = {
		type = "raidpet",
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
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
		toggleForVehicle = true,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
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
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
	},
 })

Grid2Layout:AddLayout(L["By Group 25"], {
	meta = {
		raid40 = true,
		hraid = true,
		raid = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[4] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[5] = {
		groupFilter = "5",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout(L["By Group 25 w/Pets"], {
	meta = {
		raid40 = true,
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
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
	},
})

Grid2Layout:AddLayout(L["By Class 25"], {
	meta = {
		raid40 = true,
		hraid = true,
		raid = true,
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
	},
	[2] = {
		type = "raidpet",
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
		raid40 = true,
		hraid = true,
		raid = true,
		party = true,
		pvp = true,
		arena = true,
		solo = true,
	},
	[1] = {
		showSolo = true,
		showPlayer = true,
		groupFilter = "1,2,3,4,5",
		groupBy = "ROLE",
		groupingOrder = DEFAULT_GROUP_ORDER,
		unitsPerColumn = 5,
		maxColumns = 5,
	},
	[2] = {
		type = "raidpet",
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
	},
})

Grid2Layout:AddLayout(L["By Class 1 x 25 Wide"], {
	meta = {
		raid40 = true,
		hraid = true,
		raid = true,
		party = true,
		solo = true,
		pvp = true,
		arena = true,
	},
	[1] = {
		showSolo = true,
		showPlayer = true,
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		unitsPerColumn = 25,
		maxColumns = 1,
	},
	[2] = {
		type = "raidpet",
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 25,
		maxColumns = 1,
		allowVehicleTarget = true,
	},
})

Grid2Layout:AddLayout(L["By Class 2 x 15 Wide"], {
	meta = {
		raid40 = true,
		hraid = true,
		raid = true,
		party = true,
		solo = true,
		pvp = true,
		arena = true,
	},
	[1] = {
		showSolo = true,
		showPlayer = true,
		groupFilter = "1,2,3,4,5,6",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		unitsPerColumn = 15,
		maxColumns = 2,
	},
	[2] = {
		type = "raidpet",
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 15,
		maxColumns = 2,
		allowVehicleTarget = true,
	},
})

Grid2Layout:AddLayout(L["By Group 4 x 10 Wide"], {
    meta = {
        raid40 = true,
        hraid = true,
        raid = true,
        party = true,
        solo = true,
        pvp = true,
        arena = true,
    },
    [1] = {
        showSolo = true,
        showPlayer = true,
        groupFilter = "1,2",
        groupBy = "GROUP",
        groupingOrder = DEFAULT_GROUP_ORDER,
        unitsPerColumn = 10,
        maxColumns = 4,
    },
    [2] = {
        showSolo = true,
        showPlayer = true,
        groupFilter = "3,4",
        groupBy = "GROUP",
        groupingOrder = DEFAULT_GROUP_ORDER,
        unitsPerColumn = 10,
        maxColumns = 4,
    },
    [3] = {
        showSolo = true,
        showPlayer = true,
        groupFilter = "5,6",
        groupBy = "GROUP",
        groupingOrder = DEFAULT_GROUP_ORDER,
        unitsPerColumn = 10,
        maxColumns = 4,
    },
    [4] = {
        showSolo = true,
        showPlayer = true,
        groupFilter = "7,8",
        groupBy = "GROUP",
        groupingOrder = DEFAULT_GROUP_ORDER,
        unitsPerColumn = 10,
        maxColumns = 4,
    },
    [5] = {
        type = "raidpet",
        showPlayer = true,
        showParty = true,
        showRaid = true,
        unitsPerColumn = 10,
        maxColumns = 4,
        allowVehicleTarget = true,
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
		toggleForVehicle = true,
	},
	[2] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[3] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[4] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout(L["By Class"], {
	meta = {
		raid40 = true,
		hraid = true,
		raid = true,
		pvp = true,
	},
	[1] = {
		groupFilter = "WARRIOR",
		toggleForVehicle = true,
	},
	[2] = {
		groupFilter = "DEATHKNIGHT",
		toggleForVehicle = true,
	},
	[3] = {
		groupFilter = "PALADIN",
		toggleForVehicle = true,
	},
	[4] = {
		groupFilter = "DRUID",
		toggleForVehicle = true,
	},
	[5] = {
		groupFilter = "ROGUE",
		toggleForVehicle = true,
	},
	[6] = {
		groupFilter = "SHAMAN",
		toggleForVehicle = true,
	},
	[7] = {
		groupFilter = "PRIEST",
		toggleForVehicle = true,
	},
	[8] = {
		groupFilter = "MAGE",
		toggleForVehicle = true,
	},
	[9] = {
		groupFilter = "WARLOCK",
		toggleForVehicle = true,
	},
	[10] = {
		groupFilter = "HUNTER",
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout(L["By Class w/Pets"], {
	meta = {
		raid40 = true,
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
		showPlayer = true,
		showParty = true,
		showRaid = true,
		allowVehicleTarget = true,
	},
})

Grid2Layout:AddLayout(L["Onyxia"], {
	meta = {
		raid40 = true,
		hraid = true,
		raid = true,
	},
	[1] = {
		groupFilter = "1",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[2] = {
		groupFilter = "3",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[3] = {
		groupFilter = "5",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[4] = {
		groupFilter = "7",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[5] = {
		type = "spacer",
	},
	[6] = {
		groupFilter = "2",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[7] = {
		groupFilter = "4",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[8] = {
		groupFilter = "6",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
	[9] = {
		groupFilter = "8",
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout(L["By Group 25 w/tanks"], {
	meta = {
		raid40 = true,
		hraid = true,
		raid = true,
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

Grid2Layout:AddLayout(L["By Group 40"], {
	meta = {
		raid40 = true,
		hraid = true,
		raid = true,
		pvp = true,
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

