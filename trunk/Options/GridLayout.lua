--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local media = LibStub("LibSharedMedia-3.0", true)


local raidTypesOptions= {}

local function MakeLayoutSettingsOptions()
	local ORDER_LAYOUT = 20
	local ORDER_DISPLAY = 30
	local ORDER_ANCHOR = 40
	local layoutOptions= {
		["display"] = {
			type = "select",
			name = L["Show Frame"],
			desc = L["Sets when the Grid is visible: Choose 'Always', 'Grouped', or 'Raid'."],
			order = ORDER_LAYOUT + 10,
			get = function() return Grid2Layout.db.profile.FrameDisplay end,
			set = function(_, v)
				Grid2Layout.db.profile.FrameDisplay = v
				Grid2Layout:CheckVisibility()
			end,
			values={["Always"] = L["Always"], ["Grouped"] = L["Grouped"], ["Raid"] = L["Raid"]},
		},
		["horizontal"] = {
			type = "toggle",
			name = L["Horizontal groups"],
			desc = L["Switch between horzontal/vertical groups."],
			order = ORDER_LAYOUT + 4,
			get = function ()
					  return Grid2Layout.db.profile.horizontal
				  end,
			set = function ()
					  Grid2Layout.db.profile.horizontal = not Grid2Layout.db.profile.horizontal
					  Grid2Layout:ReloadLayout()
					  Grid2Options:LayoutTestRefresh()
				  end,
		},
		["lock"] = {
			type = "toggle",
			name = L["Frame lock"],
			desc = L["Locks/unlocks the grid for movement."],
			order = ORDER_LAYOUT + 6,
			get = function() return Grid2Layout.db.profile.FrameLock end,
			set = function()
				Grid2Layout:FrameLock()
			end,
		},
		["clickthrough"] = {
			type = "toggle",
			name = L["Click through the Grid Frame"],
			desc = L["Allows mouse click through the Grid Frame."],
			order = ORDER_LAYOUT + 7,
			get = function() return Grid2Layout.db.profile.ClickThrough end,
			set = function()
				local v = not Grid2Layout.db.profile.ClickThrough
				Grid2Layout.db.profile.ClickThrough = v
				Grid2Layout.frame:EnableMouse(not v)
			end,
			disabled = function () return not Grid2Layout.db.profile.FrameLock end,
		},
		["DisplayHeader"] = {
			type = "header",
			order = ORDER_DISPLAY,
			name = L["Display"],
		},
		["padding"] = {
			type = "range",
			name = L["Padding"],
			desc = L["Adjust frame padding."],
			order = ORDER_DISPLAY + 1,
			max = 20,
			min = 0,
			step = 1,
			get = function ()
					  return Grid2Layout.db.profile.Padding
				  end,
			set = function (_, v)
					  Grid2Layout.db.profile.Padding = v
					  Grid2Layout:ReloadLayout()
				  end,
		},
		["spacing"] = {
			type = "range",
			name = L["Spacing"],
			desc = L["Adjust frame spacing."],
			order = ORDER_DISPLAY + 2,
			max = 25,
			min = 0,
			step = 1,
			get = function ()
					  return Grid2Layout.db.profile.Spacing
				  end,
			set = function (_, v)
					  Grid2Layout.db.profile.Spacing = v
					  Grid2Layout:ReloadLayout()
				  end,
		},
		["scale"] = {
			type = "range",
			name = L["Scale"],
			desc = L["Adjust Grid scale."],
			order = ORDER_DISPLAY + 3,
			min = 0.5,
			max = 2.0,
			step = 0.05,
			isPercent = true,
			get = function ()
					  return Grid2Layout.db.profile.ScaleSize
				  end,
			set = function (_, v)
					  Grid2Layout.db.profile.ScaleSize = v
					  Grid2Layout:Scale()
				  end,
		},
		["border"] = {
			type = "color",
			name = L["Border Color"],
			desc = L["Adjust border color and alpha."],
			order = ORDER_DISPLAY + 5,
			get = function ()
					  local settings = Grid2Layout.db.profile
					  return settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA
				  end,
			set = function (_, r, g, b, a)
					  local settings = Grid2Layout.db.profile
					  settings.BorderR, settings.BorderG, settings.BorderB, settings.BorderA = r, g, b, a
					  Grid2Layout:UpdateColor()
				  end,
			hasAlpha = true
		},
		["background"] = {
			type = "color",
			name = L["Background Color"],
			desc = L["Adjust background color and alpha."],
			order = ORDER_DISPLAY + 6,
			get = function ()
					  local settings = Grid2Layout.db.profile
					  return settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA
				  end,
			set = function (_, r, g, b, a)
					  local settings = Grid2Layout.db.profile
					  settings.BackgroundR, settings.BackgroundG, settings.BackgroundB, settings.BackgroundA = r, g, b, a
					  Grid2Layout:UpdateColor()
				  end,
			hasAlpha = true
		},
		["AnchorHeader"] = {
			type = "header",
			order = ORDER_ANCHOR,
			name = L["Position and Anchor"],
		},
		["layoutanchor"] = {
			type = "select",
			name = L["Layout Anchor"],
			desc = L["Sets where Grid is anchored relative to the screen."],
			order = ORDER_ANCHOR + 1,
			get = function () return Grid2Layout.db.profile.anchor end,
			set = function (_, v)
					  Grid2Layout.db.profile.anchor = v
					  Grid2Layout:SavePosition()
					  Grid2Layout:RestorePosition()
				  end,
			values={["CENTER"] = L["CENTER"], ["TOP"] = L["TOP"], ["BOTTOM"] = L["BOTTOM"], ["LEFT"] = L["LEFT"], ["RIGHT"] = L["RIGHT"], ["TOPLEFT"] = L["TOPLEFT"], ["TOPRIGHT"] = L["TOPRIGHT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"] },
		},
		["groupanchor"] = {
			type = "select",
			name = L["Group Anchor"],
			desc = L["Sets where groups are anchored relative to the layout frame."],
			order = ORDER_ANCHOR + 2,
			get = function () return Grid2Layout.db.profile.groupAnchor end,
			set = function (_, v)
					  Grid2Layout.db.profile.groupAnchor = v
					  Grid2Layout:ReloadLayout()
					  Grid2Options:LayoutTestRefresh()
				  end,
			values={["TOPLEFT"] = L["TOPLEFT"], ["TOPRIGHT"] = L["TOPRIGHT"], ["BOTTOMLEFT"] = L["BOTTOMLEFT"], ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"] },
		},
		["clamp"] = {
			type = "toggle",
			name = L["Clamped to screen"],
			desc = L["Toggle whether to permit movement out of screen."],
			order = ORDER_ANCHOR + 3,
			get = function ()
					  return Grid2Layout.db.profile.clamp
				  end,
			set = function ()
					  Grid2Layout.db.profile.clamp = not Grid2Layout.db.profile.clamp
					  Grid2Layout:SetClamp()
				  end,
		},
		["reset"] = {
			type = "execute",
			name = L["Reset"],
			desc = L["Resets the layout frame's position and anchor."],
			order = ORDER_ANCHOR + 4,
			func = function () Grid2Layout:ResetPosition() end,
		},
	}
	if Grid2Options.AddMediaOption then
		layoutOptions["borderTexture"]= {
			type = "select",
			order = ORDER_DISPLAY + 4,
			name = L["Border Texture"],
			desc = L["Adjust the border texture."],
			get = function (info)
				local v = Grid2Layout.db.profile.BorderTexture
				for i, t in ipairs(info.option.values) do
					if v == t then return i end
				end
			end,
			set = function (info, v)
				Grid2Layout.db.profile.BorderTexture= info.option.values[v]
				Grid2Layout:UpdateTextures()
				Grid2Layout:UpdateColor()
			end,
		}
		Grid2Options:AddMediaOption("border", layoutOptions.borderTexture)
	end
	return layoutOptions
end
	
	
local function MakeLayoutsGeneralOptions(options)

	local ORDER= 10

	local function MakeLayoutRaidTypeOption(options, raidType, name, desc )
		options[raidType]= {
			type = "select",
			name = name and L[name] or L["Raid %s Layout"]:format( strsub(raidType,-2) ),
			desc = desc and L[desc] or L["Select which layout to use for %s person raids."]:format( strsub(raidType,-2) ),
			order = ORDER+5,
			width = "double",	
			get = function ()
				return Grid2Layout.db.profile.layouts[raidType]
			end,
			set = function (_, v)
				Grid2Layout.db.profile.layouts[raidType] = v
				if Grid2Layout.partyType == raidType then
					Grid2Layout:LoadLayout(v)
				end
			end,
			values = Grid2Options:GetLayouts( raidType ),
		}
		options[raidType.."Test"] = {
			type = "execute",
			name = L["Test"],
			width= "half",
			desc = L["Test the layout."],
			order = ORDER+10,
			func = function(info) Grid2Options:LayoutTestEnable( Grid2Layout.db.profile.layouts[raidType], raidType ) end,
			disabled = InCombatLockdown,
		}		
		options[raidType.."sep"] = {
		  type= "description",  name= "",  order= ORDER + 99
		}
		
		ORDER = ORDER + 100
	end
	
	options= options or {}
	MakeLayoutRaidTypeOption(options, "solo"  , "Solo Layout" , "Select which layout to use for solo." )
	MakeLayoutRaidTypeOption(options, "party" , "Party Layout", "Select which layout to use for party." )
	MakeLayoutRaidTypeOption(options, "arena" , "Arena Layout", "Select which layout to use for arenas." )
	MakeLayoutRaidTypeOption(options, "raid10" )
	MakeLayoutRaidTypeOption(options, "raid15" )
	MakeLayoutRaidTypeOption(options, "raid20" )
	MakeLayoutRaidTypeOption(options, "raid25" )
	MakeLayoutRaidTypeOption(options, "raid40" )	
	MakeLayoutRaidTypeOption(options, "pvp"   , "Battleground Layout", "Select which layout to use for battlegrounds." )
	return options
end	
	
function Grid2Options:RefreshLayoutsOptions()
	for raidType,option in pairs(raidTypesOptions) do
		if option.type=="select" and option.values then
			option.values = Grid2Options:GetLayouts( raidType )
		end
	end
end	

function Grid2Options:MakeLayoutOptions(reset)
	wipe(raidTypesOptions)
	Grid2Options:AddModuleOptions( "General" , "Layout Settings", MakeLayoutSettingsOptions() )
	local general = {
		type = "group",
		order= 200,
		name = L["General"],
		args =  MakeLayoutsGeneralOptions(raidTypesOptions),
	}
	local advanced = {
		type = "group",
		order= 201,
		name = L["Advanced"],
		args = Grid2Options:MakeCustomLayoutOptions(),
		
	}
	Grid2Options:AddModuleOptions( "Layouts", nil, {
		type = "group",
		childGroups= "tab",
		name = L["Layouts"],
		args = { general = general,	advanced = advanced	},	
	})
end	
	
--}}}
