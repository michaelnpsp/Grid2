local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
--{{{  Grid2Layout AceOptions table

local ORDER_LAYOUT = 20
local ORDER_DISPLAY = 30
local ORDER_ANCHOR = 40

Grid2Layout.menuName = L["layout"]
Grid2Layout.menuOrder = 10

Grid2Options:AddModule("Grid2", "Grid2Layout", Grid2Layout, {
	--FixMe: I'm pretty sure this would look nicer if it were flat. And I reckon there's too many options here
	["layoutsettings"] = {
		type = "group",
		name = L["Layout Settings"],
		desc = L["Layout Settings"],
		order = ORDER_LAYOUT + 1,
		args = {
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
				name = L["Border"],
				desc = L["Adjust border color and alpha."],
				order = ORDER_DISPLAY + 4,
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
				name = L["Background"],
				desc = L["Adjust background color and alpha."],
				order = ORDER_DISPLAY + 5,
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
		},
	},
	["layouts"] = {
		type = "group",
		name = L["Layouts"],
		desc = L["Layouts for each type of groups you're in."],
		order = ORDER_LAYOUT + 20,
		args = {
			solo = {
				type = "select",
				name = L["Solo Layout"],
				desc = L["Select which layout to use for solo."],
				order = 1,
				get = function ()
						  return Grid2Layout.db.profile.layouts.solo
					  end,
				set = function (_, v)
						  Grid2Layout.db.profile.layouts.solo = v
						  if Grid2Layout.partyType == "solo" then
							Grid2Layout:LoadLayout(v)
						  end
					  end,
				values = {},
			},
			party = {
				type = "select",
				name = L["Party Layout"],
				desc = L["Select which layout to use for party."],
				order = 2,
				get = function ()
					return Grid2Layout.db.profile.layouts.party
				end,
				set = function (_, v)
					Grid2Layout.db.profile.layouts.party = v
					if Grid2Layout.partyType == "party" then
						Grid2Layout:LoadLayout(v)
					end
				end,
				values = {},
			},
			arena = {
				type = "select",
				name = L["Arena Layout"],
				desc = L["Select which layout to use for arenas."],
				order = 3,
				get = function ()
					return Grid2Layout.db.profile.layouts.arena
				end,
				set = function (_, v)
					Grid2Layout.db.profile.layouts.arena = v
					if Grid2Layout.partyType == "arena" then
						Grid2Layout:LoadLayout(v)
					end
				end,
				values = {},
			},
			raid10 = {
				type = "select",
				name = L["Raid %s Layout"]:format(10),
				desc = L["Select which layout to use for %s person raids."]:format(10),
				order = 4,
				get = function ()
					return Grid2Layout.db.profile.layouts.raid10
				end,
				set = function (_, v)
					Grid2Layout.db.profile.layouts.raid10 = v
					if Grid2Layout.partyType == "raid10" then
						Grid2Layout:LoadLayout(v)
					end
				end,
				values = {},
			},
			raid15 = {
				type = "select",
				name = L["Raid %s Layout"]:format(15),
				desc = L["Select which layout to use for %s person raids."]:format(15),
				order = 5,
				get = function ()
					return Grid2Layout.db.profile.layouts.raid15
				end,
				set = function (_, v)
					Grid2Layout.db.profile.layouts.raid15 = v
					if Grid2Layout.partyType == "raid15" then
						Grid2Layout:LoadLayout(v)
					end
				end,
				values = {},
			},
			raid20 = {
				type = "select",
				name = L["Raid %s Layout"]:format(20),
				desc = L["Select which layout to use for %s person raids."]:format(20),
				order = 6,
				get = function ()
					return Grid2Layout.db.profile.layouts.raid20
				end,
				set = function (_, v)
					Grid2Layout.db.profile.layouts.raid20 = v
					if Grid2Layout.partyType == "raid20" then
						Grid2Layout:LoadLayout(v)
					end
				end,
				values = {},
			},
			raid25 = {
				type = "select",
				name = L["Raid %s Layout"]:format(25),
				desc = L["Select which layout to use for %s person raids."]:format(25),
				order = 7,
				get = function ()
					return Grid2Layout.db.profile.layouts.raid25
				end,
				set = function (_, v)
					Grid2Layout.db.profile.layouts.raid25 = v
					if Grid2Layout.partyType == "raid25" then
						Grid2Layout:LoadLayout(v)
					end
				end,
				values = {},
			},
			raid40 = {
				type = "select",
				name = L["Raid %s Layout"]:format(40),
				desc = L["Select which layout to use for %s person raids."]:format(40),
				order = 8,
				get = function ()
					return Grid2Layout.db.profile.layouts.raid40
				end,
				set = function (_, v)
					Grid2Layout.db.profile.layouts.raid40 = v
					if Grid2Layout.partyType == "raid40" then
						Grid2Layout:LoadLayout(v)
					end
				end,
				values = {},
			},
			pvp = {
				type = "select",
				name = L["Battleground Layout"],
				desc = L["Select which layout to use for battlegrounds."],
				order = 9,
				get = function ()
					return Grid2Layout.db.profile.layouts.pvp
				end,
				set = function (_, v)
					Grid2Layout.db.profile.layouts.pvp = v
					if Grid2Layout.partyType == "pvp" then
						Grid2Layout:LoadLayout(v)
					end
				end,
				values = {},
			},
		},
	},

})


--}}}
