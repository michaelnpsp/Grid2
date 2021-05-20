local L = Grid2Options.L

--==========================================================================
-- Multiple Themes Support
--==========================================================================

Grid2Options:AddGeneralOptions( "General", "Themes", {
	themes = {
		type = "toggle",
		name = L["Enable Themes"],
		desc = L["Enable support for multiple themes, allowing to define different visual styles for the Grid2 frames. General options will change and a new Themes section will be displayed."],
		width = "full",
		order = 5,
		get = function ()
			 return Grid2Frame.dba.profile.extraThemes ~= nil
		end,
		set = function (_, v)
			if v then
				Grid2Layout.dba.profile.extraThemes = {}
				Grid2Frame.dba.profile.extraThemes  = {}
			elseif #Grid2Frame.dba.profile.extraThemes==0 then
				Grid2Layout.dba.profile.extraThemes = nil
				Grid2Frame.dba.profile.extraThemes  = nil
			else
				Grid2Options:MessageDialog(L["Error: this option cannot be disabled because extra themes have been created. Remove the extra themes first."])
			end
		end,
	},
}, nil)

--==========================================================================
-- Text formatting
--==========================================================================

--[[
	Text formatting options for indicators durations&stacks
	General -> Misc Tab -> Text Formatting section

	Text formatting database variables and default values:
	Grid2.db.profile.formatting = {
		longDecimalFormat        = "%.1f",
		shortDecimalFormat       = "%.0f",
		longDurationStackFormat  = "%.1f:%d",
		shortDurationStackFormat = "%.0f:%d",
		invertDurationStack      = false,
		secondsElapsedFormat     = "%ds",
		minutesElapsedFormat     = "%dm",
	}
	shortFormat = used when duration >= 1 sec
	longFormat  = used when duration <  1 sec
	The database formats are translated to/from a more user friendly format, examples:
		"%.1f" <=> "%d"     "%.1f/%d"  <=> "%d/%s"
	User friendly format tokens:
		"%d" = represents duration, becomes translated to/from: "%.0f" or "%.1f" (floating point number)
		"%s" = represents stacks,   becomes translated to/from: "%d" (integer number)
--]]

-- Update text indicators database
local function UpdateTextIndicators()
	for _, indicator in Grid2:IterateIndicators("text") do
		indicator:UpdateDB()
	end
end

-- Posible values for "Display tenths of a second" options
local tenthsValues = { L["Never"], L["Always"] , L["When duration<1sec"] }

-- Retrieve a formatting mask from database.
-- The mask is converted to a user friendly format
-- formatType = "DecimalFormat" | "DurationStackFormat"
local function GetFormat(formatType)
	local dbx = Grid2.db.profile.formatting
	local mask = dbx[ "long".. formatType ]
	return mask:gsub("%%d","%%s"):gsub("%%.0f","%%d"):gsub("%%.1f","%%d")
end

-- Calculates tenths display mode examining format masks saved in database, returns:
-- 1 => Never display tenths  ( both shortFormat and longFormat containing a "%.0f" token )
-- 2 => Always display tenths ( both shortFormat and longFormat containing a "%.1f" token )
-- 3 => Display tenths when duraction<1sec (shortFormat contains "%.1f" and longFormat contains "%.0f")
local function GetTenths(formatType)
	local dbx   = Grid2.db.profile.formatting
	local short = dbx[ "short".. formatType ]
	local long  = dbx[ "long" .. formatType ]
	return (long:find("%%.0f") and 1) or (short:find("%%.1f") and 2) or 3
end

