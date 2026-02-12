if not (UnitInPhase or UnitPhaseReason) then return end

local Phased = Grid2.statusPrototype:new("phased")

local next = next
local Grid2 = Grid2
local IsInInstance = IsInInstance
local UnitInPhase = UnitInPhase
local UnitPhaseReason = UnitPhaseReason
local UnitDistanceSquared = UnitDistanceSquared
local UnitInOtherParty = UnitInOtherParty

local timer
local einst -- enabled inside instances
local elfg  -- display lfg eye icon
local range = {}
local cache = {}

local function ResetUnit(_, unit)
	cache[unit], range[unit] = nil, nil
end

local UpdateUnit = UnitPhaseReason and function(_, unit)
	local phased = UnitPhaseReason(unit)
	if phased~=cache[unit] then
		cache[unit] = phased
		Phased:UpdateIndicators(unit)
	end
end or function(_, unit)
	local phased = not UnitInPhase(unit) or nil
	if phased~=cache[unit] then
		cache[unit] = phased
		Phased:UpdateIndicators(unit)
	end
end

local function StopTimer()
	timer:Stop()
	wipe(range)
	for unit in next, cache do
		cache[unit] = nil
		Phased:UpdateIndicators(unit)
	end
end

local function UpdateUnits()
	if einst or not IsInInstance() then
		for unit in Grid2:IterateGroupedPlayers() do
			if elfg and UnitInOtherParty(unit) and cache[unit]~=-1 then -- player in another instance group LFG/PVP instance
				cache[unit] = -1
				Phased:UpdateIndicators(unit)
			else
				local distance, valid = UnitDistanceSquared(unit)
				if valid then
					local inrange = distance<62500 -- UnitPhaseReason() only works if distance squared<250*250
					if inrange~=range[unit] then
						range[unit] = inrange
						UpdateUnit(nil, unit)
					end
				end
			end
		end
	else
		StopTimer()
	end
end

local function UpdateTimer()
	if not ( IsInInstance() or timer:IsPlaying() ) then
		timer:Play()
	end
end

function Phased:OnEnable()
	einst = self.dbx.enabledInstances
	elfg  = self.dbx.displayLFG
	self:RegisterEvent("UNIT_PHASE", UpdateUnit)
	self:RegisterEvent("UNIT_FLAGS", UpdateUnit)
	self:RegisterEvent("UNIT_OTHER_PARTY_CHANGED", UpdateUnit)
	self:RegisterMessage("Grid_UnitUpdated", ResetUnit)
	self:RegisterMessage("Grid_UnitLeft",    ResetUnit)
	if not einst then
		self:RegisterMessage("Grid_GroupTypeChanged",UpdateTimer)
	end
	timer = Grid2:CreateTimer( UpdateUnits, 1, einst or not IsInInstance() )
end

function Phased:OnDisable()
	self:UnregisterEvent("UNIT_PHASE")
	self:UnregisterEvent("UNIT_FLAGS")
	self:UnregisterEvent("UNIT_OTHER_PARTY_CHANGED")
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	self:UnregisterMessage("Grid_GroupTypeChanged")
	wipe(cache)
	wipe(range)
	Grid2:CancelTimer(timer)
end

function Phased:GetIcon(unit)
	return cache[unit]==-1 and "Interface\\LFGFrame\\LFG-Eye" or "Interface\\TARGETINGFRAME\\UI-PhasingIcon"
end

function Phased:GetTexCoord(unit)
	if cache[unit]==-1 then -- lfg eye
		return 0.14, 0.235, 0.28, 0.47
	else -- phased
		return 0.15625, 0.84375, 0.15625, 0.84375
	end
end

function Phased:IsActive(unit)
	return not not cache[unit]
end

Phased.GetColor = Grid2.statusLibrary.GetColor
Phased.GetPercent = Grid2.statusLibrary.GetPercent

Grid2.setupFunc["phased"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Phased, {"icon", "color", "percent"}, baseKey, dbx)
	return Phased
end

Grid2:DbSetStatusDefaultValue("phased", { type = "phased", color1 = {r=1, g=0, b=0, a=1} })
