if Grid2.isClassic then return end

-- Stagger monk status, created by Michael
local Stagger = Grid2.statusPrototype:new("monk-stagger")

local Grid2 = Grid2
local fmt   = string.format
local UnitClass = UnitClass
local UnitStagger = UnitStagger
local UnitHealthMax = UnitHealthMax

function Stagger:OnEnable()
	self:RegisterEvent("UNIT_POWER_UPDATE")
end

function Stagger:OnDisable()
	self:UnregisterEvent("UNIT_POWER_UPDATE")
end

function Stagger:UNIT_POWER_UPDATE(_,unit)
	local _,class = UnitClass(unit)
	if class == 'MONK' then
		self:UpdateIndicators(unit)
	end
end

function Stagger:GetColor(unit)
	local dbx, c = self.dbx
	local percent = self:GetPercent(unit)
	if percent >= 0.6 then
		c = dbx.color1
	elseif percent >= 0.3 then
		c = dbx.color2
	else
		c = dbx.color3
	end
	return c.r, c.g, c.b, c.a
end

function Stagger:GetText(unit)
	return fmt("%.1fk", (UnitStagger(unit) or 0) / 1000 )
end

function Stagger:GetPercent(unit)
	local m = UnitHealthMax(unit)
	return m>0 and (UnitStagger(unit) or 0) / m  or 0
end

function Stagger:IsActive(unit)
	return (UnitStagger(unit) or 0)>0
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Stagger, { "color", "percent", "text" }, baseKey, dbx)
	return Stagger
end

Grid2.setupFunc["monk-stagger"] = Create

Grid2:DbSetStatusDefaultValue( "monk-stagger", { type = "monk-stagger", colorCount = 3,
	color1 = { r = 1, g = 0, b = 0, a=1 },
	color2 = { r = 1, g = 1, b = 0, a=1 },
	color3 = { r = 0, g = 1, b = 0, a=1 },
} )

