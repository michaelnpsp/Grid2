local L = Grid2Options.L

if Grid2.isMidnight then
	Grid2Options:RegisterStatusOptions("heal-absorbs", "health", nil, {
		title = L["display remaining amount of heal absorb shields"],
		titleIcon = "Interface\\Icons\\spell_fire_ragnaros_lavabolt",
		colorCount = 1,
	})
	return
end

local MAX_ABSORB = Grid2.isClassic and 200000 or 5000000

Grid2Options:RegisterStatusOptions("heal-absorbs", "health", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams )
	self:MakeSpacerOptions(options, 30)
	options.maxShieldAmount = {
		type = "range",
		order = 31,
		width = "full",
		name = L["Maximum absorb amount"],
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
		name = L["Medium absorb threshold"],
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
		name = L["Low absorb threshold"],
		desc = L["The value below which a shield is considered low."],
		min = 0,
		softMax = MAX_ABSORB,
		bigStep = 100,
		step = 1,
		get = function () return status.dbx.thresholdLow end,
		set = function (_, v)
			   if status.dbx.thresholdMedium < v then v = status.dbx.thresholdMedium end
			   status.dbx.thresholdLow = v
			   status:UpdateDB()
		end,
	}
	if Grid2.isWoW90 then
		self:MakeSpacerOptions(options, 40)
		options.filterMartyr = {
			type = "toggle",
			order = 41,
			width = "full",
			name = L["Ignore Light of the Martyr debuff"],
			desc = L["Does not show the absorb amount for the Light of the Martyr paladins debuff."],
			get = function () return status.dbx.ignoreAutoAbsorbs end,
			set = function (_, v)
				status.dbx.ignoreAutoAbsorbs = v or nil
				status:Refresh()
			end
		}
	end
end, {
	color1 = L["Normal"],
	colorDesc1 = L["Normal heal absorbs color"],
	color2 = L["Medium"],
	colorDesc2 = L["Medium heal absorbs color"],
	color3 = L["Low"],
	colorDesc3 = L["Low heal absorbs color"],
	title = L["display remaining amount of heal absorb shields"],
	titleIcon = "Interface\\Icons\\spell_fire_ragnaros_lavabolt",
})
