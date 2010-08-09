local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")
local DBL = LibStub:GetLibrary("LibDBLayers-1.0")
local HealComm = LibStub:GetLibrary("LibHealComm-4.0", true)

Grid2Options.healers = {
	druid = true,
	paladin = true,
	priest = true,
	shaman = true,
}
Grid2Options.defaultSpec = {
	druid = "tree",
	paladin = "holy1",
	priest = "holy2",
	shaman = "resto",
}
local realmKey = GetRealmName()
local charKey = UnitName("player") .. " - " .. realmKey
local _, classKey = UnitClass("player")
classKey = strlower(classKey)
local specKey = Grid2Options.defaultSpec[classKey]

Grid2Options.charKey = charKey
Grid2Options.classKey = classKey
Grid2Options.specKey = specKey
Grid2Options.layers = {"account", classKey, specKey}
Grid2Options.layerOrder = {
	account = 1,
}
Grid2Options.layerOrder[classKey] = 2
if (specKey) then
	Grid2Options.layerOrder[specKey] = 3
end

function Grid2Options:GetCharacterKeys()
	return charKey, classKey, specKey
end


function Grid2Options:GetDBObjects(db, charKey, classKey, specKey)
	local profileCurrent = db["profile-current"]
	local profileCurrentKey = profileCurrent[charKey]

	local setup = db["setup-layers"][profileCurrentKey]
	local objects = db.objects
	local versions = db.versions

	return setup, objects, versions
end


function Grid2Options:InitializeDefaults(dblData)
	local layerOrder = Grid2Options.layerOrder

	DBL:InitializeObjectType(dblData, "locations", layerOrder)
	DBL:InitializeObjectType(dblData, "indicators", layerOrder)
	DBL:InitializeObjectType(dblData, "statuses", layerOrder)
	DBL:InitializeObjectType(dblData, "statusMap", layerOrder)
end

function Grid2Options.UpgradeDefaults(dblData)
	local versionsSrc = dblData.versionsSrc
	local layers = Grid2Options.layers

	Grid2Options:MakeDefaults(dblData, versionsSrc, layers)
end

function Grid2Options:FlattenDefaults(dblData)
	DBL:FlattenSetupType(dblData, "locations")
	DBL:FlattenSetupType(dblData, "indicators")
	DBL:FlattenSetupType(dblData, "statuses")
	DBL:FlattenMap(dblData, "statusMap", "indicators", "statuses")
	DBL:CopyDB(dblData.versionsSrc, dblData.versionsDst)
end


local defaultFont = "Friz Quadrata TT"

