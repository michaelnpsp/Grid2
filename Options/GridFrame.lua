local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
--{{{  Grid2Frame AceOptions table

Grid2Frame.menuName = L["frame"]
Grid2Frame.menuOrder = 20

Grid2Options:AddModule("Grid2", "Grid2Frame", Grid2Frame, {
	["tooltip"] = {
		type = "select",
		name = L["Show Tooltip"],
		desc = L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."],
		order = 10,
		get = function ()
			return Grid2Frame.db.profile.showTooltip
		end,
		set = function (_, v)
			Grid2Frame.db.profile.showTooltip = v
		end,
		values={["Always"] = L["Always"], ["Never"] = L["Never"], ["OOC"] = L["OOC"]},
	},
	["advanced"] = {
		type = "group",
		name = L["Advanced"],
		desc = L["Advanced options."],
		order = -1,
		disabled = InCombatLockdown,
		args = {
			["framewidth"] = {
				type = "range",
				name = L["Frame Width"],
				desc = L["Adjust the width of each unit's frame."],
				min = 10,
				max = 100,
				step = 1,
				get = function ()
						  return Grid2Frame.db.profile.frameWidth
					  end,
				set = function (_, v)
						  Grid2Frame.db.profile.frameWidth = v
						  Grid2Frame:ResizeAllFrames()
					  end,
			},
			["frameheight"] = {
				type = "range",
				name = L["Frame Height"],
				desc = L["Adjust the height of each unit's frame."],
				min = 10,
				max = 100,
				step = 1,
				get = function ()
						  return Grid2Frame.db.profile.frameHeight
					  end,
				set = function (_, v)
						  Grid2Frame.db.profile.frameHeight = v
						  Grid2Frame:ResizeAllFrames()
					  end,
			},
		},
	},
})

--}}}
