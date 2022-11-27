local Alpha = Grid2.indicatorPrototype:new("alpha")

local defaultAlpha = 1
local enabledAlpha = 0.5

Alpha.Create = Grid2.Dummy
Alpha.Layout = Grid2.Dummy

-- standard update, opacity value is provided by the active status
local function Alpha_OnUpdate1(self, parent, unit, status)
	parent:SetAlpha(status and status:GetPercent(unit) or defaultAlpha)
end

-- optional update, alpha provided by the statuses is ignored and instead the opacity defined in the indicator setup is used
local function Alpha_OnUpdate2(self, parent, unit, status)
	parent:SetAlpha(status and enabledAlpha or defaultAlpha)
end

function Alpha:GetFrame(parent)
	return parent
end

function Alpha:Disable(parent)
	parent:SetAlpha(1)
end

function Alpha:UpdateDB()
	defaultAlpha = self.dbx.defaultAlpha or 1
	enabledAlpha = self.dbx.alpha
	self.OnUpdate = enabledAlpha and Alpha_OnUpdate2 or Alpha_OnUpdate1
end

local function Create(indicatorKey, dbx)
	Alpha.dbx = dbx
	Grid2:RegisterIndicator(Alpha, { "percent" })
	return Alpha
end

Grid2.setupFunc["alpha"] = Create
