local RDDB = Grid2Options:GetRaidDebuffsTable()

RDDB["Mists of Pandaria"] = {
    [897] = { --Heart of Fear
        ["Trash"] = { 
        },
        ["[745-1]Imperial Vizier Zor'lok"] = {
        122760, --Exhale
        123812, --Pheromones of Zeal
        122740, --Convert
        122706, --Noise Cancelling        
        },
        ["[744-2]Blade Lord Ta'yak"] = {
        122949, --Unseen Strike
        123474, --Overwhelming Assault
        124783, --Storm Unleashed
        123600, --Storm Unleashed?        
        },
        ["[713-3]Garalon"] = {
        122835, --Pheromones
        123081, --Pungency
        123120, --Pheromone Trail        
        },
        ["[741-4]Wind Lord Mel'jarak"] = {
        29212,--Cripple (NH)
        121881, --Amber Prison
        122055, --Residue
        122064, --Corrosive Resin        
        },
        ["[737-5]Amber-Shaper Un'sok"] = {
        121949, --Parasitic Growth
        122784, --Reshape Life
        122064, --Corrosive Resin
        122504, --Burning Amber        
        },
        ["[743-6]Grand Empress Shek'zeer"] = {
        125390, --Fixate
        123707, --Eyes of the Empress
        123788, --Cry of Terror
        124097, --Sticky Resin
        125824, --Trapped!
        124777, --Poison Bomb
        124821, --Poison-Drenched Armor
        124827, --Poison Fumes
        124849, --Consuming Terror
        124863, --Visions of Demise
        124862, --Visions of Demise: Target
        123845, --Heart of Fear: Chosen
        123846, --Heart of Fear: Lure        
        },
    },
    [896] = { --Mogu'shan Vaults
        ["Trash"] = {
        118562, --Petrified
        116596, --Smoke Bomb
        },
        ["[679-1]The Stone Guard"] = {
        130395, --Jasper Chains: Stacks
        130404, --Jasper Chains
        130774, --Amethyst Pool
        116038, --Jasper Petrification
        115861, --Cobalt Petrification
        116060, --Amethyst Petrification
        116281, --Cobalt Mine Blast (dispellable)
        125206, --Rend Flesh: Tank only
        116008, --Jade Petrification
        },
        ["[689-2]Feng The Accursed"] = {
        131788, --Lightning Lash: Tank Only: Stacks
        116040, --Epicenter
        116942, --Flaming Spear: Tank Only
        116784, --Wildfire Spark
        131790, --Arcane Shock: Stack : Tank Only
        102464, --Arcane Shock: AOE
        116417, --Arcane Resonance
        116364, --Arcane Velocity
        116374, --Lightning Charge: Stun effect
        131792, --Shadowburn: Tank only: Stacks: HEROIC ONLY
        },
        ["[682-3]Gara'jal the Spiritbinder"] = {
        122151, --Voodoo doll: Super Super Important! Like Holy jesus important!
        117723, --Frail Soul: HEROIC ONLY
        116260, --Crossed Over
        },
        ["[687-4]The Spirit Kings"] = {
        118303, --Undying Shadow: Fixate
        118048, --Pillaged
        118135, --Pinned Down
        118047, --Pillage: Target
        118163, --Robbed Blind
        },
        ["[726-5]Elegon"] = {
        117878, --Overcharged
        117949, --Closed circuit (dispellable)
        117945, --Arcing Energy
        },
        ["[677-6]Will of the Emperor"] = {
        116525, --Focused Assault
        116778, --Focused Defense
        117485, --Impeding Thrust
        116550, --Energizing Smash
        116829, --Focused Energy
        },
    },
    [809] = { --Kun-Lai Summit
        ["[691-]Sha of Anger"] = {
        119626, --Aggressive Behavior [NOTE: this is the MC]
        119488, --Unleashed Wrath [NOTE: Must heal these people. Lots of shadow dmg]
        119610, --Bitter Thoughts (Silence)
        119601, --Bitter Thoughts (Silence)
        },        
    },
    [886] = { --Terrace of Endless Spring
        ["Trash"] = {
        },
        ["[683-1]Protector Kaolan"] = {
        117519, --Touch of Sha
        111850, --Lightning Prison: Targeted
        117436, --Lightning Prison: Stunned
        118191, --Corrupted Essence
        117986, --Defiled Ground: Stacks
        },
        ["[742-2]Tsulong"] = {
        122768, --Dread Shadows
        122777, --Nightmares (dispellable)
        122752, --Shadow Breath
        122789, --Sunbeam
        123012, --Terrorize: 5% (dispellable)
        123011, --Terrorize: 10% (dispellable)
        123036, --Fright (dispellable)
        122858, --Bathed in Light
        },
        ["[729-3]Lei Shi"] = {
        123121, --Spray
        123705, --Scary Fog
        },
        ["[709-4]Sha of Fear"] = {
        119414, --Breath of Fear
        129147, --Onimous Cackle
        119983, --Dread Spray
        120669, --Naked and Afraid
        75683, --Waterspout
        120629, --Huddle in Terror
        120394, --Eternal Darkness
        129189, --Sha Globe
        119086, --Penetrating Bolt
        119775, --Reaching Attack
        },        
    },
    [930] = { --Throne of Thunder
    	["Trash"] = {
    	},
    	["[827-1]Jin'rokh the Breaker"] = {
    	138349, --Static Wound
    	137399, --Focused Lightning
    	138733, --Ionization
    	138002, --Fluidity
    	},
    	["[819-2]Horridon"] = {
    	136767, --Triple Puncture
    	136708, --Stone Gaze
    	136719, --Blazing Sunlight
    	136654, --Rending Charge
    	136587, --Venom Bolt Volley
    	136512, --Hex of Confusion
    	140946, --Dire Fixation
    	136710, --Deadly Plague
    	},
    	["[816-3]Council of Elders"] = {
    	137650, --Shadowed Soul
    	137085, --Chilled to the Bone
    	136922, --Frostbite
    	136917, --Biting Cold
    	136903, --Frigid Assault
    	136857, --Entrapped
    	137359, --Marked Soul
    	137891, --Twisted Fate
    	},
    	["[825-4]Tortos"] = {
    	137552, --Crystal Shell
    	},
    	["[821-5]Megaera"] = {
    	139822, --Cinders
    	137731, --Ignite Flesh
    	139866, --Torrent of Ice
    	139841, --Arctic Freeze
    	134378, --Acid Rain
    	139839, --Rot Armor
    	140179, --Suppression
    	139994, --Diffusion
    	},
    	["[828-6]Ji-Kun"] = {
    	140092, --Infected Talons
    	134256, --Slimed
    	138319, --Feed Pool
    	134366, --Talon Rake
    	140014, --Daedelian Wings
    	},
    	["[818-7]Durumu the Forgotten"] = {
    	133767, --Serious Wound
    	133768, --Arterial Cut
    	134755, --Eye Sore
    	136413, --Force of Will
    	133795, --Life Drain
    	133597, --Dark Parasite
    	133598, --Dark Plague
    	134007, --Devour
    	},
    	["[820-8]Primordius"] = {
    	136050, --Malformed Blood
    	140546, --Fully Mutated
    	137000, --Black Blood
    	136228, --Volatile Pathogen
    	},
    	["[824-9]Dark Animus"] = {
    	138609, --Matter Swap
    	138569, --Explosive Slam
    	138659, --Touch of the Animus
    	136954, --Anima Ring
    	},
    	["[817-10]Iron Qon"] = {
    	134691, --Impale
    	134647, --Scorched
    	136193, --Arcing Lightning
    	135145, --Freeze
    	},
    	["[829-11]Twin Consorts"] = {
    	137341, --Beast of Nightmares
    	137360, --Corrupted Healing
    	137408, --Fan of Flames
    	137440, --Icy Shadows
    	},
    	["[832-12]Lei Shen"] = {
    	134916, --Decapitate
    	135150, --Crashing Thunder
    	139011, --Helm of Command
    	136478, --Fusion Slash
    	136853, --Lightning Bolt
    	136295, --Overcharged
    	135703, --Static Shock
    	},
    	["[831-13]Ra-den"] = {
    	}
    },
	[929] = { --Isle of Giants
		["[826-]Oondasta"] = {
		137504, --Crush
		},
	},
	[953] = { --Siege of Orgrimmar
		["[852-1]Immerseus"] = {
		},
		["[849-2]The Fallen Protectors"] = {
		},
		["[866-3]Norushen"] = {
		},
		["[867-4]Sha of Pride"] = {
		},
		["[868-5]Galakras"] = {
		},
		["[864-6]Iron Juggernaut"] = {
		},
		["[856-7]Kor'kron Dark Shaman"] = {
		},
		["[850-8]General Nazgrim"] = {
		},
		["[846-9]Malkorok"] = {
		},
		["[870-10]Spoils of Pandaria"] = {
		},
		["[851-11]Thok the Bloodthirsty"] = {
		},
		["[865-12]Siegecrafter Blackfuse"] = {
		},
		["[853-13]Paragons of the Klaxxi"] = {
		},
		["[869-14]Garrosh Hellscream"] = {
		},
		["Trash"] = {
		},
	},
}