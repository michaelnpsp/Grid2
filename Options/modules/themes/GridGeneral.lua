local L = Grid2Options.L

local theme = Grid2Options.editedTheme

--=========================================================================================================
-- Util functions to manage headers positions
--=========================================================================================================

local GetTableValue = Grid2Options.GetTableValueSafe
local SetTableValue = Grid2Options.SetTableValueSafe

local function GetHeaderPositionKey(headerName)
	for _,frame in ipairs(Grid2Layout.groupsUsed) do
		if headerName == frame.headerName then
			return frame.headerPosKey or Grid2Layout.frame.headerPosKey
		end
	end
end

local function GetHeaderPositionData(headerName)
	return theme.layout.Positions[ GetHeaderPositionKey(headerName) ] or {0, 0, 0}
end

local function GetPosAdjust(key, horizontal)
	if key~=nil and key~='player' then
		local anchor = GetTableValue(theme.layout.anchors, key, theme.layout.anchor)
		if horizontal then
			return (anchor:find("LEFT") or anchor:find('RIGHT')) and theme.layout.Spacing or 0
		else
			return (anchor:find("TOP") or anchor:find('BOTTOM')) and theme.layout.Spacing or 0
		end
	end
	return 0
end

local function GetPhysicalPosX(posX, key)
	local screen_w, screen_h = GetPhysicalScreenSize()
	posX = math.floor( posX * screen_w / (UIParent:GetWidth()*UIParent:GetEffectiveScale()) + 0.5 )
	return posX + GetPosAdjust(key, true)
end

local function GetVirtualPosX(posX, key)
	posX = posX - GetPosAdjust(key, true)
	local screen_w, screen_h = GetPhysicalScreenSize()
	return posX / (screen_w / (UIParent:GetWidth()*UIParent:GetEffectiveScale()))
end

local function GetPhysicalPosY(posY, key)
	local screen_w, screen_h = GetPhysicalScreenSize()
	posY = math.floor( posY * screen_h / (UIParent:GetHeight()*UIParent:GetEffectiveScale()) + 0.5 )
	return posY + GetPosAdjust(key, false)
end

local function GetVirtualPosY(posY, key)
	posY = posY - GetPosAdjust(key, false)
	local screen_w, screen_h = GetPhysicalScreenSize()
	return posY / (screen_h / (UIParent:GetHeight()*UIParent:GetEffectiveScale()))
end

--=========================================================================================================
-- Layout position & anchor
--=========================================================================================================

