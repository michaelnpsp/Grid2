-- buffs and debuffs statuses for midnight

local Grid2 = Grid2

local CopyTable = Grid2.CopyTable

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

Grid2.DispelBorderDefaults = {
	showIcon = false,
	showWhenHarmful = true,
	showWhenHelpful = true,
	showWithoutDispelType = true,
	style = Enum.CustomAuraButtonDispelTypeTextureStyle.PreserveAsset, -- Border, BorderWithIcon, Icon, PreserverAsset, CustomAsset
}

Grid2.SatedDebuffs = {
	[57723]  = true, -- Exhaustion
	[57724]  = true, -- Sated
	[80354]  = true, -- Temporal Displacement
	[95809]  = true, -- Hunter Pet Insanity
	[160455] = true, -- Hunter Pet Fatigued
	[264689] = true, -- Hunter Pet Fatigued
	[390435] = true, -- Exhaustion
	[26013]  = true, -- BG Deserter
	[71041]  = true, -- Dungeon Deserter
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

local function Auras_GetBorder()
	return 0
end

local function Auras_GetAurasFilter(self)
	return self.aura_filter
end

local function Auras_UpdateDB(self)
	local dbx = self.dbx
	local typ = dbx.type
	-- aura filter
	local filter = CopyTable( self.defaults, CopyTable(dbx.aura_filter or {}) )
	-- spells table
	local spells = GetSpellIDsTable(dbx)
	if spells then
		filter.candidateFilters = filter.candidateFilters or {}
		if filter.candidateFilters.excludeSpellIDs then
			filter.candidateFilters.excludeSpellIDs = spells
		else
			filter.candidateFilters.includeSpellIDs = spells
		end
	elseif filter.excludeSatedDebuffs then
		filter.candidateFilters = filter.candidateFilters or {}
		filter.candidateFilters.excludeSpellIDs = Grid2.SatedDebuffs
	end
	-- aura type colors
 	local colorMap, defColor = {}
	if dbx.type == "mbuff" or dbx.type == 'mbuffs' then -- buffs
		defColor = dbx.color1 or Grid2.defaultColors.BLACK
		for typ, data in pairs(Grid2.DispelCurveDefaults) do
			colorMap[typ] = defColor
		end
	else
		local colors = dbx.colors
		for typ, data in pairs(Grid2.DispelCurveDefaults) do
			colorMap[typ] = (colors and colors[typ]) or data[2]
		end
		defColor = colorMap.None
	end
	filter.borderOptions = CopyTable( Grid2.DispelBorderDefaults, {customDispelColorMap = colorMap} )
	-- default status color
	local r, g, b, a = Grid2.UnpackColor(defColor)
	self.GetColor = function() return r, g, b, a end
	-- color by remaining/elapsed time options
	filter.cooldownTextOptions = nil
	if dbx.colorThreshold and dbx.colorCount>1 then -- color by time or value
		self.ctColorCurve = self.ctColorCurve or C_CurveUtil.CreateColorCurve()
		self.ctColorCurve:SetType(Enum.LuaCurveType.Step)
		self.ctColorCurve:ClearPoints()
		for i=1,dbx.colorCount do
			self.ctColorCurve:AddPoint( dbx.colorThreshold[i] or 0, dbx["color"..i] )
		end
		local durationType = dbx.colorThresholdElapsed and Enum.DurationTextBindingProperty.ElapsedDuration or Enum.DurationTextBindingProperty.RemainingDuration
		filter.cooldownTextOptions = { textColor={ curve=self.ctColorCurve, property=durationType } }
	end
	-- save filter table
	self.aura_filter = filter
end

local function Auras_Create(baseKey, dbx, defaults, status)
	status = status or Grid2.statusPrototype:new(baseKey)
	status.isAura = true
	status.defaults = defaults
	status.IsActive = Auras_IsActive
	status.GetBorder = Auras_GetBorder
	status.UpdateDB = Auras_UpdateDB
	status.GetAurasFilter = Auras_GetAurasFilter
	Grid2:RegisterStatus(status, { "icons", "icon", "color", "aura" }, baseKey, dbx)
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
 aura_filter = { filter='HELPFUL|RAID|PLAYER', sortRule=3, sortDir=0, },
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
	colors = {}
--]]

-------------------------------------------------------------------------------
-- midnight debuffs-dispellablebyme status
-------------------------------------------------------------------------------

local DebuffsDispell = Grid2.statusPrototype:new("debuffs-DispellableByMe")

local DEFAULTS = { filter = 'HARMFUL|RAID', maxAuras = 64 }
Grid2.setupFunc["mdebuffType"] = function(baseKey, dbx)
	return Auras_Create(baseKey, dbx, DEFAULTS, DebuffsDispell)
end

Grid2:DbSetStatusDefaultValue( "debuffs-DispellableByMe", {type = "mdebuffType", subType = "DispellableByMe", colors = {}} )
