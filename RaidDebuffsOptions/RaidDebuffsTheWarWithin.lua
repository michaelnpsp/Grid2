if Grid2.isClassic then return end

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
		433425, --Impale
		433677, --Burrow Charge
		433740, --Infestation
		433747, --Ceaseless Swarm
		433766, --Eye of the Swarm
		442210, --Web Wrap
		},
		["Ki'katal the Harvester"] = {
		order = 3, ejid = 2585,
		432031, --Grasping Blood
		432117, --Cosmic Singularity
		432119, --Faded
		432227, --Venom Volley
		432130, --Erupting Webs
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
		439522, --Synergic Step
		439518, --Twin Fangs
		439621, --Shade Slash
		439637, --Echoing Shade
		439692, --Duskbringer
		440218, --Ice Sickles
		440107, --Knife Throw
		440468, --Rime Dagger
		440470, --Freezing Blood
		458741, --Frozen Solid
		440420, --Dark Paranoia
		440419, --Shadow Shunpo
		},
		["The Coaglamation"] = {
		order = 3, ejid = 2600,
		441216, --Viscous Darkness
		442285, --Corrupted Coating
		437533, --Dark Pulse
		445435, --Blood Surge
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
	},
	[1270] = {
		{ id = 1270, name = "The Dawnbreaker" },
		["Shadowcrown"] = {
		order = 1, ejid = 2580,
		451026, --Darkness Comes
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
		427001, --Terrifying Slam
		426860, --Dark Orb
		427378, --Dark Scars
		426787, --Shadowy Decay
		452127, --Animate Shadows
		452099, --Congealed Darkness
		427192, --Empowered Might
		},
		["Rasha'nan"] = {
		order = 3, ejid = 2593,
		434655, --Arathi Bomb
		434726, --Blazing
		434668, --Carrying Arathi Bomb
		434669, --Drop Arathi Bomb
		438946, --Throw Arathi Bomb
		434407, --Rolling Acid
		434576, --Acidic Stupor
		434579, --Corrosion
		448213, --Expel Webs
		448888, --Erosive Spray
		449042, --Radiant Light
		452001, --Light Fragment
		449734, --Acidic Eruption
		434089, --Spinneret's Strands
		434119, --Spinneret's Websnap
		434096, --Sticky Webs
		438957, --Acid Pool
		435793, --Tacky Burst
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
		424805, --Refracting Beam
		424879, --Earth Shatterer
		424888, --Seismic Smash
		424889, --Seismic Reverberation
		424893, --Earth Shield
		424903, --Volatile Spike
		},
		["Skarmorak"] = {
		order = 2, ejid = 2579,
		422233, --Crystalline Smash
		426215, --Reclaim
		443494, --Crystalline Eruption
		423228, --Crumbling Shell
		423246, --Shattered Shell
		423324, --Void Discharge
		423538, --Unstable Crash
		443405, --Void Fragment
		423572, --Void Empowerment
		},
		["Master Machinists Brokk and Dorlita"] = {
		order = 3, ejid = 2590,
		439577, --Silenced Speaker
		428239, --Activate Ventilation
		428819, --Exhaust Vents
		430000, --Flaming Scrap
		428161, --Molten Metal
		428202, --Scrap Song
		428555, --Scrap Cube
		428508, --Deconstruction
		428535, --Metal Splinters
		428711, --Molten Hammer
		428120, --Lava Expulsion
		},
		["Void Speaker Eirich"] = {
		order = 4, ejid = 2582,
		427315, --Void Rift
		427329, --Void Corruption
		427854, --Entropic Reckoning
		457465, --Entropy
		427869, --Unbridled Void
		},
	},
}
