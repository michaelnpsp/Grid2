local Range = Grid2.statusPrototype:new("range")

Range.defaultDB = {
	profile = {
		default = 0.25,
		elapsed = 0.1,
		range = 40,
	},
}

local cache = {}
local CheckUnitRange

local function Update()
	for guid, unitid in Grid2:IterateRoster() do
		local value = CheckUnitRange(unitid)
		if value ~= cache[unitid] then
			cache[unitid] = value
			Range:UpdateIndicators(unitid)
		end
	end
end

function Range:OnEnable()
	self:RegisterMessage("Grid_RangesUpdated")
	self:RegisterMessage("Grid_UnitChanged")
	self:RegisterMessage("Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitLeft")
	self:Grid_RangesUpdated()
end

function Range:Grid_UnitJoined(unit)
	cache[unit] = CheckUnitRange(unit)
	self:UpdateIndicators(unit)
end

function Range:Grid_UnitLeft(unit)
	cache[unit] = nil
end

function Range:Grid_UnitChanged(unit)
	cache[unit] = CheckUnitRange(unit)
	self:UpdateIndicators(unit)
end

function Range:GetFrame()
	local f = CreateFrame("Frame", nil, Grid2LayoutFrame)
	f.elapsed = 0
	f:SetScript("OnUpdate", function (self, elapsed)
		elapsed = elapsed + self.elapsed
		if elapsed > Range.db.profile.elapsed then
			elapsed = 0
			Update()
		end
		self.elapsed = elapsed
	end)
	self.frame = f
	self.GetFrame = function (self) return self.frame end
	return f
end

function Range:Grid_RangesUpdated()
	local check = GridRange:GetRangeCheck(Range.db.profile.range)
	local rezCheck = GridRange:GetRezCheck()

	if rezCheck then
		CheckUnitRange = function (unit)
			return (check(unit) or rezCheck(unit)) and 1
		end
	else
		CheckUnitRange = function (unit)
			return check(unit) and 1
		end
	end

	Update()
	self:GetFrame():Show()
end

function Range:OnDisable()
	if (self.frame) then
		self.frame:Hide()
	end
	self:UnregisterMessage("Grid_RangesUpdated")
	self:UnregisterMessage("Grid_UnitChanged")
	self:UnregisterMessage("Grid_UnitJoined")
	self:UnregisterMessage("Grid_UnitLeft")
end

function Range:IsActive(unit)
	return true
end

function Range:GetPercent(unit)
	return cache[unit] or self.db.profile.default
end

Grid2:RegisterStatus(Range, { "percent" })
