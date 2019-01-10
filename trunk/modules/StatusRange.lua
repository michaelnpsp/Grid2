--[[
Created by Grid2 original authors, modified by Michael
--]]

local Range = Grid2.statusPrototype:new("range")

local Grid2 = Grid2
local tonumber = tonumber
local tostring = tostring
local UnitIsUnit = UnitIsUnit
local UnitInRange = UnitInRange
local IsSpellInRange = IsSpellInRange
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local CheckInteractDistance = CheckInteractDistance

local timer

local cache = {}

local Ranges= {
	["10"] = function(unit) return CheckInteractDistance(unit,3) end,
	["28"] = function(unit) return CheckInteractDistance(unit,4) end,
	["38"] = UnitInRange,
	["99"] = UnitIsVisible,
}
local UnitRangeCheck
local UnitIsInRange

local playerClass = select(2, UnitClass("player"))
 
local rangeSpell
local rangeSpellID = ({PALADIN=19750,SHAMAN=77472,DRUID=774,PRIEST=73325,MONK=115450})[playerClass]
if rangeSpellID then
	rangeSpell = GetSpellInfo(rangeSpellID)
	Ranges[ rangeSpell ] = function(unit) return IsSpellInRange(rangeSpell, unit) == 1 end
end

local rezSpell = ({DRUID=20484,PRIEST=2006,PALADIN=7328,SHAMAN=2008,MONK=115178,DEATHKNIGHT=61999,WARLOCK=20707})[playerClass]
if rezSpell then
	rezSpell = GetSpellInfo(rezSpell)
	UnitIsInRange = function(unit)
		if UnitIsDeadOrGhost(unit) then
			return UnitIsUnit(unit,"player") or IsSpellInRange(rezSpell,unit) == 1
		else
			return UnitRangeCheck(unit)
		end
	end
end

-- Roster ranges update function

local function Update()
	for unit in Grid2:IterateRosterUnits() do
		local value = UnitIsInRange(unit) and 1 or false
		if value ~= cache[unit] then
			cache[unit] = value
			Range:UpdateIndicators(unit)
		end
	end
end

-- Range status 

function Range:OnEnable()
	self:UpdateDB()
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
	self:RegisterMessage("Grid_GroupTypeChanged")
	self:RegisterMessage("Grid_PlayerSpecChanged")
	timer:Play()
	Update()
end

function Range:OnDisable()
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	self:UnregisterMessage("Grid_GroupTypeChanged")
	self:UnregisterMessage("Grid_PlayerSpecChanged")
	timer:Stop()
	wipe(cache)
end

-- {{ Workaround for WoW 5.0.4 UnitInRange() bug (returns false for player&pet while solo or in arena)
local Ranges38 = { 
	solo  = function() return true end,
	arena = function(unit) return UnitIsUnit(unit,"player") or UnitInRange(unit) end
}
function Range:Grid_GroupTypeChanged(_, groupType)
	if self.range == "38" then
		self:UpdateDB()
	end
end
-- }}

-- If the range configured is a Heal Spell, when changing spec the heal spell could not be available
-- in this case we fall back to the standard 38 yards range.
function Range:Grid_PlayerSpecChanged()
	if not tonumber(self.dbx.range) then -- If is not a number -> Using RangeSpell for the player class if available
		self:UpdateDB()
	end	
end

function Range:Grid_UnitUpdated(_, unit)
	cache[unit] = UnitIsInRange(unit) and 1 or false
end

function Range:Grid_UnitLeft(_, unit)
	cache[unit] = nil
end

-- Due to ancient code, configuration can store a heal spell name in status.dbx.range (Rejuv, Healing wave, etc), but this prevents 
-- to use the same profile for different healer classes, because the heal spell is different for each class:
-- So we check if status.dbx.range stores a heal spell name (the value is not a number), and in this case the code loads the correct 
-- heal spell for the class (precalculated in rangeSpell variable) instead of the heal spell stored in config.
function Range:UpdateDB()
	Ranges["38"] = Ranges38[ Grid2:GetGroupType() ] or UnitInRange
	self.defaultAlpha = self.dbx.default or 0.25
	self.range = tonumber(self.dbx.range) and tostring(self.dbx.range) or (rangeSpellID and IsSpellKnown(rangeSpellID) and rangeSpell) 
	UnitRangeCheck = Ranges[self.range]
	if not UnitRangeCheck then
		self.range = "38"
		UnitRangeCheck = Ranges["38"]
	end
	if not rezSpell then
		UnitIsInRange = UnitRangeCheck
	end
	timer = timer or Grid2:CreateTimer( Update )
	timer:SetDuration(self.dbx.elapsed or 0.25)
end

function Range:GetPercent(unit)
	return cache[unit] or self.defaultAlpha
end

function Range:GetRanges()
	return Ranges, rangeSpell
end

function Range:IsActive(unit)
	return not cache[unit]
end

Range.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Range, {"percent", "color"}, baseKey, dbx)
	return Range
end

Grid2.setupFunc["range"] = Create

Grid2:DbSetStatusDefaultValue( "range", {type = "range", color1 = {r=1, g=0, b=0, a=1}, range= 38, default = 0.25, elapsed = 0.5})
