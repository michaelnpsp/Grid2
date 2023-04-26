local Grid2Options = Grid2Options
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("privateaura", true, function(self, indicator)
	local options = {}
	self:MakeHeaderOptions( options, "General" )
	self:MakeIndicatorPrivateAuraCustomOptions( indicator, options )
	self:MakeIndicatorLevelOptions( indicator, options )
	self:MakeIndicatorLocationOptions(indicator, options)
	self:MakeIndicatorIconSizeOptions(indicator, options)
	self:AddIndicatorOptions(indicator, nil, options, nil, filter)
end)


local indexValues = { 1, 2, 3, 4 }
function Grid2Options:MakeIndicatorPrivateAuraCustomOptions( indicator, options )
	options.auraIndex = {
		type = "select",
		order = 1.91,
		name = L["Aura Index"],
		desc = L["Select which private aura should be displayed."],
		get = function ()
			return indicator.dbx.auraIndex or 1
		end,
		set = function (_, v)
			indicator.dbx.auraIndex = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = indexValues,
	}
	self:MakeHeaderOptions( options, "Cooldown" )
	options.enableCooldown = {
		type = "toggle",
		order = 130,
		name = L["Enable Cooldown"],
		desc = L["Display a Cooldown Frame"],
		get = function () return not indicator.dbx.disableCooldown end,
		set = function (_, v)
			indicator.dbx.disableCooldown = (not v) or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.enableNumbers = { -- "Show numbers for cooldowns" setting must be enabled in blizzard options.
		type = "toggle",
		order = 135,
		name = L["Enable Numbers"],
		desc = L["Display Cooldown Numbers."],
		get = function () return not indicator.dbx.disableCooldownNumbers end,
		set = function (_, v)
			indicator.dbx.disableCooldownNumbers = (not v) or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.disableCooldown end,
	}
end