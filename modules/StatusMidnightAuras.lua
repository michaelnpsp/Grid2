-- buffs and debuffs statuses for midnight

local LBA = Grid2.BlizFramesAuras

local rosterUnits = Grid2.roster_guids
local UnitIsFriend = UnitIsFriend
local GetUnitAuras = C_UnitAuras.GetUnitAuras
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetAuraDispelTypeColor = C_UnitAuras.GetAuraDispelTypeColor

-- temporary results variables
local slots = {}
local color = {}
local colors = {color, color, color, color, color, color, color, color, color, color, color, color}
local counts = {}
local textures = {}
local durations = {}
local expirations = {}

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
-- shared functions
-------------------------------------------------------------------------------

local function GetIconsSorted(unit, max, filter, sortRule, sortDir, colorCurve, aurasFunc, displayFunc)
	local i = 0
	local color = colorCurve.r and colorCurve or nil
	local auras = (aurasFunc or GetUnitAuras)(unit, filter, displayFunc and 40 or max, sortRule, sortDir)
	for _, a in ipairs(auras) do
		if not displayFunc or displayFunc(a) then
			i = i + 1
			local auraInstanceID = a.auraInstanceID
			textures[i] = a.icon
			counts[i] = a.applications
			durations[i] = a.duration
			expirations[i] = a.expirationTime
			slots[i] = auraInstanceID
			colors[i] = color or GetAuraDispelTypeColor(unit, auraInstanceID, colorCurve)
			if i>=max then break end
		end
	end
	return i, textures, counts, expirations, durations, colors, slots
end

-------------------------------------------------------------------------------
-- shared methods
-------------------------------------------------------------------------------

local Shared = { GetColor = Grid2.statusLibrary.GetColor }

function Shared:GetIcons(unit, max)
	return GetIconsSorted(unit, max, self.aura_filter, self.aura_sortRule, self.aura_sortDir, self.aura_color, self.aura_func, self.aura_display)
end

function Shared:GetIconData(unit)
	local _, tex, cnt, exp, dur, col, slots = self:GetIcons(unit, 1)
	return tex[1], cnt[1], exp[1], dur[1], col[1], slots[1]
end

function Shared:GetTooltip(unit, tip, slotID)
	if slotID then
		tip:SetUnitAuraByAuraInstanceID(unit, slotID)
	else
		tip:SetUnitAuraByAuraInstanceID(unit, select(6,self:GetIconData(unit)) )
	end
end

function Shared:UNIT_AURA(_, unit)
	if rosterUnits[unit] then
		self:UpdateIndicators(unit)
	end
end

function Shared:LBA_UNIT_AURA(_, unit)
	self:UpdateIndicators(unit)
end

function Shared:OnEnable()
	if self.aura_func then
		LBA.RegisterCallback(self, "LBA_UNIT_AURA")
	else
		self:RegisterEvent("UNIT_AURA")
	end
end

function Shared:OnDisable()
	if self.aura_func then
		LBA.UnregisterCallback(self, "LBA_UNIT_AURA")
	else
		self:UnregisterEvent("UNIT_AURA")
	end
end

function Shared:IsActiveDef(unit)
	return GetAuraDataByIndex(unit, 1, self.aura_filter)~=nil
end

function Shared:IsActiveLBA(unit)
	return LBA.UnitHasAuras(unit, self.aura_filter)
end

-------------------------------------------------------------------------------
-- midnight-buffs status
-------------------------------------------------------------------------------

do

	local function Buffs_UpdateDB(self)
		local filter = self.dbx.aura_filter or {}
		self.aura_color    = self.dbx.color1
		self.aura_sortRule = filter.sortRule or 0
		self.aura_sortDir  = filter.sortDir or 0
		self.aura_filter   = filter.blizFilter or filter.filter or 'HELPFUL'
		self.aura_func     = filter.blizFilter and LBA.GetUnitAuras or nil
		self.IsActive      = filter.blizFilter and self.IsActiveLBA or self.IsActiveDef
	end

	-- Registration
	Grid2.setupFunc["mbuffs"] = function(baseKey, dbx)
		local status = Grid2.statusPrototype:new(baseKey)
		status:Inject(Shared)
		status.UpdateDB = Buffs_UpdateDB
		Grid2:RegisterStatus(status, { "icons", "icon", "tooltip" }, baseKey, dbx)
		return status
	end

end

--[[ mbuffs database format
 type = "mbuffs",
 aura_filter = { filter='HELPFUL|RAID|PLAYER', sortRule=3, sortDir=0 },
 color1 = {r=0, g=1, b=0, a=1}
--]]

-------------------------------------------------------------------------------
-- midnight-debuffs status
-------------------------------------------------------------------------------