-- SetFormat(formatType, mask, tenths)
-- Generate a short and long format mask according to the user selections saving the masks in database
local SetFormat
do
	-- converts a user friendly mask to the database format
	local function ToDbFormat(formatType, mask, tenths)
		if formatType == "DecimalFormat" then
			local short = tenths==2 and "%%.1f" or "%%.0f"
			local long  = tenths==1 and "%%.0f" or "%%.1f"
			return (mask:gsub("%%d", short)), (mask:gsub("%%d", long))
		elseif formatType == "DurationStackFormat" then
			local i1 = mask:find("%%d")
			local i2 = mask:find("%%s")
			if i1 and i2 then
				local short, long = ToDbFormat("DecimalFormat", mask, tenths)
				return (short:gsub("%%s","%%d")), (long:gsub("%%s","%%d")), i1>i2
			end
		end
	end
	function SetFormat(formatType, mask, tenths)
		mask   = mask   or GetFormat(formatType)
		tenths = tenths or GetTenths(formatType)
		local short, long, inverted = ToDbFormat(formatType, mask, tenths)
		if short then
			-- sanity sheck, string.format will crash if format is wrong, and nothing is saved
			string.format(short, 1, 1); string.format(long , 1, 1)
			local dbx = Grid2.db.profile.formatting
			dbx["short"..formatType] = short
			dbx["long" ..formatType] = long
			if inverted ~= nil then	dbx.invertDurationStack = inverted end
			UpdateTextIndicators()
		end
	end
end

Grid2Options:AddGeneralOptions( "General", "Text Formatting", {
	dFormat = {
		type = "input",
		order = 1,
		name = L["Duration Format"],
		desc = L["Examples:\n(%d)\n%d seconds"],
		get = function() return GetFormat("DecimalFormat") end,
		set = function(_,v)	SetFormat("DecimalFormat", v, nil) end,
	},
	dTenths = {
		type = "select",
		order = 2,
		name = L["Display tenths of a second"],
		desc = L["Display tenths of a second"],
		get = function () return GetTenths("DecimalFormat") end,
		set = function (_, v) SetFormat("DecimalFormat", nil, v) end,
		values = tenthsValues,
	},
	separator1 = { type = "description", name = "", order = 3 },
	dsFormat = {
		type = "input",
		order = 4,
		name = L["Duration+Stacks Format"],
		desc = L["Examples:\n%d/%s\n%s(%d)"],
		get = function() return GetFormat("DurationStackFormat") end,
		set = function(_,v)	SetFormat("DurationStackFormat", v, nil) end,
	},
	dsTenths = {
		type = "select",
		order = 5,
		name = L["Display tenths of a second"],
		desc = L["Display tenths of a second"],
		get = function ()  return GetTenths("DurationStackFormat") end,
		set = function (_, v) SetFormat("DurationStackFormat", nil, v) end,
		values = tenthsValues
	},
	separator2 = { type = "description", name = "", order = 6 },
	secFormat = {
		type = "input",
		order = 7,
		name = L["Seconds Format"],
		desc = L["Examples:\n%ds\n%d seconds"],
		get = function()
			return Grid2.db.profile.formatting.secondsElapsedFormat
		end,
		set = function(_,v)
			string.format(v, 1) -- sanity check, crash if v is not a correct format mask
			Grid2.db.profile.formatting.secondsElapsedFormat  = v
			UpdateTextIndicators()
		end,
	},
	minFormat = {
		type = "input",
		order = 8,
		name = L["Minutes Format"],
		desc = L["Examples:\n%dm\n%d minutes"],
		get = function()
			return Grid2.db.profile.formatting.minutesElapsedFormat
		end,
		set = function(_,v)
			string.format(v, 1) -- sanity check, crash if v is not a correct format mask
			Grid2.db.profile.formatting.minutesElapsedFormat  = v
			UpdateTextIndicators()
		end,
	},
})

--==========================================================================
-- Blink
--==========================================================================

