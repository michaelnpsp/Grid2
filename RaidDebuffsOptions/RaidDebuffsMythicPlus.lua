-- Raid debuffs module for Mythic+ Dungeons
if Grid2.isClassic then return end

local DB = { -- instanceID = moduleName
	[1271] = "The War Within",     -- Ara-Kara, City of Echoes
	[1269] = "The War Within",     -- The Stonevault
    [1270] = "The War Within",     -- The Dawnbreaker
    [1274] = "The War Within",     -- City of Threads
	[1182] = "Shadowlands",        -- The Necrotic Wake
	[1184] = "Shadowlands",        -- Mists of Tirna Scithe
	[1023] = "Battle for Azeroth", -- Siege of Boralus
	[  71] = "Cataclysm",          -- Grim Batol
}

-- Create the M+ dungeons module using data from other modules
do
	local RDDB, RDO = Grid2Options:GetRaidDebuffsTable()
	RDO.MPlusDungeonModule = DB
	local module = {}
	for id,name in pairs(DB) do
		module[id] = RDDB[name] and RDDB[name][id]
	end
	RDDB["Mythic+ Dungeons"] = module
end
