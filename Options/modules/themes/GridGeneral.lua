local L = Grid2Options.L

local theme = Grid2Options.editedTheme 

--=========================================================================================================

local order_layout  = 40
local order_display = 30
local order_anchor  = 20

local layoutOptions =  { mainheader = {
		type = "header",
		order = order_layout + 1,
		name = L["Misc"],
}, horizontal = {
		type = "toggle",
		name = L["Horizontal groups"],
		desc = L["Switch between horzontal/vertical groups."],
		order = order_layout + 4,
		get = function ()
				  return theme.layout.horizontal
			  end,
		set = function ()
			theme.layout.horizontal = not theme.layout.horizontal
			Grid2Layout:RefreshLayout()
			Grid2Options:LayoutTestRefresh()
		 end,
}, lock = {
		type = "toggle",
		name = L["Frame lock"],
		desc = L["Locks/unlocks the grid for movement."],
		order = order_layout + 6,
		get = function() return theme.layout.FrameLock end,
		set = function()
			theme.layout.FrameLock = not theme.layout.FrameLock
			Grid2Layout:UpdateFrame()
		end,
}, rightClickMenu = {
		type = "toggle",
		name = L["Right Click Menu"],
		desc = L["Display the standard unit menu when right clicking on a frame."],
		order = order_layout + 8,
		get = function () return not theme.frame.menuDisabled end,
		set = function (_, v)
			theme.frame.menuDisabled = (not v) or nil
			Grid2Frame:UpdateMenu()
		end,
}, clamp = {
		type = "toggle",
		name = L["Clamped to screen"],
		desc = L["Toggle whether to permit movement out of screen."],
		order = order_layout + 9,
		get = function ()
				  return theme.layout.clamp
			  end,
		set = function ()
				  theme.layout.clamp = not theme.layout.clamp
				  Grid2Layout:SetClamp()
			  end,		
}, displayheader = {
		type = "header",
		order = order_display,
		name = L["Display"],
}, display = {
		type = "select",
		name = L["Show Frame"],
		desc = L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."],
		order = order_display + 1,
		get = function() return theme.layout.FrameDisplay end,
		set = function(_, v)
			theme.layout.FrameDisplay = v
			Grid2Layout:CheckVisibility()
		end,
		values={["Always"] = L["Always"], ["Grouped"] = L["Grouped"], ["Raid"] = L["Raid"]},
}, petBattle = {
		type = "toggle",
		name = L["Hide in Pet Battles"],
		desc = L["Toggle to hide Grid2 window in Pet Battles"],
		order = order_display + 7,
		get = function () return theme.layout.HideInPetBattle end,
		set = function (_, v)
				  theme.layout.HideInPetBattle = v or nil
				  Grid2Layout:CheckVisibility()
			  end,
}, frameStrata = {
		type = "select",
		name = L["Frame Strata"],
		desc = L["Sets the strata in which the layout frame should be layered."],
		order = order_display + 2,
		get = function() return theme.layout.FrameStrata or "MEDIUM" end,
		set = function(_, v)
			Grid2LayoutFrame:SetFrameStrata( v )
			theme.layout.FrameStrata = (v~="MEDIUM") and v or nil
		end,
		values ={ BACKGROUND = L["BACKGROUND"], LOW = L["LOW"], MEDIUM = L["MEDIUM"], HIGH = L["HIGH"] },
}, backTexture = {
		type = 'select', dialogControl = 'LSM30_Background',
		order = order_display + 3,
		name = L['Background Texture'],
		get = function (info) return theme.layout.BackgroundTexture or "Grid2 Flat" end,
		set = function (info, v)
			theme.layout.BackgroundTexture = v
			Grid2Layout:UpdateTextures()
			Grid2Layout:UpdateColor()
			Grid2Options:LayoutTestRefresh()
		end,
		values = AceGUIWidgetLSMlists.background,
}, borderTexture = {
		type = "select", dialogControl = "LSM30_Border",
		order = order_display + 3.1,
		name = L["Border Texture"],
		desc = L["Adjust the border texture."],
		get = function (info) return theme.layout.BorderTexture or "Grid2 Flat" end,
		set = function (info, v)
			theme.layout.BorderTexture = v
			Grid2Layout:UpdateTextures()
			Grid2Layout:UpdateColor()
			Grid2Options:LayoutTestRefresh()
		end,
		values = AceGUIWidgetLSMlists.border,
}, backColor = {
		type = "color",
		name = L["Background Color"],
		desc = L["Adjust background color and alpha."],
		order = order_display + 3.2,
		get = function ()
				  local settings = theme.layout
				  return settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA
			  end,
		set = function (_, r, g, b, a)
				  local settings = theme.layout
				  settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA = r, g, b, a
				  Grid2Layout:UpdateColor()
				  Grid2Options:LayoutTestRefresh()
			  end,
		hasAlpha = true,
}, borderColor = {
		type = "color",
		name = L["Border Color"],
		desc = L["Adjust border color and alpha."],
		order = order_display + 3.3,
		get = function ()
				  local settings = theme.layout
				  return settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA
			  end,
		set = function (_, r, g, b, a)
				  local settings = theme.layout
				  settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA = r, g, b, a
				  Grid2Layout:UpdateColor()
				  Grid2Options:LayoutTestRefresh()
			  end,
		hasAlpha = true,
}, spacing = {
		type = "range",
		name = L["Spacing"],
		desc = L["Adjust frame spacing."],
		order = order_display + 4,
		max = 25,
		min = 0,
		step = 1,
		get = function () return theme.layout.Spacing end,
		set = function (_, v)
				theme.layout.Spacing = v
				Grid2Layout:RefreshLayout()
				Grid2Options:LayoutTestRefresh()
			  end,
}, padding = {
		type = "range",
		name = L["Padding"],
		desc = L["Adjust frame padding."],
		order = order_display + 5,
		max = 20,
		softMin = 0,
		step = 1,
		get = function ()
				  return theme.layout.Padding
			  end,
		set = function (_, v)
				  theme.layout.Padding = v
				  Grid2Layout:RefreshLayout()
				  Grid2Options:LayoutTestRefresh()
			  end,
}, scale = {
		type = "range",
		name = L["Scale"],
		desc = L["Adjust Grid scale."],
		order = order_display + 6,
		min = 0.5,
		max = 2.0,
		step = 0.05,
		isPercent = true,
		get = function ()
				  return theme.layout.ScaleSize
			  end,
		set = function (_, v)
				  theme.layout.ScaleSize = v
				  Grid2Layout:Scale()
				  Grid2Options:LayoutTestRefresh()
			  end,
}, anchorheader = {
		type = "header",
		order = order_anchor,
		name = L["Position and Anchor"],
}, layoutanchor = {
		type = "select",
		name = L["Layout Anchor"],
		desc = L["Sets where Grid is anchored relative to the screen."],
		order = order_anchor + 1,
		get = function () return theme.layout.anchor end,
		set = function (_, v)
				  theme.layout.anchor = v
				  Grid2Layout:SavePosition()
				  Grid2Layout:RestorePosition()
			  end,
		values={["CENTER"] = L["CENTER"], ["TOP"] = L["TOP"], ["BOTTOM"] = L["BOTTOM"], ["LEFT"] = L["LEFT"], ["RIGHT"] = L["RIGHT"], ["TOPLEFT"] = L["TOPLEFT"], ["TOPRIGHT"] = L["TOPRIGHT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"] },
}, groupanchor = {
		type = "select",
		name = L["Group Anchor"],
		desc = L["Sets where groups are anchored relative to the layout frame."],
		order = order_anchor + 2,
		get = function () return theme.layout.groupAnchor end,
		set = function (_, v)
			theme.layout.groupAnchor = v
			Grid2Layout:RefreshLayout()
			Grid2Options:LayoutTestRefresh()
		end,
		values={["TOPLEFT"] = L["TOPLEFT"], ["TOPRIGHT"] = L["TOPRIGHT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"] },
}, positionx = {
		type = "range",
		name = L["Horizontal Position"],
		desc = L["Adjust Grid2 horizontal position."],
		order = order_anchor + 3,
		softMin = -2048,
		softMax = 2048,
		step = 1,
		get = function ()
			local screen_w, screen_h = GetPhysicalScreenSize()
			return math.floor( theme.layout.PosX * screen_w / (UIParent:GetWidth()*UIParent:GetEffectiveScale()) + 0.5 )
		end,
		set = function (_, v)
			local screen_w, screen_h = GetPhysicalScreenSize()
			theme.layout.PosX = v / (screen_w / (UIParent:GetWidth()*UIParent:GetEffectiveScale()))
			Grid2Layout:RestorePosition()
			Grid2Layout:SavePosition()
			Grid2Options:LayoutTestRefresh()	
		end,
}, positiony = {
		type = "range",
		name = L["Vertical Position"],
		desc = L["Adjust Grid2 vertical position."],
		order = order_anchor + 4,
		softMin = -2048,
		softMax = 2048,
		step = 1,
		get = function ()
			local screen_w, screen_h = GetPhysicalScreenSize()
			return math.floor( theme.layout.PosY * screen_h / (UIParent:GetHeight()*UIParent:GetEffectiveScale()) + 0.5 )
		end,
		set = function (_, v)
			local screen_w, screen_h = GetPhysicalScreenSize()
			theme.layout.PosY = v / (screen_h / (UIParent:GetHeight()*UIParent:GetEffectiveScale()))
			Grid2Layout:RestorePosition()
			Grid2Layout:SavePosition()
			Grid2Options:LayoutTestRefresh()
		end,
} }

