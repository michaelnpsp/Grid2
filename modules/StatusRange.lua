--[[
Created by Grid2 original authors, modified by Michael
--]]

local Range = Grid2.statusPrototype:new("range")
local RangeAlt = Grid2.statusPrototype:new("rangealt")

local Grid2 = Grid2
local tonumber = tonumber
local tostring = tostring
local UnitIsUnit = UnitIsUnit
local UnitInRange = UnitInRange
local UnitIsFriend = UnitIsFriend
local UnitCanAttack = UnitCanAttack
local UnitCanAssist = UnitCanAssist
local IsSpellInRange = IsSpellInRange
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local CheckInteractDistance = CheckInteractDistance
local UnitPhaseReason = UnitPhaseReason or Grid2.Dummy

local groupType
local grouped_units = Grid2.grouped_units
local playerClass = Grid2.playerClass

-------------------------------------------------------------------------
-- shared functions
-------------------------------------------------------------------------

local function Update(timer)
	local self = timer.__range
	local cache, UnitRangeCheck = self.cache, self.UnitRangeCheck
	for unit in Grid2:IterateRosterUnits() do
		local value = UnitRangeCheck(unit) and 1 or false
		if value ~= cache[unit] then
			cache[unit] = value
			self:UpdateIndicators(unit)
		end
	end
end

-------------------------------------------------------------------------
-- Range status
-------------------------------------------------------------------------

local friendlySpell -- friendly spell configured by the user (spell name)
local hostileSpell  -- friendly spell configured by the user (spell name)

local rezSpellID = ({ -- classic has the same spellIDs
		DRUID       = 20484,
		PRIEST      = 2006,
		PALADIN     = 7328,
		SHAMAN      = 2008,
		MONK        = 115178,
		DEATHKNIGHT = 61999,
		WARLOCK     = 20707,
		EVOKER      = 361227,
	})[playerClass]
local rezSpell = rezSpellID and GetSpellInfo(rezSpellID)

local rangeSpellID = ({
		DRUID   = Grid2.isClassic and 774 or 8936,
		PRIEST  = Grid2.isClassic and 2050  or 2061,
		SHAMAN  = Grid2.isClassic and 25357 or 77472,
		PALADIN = 19750,
		MONK    = 116670,
		EVOKER  = 361469,
	})[playerClass]
local rangeSpell = rangeSpellID and GetSpellInfo(rangeSpellID)

local Ranges = {
	[99] = UnitIsVisible,
	[10] = function(unit)
		return CheckInteractDistance(unit,3)
	end,
	[28] = function(unit)
		return CheckInteractDistance(unit,4)
	end,
	[38] = function(unit)
		if grouped_units[unit] and groupType~='solo' then
			return UnitIsUnit(unit,"player") or UnitInRange(unit)
		else
			return CheckInteractDistance(unit,4) -- 28 yards for non grouped units: target/focus/bossX or when solo (because UnitInRange() does not work for pet when solo)
		end
	end,
	["heal"] = function(unit)
		if UnitPhaseReason(unit) then
			return
		elseif UnitIsFriend("player", unit) then
			if UnitIsUnit(unit,'player') then
				return true
			elseif UnitIsDeadOrGhost(unit) then
				return IsSpellInRange(rezSpell,unit)==1
			else
				return IsSpellInRange(rangeSpell,unit)==1
			end
		else
			return CheckInteractDistance(unit,4) -- 28y for enemies
		end
	end,
	["spell"] = function(unit)
		if not UnitPhaseReason(unit) then
			if UnitIsFriend("player", unit) then
				if UnitIsUnit(unit,'player') then
					return true
				elseif rezSpell and UnitIsDeadOrGhost(unit) then
					return IsSpellInRange(rezSpell,unit)==1
				elseif friendlySpell then
					return IsSpellInRange(friendlySpell,unit)==1
				end
			elseif hostileSpell then
				local range = IsSpellInRange(hostileSpell,unit)
				if range then
					return range==1
				else
					return CheckInteractDistance(unit,4) -- 28y for enemies
				end
			else	
				return CheckInteractDistance(unit,4) -- 28y for enemies
			end
		end
	end,
}

function Range:Grid_GroupTypeChanged(_, newGroupType)
	groupType = newGroupType
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
	return Ranges, self.curRange
end

function Range:IsActive(unit)
	return not self.cache[unit]
end

function Range:OnEnable()
	groupType = Grid2:GetGroupType()
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
	self:RegisterMessage("Grid_PlayerSpecChanged")
	self:RegisterMessage("Grid_GroupTypeChanged")
	self.timer = Grid2:CreateTimer( Update, self.dbx.elapsed or 0.25 )
	self.timer.__range = self
end

function Range:OnDisable()
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	self:UnregisterMessage("Grid_PlayerSpecChanged")
	self:UnregisterMessage("Grid_GroupTypeChanged")
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
	if self.name == 'range' then
		friendlySpell = dbr.friendlySpellID and GetSpellInfo(dbr.friendlySpellID)
		hostileSpell  = dbr.hostileSpellID  and GetSpellInfo(dbr.hostileSpellID)
	end	
	self.curRange = tonumber(dbr.range) or (dbr.range=='spell' and 'spell') or (rangeSpell and 'heal') or 38
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

Grid2:DbSetStatusDefaultValue( "range", {type = "range", color1 = {r=1, g=0, b=0, a=1}, range=38, default = 0.25, elapsed = 0.5})

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
RangeAlt.GetRangers = Range.GetRanges
RangeAlt.GetColor = Range.GetColor
RangeAlt.cache = {}

Grid2.setupFunc["rangealt"] = function(baseKey, dbx)
	Grid2:RegisterStatus( RangeAlt, {"percent", "color"}, baseKey, dbx)
	return RangeAlt
end

Grid2:DbSetStatusDefaultValue( "rangealt", {type = "rangealt", color1 = {r=1, g=0, b=0, a=1}, range=28, default = 0.25, elapsed = 0.5})
