local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("name", "misc", function(self, status, options, optionParams)
	options.emptyUnitsSource = {
		type  = "select",
		order = 10,
		name  = L["Empty Units Name"],
		desc  = L["Select the name to display for non existent units."],
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
end )
