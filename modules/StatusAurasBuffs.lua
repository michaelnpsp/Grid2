-- Group of Buffs status
local Grid2 = Grid2
local bit_bor= bit.bor
local SpellIsSelfBuff = SpellIsSelfBuff
local UnitAffectingCombat = UnitAffectingCombat
local SpellGetVisibilityInfo = SpellGetVisibilityInfo
local myUnits = Grid2.roster_my_units
local UnitAura = Grid2.UnitAuraLite

-- all buffs
local textures = {}
local slots = {}
local color = {}
local colors = {color, color, color, color, color, color, color, color}

-- normal buffs
local counts = {}
local expirations = {}
local durations = {}

-- missing buffs
local mcounts = {1}
local mexpirations = {0}
local mdurations = mexpirations

-- strict filter management functions
local function GenSpellsMask(spells)
	local bit, mask = 1, 0
	for spell in pairs(spells) do
		mask = mask + bit
		spells[spell] = bit
		bit = bit*2
	end
	return mask
end

local function status_UpdateStateStrict(s, u, i, sid, nam, tex, cnt, dur, exp)
	local mask = s.strictMask
	mask = bit_bor( mask, s.spells[nam] or s.spells[sid] )
	if mask==s.strictMASK then
		if s.idx[u] then
			s.seen, s.idx[u] = -1, i
		else
			s.seen, s.idx[u], s.tex[u], s.cnt[u], s.dur[u], s.exp[u], s.val[u], s.tkr[u] = 1, i, tex, cnt, dur, exp, 0, 1
		end
	end
	s.strictMask = mask
end

local function status_ResetStateStrict(self)
	self.strictMask = 0
end

-- buffs group status
local function status_GetIcons(self, unit, max)
	local i, j, spells, filter, name, caster, _ = 1, 1, self.spells, self.isMine
	repeat
		name, textures[j], counts[j], _, durations[j], expirations[j], caster, _, _, sid = UnitAura(unit, i)
		if not name then break end
		if (spells[name] or spells[sid]) and (filter==false or filter==myUnits[caster]) then
			slots[j] = i
			j = j + 1
		end
		i = i + 1
	until j>max
	if j>1 then
		color.r, color.g, color.b, color.a = self:GetColor(unit)
	end
	return j-1, textures, counts, expirations, durations, colors, slots
end

local function status_GetIconsMissing(self, unit)
	if self:IsActive(unit) then
		color.r, color.g, color.b, color.a = self:GetColor(unit)
		textures[1], slots[1] = self.missingTexture, 0
		return 1, textures, mcounts, mexpirations, mdurations, colors, slots
	end
	return 0
end

local function status_Update(self, dbx)
	self.GetIcons = dbx.missing and status_GetIconsMissing or status_GetIcons
	if dbx.strictFilter then
		self.UpdateState, self.ResetState, self.strictMask, self.strictMASK = status_UpdateStateStrict, status_ResetStateStrict, 0, GenSpellsMask(self.spells)
	else
		self.UpdateState, self.ResetState = nil, nil
	end
end

local statusTypes = { "color", "icon", "icons", "percent", "text" }
local function status_Create(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	if dbx.spellName then dbx.spellName = nil end -- fix possible wrong data in old database
	status.OnUpdate = status_Update
	if Grid2.classicDurations then UnitAura = LibStub("LibClassicDurations").UnitAuraDirect end
	return Grid2.CreateStatusAura( status, basekey, dbx, 'buff', statusTypes )
end

-- special buffs Blizzard status
local blizzard = { GetColor = Grid2.statusLibrary.GetColor }

local function ShouldDisplayBuff(filter, spellId, caster, canApplyAura, isBossAura)
	local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, filter)
	if hasCustom  then
		return showForMySpec or (alwaysShowMine and myUnits[caster])
	else
		return canApplyAura and myUnits[caster] and not SpellIsSelfBuff(spellId)
	end
end

function blizzard:GetIcons(unit, max)
	local filter = UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT"
	local color, i, j, name, caster, spellId, canApplyAura, isBossAura, valid, _ = self.dbx.color1, 1, 1
	repeat
		name, textures[j], counts[j], _, durations[j], expirations[j], caster, _, _, spellId, canApplyAura, isBossAura = UnitAura(unit, i)
		if not name then break end
		if ShouldDisplayBuff(filter, spellId, caster, canApplyAura, isBossAura) then
			colors[j], slots[j] = color, i
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors, slots
end

function blizzard:GetTooltip(unit, tip, slotID)
	if slotID then
		tip:SetUnitBuff(unit, slotID)
	end
end

function blizzard:UNIT_AURA(_, unit)
	self:UpdateIndicators(unit)
end

blizzard.PLAYER_REGEN_DISABLED = Grid2.statusLibrary.UpdateAllUnits
blizzard.PLAYER_REGEN_ENABLED = Grid2.statusLibrary.UpdateAllUnits

function blizzard:OnEnable()
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	if Grid2.classicDurations then
		LibStub("LibClassicDurations"):Register(blizzard)
		UnitAura = LibStub("LibClassicDurations").UnitAuraDirect
	end
end

function blizzard:OnDisable()
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	if Grid2.classicDurations then
		LibStub("LibClassicDurations"):Unregister(blizzard)
	end
end

function blizzard:IsActive(unit)
	return true
end

local function blizzard_Create(baseKey,dbx)
	local status = Grid2.statusPrototype:new(baseKey)
	status:Inject(blizzard)
	Grid2:RegisterStatus(status, { "icons" }, baseKey, dbx)
	return status
end

-- Registration
Grid2.setupFunc["buffs"] = function(baseKey, dbx)
	if dbx.subType == 'blizzard' then
		return blizzard_Create(baseKey,dbx)
	else
		return status_Create(baseKey,dbx)
	end
end

--[[ status database configuration
	type = "buffs"
	subType = 'blizzard' | nil
	auras = { "Riptide", 12323, "Earth Shield", ... }
	colorThresholdElapsed = true | nil 	-- true = color by elapsed time; nil= color by remaining time
	colorThreshold = { 10, 4, 2 } 	    -- thresholds in seconds to change the color
	colorCount = number
	color1 = { r=1,g=1,b=1,a=1 }
	color2 = { r=1,g=1,b=0,a=1 }
--]]
