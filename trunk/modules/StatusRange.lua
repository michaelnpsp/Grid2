local Range = Grid2.statusPrototype:new("range")

local cache = {}
local CheckUnitRange

local function Update()
	for unit, guid in Grid2:IterateRosterUnits() do
		local value = CheckUnitRange(unit)
		if value ~= cache[unit] then
			cache[unit] = value
			Range:UpdateIndicators(unit)
		end
	end
end

function Range:OnEnable()
	self:RegisterMessage("Grid_RangesUpdated")
	self:RegisterMessage("Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitChanged", "Grid_UnitJoined")
	self:RegisterMessage("Grid_UnitLeft")
	self:Grid_RangesUpdated()
end

function Range:Grid_UnitJoined(_, unit)
	cache[unit] = CheckUnitRange(unit)
	-- self:UpdateIndicators(unit)
end

function Range:Grid_UnitLeft(_, unit)
	cache[unit] = nil
end

function Range:GetFrame()
	local f = CreateFrame("Frame", nil, Grid2LayoutFrame)
	f.elapsed = 0
	f:SetScript("OnUpdate", function (self, elapsed)
		elapsed = elapsed + self.elapsed
		if elapsed > Range.dbx.elapsed then
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
	local queried_range = Range.dbx.range
	local check, actual_range, spell = GridRange:GetRangeCheck(queried_range or 40)
	local rezCheck = GridRange:GetRezCheck()

	if not check then
		print("Grid2 Range updated. No range check function returned, this is an error.")
		CheckUnitRange = function () return 1 end
		if self.frame then self.frame:Hide() end
	else
		-- print(("Grid2 Range updated. %d queried and %d obtained (from %s)."):format(queried_range or -1, actual_range or -1, spell or "*API*"))
		if rezCheck then
			CheckUnitRange = function (unit)
				return (check(unit) or rezCheck(unit)) and 1
			end
		else
			CheckUnitRange = function (unit)
				return check(unit) and 1
			end
		end
		self:GetFrame():Show()
	end
	Update()
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
	return cache[unit] or self.dbx.default
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Range, {"percent"}, baseKey, dbx)

	return Range
end

Grid2.setupFunc["range"] = Create

function Grid2:DebugRange()
	for unit, guid in Grid2:IterateRosterUnits() do
		local value = CheckUnitRange(unit)
print(unit, value, cache[unit])
		if value ~= cache[unit] then
			cache[unit] = value
			Range:UpdateIndicators(unit)
		end
	end
end
