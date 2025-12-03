local Grid2 = Grid2
local Location = Grid2.CreateLocation
local defaultFont = "Friz Quadrata TT"

local function MakeDatabaseDefaults()

	-- cells apearance
	local pf = Grid2.db:GetNamespace('Grid2Frame').profile
	pf.frameHeight = 46
	pf.frameWidth  = 66

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

	Grid2:DbSetValue( "indicators",  "health", {type = "bar", level = 2, location= Location("CENTER"), texture = "Gradient", color1 = {r=0,g=0,b=0,a=1}})
	Grid2:DbSetMap( "health", "health-current", 99)

	Grid2:DbSetValue( "indicators",  "health-color", {type = "bar-color"})
	Grid2:DbSetMap( "health-color", "classcolor", 99)

	-- Grid2:DbSetValue( "indicators",  "corner-bottom-left", {type = "square", level = 5, location = Location("BOTTOMLEFT"), size = 5, color1 = {r=1,g=1,b=1,a=1},})
	-- Grid2:DbSetMap( "corner-bottom-left", "threat", 99)

	Grid2:DbSetValue( "indicators",  "icon-center", {type = "icon", level = 8, location = Location("CENTER"), size = 14, fontSize = 8,})
	Grid2:DbSetMap( "icon-center", "death", 155)
	Grid2:DbSetMap( "icon-center", "ready-check", 150)

	Grid2:DbSetValue( "indicators",  "icon-right", {type = "icon", level = 8, location = Location("RIGHT",2), size = 12, fontSize = 8,})
	Grid2:DbSetMap( "icon-left", "raid-icon-player", 155)
	Grid2:DbSetValue( "indicators",  "icon-left", {type = "icon", level = 8, location = Location("LEFT",-2), size = 12, fontSize = 8,})
	Grid2:DbSetMap( "icon-right", "raid-icon-target", 155)

	Grid2:DbSetValue( "indicators",  "text-up", {type = "text", level = 7, location = Location("TOP",0,-8) , textlength = 6, fontSize = 8 })
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

	Grid2:DbSetValue( "indicators",  "text-down", {type = "text", level = 6, location = Location("BOTTOM",0,4) , textlength = 6, fontSize = 10 })
	Grid2:DbSetMap( "text-down", "name", 99)
	Grid2:DbSetValue( "indicators",  "text-down-color", {type = "text-color"})
	Grid2:DbSetMap( "text-down-color", "classcolor", 99)

	Grid2:DbSetValue( "indicators",  "buffs", {type = "icons", level = 8, location = Location("BOTTOMLEFT") } )
	Grid2:DbSetMap( "buffs", "buffs-Default", 100)

	Grid2:DbSetValue( "indicators",  "debuffs", {type = "icons", level = 8, location = Location("TOPLEFT")} )
	Grid2:DbSetMap( "debuffs", "debuffs-Default", 100)

end

Grid2:DbRegisterProfile( { -- Only test purpose, TODO, move to Grid2Options/profiles folder
	name = 'Modern',
	desc = 'Modern unit frames profile.',
	func = MakeDatabaseDefaults,
})
