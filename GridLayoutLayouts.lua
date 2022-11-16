--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local groupFilters = Grid2Layout.groupFilters

local DEFAULT_ROLE 		  = Grid2.versionCli<30000 and 'ROLE' or 'ASSIGNEDROLE'
local DEFAULT_ROLE_ORDER  = Grid2.versionCli<30000 and 'MAINTANK,MAINASSIST,NONE' or 'TANK,HEALER,DAMAGER,NONE'

local DEFAULT_GROUP_ORDER = "WARRIOR,DEATHKNIGHT,DEMONHUNTER,ROGUE,MONK,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER,EVOKER"
local DEFAULT_PET_ORDER   = "HUNTER,WARLOCK,MAGE,DEATHKNIGHT,DRUID,PRIEST,SHAMAN,MONK,PALADIN,DEMONHUNTER,ROGUE,WARRIOR,EVOKER"

local META_ALL   = { solo = true, party = true, arena = true, raid  = true }
local META_RAID  = { raid = true }

local PETS_GROUP = {
	type = "pet",
	maxColumns = "auto",
	groupBy = "CLASS",
	groupingOrder = DEFAULT_PET_ORDER,
}

-- general layouts

Grid2Layout:AddLayout("None", {
	meta = META_ALL,
	empty = true
})

Grid2Layout:AddLayout("By Group", {
	meta = META_ALL,
})

Grid2Layout:AddLayout("By Group w/Pets", {
	meta = META_ALL,
	[1] = "auto",
	[2] = PETS_GROUP,
})

Grid2Layout:AddLayout("By Group & Class", {
	meta = META_ALL,
	defaults = {
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		sortMethod = "NAME",
	},
})

Grid2Layout:AddLayout("By Group & Class w/Pets", {
	meta = META_ALL,
	defaults = {
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		sortMethod = "NAME",
	},
	[1] = "auto",
	[2] = PETS_GROUP,
})

Grid2Layout:AddLayout("By Class", {
	meta = META_ALL,
	[1]= {
		maxColumns = 8,
		groupFilter = "auto",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		sortMethod = "NAME",
	}
})

Grid2Layout:AddLayout("By Class w/Pets", {
	meta = META_ALL,
	[1]= {
		maxColumns = 8,
		groupFilter = "auto",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		sortMethod = "NAME",
	},
	[2] = PETS_GROUP,
})

Grid2Layout:AddLayout("By Role", {
	meta = META_ALL,
	[1] = {
		maxColumns = 8,
		groupFilter = "auto",
		groupBy = DEFAULT_ROLE,
		groupingOrder = DEFAULT_ROLE_ORDER,
		sortMethod = "NAME",
	},
})

Grid2Layout:AddLayout("By Role w/Pets", {
	meta = META_ALL,
	[1] = {
		maxColumns = 8,
		groupFilter = "auto",
		groupBy = DEFAULT_ROLE,
		groupingOrder = DEFAULT_ROLE_ORDER,
		sortMethod = "NAME",
	},
	[2] = PETS_GROUP,
})

-- raid only layouts

Grid2Layout:AddLayout("By Group & Role", {
	meta = META_RAID,
	defaults = {
		groupBy = DEFAULT_ROLE,
		groupingOrder = DEFAULT_ROLE_ORDER,
		sortMethod = "NAME",
	},
})

Grid2Layout:AddLayout("By Group & Role w/Pets", {
	meta = META_RAID,
	defaults = {
		groupBy = DEFAULT_ROLE,
		groupingOrder = DEFAULT_ROLE_ORDER,
		sortMethod = "NAME",
	},
	[1] = "auto",
	[2] = PETS_GROUP,
})
