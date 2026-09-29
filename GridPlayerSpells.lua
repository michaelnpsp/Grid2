-- Players Buffs & Debuffs, used by GridDefaults.lua and StatusAuraNewPredictor.lua

local GetSpellName = C_Spell.GetSpellName

Grid2.PlayerBuffsReverse = {}

Grid2.PlayerDebuffs = {
	[""] = {},
	["DEATHKNIGHT"] = {},
	["DRUID"] = {},
	["HUNTER"] = {},
	["MAGE"] = {},
	["MONK"] = {},
	["PALADIN"] = {},
	["PRIEST"] = {},
	["ROGUE"] = {},
	["SHAMAN"] = {},
	["WARLOCK"] = {},
	["WARRIOR"] = {},
	["DEMONHUNTER"] = {},
	["EVOKER"] = {},
	["MYTHIC+"] = {},
}

function Grid2:GetSimilarPlayerBuffs(spell)
	local list = self.PlayerBuffsReverse
	for category, spells in pairs(self.PlayerBuffs) do
		for i,spellID in ipairs(spells) do
			local spellName = GetSpellName(spellID)
			if spellName then
				local t =  list[spellName]
				if t==nil then t = {}; list[spellName] = t; end
				t[#t+1] = spellID
			else
				print("Invalid spell", spellID)
			end
		end
	end
	self.GetSimilarPlayerBuffs = function(self,spell)
		local spellName = type(spell)=='number' and GetSpellName(spell) or spell
		return self.PlayerBuffsReverse[spellName]
	end
	return self:GetSimilarPlayerBuffs(spell)
end
