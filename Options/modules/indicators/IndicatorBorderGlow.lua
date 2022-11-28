local L = Grid2Options.L

local DEFAULT_FREQS = { 0.25, 0.12, 0.12 }
local COLOR_VALUES = { [1] = L["Status Color"], [2] = L["Custom Color"] }
local EFFECT_VALUES = { [1] = L['Pixel'], [2] = L['Shine'], [3] = L["Blizzard"] }

local function CheckBlizzardGlowEffectNotUsed(indExcluded)
	for _,indicator in Grid2:IterateIndicators() do
		if indicator~=indExcluded and indicator.dbx.type=='glowborder' and indicator.dbx.glowType==3 then
			Grid2Options:MessageDialog(L["Blizzard Glow effect is already in use by another indicator, select another effect."])
			return
		end
	end
	return true
end

local function MakeBorderGlowOptions(self, indicator,options)
	options.colorSource = {
			type = "select",
			order = 10,
			name = L["Glow Color"],
			desc = L["Choose how to colorize the glow border."],
			get = function ()
				return indicator.dbx.glowColor and 2 or 1
			end,
			set = function (_, v)
				if v==1 then
					indicator.dbx.glowColor = nil
				else
					indicator.dbx.glowColor = { r=0.95, g=0.95, b=0.32, a=1 }
				end
				if not indicator.suspended then	indicator:UpdateDB() end
			end,
			values= COLOR_VALUES,
	}
	options.glowColor = {
		type = "color",
		hasAlpha = true,
		order = 20,
		name = L["Glow Color"],
		desc = L["Sets the glow color to use when the indicator is active."],
		get = function() return self:UnpackColor( indicator.dbx.glowColor ) end,
		set = function( info, r,g,b,a )
			self:PackColor( r,g,b,a, indicator.dbx, "glowColor" )
			self:RefreshIndicator(indicator, "Update")
		end,
		hidden = function() return indicator.dbx.glowColor==nil end
	}
	self:MakeHeaderOptions( options, "Effect" )
	options.glowType = {
			type = "select",
			order = 35,
			width = "double",
			name = L["Glow Effect"],
			desc = L["Select the glow effect."],
			get = function ()
				return indicator.dbx.glowType or 1
			end,
			set = function (_, v)
				if v~=3 or CheckBlizzardGlowEffectNotUsed(indicator) then
					indicator:DisableAllFrames()
					indicator.dbx.glowType = v
					self:RefreshIndicator(indicator, "Update")
				end
			end,
			values= EFFECT_VALUES,
	}
	-- common options
	options.frequency = {
		type = "range",
		order = 40,
		width = "double",
		name = L["Animation Speed"],
		desc = L["Animation Speed"],
		min = -1.5,
		max = 1.5,
		step = 0.01,
		get = function () return indicator.dbx.frequency or DEFAULT_FREQS[indicator.dbx.glowType or 1] end,
		set = function (_, v)
			indicator.dbx.frequency = (v~=0 and v~=DEFAULT_FREQS[v]) and v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	-- pixel and shine options
	options.offsetX = {
		type = "range",
		order = 50,
		width = "normal",
		name = L["X Offset"],
		desc = L["X Offset"],
		softMin = -10,
		softMax = 10,
		step = 1,
		get = function () return indicator.dbx.offsetX or 0 end,
		set = function (_, v)
			indicator.dbx.offsetX = (v~=0) and v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
		hidden = function() return indicator.dbx.glowType==3 end
	}
	options.offsetY = {
		type = "range",
		order = 60,
		width = "normal",
		name = L["Y Offset"],
		desc = L["Y Offset"],
		softMin = -10,
		softMax = 10,
		step = 1,
		get = function () return indicator.dbx.offsetY or 0 end,
		set = function (_, v)
			indicator.dbx.offsetY = (v~=0) and v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
		hidden = function() return indicator.dbx.glowType==3 end
	}
	-- pixel options
	options.linesCount = {
		type = "range",
		order = 70,
		width = "normal",
		name = L["Number of Lines"],
		desc = L["Number of Lines"],
		min = 1,
		max = 20,
		step = 1,
		get = function () return indicator.dbx.linesCount or 8 end,
		set = function (_, v)
			indicator.dbx.linesCount = (v~=8) and v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
		hidden = function() return (indicator.dbx.glowType or 1)~=1 end
	}
	options.thickness = {
		type = "range",
		order = 80,
		width = "normal",
		name = L["Thickness"],
		desc = L["Thickness"],
		min = 1,
		max = 10,
		step = 1,
		get = function () return indicator.dbx.thickness or 2 end,
		set = function (_, v)
			indicator.dbx.thickness = (v~=2) and v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
		hidden = function() return (indicator.dbx.glowType or 1)~=1 end
	}
	-- shine options
	options.particlesCount = {
		type = "range",
		order = 70,
		width = "normal",
		name = L["Number of particles"],
		desc = L["Number of particles"],
		min = 1,
		max = 10,
		step = 1,
		get = function () return indicator.dbx.particlesCount or 4 end,
		set = function (_, v)
			indicator.dbx.particlesCount = (v~=4) and v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
		hidden = function() return indicator.dbx.glowType~=2 end
	}
	options.particlesScale = {
		type = "range",
		order = 80,
		width = "normal",
		name = L["Scale of particles"],
		desc = L["Scale of particles"],
		min = 0.1,
		max = 5,
		step = 0.1,
		get = function () return indicator.dbx.particlesScale or 1 end,
		set = function (_, v)
			indicator.dbx.particlesScale = (v~=1) and v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
		hidden = function() return indicator.dbx.glowType~=2 end
	}
	return options
end

Grid2Options:RegisterIndicatorOptions("glowborder", true, function(self, indicator)
	local statuses, options = {}, {}
	MakeBorderGlowOptions(self, indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options)
end)