local layoutOptions1 =  { positionheader = {
		type = "header",
		order = 5,
		name = L["Main Window Position"],
		hidden = function() return theme.layout.detachedHeaders or theme.layout.specialHeaders end,
}, posx = {
		type = "range",
		name = L["Horizontal Position"],
		desc = L["Adjust Grid2 horizontal position."],
		order = 10,
		width = 1.2,
		softMin = -2048,
		softMax = 2048,
		step = 1,
		get = function ()
			return GetPhysicalPosX( theme.layout.PosX )
		end,
		set = function (_, v)
			theme.layout.PosX = GetVirtualPosX(v)
			Grid2Layout:RestorePosition()
			Grid2Layout:SavePosition()
		end,
		hidden = function() return theme.layout.detachedHeaders or theme.layout.specialHeaders end,
}, posy = {
		type = "range",
		name = L["Vertical Position"],
		desc = L["Adjust Grid2 vertical position."],
		order = 20,
		width = 1.2,
		softMin = -2048,
		softMax = 2048,
		step = 1,
		get = function ()
			return GetPhysicalPosY( theme.layout.PosY )
		end,
		set = function (_, v)
			theme.layout.PosY = GetVirtualPosY(v)
			Grid2Layout:RestorePosition()
			Grid2Layout:SavePosition()
		end,
		hidden = function() return theme.layout.detachedHeaders or theme.layout.specialHeaders end,
}, anchorheader = {
		type = "header",
		order = 30,
		name = L["Default Settings"],
}, layoutanchor = {
		type = "select",
		name = L["Layout Anchor"],
		desc = L["Sets where Grid is anchored relative to the screen."],
		order = 40,
		width = 0.9,
		get = function () return theme.layout.anchor end,
		set = function (_, v)
				  theme.layout.anchor = v
				  Grid2Layout:SavePosition()
				  Grid2Layout:RestorePosition()
				  Grid2Layout:RefreshLayout()
			  end,
		values= {["CENTER"] = L["CENTER"], ["TOP"] = L["TOP"], ["BOTTOM"] = L["BOTTOM"], ["LEFT"] = L["LEFT"], ["RIGHT"] = L["RIGHT"], ["TOPLEFT"] = L["TOPLEFT"], ["TOPRIGHT"] = L["TOPRIGHT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"] }
}, groupanchor = {
		type = "select",
		name = L["Group Anchor"],
		desc = L["Sets where groups are anchored relative to the layout frame."],
		order = 50,
		width = 0.9,
		get = function () return theme.layout.groupAnchor end,
		set = function (_, v)
			theme.layout.groupAnchor = v
			Grid2Layout:RefreshLayout()
		end,
		values= {["TOPLEFT"] = L["TOPLEFT"], ["TOPRIGHT"] = L["TOPRIGHT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"] }
}, groupHorizontal = {
		type = "select",
		name = L["Groups Orientation"],
		desc = L["Switch between horzontal/vertical groups."],
		order = 50,
		width = 0.6,
		get = function () return theme.layout.horizontal end,
		set = function (_, v)
			theme.layout.horizontal = v
			Grid2Layout:RefreshLayout()
		end,
		values= { [true] = L['Horizontal'], [false] = L['Vertical'] }
}, framewidth = {
		type = "range",
		order = 60,
		width = 1.2,
		name = L["Frame Width"],
		desc = L["Adjust the width of each unit's frame."],
		min = 10,
		softMax = 100,
		step = 1,
		get = function ()
			return theme.frame.frameWidth
		end,
		set = function (_, v)
			theme.frame.frameWidth = v
			Grid2Layout:UpdateDisplay()
		end,
		disabled = InCombatLockdown,
}, frameheight = {
		type = "range",
		order = 70,
		width = 1.2,
		name = L["Frame Height"],
		desc = L["Adjust the height of each unit's frame."],
		min = 10,
		softMax = 100,
		step = 1,
		get = function ()
			return theme.frame.frameHeight
		end,
		set = function (_, v)
			theme.frame.frameHeight = v
			Grid2Layout:UpdateDisplay()
		end,
		disabled = InCombatLockdown,
}, positionfooter = {
		type = "header",
		order = 90,
		name = L['Header Types'],
} }

--=========================================================================================================
-- Layout position & anchor by Header Type
--=========================================================================================================

