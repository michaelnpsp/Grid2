local Buffs = Grid2.statusPrototype:new("midnight-buffs")

local myUnits = Grid2.roster_my_units
local UnitAura = Grid2.API.UnitAuraLite
local SpellIsSelfBuff = SpellIsSelfBuff
local UnitAffectingCombat = UnitAffectingCombat

local slots = {}
local color = {}
local colors = {color, color, color, color, color, color, color, color}
local counts = {}
local textures = {}
local durations = {}
local expirations = {}

Buffs.GetColor = Grid2.statusLibrary.GetColor

local SpellGetVisibilityInfo = C_Spell.GetVisibilityInfo
local GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local IsAuraFilteredOutByInstanceID = C_UnitAuras.IsAuraFilteredOutByInstanceID


local function ShouldDisplayBuffFriend(filter, spellId, caster, canApplyAura, isBossAura)
	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, filter)
	if hasCustom  then
		return showForMySpec or (alwaysShowMine and myUnits[caster])
	else
		return canApplyAura and myUnits[caster] and not SpellIsSelfBuff(spellId)
	end
end

local function ShouldDisplayBuffEnemy(filter, spellId, caster, canApplyAura, isBossAura)
	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, filter)
	if hasCustom  then
		return showForMySpec or (alwaysShowMine and myUnits[caster])
	else
		return canApplyAura and myUnits[caster] and not SpellIsSelfBuff(spellId)
	end
end

function Buffs:GetIcons(unit, max)
	local display, filter
	if UnitIsEnemy("player", unit) then
		display, filter = ShouldDisplayBuffEnemy, 2 -- "ENEMY_TARGET"
	else
		display, filter = ShouldDisplayBuffFriend, UnitAffectingCombat("player") and 0 or 1 -- "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT"
	end
	local color, i, j = self.dbx.color1, 1, 1
	repeat
		local a = GetAuraDataByIndex(unit, i)
		if not a then break end
		if not IsAuraFilteredOutByInstanceID(unit, a.auraInstanceID, "HELPFUL|PLAYER") then
			textures[j], counts[j], durations[j], expirations[j] = a.icon, a.applications, a.duration, a.expirationTime
			colors[j], slots[j] = color, i
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors, slots
end

function Buffs:GetTooltip(unit, tip, slotID)
	if slotID then
		tip:SetUnitBuff(unit, slotID)
	end
end

function Buffs:UNIT_AURA(_, unit)
	self:UpdateIndicators(unit)
end

Buffs.PLAYER_REGEN_DISABLED = Grid2.statusLibrary.UpdateAllUnits
Buffs.PLAYER_REGEN_ENABLED = Grid2.statusLibrary.UpdateAllUnits

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

-- Registration
Grid2.setupFunc["midnight-buffs"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Buffs, { "icons" }, baseKey, dbx)
	return Buffs
end

Grid2:DbSetStatusDefaultValue("midnight-buffs", { type = "midnight-buffs", color1 = {r=0, g=1, b=0, a=1} })