--===============================================================================================

local frameOptions = { framewidth = {
		type = "range",
		order = 10,
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
			Grid2Options:LayoutTestRefresh()
		end,
		disabled = InCombatLockdown,
}, frameheight = {
		type = "range",
		order = 20,
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
			Grid2Options:LayoutTestRefresh()
		end,
		disabled = InCombatLockdown,
}, texture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 25,
		name = L["Background Texture"],
		desc = L["Select the frame background texture."],
		get = function (info) return theme.frame.frameTexture or "Gradient" end,
		set = function (info, v)
			theme.frame.frameTexture = v
			Grid2Frame:LayoutFrames(true)
		end,
		values = AceGUIWidgetLSMlists.statusbar,
}, borderDistance= {
		type = "range",
		name = L["Inner Border Size"],
		desc = L["Sets the size of the inner border of each unit frame"],
		min = -16,
		max = 16,
		step = 1,
		order = 27,
		get = function ()
			return theme.frame.frameBorderDistance
		end,
		set = function (_, v)
			theme.frame.frameBorderDistance = v
			Grid2Frame:LayoutFrames(true)
		end,
}, colorContent = {
		type = "color",
		order = 30,
		name = L["Background Color"],
		desc = L["Sets the background color of each unit frame"],
		get = function()
			local c= theme.frame.frameContentColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c= theme.frame.frameContentColor
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Frame:LayoutFrames(true)
			Grid2Frame:UpdateIndicators()
		 end,
		hasAlpha = true,

}, colorFrame = {
		type = "color",
		order = 40,
		name = L["Inner Border Color"],
		desc = L["Sets the color of the inner border of each unit frame"],
		get = function()
			local c= theme.frame.frameColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c= theme.frame.frameColor
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Frame:LayoutFrames(true)
		 end,
		hasAlpha = true,
}, mouseoverHighlight = {
		type = "toggle",
		name = L["Mouseover Highlight"],
		desc = L["Toggle mouseover highlight."],
		order = 60,
		get = function ()
			return theme.frame.mouseoverHighlight
		end,
		set = function (_, v)
			theme.frame.mouseoverHighlight = v
			Grid2Frame:LayoutFrames(true)
		end,
}, mouseoverColor = {
		type = "color",
		order = 70,
		name = L["Highlight Color"],
		desc = L["Sets the hightlight color of each unit frame"],
		get = function()
			local c = theme.frame.mouseoverColor
			return c.r, c.g, c.b, c.a
		end,
		set = function( info, r,g,b,a )
			local c = theme.frame.mouseoverColor
			c.r, c.g, c.b, c.a = r, g, b, a
			Grid2Frame:LayoutFrames(true)
		 end,
		hasAlpha = true,
		hidden = function() return not theme.frame.mouseoverHighlight end, 
}, mouseoverTexture = {
		type = "select", dialogControl = "LSM30_Background",
		order = 80,
		name = L["Highlight Texture"],
		desc = L["Sets the highlight border texture of each unit frame"],
		get = function (info) return theme.frame.mouseoverTexture or "Blizzard Quest Title Highlight" end,
		set = function (info, v)
			theme.frame.mouseoverTexture = v
			Grid2Frame:LayoutFrames(true)
		end,
		values = AceGUIWidgetLSMlists.background,
		hidden = function() return not theme.frame.mouseoverHighlight end, 
}, }

--===============================================================================================

local options = {
	layout = { type = "group", inline = true, order = 1, name = L["Layout"], desc = L["Layout"], args = layoutOptions },
	frame  = { type = "group", inline = true, order = 2, name = L["Frames"], desc = L["Frames"], args = frameOptions  },
}
Grid2Options:AddThemeOptions( "appearance", "Appearance", options )

-- Refresh theme general options the first time they are displayed, it's a workaround to a weird bug in AceConfig/AceGUI: 
-- sometimes all editboxes of sliders do not display any value, this only happens when we have 3 nested groups like in: 
-- "Themes>Default>General Tab>options width sliders", and clicking very fast to open general theme options.
options.bugfix = { type = "header", order = 500, name = "", hidden = function()	options.bugfix = nil; LibStub("AceConfigRegistry-3.0"):NotifyChange("Grid2"); return true end }
