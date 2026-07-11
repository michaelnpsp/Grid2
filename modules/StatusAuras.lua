-- buffs and debuffs statuses for midnight
if Grid2.versionCli<120100 then return end

local Grid2 = Grid2

-------------------------------------------------------------------------------
-- Dispel Type colors
-------------------------------------------------------------------------------

Grid2.DispelCurveDefaults = {
	None    = { 0,  DEBUFF_TYPE_NONE_COLOR    },
	Magic   = { 1,  DEBUFF_TYPE_MAGIC_COLOR   },
	Curse   = { 2,  DEBUFF_TYPE_CURSE_COLOR   },
	Disease = { 3,  DEBUFF_TYPE_DISEASE_COLOR },
	Poison  = { 4,  DEBUFF_TYPE_POISON_COLOR  },
	Enrage  = { 9,  DEBUFF_TYPE_BLEED_COLOR   },
	Bleed   = { 11, DEBUFF_TYPE_BLEED_COLOR   },
}

-------------------------------------------------------------------------------
-- shared methods
-------------------------------------------------------------------------------

local function Auras_IsActive()
	return false
end

local function Auras_UpdateDB(self)
	local dbx = self.dbx
	local filter = dbx.aura_filter or {}
	-- color
	local r,g,b,a = Grid2:UnpackColor(dbx.color1 or Grid2.defaultColors.BLACK)
	self.GetColor = function() return r, g, b, a end
	-- aura filter
	local aura_filter = filter.filter or self.defFilter
	local aura_sortDir = filter.sortDir or 0
	local aura_sortRule = filter.sortRule or 0
	self.GetAurasFilter = function() return aura_filter, aura_sortRule, aura_sortDir end
end

local function Auras_Create(baseKey, dbx, defFilter, status)
	status = status or Grid2.statusPrototype:new(baseKey)
	status.isAura = true
	status.defFilter = defFilter
	status.IsActive = Auras_IsActive
	status.UpdateDB = Auras_UpdateDB
	Grid2:RegisterStatus(status, { "icons", "icon", "color", "tooltip" }, baseKey, dbx)
	return status
end

-------------------------------------------------------------------------------
-- midnight-buffs status
-------------------------------------------------------------------------------

Grid2.setupFunc["mbuffs"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, "HELPFUL")
end

--[[ mbuffs database format
 type = "mbuffs",
 aura_filter = { filter='HELPFUL|RAID|PLAYER', sortRule=3, sortDir=0 },
 color1 = {r=0, g=1, b=0, a=1}
--]]

-------------------------------------------------------------------------------
-- midnight-debuffs status
-------------------------------------------------------------------------------

Grid2.setupFunc["mdebuffs"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, "HARMFUL")
end

--[[ mdebuffs database format
	type = "mdebuffs",
	aura_filter = { filter = 'HARMFUL' ],
	color1 = {r=0, g=1, b=0, a=1}
--]]

-------------------------------------------------------------------------------
-- midnight debuffs-dispellablebyme status
-------------------------------------------------------------------------------

local DebuffsDispell = Grid2.statusPrototype:new("debuffs-DispellableByMe")

Grid2.setupFunc["mdebuffType"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, "HARMFUL|RAID_PLAYER_DISPELLABLE", DebuffsDispell)
end

Grid2:DbSetStatusDefaultValue( "debuffs-DispellableByMe", {type = "mdebuffType", subType = "DispellableByMe", colors = {}} )
