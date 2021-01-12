local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("name", "misc", function(self, status, options, optionParams)
	options.emptyUnitsSource = {
		type  = "select",
		order = 10,
		name  = L["Default Name"],
		desc  = L["Select the text to display when the unit name is not available."],
		get   = function ()
			return (status.dbx.defaultName==1 and 1) or (status.dbx.defaultName and 2) or 3
		end,
		set   = function (_, v)
			status.dbx.defaultName = (v==1 and 1) or (v==2 and L['N/A']) or nil
			status:UpdateDB()
			Grid2Frame:WithAllFrames( function(f) if f:IsVisible() then f:UpdateIndicators() end end )
		end,
		values= { L["Unit Tag"], L["Custom Text"], L["Nothing"] }
	}
	options.emptyUnitsName = {
		type = "input",
		order = 20,
		name = L["Custom Text"],
		desc = L["Custom Text"],
		get = function ()
			return status.dbx.defaultName
		end,
		set = function (_, v)
			status.dbx.defaultName = v
			status:UpdateDB()
			Grid2Frame:WithAllFrames( function(f) if f:IsVisible() then f:UpdateIndicators() end; end )
		end,
		hidden = function() return type(status.dbx.defaultName)~='string' end,
	}
	options.transliterate = {
		type  = "toggle",
		order = 30,
		width = "full",
		name  = L["Transliterate cyrillic letters"],
		desc  = L["Convert cyrillic letters to latin alphabet."],
		get   = function ()	return status.dbx.enableTransliterate end,
		set   = function (_, v)
			status.dbx.enableTransliterate = v or nil
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}
end )
