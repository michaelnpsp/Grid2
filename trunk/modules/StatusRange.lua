--[[
Created by Grid2 original authors, modified by Michael
--]]

local Range = Grid2.statusPrototype:new("range")

local Grid2 = Grid2
local UnitIsUnit = UnitIsUnit
local UnitInRange = UnitInRange
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local IsSpellInRange = IsSpellInRange
local CheckInteractDistance = CheckInteractDistance

local cache = {}

local Ranges= {
	["10"] = function(unit) return CheckInteractDistance(unit,3) end,
	["28"] = function(unit) return CheckInteractDistance(unit,4) end,
	["38"] = function(unit) return unit=="player" or unit=="pet" or UnitInRange(unit) end,
	["99"] = UnitIsVisible,
}

local rezSpell = ({DRUID=20484,PRIEST=2006,PALADIN=7328,SHAMAN=2008})[select(2, UnitClass("player"))]
if rezSpell then
	rezSpell = GetSpellInfo(rezSpell)
end

-- Check range functions

local UnitIsInRange
local UnitNoDeadInRange
local function UnitDeadInRange(unit)
	if UnitIsDeadOrGhost(unit) then
		return UnitIsUnit(unit,"player") or IsSpellInRange(rezSpell,unit) == 1
	else
		return UnitNoDeadInRange(unit)
	end
end

-- Roster ranges update function

local function Update(self)
	for unit in Grid2:IterateRosterUnits() do
		local value = UnitIsInRange(unit) and 1 or false
		if value ~= cache[unit] then
			cache[unit] = value
			Range:UpdateIndicators(unit)
		end
	end
	self:Play()
end

-- Range status 

function Range:OnEnable()
	self:CreateTimer()
	self:UpdateDB()
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
	self.timer:Play()
end

function Range:OnDisable()
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	self.timer:Stop() 
end

function Range:Grid_UnitUpdated(_, unit)
	cache[unit] = UnitIsInRange(unit) and 1 or false
end

function Range:Grid_UnitLeft(_, unit)
	cache[unit] = nil
end

function Range:CreateTimer()
	local timer = CreateFrame("Frame", nil, Grid2LayoutFrame):CreateAnimationGroup()
	timer.animation = timer:CreateAnimation()
	timer.animation:SetOrder(1)
	timer:SetScript("OnFinished", Update)
	self.timer  = timer
	self.CreateTimer = Grid2.Dummy
end

function Range:UpdateDB()
	UnitNoDeadInRange = Ranges[tostring(self.dbx.range) or "38"] or Ranges["38"]
	UnitIsInRange     = rezSpell and UnitDeadInRange or UnitNoDeadInRange
	self.defaultAlpha = self.dbx.default or 0.25
	if self.timer then 
		self.timer.animation:SetDuration(self.dbx.elapsed or 0.25) 
	end
end

function Range:GetPercent(unit)
	return cache[unit] or self.defaultAlpha
end

function Range:GetRanges()
	return Ranges
end

Range.IsActive = Grid2.statusLibrary.IsActive

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Range, {"percent"}, baseKey, dbx)
	return Range
end

Grid2.setupFunc["range"] = Create

Grid2:DbSetStatusDefaultValue( "range", {type = "range", range= 38, default = 0.25, elapsed = 0.5})