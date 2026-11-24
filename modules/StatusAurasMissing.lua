-- Missing buff status
local Grid2 = Grid2
local pairs = pairs
local C_Timer_After = C_Timer.After
local ShouldAurasBeSecret = C_Secrets.ShouldAurasBeSecret
local UnitIsPlayer = UnitIsPlayer
local UnitCanAttack = UnitCanAttack
local GetSpellTexture = C_Spell.GetSpellTexture
local GetUnitAuraBySpellID = C_UnitAuras.GetUnitAuraBySpellID
local GetAuraDataBySpellName = C_UnitAuras.GetAuraDataBySpellName

--
local status = { GetColor = Grid2.statusLibrary.GetColor }

local function GetFilterFunc(dbx)
	if dbx.onlyFriendly and dbx.onlyPlayers then
		return function(unit, spell, func) return not UnitIsPlayer(unit) or UnitCanAttack("player", unit) or func(unit, spell, 'HELPFUL')~=nil; end
	elseif dbx.onlyFriendly then
		return function(unit, spell, func) return UnitCanAttack("player", unit) or func(unit, spell, 'HELPFUL')~=nil; end
	elseif dbx.onlyPlayers then
		return function(unit, spell, func) return not UnitIsPlayer(unit) or func(unit, spell, 'HELPFUL')~=nil; end
	else
		return function(unit, spell, func) return func(unit, spell, 'HELPFUL')~=nil end
	end
end

function status:UpdateUnitCache(unit, update)
	local new_cache
	if not self.secrets_enabled then
		local filterFunc = self.filterFunc
		new_cache = true
		for spell, func in pairs(self.spells) do
			if filterFunc(unit, spell, func) then
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
	local secrets_enabled = self.empty or ShouldAurasBeSecret()
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

function status:PLAYER_TALENT_UPDATE()
	self:UpdateDB()
	self:UpdateRestrictions(true)
end

function status:OnEnable()
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
	if self.dbx.ignoreUnknownSpells then
		self:RegisterEvent("PLAYER_TALENT_UPDATE")
	end
	self:UpdateRestrictions()
end

function status:OnDisable()
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
	if self.dbx.ignoreUnknownSpells then
		self:UnregisterEvent("PLAYER_TALENT_UPDATE")
	end
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
	local IsSpellInSpellBook = self.dbx.ignoreUnknownSpells and C_SpellBook.IsSpellInSpellBook or Grid2.statusLibrary.IsActive
	local spells, texture = {}, self.dbx.texture
	for _, spell in ipairs(self.dbx.auras) do
		if type(spell)~='number' then
			spells[spell] = GetAuraDataBySpellName
		elseif IsSpellInSpellBook(spell, Enum.SpellBookSpellBank.Player, true) then
			texture = texture or GetSpellTexture(spell)
			spells[spell] = GetUnitAuraBySpellID
		end
	end
	self.filterFunc = GetFilterFunc(self.dbx)
	self.empty = not next(spells)
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
