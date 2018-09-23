
local L = Grid2Options.L

local DISPLAY_VALUES = { [1] = L["Never"], [2] = L["Always"], [3] = L["In Combat"], [4] = L["Out of Combat"] }
local ANCHOR_VALUES  = { ['@'] = L["Default"], ANCHOR_TOP = L["TOP"], ANCHOR_BOTTOM = L["BOTTOM"], ANCHOR_LEFT = L["LEFT"], ANCHOR_RIGHT = L["RIGHT"], ANCHOR_TOPLEFT = L["TOPLEFT"], ANCHOR_TOPRIGHT = L["TOPRIGHT"], ANCHOR_BOTTOMLEFT = L["BOTTOMLEFT"], ANCHOR_BOTTOMRIGHT = L["BOTTOMRIGHT"] },

Grid2Options:RegisterIndicatorOptions("tooltip", false, function(self, indicator)
	local layout, statuses = {}, {}
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:MakeIndicatorTooltipOptions(indicator,layout)
	self:AddIndicatorOptions(indicator, statuses, layout )
end)

function Grid2Options:MakeIndicatorTooltipOptions(indicator,options)
	options.tooltip = {
			type = "select",
			order = 10,
			name = L["Show statuses in Tooltip"],
			desc = L["Show selected statuses information in tooltip when mouseover a unit."],
			get = function ()
				return indicator.dbx.showTooltip or 1
			end,
			set = function (_, v)
				indicator.dbx.showTooltip = v
				indicator:UpdateDB()
			end,
			values= DISPLAY_VALUES,
	}
	options.anchor = {
		type = "select",
		name = L["Tooltip Anchor"],
		desc = L["Sets where Tooltip is anchored relative to Grid2 window or select the game default anchor."],
		order = 20,
		get = function () return indicator.dbx.tooltipAnchor or "@" end,
		set = function (_, v)
				indicator.dbx.tooltipAnchor = v ~= '@' and v or nil
				indicator:UpdateDB()
			  end,
		values = ANCHOR_VALUES,
	}
	options.displayUnit = {
		type = "toggle",
		width= "full",
		name = L["Always display unit tooltip information when Out of Combat"],
		desc = L["This option takes priority over any other tooltip configuration."],
		order = 30,
		get = function() return indicator.dbx.displayUnitOOC end,
		set = function(_,v)
			indicator.dbx.displayUnitOOC = v or nil
			indicator:UpdateDB()
		end,
	}
end


