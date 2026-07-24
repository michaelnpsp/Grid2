
local L = Grid2Options.L

local DISPLAY_VALUES = { [1] = L["Never"], [2] = L["Always"], [3] = L["In Combat"], [4] = L["Out of Combat"] }

Grid2Options:RegisterIndicatorOptions("tooltip", false, function(self, indicator)
	local options = {}
	options.unittooltip = { type = "header", order = 1, name = L["Unit Tooltips"] }
	options.tooltip = {
			type = "select",
			order = 10,
			name = L["Show Tooltip"],
			desc = L["Show tooltip when mouseover a unit."],
			get = function ()
				return indicator.dbx.showTooltip or 4
			end,
			set = function (_, v)
				indicator.dbx.showTooltip = v
				if not indicator.suspended then	indicator:UpdateDB() end
			end,
			values= DISPLAY_VALUES,
	}
	options.anchor = {
		type = "select",
		name = L["Tooltip Anchor"],
		desc = L["Sets where Tooltip is anchored relative to Grid2 window or select the game default anchor."],
		order = 20,
		get = function () return indicator.dbx.tooltipAnchor or 'ANCHOR_ABSENT' end,
		set = function (_, v)
				indicator.dbx.tooltipAnchor = v ~= 'ANCHOR_ABSENT' and v or nil
				if not indicator.suspended then indicator:UpdateDB() end
			  end,
		values = Grid2Options.tooltipAnchorValues,
	}
	self:AddIndicatorOptions(indicator, nil, options)
end)
