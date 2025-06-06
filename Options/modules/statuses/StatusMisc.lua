-- statuses with very simple options has been grouped in this file

local L = Grid2Options.L
local LG = Grid2Options.LG

Grid2Options:RegisterStatusOptions("voice", "misc", nil, {
	titleIcon = "Interface\\COMMON\\VOICECHAT-SPEAKER"
})

Grid2Options:RegisterStatusOptions("target", "target", nil, {
	title = L["highlights your target"],
	titleIcon = Grid2.isClassic and "Interface\\Icons\\Ability_Hunter_SniperShot" or "Interface\\Icons\\Ability_hunter_mastermarksman",
})

Grid2Options:RegisterStatusOptions("self", "target", nil, {
	titleIcon = "Interface\\Icons\\Inv_wand_12",
})

Grid2Options:RegisterStatusOptions("afk", "misc", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 40)
	options.customText = {
		type = "input",
		order = 50,
		name = L["Text"],
		desc = L["Leave blank to use the default text."],
		get = function ()
			return status.dbx.text or LG["AFK"]
		end,
		set = function (_, v)
			v = strtrim(v)
			status.dbx.text = (v~='' and v~=LG["AFK"]) and v or nil
			print(">", status.dbx.text)
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}
end, {
	titleIcon = "Interface\\ICONS\\Spell_nature_sleep"
})

Grid2Options:RegisterStatusOptions("offline", "misc", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 40)
	options.customText = {
		type = "input",
		order = 50,
		name = L["Text"],
		desc = L["Leave blank to use the default text."],
		get = function ()
			return status.dbx.text or LG["Offline"]
		end,
		set = function (_, v)
			v = strtrim(v)
			status.dbx.text = (v~='' and v~=LG["Offline"]) and v or nil
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}
end, {
	titleIcon = "Interface\\CharacterFrame\\Disconnect-Icon",
	titleIconCoords = {0.3,0.7,0.2,0.8},
})

Grid2Options:RegisterStatusOptions("resurrection", "combat", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 40)
	options.color2.hidden = function() return status.dbx.onlyReviving end
	options.onlyReviving = {
		type = "toggle",
		name = L["Enabled only while the resurrection spell is being cast"],
		desc = L["Check this option to clear the status after the resurrection spell cast ends."],
		width = "full",
		order = 50,
		get = function () return status.dbx.onlyReviving end,
		set = function (_, v)
			status.dbx.onlyReviving = v or nil
			status:Refresh()
		end,
	}
end, {
	color1 = L["Casting resurrection"],
	colorDesc1 = L["A resurrection spell is being casted on the unit"],
	color2 = L["Resurrected"],
	colorDesc2 = L["A resurrection spell has been casted on the unit"],
	width = "full",
	titleIcon = "Interface\\RaidFrame\\Raid-Icon-Rez",
})

Grid2Options:RegisterStatusOptions("summon", "misc", nil, {
	color1 = L["Player Summoned"],
	colorDesc1 = L["Player has been summoned, waiting for a response."],
	color2 = L["Summon Accepted"],
	colorDesc2 = L["Player accepted the summon."],
	color3 = L["Summon Declined"],
	colorDesc3 = L["Player declined the summon."],
	width = "full",
	titleIcon = "2470702",
	titleIconCoords = {0.5890625, 0.7390625, 0.115625,  0.415625},
})

Grid2Options:RegisterStatusOptions("monk-stagger", "combat", nil, {
	color1 = L["High stagger"],
	color2 = L["Medium stagger"],
	color3 = L["Low stagger"],
	width = "full",
	titleIcon = "463281",
})

Grid2Options:RegisterStatusOptions("phased", "misc", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.displayLFG = {
		type = "toggle",
		name = L["Display other groups"],
		desc = L["Enable the status if the player is in another LFG or PvP instance."],
		width = "full",
		order = 35,
		get = function () return status.dbx.displayLFG end,
		set = function (_, v)
			status.dbx.displayLFG = v or nil
			status.dbx.enabledInstances = v or nil
			status:Refresh()
		end,
	}
	options.inInstance = {
		type = "toggle",
		name = L["Disabled in instances"],
		desc = L["Disable this status inside instances."],
		width = "full",
		order = 40,
		get = function () return not status.dbx.enabledInstances end,
		set = function (_, v)
			status.dbx.enabledInstances = not v or nil
			status:Refresh()
		end,
		disabled = function() return status.dbx.displayLFG end,
	}
end, {
	titleIcon = "Interface\\TARGETINGFRAME\\UI-PhasingIcon",
	titleIconCoords = { 0.15625, 0.84375, 0.15625, 0.84375 },
})

Grid2Options:RegisterStatusOptions("vehicle", "misc", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.classcolors = {
		type = "toggle",
		name = L["Use Owner/Vehicle Class Color"],
		desc = L["Use Owner/Vehicle Class Color"],
		width = "full",
		order = 35,
		get = function () return status.dbx.useClassColors end,
		set = function (_, v)
			status.dbx.useClassColors = v or nil
			status:Refresh()
		end,
	}
end, {
	titleIcon = "Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up",
	titleIconCoords = {0.2,0.8,0.2,0.8},
})

Grid2Options:RegisterStatusOptions("pvp", "combat", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.classcolors = {
		type = "toggle",
		name = L["Hide inside Instances"],
		desc = L["Hide inside Instances"],
		width = "full",
		order = 35,
		get = function () return not status.dbx.displayAlways end,
		set = function (_, v)
			status.dbx.displayAlways = not status.dbx.displayAlways or nil
			status:Refresh()
		end,
	}
end, {
	titleIcon = UnitFactionGroup("player") == "Horde" and  "Interface\\PVPFrame\\PVP-Currency-Horde" or "Interface\\PVPFrame\\PVP-Currency-Alliance"
})

Grid2Options:RegisterStatusOptions("unit-index", "misc", function(self, status, options, optionParams)
	options.partyUnits = {
		type = "toggle",
		name = L["Enabled only for party units"],
		desc = L["Raid indexes will not be displayed."],
		width = "full",
		order = 10,
		get = function () return status.dbx.partyUnits end,
		set = function (_, v)
			status.dbx.partyUnits = v or nil
			status:Refresh()
		end,
	}
	options.playerUnit = {
		type = "toggle",
		name = L["Enabled for player unit"],
		desc = L["Display a zero index for player unit while in party or raid."],
		width = "full",
		order = 30,
		get = function () return status.dbx.playerUnit end,
		set = function (_, v)
			status.dbx.playerUnit = v or nil
			status:Refresh()
		end,
	}
end, {
	titleIcon = "Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up"
})
