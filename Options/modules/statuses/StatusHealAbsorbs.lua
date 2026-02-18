local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("heal-absorbs", "health", function(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	self:MakeStatusHealthFormatOptions(status, options, optionParams)
end, {
	title = L["display remaining amount of heal absorb shields"],
	titleIcon = "Interface\\Icons\\spell_fire_ragnaros_lavabolt",
	colorCount = 1,
})
