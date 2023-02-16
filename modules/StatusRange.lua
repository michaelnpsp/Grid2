--[[
Created by Grid2 original authors, modified by Michael
--]]

local Range = Grid2.statusPrototype:new("range")

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

local timer
local curAlpha
local curRange
local groupType
local cache = {}
local UnitRangeCheck
local grouped_units = Grid2.grouped_units
local playerClass = Grid2.playerClass

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
		DRUID   = 774,
		PALADIN = 19750,
		PRIEST  = Grid2.isClassic and 2050  or 2061,
		SHAMAN  = Grid2.isClassic and 25357 or 77472,
		MONK    = 115450,
		EVOKER  = 361469,
	})[playerClass]
local rangeSpell = rangeSpellID and GetSpellInfo(rangeSpellID)

local Ranges= {
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

local function Update()
	for unit in Grid2:IterateRosterUnits() do
		local value = UnitRangeCheck(unit) and 1 or false
		if value ~= cache[unit] then
			cache[unit] = value
			Range:UpdateIndicators(unit)
		end
	end
end

function Range:Grid_GroupTypeChanged(_, newGroupType)
	groupType = newGroupType
end

function Range:Grid_PlayerSpecChanged()
	if tonumber(self.dbx.range)==nil then -- If is not a number -> Using RangeSpell for the player class if available
		self:UpdateDB()
	end
end

function Range:Grid_UnitUpdated(_, unit)
	cache[unit] = UnitRangeCheck(unit) and 1 or false
end

function Range:Grid_UnitLeft(_, unit)
	cache[unit] = nil
end

function Range:GetPercent(unit)
	return cache[unit] or curAlpha
end

function Range:GetRanges()
	return Ranges, curRange
end

function Range:IsActive(unit)
	return not cache[unit]
end

function Range:OnEnable()
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
	self:RegisterMessage("Grid_PlayerSpecChanged")
	self:RegisterMessage("Grid_GroupTypeChanged")
	timer:Play()
end

function Range:OnDisable()
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	self:UnregisterMessage("Grid_PlayerSpecChanged")
	self:UnregisterMessage("Grid_GroupTypeChanged")
	timer:Stop()
end

-- Due to ancient code, configuration can store a heal spell name in status.dbx.range (Rejuv, Healing wave, etc), but this prevents
-- to use the same profile for different healer classes, because the heal spell is different for each class:
-- So we check if status.dbx.range stores a heal spell name (the value is not a number), and in this case the code loads the correct
-- heal spell for the class (precalculated in rangeSpell variable) instead of the heal spell stored in config.
function Range:UpdateDB()
	local dbx = self.dbx
	local dbr = dbx.ranges and dbx.ranges[playerClass] or dbx
	friendlySpell = dbr.friendlySpellID and GetSpellInfo(dbr.friendlySpellID)
	hostileSpell  = dbr.hostileSpellID  and GetSpellInfo(dbr.hostileSpellID)
	curRange = tonumber(dbr.range) or (dbr.range=='spell' and 'spell') or (rangeSpell and 'heal') or 38
	UnitRangeCheck = Ranges[curRange] or Ranges[38]
	curAlpha = dbx.default or 0.25
	timer = timer or Grid2:CreateTimer( Update )
	timer:SetDuration(dbx.elapsed or 0.25)
end

Range.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	groupType = Grid2:GetGroupType()
	Grid2:RegisterStatus(Range, {"percent", "color"}, baseKey, dbx)
	return Range
end

Grid2.setupFunc["range"] = Create

Grid2:DbSetStatusDefaultValue( "range", {type = "range", color1 = {r=1, g=0, b=0, a=1}, range=38, default = 0.25, elapsed = 0.5})
