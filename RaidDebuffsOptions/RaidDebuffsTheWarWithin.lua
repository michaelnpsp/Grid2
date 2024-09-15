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
}
