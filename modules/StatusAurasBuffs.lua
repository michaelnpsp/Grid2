-- Group of Buffs status
local Grid2 = Grid2
local UnitAura = UnitAura
local SpellIsSelfBuff = SpellIsSelfBuff
local UnitAffectingCombat = UnitAffectingCombat
local SpellGetVisibilityInfo = SpellGetVisibilityInfo
local myUnits = Grid2.roster_my_units

local textures = {}
local counts = {}
local expirations = {}
local durations = {}
local colors = {}
local color = {}

-- buffs group status
local function status_GetIcons(self, unit, max)
	color.r, color.g, color.b, color.a = self:GetColor(unit)
	local i, j, spells, filter, name, caster, _ = 1, 1, self.spells, self.isMine
	repeat
		name, textures[j], counts[j], _, durations[j], expirations[j], caster = UnitAura(unit, i)
		if not name then break end
		if spells[name] and (filter==false or filter==myUnits[caster]) then
			colors[j] = color
			j = j + 1
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors
end

local statusTypes = { "color", "icon", "icons", "percent", "text" }
local function status_Create(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	if dbx.spellName then dbx.spellName = nil end -- fix possible wrong data in old database
	status.GetIcons = status_GetIcons
	if Grid2.classicDurations then UnitAura = LibStub("LibClassicDurations").UnitAuraDirect end
	return Grid2.CreateStatusAura( status, basekey, dbx, 'buff', statusTypes )
end

-- special buffs Blizzard status
local blizzard = { GetColor = Grid2.statusLibrary.GetColor }

function blizzard:GetIcons(unit, max)
	local filter = UnitAffectingCombat("player") and "RAID_INCOMBAT" or "RAID_OUTOFCOMBAT"
	local color, i, j, name, caster, spellId, canApplyAura, isBossAura, valid, _ = self.dbx.color1, 1, 1
	repeat
		name, textures[j], counts[j], _, durations[j], expirations[j], caster, _, _, spellId, canApplyAura, isBossAura = UnitAura(unit, i)
		if not name then break end
		if not isBossAura then
			local hasCustom, alwaysShowMine, showForMySpec = SpellGetVisibilityInfo(spellId, filter)
			if hasCustom  then
				valid = showForMySpec or (alwaysShowMine and myUnits[caster])
			else
				valid = canApplyAura and myUnits[caster] and not SpellIsSelfBuff(spellId)
			end
			if valid then
				colors[j] = color
				j = j + 1
			end
		end
		i = i + 1
	until j>max
	return j-1, textures, counts, expirations, durations, colors
end

function blizzard:UNIT_AURA(_, unit)
	self:UpdateIndicators(unit)
end

function blizzard:OnEnable()
	self:RegisterEvent("UNIT_AURA")
	if Grid2.classicDurations then
		LibStub("LibClassicDurations"):Register(blizzard)
		UnitAura = LibStub("LibClassicDurations").UnitAuraDirect
	end
end

function blizzard:OnDisable()
	self:UnregisterEvent("UNIT_AURA")
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


