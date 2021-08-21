local L = Grid2Options.L

local function MakeOptions(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	options.update = {
		type = "range",
		order = 20,
		name = L["Update rate"],
		desc = L["Rate at which the status gets updated"],
		min = 0.1,
		max = 5,
		step = 0.05,
		bigStep = 0.1,
		get = function () return status.dbx.updateRate or 0.2 end,
		set = function (_, v) status:SetUpdateRate(v) end,
	}
	if Grid2.isClassic then -- only banzai-threat exist in classic
		options.notAlwaysActive = {
			type = "toggle",
			name = L["Enabled only in combat"],
			desc = L["Track banzai threat only when the player is in combat."],
			width = "full",
			order = 30,
			get = function () return not status.dbx.alwaysActive end,
			set = function (_, v)
				local enabled = status.enabled
				if enabled then status:OnDisable() end
				status.dbx.alwaysActive = (not v) or nil
				if enabled then status:OnEnable() end
			end,
		}
	end
end

Grid2Options:RegisterStatusOptions("banzai", "combat", MakeOptions, {
	title = L["hostile casts against raid members"],
	titleIcon = "Interface\\Icons\\Spell_shadow_deathscream"
})

Grid2Options:RegisterStatusOptions("banzai-threat", "combat", MakeOptions, {
	title = L["advanced threat detection"],
	titleIcon = "Interface\\Icons\\Spell_shadow_deathscream"
})
