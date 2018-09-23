--[[
Created by Grid2 original authors, modified by Michael
--]]

--{{{ Libraries

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local groupFilters = Grid2Layout.groupFilters
local DEFAULT_GROUP_ORDER = "WARRIOR,DEATHKNIGHT,ROGUE,MONK,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER"
local DEFAULT_PET_ORDER = "HUNTER,WARLOCK,DEATHKNIGHT,MAGE,PRIEST,DRUID,SHAMAN,WARRIOR,ROGUE,PALADIN,MONK"


Grid2Layout:AddLayout("None", {
	meta = {
		raid  = true,
		party = true,
		arena = true,
		solo  = true,
	},
	empty = true
})

Grid2Layout:AddLayout("Solo", {
	meta = {
		solo = true,
	},
	[1] = {
		groupingOrder = DEFAULT_GROUP_ORDER,
		allowVehicleTarget = true,
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout("Solo w/Pet", {
	meta = {
		solo = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
		allowVehicleTarget = true,
	},
	[1] = {},
	[2] = { type = "pet" }
})

Grid2Layout:AddLayout("Party", {
	meta = {
		solo = true,
		party = true,
		arena = true,
	},
	defaults = {
        allowVehicleTarget = true,
	},
	[1] = {
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
})

Grid2Layout:AddLayout("Party w/Pets", {
	meta = {
		solo = true,
		party = true,
		arena = true,
	},
	defaults = {
        allowVehicleTarget = true,
	},
	[1] = {
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		type = "pet",
		groupingOrder = DEFAULT_PET_ORDER,
		unitsPerColumn = 5,
		maxColumns = 1,
	},
})

Grid2Layout:AddLayout("By Class", {
	meta = {
		solo = true,
		party = true,
		raid = true,
		arena = true,
	},
	defaults = {
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1]= {
		groupFilter = "auto",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		unitsPerColumn = 5,
		maxColumns = 8,
	}
})

Grid2Layout:AddLayout("By Class w/Pets", {
	meta = {
		solo = true,
		party = true,
		raid = true,
		arena = true,
	},
	defaults = {
        allowVehicleTarget = true,
		unitsPerColumn = 5,
		maxColumns = 8,
		groupBy = "CLASS",
	},
	[1]= {
		groupFilter = "auto",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		type = "pet",
		groupingOrder = DEFAULT_PET_ORDER,
	},
})

Grid2Layout:AddLayout("By Group w/Tanks", {
	meta = {
		raid = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1] = {
		groupFilter = "MAINTANK,MAINASSIST",
		groupingOrder = "MAINTANK,MAINASSIST",
	},
	[2] = "auto",
})

Grid2Layout:AddLayout("By Group", {
	meta = {
		raid = true,
		arena = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	}
})

Grid2Layout:AddLayout("By Group w/Pets", {
	meta = {
		raid = true,
		arena = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
	},
	[1] = "auto",
	[2] = {
		type = "pet",
		groupingOrder = DEFAULT_PET_ORDER,
		unitsPerColumn = 5,
		maxColumns = 3,
	},
})

Grid2Layout:AddLayout("By Group & Role", {
	meta = {
		raid = true,
	},
	defaults = {
		unitsPerColumn = 5,
        allowVehicleTarget = true,
		toggleForVehicle = true,
		groupBy = "ASSIGNEDROLE",
		groupingOrder = "TANK,HEALER,DAMAGER,NONE",
	},
})

Grid2Layout:AddLayout("By Role", {
	meta = {
		solo  = true,
		raid  = true,
		party = true,
		arena = true,
	},
	defaults = {
        allowVehicleTarget = true,
		unitsPerColumn = 5,
		maxColumns = 8
	},
	[1] = {
		groupFilter = "auto",
		groupBy = "ASSIGNEDROLE",
		groupingOrder = "TANK,HEALER,DAMAGER,NONE",
	},
})

Grid2Layout:AddLayout("By Role w/Pets", {
	meta = {
		solo  = true,
		raid  = true,
		party = true,
		arena = true,
	},
	defaults = {
        allowVehicleTarget = true,
		unitsPerColumn = 5,
		maxColumns = 8
	},
	[1] = {
		groupFilter = "auto",
		groupBy = "ASSIGNEDROLE",
		groupingOrder = "TANK,HEALER,DAMAGER,NONE",
	},
	[2] = {
		type = "pet",
	},
})

Grid2Layout:AddLayout("By Class | 1x25", {
	meta = {
		raid = true,
	},
	defaults = {
        allowVehicleTarget = true,
		unitsPerColumn = 25,
		maxColumns = 1,
	},
	[1] = {
		groupingOrder = DEFAULT_GROUP_ORDER,
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
	},
	[2] = {
		type = "pet",
		groupingOrder = DEFAULT_PET_ORDER,
	},
})

Grid2Layout:AddLayout("By Class | 2x15", {
	meta = {
		raid  = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		unitsPerColumn = 15,
		maxColumns = 2,
	},
	[1] = {
		groupFilter = "1,2,3,4,5,6",
		groupBy = "CLASS",
	},
	[2] = {
		type = "pet",
	},
})

Grid2Layout:AddLayout("By Group | 40", {
	meta = {
		raid = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = groupFilters[3],
	[4] = groupFilters[4],
	[5] = groupFilters[5],
	[6] = groupFilters[6],
	[7] = groupFilters[7],
	[8] = groupFilters[8],
})

Grid2Layout:AddLayout("By Group | 40 w/Pets", {
	meta = {
		raid = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = groupFilters[3],
	[4] = groupFilters[4],
	[5] = groupFilters[5],
	[6] = groupFilters[6],
	[7] = groupFilters[7],
	[8] = groupFilters[8],
    [9] = {
        type = "pet",
		groupingOrder = DEFAULT_PET_ORDER,
    },
})

Grid2Layout:AddLayout("By Group | 4x10", {
    meta = {
		raid = true,
    },
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
        groupBy = "GROUP",
        unitsPerColumn = 10,
        maxColumns = 1,
	},
    [1] = { groupFilter = "1,2" },
    [2] = { groupFilter = "3,4" },
    [3] = { groupFilter = "5,6" },
    [4] = { groupFilter = "7,8" },
})

Grid2Layout:AddLayout("By Group | 4x10 w/Pets", {
	meta = {
		raid = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
		allowVehicleTarget = true,
		groupBy = "GROUP",
		unitsPerColumn = 10,
		maxColumns = 1,
	},
	[1] = { groupFilter = "1,2" },
	[2] = { groupFilter = "3,4" },
	[3] = { groupFilter = "5,6" },
	[4] = { groupFilter = "7,8" },
	[5] = {
		type = "pet",
		groupingOrder = DEFAULT_PET_ORDER,
	},
})

Grid2Layout:AddLayout("By Role 10x", {
	meta = {
		raid  = true,
	},
	defaults = {
        allowVehicleTarget = true,
		unitsPerColumn = 10,
		maxColumns = 8
	},
	[1] = {
		groupFilter = "auto",
		groupBy = "ASSIGNEDROLE",
		groupingOrder = "TANK,HEALER,DAMAGER,NONE",
	},
})
