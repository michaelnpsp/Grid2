local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local media = LibStub("LibSharedMedia-3.0", true)

local function AddTextIndicatorOptions(Text)
	local options = {
		textlength = {
			type = "range",
			name = L["Center Text Length"],
			desc = L["Number of characters to show on Center Text indicator."],
			order = 11,
			min = 0,
			max = 20,
			step = 1,
			get = function () return Text.db.profile.textlength end,
			set = function (_, v)
				Text.db.profile.textlength = v
				Grid2Frame:UpdateAllFrames()
			end,
		},
		fontsize = {
			type = "range",
			name = L["Font Size"],
			desc = L["Adjust the font size."],
			min = 6,
			max = 24,
			step = 1,
			get = function ()
				return Text.db.profile.fontSize
			end,
			set = function (_, v)
				Text.db.profile.fontSize = v
				local font = media and media:Fetch('font', Text.db.profile.font) or STANDARD_TEXT_FONT
				Grid2Frame:WithAllFrames(function (f) Text:SetTextFont(f, font, v) end)
			end,
		},
	}

	if Grid2Options.AddMediaOption then
		local fontOption = {
			type = "select",
			name = L["Font"],
			desc = L["Adjust the font settings"],
			get = function ()
				return Text.db.profile.font
			end,
			set = function (_, v)
				Text.db.profile.font = v
				local font = media:Fetch("font", v)
				local fontsize = Text.db.profile.fontSize
				Grid2Frame:WithAllFrames(function (f) Text:SetTextFont(f, font, fontsize) end)
			end,
		}
		Grid2Options:AddMediaOption("font", fontOption)
		options.font = fontOption
	end

	Grid2Options:AddElement("indicator", Text, options)
end

local function AddBarIndicatorOptions(Bar)
	local options = {
		orientation = {
			type = "select",
			name = L["Orientation of Frame"],
			desc = L["Set frame orientation."],
			get = function ()
				return Bar.db.profile.orientation
			end,
			set = function (_, v)
				Bar.db.profile.orientation = v
				Grid2Frame:WithAllFrames(function (f) Bar:SetOrientation(f) end)
			end,
			values={["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
		},
	}

	if Grid2Options.AddMediaOption then
		local textureOption = {
			type = "select",
			name = L["Frame Texture"],
			desc = L["Adjust the texture of each unit's frame."],
			get = function (info)
				local v = Bar.db.profile.texture
				for i, t in ipairs(info.option.values) do
					if v == t then return i end
				end
			end,
			set = function (info, v)
				v = info.option.values[v]
				Bar.db.profile.texture = v
				local texture = media:Fetch("statusbar", v)
				Grid2Frame:WithAllFrames(function (f) Bar:SetTexture(f, texture) end)
			end,
		}
		Grid2Options:AddMediaOption("statusbar", textureOption)
		options.texture = textureOption
	end

	Grid2Options:AddElement("indicator", Bar, options)
end

local function AddIconIndicatorOptions(Icon)
	Grid2Options:AddElement("indicator", Icon, {
		iconsize = {
			type = "range",
			name = L["Icon Size"],
			desc = L["Adjust the size of the center icon."],
			min = 5,
			max = 50,
			step = 1,
			get = function ()
				return Icon.db.profile.iconSize
			end,
			set = function (_, v)
				Icon.db.profile.iconSize = v
				Grid2Frame:WithAllFrames(function (f) Icon:SetIconSize(f, v) end)
			end,
		},
	})
end

local function AddCornerIndicatorOptions(Corner)
	Grid2Options:AddElement("indicator", Corner, {
		cornersize = {
			type = "range",
			name = L["Corner Size"],
			desc = L["Adjust the size of the corner indicators."],
			min = 1,
			max = 20,
			step = 1,
			get = function ()
				return Corner.db.profile.cornerSize
			end,
			set = function (_, v)
				Corner.db.profile.cornerSize = v
				Grid2Frame:WithAllFrames(function (f) Corner:SetCornerSize(f, v) end)
			end,
		},
	})
end

local function AddBarColorIndicatorOptions(BarColor)
	Grid2Options:AddElement("indicator", BarColor, {
		invert = {
			type = "toggle",
			name = L["Invert Bar Color"],
			desc = L["Swap foreground/background colors on bars."],
			order = 12,
			get = function ()
				return BarColor.db.profile.invertBarColor
			end,
			set = function (_, v)
				BarColor.db.profile.invertBarColor = v
				Grid2Frame:WithAllFrames(function (f) BarColor:Update(f, f.unit) end)
			end,
		},
	})
end

AddTextIndicatorOptions(Grid2.indicators["text-up"])
AddTextIndicatorOptions(Grid2.indicators["text-down"])
AddBarIndicatorOptions(Grid2.indicators["bar-health"])
AddBarColorIndicatorOptions(Grid2.indicators["bar-health-color"])
AddBarIndicatorOptions(Grid2.indicators["bar-heals"])
AddBarColorIndicatorOptions(Grid2.indicators["bar-heals-color"])
AddIconIndicatorOptions(Grid2.indicators["icon-center"])
AddCornerIndicatorOptions(Grid2.indicators["corner-bottomleft"])
AddCornerIndicatorOptions(Grid2.indicators["corner-bottomright"])
AddCornerIndicatorOptions(Grid2.indicators["corner-topright"])
AddCornerIndicatorOptions(Grid2.indicators["corner-topleft"])
