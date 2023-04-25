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
	options.disableCooldown = {
		type = "toggle",
		order = 130,
		name = L["Disable Cooldown"],
		desc = L["Disable the Cooldown Frame"],
		tristate = false,
		get = function () return indicator.dbx.disableCooldown end,
		set = function (_, v)
			indicator.dbx.disableCooldown = v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end