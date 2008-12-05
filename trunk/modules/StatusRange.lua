local Range = Grid2.statusPrototype:new("range")

Range.defaultDB = {
	profile = {
		default = 0.6,
		elapsed = 0.1,
		ranges = {
			[40] = 1,
		},
	},
}

local cache = {}
local GetRangeValue

local function Update()
	for unit in Grid2:IterateRoster(true) do
		local value = GetRangeValue(unit)
		if value ~= cache[unit] then
			cache[unit] = value
			Range:UpdateIndicators(unit)
		end
	end
end


function Range:OnEnable()
	self:RegisterMessage("Grid_RangesUpdated")
end

function Range:Grid_RangesUpdated()
	-- @FIXME: based of config
	local check = GridRange:GetRangeCheck(40) or GridRange:GetRangeCheck(28)
	local rezCheck = GridRange:GetRezCheck()
	if rezCheck then
		GetRangeValue = function (unit)
			return (check(unit) or rezCheck(unit)) and 1
		end
	else
		GetRangeValue = function (unit)
			return check(unit) and 1
		end
	end
	Update()
	if not self.frame then
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
	end
	self.frame:Show()
end

function Range:OnDisable()
	self.frame:Hide()
	self:UnregisterMessage("Grid_RangesUpdated")
end

function Range:IsActive(unit)
	return true
end

function Range:GetPercent(unit)
	return cache[unit] or self.db.profile.default
end

Grid2:RegisterStatus(Range, { "percent" })
