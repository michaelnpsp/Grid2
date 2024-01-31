local L = Grid2Options.L

function Grid2Options:MakeStatusBuffsStrictOptions(status, options, optionParams)
	options.strictFilter = {
		type = "toggle",
		name = L["Show when all buffs are active"],
		desc = L["Display the status only when all buffs are active."],
		width = 1.5,
		order = 4.7,
		get = function () return status.dbx.strictFilter end,
		set = function (_, v)
			status.dbx.strictFilter = v or nil
			status:Refresh()
		end,
		hidden = function() return status.dbx.missing end,
	}
	return options
end

Grid2Options:RegisterStatusOptions("buffs", "buff", function(self, status, options, optionParams)
	if status.dbx.subType == 'blizzard' then
		self:MakeStatusColorOptions(status, options, optionParams)
	else
		self:MakeStatusBuffsStrictOptions(status, options, optionParams)
		self:MakeStatusAuraColorsOptions(status, options, optionParams)
		self:MakeStatusAuraMissingOptions(status, options, optionParams)
		self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
		self:MakeHeaderOptions( options, "AurasExpanded" )
		self:MakeStatusAuraListOptions(status, options, optionParams)
	end
end,{
	groupOrder = 20, isDeletable = true,
	titleIcon = "Interface\\Icons\\Inv_enchant_shardbrilliantsmall",
})