do
	local key, def
	local defUPC = { player = 5, pet = 5, boss =  8 }
	local specialHeaders = { boss = true, target = true, focus = true }
	local headerAnchorPoints = { [''] = L['Default'], CENTER = L["CENTER"], TOP = L["TOP"], BOTTOM = L["BOTTOM"], LEFT = L["LEFT"], RIGHT = L["RIGHT"], TOPLEFT = L["TOPLEFT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMLEFT = L["BOTTOMLEFT"], BOTTOMRIGHT = L["BOTTOMRIGHT"] }
	local groupAnchorPoints  = { [''] = L['Default'], TOPLEFT = L["TOPLEFT"], TOPRIGHT = L["TOPRIGHT"], BOTTOMLEFT = L["BOTTOMLEFT"], BOTTOMRIGHT = L["BOTTOMRIGHT"] }

	local layoutAnchorOptions = {

		__load = { type = "header", order = 0, name = "", hidden = function(info)
			key = info[#info-1]
			return true
		end },

		posx = {
			type = "range",
			name = L["Horizontal Position"],
			desc = L["Adjust Grid2 horizontal position."],
			order = 1,
			width = 1.2,
			softMin = -2048,
			softMax = 2048,
			step = 1,
			get = function ()
				return GetPhysicalPosX( GetHeaderPositionData(key)[2], key )
			end,
			set = function (_, v)
				GetHeaderPositionData(key)[2] = GetVirtualPosX(v, key)
				Grid2Layout:RefreshLayout()
			end,
			hidden = function() return not (theme.layout.detachedHeaders or theme.layout.specialHeaders) end,
		},

		posy = {
			type = "range",
			name = L["Vertical Position"],
			desc = L["Adjust Grid2 vertical position."],
			order = 2,
			width = 1.2,
			softMin = -2048,
			softMax = 2048,
			step = 1,
			get = function ()
				return GetPhysicalPosY( GetHeaderPositionData(key)[3], key )
			end,
			set = function (_, v)
				GetHeaderPositionData(key)[3] = GetVirtualPosY(v, key)
				Grid2Layout:RefreshLayout()
			end,
			hidden = function() return not (theme.layout.detachedHeaders or theme.layout.specialHeaders) end,
		},

		anchor = {
			type = "select",
			name = L['Layout Anchor'],
			order = 10,
			width = 0.9,
			get = function ()
				return GetTableValue(theme.layout.anchors, key, '')
			end,
			set = function (_, v)
				SetTableValue(theme.layout, 'anchors',  key, v~='' and v or nil)
				Grid2Layout:RefreshLayout()
			end,
			values = headerAnchorPoints,
			hidden = function() return specialHeaders[key]==nil and ( key=='player' or theme.layout.detachedHeaders==nil ) end,
		},

		groupAnchor = {
			type = "select",
			name = L["Group Anchor"],
			order = 20,
			width = 0.9,
			get = function ()
				return GetTableValue(theme.layout.groupAnchors, key, '')
			end,
			set = function (_, v)
				SetTableValue(theme.layout, 'groupAnchors',  key, v~='' and v or nil)
				Grid2Layout:RefreshLayout()
			 end,
			values= groupAnchorPoints,
			disabled = function() return defUPC[key]==nil end,
			hidden = function() return specialHeaders[key]==nil and ( key=='player' or theme.layout.detachedHeaders==nil ) end,
		},

		groupOrientation = {
			type = "select",
			name = L["Groups Orientation"],
			desc = L["Switch between horzontal/vertical groups."],
			order = 30,
			width = 0.6,
			get = function ()
				return GetTableValue(theme.layout.groupHorizontals, key, '')
			end,
			set = function (_, v)
				if v=='' then v = nil end
				SetTableValue(theme.layout, 'groupHorizontals',  key, v)
				Grid2Layout:RefreshLayout()
			end,
			values= { [''] = L['Default'], [true] = L['Horizontal'], [false] = L['Vertical'] },
			disabled = function() return defUPC[key]==nil end,
			hidden = function()	return specialHeaders[key]==nil and ( key=='player' or theme.layout.detachedHeaders==nil ) end,
		},

		frameWidth = {
			type = "range",
			order = 35,
			width = 0.9,
			name = L['Frame Width'],
			desc = L["Adjust the width percent of each unit's frame."],
			min = 0.01,
			max = 5,
			step = 0.001,
			softMax = 1,
			isPercent = true,
			get = function ()
				return GetTableValue( theme.frame.frameHeaderWidths, key, 1 )
			end,
			set = function (_, v)
				SetTableValue( theme.frame, 'frameHeaderWidths', key, v~=1 and v or nil )
				Grid2Layout:UpdateDisplay()
			end,
		},

		frameHeight = {
			type = "range",
			order = 36,
			width = 0.9,
			name = L['Frame Height'],
			desc = L["Adjust the height percent of each unit's frame."],
			min = 0.01,
			max = 5,
			step = 0.001,
			softMax = 1,
			isPercent = true,
			get = function ()
				return GetTableValue( theme.frame.frameHeaderHeights, key, 1 )
			end,
			set = function (_, v)
				SetTableValue( theme.frame, 'frameHeaderHeights', key, v~=1 and v or nil )
				Grid2Layout:UpdateDisplay()
			end,
		},

		unitsPerColumn = {
			order = 40,
			width = 0.6,
			type = "range",
			name = L["Units per Column"],
			desc = L["Adjust the default units per column for this group type."],
			min = 1,
			max = 40,
			softMax = 10,
			step = 1,
			get = function ()
				return GetTableValue( theme.layout.unitsPerColumns, key, defUPC[key] or 1 )
			end,
			set = function (_, v)
				SetTableValue( theme.layout, 'unitsPerColumns', key, v~=defUPC[key] and v or nil )
				Grid2Layout:RefreshLayout()
			end,
			disabled = function() return not defUPC[key] end,
		},

		detachedPlayerHeaders = {
			order = 50,
			type = "toggle",
			width = 'full',
			name = L['Detach all groups'],
			desc = L["Enable this option to detach unit frame groups, so each group can be moved individually."],
			get = function(info)
				return theme.layout.detachedHeaders=='player'
			end,
			set = function(info,v)
				theme.layout.detachedHeaders = v and 'player' or nil
				Grid2Layout:RefreshLayout()
			end,
			hidden = function() return key~='player' end,
		},

		detachedPetHeaders = {
			order = 50,
			type = "toggle",
			width = 'full',
			name = L['Detach pets groups'],
			desc = L["Enable this option to detach the pets group, so pets group can be moved individually."],
			get = function(info)
				return theme.layout.detachedHeaders~=nil
			end,
			set = function(info,v)
				theme.layout.detachedHeaders = v and 'pet' or nil
				Grid2Layout:RefreshLayout()
			end,
			disabled = function() return theme.layout.detachedHeaders=='player' end,
			hidden = function() return key~='pet' end,
		},

		hideEmptyUnits = {
			order = 60,
			type = "toggle",
			name = L['Hide Empty Units'],
			desc = L["Hide frames of non-existant units."],
			get = function(info)
				return not (theme.layout.specialHeaders and theme.layout.specialHeaders[key])
			end,
			set = function(info)
				theme.layout.specialHeaders[key] = not theme.layout.specialHeaders[key]
				Grid2Layout:RefreshLayout()
			end,
			hidden = function() return not specialHeaders[key] end,
		},

	}

	layoutOptions1.player = {
		type = "group", order = 1, name = L['Players'],
		args = layoutAnchorOptions,
	}
	layoutOptions1.pet    = {
		type = "group", order = 2, name = L['Pets'],
		args = layoutAnchorOptions,
	}
	layoutOptions1.self  = {
		type = "group", order = 3, name = L['Player'],
		args = layoutAnchorOptions,
		disabled = function() return theme.layout.specialHeaders==nil or theme.layout.specialHeaders.self==nil end
	}
	layoutOptions1.target = {
	    type = "group", order = 4, name = L['Target'],
		args = layoutAnchorOptions,
		disabled = function() return theme.layout.specialHeaders==nil or theme.layout.specialHeaders.target==nil end,
	}
	layoutOptions1.focus  = {
		type = "group", order = 5, name = L['Focus'],
		args = layoutAnchorOptions,
		disabled = function() return Grid2.isVanilla or theme.layout.specialHeaders==nil or theme.layout.specialHeaders.focus==nil end
	}
	layoutOptions1.boss  = {
		type = "group", order = 6, name = L['Bosses'],
		args = layoutAnchorOptions,
		disabled = function() return Grid2.isClassic or theme.layout.specialHeaders==nil or theme.layout.specialHeaders.boss==nil end
	}

end

--=========================================================================================================
-- Layout Look&Feel
--=========================================================================================================

local layoutOptions2 =  { displayheader = {
		type = "header",
		order = 100,
		name = L["Display"],
}, display = {
		type = "select",
		name = L["Show Frame"],
		desc = L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."],
		order = 101,
		get = function() return theme.layout.FrameDisplay~="Never" and theme.layout.FrameDisplay or "@Never" end,
		set = function(_, v)
			theme.layout.FrameDisplay = v~='@Never' and v or 'Never'
			Grid2Layout:UpdateVisibility()
		end,
		values={["Always"] = L["Always"], ["Grouped"] = L["Grouped"], ["Raid"] = L["Raid"], ["@Never"] = L["Never"]},
}, petBattle = {
		type = "toggle",
		name = L["Hide in Pet Battles"],
		desc = L["Toggle to hide Grid2 window in Pet Battles"],
		order = 107,
		get = function () return theme.layout.HideInPetBattle end,
		set = function (_, v)
				  theme.layout.HideInPetBattle = v or nil
				  Grid2Layout:UpdateVisibility()
			  end,
}, frameStrata = {
		type = "select",
		name = L["Frame Strata"],
		desc = L["Sets the strata in which the layout frame should be layered."],
		order = 102,
		get = function() return theme.layout.FrameStrata or "MEDIUM" end,
		set = function(_, v)
			Grid2LayoutFrame:SetFrameStrata( v )
			theme.layout.FrameStrata = (v~="MEDIUM") and v or nil
		end,
		values ={ BACKGROUND = L["BACKGROUND"], LOW = L["LOW"], MEDIUM = L["MEDIUM"], HIGH = L["HIGH"] },
}, backTexture = {
		type = 'select', dialogControl = 'LSM30_Background',
		order = 103,
		name = L['Background Texture'],
		get = function (info) return theme.layout.BackgroundTexture or "Grid2 Flat" end,
		set = function (info, v)
			theme.layout.BackgroundTexture = v
			Grid2Layout:UpdateTextures()
			Grid2Layout:UpdateColor()
		end,
		values = AceGUIWidgetLSMlists.background,
}, borderTexture = {
		type = "select", dialogControl = "LSM30_Border",
		order = 103.1,
		name = L["Border Texture"],
		desc = L["Adjust the border texture."],
		get = function (info) return theme.layout.BorderTexture or "Grid2 Flat" end,
		set = function (info, v)
			theme.layout.BorderTexture = v
			Grid2Layout:UpdateTextures()
			Grid2Layout:UpdateColor()
		end,
		values = AceGUIWidgetLSMlists.border,
}, backColor = {
		type = "color",
		name = L["Background Color"],
		desc = L["Adjust background color and alpha."],
		order = 103.2,
		get = function ()
				  local settings = theme.layout
				  return settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA
			  end,
		set = function (_, r, g, b, a)
				  local settings = theme.layout
				  settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA = r, g, b, a
				  Grid2Layout:UpdateColor()
			  end,
		hasAlpha = true,
}, borderColor = {
		type = "color",
		name = L["Border Color"],
		desc = L["Adjust border color and alpha."],
		order = 103.3,
		get = function ()
				  local settings = theme.layout
				  return settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA
			  end,
		set = function (_, r, g, b, a)
				  local settings = theme.layout
				  settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA = r, g, b, a
				  Grid2Layout:UpdateColor()
			  end,
		hasAlpha = true,
}, spacing = {
		type = "range",
		name = L["Spacing"],
		desc = L["Adjust frame spacing."],
		order = 104,
		max = 25,
		min = 0,
		step = 1,
		get = function () return theme.layout.Spacing end,
		set = function (_, v)
				theme.layout.Spacing = v
				Grid2Layout:RefreshLayout()
			  end,
}, padding = {
		type = "range",
		name = L["Padding"],
		desc = L["Adjust frame padding."],
		order = 105,
		max = 20,
		softMin = 0,
		step = 1,
		get = function ()
				  return theme.layout.Padding
			  end,
		set = function (_, v)
				  theme.layout.Padding = v
				  Grid2Layout:RefreshLayout()
			  end,
}, scale = {
		type = "range",
		name = L["Scale"],
		desc = L["Adjust Grid scale."],
		order = 106,
		min = 0.5,
		max = 2.0,
		step = 0.05,
		isPercent = true,
		get = function ()
				  return theme.layout.ScaleSize
			  end,
		set = function (_, v)
				  theme.layout.ScaleSize = v
				  Grid2Layout:RefreshLayout()
			  end,
}, mischeader = {
		type = "header",
		order = 200,
		name = L["Misc"],
}, lock = {
		type = "toggle",
		name = L["Frame lock"],
		desc = L["Locks/unlocks the grid for movement."],
		order = 210,
		get = function() return theme.layout.FrameLock end,
		set = function()
			theme.layout.FrameLock = not theme.layout.FrameLock
			Grid2Layout:UpdateFrame()
		end,
}, clamp = {
		type = "toggle",
		name = L["Clamped to screen"],
		desc = L["Toggle whether to permit movement out of screen."],
		order = 220,
		get = function ()
				  return theme.layout.clamp
			  end,
		set = function ()
				  theme.layout.clamp = not theme.layout.clamp
				  Grid2Layout:SetClamp()
			  end,
} }

--===============================================================================================
-- Frames Look & Feel
--===============================================================================================

local frameOptions2 = { headerback = {
		type = "header",
		order = 21,
		name = L["Background"],
}, backgroundTexture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 22,
		name = L["Background Texture"],
		desc = L["Select the frame background texture."],
		get = function (info) return theme.frame.frameTexture or "Gradient" end,
		set = function (info, v)
			theme.frame.frameTexture = v
			Grid2Options:LayoutFrames()
		end,
		values = AceGUIWidgetLSMlists.statusbar,
},  backgroundColor = {
		type = "color",
		order = 23,
		name = L["Background Color"],
		desc = L["Sets the default color for the background indicator."],
		get = function()
			local c= theme.frame.frameContentColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c = theme.frame.frameContentColor
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Frame:UpdateIndicators()
		 end,
		hasAlpha = true,
}, headerborder = {
		type = "header",
		order = 25,
		name = L["Borders"],
}, borderIndicatorColor = {
	type = "color",
	order = 33,
	name = L["Border Color"],
	desc = L["Sets the default color for the border indicator."],
	get = function()
		c = Grid2:MakeColor( theme.frame.frameBorderColor, 'TRANSPARENT' )
		return c.r, c.g, c.b, c.a
	end,
	set = function( info, r,g,b,a )
		local c = theme.frame.frameBorderColor or {}
		c.r, c.g, c.b, c.a = r, g, b, a
		theme.frame.frameBorderColor = c
		Grid2Options:RefreshIndicator(Grid2.indicators.border, "Update")
	 end,
	hasAlpha = true,
}, borderIndicatorSize = {
	type = "range",
	order = 32,
	name = L["Border Size"],
	desc = L["Adjust the border of each unit's frame."],
	min = 1,
	max = 20,
	step = 1,
	get = function () return theme.frame.frameBorder end,
	set = function (_, frameBorder)
		theme.frame.frameBorder = frameBorder
		Grid2Options:LayoutFrames()
	end,
	disabled = InCombatLockdown,
}, innerBordercolor = {
		type = "color",
		order = 41,
		name = L["Inner Border Color"],
		desc = L["Sets the color of the inner border of each unit frame"],
		get = function()
			local c= theme.frame.frameColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c= theme.frame.frameColor
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Options:LayoutFrames()			
		 end,
		hasAlpha = true,
}, innerBorderDistance= {
		type = "range",
		order = 40,
		name = L["Inner Border Size"],
		desc = L["Sets the size of the inner border of each unit frame"],
		min = -16,
		max = 16,
		step = 1,
		get = function ()
			return theme.frame.frameBorderDistance
		end,
		set = function (_, v)
			theme.frame.frameBorderDistance = v
			Grid2Options:LayoutFrames()
		end,
}, borderIndicatorTexture = {
	type = "select", dialogControl = "LSM30_Border",
	order = 42,
	name = L["Border Texture"],
	desc = L["Adjust the border texture."],
	get = function (info) return theme.frame.frameBorderTexture or "Grid2 Flat" end,
	set = function (info, v)
		theme.frame.frameBorderTexture = v
		Grid2Options:LayoutFrames()		
	end,
	values = AceGUIWidgetLSMlists.border,

}, headermouse = {
		type = "header",
		order = 50,
		name = L["Mouseover"],
}, mouseoverHighlight = {
		type = "toggle",
		name = L["Mouseover Highlight"],
		desc = L["Toggle mouseover highlight."],
		width = "full",
		order = 51,
		get = function ()
			return theme.frame.mouseoverHighlight
		end,
		set = function (_, v)
			theme.frame.mouseoverHighlight = v
			Grid2Options:LayoutFrames()
		end,
}, mouseoverColor = {
		type = "color",
		order = 53,
		name = L["Highlight Color"],
		desc = L["Sets the hightlight color of each unit frame"],
		get = function()
			local c = theme.frame.mouseoverColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c = theme.frame.mouseoverColor
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Options:LayoutFrames()			
		 end,
		hasAlpha = true,
		hidden = function() return not theme.frame.mouseoverHighlight end,
}, mouseoverTexture = {
		type = "select", dialogControl = "LSM30_Background",
		order = 52,
		name = L["Highlight Texture"],
		desc = L["Sets the highlight border texture of each unit frame"],
		get = function (info) return theme.frame.mouseoverTexture or "Blizzard Quest Title Highlight" end,
		set = function (info, v)
			theme.frame.mouseoverTexture = v
			Grid2Options:LayoutFrames()
		end,
		values = AceGUIWidgetLSMlists.background,
		hidden = function() return not theme.frame.mouseoverHighlight end,
}, mischeader = {
		type = "header",
		order = 100,
		name = L["Misc"],
}, rightClickMenu = {
		type = "toggle",
		name = L["Right Click Menu"],
		desc = L["Display the standard unit menu when right clicking on a frame."],
		order = 110,
		get = function () return not theme.frame.menuDisabled end,
		set = function (_, v)
			theme.frame.menuDisabled = (not v) or nil
			Grid2Layout:UpdateMenu()
		end,
}, }

--===============================================================================================

local options = {
	layout1 = { type = "group", order = 1, name = L["Layout Disposition"], desc = L["Layout"], args = layoutOptions1, childGroups = 'tab' },
	layout2 = { type = "group", order = 2, name = L["Layout Look&Feel"],   desc = L["Layout"], args = layoutOptions2 },
	frame2  = { type = "group", order = 4, name = L["Frames Look&Feel"],   desc = L["Frames"], args = frameOptions2  },
}
Grid2Options:AddThemeOptions( "appearance", "Appearance", options )

-- Refresh theme general options the first time they are displayed, it's a workaround to a weird bug in AceConfig/AceGUI:
-- sometimes all editboxes of sliders do not display any value, this only happens when we have 3 nested groups like in:
-- "Themes>Default>General Tab>options width sliders", and clicking very fast to open general theme options.
options.bugfix = { type = "header", order = 500, name = "", hidden = function()	options.bugfix = nil; Grid2Options:NotifyChange(); return true end }
