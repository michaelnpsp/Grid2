-- Created by Grid2 original authors, modified by Michael

local Range = Grid2.statusPrototype:new("range")
local RangeAlt = Grid2.statusPrototype:new("rangealt")

local Grid2 = Grid2
local tonumber = tonumber
local UnitIsUnit = UnitIsUnit
local UnitCanAttack = UnitCanAttack
local InCombatLockdown = InCombatLockdown
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local CheckInteractDistance = CheckInteractDistance
local playerClass = Grid2.playerClass
local GetSpellInfo = Grid2.API.GetSpellInfo
local IsSpellInRange = Grid2.API.IsSpellInRange

-------------------------------------------------------------------------
--  Range check spells initialization
-------------------------------------------------------------------------
local spellHostile, spellFriendly = nil, nil
do
	local function IVS(spellID) return IsPlayerSpell(spellID) and spellID end
	local getHostile, getFriendly
	if playerClass == 'DRUID' then
		getHostile  = function() return 8921 end -- Moonfire
		getFriendly = function() return 8936 end -- Regrowth
	elseif playerClass == 'PRIEST' then
		getHostile  = function() return 585  end  -- Smite
		getFriendly = function() return 2061 end  -- Flash Heal
	elseif playerClass == 'SHAMAN' then
		getHostile  = function() return 188196  end -- Lightning Bolt
		getFriendly = function() return 8004 end    -- Healing Surge
	elseif playerClass == 'PALADIN' then
		getHostile  = function() return 62124 end -- Hand of Reckoning
		getFriendly = function() return 19750 end -- Flash of light
	elseif playerClass == 'MONK' then
		getHostile  = function() return 115546 end -- Provoke
		getFriendly = function() return 116670 end -- Vivify
	elseif playerClass == 'EVOKER' then
		getHostile  = function() return 361469 end -- Living flame
		getFriendly = function() return 355913 end -- Emerald Blossom
	elseif playerClass == 'WARLOCK' then
		getHostile  = function() return 686 end   -- Shadow Bolt
		getFriendly = function() return 20707 end -- Soulstone
	elseif playerClass == 'WARRIOR' then
		getHostile  = function() return 355 end  -- Taunt
		getFriendly = function() return nil end  -- no avail
	elseif playerClass == 'DEMONHUNTER' then
		getHostile  = function() return 185123 end -- Throw Glaive
		getFriendly = function() return nil    end -- no avail
	elseif playerClass == 'HUNTER' then
		getHostile  = function() return IVS(193455) or IVS(19434) or IVS(132031) end -- Cobra Shot, Aimed Short, Steady shot
		getFriendly = function() return nil end -- no avail
	elseif playerClass == 'ROGUE' then
		getHostile  = function() return IVS(36554) or IVS(6770) end -- Shadowstep, Sap
		getFriendly = function() return IVS(36554) end -- Shadowstep
	elseif playerClass == 'DEATHKNIGHT' then
		getHostile  = function() return IVS(47541) or IVS(49576) end -- Death Coil, Death Grip
		getFriendly = function() return IVS(47541) end -- Death Coil
	elseif playerClass == 'MAGE' then
		getHostile  = function() return IVS(116) or IVS(30451) or IVS(133) end -- Frostbolt, Arcane Blast, Fireball
		getFriendly = function() return 1459 end -- Arcane intellect
	end
	-- update range spells, called from GridCore.lua
	function Grid2:UpdatePlayerRangeSpells()
		spellHostile  = GetSpellInfo( getHostile() )
		spellFriendly = GetSpellInfo( getFriendly() )
	end
end

------------------------------------------------------------------------
-- Range status
-------------------------------------------------------------------------

local friendlySpell -- friendly spell configured by the user (spell name)

local hostileSpell  -- hostile spell configured by the user (spell name)

local playerCanHeal = ({DRUID=true,PRIEST=true,SHAMAN=true,PALADIN=true,MONK=true,EVOKER=true})[playerClass]

local rezSpellID = ({DRUID=20484,PRIEST=2006,PALADIN=7328,SHAMAN=2008,MONK=115178,DEATHKNIGHT=61999,WARLOCK=20707,EVOKER=361227})[playerClass]

local rezSpell = rezSpellID and GetSpellInfo(rezSpellID)

-- These range functions can be called before Grid2:UpdatePlayerRangeSpells() is executed because SPELLS_CHANGED
-- event is executed after PLAYER_ENTERING_WORLD, it should not be a problem because those functions are checking
-- if spellFriendly/spellHostile are not nil before calling IsSpellInRange()
local Ranges = {
	[99] = UnitIsVisible,
	[38] = function(unit)
		if UnitIsUnit(unit,"player") then
			return true
		elseif UnitCanAttack('player', unit) then
			return spellHostile == nil or IsSpellInRange(spellHostile, unit) == 1
		elseif spellFriendly then
			return IsSpellInRange(spellFriendly, unit) == 1
		else
			return InCombatLockdown() or CheckInteractDistance(unit,4)
		end
	end,
	["heal"] = function(unit)
		if UnitIsUnit(unit, 'player') then
			return true
		elseif UnitCanAttack('player', unit) then
			return spellHostile == nil or IsSpellInRange(spellHostile, unit) == 1
		elseif rezSpell and UnitIsDeadOrGhost(unit) then
			return IsSpellInRange(rezSpell, unit) == 1
		elseif spellFriendly then
			return IsSpellInRange(spellFriendly, unit) == 1
		else
			return InCombatLockdown() or CheckInteractDistance(unit,4)
		end
	end,
	["spell"] = function(unit)
		if not UnitCanAttack('player', unit) then
			if UnitIsUnit(unit,'player') then
				return true
			elseif rezSpell and UnitIsDeadOrGhost(unit) then
				return IsSpellInRange(rezSpell, unit) == 1
			elseif friendlySpell then
				return IsSpellInRange(friendlySpell, unit) == 1
			end
		elseif hostileSpell then
			local range = IsSpellInRange(hostileSpell, unit)
			if range then return range == 1 end
		end
		return spellHostile == nil or IsSpellInRange(spellHostile, unit) == 1
	end,
}

