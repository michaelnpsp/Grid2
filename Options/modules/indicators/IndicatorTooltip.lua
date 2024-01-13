
local L = Grid2Options.L

local DISPLAY_VALUES = { [1] = L["Never"], [2] = L["Always"], [3] = L["In Combat"], [4] = L["Out of Combat"] }

local function AdvancedTooltipsEnabled(indicator)
	return not indicator.dbx.showDefault or #indicator.statuses>0
end

Grid2Options:RegisterIndicatorOptions("tooltip", false, function(self, indicator)
	if indicator.dbx.showTooltip~=1 and AdvancedTooltipsEnabled(indicator) then
		local layout, statuses = {}, {}
		self:MakeIndicatorStatusOptions(indicator, statuses)
		self:MakeIndicatorUnitTooltipOptions(indicator,layout)
		self:MakeIndicatorIconTooltipOptions(indicator,layout)
		self:AddIndicatorOptions(indicator, statuses, layout )
	else
		local layout = {}
		self:MakeIndicatorUnitTooltipOptions(indicator,layout)
		self:MakeIndicatorIconTooltipOptions(indicator,layout)
		self:AddIndicatorOptions(indicator, nil, layout )
	end
end)

function Grid2Options:MakeIndicatorUnitTooltipOptions(indicator, options)
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
				local refresh = (v==1 or indicator.dbx.showTooltip==1) and AdvancedTooltipsEnabled(indicator)
				indicator.dbx.displayUnitOOC = nil
				indicator.dbx.showTooltip = v
				if not indicator.suspended then	indicator:UpdateDB() end
				if refresh then	Grid2Options:MakeIndicatorOptions(indicator) end
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
				if not indicator.suspended then	indicator:UpdateDB() end
			  end,
		values = Grid2Options.tooltipAnchorValues,
	}
	options.advanced = {
		type = "toggle",
		width= "full",
		name = "|cffffd200".. L["Enable Advanced Tooltips"] .."|r",
		desc = L["Enable this option to be able to customize the tooltip. Once enabled you can go to the 'statuses' tab to select which information you want to display."],
		order = 30,
		get = function() return AdvancedTooltipsEnabled(indicator) end,
		set = function(_,v)
			indicator.dbx.showDefault = not v
			if indicator.dbx.showDefault then -- Default unit tooltips
				while #indicator.statuses>0 do -- unregister all statuses
					Grid2:DbSetMap(indicator.name, indicator.statuses[1].name, nil)
					indicator:UnregisterStatus(indicator.statuses[1])
				end
				indicator.dbx.displayUnitOOC = nil
			else -- Advanced tooltips
				Grid2:DbSetMap(indicator.name, "name", 50) -- register "name" status
				indicator:RegisterStatus(Grid2:GetStatusByName("name"), 50)
			end
			if not indicator.suspended then	indicator:UpdateDB() end
			Grid2Options:MakeIndicatorOptions(indicator)
		end,
		confirm = function() return AdvancedTooltipsEnabled(indicator) and L["Are you sure you want to disable the advanced tooltips?"] end,
		hidden = function() return indicator.dbx.showTooltip==1 end,
	}
	options.advancedOOC = {
		type = "toggle",
		width= "full",
		name = L["Display default unit tooltip when Out of Combat"],
		desc = L["Enable this option to display the default unit tooltip when Out of Combat."],
		order = 35,
		get = function() return indicator.dbx.displayUnitOOC end,
		set = function(_,v)
			indicator.dbx.displayUnitOOC = v or nil
			if not indicator.suspended then	indicator:UpdateDB() end
		end,
		hidden = function() return not AdvancedTooltipsEnabled(indicator) or indicator.dbx.showTooltip ~= 3 end,
	}
end

-- Grid2Options:MakeIndicatorIconTooltipOptions()
do
	local indicators = {}
	function Grid2Options:MakeIndicatorIconTooltipOptions(indicator, options)
		options.__display = { type = "header", order = 0, name = "", hidden = function()
			wipe(indicators)
			for _,indicator in next, Grid2.indicatorTypes.icon do
				indicators[#indicators+1] = indicator
			end
			table.sort( indicators, function(a,b) if a.dbx.type==b.dbx.type then return a.name<b.name else return a.dbx.type>b.dbx.type	end; end )
			return true
		end }
		options.icontooltip = { type = "header", order = 100, name = L["Icon Tooltips"] }
		for i=1,10 do
			options['icon'..i] = {
				type = "toggle",
				order = 110 + i,
				desc = L["Check this option to display a tooltip when the mouse is over this indicator."],
				name = function()
					return indicators[i] and self:LocalizeIndicator(indicators[i]) or ''
				end,
				get = function()
					return indicators[i].dbx.tooltipEnabled
				end,
				set = function(_,v)
					local indicator = indicators[i]
					indicator.dbx.tooltipAnchor = nil
					indicator.dbx.tooltipEnabled = v or nil
					indicator:DisableTooltips(); indicator:EnableTooltips()
				end,
				hidden = function()
					return indicators[i]==nil
				end,
			}
			options['anchor'..i] = {
				type = "select",
				order = 110.1 + i,
				name = L["Tooltip Anchor"],
				desc = L["Sets where the Tooltip is anchored relative to the icon."],
				get = function ()
					return indicators[i] and indicators[i].dbx.tooltipAnchor or 'ANCHOR_ABSENT'
				end,
				set = function (_, v)
					indicators[i].dbx.tooltipAnchor = v ~= 'ANCHOR_ABSENT' and v or nil
				end,
				hidden = function()
					return indicators[i]==nil
				end,
				disabled = function()
					return not indicators[i].dbx.tooltipEnabled
				end,
				values = Grid2Options.tooltipAnchorValues,
			}
			options['newline'..i] = {
				type = "description",
				order = 110.2 + i,
				name = "",
			}
		end
	end
end
