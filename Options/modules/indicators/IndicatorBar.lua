-- bar indicator options

local Grid2Options = Grid2Options
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("bar", true, function(self, indicator)
	local colors, options, statuses  = {}, {}, {}
	self:MakeIndicatorBarLocationOptions(indicator,options)
	self:MakeIndicatorBarAppearanceOptions(indicator,options)
	self:MakeIndicatorBarMiscOptions(indicator,options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:MakeIndicatorStatusOptions(indicator.sideKick, colors)
	self:AddIndicatorOptions( indicator, statuses, options, colors )
end)

local list = {}
local function GetValues(info)
	local empty = true
	local exclude = info.arg
	wipe(list)
	if not info.arg.childName then
		for name, ind in Grid2:IterateIndicators() do
			if ind.dbx.type=="bar" and ind.sideKick and ind~=exclude and ( ((not ind.parentName) and (not ind.childName)) or ind.childName==exclude.name ) then
				list[name] = L[name]
			end
		end
	end
	local empty = not next(list)
	list["NONE"] = L["None"]
	return list, empty
end

local function anchorToDisabled(info)
	local _, empty = GetValues(info)
	return empty
end

local function SetParent(info,v)
	local child = info.arg
	local oldParent = Grid2.indicators[ child.parentName ]
	local newParent = v and Grid2.indicators[v]
	if oldParent then
		oldParent.childName = nil
		oldParent:UpdateDB() -- really not necessary in current implementation
	end
	child.dbx.anchorTo = newParent and newParent.name or nil
	child:UpdateDB()
	if oldParent then Grid2Frame:WithAllFrames(oldParent, "Layout") end
	if newParent then Grid2Frame:WithAllFrames(newParent, "Layout") end
	Grid2Frame:WithAllFrames(child, "Layout")
	Grid2Frame:UpdateIndicators()
	for _, indicator in Grid2:IterateIndicators() do
		if indicator.dbx.type=="bar" and indicator.sideKick then
			Grid2Options:MakeIndicatorOptions(indicator)
		end
	end
end

function Grid2Options:MakeIndicatorBarAnchorOptions(indicator,options)
	options.parentBar = {
		type   = "select",
		order  = 1.91,
		name   = L["Anchor to"],
		desc   = L["Anchor the indicator to the selected bar."],
		get    = function () return indicator.dbx.anchorTo or "NONE" end,
		set    = SetParent,
		values = GetValues,
		disabled = anchorToDisabled,
		arg    = indicator,
	}
end
-- Grid2Options:MakeIndicatorBarParentOptions()
function Grid2Options:MakeIndicatorBarLocationOptions(indicator,options)
	self:MakeHeaderOptions( options, "General" )
	if not indicator.parentName then
		self:MakeIndicatorLevelOptions(indicator,options)
		self:MakeIndicatorLocationOptions(indicator,options)
	end
	self:MakeIndicatorBarAnchorOptions(indicator,options)
end

-- Grid2Options:MakeIndicatorBarDisplayOptions()
function Grid2Options:MakeIndicatorBarAppearanceOptions(indicator,options)
	self:MakeHeaderOptions( options, "Appearance" )
	if indicator.dbx.anchorTo then return end
	options.orientation = {
		type = "select",
		order = 15,
		name = L["Orientation of the Bar"],
		desc = L["Set status bar orientation."],
		get = function ()
			return indicator.dbx.orientation or "DEFAULT"
		end,
		set = function (_, v)
			if v=="DEFAULT" then v= nil	end
			indicator:SetOrientation(v)
			Grid2Frame:WithAllFrames(indicator, "Layout")
			if indicator.childName then
				self:RefreshIndicator( Grid2.indicators[indicator.childName], "Layout" )
			end
		end,
		values={ ["DEFAULT"]= L["DEFAULT"], ["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
	}
	options.barWidth= {
		type = "range",
		order = 30,
		name = L["Bar Width"],
		desc = L["Choose zero to set the bar to the same width as parent frame"],
		min = 0,
		softMax = 75,
		step = 1,
		get = function ()
			return indicator.dbx.width
		end,
		set = function (_, v)
			if v==0 then v= nil end
			indicator.dbx.width = v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.barHeight= {
		type = "range",
		order = 40,
		name = L["Bar Height"],
		desc = L["Choose zero to set the bar to the same height as parent frame"],
		min = 0,
		softMax = 75,
		step = 1,
		get = function ()
			return indicator.dbx.height
		end,
		set = function (_, v)
			if v==0 then v= nil end
			indicator.dbx.height = v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
	options.reverseFill= {
		type = "toggle",
		name = L["Reverse Fill"],
		desc = L["Fill the bar in reverse."],
		order = 44,
		tristate = false,
		get = function () return indicator.dbx.reverseFill end,
		set = function (_, v)
			indicator.dbx.reverseFill = v or nil
			self:RefreshIndicator(indicator, "Layout")
			if indicator.childName then
				self:RefreshIndicator( Grid2.indicators[indicator.childName], "Layout" )
			end
		end,
	}
	self:MakeHeaderOptions( options, "Background" )
	options.enableBack = {
		type = "toggle",
		name = L["Enable Background"],
		desc = L["Enable Background"],
		order = 61,
		get = function () return indicator.dbx.backColor~=nil end,
		set = function (_, v)
			if v then
				indicator.dbx.backColor = { r=0,g=0,b=0,a=1 }
			else
				indicator.dbx.backColor, indicator.dbx.backTexture = nil, nil
			end
			self:RefreshIndicator(indicator, "Create")
		end,
	}
	options.backAlwaysVisible = {
		type = "toggle",
		name = L["Always Visible"],
		desc = L["Display the background even when the indicator is not active."],
		order = 62,
		get = function () return not indicator.dbx.hideWhenInactive end,
		set = function (_, v)
			indicator.dbx.hideWhenInactive = (not v) or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return not indicator.dbx.backColor end,
	}
	options.backColor = {
		type = "color",
		order = 63,
		name = L["Background Color"],
		desc = L["Background Color"],
		hasAlpha = true,
		get = function() return self:UnpackColor( indicator.dbx.backColor, "BLACK" ) end,
		set = function(info,r,g,b,a)
			self:PackColor( r,g,b,a, indicator.dbx, "backColor" )
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return not indicator.dbx.backColor end,
	}
	options.backTexture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 64,
		name = L["Background Texture"],
		desc = L["Adjust the background texture."],
		get = function (info) return indicator.dbx.backTexture or self.MEDIA_VALUE_DEFAULT end,
		set = function (info, v)
			indicator.dbx.backTexture = v~=self.MEDIA_VALUE_DEFAULT and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = self.GetStatusBarValues,
		hidden = function() return not indicator.dbx.backColor end,
	}
end

-- Grid2Options:MakeIndicatorBarMiscOptions()
function Grid2Options:MakeIndicatorBarMiscOptions(indicator, options)
	options.texture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 20,
		name = L["Frame Texture"],
		desc = L["Adjust the frame texture."],
		get = function (info) return indicator.dbx.texture or self.MEDIA_VALUE_DEFAULT end,
		set = function (info, v)
			indicator.dbx.texture = v~=self.MEDIA_VALUE_DEFAULT and v or nil
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = self.GetStatusBarValues,
	}
	options.barOpacity = {
		type = "range",
		order = 43,
		name = L["Opacity"],
		desc = L["Set the opacity."],
		min = 0,
		max = 1,
		step = 0.01,
		bigStep = 0.05,
		get = function () return indicator.dbx.opacity or 1	end,
		set = function (_, v)
			indicator.dbx.opacity = v
			indicator.sideKick:UpdateDB()
			Grid2Frame:UpdateIndicators()
		end,
	}
	self:MakeHeaderOptions( options, "Special" )
	options.inverColor= {
		type = "toggle",
		name = L["Invert Bar Color"],
		desc = L["Swap foreground/background colors on bars."],
		order = 71,
		tristate = false,
		get = function () return indicator.dbx.invertColor	end,
		set = function (_, v)
			indicator.dbx.invertColor = v or nil
			indicator.sideKick:UpdateDB()
			self:RefreshIndicator(indicator, "Create")
		end,
	}
	self:MakeHeaderOptions( options, "Display" )
	options.duration = {
		type = "toggle",
		name = L["Show duration"],
		desc = L["Show the time remaining."],
		order = 81,
		tristate = false,
		get = function () return indicator.dbx.duration	end,
		set = function (_, v)
			indicator.dbx.duration = v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
	options.stack = {
		type = "toggle",
		name = L["Show stack"],
		desc = L["Show the number of stacks."],
		order = 85,
		tristate = false,
		get = function () return indicator.dbx.stack end,
		set = function (_, v)
			indicator.dbx.stack = v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
end