-- dblData - data table for the mod
-- versions - table of version info
-- layers to create defaults for
function Grid2Options:MakeDefaults(dblData, versions, layers)
	for i, layer in pairs(layers) do
		if (layer == "account") then
			if (versions.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "locations", layer, "corner-top-left", {relIndicator = nil, point = "TOPLEFT", relPoint = "TOPLEFT", x = 1, y = -1, name = "corner-top-left"})
				DBL:SetupLayerObject(dblData, "locations", layer, "corner-top-right", {relIndicator = nil, point = "TOPRIGHT", relPoint = "TOPRIGHT", x = -1, y = -1, name = "corner-top-right"})
				DBL:SetupLayerObject(dblData, "locations", layer, "corner-bottom-left", {relIndicator = nil, point = "BOTTOMLEFT", relPoint = "BOTTOMLEFT", x = 1, y = 1, name = "corner-bottom-left"})
				DBL:SetupLayerObject(dblData, "locations", layer, "corner-bottom-right", {relIndicator = nil, point = "BOTTOMRIGHT", relPoint = "BOTTOMRIGHT", x = -1, y = 1, name = "corner-bottom-right"})
				DBL:SetupLayerObject(dblData, "locations", layer, "side-left", {relIndicator = nil, point = "LEFT", relPoint = "LEFT", x = 2, y = 0, name = "side-left"})
				DBL:SetupLayerObject(dblData, "locations", layer, "side-right", {relIndicator = nil, point = "RIGHT", relPoint = "RIGHT", x = -2, y = 0, name = "side-right"})
				DBL:SetupLayerObject(dblData, "locations", layer, "side-top", {relIndicator = nil, point = "TOP", relPoint = "TOP", x = 0, y = -1, name = "side-top"})
				DBL:SetupLayerObject(dblData, "locations", layer, "side-bottom", {relIndicator = nil, point = "BOTTOM", relPoint = "BOTTOM", x = 0, y = 1, name = "side-bottom"})
				DBL:SetupLayerObject(dblData, "locations", layer, "side-bottom-left", {relIndicator = nil, point = "RIGHT", relPoint = "BOTTOM", x = -2, y = 8, name = "side-bottom-left"})
				DBL:SetupLayerObject(dblData, "locations", layer, "side-bottom-right", {relIndicator = nil, point = "LEFT", relPoint = "BOTTOM", x = 2, y = 2, name = "side-bottom-right"})
				DBL:SetupLayerObject(dblData, "locations", layer, "center", {relIndicator = nil, point = "CENTER", relPoint = "CENTER", x = 0, y = 0, name = "center"})
				DBL:SetupLayerObject(dblData, "locations", layer, "center-left", {relIndicator = "center", point = "RIGHT", relPoint = "CENTER", x = -4, y = 0, name = "center-left"})
				DBL:SetupLayerObject(dblData, "locations", layer, "center-right", {relIndicator = "center", point = "LEFT", relPoint = "CENTER", x = 4, y = 0, name = "center-right"})
				DBL:SetupLayerObject(dblData, "locations", layer, "center-top", {relIndicator = "center", point = "BOTTOM", relPoint = "CENTER", x = 0, y = 4, name = "center-top"})
				DBL:SetupLayerObject(dblData, "locations", layer, "center-bottom", {relIndicator = "center", point = "TOP", relPoint = "CENTER", x = 0, y = -4, name = "center-bottom"})
				DBL:SetupLayerObject(dblData, "locations", layer, "name", {relIndicator = nil, point = "TOP", relPoint = "TOP", x = 0, y = -8, name = "name"})

				DBL:SetupLayerObject(dblData, "indicators", layer, "alpha", {type = "alpha", color1 = {r=0,g=0,b=0,a=1}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "alpha", "death", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "alpha", "range", 98)
				DBL:SetupMapObject(dblData, "statusMap", layer, "alpha", "offline", 97)

				DBL:SetupLayerObject(dblData, "indicators", layer, "border", {type = "border", color1 = {r=0,g=0,b=0,a=1}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "border", "target", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "border", "voice", 89)
				DBL:SetupMapObject(dblData, "statusMap", layer, "border", "lowmana", 79)
				DBL:SetupMapObject(dblData, "statusMap", layer, "border", "health-low", 69)
				DBL:SetupMapObject(dblData, "statusMap", layer, "border", "pvp", 45)

				DBL:SetupLayerObject(dblData, "indicators", layer, "health", {type = "bar", level = 2, location = "center", texture = "Gradient", color1 = {r=0,g=0,b=0,a=1}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "health", "health-current", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "health-color", {type = "bar-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "health-color", "classcolor", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "health-color", "health-current", 85)

				DBL:SetupLayerObject(dblData, "indicators", layer, "heals", {type = "bar", level = 1, location = "center", texture = "Gradient", color1 = {r=0,g=0,b=0,a=0}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "heals", "heals-incoming", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "heals-color", {type = "bar-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "heals-color", "heals-incoming", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "side-bottom", {type = "square", level = 5, location = "side-bottom", size = 5, color1 = {r=1,g=1,b=1,a=1},})

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-bottom-left", {type = "square", level = 5, location = "corner-bottom-left", size = 5, color1 = {r=1,g=1,b=1,a=1},})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-bottom-left", "threat", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "icon-center", {type = "icon", level = 8, location = "center", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "icon-center", "buff-SpiritOfRedemption", 160)
				DBL:SetupMapObject(dblData, "statusMap", layer, "icon-center", "death", 155)
				DBL:SetupMapObject(dblData, "statusMap", layer, "icon-center", "ready-check", 150)

				DBL:SetupLayerObject(dblData, "indicators", layer, "text-name", {type = "text", level = 6, location = "name", textlength = 12, fontSize = 8, font = defaultFont,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-name", "name", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "text-name-color", {type = "text-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-name-color", "classcolor", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "text-down", {type = "text", level = 7, location = "center-bottom", textlength = 12, fontSize = 8, font = defaultFont,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "feign-death", 96)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "death", 95)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "offline", 93)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "vehicle", 70)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "charmed", 65)
				-- DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "heals-incoming", 55)
				-- DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "health-deficit", 50)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "role", 45)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down", "pvp", 35)

				DBL:SetupLayerObject(dblData, "indicators", layer, "text-down-color", {type = "text-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down-color", "feign-death", 96)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down-color", "death", 95)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down-color", "offline", 93)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down-color", "vehicle", 70)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down-color", "charmed", 65)
				-- DBL:SetupMapObject(dblData, "statusMap", layer, "text-down-color", "heals-incoming", 55)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down-color", "role", 45)
				DBL:SetupMapObject(dblData, "statusMap", layer, "text-down-color", "pvp", 35)


				DBL:SetupLayerObject(dblData, "statuses", layer, "charmed", {type = "charmed", color1 = {r=1,g=.1,b=.1,a=1}})

				local colors = {
					HOSTILE = { r = 1, g = 0.1, b = 0.1, a = 1 },
					UNKNOWN_UNIT = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
					UNKNOWN_PET = { r = 0, g = 1, b = 0, a = 1 },
					[L["Beast"]] = { r = 0.93725490196078, g = 0.75686274509804, b = 0.27843137254902, a = 1 },
					[L["Demon"]] = { r = 0.54509803921569, g = 0.25490196078431, b = 0.68627450980392, a = 1 },
					[L["Humanoid"]] = { r = 0.91764705882353, g = 0.67450980392157, b = 0.84705882352941, a = 1 },
					[L["Elemental"]] = { r = 0.1, g = 0.3, b = 0.9, a = 1 },
				}
				for class, color in pairs(RAID_CLASS_COLORS) do
					if (not colors[class]) then
						colors[class] = { r = color.r, g = color.g, b = color.b, a = 1 }
					end
				end
				DBL:SetupLayerObject(dblData, "statuses", layer, "classcolor", {type = "classcolor", colorHostile = true, colors = colors})

				DBL:SetupLayerObject(dblData, "statuses", layer, "death", {type = "death", color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "feign-death", {type = "feign-death", color1 = {r=1,g=.5,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "health-current", {type = "health-current", color1 = {r=0,g=1,b=0,a=1}, deadAsFullHealth = nil})
				DBL:SetupLayerObject(dblData, "statuses", layer, "health-deficit", {type = "health-deficit", threshold = 0.2})
				DBL:SetupLayerObject(dblData, "statuses", layer, "health-low", {type = "health-low", threshold = 0.4, color1 = {r=1,g=0,b=0,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "heals-incoming", {type = "heals-incoming", includePlayerHeals = true, timeFrame = nil, flags = HealComm.ALL_HEALS, color1 = {r=0,g=1,b=0,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "lowmana", {type = "lowmana", threshold = 0.75, color1 = {r=0,g=0,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "mana", {type = "mana"})
				DBL:SetupLayerObject(dblData, "statuses", layer, "name", {type = "name"})
				DBL:SetupLayerObject(dblData, "statuses", layer, "offline", {type = "offline", color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "pvp", {type = "pvp", color1 = {r=0,g=1,b=1,a=.75}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "range", {type = "range", default = 0.25, elapsed = 0.1, range = 40,})
				DBL:SetupLayerObject(dblData, "statuses", layer, "ready-check", {type = "ready-check", threshold = 10, colorCount = 4, color1 = {r=1,g=1,b=0,a=1}, color2 = {r=0,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1}, color4 = {r=1,g=0,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "role", {type = "role", colorCount = 2, color1 = {r=1,g=1,b=.5,a=1}, color2 = {r=.5,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "target", {type = "target", color1 = {r=.8,g=.8,b=.8,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "threat", {type = "threat", colorCount = 3, color1 = {r=1,g=0,b=0,a=1}, color2 = {r=.5,g=1,b=1,a=1}, color3 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "vehicle", {type = "vehicle", color1 = {r=0,g=1,b=1,a=.75}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "voice", {type = "voice", color1 = {r=1,g=1,b=0,a=1}})

				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Drink", {type = "buff", spellName = L["Drink"], mine = true, color1 = {r=.8,g=.8,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Food", {type = "buff", spellName = L["Food"], mine = true, color1 = {r=1,g=1,b=.6,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-SpiritOfRedemption", {type = "buff", spellName = 27827, blinkThreshold = 3, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "debuff-Magic", {type = "debuffType", subType = "Magic", color1 = {r=.2,g=.6,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "debuff-Poison", {type = "debuffType", subType = "Poison", color1 = {r=0,g=.6,b=0,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "debuff-Curse", {type = "debuffType", subType = "Curse", color1 = {r=.6,g=0,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "debuff-Disease", {type = "debuffType", subType = "Disease", color1 = {r=.6,g=.4,b=0,a=1}})

				versions.Grid2Options = 1
			end
		elseif (layer == "deathknight") then
			if (versions.deathknight.Grid2Options < 1) then
				DBL:SetupMapObject(dblData, "statusMap", layer, "icon-center", "debuff-Magic", 40)

				versions.deathknight.Grid2Options = 1
			end
		elseif (layer == "druid") then
			if (versions.druid.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "locations", layer, "side-left-top", {relIndicator = nil, point = "BOTTOM", relPoint = "LEFT", x = 1, y = -2, name = "side-left-top"})
				DBL:SetupLayerObject(dblData, "locations", layer, "side-left-bottom", {relIndicator = nil, point = "TOP", relPoint = "LEFT", x = 1, y = 2, name = "side-left-bottom"})

				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-AbolishPoison-mine", {type = "buff", spellName = 2893, mine = true, blinkThreshold = 3, color1 = {r=.9,g=1,b=.6,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Lifebloom-mine", {type = "buff", spellName = 33763, mine = true, colorCount = 3, color1 = {r=.2,g=.7,b=.2,a=1}, color2 = {r=.6,g=.9,b=.6,a=1}, color3 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Rejuv-mine", {type = "buff", spellName = 774, mine = true, color1 = {r=1,g=0,b=.6,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Regrowth-mine", {type = "buff", spellName = 8936, mine = true, color1 = {r=.5,g=1,b=0,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Thorns", {type = "buff", spellName = 467, missing = true, color1 = {r=.2,g=.05,b=.05,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-WildGrowth-mine", {type = "buff", spellName = 53248, mine = true, color1 = {r=0.2,g=.9,b=.2,a=1}})

				DBL:SetupLayerObject(dblData, "indicators", layer, "side-top", {type = "text", level = 9, location = "side-top", textlength = 12, fontSize = 8, font = defaultFont, duration = true})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-top", "buff-Regrowth-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "side-top-color", {type = "text-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-top-color", "buff-Regrowth-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-left", {type = "text", level = 9, location = "corner-top-left", textlength = 12, fontSize = 8, font = defaultFont, duration = true})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left", "buff-Lifebloom-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-left-color", {type = "text-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left-color", "buff-Lifebloom-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-right", {type = "text", level = 9, location = "corner-top-right", textlength = 12, fontSize = 8, font = defaultFont, duration = true})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-Rejuv-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-right-color", {type = "text-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right-color", "buff-Rejuv-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "center-left", {type = "icon", level = 9, location = "center-left", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-left", "debuff-Poison", 90)

				DBL:SetupLayerObject(dblData, "indicators", layer, "center-right", {type = "icon", level = 9, location = "center-right", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-right", "debuff-Curse", 80)

				DBL:SetupLayerObject(dblData, "locations", layer, "side-right-bottom", {relIndicator = nil, point = "TOPRIGHT", relPoint = "RIGHT", x = -1, y = -2, name = "side-right-bottom"})
				DBL:SetupLayerObject(dblData, "indicators", layer, "side-right-bottom", {type = "square", level = 5, location = "side-right-bottom", size = 5,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-right-bottom", "buff-AbolishPoison-mine", 99)

				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-WildGrowth-mine", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-Thorns", 59)

				versions.druid.Grid2Options = 1
			end
		-- elseif (layer == "tree") then
			-- if (versions.tree.Grid2Options < 1) then

				-- versions.tree.Grid2Options = 1
			-- end
		elseif (layer == "hunter") then
			if (versions.hunter.Grid2Options < 1) then

				versions.hunter.Grid2Options = 1
			end
		elseif (layer == "mage") then
			if (versions.mage.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-bottom-right", {type = "square", level = 5, location = "corner-bottom-right", size = 5,})
				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-left", {type = "square", level = 9, location = "corner-top-left", size = 5,})
				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-right", {type = "square", level = 9, location = "corner-top-right", size = 5,})

				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-AmplifyMagic", {type = "buff", spellName = 33946, color1 = {r=0,g=0,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-DampenMagic", {type = "buff", spellName = 33944, color1 = {r=.4,g=.2,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-FocusMagic", {type = "buff", spellName = 54646, color1 = {r=.11,g=.22,b=.33,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-IceArmor-mine", {type = "buff", spellName = 7302, mine = true, missing = true, color1 = {r=.2,g=.4,b=.4,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-IceBarrier-mine", {type = "buff", spellName = 11426, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})

				DBL:SetupMapObject(dblData, "statusMap", layer, "icon-center", "debuff-Curse", 20)

				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-AmplifyMagic", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left", "buff-DampenMagic", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-bottom-right", "buff-FocusMagic", 99)

				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-IceArmor-mine", 79)
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-IceBarrier-mine", 89)

				versions.mage.Grid2Options = 1
			end
		elseif (layer == "paladin") then
			if (versions.paladin.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-left", {type = "text", level = 9, location = "corner-top-left", textlength = 12, fontSize = 8, font = defaultFont, duration = true})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left", "buff-BeaconOfLight", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left", "buff-BeaconOfLight-mine", 89)
				-- DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left", "buff-LightsBeacon-mine", 79)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-left-color", {type = "text-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left-color", "buff-BeaconOfLight", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left-color", "buff-BeaconOfLight-mine", 89)

				DBL:SetupLayerObject(dblData, "indicators", layer, "side-top", {type = "text", level = 9, location = "side-top", textlength = 12, fontSize = 8, font = defaultFont, duration = true})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-top", "buff-FlashOfLight-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "side-top-color", {type = "text-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-top-color", "buff-FlashOfLight-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-right", {type = "text", level = 9, location = "corner-top-right", textlength = 12, fontSize = 8, font = defaultFont, duration = true})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-SacredShield", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-SacredShield-mine", 89)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-right-color", {type = "text-color"})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right-color", "buff-SacredShield", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right-color", "buff-SacredShield-mine", 89)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-bottom-left", {type = "square", level = 5, location = "corner-bottom-left", size = 5, color1 = {r=1,g=1,b=1,a=1},})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-bottom-left", "buff-HandOfSalvation", 101)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-bottom-left", "buff-HandOfSalvation-mine", 100)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-bottom-right", {type = "icon", level = 8, location = "corner-bottom-right", size = 12, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-bottom-right", "debuff-Forbearance", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-DivineShield-mine", 97)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-DivineProtection-mine", 95)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-HandOfProtection-mine", 93)

				DBL:SetupLayerObject(dblData, "indicators", layer, "side-left", {type = "square", level = 9, location = "side-left", size = 5,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-left", "buff-SacredShield-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "center-left", {type = "icon", level = 9, location = "center-left", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-left", "debuff-Magic", 40)
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-left", "debuff-Poison", 30)

				DBL:SetupLayerObject(dblData, "indicators", layer, "center-right", {type = "icon", level = 9, location = "center-right", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-right", "debuff-Disease", 10)

				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-BeaconOfLight", {type = "buff", spellName = 53654, color1 = {r=.7,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-BeaconOfLight-mine", {type = "buff", spellName = 53654, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-DivineIntervention", {type = "buff", spellName = 19752, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-FlashOfLight-mine", {type = "buff", spellName = 66922, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-LightsBeacon-mine", {type = "buff", spellName = 53651, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-DivineShield-mine", {type = "buff", spellName = 642, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-DivineProtection-mine", {type = "buff", spellName = 498, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-HandOfProtection-mine", {type = "buff", spellName = 1022, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-HandOfSalvation", {type = "buff", spellName = 1038, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-HandOfSalvation-mine", {type = "buff", spellName = 1038, mine = true, color1 = {r=.8,g=.8,b=.7,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-SacredShield", {type = "buff", spellName = 53601, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-SacredShield-mine", {type = "buff", spellName = 53601, mine = true, color1 = {r=.8,g=.9,b=.9,a=1}})

				DBL:SetupLayerObject(dblData, "statuses", layer, "debuff-Forbearance", {type = "debuff", spellName = 25771, color1 = {r=1,g=0,b=0,a=1}})

				DBL:SetupMapObject(dblData, "statusMap", layer, "icon-center", "buff-DivineIntervention", 99)

				versions.paladin.Grid2Options = 1
			end
		-- elseif (layer == "holy1") then
			-- if (versions.holy1.Grid2Options < 1) then

				-- versions.holy1.Grid2Options = 1
			-- end
		elseif (layer == "priest") then
			if (versions.priest.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Grace-mine", {type = "buff", spellName = 47516, mine = true,
						colorCount = 3, color1 = {r=.6,g=.6,b=.6,a=1}, color2 = {r=.8,g=.8,b=.8,a=1}, color3 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-DivineAegis", {type = "buff", spellName = 47509, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-InnerFire", {type = "buff", spellName = 588, missing = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-PrayerOfMending-mine", {type = "buff", spellName = 33076, mine = true,
						colorCount = 5, color1 = {r=1,g=.2,b=.2,a=1}, color2 = {r=1,g=1,b=.4,a=.4}, color3 = {r=1,g=.6,b=.6,a=1}, color4 = {r=1,g=.8,b=.8,a=1}, color5 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-PowerWordShield", {type = "buff", spellName = 17, color1 = {r=0,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Renew-mine", {type = "buff", spellName = 139, mine = true, color1 = {r=1,g=1,b=1,a=1}})

				DBL:SetupLayerObject(dblData, "statuses", layer, "debuff-WeakenedSoul", {type = "debuff", spellName = 6788, color1 = {r=0,g=.2,b=.9,a=1}})

				DBL:SetupLayerObject(dblData, "indicators", layer, "center-left", {type = "icon", level = 9, location = "center-left", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-left", "debuff-Disease", 10)

				DBL:SetupLayerObject(dblData, "indicators", layer, "center-right", {type = "icon", level = 9, location = "center-right", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-right", "debuff-Magic", 40)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-left", {type = "square", level = 9, location = "corner-top-left", size = 5,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left", "buff-Renew-mine", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-PowerWordShield", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "side-right", {type = "icon", level = 9, location = "side-right", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-right", "buff-PrayerOfMending-mine", 99)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-right", {type = "square", level = 9, location = "corner-top-right", size = 5,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "debuff-WeakenedSoul", 89)

				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-DivineAegis", 79)
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-InnerFire", 79)

				versions.priest.Grid2Options = 1
			end
		-- elseif (layer == "holy2") then
			-- if (versions.holy2.Grid2Options < 1) then

				-- versions.holy2.Grid2Options = 1
			-- end
		elseif (layer == "rogue") then
			if (versions.rogue.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Evasion-mine", {type = "buff", spellName = 5277, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-Evasion-mine", 99)

				versions.rogue.Grid2Options = 1
			end
		elseif (layer == "shaman") then
			if (versions.shaman.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Riptide-mine", {type = "buff", spellName = 61295, mine = true, color1 = {r=.8,g=.6,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Earthliving", {type = "buff", spellName = 51945, color1 = {r=.8,g=1,b=.5,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-EarthShield", {type = "buff", spellName = 974, color1 = {r=.8,g=.8,b=.2,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-EarthShield-mine", {type = "buff", spellName = 974, mine = true, color1 = {r=.9,g=.9,b=.4,a=1}})

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-left", {type = "square", level = 9, location = "corner-top-left", size = 5,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left", "buff-Riptide-mine", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-left", "buff-Earthliving", 89)

				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-top-right", {type = "square", level = 9, location = "corner-top-right", size = 5,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-EarthShield-mine", 99)
				DBL:SetupMapObject(dblData, "statusMap", layer, "corner-top-right", "buff-EarthShield", 89)

				DBL:SetupLayerObject(dblData, "indicators", layer, "center-left", {type = "icon", level = 9, location = "center-left", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-left", "debuff-Poison", 50)
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-left", "debuff-Curse", 40)

				DBL:SetupLayerObject(dblData, "indicators", layer, "center-right", {type = "icon", level = 9, location = "center-right", size = 16, fontSize = 8,})
				DBL:SetupMapObject(dblData, "statusMap", layer, "center-right", "debuff-Disease", 10)

				versions.shaman.Grid2Options = 1
			end
		-- elseif (layer == "resto") then
			-- if (versions.resto.Grid2Options < 1) then

				-- versions.resto.Grid2Options = 1
			-- end
		elseif (layer == "warlock") then
			if (versions.warlock.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-ShadowWard-mine", {type = "buff", spellName = 6229, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-ShadowWard-mine", 99)

				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-SoulLink-mine", {type = "buff", spellName = 19028, mine = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-SoulLink-mine", 99)

				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-DemonArmor-mine", {type = "buff", spellName = 706, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-DemonSkin-mine", {type = "buff", spellName = 696, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})

				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-FelArmor-mine", {type = "buff", spellName = 28189, mine = true, missing = true, color1 = {r=1,g=1,b=1,a=1}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-FelArmor-mine", 99)

				versions.warlock.Grid2Options = 1
			end
		elseif (layer == "warrior") then
			if (versions.warrior.Grid2Options < 1) then
				DBL:SetupLayerObject(dblData, "indicators", layer, "corner-bottom-right", {type = "square", level = 5, location = "corner-bottom-right", size = 5,})

				--DBL:SetupLayerObject(dblData, "statuses", layer, "buff-BattleShout", {type = "buff", spellName = 2048, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
				--DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-BattleShout", 89)

				--DBL:SetupLayerObject(dblData, "statuses", layer, "buff-CommandingShout", {type = "buff", spellName = 469, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
				--DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-CommandingShout", 79)

				-- DBL:SetupLayerObject(dblData, "statuses", layer, "buff-LastStand", {type = "buff", spellName = 12975, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
				-- DBL:SetupMapObject(dblData, "statusMap", layer, "corner-bottom-right", "buff-LastStand", 99)

				-- DBL:SetupLayerObject(dblData, "statuses", layer, "buff-ShieldWall", {type = "buff", spellName = 871, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
				-- DBL:SetupMapObject(dblData, "statusMap", layer, "corner-bottom-right", "buff-ShieldWall", 89)

				DBL:SetupLayerObject(dblData, "statuses", layer, "buff-Vigilance", {type = "buff", spellName = 50720, mine = true, color1 = {r=.1,g=.1,b=1,a=1}})
				DBL:SetupMapObject(dblData, "statusMap", layer, "side-bottom", "buff-Vigilance", 99)

				versions.warrior.Grid2Options = 1
			end
		end
	end
end

