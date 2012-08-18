local RDDB = Grid2Options:GetRaidDebuffsTable()

RDDB["Mists of Pandaria"] = {
    ["Heart of Fear"] = {
        ["Trash"]= { 
        },
        ["Imperial Vizier Zor'lok"]= {
        122760, --Exhale
        123812, --Pheromones of Zeal
        122740, --Convert
        122706, --Noise Cancelling        
		},
        ["Blade Lord Ta'yak"]= {
        122949, --Unseen Strike
        123474, --Overwhelming Assault
        124783, --Storm Unleashed
        123600, --Storm Unleashed?        
		},
        ["Garalon"]= {
        122835, --Pheromones
        123081, --Pungency
        123120, --Pheromone Trail        
		},
        ["Wind Lord Mel'jarak"]= {
        29212,--Cripple (NH)
        121881, --Amber Prison
        122055, --Residue
        122064, --Corrosive Resin        
		},
        ["Amber-Shaper Un'sok"]= {
        121949, --Parasitic Growth
        122784, --Reshape Life
        122064, --Corrosive Resin
        122504, --Burning Amber        
		},
        ["Grand Empress Shek'zeer"]= {
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
    ["Mogushan Vaults"] = {
        ["Trash"]={
        118562, --Petrified
        116596, --Smoke Bomb
        },
        ["The Stone Guard"]= {
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
        ["Feng The Accursed"]={
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
        ["Gara'jal the Spiritbinder"]={
        122151, --Voodoo doll: Super Super Important! Like Holy jesus important!
        117723, --Frail Soul: HEROIC ONLY
        116260, --Crossed Over
        },
        ["The Spirit Kings"]={
        118303, --Undying Shadow: Fixate
        118048, --Pillaged
        118135, --Pinned Down
        118047, --Pillage: Target
        118163, --Robbed Blind
        },
        ["Elegon"]={
        117878, --Overcharged
        117949, --Closed circuit (dispellable)
        117945, --Arcing Energy
        },
        ["Will of the Emperor"]={
        116525, --Focused Assault
        116778, --Focused Defense
        117485, --Impeding Thrust
        116550, --Energizing Smash
        116829, --Focused Energy
        },
    },
    ["Kun-Lai Summit"] = {
        ["Sha of Anger"]= {
        119626, --Aggressive Behavior [NOTE: this is the MC]
        119488, --Unleashed Wrath [NOTE: Must heal these people. Lots of shadow dmg]
        119610, --Bitter Thoughts (Silence)
        119601, --Bitter Thoughts (Silence)
        },        
    },
    ["Terrace of Endless Spring"] = {
        ["Trash"]= {
        },
        ["Protector Kaolan"]= {
        117519, --Touch of Sha
        111850, --Lightning Prison: Targeted
        117436, --Lightning Prison: Stunned
        118191, --Corrupted Essence
        117986, --Defiled Ground: Stacks
        },
        ["Tsulong"]= {
        122768, --Dread Shadows
        122777, --Nightmares (dispellable)
        122752, --Shadow Breath
        122789, --Sunbeam
        123012, --Terrorize: 5% (dispellable)
        123011, --Terrorize: 10% (dispellable)
        123036, --Fright (dispellable)
        122858, --Bathed in Light
        },
        ["Lei Shi"]= {
        123121, --Spray
        123705, --Scary Fog
        },
        ["Sha of Fear"]= {
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
}