Grid2Options:AddGeneralOptions( "General", "blink", {
	effect = {
		type = "select",
		name = L["Blink effect"],
		desc = L["Select the type of Blink effect used by Grid2."],
		order = 10,
		get = function () return Grid2Frame.db.shared.blinkType end,
		set = function (_, v)
			Grid2Frame.db.shared.blinkType = v
			for _,indicator in ipairs(Grid2:GetIndicatorsSorted()) do
				if indicator.GetBlinkFrame then
					indicator:UpdateDB()
				end
			end
			Grid2Options:MakeStatusesOptions(Grid2Options.statusesOptions)
		end,
		values= { None = L["None"], Flash = L["Flash"] },
	},
	frequency = {
		type = "range",
		name = L["Blink Frequency"],
		desc = L["Adjust the frequency of the Blink effect."],
		disabled = function () return Grid2Frame.db.shared.blinkType == "None" end,
		min = 1,
		max = 10,
		step = .5,
		get = function ()
			return Grid2Frame.db.shared.blinkFrequency
		end,
		set = function (_, v)
			Grid2Frame.db.shared.blinkFrequency = v
			for _,indicator in ipairs(Grid2:GetIndicatorsSorted()) do
				if indicator.GetBlinkFrame then
					Grid2Frame:WithAllFrames(function (f)
						local anim = indicator:GetBlinkFrame(f).blinkAnim
						if anim then anim.settings:SetDuration(1/v) end
					end)
				end
			end
		end,
	},
})

--==========================================================================
-- Classic Auras Duration
--==========================================================================

if Grid2.isClassic then
	Grid2Options:AddGeneralOptions( "General", "Auras", {
		classicDurations = {
			type = "toggle",
			name = L["Enable Durations"],
			desc = L["Check this option to be able to display auras duration & expiration time."],
			width = "full",
			order = 115,
			get = function () return not Grid2.db.global.disableDurations end,
			set = function (_, v)
				Grid2.db.global.disableDurations = (not v) or nil
				ReloadUI()
			end,
			confirm = function() return L["UI must be reloaded to change this option. Are you sure?"] end,
		},
	})
end


--==========================================================================
-- Minimap
--==========================================================================

if Grid2Layout.minimapIcon then -- checks if Grid2LDB addon was loaded
	Grid2Options:AddGeneralOptions( "General", "Minimap Icon", {
		showMinimapIcon = {
			type = "toggle",
			name = L["Show Minimap Icon"],
			desc = L["Show Minimap Icon"],
			width = "full",
			order = 119,
			get = function () return not Grid2Layout.db.shared.minimapIcon.hide end,
			set = function (_, v)
				Grid2Layout.db.shared.minimapIcon.hide = not v
				if v then
					Grid2Layout.minimapIcon:Show("Grid2")
				else
					Grid2Layout.minimapIcon:Hide("Grid2")
				end
			end,
		},
	})
end


--==========================================================================
-- Hide blizzard raid frames
--==========================================================================

do
	local addons = { "Blizzard_CompactRaidFrames", "Blizzard_CUFProfiles" }

	Grid2Options:AddGeneralOptions( "General", "Blizzard Raid Frames", {
		hideBlizzardRaidFrames = {
			type = "toggle",
			name = L["Hide Blizzard Raid Frames"],
			desc = L["Hide Blizzard Raid Frames"],
			width = "full",
			order = 120,
			get = function () return not IsAddOnLoaded( addons[1] ) end,
			set = function (_, v)
				local func = v and DisableAddOn or EnableAddOn
				for _, v in pairs(addons) do
					func(v)
				end
				ReloadUI()
			end,
			confirm = function() return "UI will be reloaded. Are your sure ?" end,
		},
	})
end

--==========================================================================
-- Load on demand
--==========================================================================

Grid2Options:AddGeneralOptions( "General", "Options management", {
	loadOnDemand = {
		type = "toggle",
		name = L["Load options on demand (requires UI reload)"],
		desc = L["OPTIONS_ONDEMAND_DESC"],
		width = "full",
		order = 150,
		get = function () return not Grid2.db.global.LoadOnDemandDisabled end,
		set = function (_, v)
			Grid2.db.global.LoadOnDemandDisabled = (not v) or nil
		end,
	},
})
