-- Auras
for name, data in pairs(Grid2.db.profile.setup.buffs) do
	Grid2Options:AddAura("Buff", name, unpack(data))
end
for name, data in pairs(Grid2.db.profile.setup.debuffs) do
	Grid2Options:AddAura("Debuff", name, unpack(data))
end
