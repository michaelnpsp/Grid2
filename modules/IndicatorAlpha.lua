local Alpha = Grid2.indicatorPrototype:new("alpha")

local indicatorName
local defaultAlpha = 1
local enabledAlpha = 0.5

Alpha.Create = Grid2.Dummy
Alpha.Layout = Grid2.Dummy

-- standard update, opacity value is provided by the active status
local function Alpha_OnUpdate1(self, parent, unit, status, state, secret)
	if secret then
		parent:SetAlphaFromBoolean(state, status:GetPercent(unit), defaultAlpha)
	else
		parent:SetAlpha(status and status:GetPercent(unit) or defaultAlpha)
	end
end

-- optional update, alpha provided by the statuses is ignored and instead the opacity defined in the indicator setup is used
local function Alpha_OnUpdate2(self, parent, unit, status, state, secret)
	if secret then
		parent:SetAlphaFromBoolean(state, enabledAlpha, defaultAlpha)
	else
		parent:SetAlpha(status and enabledAlpha or defaultAlpha)
	end
end

-- standard indicator update, opacity value is provided by the active status
local function Alpha_OnUpdate3(self, parent, unit, status, state, secret)
	local target = parent[indicatorName] or parent
	if secret then
		target:SetAlphaFromBoolean(status, status:GetPercent(unit), defaultAlpha)
	else
		target:SetAlpha(status and status:GetPercent(unit) or defaultAlpha)
	end
end

-- optional indicator update, alpha provided by the statuses is ignored and instead the opacity defined in the indicator setup is used
local function Alpha_OnUpdate4(self, parent, unit, status, state, secret)
	local target = parent[indicatorName] or parent
	if secret then
		target:SetAlphaFromBoolean(state, enabledAlpha, defaultAlpha)
	else
		target:SetAlpha(status and enabledAlpha or defaultAlpha)
	end
end

function Alpha:GetFrame(parent)
	return parent[indicatorName] or parent
end

function Alpha:Disable(parent)
	self:GetFrame(parent):SetAlpha(1)
end

function Alpha:UpdateDB()
	local dbx = self.dbx
	defaultAlpha = dbx.defaultAlpha or 1
	enabledAlpha = dbx.alpha
	indicatorName = dbx.anchorTo -- hackish, we need to use anchorTo fieldname to force the controlled indicator to be loaded before alpha indicator in GridSetup.lua
	if indicatorName and Grid2.indicators[indicatorName] then
		self.OnUpdate = enabledAlpha and Alpha_OnUpdate4 or Alpha_OnUpdate3
	else
		self.OnUpdate = enabledAlpha and Alpha_OnUpdate2 or Alpha_OnUpdate1
	end
end

local function Create(indicatorKey, dbx)
	Alpha.dbx = dbx
	Grid2:RegisterIndicator(Alpha, { "percent" })
	return Alpha
end

Grid2.setupFunc["alpha"] = Create
