local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Alpha = Grid2.indicatorPrototype:new("alpha")

function Alpha:Create(parent)
end

function Alpha:Layout(parent)
end

function Alpha:OnUpdate(parent, unit, status)
	parent:SetAlpha(status and status:GetPercent(unit) or 1)
end

Grid2:RegisterIndicator(Alpha, { "percent" })
