-- buffs and debuffs statuses for midnight


local myUnits = Grid2.roster_my_units
local rosterUnits = Grid2.roster_guids
local canaccessvalue = Grid2.canaccessvalue
local SpellIsSelfBuff = SpellIsSelfBuff
local UnitAffectingCombat = UnitAffectingCombat
local SpellGetVisibilityInfo = C_Spell.GetVisibilityInfo
local GetUnitAuras = C_UnitAuras.GetUnitAuras
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GetAuraDispelTypeColor = C_UnitAuras.GetAuraDispelTypeColor
local IsAuraFilteredOutByInstanceID = C_UnitAuras.IsAuraFilteredOutByInstanceID
local GetAuraDurationRemainingByAuraInstanceID = C_UnitAuras.GetAuraDurationRemainingByAuraInstanceID

-- shared functions and variables
local Buffs = {}
local Debuffs = {}
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

local dispelColorCurve = C_CurveUtil.CreateColorCurve()
do
	dispelColorCurve:SetType(Enum.LuaCurveType.Step)
    dispelColorCurve:AddPoint( 0  , DEBUFF_TYPE_NONE_COLOR )
    dispelColorCurve:AddPoint( 1  , DEBUFF_TYPE_MAGIC_COLOR )
    dispelColorCurve:AddPoint( 2  , DEBUFF_TYPE_CURSE_COLOR )
    dispelColorCurve:AddPoint( 3  , DEBUFF_TYPE_DISEASE_COLOR )
    dispelColorCurve:AddPoint( 4  , DEBUFF_TYPE_POISON_COLOR )
    dispelColorCurve:AddPoint( 9  , DEBUFF_TYPE_BLEED_COLOR ) -- enrage
    dispelColorCurve:AddPoint( 11 , DEBUFF_TYPE_BLEED_COLOR )
end

--[[
Sort rules are as follows:
Enum.UnitAuraSortRule.Default - equivalent to AuraUtil.DefaultAuraCompare
Enum.UnitAuraSortRule.BigDefensive - equivalent to AuraUtil.BigDefensiveAuraCompare
Enum.UnitAuraSortRule.Expiration - equivalent to Default with an added comparison for expiration time before the aura instance ID fallback. Unlike SecureAuraHeaderTemplate, this sorts permanent duration auras to the end of the list (ie. as-if they had an infinite expiry time).
Enum.UnitAuraSortRule.ExpirationOnly - Pure comparison on expiration time only. Same note about permanent aura durations applies.
Enun.UnitAuraSortRule.Name - equivalent to Default with an added comparison for (unicode-aware) name-based sorting before the aura instance ID fallback.
Enum.UnitAuraSortRule.NameOnly - Pure comparison on name only.
Enum.UnitAuraSortRule.Default, Enum.UnitAuraSortDirection.Reverse
--]]

