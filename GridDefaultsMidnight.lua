--[[ Created by Michael, based on Grid2Options\GridDefaults.lua from original Grid2 authors --]]
if not Grid2.isMidnight then return end

local Grid2 = Grid2
local Loc = Grid2.CreateLocation
local Copy = Grid2.CopyTable
local fontDefault = "Friz Quadrata TT"
local iconsDefault = { -- defaults for aura icons
	type = "icons",
	level = 8,
	borderOpacity = 1,
	borderSize = 1,
	reverseCooldown = true,
	enableCooldownText = true,
	disableOmniCC = true,
	ctFontSize = 10,
	fontSize = 9,
	fontJustifyV = 'TOP',
	fontJustifyH = 'RIGHT',
	color1 = {r=0,g=0,b=0,a=1},
}

local function MakeDatabaseDefaults()

	-- frames apearance
	local pf = Grid2.db:GetNamespace('Grid2Frame').profile
	pf.frameHeight = 66
	pf.frameWidth = 66
	pf.iconSize = 16

	-- statuses
	Grid2:DbSetValue( "statuses", "buffs-Default", { type = "mbuffs", aura_filter = 'HELPFUL|RAID|PLAYER', aura_filter_enemy = 'HELPFUL', color1 = {r=0, g=1, b=0, a=1} })
	Grid2:DbSetValue( "statuses", "debuffs-Default", { type = "mdebuffs", aura_filter = 'HARMFUL', color1 = {r=1, g=0, b=0, a=1} })

	-- indicators
	Grid2:DbSetValue( "indicators",  "background", {type = "background"})

	Grid2:DbSetValue( "indicators",  "tooltip", {type = "tooltip", showTooltip = 4, showDefault = true} )

	Grid2:DbSetValue( "indicators",  "alpha", {type = "alpha"})
	Grid2:DbSetMap( "alpha", "range", 99)

	Grid2:DbSetValue( "indicators",  "border", {type = "border", color1 = {r=0,g=0,b=0,a=0}})
	Grid2:DbSetMap( "border", "target", 50)

	Grid2:DbSetValue( "indicators",  "health", {type = "bar", level = 2, location= Loc("CENTER"), texture = "Gradient", color1 = {r=0,g=0,b=0,a=1}})
	Grid2:DbSetMap( "health", "health-current", 99)

	Grid2:DbSetValue( "indicators",  "health-color", {type = "bar-color"})
	Grid2:DbSetMap( "health-color", "classcolor", 99)

	Grid2:DbSetValue( "indicators",  "corner-bottom", {type = "square", level = 5, location = Loc("BOTTOM",0,2), size = 7, color1 = {r=1,g=1,b=1,a=1},})
	Grid2:DbSetMap( "corner-bottom", "threat", 99)

	Grid2:DbSetValue( "indicators",  "icon-center", {type = "icon", level = 9, location = Loc("CENTER"), size = 20, fontSize = 8})
	Grid2:DbSetMap( "icon-center", "death", 155)
	Grid2:DbSetMap( "icon-center", "ready-check", 150)

	Grid2:DbSetValue( "indicators",  "icon-right", {type = "icon", level = 8, location = Loc("RIGHT",2), size = 12, fontSize = 8})
	Grid2:DbSetMap( "icon-left", "raid-icon-player", 155)

	Grid2:DbSetValue( "indicators",  "icon-left", {type = "icon", level = 8, location = Loc("LEFT",-2), size = 12, fontSize = 8})
	Grid2:DbSetMap( "icon-right", "dungeon-role", 150)

	Grid2:DbSetValue( "indicators", "buffs", Copy(iconsDefault,{location = Loc("TOPLEFT")}) )
	Grid2:DbSetMap( "buffs", "buffs-Default", 100)

	Grid2:DbSetValue( "indicators",  "debuffs", Copy(iconsDefault,{location = Loc("CENTER"), iconSize = 24, smartCenter = true}) )
	Grid2:DbSetMap( "debuffs", "debuffs-Default", 100)

	Grid2:DbSetValue( "indicators",  "text-up", {type = "text", level = 7, location = Loc("TOP",0,-8) , textlength = 6, fontSize = 8 })
	Grid2:DbSetMap( "text-up", "feign-death", 96)
	Grid2:DbSetMap( "text-up", "death", 95)
	Grid2:DbSetMap( "text-up", "offline", 93)
	Grid2:DbSetMap( "text-up", "vehicle", 70)
	Grid2:DbSetMap( "text-up", "charmed", 65)
	Grid2:DbSetValue( "indicators",  "text-up-color", {type = "text-color"})
	Grid2:DbSetMap( "text-up-color", "feign-death", 96)
	Grid2:DbSetMap( "text-up-color", "death", 95)
	Grid2:DbSetMap( "text-up-color", "offline", 93)
	Grid2:DbSetMap( "text-up-color", "vehicle", 70)
	Grid2:DbSetMap( "text-up-color", "charmed", 65)

	Grid2:DbSetValue( "indicators",  "text-down", {type = "text", level = 6, location = Loc("BOTTOM",0,4) , textlength = 6, fontSize = 10 })
	Grid2:DbSetMap( "text-down", "name", 99)
	Grid2:DbSetValue( "indicators",  "text-down-color", {type = "text-color"})
	Grid2:DbSetMap( "text-down-color", "classcolor", 99)

end

Grid2:DbRegisterProfile( { -- Register the basic profile
	name = 'Classic',
	desc = 'Classic Grid Unit Frames with vertical health bars and a compact design.',
	image = 'Interface\\Addons\\Grid2\\media\\profile-classic',
	imageWidth = 440 * 0.8,
	imageHeight = 109 * 0.8,
	func = MakeDatabaseDefaults,
}, 0)
