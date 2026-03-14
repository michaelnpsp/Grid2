local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("buffs", "buff", function(self, status, options, optionParams)
	self:MakeStatusAuraColorsOptions(status, options, optionParams)
	self:MakeStatusAuraMissingOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeHeaderOptions( options, "AurasExpanded" )
	self:MakeStatusAuraListOptions(status, options, optionParams)
end,{
	groupOrder = 20, isDeletable = true,
	titleIcon = "Interface\\Icons\\Inv_enchant_shardbrilliantsmall",
})
