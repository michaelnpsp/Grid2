local Banzai = LibStub("LibBanzai-2.0", true)
if not Banzai then return end

local select = select
local Aggro = Grid2.statusPrototype:new("aggro")

local cache = {}

local function update(aggro, name, ...)
	for i = 1, select("#", ...) do
		local unit = select(i, ...)
		cache[unit] = aggro ~= 0
		Aggro:UpdateIndicators(unit)
	end
end

function Aggro:OnEnable()
	Banzai:RegisterCallback(update)
end

function Aggro:OnDisable()
	Banzai:UnregisterCallback(update)
end

function Aggro:IsActive(unit)
	return cache[unit] and "blink"
end

Aggro.defaultDB = {
	profile = {
		color = { r = 1, g = 0, b = 0, a = 1 },
	}
}

function Aggro:GetColor(unit)
	local color = self.db.profile.color
	return color.r, color.g, color.b, color.a
end

Grid2:RegisterStatus(Aggro, { "color" })
