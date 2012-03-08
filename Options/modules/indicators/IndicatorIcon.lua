local media = LibStub("LibSharedMedia-3.0", true)
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("icon", true, function(self, indicator)
	local statuses, options =  {}, {}
	self:MakeIndicatorTypeOptions(indicator, options)
	self:MakeIndicatorLocationOptions(indicator, options)
	self:MakeIndicatorSizeOptions(indicator, options)
	self:MakeIndicatorBorderOptions(indicator, options)
	self:MakeIndicatorIconCustomOptions(indicator, options)
	self:MakeIndicatorDeleteOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options )
end)

function Grid2Options:MakeIndicatorIconCustomOptions(indicator, options)
	self:MakeHeaderOptions( options, "Appearance"  )
	self:MakeHeaderOptions( options, "Cooldown" )
	options.useStatusColor = {
		type = "toggle",
		name = L["Use Status Color"],
		desc = L["Always use the status color for the border"],
		order = 25,
		tristate = false,
		get = function () return indicator.dbx.useStatusColor end,
		set = function (_, v)
			indicator.dbx.useStatusColor = v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.disableCooldown = {
		type = "toggle",
		order = 130,
		name = L["Disable Cooldown"],
		desc = L["Disable the Cooldown Frame"],
		tristate = false,
		get = function () return indicator.dbx.disableCooldown end,
		set = function (_, v)
			indicator.dbx.disableCooldown = v or nil
			self:RefreshIndicator(indicator, "Create")
		end,
	}		
	options.reverseCooldown = {
		type = "toggle",
		order = 135,
		name = L["Reverse Cooldown"],
		desc = L["Set cooldown to become darker over time instead of lighter."],
		tristate = false,
		get = function () return indicator.dbx.reverseCooldown end,
		set = function (_, v)
			indicator.dbx.reverseCooldown = v or nil
			local indicatorKey = indicator.name
			Grid2Frame:WithAllFrames(function (f)
				f[indicatorKey].Cooldown:SetReverse(indicator.dbx.reverseCooldown)
			end)
		end,
		hidden= function() return indicator.dbx.disableCooldown end,
	}		
	options.disableOmniCC = {
		type = "toggle",
		order = 140,
		name = L["Disable OmniCC"],
		desc = L["Disable OmniCC"],
		tristate = false,
		get = function () return indicator.dbx.disableOmniCC end,
		set = function (_, v)
			indicator.dbx.disableOmniCC = v or nil
			local indicatorKey = indicator.name
			Grid2Frame:WithAllFrames(function (f) f[indicatorKey].Cooldown.noCooldownCount= v end)
		end,
		hidden= function() return indicator.dbx.disableCooldown end,
	}
	self:MakeHeaderOptions( options, "StackText" )
	options.disableStacks = {
		type = "toggle",
		order = 95,
		name = L["Disable Stack Text"],
		desc = L["Disable Stack Text"],
		tristate = false,
		get = function () return indicator.dbx.disableStack end,
		set = function (_, v)
			indicator.dbx.disableStack = v or nil
			self:RefreshIndicator(indicator, "Create")
		end,
	}
	options.fontsize = {
		type = "range",
		order = 105,
		name = L["Font Size"],
		desc = L["Adjust the font size."],
		min = 6,
		max = 24,
		step = 1,
		get = function () return indicator.dbx.fontSize	end,
		set = function (_, v)
			indicator.dbx.fontSize = v
			local indicatorKey = indicator.name
			Grid2Frame:WithAllFrames(function (f)
				local text = f[indicatorKey].CooldownText
				text:SetFont( text:GetFont() , v, "OUTLINE" )
			end)
		end,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontColor = {
		type = "color",
		order = 110,
		name = L["Color"],
		desc = L["Color"],
		get = function()
			local c= indicator.dbx.stackColor
			if c then 	return c.r, c.g, c.b, c.a
			else		return 1,1,1,1
			end
		end,
		set = function( info, r,g,b,a )
			local c = indicator.dbx.stackColor
			if c then c.r, c.g, c.b, c.a = r, g, b, a
			else	  indicator.dbx.stackColor= { r=r, g=g, b=b, a=a}
			end
			local indicatorKey = indicator.name
			Grid2Frame:WithAllFrames(function (f) 
				local text = f[indicatorKey].CooldownText
				if text then text:SetTextColor(r,g,b,a) end
			end)
		 end, 
		hasAlpha = true,
		hidden= function() return indicator.dbx.disableStack end,
	}		
	options.fontJustify = {
		type = 'select',
		order = 100,
		name = L["Text Location"],
		desc = L["Text Location"],
		values = self.pointValueList,
		get = function()
			local JustifyH = indicator.dbx.fontJustifyH or "CENTER"
			local JustifyV = indicator.dbx.fontJustifyV or "MIDDLE"
			return self.pointMapText[ JustifyH..JustifyV ]
		end,
		set = function(_, v)
			local justify =  self.pointMapText[v]
			indicator.dbx.fontJustifyH = justify[1] 
			indicator.dbx.fontJustifyV = justify[2]
			Grid2Frame:WithAllFrames(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.disableStack end,
	}
	options.font = {
		type = "select", dialogControl = "LSM30_Font",
		order = 105,
		name = L["Font"],
		desc = L["Adjust the font settings"],
		get = function (info) return indicator.dbx.font end,
		set = function (info, v)
			indicator.dbx.font = v
			local font = media:Fetch("font", v)
			local fontsize = indicator.dbx.fontSize
			local indicatorKey = indicator.name
			Grid2Frame:WithAllFrames(function (f) 
				local text = f[indicatorKey].CooldownText
				if text then text:SetFont(font,fontsize, "OUTLINE") end
			end)
		end,
		values = AceGUIWidgetLSMlists.font,
		hidden= function() return indicator.dbx.disableStack end,
	}
end
