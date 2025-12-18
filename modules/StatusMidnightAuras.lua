-- buffs and debuffs statuses for midnight

local myUnits = Grid2.roster_my_units
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

local function GetIcons(self, unit, max, filter, displayFunc)
	local color, i, j = self.dbx.color1, 1, 1
	repeat
		local a = GetAuraDataByIndex(unit, i, filter)
		if not a then break end
		textures[j], counts[j], colors[j], slots[j] = a.icon, a.applications, color, i
		if not displayFunc or displayFunc(a) then
			durations[j] = a.duration
			expirations[j] = a.expirationTime
			colors[j] = GetAuraDispelTypeColor(unit, a.auraInstanceID, dispelColorCurve)
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors, slots
end


--[[
Farmer Meorawr (✿◠◡◠) 🦆: Sorting is implemented through extra optional parameters to C_UnitAuras.GetUnitAuras/GetUnitAuraInstanceIDs:

The sorting is applied on all auras for the unit matching the supplied filter, and after sorting the result list is truncated to maxCount if specified.

Sort rules are as follows:

Enum.UnitAuraSortRule.Default - equivalent to AuraUtil.DefaultAuraCompare
Enum.UnitAuraSortRule.BigDefensive - equivalent to AuraUtil.BigDefensiveAuraCompare
Enum.UnitAuraSortRule.Expiration - equivalent to Default with an added comparison for expiration time before the aura instance ID fallback. Unlike SecureAuraHeaderTemplate, this sorts permanent duration auras to the end of the list (ie. as-if they had an infinite expiry time).
Enum.UnitAuraSortRule.ExpirationOnly - Pure comparison on expiration time only. Same note about permanent aura durations applies.
Enun.UnitAuraSortRule.Name - equivalent to Default with an added comparison for (unicode-aware) name-based sorting before the aura instance ID fallback.
Enum.UnitAuraSortRule.NameOnly - Pure comparison on name only.

--]]

-- Enum.UnitAuraSortRule.Default, Enum.UnitAuraSortDirection.Reverse)
local function GetIconsSorted(self, unit, max, filter, sortRule, sortDir)
	local auras = GetUnitAuras(unit, filter, max, sortRule, sortDir)
	for j, a in ipairs(auras) do
		local auraInstanceID = a.auraInstanceID
		textures[j] = a.icon
		counts[j] = a.applications
		durations[j] = a.duration
		expirations[j] = a.expirationTime
		slots[j] = auraInstanceID
		colors[j] = GetAuraDispelTypeColor(unit, auraInstanceID, dispelColorCurve)
	end
	return #auras, textures, counts, expirations, durations, colors, slots
end

-------------------------------------------------------------------------------
-- midnight-buffs status
-------------------------------------------------------------------------------

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
	return GetIconsSorted(self, unit, max, self.aura_filter, self.aura_sortRule, self.aura_sortDir)
end

function Buffs:GetTooltip(unit, tip, slotID)
	if slotID then
		tip:SetUnitAuraByAuraInstanceID(unit, slotID)
	end
end

function Buffs:UNIT_AURA(_, unit)
	self:UpdateIndicators(unit)
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
	self.aura_filter = self.dbx.aura_filter or 'HELPFUL'
	self.aura_sortRule = self.dbx.aura_sortRule or 0
	self.aura_sortDir = self.dbx.aura_sortDir or 0
end

-- Registration
Grid2.setupFunc["mbuffs"] = function(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey)
	status:Inject(Buffs)
	Grid2:RegisterStatus(status, { "icons" }, baseKey, dbx)
	return status
end

-- Grid2:DbSetStatusDefaultValue("midnight-buffs", { type = "mbuffs", aura_filter = 'HELPFUL|RAID|PLAYER', color1 = {r=0, g=1, b=0, a=1} })

-------------------------------------------------------------------------------
-- midnight-debuffs status
-------------------------------------------------------------------------------

Debuffs.GetColor = Grid2.statusLibrary.GetColor

function Debuffs:GetIcons(unit, max)
	return GetIconsSorted(self, unit, max, self.aura_filter, self.aura_sortRule, self.aura_sortDir)
end

function Debuffs:GetTooltip(unit, tip, slotID)
	if slotID then
		tip:SetUnitAuraByAuraInstanceID(unit, slotID)
	end
end

function Debuffs:UNIT_AURA(_, unit)
	self:UpdateIndicators(unit)
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
	self.aura_filter = self.dbx.aura_filter or 'HARMFUL'
	self.aura_sortRule = self.dbx.aura_sortRule or 0
	self.aura_sortDir = self.dbx.aura_sortDir or 0
end

-- Registration
Grid2.setupFunc["mdebuffs"] = function(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey)
	status:Inject(Debuffs)
	Grid2:RegisterStatus(status, { "icons" }, baseKey, dbx)
	return status
end

-- Grid2:DbSetStatusDefaultValue("midnight-debuffs", { type = "mdebuffs", aura_filter = 'HARMFUL', color1 = {r=1, g=0, b=0, a=1} })
