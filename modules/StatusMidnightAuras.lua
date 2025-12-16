-- buffs and debuffs statuses for midnight

local myUnits = Grid2.roster_my_units
local canaccessvalue = Grid2.canaccessvalue
local SpellIsSelfBuff = SpellIsSelfBuff
local UnitAffectingCombat = UnitAffectingCombat
local SpellGetVisibilityInfo = C_Spell.GetVisibilityInfo
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
	if self.filter_enemy and UnitIsEnemy("player", unit) then
		return GetIcons(self, unit, max, self.filter_enemy)
	else
		return GetIcons(self, unit, max, self.filter_friend)
		-- return GetIcons(self, unit, max, self.filter_friend, not UnitAffectingCombat("player") and self.display_check)
	end
end

function Buffs:GetTooltip(unit, tip, slotID)
	if slotID then
		tip:SetUnitBuff(unit, slotID)
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
	self.filter_friend = self.dbx.aura_filter or 'HELPFUL'
	self_filter_enemy  = self.dbx.aura_filter_enemy
	self.display_check = Buffs_DisplayCheck
end

-- Registration
Grid2.setupFunc["mbuffs"] = function(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey)
	status:Inject(Buffs)
	Grid2:RegisterStatus(status, { "icons" }, baseKey, dbx)
	return status
end

-- Grid2:DbSetStatusDefaultValue("midnight-buffs", { type = "mbuffs", aura_filter = 'HELPFUL|RAID|PLAYER', aura_filter_enemy = 'HELPFUL', color1 = {r=0, g=1, b=0, a=1} })

-------------------------------------------------------------------------------
-- midnight-debuffs status
-------------------------------------------------------------------------------

Debuffs.GetColor = Grid2.statusLibrary.GetColor

function Debuffs:GetIcons(unit, max)
	return GetIcons(self, unit, max, self.aura_filter)
end

function Debuffs:GetTooltip(unit, tip, slotID)
	if slotID then
		tip:SetUnitBuff(unit, slotID)
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
end

-- Registration
Grid2.setupFunc["mdebuffs"] = function(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey)
	status:Inject(Debuffs)
	Grid2:RegisterStatus(status, { "icons" }, baseKey, dbx)
	return status
end

-- Grid2:DbSetStatusDefaultValue("midnight-debuffs", { type = "mdebuffs", aura_filter = 'HARMFUL', color1 = {r=1, g=0, b=0, a=1} })
