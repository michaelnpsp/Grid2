local Alpha = Grid2.indicatorPrototype:new("alpha")

local EvaluateColorValueFromBoolean = C_CurveUtil.EvaluateColorValueFromBoolean

local indicatorName
local defaultAlpha = 1
local enabledAlpha = 0.5

Alpha.Create = Grid2.Dummy
Alpha.Layout = Grid2.Dummy

-- standard update, opacity value is provided by the active status
local function Alpha_UpdateStandard(self, parent, unit)
	if unit then
		local alpha, statuses = 1, self.statuses
		for i=#statuses,1,-1 do
			local status = statuses[i]
			local state, invert = status:IsActive(unit)
			if invert then
				alpha = EvaluateColorValueFromBoolean(state, defaultAlpha, status:GetPercent() or enabledAlpha)
			else
				alpha = EvaluateColorValueFromBoolean(state, status:GetPercent() or enabledAlpha, defaultAlpha)
			end
		end
		(indicatorName and parent[indicatorName] or parent):SetAlpha(alpha)
	end
end

-- optional update, alpha provided by the statuses is ignored and instead the opacity defined in the indicator setup is used
local function Alpha_UpdateOptional(self, parent, unit)
	if unit then
		local alpha, statuses = 1, self.statuses
		for i=#statuses,1,-1 do
			local state, invert = statuses[i]:IsActive(unit)
			if invert then
				alpha = EvaluateColorValueFromBoolean(state, defaultAlpha, enabledAlpha )
			else
				alpha = EvaluateColorValueFromBoolean(state, enabledAlpha, defaultAlpha )
			end
		end
		(indicatorName and parent[indicatorName] or parent):SetAlpha(alpha)
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
	indicatorName = indicatorName and Grid2.indicators[indicatorName] and indicatorName
	self.UpdateO = enabledAlpha and Alpha_UpdateOptional or Alpha_UpdateStandard
end

local function Create(indicatorKey, dbx)
	Alpha.dbx = dbx
	Grid2:RegisterIndicator(Alpha, { "percent" })
	return Alpha
end

Grid2.setupFunc["alpha"] = Create
