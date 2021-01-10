local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("name", "misc", function(self, status, options, optionParams)
	options.transliterate = {
		type  = "toggle",
		order = 10,
		width = "full",
		name  = L["Transliterate Names"],
		desc  = L["Convert cyrillic letters to latin alphabet."],
		get   = function ()	return status.dbx.enableTransliterate end,
		set   = function (_, v)
			status.dbx.enableTransliterate = v or nil
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}
end )
