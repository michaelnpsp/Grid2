local L = Grid2Options.L

local optionParams = {
	color1 = RAID_TARGET_1,
	color2 = RAID_TARGET_2,
	color3 = RAID_TARGET_3,
	color4 = RAID_TARGET_4,
	color5 = RAID_TARGET_5,
	color6 = RAID_TARGET_6,
	color7 = RAID_TARGET_7,
	color8 = RAID_TARGET_8,
	titleIcon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcons",
	titleIconCoords = { 0.5, 1, 0, 0.5 },
}

Grid2Options:RegisterStatusOptions("raid-icon-player", "target", Grid2.Dummy, optionParams)
Grid2Options:RegisterStatusOptions("raid-icon-target", "target", Grid2.Dummy, optionParams)
