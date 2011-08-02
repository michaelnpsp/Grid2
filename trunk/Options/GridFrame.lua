--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")

function Grid2Options:MakeFrameOptions(reset)
local options= {
		mouseoverHighlight = {
			type = "toggle",
			name = L["Mouseover Highlight"],
			desc = L["Toggle mouseover highlight."],
			order = 59,
			get = function ()
				return Grid2Frame.db.profile.mouseoverHighlight
			end,
			set = function (_, v)
				Grid2Frame.db.profile.mouseoverHighlight = v
				Grid2Frame:LayoutFrames()
			end,
		},
		tooltip = {
			type = "select",
			order = 55,
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
				Grid2Frame:LayoutFrames()
				Grid2Layout:UpdateHeadersSize()
				Grid2Layout:UpdateSize()
				Grid2Options:LayoutTestRefresh()
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
				Grid2Frame:LayoutFrames()
				Grid2Layout:UpdateHeadersSize()
				Grid2Layout:UpdateSize()
				Grid2Options:LayoutTestRefresh()
			end,
			disabled = InCombatLockdown,
		},
		orientation = {
			type = "select",
			order = 5,
			name = L["Orientation of Frame"],
			desc = L["Set frame orientation."],
			get = function ()
				return Grid2Frame.db.profile.orientation
			end,
			set = function (_, v)
				Grid2Frame.db.profile.orientation = v
				for _, indicator in Grid2:IterateIndicators() do
					if indicator.SetOrientation and indicator.orientation==nil then
						Grid2Frame:WithAllFrames(function (f) indicator:SetOrientation(f) end)
					end
				end
			end,
			values={["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
		},
		borderDistance= {
			type = "range",
			name = L["Inner Border Size"],
			desc = L["Sets the size of the inner border of each unit frame"],
			min = -16,
			max = 16,
			step = 1,
			order = 58,
			get = function ()
				return Grid2Frame.db.profile.frameBorderDistance
			end,
			set = function (_, v)
				Grid2Frame.db.profile.frameBorderDistance = v
				Grid2Frame:LayoutFrames()
			end,
		},		
		colorFrame = {
			type = "color",
			order = 59,
			name = L["Inner Border Color"],
			desc = L["Sets the color of the inner border of each unit frame"],
			get = function()
				local c= Grid2Frame.db.profile.frameColor
				return c.r, c.g, c.b, c.a
			end,
			set = function( info, r,g,b,a )
				local c= Grid2Frame.db.profile.frameColor
				c.r, c.g, c.b, c.a = r, g, b, a
				Grid2Frame:LayoutFrames()
			 end, 
			hasAlpha = true,
		},
		colorContent = {
			type = "color",
			order = 57,
			name = L["Background Color"],
			desc = L["Sets the background color of each unit frame"],
			get = function()
				local c= Grid2Frame.db.profile.frameContentColor
				return c.r, c.g, c.b, c.a
			end,
			set = function( info, r,g,b,a )
				local c= Grid2Frame.db.profile.frameContentColor
				c.r, c.g, c.b, c.a = r, g, b, a
				Grid2Frame:LayoutFrames()
			 end, 
			hasAlpha = true,
		}		
	}
	if Grid2Options.AddMediaOption then
		local textureOption = {
			type = "select",
			order = 54,
			name = L["Background Texture"],
			desc = L["Select the frame background texture."],
			get = function (info)
				local v = Grid2Frame.db.profile.frameTexture
				for i, t in ipairs(info.option.values) do
					if v == t then return i end
				end
			end,
			set = function (info, v)
				Grid2Frame.db.profile.frameTexture = info.option.values[v]
				Grid2Frame:LayoutFrames()
			end,
		}
		Grid2Options:AddMediaOption("statusbar", textureOption)
		options.texture = textureOption
	end
	
	Grid2Options:AddModuleOptions("General", "Frames", options)
	
end

-- Force GridLayoutHeaders size recalculation. Called from Grid2Options when frames width or height changes. 
-- Without this, UpdateSize calculates wrong layout size because g:GetWidth/g:GetHeight dont return correct values.
-- TODO: A better way to fix this issue ?
function Grid2Layout:UpdateHeadersSize()
	for type, headers in pairs(self.groups) do
		for i = 1, self.indexes[type] do
			local g = headers[i]
			g:Hide()
			g:Show()
		end
	end
end

