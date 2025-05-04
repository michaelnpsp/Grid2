local L = Grid2Options.L

local MAX_ABSORB = Grid2.isClassic and 200000 or 5000000

Grid2Options:RegisterStatusOptions("shields-overflow", "health", nil, {
	title = L["display damage absorb shields above max hp"],
	titleIcon = "Interface\\ICONS\\Spell_Holy_PowerWordShield"
})

Grid2Options:RegisterStatusOptions("shields", "health", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, {
		color1 = L["Normal"], colorDesc1 = L["Normal shield color"],
		color2 = L["Medium"], colorDesc2 = L["Medium shield color"],
		color3 = L["Low"],    colorDesc3 = L["Low shield color"],
	})
	self:MakeSpacerOptions(options, 30)
	options.maxShieldAmount = {
		type = "range",
		order = 31,
		width = "full",
		name = L["Maximum shield amount"],
		desc = L["Value used by bar indicators. Select zero to use players Maximum Health."],
		min = 0,
		softMax = MAX_ABSORB,
		bigStep = 1000,
		step = 1,
		get = function () return status.dbx.maxShieldValue or 0 end,
		set = function (_, v)
			status.dbx.maxShieldValue = v>0 and v or nil
			status:UpdateDB()
		end,
	}
	options.thresholdMedium = {
		type = "range",
		order = 32,
		width = "full",
		name = L["Medium shield threshold"],
		desc = L["The value below which a shield is considered medium."],
		min = 0,
		softMax = MAX_ABSORB,
		bigStep = 1000,
		step = 1,
		get = function () return status.dbx.thresholdMedium end,
		set = function (_, v)
			   if status.dbx.thresholdLow > v then v = status.dbx.thresholdLow end
			   status.dbx.thresholdMedium = v
			   status:UpdateDB()
		end,
	}
	options.thresholdLow = {
		type = "range",
		order = 33,
		width = "full",
		name = L["Low shield threshold"],
		desc = L["The value below which a shield is considered low."],
		min = 0,
		softMax = MAX_ABSORB,
		bigStep = 1000,
		step = 1,
		get = function () return status.dbx.thresholdLow end,
		set = function (_, v)
			   if status.dbx.thresholdMedium < v then v = status.dbx.thresholdMedium end
			   status.dbx.thresholdLow = v
			   status:UpdateDB()
		end,
	}
	options.blinkThreshold = {
		type = "range",
		order = 35,
		width = "full",
		name = L["Highlight"],
		desc = L["Threshold at which to highlight the status."],
		min = 0,
		softMax = MAX_ABSORB,
		bigStep = 100,
		step = 1,
		get = function () return status.dbx.blinkThreshold or 0	end,
		set = function (_, v)
			if v == 0 then v = nil end
			status.dbx.blinkThreshold = v
			status:UpdateDB()
		end,
	}
end, {
	title = L["display remaining amount of damage absorb shields"],
	titleIcon = "Interface\\ICONS\\Spell_Holy_PowerWordShield"
} )
