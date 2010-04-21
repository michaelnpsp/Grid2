local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local DBL = LibStub:GetLibrary("LibDBLayers-1.0")

Grid2Frame.menuName = L["frame"]
Grid2Frame.menuOrder = 20

Grid2Options:AddModule("Grid2", "Grid2Frame", Grid2Frame, {
	mouseoverHighlight = {
		type = "toggle",
		name = L["Mouseover Highlight"],
		desc = L["Toggle mouseover highlight."],
		order = 10,
		get = function ()
			return Grid2Frame.db.profile.mouseoverHighlight
		end,
		set = function (_, v)
			Grid2Frame.db.profile.mouseoverHighlight = v
			Grid2Frame:WithAllFrames(function(f)
				f:EnableMouseoverHighlight(v)
			end)
		end,
	},
	tooltip = {
		type = "select",
		order = 15,
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
	frameBorder = {
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
	framewidth = {
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
	frameheight = {
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
	orientationHeader = {
		type = "header",
		order = 50,
		name = "",
	},
	orientation = {
		type = "select",
		order = 51,
		name = L["Orientation of Frame"],
		desc = L["Set frame orientation."],
		get = function ()
			return Grid2Frame.db.profile.orientation
		end,
		set = function (_, v)
			Grid2Frame.db.profile.orientation = v
			local indicator = Grid2.indicators["health"]
			Grid2Frame:WithAllFrames(function (f) indicator:SetOrientation(f) end)
			indicator = Grid2.indicators["heals"]
			Grid2Frame:WithAllFrames(function (f) indicator:SetOrientation(f) end)
		end,
		values={["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
	},
	invert = {
		type = "toggle",
		order = 12,
		name = L["Invert Bar Color"],
		desc = L["Swap foreground/background colors on bars."],
		tristate = true,
		get = function ()
			return Grid2Frame.db.profile.invertBarColor
		end,
		set = function (_, v)
			Grid2Frame.db.profile.invertBarColor = v
			Grid2.indicators["health-color"]:UpdateDB()
			Grid2Frame:WithAllFrames(function (f)
				Grid2:InterleaveHealsHealth(f)
			end)
			Grid2Frame:Reset()
		end,
	},
})

