if not Grid2.secretsEnabled then return end

-- Heals absorb status, created by Michael
if Grid2.versionCli<50000 or not UnitGetTotalHealAbsorbs then return end -- only MoP or retail

local Shields = Grid2.statusPrototype:new("heal-absorbs")

local Grid2 = Grid2
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs

function Shields:OnEnable()
	self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
end

function Shields:OnDisable()
	self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
end

function Shields:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(_,unit)
	self:UpdateIndicators(unit)
end

function Shields:GetColor(unit) -- TODO color curve
	local c
	local amount = UnitGetTotalHealAbsorbs(unit) or 0
	local dbx = self.dbx
	if amount > dbx.thresholdMedium then
		c = dbx.color1
	elseif amount > dbx.thresholdLow then
		c = dbx.color2
	else
		c = dbx.color3
	end
	return c.r, c.g, c.b, c.a
end

function Shields:GetText(unit)
	return AbbreviateLargeNumbers( UnitGetTotalHealAbsorbs(unit) or 0 )
end

function Shields:GetValueMinMaxCustom(unit)
	return UnitGetTotalHealAbsorbs(unit) or 0, 0, self.maxShieldValue
end

function Shields:GetValueMinMaxHealth(unit)
	return UnitGetTotalHealAbsorbs(unit) or 0, 0, UnitHealthMax(unit)
end

function Shields:IsActive(unit)
	return true
end

function Shields:UpdateDB()
	self.maxShieldValue = self.dbx.maxShieldValue
	self.GetValueMinMax = self.maxShieldValue and self.GetValueMinMaxCustom or self.GetValueMinMaxHealth
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Shields, { "color", "percent", "text" }, baseKey, dbx)
	return Shields
end

Grid2.setupFunc["heal-absorbs"] = Create

Grid2:DbSetStatusDefaultValue( "heal-absorbs", {type = "heal-absorbs", thresholdMedium = 75000, thresholdLow = 25000,  colorCount = 3,
	color1 = {r=1,g=0  ,b=0,a=1},
	color2 = {r=1,g=0.5,b=0,a=1},
	color3 = {r=1,g=1  ,b=0,a=1},
})
