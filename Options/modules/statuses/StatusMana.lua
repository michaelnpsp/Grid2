local L = Grid2Options.L

local CLASSES_MANA = { PRIEST = true, DRUID = true, MAGE = true,  WARLOCK = true, PALADIN = true, SHAMAN = true, MONK = true, EVOKER = true, HUNTER = Grid2.isClassic or nil }
for class in pairs(CLASSES_MANA) do
	CLASSES_MANA[class] = LOCALIZED_CLASS_NAMES_MALE[class]
end

local function ManaOptions(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	self:MakeHeaderOptions(options, "Display")	
	options.display1 = {
		type = "toggle",
		order = 110,
		width = 'full',
		name = L['Primary resource'],
		desc = L["Mana visible when it is the primary resource."],
		get = function () return (status.dbx.displayType or 0)~=2 end,
		set = function (info, v)
			if v then
				status.dbx.displayType = 1
			else
				status.dbx.displayType = 2
			end			
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}	
	options.display2 = {
		type = "toggle",
		order = 120,
		width = 'full',
		name = L['Secondary resource'],
		desc = L["Mana visible when it is not the primary resource, for example: druids in bear form or shadow priests."],
		get = function () return (status.dbx.displayType or 0)~=0 end,
		set = function (info, v)
			if v then
				status.dbx.displayType = 1
			else
				status.dbx.displayType = false
			end
			status:UpdateDB()
			status:UpdateAllUnits()
		end,
	}	
end

Grid2Options:RegisterStatusOptions("mana","mana",  ManaOptions, {
	titleIcon = "Interface\\Icons\\Inv_potion_72",
	unitFilter = true,
})

Grid2Options:RegisterStatusOptions("manaalt", "mana",  ManaOptions, {
	titleIcon = "Interface\\Icons\\Inv_potion_72",
	unitFilter = true,
})

Grid2Options:RegisterStatusOptions("lowmana",  "mana", Grid2Options.MakeStatusColorThresholdOptions, {
	titleIcon = "Interface\\Icons\\Inv_potion_86"
})

Grid2Options:RegisterStatusOptions("poweralt", "mana", Grid2Options.MakeStatusColorOptions, {
	titleIcon = "Interface\\Icons\\Inv_potion_34"
})
Grid2Options:RegisterStatusOptions("power",    "mana", Grid2Options.MakeStatusColorOptions, {
	color1 = L["Mana"],
	colorDesc1 = L["Mana"],
	color2 = L["Rage"],
	colorDesc2 = L["Rage"],
	color3 = L["Focus"],
	colorDesc3 = L["Focus"],
	color4 = L["Energy"],
	colorDesc4 = L["Energy"],
	color5 = L["Runic Power"],
	colorDesc5 = L["Runic Power"],
	color6 = L["Insanity"],
	colorDesc6 = L["Insanity"],
	color7 = L["Maelstrom"],
	colorDesc7 = L["Maelstrom"],
	color8 = L["Lunar Power"],
	colorDesc8 = L["Lunar Power"],
	color9 = L["Fury"],
	colorDesc9 = L["Fury"],
	color10 = L["Pain"],
	colorDesc10 = L["Pain"],
	width = "full",
	titleIcon = "Interface\\Icons\\Inv_potion_33",
	unitFilter = true,
})
