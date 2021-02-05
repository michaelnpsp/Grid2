if Grid2.isClassic then return end

local Phased = Grid2.statusPrototype:new("phased")

local Grid2 = Grid2
local IsInInstance = IsInInstance
local UnitPhaseReason = UnitPhaseReason
local UnitDistanceSquared = UnitDistanceSquared

local timer
local range = {}
local cache = {}

local function ResetUnit(_, unit)
	cache[unit], range[unit] = nil, nil
end

local function UpdateUnit(_, unit)
	local phased = UnitPhaseReason(unit)
	if phased~=cache[unit] then
		cache[unit] = phased
		Phased:UpdateIndicators(unit)
	end
end

local function UpdateUnits()
	for unit in Grid2:IterateGroupedPlayers() do
		local distance, valid = UnitDistanceSquared(unit)
		local inrange = valid and distance<62500 -- UnitPhaseReason() only works if distance squared<250*250
		if inrange~=range[unit] then
			range[unit] = inrange
			UpdateUnit(nil, unit)
		end
	end
	if IsInInstance() then timer:Stop() end
end

local function UpdateTimer()
	if not (IsInInstance() or timer:IsPlaying()) then
		timer:Play()
	end
end

function Phased:OnEnable()
	self:RegisterEvent("UNIT_PHASE", UpdateUnit)
	self:RegisterEvent("UNIT_FLAGS", UpdateUnit)
	self:RegisterMessage("Grid_UnitUpdated", ResetUnit)
	self:RegisterMessage("Grid_UnitLeft",    ResetUnit)
	self:RegisterMessage("Grid_GroupTypeChanged",UpdateTimer)
	timer = Grid2:CreateTimer( UpdateUnits, 1, not IsInInstance() )
end

function Phased:OnDisable()
	self:UnregisterEvent("UNIT_PHASE")
	self:UnregisterEvent("UNIT_FLAGS")
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	self:UnregisterMessage("Grid_GroupTypeChanged")
	wipe(cache)
	wipe(range)
	Grid2:CancelTimer(timer)
end

function Phased:GetIcon()
	return "Interface\\TARGETINGFRAME\\UI-PhasingIcon"
end

function Phased:GetTexCoord()
	return 0.15625, 0.84375, 0.15625, 0.84375
end

function Phased:IsActive(unit)
	return cache[unit]
end

Phased.GetColor = Grid2.statusLibrary.GetColor
Phased.GetPercent = Grid2.statusLibrary.GetPercent

Grid2.setupFunc["phased"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Phased, {"icon", "color", "percent"}, baseKey, dbx)
	return Phased
end

Grid2:DbSetStatusDefaultValue("phased", { type = "phased", color1 = {r=1, g=0, b=0, a=1} })