do

	local filterTypedFuncs = {
		[false] = function(aura) return aura.dispelName==nil; end,
		[true] = function(aura) return aura.dispelName~=nil; end,
	}

	local function Debuffs_UpdateDB(self)
		local filter = self.dbx.aura_filter or {}
		self.aura_filter   = filter.filter or 'HARMFUL'
		self.aura_sortRule = filter.sortRule or 0
		self.aura_sortDir  = filter.sortDir or 0
		self.aura_display  = filterTypedFuncs[filter.typed]
		self.aura_func     = filter.blizFilter and LBA.GetUnitAuras or nil
		self.IsActive      = filter.blizFilter and self.IsActiveLBA or self.IsActiveDef
		self.aura_color:ClearPoints()
		local colors = self.dbx.colors or {}
		for typ, def in pairs(Grid2.DispelCurveDefaults) do
			self.aura_color:AddPoint( def[1], colors[typ] or def[2])
		end
	end

	-- Registration
	Grid2.setupFunc["mdebuffs"] = function(baseKey, dbx)
		local status = Grid2.statusPrototype:new(baseKey)
		status:Inject(Shared)
		status.UpdateDB = Debuffs_UpdateDB
		status.aura_color = C_CurveUtil.CreateColorCurve()
		status.aura_color:SetType(Enum.LuaCurveType.Step)
		Grid2:RegisterStatus(status, { "icons", "icon", "tooltip" }, baseKey, dbx)
		return status
	end

end

--[[ mdebuffs database format
	type = "mdebuffs",
	aura_filter = { filter= 'HARMFUL' ],
	colors = {}
--]]

-------------------------------------------------------------------------------
-- midnight debuffs-dispellablebyme status
-------------------------------------------------------------------------------
do

	local DebuffsDispell = Grid2.statusPrototype:new("debuffs-DispellableByMe")

	local dispel_cache = {}

	DebuffsDispell.defaultColors = {
		Magic   = { 1,  DEBUFF_TYPE_MAGIC_COLOR   },
		Curse   = { 2,  DEBUFF_TYPE_CURSE_COLOR   },
		Disease = { 3,  DEBUFF_TYPE_DISEASE_COLOR },
		Poison  = { 4,  DEBUFF_TYPE_POISON_COLOR  },
		Enrage  = { 9,  DEBUFF_TYPE_BLEED_COLOR   },
		Bleed   = { 11, DEBUFF_TYPE_BLEED_COLOR   },
	}

	DebuffsDispell.aura_color = C_CurveUtil.CreateColorCurve()
	DebuffsDispell.aura_color:SetType(Enum.LuaCurveType.Step)

	DebuffsDispell:Inject(Shared)

	function DebuffsDispell:UpdateCache(unit, aura)
		local active = aura~=nil
		if active or active ~= (dispel_cache[unit]~=nil) then -- TODO: this is wrong, if an aura is replaced by another ahora we need to update the color and the indicators
			dispel_cache[unit] = active and GetAuraDispelTypeColor(unit, aura.auraInstanceID, self.aura_color) or nil
			self:UpdateIndicators(unit)
		end
	end

	function DebuffsDispell:GetColor(unit)
		local c = dispel_cache[unit]
		return c.r, c.g, c.b, c.a
	end

	function DebuffsDispell:LBA_UNIT_AURA(event, unit)
		self:UpdateCache( unit, UnitIsFriend("player", unit) and LBA.GetUnitDebuffsDispellable(unit, "HARMFUL|RAID", 1)[1] or nil )
	end

	function DebuffsDispell:UNIT_AURA(event, unit)
		if rosterUnits[unit] then
			self:UpdateCache( unit, UnitIsFriend("player", unit) and GetAuraDataByIndex(unit, 1, "HARMFUL|RAID") or nil )
		end
	end

	function DebuffsDispell:Grid_UnitUpdated(_, unit)
		if not self.aura_func then
			dispel_cache[unit] = nil
		end
	end

	function DebuffsDispell:OnEnable()
		Shared.OnEnable(self)
		self:RegisterMessage("Grid_UnitUpdated")
	end

	function DebuffsDispell:OnDisable()
		Shared.OnDisable(self)
		self:UnregisterMessage("Grid_UnitUpdated")
	end

	function DebuffsDispell:IsActive(unit)
		return dispel_cache[unit]~=nil
	end

	function DebuffsDispell:UpdateDB()
		self.aura_filter = 'HARMFUL|RAID'
		self.aura_func = self.dbx.blizFilter and LBA.GetUnitAuras or nil
		self.aura_color:ClearPoints()
		local colors = self.dbx.colors or {}
		for typ, def in pairs(Grid2.DispelCurveDefaults) do
			self.aura_color:AddPoint( def[1], colors[typ] or def[2])
		end
	end

	-- Registration
	Grid2.setupFunc["mdebuffType"] = function(baseKey, dbx)
		Grid2:RegisterStatus(DebuffsDispell, { "icons", "icon", "color", "tooltip" }, baseKey, dbx)
		return DebuffsDispell
	end

	Grid2:DbSetStatusDefaultValue( "debuffs-DispellableByMe", {type = "mdebuffType", subType = "DispellableByMe", colors = {}} )
end
