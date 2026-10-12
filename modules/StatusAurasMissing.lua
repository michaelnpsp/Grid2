-- Missing buff status
local Grid2 = Grid2
local pairs = pairs
local C_Timer_After = C_Timer.After
local ShouldAurasBeSecret = C_Secrets.ShouldAurasBeSecret
local GetSpellTexture = C_Spell.GetSpellTexture
local GetUnitAuraBySpellID = C_UnitAuras.GetUnitAuraBySpellID
local GetAuraDataBySpellName = C_UnitAuras.GetAuraDataBySpellName

--
local status = { GetColor = Grid2.statusLibrary.GetColor }

function status:UpdateUnitCache(unit, update)
	local new_cache
	if not self.secrets_enabled then
		new_cache = true
		for spell, func in pairs(self.spells) do
			if func(unit, spell, 'HELPFUL')~=nil then
				new_cache = nil
				break
			end
		end
	end
	if new_cache ~= self.cache[unit] then
		self.cache[unit] = new_cache
		if update then self:UpdateIndicators(unit) end
	end
end

function status:UpdateRestrictions(update)
	local secrets_enabled = ShouldAurasBeSecret()
	if self.secrets_enabled ~= secrets_enabled then
		self.secrets_enabled = secrets_enabled
		if secrets_enabled then
			self:UnregisterRosterUnitEvent("UNIT_AURA")
		else
			self:RegisterRosterUnitEvent("UNIT_AURA")
		end
		for unit in Grid2:IterateRosterUnits() do
			self:UpdateUnitCache(unit, update)
		end
	end
end

function status:Grid_UnitUpdated(_, unit)
	self:UpdateUnitCache(unit)
end

function status:UNIT_AURA(_, unit)
	self:UpdateUnitCache(unit, true)
end

function status:ADDON_RESTRICTION_STATE_CHANGED(event, typ, state)
	C_Timer_After(0, function() self:UpdateRestrictions(true) end)
end

function status:OnEnable()
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
	self:ADDON_RESTRICTION_STATE_CHANGED()
	self:UpdateRestrictions()
end

function status:OnDisable()
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
	self.secrets_enabled = nil
	wipe(self.cache)
end

function status:IsActive(unit)
	return self.cache[unit]~=nil
end

function status:GetIcon()
	return self.texture
end

function status:UpdateDB()
	local spells, texture = {}
	for _, spell in ipairs(self.dbx.auras) do
		if type(spell)=='number' then
			texture = texture or GetSpellTexture(spell)
			spells[spell] = GetUnitAuraBySpellID
		else
			spells[spell] = GetAuraDataBySpellName
		end
	end
	self.spells = spells
	self.texture = texture or "Interface\\ICONS\\Achievement_General"
end

Grid2.setupFunc["mbuff-missing"] = function(baseKey, dbx)
	local missing = Grid2.statusPrototype:new(baseKey)
	missing.cache = {}
	missing:Inject(status)
	Grid2:RegisterStatus(missing, { "icons", "icon",  "color" }, baseKey, dbx)
	return missing
end

--[[ status database configuration
	type = "mbuff-missing"
	auras = { 12323, "Earth Shield", ... }
--]]
