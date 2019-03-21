
local L = Grid2Options.L

local DISPLAY_VALUES = { [1] = L["Never"], [2] = L["Always"], [3] = L["In Combat"], [4] = L["Out of Combat"] }
local ANCHOR_VALUES  = { ['@'] = L["Default"], ANCHOR_TOP = L["TOP"], ANCHOR_BOTTOM = L["BOTTOM"], ANCHOR_LEFT = L["LEFT"], ANCHOR_RIGHT = L["RIGHT"], ANCHOR_TOPLEFT = L["TOPLEFT"], ANCHOR_TOPRIGHT = L["TOPRIGHT"], ANCHOR_BOTTOMLEFT = L["BOTTOMLEFT"], ANCHOR_BOTTOMRIGHT = L["BOTTOMRIGHT"] }

local function AdvancedTooltipsEnabled(indicator)
	return not indicator.dbx.showDefault or #indicator.statuses>0
end

Grid2Options:RegisterIndicatorOptions("tooltip", false, function(self, indicator)
	if indicator.dbx.showTooltip~=1 and AdvancedTooltipsEnabled(indicator) then
		local layout, statuses = {}, {}
		self:MakeIndicatorStatusOptions(indicator, statuses)
		self:MakeIndicatorTooltipOptions(indicator,layout)
		self:AddIndicatorOptions(indicator, statuses, layout )
	else
		local layout = {}
		self:MakeIndicatorTooltipOptions(indicator,layout)
		self:AddIndicatorOptions(indicator, nil, layout )
	end	
end)

function Grid2Options:MakeIndicatorTooltipOptions(indicator, options)
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
		get = function () return indicator.dbx.tooltipAnchor or "@" end,
		set = function (_, v)
				indicator.dbx.tooltipAnchor = v ~= '@' and v or nil
				if not indicator.suspended then	indicator:UpdateDB() end
			  end,
		values = ANCHOR_VALUES,
		hidden = function() return indicator.dbx.showTooltip==1 end,
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


