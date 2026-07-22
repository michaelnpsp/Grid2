-- buffs and debuffs statuses for midnight
if Grid2.versionCli<120100 then return end

local Grid2 = Grid2

local CopyTable = Grid2.CopyTable

-------------------------------------------------------------------------------
-- Dispel Type colors
-------------------------------------------------------------------------------

Grid2.DispelCurveDefaults = {
	['']    = { 0,  DEBUFF_TYPE_NONE_COLOR    },
	Magic   = { 1,  DEBUFF_TYPE_MAGIC_COLOR   },
	Curse   = { 2,  DEBUFF_TYPE_CURSE_COLOR   },
	Disease = { 3,  DEBUFF_TYPE_DISEASE_COLOR },
	Poison  = { 4,  DEBUFF_TYPE_POISON_COLOR  },
	Enrage  = { 9,  DEBUFF_TYPE_BLEED_COLOR   },
	Bleed   = { 11, DEBUFF_TYPE_BLEED_COLOR   },
}

Grid2.DispelBorderDefaults = {
	showIcon = true,
	showWhenHarmful = true,
	showWhenHelpful = true,
	showWithoutDispelType = true,
	style = 1 -- Atlas = 0, Color = 1
}

-------------------------------------------------------------------------------
-- shared methods
-------------------------------------------------------------------------------

local function GetSpellIDsTable(dbx)
	local r = nil
	if dbx.auras then -- buffs/mbuffs/mdebufs statuses
		r = {}
		for _,spell in ipairs(dbx.auras) do
			r[spell] = true
		end
	elseif dbx.spellName then -- buff status
		r = { [dbx.spellName] = true }
	end
	return r
end

local function Auras_IsActive()
	return false
end

local function Auras_GetAurasFilter(self)
	return self.aura_filter
end

local function Auras_UpdateDB(self)
	local dbx = self.dbx
	local typ = dbx.type
	-- aura filter
	local filter = CopyTable( self.defaults, CopyTable(dbx.aura_filter or {}) )
	--[[
	if typ=='buff' then
		filter.maxAuras = 1
		filter.filter=  (dbx.mine==1 and 'HELPFUL|PLAYER') or (dbx.mine==2 and 'HELPFUL|!PLAYER') or 'HELPFUL'
	elseif typ=='buffs' then
		filter.maxAuras = filter.maxAuras or math.huge
		filter.filter=  (dbx.mine==1 and 'HELPFUL|PLAYER') or (dbx.mine==2 and 'HELPFUL|!PLAYER') or 'HELPFUL'
	else -- mbuffs/mdebuffs
		filter.maxAuras = filter.maxAuras or math.huge
		filter.filter = filter.filter or self.defFilter
	end
	--]]
	-- spells table
	local spells = GetSpellIDsTable(dbx)
	if spells then
		filter.candidateFilters = filter.candidateFilters or {}
		if filter.candidateFilters.excludeSpellIDs then
			filter.candidateFilters.excludeSpellIDs = spells
		else
			filter.candidateFilters.includeSpellIDs = spells
		end
	end
	-- aura type colors
 	local colorMap, defColor = {}
	if dbx.color1 then -- single buff
		defColor = dbx.color1 or Grid2.defaultColors.BLACK
		colorMap[""] = defColor
	else
		local colors = dbx.colors
		for typ, data in pairs(Grid2.DispelCurveDefaults) do
			colorMap[typ] = (colors and colors[typ]) or data[2]
		end
		defColor = colorMap['']
	end
	filter.borderOptions = CopyTable( Grid2.DispelBorderDefaults, {customDispelColorMap = colorMap} )
	-- default status color
	local r, g, b, a = Grid2.UnpackColor(defColor)
	self.GetColor = function() return r, g, b, a end
	-- save filter table
	self.aura_filter = filter
end

local function Auras_Create(baseKey, dbx, defaults, status)
	status = status or Grid2.statusPrototype:new(baseKey)
	status.isAura = true
	status.defaults= defaults
	status.IsActive = Auras_IsActive
	status.UpdateDB = Auras_UpdateDB
	status.GetAurasFilter = Auras_GetAurasFilter
	Grid2:RegisterStatus(status, { "icons", "icon", "color" }, baseKey, dbx)
	return status
end

-------------------------------------------------------------------------------
-- midnight-buffs status
-------------------------------------------------------------------------------
--[[
Grid2.setupFunc["buff"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, "HELPFUL")
end

Grid2.setupFunc["buffs"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, "HELPFUL")
end
--]]

local DEFAULTS = { filter = 'HELPFUL', maxAuras = 1 }
Grid2.setupFunc["mbuff"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, DEFAULTS)
end

local DEFAULTS = { filter = 'HELPFUL', maxAuras = 64 }
Grid2.setupFunc["mbuffs"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, DEFAULTS)
end

--[[ mbuffs database format
 type = "mbuffs",
 aura_filter = { filter='HELPFUL|RAID|PLAYER', sortRule=3, sortDir=0 },
 color1 = {r=0, g=1, b=0, a=1}
--]]

-------------------------------------------------------------------------------
-- midnight-debuffs status
-------------------------------------------------------------------------------

local DEFAULTS = { filter = 'HARMFUL', maxAuras = 64 }
Grid2.setupFunc["mdebuffs"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, DEFAULTS)
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

local DEFAULTS = { filter = 'HARMFUL|RAID_PLAYER_DISPELLABLE', maxAuras = 64 }
Grid2.setupFunc["mdebuffType"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, DEFAULTS, DebuffsDispell)
end

Grid2:DbSetStatusDefaultValue( "debuffs-DispellableByMe", {type = "mdebuffType", subType = "DispellableByMe", colors = {}} )
