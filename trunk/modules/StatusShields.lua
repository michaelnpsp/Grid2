-- Shields absorb status, created by Michael

local Shields = Grid2.statusPrototype:new("shields")

local Grid2    = Grid2
local select   = select
local next     = next
local min      = math.min
local fmt      = string.format
local select   = select
local UnitAura = UnitAura

local shields     = {}  
local shields_det = setmetatable({}, {__index = function(self,unit) local v= {} self[unit]= v return v end})
local shields_tot = setmetatable({}, {__index = function(self,unit) return 0 end})
local shields_ava = {   
	17 ,   -- Power Word: Shield (Priest)
	47509, -- Divine Aegis (Priest)
	76669, -- Illuminated Healing (Paladin)
	85285, -- Sacred Shield (Paladin)
	62600, -- Savage Defense (Druid)
	11426, -- Ice Barrier (Mage)
	1463,  -- Mana Shield (Mage)
	-- 7812,  -- Sacrifice (Warlock)
}

function Shields:ApplyShield(unit,spellName, amount)
	if amount and amount>0 then
		local old = shields_det[unit][spellName] or 0
		shields_det[unit][spellName] = amount
		shields_tot[unit]            = shields_tot[unit] + amount - old
		self:UpdateIndicators(unit)
	end
end

function Shields:RemoveShield(unit,spellName)
	local amount = shields_det[unit][spellName]
	if amount and amount>0 then
		shields_det[unit][spellName] = nil
		shields_tot[unit]            = shields_tot[unit] - amount
		self:UpdateIndicators(unit)
	end	
end

function Shields:UpdateShields(unit)
	for spellName in next, shields_det[unit] do
		local amount = select(14, UnitAura(unit, spellName))
		if amount then
			if amount>0 then
				self:ApplyShield(unit,spellName,amount)
			else
				self:RemoveShield(unit,spellName)
			end
		end
	end
end

local Actions= {
	SPELL_AURA_APPLIED      = Shields.ApplyShield,
	SPELL_AURA_REFRESH      = Shields.ApplyShield,
	SPELL_AURA_REMOVED      = Shields.RemoveShield,
	SPELL_AURA_BROKEN       = Shields.RemoveShield,
	SPELL_AURA_BROKEN_SPELL = Shields.RemoveShield,
	SWING_MISSED            = true,
	RANGE_MISSED            = true,
	SPELL_MISSED            = true,
	SPELL_PERIODIC_MISSED   = true,
	ENVIRONMENTAL_MISSED    = true,
}

function Shields:COMBAT_LOG_EVENT_UNFILTERED(...)
	local action = Actions[select(3,...)]
	if action then 
		if action==true then
			local unit= Grid2:GetUnitidByGUID( select(9,...) )
			if unit then Shields:UpdateShields(unit) end	
		else
			local shieldName = select(14,...)
			if shields[shieldName] then
				local unit= Grid2:GetUnitidByGUID( select(9,...) )
				if unit then action( self, unit, shieldName, select(17,...) ) end -- amount
			end	
		end	
	end	
end

function Shields:OnEnable()
	self:UpdateDB()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Shields:OnDisable()
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function Shields:IsActive(unit)
	local amount= shields_tot[unit]
	return amount and amount>0
end

function Shields:GetPercent(unit)
	return min( shields_tot[unit] / self.maxShieldAmount, 1)
end

function Shields:GetColor(unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

function Shields:GetText(unit)
	return fmt("%.1fk", shields_tot[unit] / 1000 )
end

function Shields:UpdateDB()
	wipe(shields)
	self.maxShieldAmount= self.dbx.maxShieldAmount or 30000
	local filtered = self.dbx.filtered
	for _,spellId in pairs(shields_ava) do
		if (not filtered) or (not filtered[spellId]) then
			shields[ GetSpellInfo(spellId) ] = true
		end	
	end
end

function Shields:GetAvailableShields()
	return shields_ava
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Shields, { "color", "percent", "text" }, baseKey, dbx)

	return Shields
end

Grid2.setupFunc["shields"] = Create
