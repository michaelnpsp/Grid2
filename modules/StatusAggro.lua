local Banzai = LibStub("LibBanzai-2.0", true)
if not Banzai then return end

local select = select
local Aggro = Grid2.statusPrototype:new("aggro")

local cache = {}

local function update(aggro, name, ...)
	for i = 1, select("#", ...) do
		local unitid = select(i, ...)
		cache[unitid] = aggro ~= 0
		Aggro:UpdateIndicators(unitid)
	end
end

function Aggro:OnEnable()
	Banzai:RegisterCallback(update)
end

function Aggro:OnDisable()
	Banzai:UnregisterCallback(update)
end

function Aggro:IsActive(unitid)
	return cache[unitid] and "blink"
end

Aggro.defaultDB = {
	profile = {
		color1 = { r = 1, g = 0, b = 0, a = 1 },
	}
}

function Aggro:GetColor(unitid)
	local color = self.db.profile.color1
	return color.r, color.g, color.b, color.a
end

function Aggro:GetIcon(unitid)
	return [[Interface\RaidFrame\UI-RaidFrame-Threat]]
end

Grid2:RegisterStatus(Aggro, { "color", "icon" })
