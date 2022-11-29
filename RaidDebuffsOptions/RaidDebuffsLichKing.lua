-- Wow TBC raid debuffs
-- Key&id = InstanceMapID (select(8,GetInstanceInfo())) + 100000
if Grid2.versionCli<30000 then return end

local RDDB= Grid2Options:GetRaidDebuffsTable()

RDDB["Wrath of the Lich King"] = {
	[100533] = {
	    { id = 100533, name = "Naxxramas", raid = true },
		["Anub'Rekhan"]= {
		order = 1, ejid = nil,
		28786, --Locust Swarm (N, H)
		28969, --acid-spit
		28783, --impale
		28991, --web
		},
		["Grand Widow Faerlina"]= {
		order = 2, ejid = nil,
		28796, --Poison Bolt Volley (N, H)
		28794, --Rain of Fire (N, H)
		},
		["Maexxna"]= {
		order = 3, ejid = nil,
		28622, --Web Wrap (NH)
		29484, --web-spray
		54121, --Necrotic Poison (N, H)
		},
		["Noth the Plaguebringer"]= {
		order = 4, ejid = nil,
		29213, --Curse of the Plaguebringer (N, H)
		29214, --Wrath of the Plaguebringer (N, H)
		29212,--Cripple (NH)
		},
		["Heigan the Unclean"]= {
		order = 5, ejid = nil,
		29998, --Decrepit Fever (N, H)
		29310, --Spell Disruption (NH)
		},
		["Loatheb"] = {
		order = 6, ejid = nil,
		29232, --fungal-bloom
		29865, --poison-aura
		29185, --corrupted-mind
		},
		["Instructor Razuvious"]= {
		order = 7, ejid = nil,
		55550, --Jagged Knife (NH)
		26613, --unbalancing-strike
		},
		["Gothik The Harvester"] = {
		order = 8, ejid = nil,
		5164,  --knockdown
		30285, --eagle-claw
		27825, --shadow-mark
		17467, --unholy-aura
		28679, --harvest-soul
		},
		["Four Horsemen"] = {
		order = 9, ejid = nil,
		28863, --void-zone
		28882, --righteous-fire
		28832, --mark-of-korthazz
		28833, --mark-of-blaumeux
		28835, --mark-of-zeliek
		28834, --mark-of-mograine
		},
		["Patchwerk"] = {
		order = 10, ejid = nil,
		28311, --slime-bolt
		},
		["Grobbulus"]= {
		order = 11, ejid = nil,
		28169,--Mutating Injection (NH)
		},
		["Gluth"]= {
		order = 12, ejid = nil,
		54378,--Mortal Wound (NH)
		29306,--Infected Wound (NH)
		},
		["Thaddius"]= {
		order = 13, ejid = nil,
		28084, --Negative Charge (N, H)
		28059, --Positive Charge (N, H)
		},
		["Sapphiron"]= {
		order = 14, ejid = nil,
		28522, --Icebolt (NH)
		28542, --Life Drain (N, H)
		},
		["Kel'Thuzad"]= {
		order = 15, ejid = nil,
		28410,--Chains of Kel'Thuzad (H)
		27819,--Detonate Mana (NH)
		27808,--Frost Blast (NH)
		},
		["Trash"]= {
		order = 16, ejid = nil,
		55314, --Strangulate
		4283,  --stomp
		13737, --mortal-strike
		16145, --sunder-armor
		},
	},
	[100603] = {
		{ id = 100603, name = "Ulduar", raid = true },
		["Razorscale"]= {
		order = 1, ejid = nil,
		64771,--Fuse Armor (NH)
		},
		["Ignis the Furnace Master"]= {
		order = 2, ejid = nil,
		62548, --Scorch (N, H)
		62680, --Flame Jet (N, H)
		62717, --Slag Pot (N, H)
		},
		["XT-002"]= {
		order = 3, ejid = nil,
		63024, --Gravity Bomb (N, H)
		63018, --Light Bomb (N, H)
		},
		["The Assembly of Iron"]= {
		order = 4, ejid = nil,
		61888, --Overwhelming Power (N, H)
		62269, --Rune of Death (N, H)
		61903, --Fusion Punch (N, H)
		61912, --Static Disruption(N, H)
		},
		["Kologarn"]= {
		order = 5, ejid = nil,
		64290, --Stone Grip (N, H)
		63355, --Crunch Armor (N, H)
		62055, --Brittle Skin (NH)
		},
		["Hodir"]= {
		order = 6, ejid = nil,
		62469, --Freeze (NH)
		61969, --Flash Freeze (N, H)
		62188, --Biting Cold (NH)
		},
		["Thorim"]= {
		order = 7, ejid = nil,
		62042, --Stormhammer (NH)
		62130, --Unbalancing Strike (NH)
		62526, --Rune Detonation (NH)
		62470, --Deafening Thunder (NH)
		62331, --Impale (N, H)
		},
		["Freya"]= {
		order = 8, ejid = nil,
		62532, --Conservator's Grip (NH)
		62589, --Nature's Fury (N, H)
		62861, --Iron Roots (N, H)
		},
		["Mimiron"]= {
		order = 9, ejid = nil,
		63666,--Napalm Shell (N)
		62997,--Plasma Blast (N)
		64668,--Magnetic Field (NH)
		},
		["General Vezax"]= {
		order = 10, ejid = nil,
		63276,--Mark of the Faceless (NH)
		63322,--Saronite Vapors (NH)
		},
		["Yogg-Saron"]= {
		order = 11, ejid = nil,
		63147,--Sara's Anger(NH)
		63134,--Sara's Blessing(NH)
		63138,--Sara's Fervor(NH)
		63830,--Malady of the Mind (H)
		63802,--Brain Link(H)
		63042,--Dominate Mind (H)
		64152,--Draining Poison (H)
		64153,--Black Plague (H)
		64125,--Squeeze (N, H)
		64156,--Apathy (H)
		64157,--Curse of Doom (H)
		--63050,--Sanity(NH)
		},
		["Algalon"]= {
		order = 12, ejid = nil,
		64412,--Phase Punch
		},
		["Trash"]= {
		order = 13, ejid = nil,
		62310, --Impale (N, H)
		63612, --Lightning Brand (N, H)
		63615, --Ravage Armor (NH)
		62283, --Iron Roots (N, H)
		63169, --Petrify Joints (N, H)
		},
	},
	[100615] = {
	    { id = 100615, name = "The Obsidian Sanctum", raid = true },
		["Sartharion"]= {
		order = 1, ejid = nil,
		60708,--Fade Armor (N, H)
		57491,--Flame Tsunami (N, H)
		},
		["Trash"]= {
		order = 2, ejid = nil,
		39647,--Curse of Mending
		58936,--Rain of Fire
		},
	},
	[100616] = {
		{ id = 100616, name = "The Eye of Eternity", raid = true },
		["Malygos"]= {
		order = 1, ejid = nil,
		56272, --Arcane Breath (N, H)
		57407, --Surge of Power (N, H)
		}
	},
	[100624] = {
	    { id = 100624, name = "Vault of Archavon", raid = true },
		["Koralon"]= {
		order = 1, ejid = nil,
		66690,--Flaming Cinder (10, 25)
		},
		["Toravon the Ice Watcher"]= {
		order = 2, ejid = nil,
		72004,--Frostbite
		},
	},
	[100631] = {
		{ id = 100631, name = "Icecrown Citadel", raid = true },
		["Lord Marrowgar"]= {
		order = 1, ejid = nil,
		72705,--Coldflame (70823)
		69065,--Impaled
		69075,--Bone Storm (70835)
		},
		["Lady Deathwhisper"]= {
		order = 2, ejid = nil,
		71001,--Death and Decay (72109)
		71289,--Dominate Mind
		71204,--Touch of Insignificance
		69917,--Frost Fever (67934)
		71237,--Curse of Torpor
		71951,--Necrotic Strike (72491)
		},
		["Gunship Battle"]= {
		order = 3, ejid = nil,
		69651,--Wounding Strike
		},
		["Deathbringer Saurfang"]= {
		order = 4, ejid = nil,
		72293,--Mark of the Fallen Champion
		72385,--Boiling Blood (72442)
		72410,--Rune of Blood (72449)
		72769,--Scent of Blood (heroic)
		},
		["Festergut"]= {
		order = 5, ejid = nil,
		69290,--Blighted Spore
		69248,--Vile Gas
		72219,--Gastric Bloat
		69278,-- Gas Spore
		},
		["Rotface"]= {
		order = 6, ejid = nil,
		69674,--Mutated Infection
		69802, --Ooze Flood (71215)
		69508,--Slime Spray
		30494,--Sticky Ooze
		},
		["Professor Putricide"]= {
		order = 7, ejid = nil,
		70215,--Gaseous Bloat
		72297,--Malleable Goo (72549)
		72454,--Mutated Plague
		70341,--Slime Puddle (Spray)
		70342,--Slime Puddle (Pool)
		70911,--Unbound Plague
		69774,--Volatile Ooze Adhesive
		},
		["Blood Prince Council"]= {
		order = 8, ejid = nil,
		72999,--Shadow Prison
		71807,--Glittering Sparks
		71911,--Shadow Resonance
		},
		["Blood-Queen Lana'thel"]= {
		order = 9, ejid = nil,
		70838,--Blood Mirror
		71623,--Delirious Slash
		70949,--Essence of the Blood Queen (hand icon)
		72151,--Frenzied Bloodthirst (bite icon)
		71340,--Pact of the Darkfallen
		72985,--Swarming Shadows (pink icon)
		70923,--Uncontrollable Frenzy
		},
		["Valithria Dreamwalker"]= {
		order = 10, ejid = nil,
		70873,--Emerald Vigor
		70744,--Acid Burst
		70751,--Corrosion
		70633,--Gut Spray
		71941,--Twisted Nightmares
		70766,--Dream State
		},
		["Sindragosa"]= {
		order = 11, ejid = nil,
		70107,--Permeating Chill
		70106,--Chilled to the Bone
		69766,--Instability
		71665,--Asphyxiation
		70126,--Frost Beacon
		70157,--Ice Tomb
		},
		["Lich King"]= {
		order = 12, ejid = nil,
		72133,--Pain and Suffering
		68981,--Remorseless Winter
		69242,--Soul Shriek
		69409,--Soul Reaper
		70541,--Infest
		27177,--Defile
		68980,--Harvest Soul
		},
		["Trash"]= {
		order = 13, ejid = nil,
		70980,--Web Wrap
		70450,--Blood Mirror
		71089,--Bubbling Pus
		69483,--Dark Reckoning
		71163,--Devour Humanoid
		71127,--Mortal Wound
		70435,--Rend Flesh
		70671,--Leeching Rot
		70432,--Blood Sap
		71257,--Barbaric Strike
		},
	},
	[100649] = {
		{ id = 100649, name = "Trial of the Crusader", raid = true },
		["Gormok the Impaler"]= {
		order = 1, ejid = nil,
		66331, --Impale(10, 25, 10H, 25H)
		66406, --Snobolled!
		},
		["Acidmaw"]= {
		order = 2, ejid = nil,
		66819, --Acidic Spew (10, 25, 10H, 25H)
		66821, --Molten Spew (10, 25, 10H, 25H)
		66823, --Paralytic Toxin (10, 25, 10H, 25H)
		66869,--Burning Bile
		},
		["Icehowl"]= {
		order = 3, ejid = nil,
		66770, --Ferocious Butt(10, 25, 10H, 25H)
		66689, --Arctic Breathe(10, 25, 10H, 25H)
		66683, --Massive Crash
		},
		["Lord Jaraxxus"]= {
		order = 4, ejid = nil,
		66532, --Fel Fireball (10, 25, 10H, 25H)
		66237, --Incinerate Flesh (10, 25, 10H, 25H)
		66242, --Burning Inferno (10, 25, 10H, 25H)
		66197, --Legion Flame (10, 25, 10H, 25H)
		66283, --Spinning Pain Spike
		66209, --Touch of Jaraxxus(H)
		66211, --Curse of the Nether(H)
		66333, --Mistress' Kiss (10H, 25H)
		},
		["Faction Champions"]= {
		order = 5, ejid = nil,
		65812, --Unstable Affliction (10, 25, 10H, 25H)
		--65960,--Blind
		--65801,--Polymorph
		--65543,--Psychic Scream
		--66054,--Hex
		--65809,--Fear
		},
		["The Twin Val'kyr"]= {
		order = 6, ejid = nil,
		65684, --Dark Essence (67176)
		65686, --Light Essence (67223)
		-- 67282, --Dark Touch ()
		-- 67297, --Light Touch ()
		66069, --Twin Spike (10, 25, 10H, 25H) (67309)
		},
		["Anub'arak"]= {
		order = 7, ejid = nil,
		67574,--Pursued by Anub'arak
		--66240, 67630, 68646, 68647,--Leeching Swarm (10, 25, 10H, 25H)
		66013, --Penetrating Cold (10, 25, 10H, 25H)
		67721, --Expose Weakness (67847)
		66012, --Freezing Slash
		65775, --Acid-Drenched Mandibles(25H) (67863)
		},
	},
	[100724] = {
	    { id = 100724, name = "The Ruby Sanctum", raid = true },
		["Baltharus the Warborn"]= {
		order = 1, ejid = nil,
		74502,--Enervating Brand
		},
		["General Zarithrian"]= {
		order = 2, ejid = nil,
		74367,--Cleave Armor
		},
		["Saviana Ragefire"]= {
		order = 3, ejid = nil,
		74452,--Conflagration
		},
		["Halion"]= {
		order = 4, ejid = nil,
		74562,--Fiery Combustion
		74567,--Mark of Combustion
		74792,--Soul Consumption
		74795,--Mark of Consumption
		},
	},
}
