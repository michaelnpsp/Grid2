-- Shields absorb status, created by Michael

local Shields = Grid2.statusPrototype:new("shields")

local Grid2    = Grid2
local select   = select
local next     = next
local min      = math.min
local fmt      = string.format
local UnitAura = UnitAura

local shields_ava = {   
	17 ,   -- Power Word: Shield (Priest)
	47515, -- Divine Aegis (Priest)
	114908, -- Spirit Shell (Priest)
	76669, -- Illuminated Healing (Paladin)
	65148, -- Sacred Shield (Paladin)
	77513, -- Blood shield (DK)
	11426, -- Ice Barrier (Mage)
	1463,  -- Mana Shield (Mage)
}

local shields     = {}  
local shields_det = setmetatable({}, {__index = function(self,unit) local v= {} self[unit]= v return v end})
local shields_tot = setmetatable({}, {__index = function(self,unit) return 0 end})

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
				if unit then 
					local amount = select(17,...) or select(14, UnitAura(unit, shieldName))
					action( self, unit, shieldName, amount ) 
				end 
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

function Shields:GetPercent(unit)
	return min( shields_tot[unit] / self.maxShieldAmount, 1)
end

function Shields:GetColor(unit)
	local c
	local amount = shields_tot[unit]
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
	return fmt("%.1fk", shields_tot[unit] / 1000 )
end

function Shields:IsActiveNormal(unit)
	return shields_tot[unit]>0
end

function Shields:IsActiveBLink(unit)
	local amount = shields_tot[unit]
	if amount>0 then
		if amount>self.blinkThreshold then
			return true
		else	
			return "blink"
		end	
	end
end

function Shields:UpdateDB()
	local dbx= self.dbx
	wipe(shields)
	self.maxShieldAmount = dbx.maxShieldAmount
	self.blinkThreshold  = dbx.blinkThreshold
	self.IsActive        = self.blinkThreshold and Shields.IsActiveBLink or Shields.IsActiveNormal
	local filtered = dbx.filtered
	for _,spellId in pairs(shields_ava) do
		if (not filtered) or (not filtered[spellId]) then
			local spell = GetSpellInfo(spellId)
			if spell then 
				shields[ spell ] = true 
			end	
		end	
	end
	if dbx.customShields then
		local customShields = { strsplit(",", dbx.customShields) }
		for i=1,#customShields do
			shields[ customShields[i] ] = true
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

Grid2:DbSetStatusDefaultValue( "shields", { type = "shields", maxShieldAmount = 50000, thresholdMedium = 15000, thresholdLow = 6000,  colorCount = 3,
	color1 = { r = 0, g = 1,   b = 0, a=1 },    
	color2 = { r = 1, g = 0.5, b = 0, a=1 },
	color3 = { r = 1, g = 1,   b = 0, a=1 },
} ) 
