local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
--{{{  Grid2Frame AceOptions table

Grid2Frame.menuName = L["frame"]
Grid2Frame.menuOrder = 20

Grid2Options:AddModule("Grid2", "Grid2Frame", Grid2Frame, {
	["tooltip"] = {
		type = "select",
		order = 10,
		name = L["Show Tooltip"],
		desc = L["Show unit tooltip.  Choose 'Always', 'Never', or 'OOC'."],
		get = function ()
			return Grid2Frame.db.profile.showTooltip
		end,
		set = function (_, v)
			Grid2Frame.db.profile.showTooltip = v
		end,
		values={["Always"] = L["Always"], ["Never"] = L["Never"], ["OOC"] = L["OOC"]},
	},
	["frameBorder"] = {
		type = "range",
		order = 20,
		name = L["Border Size"],
		desc = L["Adjust the border of each unit's frame."],
		min = 1,
		max = 8,
		step = 1,
		get = function ()
				  return Grid2Frame.db.profile.frameBorder
			  end,
		set = function (_, frameBorder)
			Grid2Frame.db.profile.frameBorder = frameBorder
			Grid2Frame:WithAllFrames(function (f)
				f:SetBackdrop({
					bgFile = "Interface\\Addons\\Grid2\\white16x16", tile = true, tileSize = 16,
					edgeFile = "Interface\\Addons\\Grid2\\white16x16", edgeSize = frameBorder,
					insets = {left = frameBorder, right = frameBorder, top = frameBorder, bottom = frameBorder},
				})
				f:LayoutIndicators()
			end)
		end,
		disabled = InCombatLockdown,
	},
	["framewidth"] = {
		type = "range",
		order = 30,
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
		disabled = InCombatLockdown,
	},
	["frameheight"] = {
		type = "range",
		order = 40,
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
		disabled = InCombatLockdown,
	},
})

--}}}
