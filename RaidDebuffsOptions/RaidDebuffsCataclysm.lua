if Grid2.isClassic then return end

local RDDB= Grid2Options:GetRaidDebuffsTable()

RDDB["Cataclysm"] = {
	[100669] = {
		{ id = 73, name = "Blackwing Descent" },
		["Magmaw"]= {
		order = 2, ejid = 170,
		89773, -- Mangle
		88287, -- Massive Crash
        78199, -- Sweltering Armor
		},
		["Omnitron Defense System"]= {
		order = 1, ejid = 169,
		79889, -- Lightning Conductor
		80161, -- Chemical Cloud
		80011, -- Soaked in Poison
		91829, -- Fixate
        92053, -- Shadow Conductor
        92048, -- Shadow Infusion
        92023, -- Encasing Shadows
		},
		["Maloriak"]= {
		order = 5, ejid = 173,
		78225, -- Acid Nova
		92910, -- Debilitating Slime
		77786, -- Consuming Flames
		91829, -- Fixate
		77760, -- Biting Chill
		77699, -- Flash Freeze
		},
		["Atremedes"]= {
		order = 3, ejid = 171,
		78092, -- Tracking
		77840, -- Searing
		78353, -- Roaring Flame
		78897, -- Noisy
		},
		["Chimaeron"]= {
		order = 4, ejid = 172,
		89084, -- Low Health
		82934, -- Mortality
		82881, -- Break
        91307, -- Mocking Shadows
		},
		["Nefarian"]={
		order = 6, ejid = 174,
		77827, -- Tail Lash
        79339, -- Explosive Cinders
        79318, -- Dominion
		},
	},
	[100671] = {
		{ id = 72, name = "The Bastion of Twilight" },
		["Halfus Wyrmbreaker"]= {
		order = 1, ejid = 156,
		83710, -- Furious Roar
		83908, -- Malevolent Strike
		83603, -- Stone Touch
		},
		["Valiona & Theralion"]= {
		order = 2, ejid = 157,
		86788, -- Blackout
		86360, -- Twilight Shift
        86014, -- Twilight Meteorite
		},
		["Ascendant Council"]= {
		order = 3, ejid = 158,
		82762, -- Waterlogged
		83099, -- Lightning Rod
		82285, -- Elemental Stasis
		82660, -- Burning Blood
		82665, -- Heart of Ice
        82772, -- Frozen
        84948, -- Gravity Crush
        83500, -- Swirling Winds
        83581, -- Grounded
        92307, -- Frost Beacon
		},
		["Cho'gall"]= {
		order = 4, ejid = 167,
        81836, -- Corruption: Accelerated
        82125, -- Corruption: Malformation
        82170, -- Corruption: Absolute
		82523, -- Gall's Blast
		82518, -- Cho's Blast
		},
		["Sinestra"]= {
		order = 5, ejid = 168,
		89299, -- Twilight Spit
		},
	},
	[100754] = {
		{ id = 74, name = "Throne of the Four Winds" },
		["Conclave of Wind"]= {
		order = 1, ejid = 154,
		84645, -- Wind Chill
		86107, -- Ice Patch
		86082, -- Permafrost
		84643, -- Hurricane
		86281, -- Toxic Spores
		85573, -- Deafening Winds
		85576, -- Withering Winds
		},
		["Al'Akir"]= {
		order = 2, ejid = 155,
		88290, -- Acid Rain
		87873, -- Static Shock
		88427, -- Electrocute
		89668, -- Lightning Rod
        87856, -- Squall Line
		},
	},
    [100757] = {
        { id = 75, name = "Baradin Hold" },
        ["Argaloth"]= {
		order = 1, ejid = 139,
        88942, -- Meteor Slash
        88954, -- Consuming Darkness
        },
		["Occu'thar"] = {
		order = 2, ejid = 140,
		96913, -- Searing Shadows
		},
		["Alizabal"] = {
		order = 3, ejid = 339,
		104936, -- Skewer
		105067, -- Seething Hate
		},
    },
	[100720] = {
		{ id = 78, name = "Firelands" },
		["Beth'tilac"]= {
		order = 1, ejid = 192,
		49026, -- Fixate
		97079, -- Seeping Venom
		97202, -- Fiery Web Spin
		99506, -- Widow Kiss
		},
		["Lord Rhyolith"]= {
		order = 2, ejid = 193,
		98492, -- Eruption
		},
		["Alysrazor"]= {
		order = 3, ejid = 194,
		100094, -- Fireblast
		99389,  -- Imprinted
		99308,  -- Gushing Wound
		100640, -- Harsh Winds
		100555, -- Souldering Roots
		},
		["Shannox"]= {
		order = 4, ejid = 195,
		99936,	-- Jagged Tear
		99837,  -- Crustal Prison
		99840,  -- Magma Rupture
		},
		["Baleroc"]= {
		order = 5, ejid = 196,
		99252,  -- Blaze of Glory
		99256,  -- Torment
		99516,  -- Count Down
		},
		["Majordomo Staghelm"]= {
		order = 6, ejid = 197,
		98443,  -- Fiery Cylcone
		98450,	-- Searing Seeds
		98535,  -- Leaping flames
		96993,  -- Stay Withdrawn
		},
		["Ragnaros"]= {
		order = 7, ejid = 198,
		99399,  -- Burning Wound
		100238, -- Magma Trap vulnerability
		98313,  -- Magma blast
		100460, -- Blazing Heat
		98981,  -- Lava Bolt
		99613,  -- Molten Blast
		},
		["Trash"]= {
		76622, -- Sunder Armor
		97151, -- Magma
		99610, -- Shockwave
		99693,  -- Dinner Time
		99695, -- Flaming Spear
		99800, -- Ensnare
		99993,  -- Fiery Blood
		100767, -- Melt Armor
		},
	},
	[100967] = {
		{ id = 187, name = "Dragon Soul" },
		["Morchok"] = {
		order = 1, ejid = 311,
		103687, -- Crush Armor
		},
		["Hagara the Stormbinder"] = {
		order = 4, ejid = 317,
		104451,  -- Ice Tomb
		105285,  -- Target (next Ice Lance)
		105316,  -- Ice Lance
		105289,  -- Shattered Ice
		105259,  -- Watery Entrenchment
		105465,  -- Lightning Storm
		105369,  -- Lightning Conduit
		},
		["Warmaster Blackhorn"] = {
		order = 6, ejid = 332,
		108046, -- Shockwave
		108043, -- Devastate
		107567, -- Brutal strike
		107558, -- Degeneration
		110214, -- Consuming Shroud
		},
		["Ultraxion"] = {
		order = 5, ejid = 331,
		106108, -- Heroic will
		106415, -- Twilight burst
		105927, -- Faded Into Twilight
		106369, -- Twilight shift
		},
		["Yor'sahj the Unsleeping"] = {
		order = 3, ejid = 325,
		104849, -- Void bolt
		109389, -- Deep Corruption
		105695, -- Fixate
		},
		["Warlord Zon'ozz"] = {
		order = 2, ejid = 324,
		103434, -- Disrupting shadows
		},
		["Spine of Deathwing"] = {
		order = 7, ejid = 318,
		105563, -- Grasping Tendrils
		105490, -- Fiery Grip
		105479, -- Searing Plasma
		106199, -- Blood corruption: death
		106200, -- Blood corruption: earth
		106005, -- Degradation
		},
		["Madness of Deathwing"] = {
		order = 8, ejid = 333,
		106794, -- Shrapnel
		106385, -- Crush
		105841, -- Degenerative bite
		105445, -- Blistering heat
		},
	},
	-- 5 man instances
	[66] = {
		{ id = 66, name = "Blackrock Caverns" },
		["Rom'ogg Bonecrusher"] = {
		order = 1, ejid = 105,
		},
		["Corla, Herald of Twilight"] = {
		order = 2, ejid = 106,
		},
		["Karsh Steelbender"] = {
		order = 3, ejid = 107,
		},
		["Beauty"] = {
		order = 4, ejid = 108,
		},
		["Ascendant Lord Obsidius"] = {
		order = 5, ejid = 109,
		},
	},
	[63] = {
		{ id = 63, name = "Deadmines" },
		["Glubtok"] = {
		order = 1, ejid = 89,
		},
		["Helix Gearbreaker"] = {
		order = 2, ejid = 90,
		},
		["Foe Reaper 5000"] = {
		order = 3, ejid = 91,
		},
		["Admiral Ripsnarl"] = {
		order = 4, ejid = 92,
		},
		["Captain Cookie"] = {
		order = 5, ejid = 93,
		},
		["Vanessa VanCleef"] = {
		order = 6, ejid = 95,
		},
	},
	[184] = {
		{ id = 184, name = "End Time" },
		["Echo of Baine"] = {
		order = 1, ejid = 340,
		},
		["Echo of Jaina"] = {
		order = 2, ejid = 285,
		},
		["Echo of Sylvanas"] = {
		order = 3, ejid = 323,
		},
		["Echo of Tyrande"] = {
		order = 4, ejid = 283,
		},
		["Murozond"] = {
		order = 5, ejid = 289,
		},
	},
	[71] = {
		{ id = 71, name = "Grim Batol" },
		["General Umbriss"] = {
		order = 1, ejid = 131,
		},
		["Forgemaster Throngus"] = {
		order = 2, ejid = 132,
		},
		["Drahga Shadowburner"] = {
		order = 3, ejid = 133,
		},
		["Erudax, the Duke of Below"] = {
		order = 4, ejid = 134,
		},
	},
	[70] = {
		{ id = 70, name = "Halls of Origination" },
		["Temple Guardian Anhuur"] = {
		order = 1, ejid = 124,
		},
		["Earthrager Ptah"] = {
		order = 2, ejid = 125,
		},
		["Anraphet"] = {
		order = 3, ejid = 126,
		},
		["Isiset, Construct of Magic"] = {
		order = 4, ejid = 127,
		},
		["Ammunae, Construct of Life"] = {
		order = 5, ejid = 128,
		},
		["Setesh, Construct of Destruction"] = {
		order = 6, ejid = 129,
		},
		["Rajh, Construct of Sun"] = {
		order = 7, ejid = 130,
		},
	},
	[186] = {
		{ id = 186, name = "Hour of Twilight" },
		["Arcurion"] = {
		order = 1, ejid = 322,
		},
		["Asira Dawnslayer"] = {
		order = 2, ejid = 342,
		},
		["Archbishop Benedictus"] = {
		order = 3, ejid = 341,
		},
	},
	[69] = {
		{ id = 69, name = "Lost City of the Tol'vir" },
		["General Husam"] = {
		order = 1, ejid = 117,
		},
		["Lockmaw"] = {
		order = 2, ejid = 118,
		},
		["High Prophet Barim"] = {
		order = 3, ejid = 119,
		},
		["Siamat"] = {
		order = 4, ejid = 122,
		},
	},
	[64] = {
		{ id = 64, name = "Shadowfang Keep" },
		["Baron Ashbury"] = {
		order = 1, ejid = 96,
		},
		["Baron Silverlaine"] = {
		order = 2, ejid = 97,
		},
		["Commander Springvale"] = {
		order = 3, ejid = 98,
		},
		["Lord Walden"] = {
		order = 4, ejid = 99,
		},
		["Lord Godfrey"] = {
		order = 5, ejid = 100,
		},
	},
	[67] = {
		{ id = 67, name = "The Stonecore" },
		["Corborus"] = {
		order = 1, ejid = 110,
		},
		["Slabhide"] = {
		order = 2, ejid = 111,
		},
		["Ozruk"] = {
		order = 3, ejid = 112,
		},
		["High Priestess Azil"] = {
		order = 4, ejid = 113,
		},
	},
	[68] = {
		{ id = 68, name = "The Vortex Pinnacle" },
		["Grand Vizier Ertan"] = {
		order = 1, ejid = 114,
		86267, -- Cyclone Shield
		413158, -- Cyclone Shield Fragment
		413151, -- Summon Tempest
		411001, -- Lethal Current
		},
		["Altairus"] = {
		order = 2, ejid = 115,
		88286, -- Downwind of Altairus
		88282, -- Upwind of Altairus
		413296, -- Downburst
		88308, -- Chilling Breath
		413331, -- Biting Cold
		413275, -- Cold Front
		},
		["Asaad, Caliph of Zephyrs"] = {
		order = 3, ejid = 116,
		87618, -- Static Cling
		87622, -- Chain Lightning
		413263, -- Skyfall Nova
		},
	},
	[65] = {
		{ id = 65, name = "Throne of the Tides" },
		["Lady Naz'jar"] = {
		order = 1, ejid = 101,
		428103, -- Frostbolt
		},
		["Commander Ulthok, the Festering Prince"] = {
		order = 2, ejid = 102,
		427670, -- Crushing Claw
		427668, -- Festering Shockwave
		427559, -- Bubbling Ooze
		},
		["Mindbender Ghur'sha"] = {
		order = 3, ejid = 103,
		429172, -- Terrifying Vision
		429051, -- Earthfury
		429048, -- Flame Shock
		},
		["Ozumat"] = {
		order = 4, ejid = 104,
		428403, -- Grimy
		428404, -- Blotting Darkness
		428868, -- Putrid Roar
		428407, -- Blotting Barrage
		},
		["Trash"]= {
		order = 5, ejid = nil,
		426660, --Razor Jaws
		426663, --Ravenous Pursuit
		76820 , --Hex
		428542, --Crushing Depths
		426741, --Shellbreaker
		426727, --Acid Barrage
		426688, --Volatile Acid
		75992 , --Lightning Surge
		426681, --Electric Jaws
		426783, --Mind Flay
		426808, --Null Blast
		76516 , --Poisoned Spear
		76363 , --Wave of Corruption
		},
	},
	[185] = {
		{ id = 185, name = "Well of Eternity" },
		["Peroth'arn"] = {
		order = 1, ejid = 290,
		},
		["Queen Azshara"] = {
		order = 2, ejid = 291,
		},
		["Mannoroth and Varo'then"] = {
		order = 3, ejid = 292,
		},
	},
	[77] = {
		{ id = 77, name = "Zul'Aman" },
		["Akil'zon"] = {
		order = 1, ejid = 186,
		},
		["Nalorakk"] = {
		order = 2, ejid = 187,
		},
		["Jan'alai"] = {
		order = 3, ejid = 188,
		},
		["Halazzi"] = {
		order = 4, ejid = 189,
		},
		["Hex Lord Malacrass"] = {
		order = 5, ejid = 190,
		},
		["Daakara"] = {
		order = 6, ejid = 191,
		},
	},
	[76] = {
		{ id = 76, name = "Zul'Gurub" },
		["High Priest Venoxis"] = {
		order = 1, ejid = 175,
		},
		["Bloodlord Mandokir"] = {
		order = 2, ejid = 176,
		},
		["Cache of Madness - Gri'lek"] = {
		order = 3, ejid = 177,
		},
		["Cache of Madness - Hazza'rah"] = {
		order = 4, ejid = 178,
		},
		["Cache of Madness - Renataki"] = {
		order = 5, ejid = 179,
		},
		["Cache of Madness - Wushoolay"] = {
		order = 6, ejid = 180,
		},
		["High Priestess Kilnara"] = {
		order = 7, ejid = 181,
		},
		["Zanzil"] = {
		order = 8, ejid = 184,
		},
		["Jin'do the Godbreaker"] = {
		order = 9, ejid = 185,
		},
	},
}
