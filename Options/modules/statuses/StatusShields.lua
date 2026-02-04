local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("shields-overflow", "health", nil, {
	title = L["display damage absorb shields above max hp"],
	titleIcon = "Interface\\ICONS\\Spell_Holy_PowerWordShield"
})

Grid2Options:RegisterStatusOptions("shields", "health", nil, {
	title = L["display remaining amount of damage absorb shields"],
	titleIcon = "Interface\\ICONS\\Spell_Holy_PowerWordShield",
	colorCount = 1,
})
