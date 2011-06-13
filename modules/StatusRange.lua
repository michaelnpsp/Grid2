--[[
Created by Grid2 original authors, modified by Michael
--]]

local Range = Grid2.statusPrototype:new("range")

local UnitIsUnit= UnitIsUnit
local UnitIsDead= UnitIsDead
local IsSpellInRange= IsSpellInRange
local UnitIsVisible= UnitIsVisible
local UnitInRange= UnitInRange
local CheckInteractDistance= CheckInteractDistance

local cache = {}

local Ranges= {
	[10] = function(unit) return CheckInteractDistance(unit,3) end,
	[28] = function(unit) return CheckInteractDistance(unit,4) end,
	[38] = UnitInRange,
	[99] = UnitIsVisible,
}
local UnitNoDeadInRange

local rezSpell= ({DRUID=20484,PRIEST=2006,PALADIN=7328,SHAMAN=2008})[select(2, UnitClass("player"))] 
if rezSpell then
	rezSpell= GetSpellInfo(rezSpell)
end

-- Check range function, returns: 1= in range  false= out of range

local function UnitIsInRange(unit)
	if UnitIsUnit(unit, "player") then 
		return 1 
	elseif rezSpell and UnitIsDead(unit) and IsSpellInRange(rezSpell,unit) == 1 then
		return 1
	elseif UnitNoDeadInRange(unit) then
		return 1
	end
	return false
end	

-- Roster ranges update function

local function Update()
	for unit, guid in Grid2:IterateRosterUnits() do
		local value = UnitIsInRange(unit)
		if value ~= cache[unit] then
			cache[unit] = value
			Range:UpdateIndicators(unit)
		end
	end
end

-- Frame OnUpdate Timer event

local updateRate
local updateTime
local function OnUpdate(self, elapsed)
	updateTime= updateTime - elapsed
	if updateTime<0 then
		updateTime= updateRate
		Update()
	end
end

-- Range status 

function Range:OnEnable()
	self:UpdateDB()
	self:RegisterMessage("Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitChanged", "Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitLeft")
	self:GetFrame():Show()
	Update()
end

function Range:OnDisable()
	if self.frame then
		self.frame:Hide()
	end
	self:UnregisterMessage("Grid_UnitChanged")
	self:UnregisterMessage("Grid_UnitJoined")
	self:UnregisterMessage("Grid_UnitLeft")
end

function Range:Grid_UnitJoined(_, unit)
	cache[unit] = UnitIsInRange(unit)
end

function Range:Grid_UnitLeft(_, unit)
	cache[unit] = nil
end

function Range:GetFrame()
	local f = CreateFrame("Frame", nil, Grid2LayoutFrame)
	updateTime= updateRate
	f:SetScript("OnUpdate", OnUpdate)
	self.frame = f
	self.GetFrame = function (self) return self.frame end
	return f
end

function Range:UpdateDB()
	UnitNoDeadInRange = Ranges[tonumber(self.dbx.range) or 38] or Ranges[38]
	self.defaultAlpha = self.dbx.default or 0.25
	updateRate = self.dbx.elapsed or 0.25
end

function Range:IsActive(unit)
	return true
end

function Range:GetPercent(unit)
	return cache[unit] or self.defaultAlpha
end

function Range:GetRanges()
	return { 10, 28, 38 , 99 }
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Range, {"percent"}, baseKey, dbx)

	return Range
end

Grid2.setupFunc["range"] = Create
