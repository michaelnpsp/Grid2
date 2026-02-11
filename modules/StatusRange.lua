-- Created by Grid2 original authors, modified by Michael
local Range = Grid2.statusPrototype:new("range")
local RangeAlt = Grid2.statusPrototype:new("rangealt")

local Grid2 = Grid2
local next = next
local tonumber = tonumber
local UnitIsUnit = UnitIsUnit
local UnitCanAttack = UnitCanAttack
local InCombatLockdown = InCombatLockdown
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local CheckInteractDistance = CheckInteractDistance
local playerClass = Grid2.playerClass
local GetSpellInfo = Grid2.API.GetSpellInfo
local IsSpellInRange = C_Spell.IsSpellInRange

local issecretvalue = Grid2.issecretvalue
local roster_guids = Grid2.roster_guids
local roster_external = Grid2.roster_external
local grouped_units = Grid2.grouped_units

-------------------------------------------------------------------------
--  Range check spells initialization
-------------------------------------------------------------------------
local spellHostile, spellFriendly = "", nil
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
		if Range.enabled then Range:UpdateDB() end
		if RangeAlt.enabled then RangeAlt:UpdateDB() end
	end
end

------------------------------------------------------------------------
-- Range status
-------------------------------------------------------------------------

local InCombat = false

local playerCanHeal = ({DRUID=true,PRIEST=true,SHAMAN=true,PALADIN=true,MONK=true,EVOKER=true})[playerClass]

local rezSpellID = ({DRUID=20484,PRIEST=2006,PALADIN=7328,SHAMAN=2008,MONK=115178,DEATHKNIGHT=61999,WARLOCK=20707,EVOKER=361227})[playerClass]

local rezSpell = rezSpellID and GetSpellInfo(rezSpellID)

local function CreateRangeCheck(spellFriendly, spellHostile, blizRange)
	return function(unit)
		if UnitIsUnit(unit,"player") then
			return true
		elseif UnitPhaseReason(unit) then
			return false
		elseif UnitCanAttack('player', unit) then
			return IsSpellInRange(spellHostile, unit) == true
		elseif rezSpell and UnitIsDeadOrGhost(unit) then
			return IsSpellInRange(rezSpell, unit) == true
		elseif blizRange and grouped_units[unit] then
			return UnitInRange(unit)
		elseif spellFriendly then -- extra CheckInteractDistance() for OOC friendly npcs if spell check fails
			return IsSpellInRange(spellFriendly, unit) == true or (not InCombat and CheckInteractDistance(unit, 4))
		else
			return InCombat or CheckInteractDistance(unit,4)
		end
	end
end

local Ranges = {
	[99] = function() return UnitIsVisible end,
	[38] = CreateRangeCheck,
	["heal"] = CreateRangeCheck,
	["spell"] = CreateRangeCheck,
}

Range.cache = setmetatable( {}, {__index = function() return false end} )

Range.GetColor = Grid2.statusLibrary.GetColor

function Range:UpdateUnits() -- we need to update this on a timer for non-grouped units: target, focus, etc.
	local cache = self.cache
	local check = self.UnitRangeCheck
	for unit in next, self.refreshUnits do
		local new = check(unit)
		local old = cache[unit]
		if issecretvalue(new) or issecretvalue(old) or new ~= old then
			cache[unit] = new
			self:UpdateIndicators(unit)
		end
	end
end

function Range:PLAYER_REGEN_ENABLED()
	InCombat = false
end

function Range:PLAYER_REGEN_DISABLED()
	InCombat = true
end

function Range:UNIT_IN_RANGE_UPDATE(_, unit)
	self.cache[unit] = self.UnitRangeCheck(unit)
	self:UpdateIndicators(unit)
end

function Range:Grid_UnitUpdated(_, unit)
	self.cache[unit] = self.UnitRangeCheck(unit)
	self.timer:SetPlaying( next(self.refreshUnits)~=nil )
end

function Range:Grid_UnitLeft(_, unit)
	self.cache[unit] = nil
end

function Range:GetPercent(unit)
	return self.curAlpha
end

function Range:GetRanges()
	return Ranges, self.curRange, rezSpellID
end

function Range:IsActive(unit)
	return self.cache[unit], true -- true means inverted activation, hackish because we cannot negate a secret value
end

function Range:OnEnable()
	InCombat = InCombatLockdown()
	self.timer = Grid2:CreateTimer( function() self:UpdateUnits() end, self.dbx.elapsed or 0.25, false )
	self.timer:SetPlaying( next(self.refreshUnits)~=nil )
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	if self.curRange==38 then
		Grid2:RegisterRosterUnitEvent("UNIT_IN_RANGE_UPDATE", Range)
	end
end

function Range:OnDisable()
	self.timer = Grid2:CancelTimer( self.timer )
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	self:UnregisterEvent("UNIT_IN_RANGE_UPDATE")
	Grid2:UnregisterRosterUnitEvent("UNIT_IN_RANGE_UPDATE")
end

function Range:UpdateDB()
	local dbx = self.dbx
	local dbr = dbx.ranges and dbx.ranges[playerClass] or dbx
	local spellh = dbr.hostileSpellID and GetSpellInfo(dbr.hostileSpellID) or spellHostile
	local spellf = dbr.friendlySpellID and GetSpellInfo(dbr.friendlySpellID) or spellFriendly
	local rangec = tonumber(dbr.range) or dbr.range
	self.curRange = Ranges[rangec] and rangec or 38
	self.refreshUnits = (rangec==38) and roster_external or roster_guids
	self.UnitRangeCheck = Ranges[rangec](spellf, spellh, rangec==38)
	self.curAlpha = dbx.default or 0.25
	if self.timer then self.timer:SetDuration(dbx.elapsed or 0.25) end
end

Grid2.setupFunc["range"] = function(baseKey, dbx)
	Grid2:RegisterStatus( Range, {"percent", "color"}, baseKey, dbx)
	return Range
end

Grid2:DbSetStatusDefaultValue( "range", {type = "range", color1 = {r=1, g=0, b=0, a=1}, range=38, default = 0.25, elapsed = 0.5} )

-------------------------------------------------------------------------
-- rangealt status
-------------------------------------------------------------------------

RangeAlt.cache = setmetatable( {}, {__index = function() return false end} )
RangeAlt.GetColor = Range.GetColor
RangeAlt.UNIT_IN_RANGE_UPDATE = Range.UNIT_IN_RANGE_UPDATE
RangeAlt.Grid_UnitUpdated = Range.Grid_UnitUpdated
RangeAlt.Grid_UnitLeft = Range.Grid_UnitLeft
RangeAlt.UpdateUnits = Range.UpdateUnits
RangeAlt.OnEnable = Range.OnEnable
RangeAlt.OnDisable = Range.OnDisable
RangeAlt.GetPercent = Range.GetPercent
RangeAlt.IsActive = Range.IsActive
RangeAlt.UpdateDB = Range.UpdateDB
RangeAlt.GetRanges = Range.GetRanges

Grid2.setupFunc["rangealt"] = function(baseKey, dbx)
	Grid2:RegisterStatus( RangeAlt, {"percent", "color"}, baseKey, dbx)
	return RangeAlt
end

Grid2:DbSetStatusDefaultValue( "rangealt", {type = "rangealt", color1 = {r=1, g=0, b=0, a=1}, range= 38, default = 0.25, elapsed = 0.5} )
