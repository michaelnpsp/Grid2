if Grid2.secretsEnabled then return end

-- Heals absorb status, created by Michael
if Grid2.versionCli<50000 or not UnitGetTotalHealAbsorbs then return end -- only MoP or retail

local Shields = Grid2.statusPrototype:new("heal-absorbs")

local Grid2 = Grid2
local min   = math.min
local fmt   = string.format
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitHealthMax = UnitHealthMax

function Shields:OnEnable()
	self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
end

function Shields:OnDisable()
	self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
end

function Shields:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(_,unit)
	self:UpdateIndicators(unit)
end

function Shields:GetColor(unit)
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

-- Using a user defined max shield value (used by bar indicators)
local function GetPercentCustomMax(self, unit)
	return (UnitGetTotalHealAbsorbs(unit) or 0) / self.maxShieldValue
end
-- Use unit maximum health as max shield value (used by bar indicators)
local function GetPercentHealthMax(_, unit)
	local m = UnitHealthMax(unit)
	return m>0 and (UnitGetTotalHealAbsorbs(unit) or 0) / m or 0
end

function Shields:GetText(unit)
	return fmt("%.1fk", (UnitGetTotalHealAbsorbs(unit) or 0) / 1000 )
end

function Shields:IsActive(unit)
	return (UnitGetTotalHealAbsorbs(unit) or 0)>0
end

function Shields:UpdateDB()
	self.maxShieldValue = self.dbx.maxShieldValue
	self.GetPercent = self.maxShieldValue and GetPercentCustomMax or GetPercentHealthMax
	self:SetAutoDebuffsFilter(self.dbx.ignoreAutoAbsorbs)
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

-- special case to filter paladin martyr absorbs auto debuff in retail, replacing UnitGetTotalHealAbsorbs()
-- function with a custom function that substracts Light of the Martyr debuff absorb amount and caching the results.
do
	local UnitGetTotalHealAbsorbsOriginal = UnitGetTotalHealAbsorbs
	local GetAuraDataBySpellName = C_UnitAuras.GetAuraDataBySpellName
	local UnitClass = UnitClass
	local MARTYR_SPELL = Grid2.API.GetSpellInfo(448005)
	local filter_enabled, orig_OnEnable, orig_OnDisable = false, nil, nil
	local paladin_cache = setmetatable( {}, { __index = function(t,u)
		t[u] = (select(3,UnitClass(u))==2)
		return t[u]
	end } )
	local shield_cache = setmetatable( {}, { __index = function(t,u)
		local v = UnitGetTotalHealAbsorbsOriginal(u)
		if paladin_cache[u] then
			local data = GetAuraDataBySpellName(u, MARTYR_SPELL, 'HARMFUL')
			v = v - (data and data.points[1] or 0)
		end
		t[u] = v
		return v
	end } )
	local function UnitGetTotalHealAbsorbsOverride(unit)
		return shield_cache[unit]
	end
	local function ResetShield(_,unit)
		paladin_cache[unit] = nil
		shield_cache[unit] = nil
	end
	local function UpdateShield(_,unit)
		shield_cache[unit] = nil
		Shields:UpdateIndicators(unit)
	end
	local function Shields_OnEnable(self)
		self:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", UpdateShield)
		self:RegisterMessage("Grid_UnitUpdated", ResetShield)
	end
	local function Shields_OnDisable(self)
		self:UnregisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
		self:UnregisterMessage("Grid_UnitUpdated")
		wipe(paladin_cache)
		wipe(shield_cache)
	end
	function Shields:SetAutoDebuffsFilter(enabled)
		enabled = not not enabled
		if filter_enabled~=enabled then
			filter_enabled = enabled
			orig_OnEnable =  orig_OnEnable or self.OnEnable
			orig_OnDisable = orig_OnDisable or self.OnDisable
			self.OnEnable =  enabled and Shields_OnEnable or orig_OnEnable
			self.OnDisable = enabled and Shields_OnDisable or orig_OnDisable
			UnitGetTotalHealAbsorbs = enabled and UnitGetTotalHealAbsorbsOverride or UnitGetTotalHealAbsorbsOriginal
		end
	end
end