local function Update(timer)
	local self = timer.__range
	local cache = self.cache
	local UnitRangeCheck = self.UnitRangeCheck
	hostileSpell = self.hostileSpell
	friendlySpell = self.friendlySpell
	for unit in Grid2:IterateRosterUnits() do
		local value = UnitRangeCheck(unit) and 1 or false
		if value ~= cache[unit] then
			cache[unit] = value
			self:UpdateIndicators(unit)
		end
	end
end

function Range:Grid_PlayerSpecChanged()
	if tonumber(self.dbx.range)==nil then -- If is not a number -> Using RangeSpell for the player class if available
		self:UpdateDB()
	end
end

function Range:Grid_UnitUpdated(_, unit)
	self.cache[unit] = self.UnitRangeCheck(unit) and 1 or false
end

function Range:Grid_UnitLeft(_, unit)
	self.cache[unit] = nil
end

function Range:GetPercent(unit)
	return self.cache[unit] or self.curAlpha
end

function Range:GetRanges()
	return Ranges, self.curRange, rezSpellID
end

function Range:IsActive(unit)
	return not self.cache[unit]
end

function Range:OnEnable()
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
	self:RegisterMessage("Grid_PlayerSpecChanged")
	self.timer = Grid2:CreateTimer( Update, self.dbx.elapsed or 0.25, false )
	self.timer.__range = self
	self.timer:Play()
end

function Range:OnDisable()
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	self:UnregisterMessage("Grid_PlayerSpecChanged")
	self.timer.__range = nil
	self.timer = Grid2:CancelTimer( self.timer )
end

-- Due to ancient code, configuration can store a heal spell name in status.dbx.range (Rejuv, Healing wave, etc), but this prevents
-- to use the same profile for different healer classes, because the heal spell is different for each class:
-- So we check if status.dbx.range stores a heal spell name (the value is not a number), and in this case the code loads the correct
-- heal spell for the class (precalculated in rangeSpell variable) instead of the heal spell stored in config.
function Range:UpdateDB()
	local dbx = self.dbx
	local dbr = dbx.ranges and dbx.ranges[playerClass] or dbx
	self.hostileSpell = dbr.hostileSpellID  and GetSpellInfo(dbr.hostileSpellID)
	self.friendlySpell = dbr.friendlySpellID and GetSpellInfo(dbr.friendlySpellID)
	self.curRange = tonumber(dbr.range) or (dbr.range=='spell' and 'spell') or (playerCanHeal and 'heal') or 38
	self.UnitRangeCheck = Ranges[self.curRange] or Ranges[38]
	self.curAlpha = dbx.default or 0.25
	self.timer = self.timer or Grid2:CreateTimer( Update )
	if self.timer then
		self.timer:SetDuration(dbx.elapsed or 0.25)
	end
end

Range.GetColor = Grid2.statusLibrary.GetColor

Range.cache = {}

Grid2.setupFunc["range"] = function(baseKey, dbx)
	Grid2:RegisterStatus( Range, {"percent", "color"}, baseKey, dbx)
	return Range
end

Grid2:DbSetStatusDefaultValue( "range", {type = "range", color1 = {r=1, g=0, b=0, a=1}, range=38, default = 0.25, elapsed = 0.5} )

-------------------------------------------------------------------------
-- rangealt status
-------------------------------------------------------------------------

RangeAlt.Grid_GroupTypeChanged = Range.Grid_GroupTypeChanged
RangeAlt.Grid_PlayerSpecChanged = Range.Grid_PlayerSpecChanged
RangeAlt.Grid_UnitUpdated = Range.Grid_UnitUpdated
RangeAlt.Grid_UnitLeft = Range.Grid_UnitLeft
RangeAlt.UpdateDB = Range.UpdateDB
RangeAlt.OnEnable = Range.OnEnable
RangeAlt.OnDisable = Range.OnDisable
RangeAlt.GetPercent = Range.GetPercent
RangeAlt.IsActive = Range.IsActive
RangeAlt.GetRanges = Range.GetRanges
RangeAlt.GetColor = Range.GetColor
RangeAlt.cache = {}

Grid2.setupFunc["rangealt"] = function(baseKey, dbx)
	Grid2:RegisterStatus( RangeAlt, {"percent", "color"}, baseKey, dbx)
	return RangeAlt
end

Grid2:DbSetStatusDefaultValue( "rangealt", {type = "rangealt", color1 = {r=1, g=0, b=0, a=1}, range= 38, default = 0.25, elapsed = 0.5} )
