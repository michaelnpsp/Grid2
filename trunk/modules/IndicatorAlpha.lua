local Alpha = Grid2.indicatorPrototype:new("alpha")

Alpha.Create = Grid2.Dummy
Alpha.Layout = Grid2.Dummy

local defaultAlpha

-- standard update, opacity value is provided by the active status 
local function Alpha_OnUpdate1(self, parent, unit, status)
	parent:SetAlpha(status and status:GetPercent(unit) or 1)
end

-- optional Update, ignore alpha provided by the statuses and instead use an opacity defined in the indicator setup
local function Alpha_OnUpdate2(self, parent, unit, status)
	parent:SetAlpha(status and defaultAlpha or 1)
end

function Alpha:Disable(parent)
	parent:SetAlpha(1)
end

function Alpha:UpdateDB()
	defaultAlpha = self.dbx.alpha
	self.OnUpdate = defaultAlpha and Alpha_OnUpdate2 or Alpha_OnUpdate1
end

local function Create(indicatorKey, dbx)
	Alpha.dbx = dbx
	Alpha:UpdateDB()
	Grid2:RegisterIndicator(Alpha, { "percent" })
	return Alpha
end

Grid2.setupFunc["alpha"] = Create
