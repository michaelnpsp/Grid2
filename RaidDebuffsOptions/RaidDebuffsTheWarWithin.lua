if Grid2.versionCli<110000 then return end

local RDDB = Grid2Options:GetRaidDebuffsTable()
RDDB["The War Within"] = {
	-- 5 man instances
	[1271] = {
		{ id = 1271, name = "Ara-Kara, City of Echoes" },
		["Avanoxx"] = {
		order = 1, ejid = 2583,
		446788, --Insatiable
		438476, --Alerting Shrill
		438490, --Hunger
		438473, --Gossamer Onslaught
		434830, --Vile Webbing
		436614, --Web Wrap
		438471, --Voracious Bite
		},
		["Anub'zekt"] = {
		order = 2, ejid = 2584,
		433766, --Eye of the Swarm
		442210, --Silken Restraints
		433740, --Infestation
		433747, --Ceaseless Swarm
		433677, --Burrow Charge
		433425, --Impale
		},
		["Ki'katal the Harvester"] = {
		order = 3, ejid = 2585,
		432031, --Grasping Blood
		432117, --Cosmic Singularity
		432119, --Faded
		461487, --Cultivated Poisons
		432227, --Venom Volley
		432130, --Erupting Webs
		},
		["Trash"] = {
		order = 4, ejid = nil,
		433843, -- Erupting Webs
		434252, -- Massive Slam
		448248, -- Revolting Volley
		433841, -- Venom Volley
		436322, -- Poisen Bolt
		436401, -- AUGH!
		438599, -- Bleeding Jab
		438825, -- Poisonous Cloud
		},
	},
	[1272] = {
		{ id = 1272, name = "Cinderbrew Meadery" },
		["Brew Master Aldryr"] = {
		order = 1, ejid = 2586,
		442525, --Happy Hour
		442611, --Disregard
		445180, --Crawling Brawl
		431896, --Rowdy Yell
		432198, --Blazing Belch
		432182, --Throw Cinderbrew
		432196, --Hot Honey
		432229, --Keg Smash
		},
		["I'pa"] = {
		order = 2, ejid = 2587,
		439365, --Spouting Stout
		441171, --Oozing Honey
		440104, --Fill 'Er Up
		442122, --Frothy
		448718, --Reform
		439202, --Burning Fermentation
		439031, --Bottoms Uppercut
		},
		["Benk Buzzbee"] = {
		order = 3, ejid = 2588,
		438025, --Snack Time
		438971, --Shredding Sting
		438763, --Bee-Haw!
		440134, --Honey Marinade
		443983, --Honey Gorged
		439524, --Fluttering Wing
		},
		["Goldie Baronbottom"] = {
		order = 4, ejid = 2589,
		435567, --Spread the Love!
		435788, --Cinder-BOOM!
		435789, --Cindering Wounds
		435622, --Let It Hail!
		436640, --Burning Ricochet
		436592, --Cash Cannon
		},
	},
	[1274] = {
		{ id = 1274, name = "City of Threads" },
		["Orator Krix'vizk"] = {
		order = 1, ejid = 2594,
		434710, --Chains of Oppression
		434722, --Subjugate
		434779, --Terrorize
		448561, --Shadows of Doubt
		434829, --Vociferous Indoctrination
		434926, --Lingering Influence
		},
		["Fangs of the Queen"] = {
		order = 2, ejid = 2595,
		439518, --Twin Fangs
		439522, --Synergic Step
		439621, --Shade Slash
		439637, --Echoing Shade
		439692, --Duskbringer
		440218, --Ice Sickles
		440107, --Knife Throw
		440468, --Rime Dagger
		440470, --Freezing Blood
		458741, --Frozen Solid
		},
		["The Coaglamation"] = {
		order = 3, ejid = 2600,
		441216, --Viscous Darkness
		442285, --Corrupted Coating
		461842, --Oozing Smash
		461880, --Blood Surge
		437533, --Dark Pulse
		},
		["Izo, the Grand Splicer"] = {
		order = 4, ejid = 2596,
		439401, --Shifting Anomalies
		439341, --Splice
		437700, --Tremor Slam
		450042, --Gorge
		450047, --Gorged
		450055, --Gutburst
		438860, --Umbral Weave
		439646, --Process of Elimination
		},
		["Trash"] = {
		order = 5, ejid = nil,
		443401, -- Venom Strike
		443437, -- Shadow of Doubt
		443438, -- Doubt
		450783, -- Perfume Toss
		443432, -- Silken Binding
		446718, -- Umbral Weave
		443435, -- Twist Thoughts
		448047, -- Web Wrap
		451426, -- Gossamer Barrage
		461630, -- Venomous Spray
		451239, -- Brutal Jab
		451295, -- Void Rush
		452151, -- Rigorous Jab
		443509, -- Ravenous Swarm
		445812, -- Dark Barrage
		443427, -- Web Bolt
		451309, -- Eye of the Queen
		},
	},
	[1210] = {
		{ id = 1210, name = "Darkflame Cleft" },
		["Ol' Waxbeard"] = {
		order = 1, ejid = 2569,
		422150, --Reckless Charge
		422270, --Cave-In
		422245, --Rock Buster
		421875, --"Kol"-to-Arms
		422682, --Crude Weapons
		428268, --Underhanded Track-tics
		422162, --Luring Candleflame
		},
		["Blazikon"] = {
		order = 2, ejid = 2559,
		421638, --Wicklighter Barrage
		422700, --Extinguishing Gust
		424223, --Incite Flames
		423099, --Enkindling Inferno
		425394, --Dousing Breath
		443835, --Blazing Storms
		},
		["The Candle King"] = {
		order = 3, ejid = 2560,
		420659, --Eerie Molds
		421648, --Cursed Wax
		421277, --Darkflame Pickaxe
		426145, --Paranoid Mind
		420696, --Throw Darkflame
		421067, --Molten Wax
		},
		["The Darkness"] = {
		order = 4, ejid = 2561,
		422806, --Smothering Shadows
		426943, --Rising Gloom
		426866, --Candlelight
		426941, --Wax Lump
		428266, --Eternal Darkness
		427157, --Call Darkspawn
		427176, --Drain Light
		427100, --Umbral Slash
		427011, --Shadowblast
		},
	},
	[1267] = {
		{ id = 1267, name = "Priory of the Sacred Flame" },
		["Captain Dailcry"] = {
		order = 1, ejid = 2571,
		447439, --Savage Mauling
		424419, --Battle Cry
		447272, --Hurl Spear
		424414, --Pierce Armor
		424628, --Strength in Numbers
		448385, --Bound by Fate
		424621, --Brutal Smash
		424423, --Lunging Strike
		424431, --Holy Radiance
		448515, --Divine Judgment
		427583, --Repentance
		424462, --Ember Storm
		424420, --Cinderblast
		424421, --Fireball
		},
		["Baron Braunpyke"] = {
		order = 2, ejid = 2570,
		422969, --Vindictive Wrath
		423015, --Castigator's Shield
		423019, --Castigator's Detonation
		423051, --Burning Light
		423062, --Hammer of Purity
		446368, --Sacred Pyre
		},
		["Prioress Murrpray"] = {
		order = 3, ejid = 2573,
		423588, --Barrier of Light
		423665, --Embrace the Light
		425544, --Purifying Light
		423539, --Inner Light
		451606, --Holy Flame
		423536, --Holy Smite
		},
		["Trash"] = {
		order = 4, ejid = nil,
		426964, --Mortal Strike
		},
	},
	[1270] = {
		{ id = 1270, name = "The Dawnbreaker" },
		["Speaker Shadowcrown"] = {
		order = 1, ejid = 2580,
		451026, --Darkness Comes
		449042, --Radiant Light
		449332, --Encroaching Shadows
		452001, --Light Fragment
		425264, --Obsidian Blast
		453212, --Obsidian Beam
		426712, --Collapsing Darkness
		453140, --Collapsing Night
		426734, --Burning Shadows
		426736, --Shadow Shroud
		428086, --Shadow Bolt
		},
		["Anub'ikkaj"] = {
		order = 2, ejid = 2581,
		427192, --Empowered Might
		426860, --Dark Orb
		427378, --Dark Scars
		427001, --Terrifying Slam
		426787, --Shadowy Decay
		452127, --Animate Shadows
		452099, --Congealed Darkness
		},
		["Rasha'nan"] = {
		order = 3, ejid = 2593,
		434655, --Arathi Bombs
		434668, --Sparking Arathi Bomb
		438946, --Throw Arathi Bomb
		434407, --Rolling Acid
		434579, --Corrosion
		434576, --Acidic Stupor
		448213, --Expel Webs
		448888, --Erosive Spray
		463428, --Lingering Erosion
		449042, --Radiant Light
		449332, --Encroaching Shadows
		452001, --Light Fragment
		449734, --Acidic Eruption
		434089, --Spinneret's Strands
		434119, --Spinneret's Websnap
		434096, --Sticky Webs
		438957, --Acid Pools
		435793, --Tacky Burst
		},
		["Trash"] = {
		order = 4, ejid = nil,
		451115, -- Terrifying Slam
		432448, -- Stygian Seed
		451107, -- Bursting Cocoon
		451098, -- Tacky Nova
		431309, -- Ensnaring Shadows
		431350, -- Tormenting Eruption
		431365, -- Tormenting Ray
		431491, -- Tainted Slash
		451119, -- Abyssal Blast
		453345, -- Abyssal Rot
		449332, -- Encroaching Shadows
		},
	},
	[1268] = {
		{ id = 1268, name = "The Rookery" },
		["Kyrioss"] = {
		order = 1, ejid = 2566,
		424148, --Chain Lightning
		420739, --Unstable Charge
		444250, --Lightning Torrent
		419871, --Lightning Dash
		444324, --Stormheart
		444411, --Thunderbolt
		},
		["Stormguard Gorren"] = {
		order = 2, ejid = 2567,
		424737, --Chaotic Corruption
		424797, --Chaotic Vulnerability
		425048, --Dark Gravity
		424958, --Crush Reality
		426136, --Reality Tear
		424966, --Lingering Void
		},
		["Voidstone Monstrosity"] = {
		order = 3, ejid = 2568,
		423305, --Null Upheaval
		433067, --Seeping Fragment
		458088, --Stormrider's Charge
		445262, --Void Shell
		424371, --Storm's Vengeance
		423839, --Electrocuted
		428269, --Reshape
		429028, --Corruption Pulse
		429487, --Unleash Corruption
		445457, --Oblivion Wave
		423393, --Entropy
		},
	},
	[1269] = {
		{ id = 1269, name = "The Stonevault" },
		["E.D.N.A."] = {
		order = 1, ejid = 2572,
		424903, --Volatile Spike
		424805, --Refracting Beam
		424879, --Earth Shatterer
		424888, --Seismic Smash
		424889, --Seismic Reverberation
		424893, --Stone Shield
		},
		["Skarmorak"] = {
		order = 2, ejid = 2579,
		423200, --Fortified Shell
		423324, --Void Discharge
		422233, --Crystalline Smash
		443494, --Crystalline Eruption
		423538, --Unstable Crash
		443405, --Unstable Fragments
		435813, --Unstable Energy
		},
		["Master Machinists"] = {
		order = 3, ejid = 2590,
		439577, --Silenced Speaker
		443954, --Exhaust Vents
		429999, --Flaming Scrap
		428202, --Scrap Song
		428547, --Scrap Cube
		428161, --Molten Metal
		428508, --Blazing Crescendo
		464392, --Blazing Shrapnel
		463057, --Magma Wave
		428711, --Igneous Hammer
		428120, --Lava Cannon
		},
		["Void Speaker Eirich"] = {
		order = 4, ejid = 2582,
		427315, --Void Rift
		427329, --Void Corruption
		427854, --Entropic Reckoning
		457465, --Entropy
		427869, --Unbridled Void
		},
		["Trash"] = {
		order = 5, ejid = nil,
		449455, -- Howling Fear
		429545, -- Censoring gear
		448975, -- Shield Stampede
		425027, -- Seismic Wave
		426308, -- Void Infection
		427361, -- Fracture
		428887, -- Smashed
		449154, -- Molten Mortar
		445207, -- Piercing Wail
		464879, -- Concussive Smash
		425974, -- Ground Pound
		},
	},
	[1298] = {
		{ id = 1298, name = "Operation: Floodgate" },
		["Big M.O.M.M.A."] = {
		order = 1, ejid = 2648,
		460156, --Jumpstart
		473287, --Excessive Electrification
		471585, --Mobilize Mechadrones
		1214780, --Maximum Distortion
		460393, --Shoot
		472452, --Doom Storm
		473351, --Electrocrush
		473220, --Sonic Boom
		469981, --Kill-o-Block Barrier
		},
		["Demolition Duo"] = {
		order = 2, ejid = 2649,
		460867, --Big Bada BOOM!
		460787, --Deflagration
		472755, --Shrapnel
		1217653, --B.B.B.F.G.
		460602, --Quick Shot
		473690, --Kinetic Explosive Gel
		459779, --Barreling Charge
		459799, --Wallop
		470090, --Divided Duo
		},
		["Swampface"] = {
		order = 3, ejid = 2650,
		470039, --Razorchoke Vines
		473070, --Awaken the Swamp
		473047, --Skewering Root
		473052, --Rushing Tide
		473112, --Mudslide
		469478, --Sludge Claws
		},
		["Geezle Gigazap"] = {
		order = 4, ejid = 2651,
		465456, --Turbo Charge
		466088, --Turbo Bolt
		468276, --Dam!
		468261, --Dam Water
		468661, --Shock Water
		468606, --Dam Rubble
		468846, --Leaping Sparks
		468812, --Gigazap
		466197, --Thunder Punch
		},
	},
	[1303] = {
		{ id = 1303, name = "Eco-Dome Al'dani" },
		["Azhiccar"] = {
		order = 1, ejid = 2675,
		1217232, --Devour
		1217241, --Feast
		1217327, --Invading Shriek
		1231811, --Uncontrolled
		1217381, --Engorge
		1217436, --Toxic Regurgitation
		1217446, --Digestive Spittle
		1217664, --Thrash
		},
		["Taah'bat and A'wazj"] = {
		order = 2, ejid = 2676,
		1219417, --Beastmaster's Bond
		1219700, --Arcane Blitz
		1219457, --Incorporeal
		1219731, --Destabilized
		1220497, --Arcane Overload
		1227137, --Warp Strike
		1219536, --Binding Javelin
		1219482, --Rift Claws
		},
		["Soul-Scribe"] = {
		order = 3, ejid = 2677,
		1224793, --Whispers of Fate
		1224865, --Fatebound
		1236703, --Eternal Weave
		1237184, --Splinters of Fate
		1225218, --Dread of the Unknown
		1226444, --Wounded Fate
		1225162, --Ceremonial Dagger
		1242000, --Echoes of Fate
		},
	},
	-- Raid instances
	[1278] = {
		{ id = 1278, name = "Khaz Algar", raid = true },
		["Kordac, the Dormant Protector"] = {
		order = 1, ejid = 2637,
		458423, --Arcane Bombardment
		458209, --Overcharged Lasers
		458799, --Overcharged Earth
		459281, --Empowering Coalescence
		458320, --Titanic Impact
		458838, --Supression Burst
		},
		["Aggregation of Horrors"] = {
		order = 2, ejid = 2635,
		452210, --Crystalline Barrage
		453271, --Dark Awakening
		452981, --Voidquake
		453294, --Crystal Strike
		456148, --Annihilation Barrage
		},
		["Shurrai, Atrocity of the Undersea"] = {
		order = 3, ejid = 2636,
		453607, --Abyssal Strike
		453733, --Briny Vomit
		455275, --Dark Tide
		453875, --Regurgitate Souls
		455639, --Shroud of the Drowned
		453863, --Ocean's Reckoning
		},
		["Orta, the Broken Mountain"] = {
		order = 4, ejid = 2625,
		450454, --Tectonic Roar
		450407, --Colossal Slam
		450677, --Rupturing Runes
		450929, --Mountain's Grasp
		451702, --Discard Weaklings
		},
	},
	[1273] = {
		{ id = 1273, name = "Nerub-ar Palace", raid = true },
		["Ulgrax the Devourer"] = {
		order = 1, ejid = 2607,
		434776, --Carnivorous Contest
		440904, --Devour
		455847, --Battered and Bruised
		440849, --Contemptful Rage
		441451, --Stalker's Webbing
		439419, --Stalker's Netting
		455831, --Hardened Netting
		435138, --Digestive Acid
		435136, --Venomous Lash
		434697, --Brutal Crush
		434705, --Tenderized
		435341, --Hulking Crash
		440177, --Ready to Feed
		438012, --Hungering Bellows
		438041, --Insatiable Rage
		436255, --Juggernaut Charge
		439037, --Disembowel
		438657, --Chunky Viscera
		438324, --Feed
		455870, --Bioactive Spines
		443842, --Swallowing Darkness
		},
		["The Bloodbound Horror"] = {
		order = 2, ejid = 2611,
		444363, --Gruesome Disgorge
		462306, --The Unseeming
		451288, --Black Bulwark
		445016, --Spectral Slam
		445174, --Manifest Horror
		445257, --Blood Pact
		445570, --Unseeming Blight
		452237, --Bloodcurdle
		445936, --Spewing Hemorrhage
		442530, --Goresplatter
		461876, --Seeping Transfusion
		443305, --Crimson Rain
		443042, --Grasp From Beyond
		438696, --Black Sepsis
		},
		["Sikran, Captain of the Sureki"] = {
		order = 3, ejid = 2599,
		433475, --Phase Blades
		458272, --Cosmic Simulacrum
		459273, --Cosmic Shards
		459785, --Cosmic Residue
		461401, --Collapsing Nova
		442428, --Decimate
		456420, --Shattering Sweep
		439511, --Captain's Flourish
		435401, --Expose
		432969, --Phase Lunge
		439559, --Rain of Arrows
		},
		["Rasha'nan"] = {
		order = 4, ejid = 2609,
		439789, --Rolling Acid
		439785, --Corrosion
		439787, --Acidic Stupor
		439776, --Acid Pools
		439784, --Spinneret's Strands
		439778, --Spinneret's Websnap
		460789, --Tacky Threads
		439780, --Sticky Webs
		439815, --Infested Spawn
		455287, --Infested Bite
		454989, --Enveloping Webs
		444687, --Savage Assault
		458067, --Savage Wound
		439795, --Web Reave
		439811, --Erosive Spray
		440193, --Lingering Erosion
		452806, --Acidic Eruption
		457877, --Acidic Carapace
		444094, --Caustic Hail
		439792, --Tacky Burst
		},
		["Broodtwister Ovi'nax"] = {
		order = 5, ejid = 2612,
		442526, --Experimental Dosage
		446694, --Mutation: Necrotic
		438807, --Vicious Bite
		458212, --Necrotic Wound
		446690, --Mutation: Ravenous
		446700, --Poison Burst
		442263, --Mutation: Accelerated
		442251, --Fixate
		442257, --Infest
		442430, --Ingest Black Blood
		450362, --Unstable Infusion
		441612, --Vile Discharge
		452802, --Catalyze Mutation
		442799, --Sanguine Overflow
		450661, --Caustic Reaction
		446349, --Sticky Web
		446351, --Web Eruption
		441362, --Volatile Concoction
		},
		["Nexus-Princess Ky'veza"] = {
		order = 6, ejid = 2601,
		436867, --Assassination
		437343, --Queensbane
		439409, --Dark Viscera
		437620, --Nether Rift
		437786, --Atomized
		439576, --Nexus Daggers
		436950, --Stalking Shadows
		448364, --Death Masks
		447174, --Death Cloak
		438245, --Twilight Massacre
		436749, --Reaper
		440377, --Void Shredders
		440576, --Chasmal Gash
		435414, --Starless Night
		442278, --Eternal Night
		435486, --Regicide
		434645, --Eclipse
		},
		["The Silken Court"] = {
		order = 7, ejid = 2608,
		455796, --Whispers of The Silken Court
		455849, --Mark of Paranoia
		460357, --Mote of Overwrought Paranoia
		460359, --Void Degeneration
		455850, --Mark of Rage
		460263, --Mote of Unrelenting Rage
		460281, --Burning Rage
		455863, --Mark of Death
		455363, --Queen's Proclamation
		440158, --Reckless Charge
		460360, --Burrowed Eruption
		438801, --Call of the Swarm
		438706, --Harden Carapace
		438773, --Shattered Shell
		455080, --Scarab Lord's Perseverance
		440504, --Impaling Eruption
		449857, --Impaled
		438218, --Piercing Strike
		439992, --Web Bomb
		440001, --Binding Webs
		440179, --Entangled
		438656, --Venomous Rain
		450045, --Skittering Leap
		438200, --Poison Bolt
		450980, --Shatter Existence
		460600, --Entropic Barrage
		463461, --Entropic Vulnerability
		438677, --Stinging Swarm
		449993, --Stinging Burst
		456235, --Stinging Delirium
		438355, --Cataclysmic Entropy
		441634, --Web Vortex
		450129, --Entropic Desolation
		441782, --Strands of Reality
		450483, --Void Step
		441772, --Void Bolt
		451277, --Spike Storm
		460364, --Seismic Upheaval
		463464, --Seismic Vulnerability
		443092, --Spike Eruption
		443063, --Unleashed Swarm
		},
		["Queen Ansurek"] = {
		order = 8, ejid = 2602,
		437592, --Reactive Toxin
		438846, --Reactive Froth
		451278, --Concentrated Toxin
		464628, --Reaction Trauma
		464638, --Frothy Toxin
		464643, --Lingering Toxin
		460133, --Toxic Reaction
		438481, --Toxic Waves
		437078, --Acid
		437417, --Venom Nova
		441556, --Reaction Vapor
		439814, --Silken Tomb
		441958, --Grasping Silk
		440899, --Liquefy
		441084, --Acid Explosion
		437093, --Feast
		439299, --Web Blades
		440607, --Acrid Presence
		447076, --Predation
		447170, --Predation Threads
		447456, --Paralyzing Venom
		451607, --Paralyzing Waves
		447411, --Wrest
		447240, --Devour
		460366, --Shadowgate
		464056, --Gloom Touch
		447983, --Gloom Blast
		443403, --Gloom
		460218, --Shadowy Distortion
		448660, --Acid Bolt
		449940, --Acidic Apocalypse
		447950, --Shadowblast
		447999, --Radiating Gloom
		448176, --Gloom Orbs
		448046, --Gloom Eruption
		448300, --Echoing Connection
		448488, --Worshipper's Protection
		462541, --Cosmic Rupture
		464799, --Lingering Fallout
		462564, --Cosmic Fallout
		448458, --Cosmic Apocalypse
		448147, --Oust
		460315, --Ousting Fragments
		451600, --Expulsion Beam
		455374, --Dark Detonation
		449235, --Caustic Fangs
		443888, --Abyssal Infusion
		443915, --Abyssal Conduit
		455387, --Abyssal Reverberation
		444507, --Conduit Ejections
		444502, --Conduit Collapse
		445422, --Frothing Gluttony
		445623, --Glutton Threads
		445877, --Froth Vapor
		461408, --Consume
		444829, --Queen's Summons
		445152, --Acolyte's Essence
		446012, --Essence Scarred
		445013, --Dark Barrier
		445021, --Null Detonation
		438976, --Royal Condemnation
		441865, --Royal Shackles
		441872, --Royal Cocoon
		443325, --Infest
		443667, --Infested Gloomburst
		443720, --Gloom Hatchling
		443336, --Gorge
		443396, --Gloom Splatter
		445268, --Dreadful Presence
		451832, --Cataclysmic Evolution
		},
	},
	[1296] = {
		{ id = 1296, name = "Liberation of Undermine", raid = true },
		["Vexie and the Geargrinders"] = {
		order = 1, ejid = 2639,
		466615, --Protective Plating
		471403, --Unrelenting CAR-nage
		459943, --Call Bikers
		1216731, --Oil Canister
		473507, --Soaked in Oil
		459679, --Oil Slick
		459453, --Blaze of Glory
		460625, --Burning Shrapnel
		459994, --Hot Wheels
		459666, --Spew Oil
		468207, --Incendiary Fire
		459974, --Bomb Voyage!
		459627, --Tank Buster
		468147, --Exhaust Fumes
		460603, --Mechanical Breakdown
		460386, --Backfire
		460116, --Tune-Up
		473636, --High Maintenance
		460153, --Repair
		},
		["Cauldron of Carnage"] = {
		order = 2, ejid = 2640,
		465833, --Colossal Clash
		463800, --Zapbolt
		465446, --Fiery Wave
		1221826, --Tiny Tussle
		471660, --Raised Guard
		471557, --King of Carnage
		472220, --Blistering Spite
		473650, --Scrapbomb
		1214039, --Molten Pool
		1213688, --Molten Phlegm
		472231, --Blastburn Roarcannon
		1214190, --Eruption Stomp
		472223, --Galvanized Spite
		1218088, --Tempest Unleashed
		473951, --Static Charge
		473983, --Static Discharge
		463840, --Thunderdrum Salvo
		1213994, --Voltaic Image
		463925, --Lingering Electricity
		466178, --Lightning Bash
		},
		["Rik Reverb"] = {
		order = 3, ejid = 2641,
		473748, --Amplification!
		1214829, --Feedback Nullifier
		1217120, --Lingering Voltage
		468119, --Resonant Echoes
		1214598, --Entranced
		465795, --Noise Pollution
		466093, --Haywire
		466866, --Echoing Chant
		467606, --Sound Cannon
		466961, --Faulty Zap
		467297, --Static Jolt
		472306, --Sparkblast Ignition
		472294, --Grand Finale
		1214164, --Excitement
		466128, --Resonance
		464488, --Sonic Blast
		464518, --Tinnitus
		466722, --Blowout!
		1213817, --Sound Cloud
		467991, --Blaring Drop
		473655, --Hype Fever!
		},
		["Stix Bunkjunker"] = {
		order = 4, ejid = 2642,
		464399, --Electromagnetic Sorting
		461536, --Rolling Rubbish
		465741, --Garbage Dump
		1217685, --Messed Up
		465611, --Rolled!
		464854, --Garbage Pile
		464865, --Discarded Doomsplosive
		1217975, --Doomsploded
		465747, --Muffled Doomsplosion
		473066, --Territorial
		473115, --Short Fuse
		1218706, --Prototype Powercoil
		1218708, --Hypercharged
		1219384, --Scrap Rockets
		466742, --Dumpster Dive
		1220752, --The Recycler
		466748, --Infected Bite
		464149, --Incinerator
		472893, --Incineration
		464248, --Hot Garbage
		1218343, --Toxic Fumes
		464112, --Demolish
		1217954, --Meltdown
		467117, --Overdrive
		467149, --Overcharged Bolt
		467135, --Trash Compactor
		473227, --Maximum Output
		},
		["Sprocketmonger Lockenstock"] = {
		order = 5, ejid = 2653,
		473276, --Activate Inventions!
		1216414, --Blazing Beam
		1216525, --Rocket Barrage
		1215858, --Mega Magnetize
		1216674, --Jumbo Void Beam
		1216699, --Void Barrage
		1217673, --Voidsplash
		1216802, --Polarization Generator
		1216911, --Posi-Polarization
		1216934, --Nega-Polarization
		1216965, --Polarization Blast
		1217083, --Foot-Blasters
		1219047, --Polarized Catastro-Blast
		1216406, --Unstable Explosion
		1218342, --Unstable Shrapnel
		466235, --Wire Transfer
		1216508, --Screw Up
		1217261, --Screwed!
		465232, --Sonic Ba-Boom
		471308, --Blisterizer Mk. II
		1214872, --Pyro Party Pack
		465917, --Gravi-Gunk
		466765, --Beta Launch
		466860, --Bleeding Edge
		1218319, --Voidsplosion
		1214265, --Black Bloodsplatter
		1218344, --Upgraded Bloodtech
		},
		["The One-Armed Bandit"] = {
		order = 6, ejid = 2644,
		461060, --Spin To Win!
		461068, --Fraud Detected!
		461083, --Reward: Shock and Flame
		474731, --Traveling Flames
		473009, --Explosive Shrapnel
		461091, --Reward: Shock and Bomb
		467870, --Explosive Gaze
		461176, --Reward: Flame and Bomb
		472178, --Burning Blast
		461389, --Reward: Flame and Coin
		461101, --Reward: Coin and Shock
		474665, --Coin Magnet
		461395, --Reward: Coin and Bomb
		460973, --Dark Lined Cuirass
		460582, --Overload!
		472197, --Withering Flames
		460847, --Electric Blast
		464705, --Golden Ticket
		460181, --Pay-Line
		460444, --High Roller!
		460430, --Crushed!
		472718, --Up the Ante
		460164, --Foul Exhaust
		460472, --The Big Hit
		460474, --Shocking Field
		465309, --Cheat to Win!
		465432, --Linked Machines
		473178, --Voltaic Streak
		465322, --Hot Hot Heat
		465580, --Scattered Payout
		465587, --Explosive Jackpot
		},
		["Mug'Zee, Heads of Security"] = {
		order = 7, ejid = 2645,
		466376, --Head Honcho
		466385, --Moxie
		468658, --Elemental Carnage
		468663, --Elemental Calamity
		468694, --Uncontrolled Destruction
		469715, --Uncontrolled Burn
		1216142, --Double-Minded Fury
		472631, --Earthshaker Gaol
		1214623, --Enraged
		472659, --Shakedown
		472782, --Pay Respects
		470910, --Gaol Break
		474554, --Shaken Earth
		466476, --Frostshatter Boots
		466480, --Frostshatter Spear
		466509, --Stormfury Finger Gun
		466516, --Stormfury Cloud
		466518, --Molten Gold Knuckles
		467202, --Golden Drip
		467225, --Solid Gold
		470089, --Molten Gold Pool
		466539, --Unstable Crawler Mines
		469043, --Searing Shrapnel
		1219283, --Experimental Plating
		1220551, --Unstable Cluster Bomb
		467381, --Goblin-guided Rocket
		1215488, --Disintegration Beam
		1216202, --Rocket Jump
		472057, --Hot Mess
		469076, --Radiation Sickness
		466545, --Spray and Pray
		1214991, --Surging Arc
		1215591, --Faulty Wiring
		1222948, --Electro-Charged Shield
		469490, --Double Whammy Shot
		469391, --Perforating Wound
		469375, --Explosive Payload
		1216495, --Electrocution Matrix
		1215953, --Static Charge
		471574, --Bulletstorm
		463967, --Bloodlust
		},
		["Chrome King Gallywix"] = {
		order = 8, ejid = 2646,
		466340, --Scatterblast Canisters
		1220761, --Mechengineer's Canisters
		474447, --Canister Detonation
		465952, --Big Bad Buncha Bombs
		466154, --Blast Burns
		466153, --Bad Belated Boom
		466158, --Sapper's Satchel
		1217290, --Another in the Bag
		466165, --1500-Pound "Dud"
		466246, --Focused Detonation
		1217292, --Time-Release Crackle
		466338, --Zagging Zizzler
		467182, --Suppression
		466751, --Venting Heat
		466753, --Overheating
		471225, --Gatling Cannon
		1220290, --Trick Shots
		469286, --Giga Coils
		469327, --Giga Blast
		469404, --Giga BOOM!
		469297, --Sabotaged Controls
		1220846, --Control Meltdown
		1215209, --Sabotage Zone
		1219313, --Overloaded Bolts
		466341, --Fused Canisters
		469362, --Charged Giga Bomb
		469363, --Fling Giga Bomb
		469767, --Giga Bomb Detonation
		471352, --Juice It!
		1223126, --Party Crashing Rocket
		466834, --Shock Barrage
		1216845, --Wrench
		1216852, --Lumbering Rage
		1214226, --Cratering
		1214229, --Armageddon-class Plating
		1219319, --Radiant Electricity
		1219278, --Gallybux Pest Eliminator
		1214369, --TOTAL DESTRUCTION!!!
		1214607, --Bigger Badder Bomb Blast
		1214755, --Overloaded Rockets
		466342, --Tick-Tock Canisters
		1219333, --Gallybux Finale Blast
		466958, --Ego Check
		467064, --Checked Ego
		1217987, --Combination Canisters
		1218504, --Giga Blast Residue
		1218992, --Discharged Giga Bomb
		1220784, --Auto-Locking Cuff Bomb
		1219039, --Ionization
		1219041, --Static Zap
		},
	},
	[1302] = {
		{ id = 1302, name = "Manaforge Omega", raid = true },
		["Plexus Sentinel"] = {
		order = 1, ejid = 2684,
		1218148, --Phase Blink
		1217649, --Arcanomatrix Atomizer
		1219223, --Atomize
		1219248, --Arcane Radiation
		1227794, --Arcane Lightning
		1234733, --Cleanse the Chamber
		1219532, --Eradicating Salvo
		1219450, --Manifest Matrices
		1218626, --Displacement Matrix
		1219354, --Potent Mana Residue
		1219263, --Obliteration Arcanocannon
		1223364, --Powered Automaton
		1220489, --Protocol: Purge
		1218669, --Energy Cutter
		1233110, --Purging Lightning
		1219471, --Expulsion Zone
		1235816, --Energy Overload
		},
		["Loom'ithar"] = {
		order = 2, ejid = 2686,
		1237272, --Lair Weaving
		1238502, --Woven Ward
		1247672, --Infusion Pylons
		1247029, --Excess Nova
		1247045, --Hyper Infusion
		1226315, --Infusion Tether
		1226366, --Living Silk
		1226721, --Silken Snare
		1226395, --Overinfusion Burst
		1226867, --Primal Spellstorm
		1231408, --Arcane Overflow
		1227263, --Piercing Strand
		1231403, --Silk Blast
		1228059, --Unbound Rage
		1243771, --Arcane Ichor
		1227782, --Arcane Outrage
		1227226, --Writhing Wave
		1242303, --Writhing Swathe
		},
		["Soulbinder Naazindhri"] = {
		order = 3, ejid = 2685,
		1225582, --Soul Calling
		1239988, --Soulweave
		1227048, --Voidblade Ambush
		1227052, --Void Burst
		1242018, --Void Resonance
		1235576, --Phase Blades
		1227848, --Essence Implosion
		1227276, --Soulfray Annihilation
		1246530, --Arcane Sigils
		1246775, --Shatterpulse
		1223859, --Arcane Expulsion
		1242086, --Arcane Energy
		1225616, --Soulfire Convergence
		1226827, --Soulrend Orb
		1240754, --Spellburn
		1241100, --Mystic Lash
		},
		["Forgeweaver Araz"] = {
		order = 4, ejid = 2687,
		1231720, --Invoke Collector
		1228214, --Astral Harvest
		1236207, --Astral Surge
		1237322, --Prime Sequence
		1228103, --Arcane Siphon
		1231726, --Arcane Barrier
		1248171, --Void Tear
		1245640, --Power Manifested
		1228218, --Arcane Obliteration
		1238867, --Echoing Invocation
		1238874, --Echoing Tempest
		1228454, --Mark of Power
		1228219, --Astral Mark
		1228188, --Silencing Tempest
		1228502, --Overwhelming Power
		1227631, --Arcane Expulsion
		1248009, --Dark Terminus
		1240705, --Astral Burn
		1232409, --Unstable Surge
		1234328, --Photon Blast
		1226260, --Arcane Convergence
		1243272, --Containment Breach
		1232738, --Hardened Shell
		1238266, --Ramping Power
		1233415, --Mana Splinter
		1232412, --Focusing Iris
		1233076, --Dark Singularity
		1233074, --Crushing Darkness
		1243901, --Void Harvest
		1243641, --Void Surge
		1232221, --Death Throes
		},
		["The Soul Hunters"] = {
		order = 5, ejid = 2688,
		1222232, --Devourer's Ire
		1234565, --Consume
		1222310, --Unending Hunger
		1227355, --Voidstep
		1227685, --Hungering Slash
		1235045, --Encroaching Oblivion
		1245743, --Eradicate
		1227809, --The Hunt
		1247415, --Weakened Prey
		1241306, --Blade Dance
		1218103, --Eye Beam
		1221490, --Fel-Singed
		1225127, --Felblade
		1223725, --Fel Inferno
		1241833, --Fracture
		1226493, --Shattered Soul
		1241917, --Frailty
		1242259, --Spirit Bomb
		1242284, --Soulcrush
		1242304, --Expulsed Soul
		1240891, --Sigil of Chains
		1225154, --Immolation Aura
		1249198, --Unstable Soul
		1233093, --Collapsing Star
		1233105, --Dark Residue
		1233968, --Event Horizon
		1245978, --Soul Tether
		1233863, --Fel Rush
		1227113, --Infernal Strike
		1227117, --Fel Devastation
		1233381, --Withering Flames
		},
		["Fractillus"] = {
		order = 6, ejid = 2747,
		1233657, --Nether Prism
		1226089, --Crystal Nexus
		1232130, --Nexus Shrapnel
		1236784, --Brittle Nexus
		1232760, --Crystal Lacerations
		1236785, --Void-Infused Nexus
		1247424, --Null Consumption
		1247495, --Null Explosion
		1233917, --Crystaline Overcharge
		1224414, --Crystalline Shockwave
		1220394, --Shattering Backhand
		1227373, --Shattershell
		1227378, --Crystal Encasement
		1231871, --Shockwave Slam
		},
		["Nexus-King Salhadaar"] = {
		order = 7, ejid = 2690,
		1224731, --Decree: Oath-Bound
		1224767, --King's Thrall
		1224764, --Oath-Breaker
		1224906, --Invoke the Oath
		1238975, --Vengeful Oath
		1224776, --Subjugation Rule
		1224787, --Conquer
		1224812, --Vanquish
		1227529, --Banishment
		1224822, --Tyranny
		1225099, --Fractal Images
		1247215, --Fractal Claw
		1224827, --Behead
		1231097, --Cosmic Rip
		1227330, --Besiege
		1227891, --Coalesce Voidwing
		1228113, --Netherbreaker
		1228163, --Dimension Breath
		1234539, --Dimension Glare
		1234529, --Cosmic Maw
		1228065, --Rally the Shadowguard
		1230302, --Self-Destruct
		1232399, --Dread Mortar
		1237105, --Twilight Barrier
		1228075, --Nexus Beams
		1230261, --Netherblast
		1237107, --Twilight Massacre
		1250044, --Taking Aim
		1228053, --Reap
		1232327, --Seal the Forge
		1228284, --Royal Ward
		1228265, --King's Hunger
		1226648, --Galactic Smash
		1248137, --Dark Star
		1225444, --Atomized
		1225645, --Twilight Spikes
		1226384, --Dark Orbit
		1226879, --Stars Collide
		1234906, --Nexus Collapse
		1226362, --Twilight Scar
		1226417, --Starshattered
		1226347, --Starkiller Swing
		1226042, --Starkiller Nova
		1225634, --World in Twilight
		},
		["Dimensius, the All-Devouring"] = {
		order = 8, ejid = 2691,
		1229327, --Oblivion
		1230087, --Massive Smash
		1231005, --Fission
		1228206, --Excess Mass
		1228207, --Collective Gravity
		1230168, --Mortal Fragility
		1248240, --Infinite Possibilities
		1229038, --Devour
		1229674, --Growing Hunger
		1230979, --Dark Matter
		1231002, --Dark Energy
		1243690, --Shattered Space
		1243704, --Antimatter
		1243699, --Spatial Fragment
		1243577, --Reverse Gravity
		1243609, --Airborne
		1250614, --Anomalous Force
		1227665, --Fists of the Voidlord
		1228367, --Cosmic Radiation
		1235114, --Soaring Reshii
		1235467, --Umbral Gate
		1241188, --Endless Darkness
		1237080, --Broken World
		1235490, --Astrophysical Jet
		1232987, --Black Hole
		1230674, --Spaghettification
		1246930, --Stellar Core
		1246948, --Shooting Star
		1238765, --Extinction
		1237319, --Gamma Burst
		1234242, --Gravitational Distortion
		1234243, --Crushing Gravity
		1234251, --Crushed
		1234244, --Inverse Gravity
		1237690, --Eclipse
		1237694, --Mass Ejection
		1237696, --Debris Field
		1249423, --Mass Destruction
		1239262, --Conqueror's Cross
		1239270, --Voidwarding
		1246537, --Entropic Unity
		1246541, --Null Binding
		1249248, --Boundless
		1246143, --Touch of Oblivion
		1237695, --Stardust Nova
		1249454, --Starshard Nova
		1254385, --Starshard
		1254384, --Star Burst
		1245292, --Destabilized
		1233292, --Accretion Disk
		1231716, --Extinguish The Stars
		1232394, --Gravity Well
		1248479, --Stellar Overload
		1233557, --Density
		1232973, --Supernova
		1234052, --Darkened Sky
		1234054, --Shadowquake
		1234263, --Cosmic Collapse
		1234266, --Cosmic Fragility
		1250055, --Voidgrasp
		},
	},
}
