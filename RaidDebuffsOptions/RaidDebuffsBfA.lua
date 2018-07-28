-- Battle for Azeroth raid debuffs
-- Notes:
--   EJ_GetInstanceForMap() returns 0 for non instanced zones, so its impossible to differentiate continents: Kalimdor/Outland/Broken Isles, etc.
--   RaidDebufs code looks for InstanceMapID zone first, and if not found use: Encounter Journal InstanceID.
-- Keys meaning:
--   Key<100000 = Encounter Journal InstanceID (EJ_GetInstanceForMap())
--   Key>100000 = InstanceMapID (select(8,GetInstanceInfo())) + 100000 (+100000 to avoid collisions with InstanceID)
-- Using:
--   For real instances     : Encounter Journal InstanceID
--   For BfA world bosses   : 0 (because EJ_GetInstanceForMap() returns 0 for most world zones instead of for example 1028 for azeroth)
--   For other world bosses : InstanceMapID (100870=Pandaria, 101116=Draenor, 101220=Broken Isles, etc)
local RDDB = Grid2Options:GetRaidDebuffsTable()
RDDB["Battle for Azeroth"] = {
	[1030] = {
		{ id = 1030, name = "Temple of Sethraliss" },
		["Adderis and Aspix"] = {
		order = 1, ejid = 2142,
		263371, -- Conduction
		263234, -- Arcing Blade
		},
		["Merektha"] = {
		order = 2, ejid = 2143,
		267027, -- Cytotoxin
		263958, -- A Knot of Snakes
		261732, -- Blinding Sand
		},
		["Galvazzt"] = {
		order = 3, ejid = 2144,
		266512, -- Consume Charge
		},
		["Avatar of Sethraliss"] = {
		order = 4, ejid = 2145,
		269686, -- Plague
		},
	},
	[1001] = {
		{ id = 1001, name = "Freehold" },
		["Skycap'n Kragg"] = {
		order = 1, ejid = 2102,
		278993, -- Vile Bombardment
		},
		["Council o' Captains"] = {
		order = 2, ejid = 2093,
		258874, -- Blackout Barrel
		},
		["Ring of Booty"] = {
		order = 3, ejid = 2094,
		256553, -- Flailing Shark
		},
		["Harlan Sweete"] = {
		order = 4, ejid = 2095,
		281591, -- Cannon Barrage
		},
	},
	[1022] = {
		{ id = 1022, name = "The Underrot" },
		["Elder Leaxa"] = {
		order = 1, ejid = 2157,
		260685, -- Taint of G'huun
		},
		["Cragmaw the Infested"] = {
		order = 2, ejid = 2131,
		260333, -- Tantrum
		},
		["Sporecaller Zancha"] = {
		order = 3, ejid = 2130,
		259714, -- Decaying Spores
		},
		["Unbound Abomination"] = {
		order = 4, ejid = 2158,
		269301, -- Putrid Blood
		},
	},
	[968] = {
		{ id = 968, name = "Atal'Dazar" },
		["Priestess Alun'za"] = {
		order = 1, ejid = 2082,
		274195, -- Corrupted Blood
		277072, -- Corrupted Gold
		265914, -- Molten Gold
		},
		["Vol'kaal"] = {
		order = 2, ejid = 2036,
		263927, -- Toxic Pool
		250372, -- Lingering Nausea
		},
		["Rezan"] = {
		order = 3, ejid = 2083,
		255434, -- Serrated Teeth
		255371, -- Terrifying Visage
		257407, -- Pursuit
		255421, -- Devour
		},
		["Yazma"] = {
		order = 4, ejid = 2030,
		259145, -- Soulrend
		249919, -- Skewer
		},
	},
	[1036] = {
		{ id = 1036, name = "Shrine of the Storm" },
		["Aqu'sirr"] = {
		order = 1, ejid = 2153,
		264560, -- Choking Brine
		},
		["Tidesage Council"] = {
		order = 2, ejid = 2154,
		267899, -- Hindering Cleave
		},
		["Lord Stormsong"] = {
		order = 3, ejid = 2155,
		268896, -- Mind Rend
		},
		["Vol'zith the Whisperer"] = {
		order = 4, ejid = 2156,
		267034, -- Whispers of Power
		},
	},
	[1002] = {
		{ id = 1002, name = "Tol Dagor" },
		["The Sand Queen"] = {
		order = 1, ejid = 2097,
		257092, -- Sand Trap
		},
		["Jes Howlis"] = {
		order = 2, ejid = 2098,
		257791, -- Howling Fear
		},
		["Knight Captain Valyri"] = {
		order = 3, ejid = 2099,
		257028, -- Fuselighter
		},
		["Overseer Korgus"] = {
		order = 4, ejid = 2096,
		256198, -- Azerite Rounds: Incendiary
		256038, -- Deadeye
		},
	},
	[1021] = {
		{ id = 1021, name = "Waycrest Manor" },
		["Heartsbane Triad"] = {
		order = 1, ejid = 2125,
		260741, -- Jagged Nettles
		260926, -- Soul Manipulation
		260703, -- Unstable Runic Mark
		},
		["Soulbound Goliath"] = {
		order = 2, ejid = 2126,
		260551, -- Soul Thorns
		},
		["Raal the Gluttonous"] = {
		order = 3, ejid = 2127,
		268231, -- Rotten Expulsion
		},
		["Lord and Lady Waycrest"] = {
		order = 4, ejid = 2128,
		261439, -- Virulent Pathogen
		},
		["Gorak Tul"] = {
		order = 5, ejid = 2129,
		268203, -- Death Lens
		},
	},
	[1023] = {
		{ id = 1023, name = "Siege of Boralus" },
		["Chopper Redhook"] = {
		order = 1, ejid = 2132,
		257459, -- On the Hook
		257288, -- Heavy Slash
		},
		["Dread Captain Lockwood"] = {
		order = 2, ejid = 2173,
		256076, -- Gut Shot
		},
		["Hadal Darkfathom"] = {
		order = 3, ejid = 2134,
		257882, -- Break Water
		257862, -- Crashing Tide
		},
		["Viq'Goth"] = {
		order = 4, ejid = 2140,
		274991, -- Putrid Waters
		},
	},
	[1041] = {
		{ id = 1041, name = "Kings' Rest" },
		["The Golden Serpent"] = {
		order = 1, ejid = 2165,
		265773, -- Spit Gold
		265914, -- Molten Gold
		},
		["Mchimba the Embalmer"] = {
		order = 2, ejid = 2171,
		267626, -- Dessication
		267702, -- Entomb
		267764, -- Struggle
		267639, -- Burn Corruption
		},
		["The Council of Tribes"] = {
		order = 3, ejid = 2170,
		267273, -- Poison Nova
		266238, -- Shattered Defenses
		266231, -- Severing Axe
		267257, -- Thundering Crash
		},
		["Dazar, The First King"] = {
		order = 4, ejid = 2172,
		268932, -- Quaking Leap
		268586, -- Blade Combo
		},
	},
	[1012] = {
		{ id = 1012, name = "The MOTHERLODE!!" },
		["Coin-Operated Crowd Pummeler"] = {
		order = 1, ejid = 2109,
		256137, -- Timed Detonation
		257333, -- Shocking Claw
		},
		["Azerokk"] = {
		order = 2, ejid = 2114,
		257582, -- Raging Gaze
		258627, -- Resonant Quake
		},
		["Rixxa Fluxflame"] = {
		order = 3, ejid = 2115,
		258971, -- Azerite Catalyst
		259940, -- Propellant Blast
		},
		["Mogul Razdunk"] = {
		order = 4, ejid = 2116,
		260811, -- Homing Missile
		},
	},
	[0] = { -- EJ_GetInstanceForMap() returns 0 for azeroth world maps, not 1028.
		{ id = 1028, name = "Azeroth", raid = true },
		["T'zane"] = {
		order = 1, ejid = 2139,
		261605, -- Consuming Spirits
		261552, -- Terror Wail
		},
		["Ji'arak"] = {
		order = 2, ejid = 2141,
		260989, -- Storm Wing
		261509, -- Clutch
		},
		["Hailstone Construct"] = {
		order = 3, ejid = 2197,
		274895, -- Freezing Tempest
		274891, -- Glacial Breath
		},
		["Azurethos, The Winged Typhoon"] = {
		order = 4, ejid = 2199,
		274839, -- Azurethos' Fury
		},
		["Doom's Howl"] = {
		order = 5, ejid = 2213,
		271244, -- Demolisher Cannon
		},
		["Warbringer Yenajz"] = {
		order = 6, ejid = 2198,
		274932, -- Endless Abyss
		274904, -- Reality Tear
		},
		["Dunegorger Kraulok"] = {
		order = 7, ejid = 2210,
		275175, -- Sonic Bellow
		},
	},
	[1031] = {
		{ id = 1031, name = "Uldir", raid = true },
		["Taloc"] = {
		order = 1, ejid = 2168,
		271222, -- Plasma Discharge
		270290, -- Blood Storm
		275270, -- Fixate
		},
		["MOTHER"] = {
		order = 2, ejid = 2167,
		267821, -- Defense Grid
		267787, -- Sanitizing Strike
		268095, -- Cleansing Purge
		268198, -- Clinging Corruption		
		268253, -- Surgical Beam
		268277, -- Purifying Flame
		},
		["Fetid Devourer"] = {
		order = 3, ejid = 2146,
		262313, -- Malodorous Miasma
		262314, -- Putrid Paroxysm
		262292, -- Rotting Regurgitation
		},
		["Zek'voz, Herald of N'zoth"] = {
		order = 4, ejid = 2169,
		265360, -- Roiling Deceit
		265662, -- Corruptor's Pact
		265237, -- Shatter
		265264, -- Void Lash
		265646, -- Will of the Corruptor		
		},
		["Vectis"] = {
		order = 5, ejid = 2166,
		265129, -- Omega Vector
		265178, -- Evolving Affliction
		265212, -- Gestate
		265127, -- Lingering Infection
		265206, -- Immunosuppression
		},
		["Zul, Reborn"] = {
		order = 6, ejid = 2195,
		273365, -- Dark Revelation
		274358, -- Rupturing Blood
		274271, -- Deathwish
		273434, -- Pit of Despair
		274195, -- Corrupted Blood
		272018, -- Absorbed in Darkness		
		},
		["Mythrax the Unraveler"] = {
		order = 7, ejid = 2194,
		272336, -- Annihilation
		272536, -- Imminent Ruin
		274693, -- Essence Shear
		272407, -- Oblivion Sphere		
		},
		["G'huun"] = {
		order = 8, ejid = 2147,
		263334, -- Putrid Blood
		263372, -- Power Matrix
		263436, -- Imperfect Physiology
		272506, -- Explosive Corruption
		267409, -- Dark Bargain
		267430, -- Torment
		263235, -- Blood Feast
		270287, -- Blighted Ground		
		},
	},
}