local function GetIconsSorted(self, unit, max, filter, sortRule, sortDir, colorCurve, displayFunc)
	local i = 0
	local color = colorCurve.r and colorCurve or nil
	local auras = GetUnitAuras(unit, filter, displayFunc and max or 40, sortRule, sortDir)
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
-- midnight-buffs status
-------------------------------------------------------------------------------
do

	Buffs.GetColor = Grid2.statusLibrary.GetColor
	Buffs.PLAYER_REGEN_DISABLED = Grid2.statusLibrary.UpdateAllUnits
	Buffs.PLAYER_REGEN_ENABLED = Grid2.statusLibrary.UpdateAllUnits

	-- This is the logic used by blizzard raid frames to show/hide buffs.
	-- SpellGetVisibilityInfo(spellId, n) where n:
	-- 0 => in combat
	-- 1 => only out of combat
	-- 2 => for enemy targets
	-- SpellGetVisiblityInfo() cannot be used in combat in midnight so 0,2 options are useless
	-- Maybe use this code on buffs.
	local function Buffs_DisplayCheck(aura)
		local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(aura.spellId, 1)
		if hasCustom  then
			return showForMySpec or (alwaysShowMine and myUnits[a.sourceUnit])
		else
			return aura.canApplyAura and myUnits[aura.sourceUnit] and not SpellIsSelfBuff(aura.spellId)
		end
	end

	function Buffs:GetIcons(unit, max)
		return GetIconsSorted(self, unit, max, self.aura_filter, self.aura_sortRule, self.aura_sortDir, self.aura_color)
	end

	function Buffs:GetTooltip(unit, tip, slotID)
		if slotID then
			tip:SetUnitAuraByAuraInstanceID(unit, slotID)
		end
	end

	function Buffs:UNIT_AURA(_, unit)
		if rosterUnits[unit] then
			self:UpdateIndicators(unit)
		end
	end

	function Buffs:OnEnable()
		self:RegisterEvent("UNIT_AURA")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
	end

	function Buffs:OnDisable()
		self:UnregisterEvent("UNIT_AURA")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	end

	function Buffs:IsActive(unit)
		return true
	end

	function Buffs:UpdateDB()
		local filter = self.dbx.aura_filter or {}
		self.aura_filter   = filter.filter or 'HELPFUL'
		self.aura_sortRule = filter.sortRule or 0
		self.aura_sortDir  = filter.sortDir or 0
		self.aura_color    = self.dbx.color1
	end

	-- Registration
	Grid2.setupFunc["mbuffs"] = function(baseKey, dbx)
		local status = Grid2.statusPrototype:new(baseKey)
		status:Inject(Buffs)
		Grid2:RegisterStatus(status, { "icons" }, baseKey, dbx)
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

	Debuffs.GetColor = Grid2.statusLibrary.GetColor

	function Debuffs:GetIcons(unit, max)
		return GetIconsSorted(self, unit, max, self.aura_filter, self.aura_sortRule, self.aura_sortDir, self.colorCurve, self.aura_display)
	end

	function Debuffs:GetTooltip(unit, tip, slotID)
		if slotID then
			tip:SetUnitAuraByAuraInstanceID(unit, slotID)
		end
	end

	function Debuffs:UNIT_AURA(_, unit)
		if rosterUnits[unit] then
			self:UpdateIndicators(unit)
		end
	end

	function Debuffs:OnEnable()
		self:RegisterEvent("UNIT_AURA")
	end

	function Debuffs:OnDisable()
		self:UnregisterEvent("UNIT_AURA")
	end

	function Debuffs:IsActive(unit)
		return true
	end

	function Debuffs:UpdateDB()
		local filter = self.dbx.aura_filter or {}
		self.aura_filter   = filter.filter or 'HARMFUL'
		self.aura_sortRule = filter.sortRule or 0
		self.aura_sortDir  = filter.sortDir or 0
		self.aura_display  = filterTypedFuncs[filter.typed]
		self.colorCurve:ClearPoints()
		local colors = self.dbx.colors or {}
		for typ, def in pairs(Grid2.DispelCurveDefaults) do
			self.colorCurve:AddPoint( def[1], colors[typ] or def[2])
		end
	end

	-- Registration
	Grid2.setupFunc["mdebuffs"] = function(baseKey, dbx)
		local status = Grid2.statusPrototype:new(baseKey)
		status:Inject(Debuffs)
		status.colorCurve = C_CurveUtil.CreateColorCurve()
		status.colorCurve:SetType(Enum.LuaCurveType.Step)
		Grid2:RegisterStatus(status, { "icons" }, baseKey, dbx)
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

	local colorCurve = C_CurveUtil.CreateColorCurve()

	local dispel_cache = {}

	DebuffsDispell.defaultColors = {
		-- None    = { 0,  DEBUFF_TYPE_NONE_COLOR    },
		Magic   = { 1,  DEBUFF_TYPE_MAGIC_COLOR   },
		Curse   = { 2,  DEBUFF_TYPE_CURSE_COLOR   },
		Disease = { 3,  DEBUFF_TYPE_DISEASE_COLOR },
		Poison  = { 4,  DEBUFF_TYPE_POISON_COLOR  },
		Enrage  = { 9,  DEBUFF_TYPE_BLEED_COLOR   },
		Bleed   = { 11, DEBUFF_TYPE_BLEED_COLOR   },
	}

	function DebuffsDispell:GetColor(unit)
		local c = dispel_cache[unit]
		return c.r, c.g, c.b, c.a
	end

	function DebuffsDispell:GetIcons(unit, max)
		return GetIconsSorted(self, unit, max, "HARMFUL|RAID", nil, nil, colorCurve)
	end

	function DebuffsDispell:GetTooltip(unit, tip, slotID)
		if slotID then
			tip:SetUnitAuraByAuraInstanceID(unit, slotID)
		end
	end

	function DebuffsDispell:UNIT_AURA(_, unit)
		if rosterUnits[unit] then
			local aura = GetUnitAuras(unit, "HARMFUL|RAID", 1)[1]
			local active = aura~=nil
			if active or active ~= (dispel_cache[unit]~=nil) then
				dispel_cache[unit] = active and GetAuraDispelTypeColor(unit, aura.auraInstanceID, colorCurve) or nil
				self:UpdateIndicators(unit)
			end
		end
	end

	function DebuffsDispell:Grid_UnitUpdated(_, unit)
		dispel_cache[unit] = nil
	end

	function DebuffsDispell:OnEnable()
		self:RegisterEvent("UNIT_AURA")
		self:RegisterMessage( "Grid_UnitUpdated" )
	end

	function DebuffsDispell:OnDisable()
		self:UnregisterEvent("UNIT_AURA")
		self:UnregisterMessage( "Grid_UnitUpdated" )
	end

	function DebuffsDispell:IsActive(unit)
		return dispel_cache[unit]~=nil
	end

	function DebuffsDispell:UpdateDB()
		colorCurve:ClearPoints()
		local colors = self.dbx.colors or {}
		for typ, def in pairs(Grid2.DispelCurveDefaults) do
			colorCurve:AddPoint( def[1], colors[typ] or def[2])
		end
	end

	-- Registration
	Grid2.setupFunc["mdebuffType"] = function(baseKey, dbx)
		colorCurve:SetType(Enum.LuaCurveType.Step)
		Grid2:RegisterStatus(DebuffsDispell, { "icons", "color" }, baseKey, dbx)
		return DebuffsDispell
	end

	Grid2:DbSetStatusDefaultValue( "debuffs-DispellableByMe", {type = "mdebuffType", subType = "DispellableByMe", colors = {}} )
end
