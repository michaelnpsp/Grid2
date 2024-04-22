if Grid2.isClassic then return end

local RDDB = Grid2Options:GetRaidDebuffsTable()
RDDB["Dragonflight"] = {
	-- 5 man instances
	[1196] = {
		{ id = 1196, name = "Brackenhide Hollow" },
		["Hackclaw's War-Band"] = {
		order = 1, ejid = 2471,
		378020, --gash-frenzy
		381379, --decayed-senses
		377844, -- Bladestorm
		381835, -- Bladestorm
		381466, -- Hextrick
		381461, -- Savage Charge
		378229, -- Marked for Butchery
		},
		["Treemouth"] = {
		order = 2, ejid = 2473,
		377864, --infectious-spit
		378054, --withering-away
		378022, --consuming
		376933, --grasping-vines
		383875, -- Partially Digested
			},
		["Gutshot"] = {
		order = 3, ejid = 2472,
		376997, --savage-peck
		384425, -- Smell Like Meat
		385356, -- Ensnaring Trap
		},
		["Decatriarch Wratheye"] = {
		order = 4, ejid = 2474,
		373896, --withering-rot
		373917, -- Decaystrike
		},
		["Trash"] = {
		order = 5, ejid = nil,
		375416, -- Bleeding
		367481, -- Bloody Bite
		367521, -- Bone Bolt
		384558, -- Bounding Leap
		382593, -- Crushing Smash
		382787, -- Decay Claws
		373899, -- Decaying Roots
		385185, -- Disoriented
		373872, -- Gushing Ooze
		367500, -- Hideous Cackle
		368091, -- Infected Bite
		382805, -- Necrotic Breath
		373943, -- Stomp
		367485, -- Vicious Clawmangle
		368081, -- Withering
		396305, -- Withering Contagion
		},
	},
	[1197] = {
		{ id = 1197, name = "Uldaman: Legacy of Tyr" },
		["The Lost Dwarves"] = {
		order = 1, ejid = 2475,
		377825, --burning-pitch
		375286, --searing-cannonfire
		369791, -- Skullcracker
		},
		["Bromach"] = {
		order = 2, ejid = 2487,
		369660, --tremor
		},
		["Sentinel Talondras"] = {
		order = 3, ejid = 2484,
		372652, --resonating-orb
		372718, -- Earthen Shards
		},
		["Emberon"] = {
		order = 4, ejid = 2476,
		369110, --unstable-embers
		369025, --fire-wave
		369006, -- Burning Heat
		},
		["Chrono-Lord Deios"] = {
		order = 5, ejid = 2479,
		376325, --eternity-zone
		377405, --time-sink
		},
		["Trash"] = {
		order = 5, ejid = nil,
		369811, -- Brutal Slam
		369828, -- Chomp
		369365, -- Curse of Stone
		369337, -- Difficult Terrain
		369818, -- Diseased Bite
		377732, -- Jagged Bite
		382576, -- Scorn of Tyr
		369791, -- Skullcracker
		369411, -- Sonic Burst
		377510, -- Stolen Time
		377486, -- Time Blade
		369419, -- Venomous Fangs
		},
	},
	[1198] = {
		{ id = 1198, name = "The Nokhud Offensive" },
		["The Raging Tempest"] = {
		order = 2, ejid = 2497,
		384185, -- Lightning Strike
		386916, -- The Raging Tempest
		382628, -- Surge of Power
		384620, -- Electrical Storm
		},
		["Teera and Maruuk"] = {
		order = 3, ejid = 2478,
		392151, -- Gale Arrow
		395669, -- Aftershock
		386063, -- Frightful Roar
		},
		["Balakar Khan"] = {
		order = 4, ejid = 2477,
		375937, -- Rending Strike
		376634, -- Iron Spear
		393421, -- Quake
		376730, -- Stormwinds
		376827, -- Conductive Strike
		376864, -- Static Spear
		376894, -- Crackling Upheaval
		376899, -- Crackling Cloud
		},
		["Trash"] = {
		order = 5, ejid = nil,
		384134, -- Pierce
		381692, -- Swift Stab
		334610, -- Hunt Prey
		384336, -- War Stomp
		384492, -- Hunter's Mark
		386025, -- Tempest
		386912, -- Stormsurge Cloud
		388801, -- Mortal Strike
		387615, -- Grasp of the Dead
		387616, -- Grasp of the Dead
		381530, -- Storm Shock
		373395, -- Bloodcurdling Shout
		387629, -- Rotting Wind
		395035, -- Shatter Soul
		384365, -- Disruptive Shout
		436841, -- Rotting Wind
		387826, -- Sundering Slash
		400474, -- Surge of Power
		386024, -- Tempest
		386028, -- Thunder Clap
		},
	},
	[1199] = {
		{ id = 1199, name = "Neltharus" },
		["Chargath, Bane of Scales"] = {
		order = 1, ejid = 2490,
		374471, --erupted-ground
		374482, --grounding-chain
		373735, -- Dragon Strike
		396332, -- Fiery Focus
		389059, -- Slag Eruption
		},
		["Forgemaster Gorek"] = {
		order = 2, ejid = 2489,
		381482, --forgefire
		392666, -- Blazing Aegis
		374842, -- Blazing Aegis
		},
		["Magmatusk"] = {
		order = 3, ejid = 2494,
		375890, --magma-eruption
		374410, --magma-tentacle
		372461, -- Imbued Magma
		378818, -- Magma Conflagration
		},
		["Warlord Sargha"] = {
		order = 4, ejid = 2501,
		377522, --burning-pursuit
		376784, --flame-vulnerability
		377018, --molten-gold
		377022, --hardened-gold
		377542, --burning-ground
		391762, -- Curse of the Dragon Hoard
		},
		["Trash"] = {
		order = 5, ejid = nil,
		377522, -- Burning Pursuit
		372224, -- Dragonbone Axe
		372461, -- Imbued Magma
		378818, -- Magma Conflagration
		378221, -- Molten Vulnerability
		384161, -- Mote of Combustion
		372971, -- Reverberating Slam
		},
	},
	[1201] = {
		{ id = 1201, name = "Algeth'ar Academy" },
		["Vexamus"] = {
		order = 1, ejid = 2509,
		391977, -- Oversurge
		386181, -- Mana Bomb
		386201, -- Corrupted Mana
		},
		["Overgrown Ancient"] = {
		order = 2, ejid = 2512,
		388544, -- Barkbreaker
		396716, -- Splinterbark
		389033, -- Lasher Toxin
		},
		["Crawth"] = {
		order = 3, ejid = 2495,
		397210, -- Sonic Vulnerability
		376449, -- Firestorm
		376997, -- Savage Peck
		},
		["Echo of Doragosa"] = {
		order = 4, ejid = 2514,
		374350, -- Energy Bomb
		},
		["Trash"] = {
		order = 5, ejid = nil,
		390918, -- Seed Detonation
		377344, -- Peck
		388912, -- Severing Slash
		388866, -- Mana Void
		388984, -- Vicious Ambush
		388392, -- Monotonous Lecture
		387932, -- Astral Whirlwind
		378011, -- Deadly Winds
		387843, -- Astral Bomb
		},
	},
	[1202] = {
		{ id = 1202, name = "Ruby Life Pools" },
		["Melidrussa Chillworn"] = {
		order = 1, ejid = 2488,
		385518, -- Chillstorm
		372963, -- Chillstorm
		372682, -- Primal Chill
		378968, -- Flame Patch
		373022, -- Frozen Solid
		},
		["Kokia Blazehoof"] = {
		order = 2, ejid = 2485,
		372860, -- Searing Wounds
		372820, -- Scorched Earth
		372811, -- Molten Boulder
		384823, -- Inferno
		},
		["Kyrakka and Erkhart Stormvein"] = {
		order = 3, ejid = 2503,
		381526, -- Roaring Firebreath
		381862, -- Infernocore
		381515, -- Stormslam
		381518, -- Winds of Change
		384773, -- Flaming Embers
		},
		["Trash"] = {
		order = 4, ejid = nil,
		372697, -- Jagged Earth
		372047, -- Steel Barrage
		373869, -- Burning Touch
		392641, -- Rolling Thunder
		373693, -- Living Bomb
		373692, -- Inferno
		395292, -- Fire Maw
		372796, -- Blazing Rush
		392406, -- Thunderclap
		392451, -- Flashfire
		392924, -- Shock Blast
		373589, -- Primal Chill
		385536, -- Flame Dance
		391050, -- Tempest Stormshield
		},
	},
	[1203] = {
		{ id = 1203, name = "The Azure Vault" },
		["Leymor"] = {
		order = 1, ejid = 2492,
		374789, -- Infused Strike
		374523, -- Stinging Sap
		374567, -- Explosive Brand
		},
		["Azureblade"] = {
		order = 2, ejid = 2505,
		384625, -- Overwhelming Energy
		389855, -- Unstable Magic
		},
		["Telash Greywing"] = {
		order = 3, ejid = 2483,
		386881, -- Frost Bomb
		387150, -- Frozen Ground
		387151, -- Icy Devastator
		387152, -- Icy Devastator
		388072, -- Vault Rune
		396722, -- Absolute Zero
		},
		["Umbrelskul"] = {
		order = 4, ejid = 2508,
		388777, -- Oppressive Miasma
		384978, -- Dragon Strike
		385331, -- Fracture
		385267, -- Crackling Vortex
		},
		["Trash"] = {
		order = 5, ejid = nil,
		387564, -- Mystic Vapors
		370764, -- Piercing Shards
		375596, -- Erratic Growth
		375602, -- Erratic Growth
		375649, -- Infused Ground
		370766, -- Crystalline Rupture
		371007, -- Splintering Shards
		375591, -- Sappy Burst
		395492, -- Scornful Haste
		395532, -- Sluggish Adoration
		390301, -- Hardening Scales
		386549, -- Waking Bane
		371352, -- Forbidden Knowledge
		377488, -- Icy Bindings
		386640, -- Tear Flesh
		371358, -- Forbidden Knowledge
		377488, -- Icy Bindings
		386536, -- Null Stomp
		436652, -- Shoulder Slam
		},
	},
	[1204] = {
		{ id = 1204, name = "Halls of Infusion" },
		["Watcher Irideus"] = {
		order = 1, ejid = 2504,
		384524, -- titanic-fist
		383935, -- spark-volley
		389179, -- power-overload
		389181, -- power-field
		389443, -- Purifying Blast
		},
		["Gulping Goliath"] = {
		order = 2, ejid = 2507,
		374389, -- gulp-swog-toxin
		385551, -- gulp
		385451, -- toxic-effluvia
		},
		["Khajin the Unyielding"] = {
		order = 3, ejid = 2510,
		385963, -- frost-shock
		386741, -- polar-winds
		},
		["Primal Tsunami"] = {
		order = 4, ejid = 2511,
		387359, -- waterlogged
		387571, -- focused-deluge
		},
		["Trash"] = {
		order = 5, ejid = nil,
		374020, -- containment-beam
		393444, -- gushing-wound
		374706, -- pyretic-burst
		374149, -- tailwind
		374615, -- cheap-shot
		374563, -- dazzle
		374724, -- molten-subduction
		391634, -- Deep Chill
		374339, -- Demoralizing Shout
		375384, -- Rumbling Earth
		},
	},
	[1209] = {
		{ id = 1209, name = "Dawn of the Infinite" },
		["Chronikar"] = {
		order = 1, ejid = 2521,
		413105, --Eon Shatter
		403486, --Eon Residue
		403259, --Residue Blast
		405970, --Eon Fragments
		413013, --Chronoshear
		413041, --Sheared Lifespan
		401421, --Sand Stomp
		401794, --Withering Sandpool
		},
		["Manifested Timeways"] = {
		order = 2, ejid = 2528,
		403910, --Decaying Time
		403912, --Accelerating Time
		404141, --Chrono-faded
		405448, --Chronofade
		405431, --Fragments of Time
		414303, --Unwind
		414307, --Radiant
		},
		["Blight of Galakrond"] = {
		order = 3, ejid = 2535,
		406886, --Corrosive Infusion
		407406, --Corrosion
		418346, --Corrupted Mind
		407027, --Corrosive Expulsion
		407159, --Blight Reclamation
		407057, --Blight Seep
		407978, --Necrotic Winds
		413608, --Essence Connection
		408029, --Necrofrost
		408141, --Incinerating Blightbreath
		413590, --Noxious Ejection
		},
		["Iridikron the Stonescaled"] = {
		order = 4, ejid = 2537,
		409261, --Extinction Blast
		414330, --Timeline Protection
		414353, --Exhausted
		414496, --Timeline Acceleration
		414535, --Stonecracker Barrage
		414552, --Stonecrack
		409456, --Earthsurge
		409287, --Rending Earthspikes
		414376, --Punctured Ground
		409635, --Pulverizing Exhalation
		409884, --Pulverizing Creations
		416256, --Stonebolt
		409692, --Patient Tactician
		414184, --Cataclysmic Obliteration
		414293, --Timeline Transcendence
		414075, --Crushing Onslaught
		},
		["Tyr, the Infinite Keeper"] = {
		order = 5, ejid = 2526,
		404296, --Infinite Hand Technique
		410240, --Titanic Blow
		403724, --Consecrated Ground
		401463, --Infinite Annihilation
		400641, --Dividing Strike
		408183, --Titanic Empowerment
		400649, --Spark of Tyr
		408768, --Siphon Oathstone
		410249, --Radiant Barrier
		404315, --Temporal Essence
		406543, --Stolen Time
		},
		["Morchie"] = {
		order = 6, ejid = 2536,
		404916, --Sand Blast
		403891, --More Problems!
		404365, --Dragon's Breath
		413208, --Sand Buffeted
		405279, --Familiar Faces
		401197, --Fixate
		412768, --Anachronistic Decay
		406481, --Time Traps
		401667, --Time Stasis
		406100, --Temporal Backlash
		},
		["Time-Lost Battlefield"] = {
		order = 7, ejid = 2533,
		407120, --Serrated Axe
		406962, --Axe Throw
		407122, --Rain of Fire
		407121, --Immolate
		410234, --Bladestorm
		410254, --Decapitate
		410497, --Mortal Wounds
		419602, --Thirst for Battle
		408227, --Shockwave
		418046, --FOR THE HORDE!
		410496, --War Cry
		},
		["Chrono-Lord Deios"] = {
		order = 8, ejid = 2538,
		416152, --Summon Infinite Keeper
		416261, --Collapsing Time Rift
		412027, --Chronal Burn
		411763, --Infinite Blast
		410911, --Time-Displaced Trooper
		411023, --Time-Displacement
		410904, --Infinity Orb
		410908, --Infinity Nova
		416139, --Temporal Breath
		416264, --Infinite Corruption
		417413, --Temporal Scar
		},
		["Trash"] = {
		412044, -- Temposlice
		411994, -- Chronomelt
		415436, -- Tainted Sands
		415554, -- Chronoburst
		415437, -- Enervate
		413547, -- Bloom
		413529, -- Untwist
		412810, -- Blight Spew
		412285, -- Stonebolt
		412505, -- Rending Cleave
		413606, -- Corroding Volley
		414922, -- Shrouding Sandstorm
		412922, -- Binding Grasp
		412131, -- Orb of Contemplation
		413027, -- Titanic Bulwark
		413618, -- Timeless Curse
		419351, -- Bronze Exhalation
		418092, -- Twisted Timeways
		418200, -- Infinite Burn
		413427, -- Time Beam
		419511, -- Temporal Link
		419517, -- Chronal Eruption
		407125, -- Sundering Slam
		407651, -- Sapper’s Perogative
		407715, -- Kaboom!
		407906, -- Earthquake
		407123, -- Rain of Fire
		411700, -- Slobbering Bite
		411644, -- Soggy Bonk
		412262, -- Staticky Punch
		407313, -- Shrapnel
		},
	},
	-- World Bosses
	[102444] = {
		{ id = 1205, name = "Dragon Isles", raid = true },
		["Strunraan, The Sky's Misery"] = {
		order = 1, ejid = 2515,
		387265, -- overcharge
		},
		["Basrikron, The Shale Wing"] = {
		order = 2, ejid = 2506,
		385137, -- shale-breath
		},
		["Bazual, The Dreaded Flame"] = {
		order = 3, ejid = 2517,
		389368, -- magma-eruption
		391257, -- searing-heat
		},
		["Liskanoth, The Futurebane"] = {
		order = 4, ejid = 2518,
		388767, -- binding-ice
		389287, -- glacial-storm
		389762, -- deep-freeze
		388924, -- biting-frost
		},
	},
	-- Raid instances
	[1200] = {
		{ id = 1200, name = "Vault of the Incarnates", raid = true },
		["Eranog"] = {
		order = 1, ejid = 2480,
		370597, --kill-order
		371059, --melting-armor
		371955, --rising-heat
		370410, --pulsing-flames
		},
		["Terros"] = {
		order = 2, ejid = 2500,
		376276, --concussive-slam
		382776, --awakened-earth
		381576, --seismic-assault
		},
		["The Primal Council"] = {
		order = 3, ejid = 2486,
		371591, --frost-tomb
		371857, --shivering-lance
		371624, --conductive-mark
		372056, --crush
		374792, --faultline
		372027, --slashing-blaze
		},
		["Sennarth, the Cold Breath"] = {
		order = 4, ejid = 2482,
		372736, --permafrost
		372648, --pervasive-cold
		373817, --chilling-aura
		372129, --web-blast
		372044, --wrapped-in-webs
		372082, --enveloping-webs
		371976, --chilling-blast
		372030, --sticky-webbing
		372055, --icy-ground
		},
		["Dathea, Ascended"] = {
		order = 5, ejid = 2502,
		378095, --crushing-atmosphere
		377819, --lingering-slash
		374900, --microburst
		376802, --razor-winds
		375580, --zephyr-slam
		},
		["Kurog Grimtotem"] = {
		order = 6, ejid = 2491,
		374864, --primal-break
		372158, --sundering-strike
		373681, --biting-chill
		373487, --lightning-crash
		372514, --frost-bite
		372517, --frozen-solid
		377780, --skeletal-fractures
		374623, --frost-binds
		374554, --lava-pool
		},
		["Broodkeeper Diurna"] = {
		order = 7, ejid = 2493,
		378782, --mortal-wounds
		375829, --clutchwatchers-rage
		378787, --crushing-stoneclaws
		375871, --wildfire
		376266, --burrowing-strike
		375575, --flame-sentry
		375475, --rending-bite
		375457, --chilling-tantrum
		375653, --static-jolt
		376392, --disoriented
		375876, --icy-shards
		375430, --sever-tendon
		},
		["Raszageth the Storm-Eater"] = {
		order = 8, ejid = 2499,
		381615, --static-charge
		377594, --lightning-breath
		381249, --electrifying-presence
		},
	},
	[1208] = {
		{ id = 1208, name = "Aberrus, the Shadowed Crucible", raid = true },
		["Kazzara, the Hellforged"] = {
		order = 1, ejid = 2522,
		400432, --hellbeam
		403326, --wings-of-extinction
		404744, --terror-claws
		407196, --dread-rifts
		},
		["The Amalgamation Chamber"] = {
		order = 2, ejid = 2529,
		401809, -- corrupting-shadow
		402617, -- blazing-heat
		406780, -- shadowflame-contamination
		405641, -- blistering-twilight
		408219, -- convergent-eruption
		405914, -- withering-vulnerability
		405016, -- umbral-detonation
		},
		["The Forgotten Experiments"] = {
		order = 3, ejid = 2530,
		406358, --rending-charge
		406305, --infused-strikes
		405042, --unstable-essence
		405383, --violent-eruption
		407617, --temporal-anomaly
		405391, --disintegrate
		},
		["Assault of the Zaqali"] = {
		order = 4, ejid = 2524,
		404687, --barrier-backfire
		398938, --devastating-leap
		401258, --heavy-cudgel
		397383, --molten-barrier
		401401, --blazing-spear
		408624, --scorching-roar
		401867, --volcanic-shield
		404687, --barrier-backfire
		},
		["Rashok, the Elder"] = {
		order = 5, ejid = 2525,
		405316, --ancient-fury
		406851, --doom-flames
		403543, --lava-wave
		401419, --elders-conduit
		},
		["The Vigilant Steward, Zskarn"] = {
		order = 6, ejid = 2532,
		405462, --dragonfire-traps
		404955, --shrapnel-bomb
		404007, --unstable-embers
		403978, --blast-wave
		404942, --searing-claws
		},
		["Magmorax"] = {
		order = 7, ejid = 2527,
		408359, --catastrophic-eruption
		402989, --molten-spittle
		409853, --igniting-roar
		401348, --incinerating-maws
		},
		["Echo of Neltharion"] = {
		order = 8, ejid = 2523,
		401022, --calamitous-strike
		403057, --surrender-to-corruption
		407793, --sunder-shadow
		407917, --ebon-destruction
		401825, --shatter
		410972, --corruption
		},
		["Scalecommander Sarkareth"] = {
		order = 9, ejid = 2520,
		401951, --oblivion
		401215, --emptiness-between-stars
		413070, --destabilize
		407576, --astral-flare
		401383, --oppressing-howl
		410247, --echoing-howl
		401819, --glittering-surge
		401905, --dazzled
		406989, --burning-ground
		401525, --scorching-detonation
		401718, --disintegrated
		402051, --searing-breath
		402052, --seared
		402746, --drifting-embers
		401325, --burning-claws
		404154, --void-surge
		404218, --void-fracture
		404769, --empty-strike
		404288, --infinite-duress
		404269, --ebon-might
		403497, --astral-formation
		413106, --void-might
		},
	},
	[1207] = {
		{ id = 1207, name = "Amirdrassil, the Dream's Hope", raid = true },
		["Gnarlroot"] = {
		order = 1, ejid = 2564,
		421971, --Controlled Burn
		422023, --Shadow-Scorched Earth
		422026, --Tortured Scream
		421038, --Ember-Charred
		426548, --Searing Bramble
		421840, --Uprooted Agony
		422053, --Shadow Spines*
		425816, --Blazing Pollen*
		425819, --Flaming Sap*
		424352, --Dreadfire Barrage*
		},
		["Igira the Cruel"] = {
		order = 2, ejid = 2554,
		414340, --Drenched Blades
		414770, --Blistering Torment
		414367, --Gathering Torment
		419462, --Flesh Mortification
		423715, --Searing Sparks
		416056, --Umbral Destruction
		429277, --Brutalized
		426017, --Vital Rupture
		422776, --Marked for Torment*
		415624, --Heart Stopper*
		414425, --Blistering Spear*
		},
		["Volcoross"] = {
		order = 3, ejid = 2557,
		421082, --Hellboil
		427201, --Coiling Eruption
		423494, --Tidal Blaze
		419054, --Molten Venom
		421284, --Coiling Flames*
		420934, --Flood of the Firelands*
		421672, --Serpent's Fury*
		},
		["Council of Dreams"] = {
		order = 4, ejid = 2555,
		420856, --Poisonous Javelin
		421292, --Constricting Thicket
		426390, --Corrosive Pollen
		421032, --Captivating Finale
		418720, --Polymorph Bomb
		427602, --Hungry
		427010, --Satiated
		420409, --Quack!
		424269, --Slippery
		421024, --Emerald Winds
		423551, --Whimsical Gust
		420671, --Noxious Blossom*
		421020, --Agonizing Claws*
		420937, --Relentless Barrage*
		423522, --Unstable Venom*
		},
		["Larodar, Keeper of the Flame"] = {
		order = 5, ejid = 2553,
		425889, --Igniting Growth
		425531, --Dream Fatigue
		418522, --Blistering Splinters
		426387, --Scorching Bramblethorn
		419485, --Nature's Bulwark+
		423719, --Nature's Fury
		429032, --Everlasting Blaze
		427306, --Encased in Ash
		427343, --Fire Whirl
		421594, --Smoldering Suffocation
		428946, --Ashen Asphyxiation
		421323, --Searing Ash
		},
		["Nymue, Weaver of the Cycle"] = {
		order = 6, ejid = 2556,
		429785, --Impending Loom
		430563, --Ephemeral Flora
		430485, --Reclamation
		425357, --Surging Growth
		420907, --Viridian Rain
		423195, --Inflorescence+
		428273, --Woven Resonance?
		423369, --Barrier Blossom
		421368, --Unravel
		428479, --Lucid Vulnerability
		423842, --Verdant Rend
		418423, --Verdant Matrix*
		420846, --Continuum*
		428012, --Lucid Miasma*
		},
		["Smolderon"] = {
		order = 7, ejid = 2563,
		421656, --Cauterizing Wound
		421643, --Emberscar's Mark
		430325, --Inferno
		421532, --Smoldering Ground
		421858, --Ignited Essence
		421455, --Overheated*
		422577, --Searing Aftermath*
		426018, --Seeking Inferno*
		420950, --Blistering Heat*
		425574, --Lingering Burn*
		},
		["Tindral Sageswift, Seer of the Flame"] = {
		order = 8, ejid = 2565,
		424495, --Mass Entanglement
		424581, --Fiery Growth
		424499, --Scorching Ground
		424582, --Lingering Cinder
		422000, --Searing Wrath
		427297, --Flame Surge
		425657, --Fallen Feather
		429166, --Astral Heat
		424579, --Suppressive Ember
		430583, --Germinating Aura
		424258, --Dream Essence+
		429740, --Pulsing Heat+
		421884, --Emerald Gale+
		422509, --Empowered Feather+
		426687, --Poisonous Mushroom*
		421398, --Fire Beam*
		424665, --Seed of Flame*
		422325, --Flaming Tree*
		},
		["Fyrakk the Blazing"] = {
		order = 9, ejid = 2519,
		425483, --Incinerated
		417807, --Aflame
		417443, --Fyr'alath's Mark
		429903, --Flamebound
		429906, --Shadowbound
		419123, --Flamefall
		423601, --Seed of Amirdrassil+
		423717, --Bloom+
		430048, --Corrupted Seed
		430045, --Corruption
		426368, --Darkflame Cleave*
		417455, --Dream Rend*
		410223, --Shadowflame Breath*
		429866, --Shadowflame Eruption*
		422836, --Burning Scales*
		428971, --Molten Eruption*
		428400, --Exploding Core*
		428968, --Shadow Cage*
		422524, --Shadowflame Devastation*
		430051, --Searing Screams*
		422837, --Apocalypse Roar*
		425492, --Infernal Maw*
		},
	},
}
