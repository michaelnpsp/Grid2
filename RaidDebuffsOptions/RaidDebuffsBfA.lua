if Grid2.isClassic then return end

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
		268993, -- Golpe bajo
		263778, -- Fuerza de vendaval
		225080, -- Reencarnaci�n
		},
		["Merektha"] = {
		order = 2, ejid = 2143,
		267027, -- Cytotoxin
		263958, -- A Knot of Snakes
		261732, -- Blinding Sand
		263927, -- Charco t�xico
		},
		["Galvazzt"] = {
		order = 3, ejid = 2144,
		266512, -- Consume Charge
		266923, -- Galvanizar
		},
		["Avatar of Sethraliss"] = {
		order = 4, ejid = 2145,
		269686, -- Plague
		269670, -- Potenciaci�n
		268024, -- Pulso
		},
		["Trash"] = {
		order = 5, ejid = nil,
		273563, -- Neurotoxina
		272657, -- Aliento nocivo
		272655, -- Arena asoladora
		272696, -- Rel�mpagos embotellados
		272699, -- Flema venenosa
		268013, -- Choque de llamas
		268007, -- Ataque al coraz�n
		268008, -- Amuleto de serpiente
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
		267523, -- Oleada cortante
		1604,   -- Atontado
		},
		["Ring of Booty"] = {
		order = 3, ejid = 2094,
		256553, -- Flailing Shark
		256363, -- Pu�etazo desgarrador
		},
		["Harlan Sweete"] = {
		order = 4, ejid = 2095,
		281591, -- Cannon Barrage
		257460, -- Escombros igneos
		257314, -- Bomba de polvora negra
		},
		["Trash"] = {
		257908, -- Hoja aceitada
		257478, -- Mordedura entorpecedora
		274384, -- Trampas para ratas
		}
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
		260455, -- Colmillos serrados
		},
		["Sporecaller Zancha"] = {
		order = 3, ejid = 2130,
		259714, -- Decaying Spores
		259718, -- Agitaci�n
		273226, -- Esporas putrefactas
		},
		["Unbound Abomination"] = {
		order = 4, ejid = 2158,
		269301, -- Putrid Blood
		},
		["Trash"] = {
		order = 5, ejid = nil,
		265533, -- Fauce sangrienta
		265019, -- Tajo salvaje
		265377, -- Trampa con gancho
		265568, -- Presagio oscuro
		266107, -- Sed de sangre
		266265, -- Asalto malvado
		272180, -- Descarga mortal
		265468, -- Maldici�n fulminante
		272609, -- Mirada enloquecedora
		265511, -- Drenaje de esp�ritu
		278961, -- Mente putrefacta
		273599, -- Aliento podrido
		},
	},
	[968] = {
		{ id = 968, name = "Atal'Dazar" },
		["Priestess Alun'za"] = {
		order = 1, ejid = 2082,
		274195, -- Corrupted Blood
		277072, -- Corrupted Gold
		265914, -- Molten Gold
		255835, -- Transfusi�n
		255836, -- Transfusi�n
		},
		["Vol'kaal"] = {
		order = 2, ejid = 2036,
		263927, -- Toxic Pool
		250372, -- Lingering Nausea
		255620, -- Erupci�n purulenta
		},
		["Rezan"] = {
		order = 3, ejid = 2083,
		255434, -- Serrated Teeth
		255371, -- Terrifying Visage
		257407, -- Pursuit
		255421, -- Devour
		257483, -- Pile of Bones
		},
		["Yazma"] = {
		order = 4, ejid = 2030,
		250096, -- Dolor atroz
		259145, -- Soulrend
		249919, -- Skewer
		},
		["Trash"] = {
		order = 5, ejid = nil,
		253562, -- Fuego salvaje
		254959, -- Quemar alma
		260668, -- Transfusi�n
		255567, -- Carga fren�tica
		279118, -- Maleficio inestable
		252692, -- Golpe embotador
		252687, -- Golpe de Venolmillo
		255041, -- Chirrido aterrorizador
		255814, -- Acometida desgarradora
		258723, -- Grotesque Pool  
		255558, -- Tainted Blood   
		250036, -- Shadowy Remains 
		},
	},
	[1036] = {
		{ id = 1036, name = "Shrine of the Storm" },
		["Aqu'sirr"] = {
		order = 1, ejid = 2153,
		264560, -- Choking Brine
		264477, -- Grasp from the Depths
		},
		["Tidesage Council"] = {
		order = 2, ejid = 2154,
		267899, -- Hindering Cleave
		267818, -- Viento cortante
		},
		["Lord Stormsong"] = {
		order = 3, ejid = 2155,
		268896, -- Mind Rend
		269104, -- Vac�o explosivo
		269131, -- Dominamentes ancestral
		},
		["Vol'zith the Whisperer"] = {
		order = 4, ejid = 2156,
		267034, -- Whispers of Power
		},
		["Trash"] = {
		order = 5, ejid = nil,
		268233, -- Choque electrizante
		274633, -- Arremetida hendiente
		268309, -- Oscuridad infinita
		268315, -- Latigazo
		268317, -- Desgarrar mente
		268322, -- Toque de los ahogados
		268391, -- Ataque mental
		274720, -- Golpe abisal
		276268, -- Golpe tumultuoso
		268059, -- Ancla de vinculaci�n
		268027, -- Mareas crecientes
		268214, -- Grabar carne
		},
	},
	[1002] = {
		{ id = 1002, name = "Tol Dagor" },
		["The Sand Queen"] = {
		order = 1, ejid = 2097,
		257092, -- Sand Trap
		260016, -- Mordedura irritante
		},
		["Jes Howlis"] = {
		order = 2, ejid = 2098,
		257791, -- Howling Fear
		257777, -- Chafarote entorpecedor
		257793, -- Polvo de humo
		260067, -- Vapuleo sa�oso
		},
		["Knight Captain Valyri"] = {
		order = 3, ejid = 2099,
		257028, -- Fuselighter
		259711, -- A cal y canto
		},
		["Overseer Korgus"] = {
		order = 4, ejid = 2096,
		256198, -- Azerite Rounds: Incendiary
		256038, -- Deadeye
		256044, -- Deadeye
		256200, -- Veneno Muerte Diestra
		256105, -- R�faga explosiva
		256201, -- Cartuchos incendiarios
		},
		["Trash"] = {
		order = 5, ejid = nil,
		258864, -- Fuego de supresi�n
		258313, -- Esposar
		258079, -- Dentellada enorme
		258075, -- Mordedura irritante
		258058, -- Exprimir
		265889, -- Golpe de antorcha
		258128, -- Grito debilitante
		225080, -- Reencarnaci�n
		},
	},
	[1021] = {
		{ id = 1021, name = "Waycrest Manor" },
		["Heartsbane Triad"] = {
		order = 1, ejid = 2125,
		260741, -- Jagged Nettles
		260926, -- Soul Manipulation
		260703, -- Unstable Runic Mark
		268086, -- Aura of Dread
		268125, -- Aura of Thorns
		268080, -- Aura of Apathy
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
		261438, -- Golpe extenuante
		261440, -- Patogeno virulento
		},
		["Gorak Tul"] = {
		order = 5, ejid = 2129,
		268203, -- Death Lens
		},
		["Trash"] = {
		order = 6, ejid = nil,
		263905, -- Tajo marcador
		265352, -- A�ublo de sapo
		266036, -- Drenar esencia
		264105, -- Se�al r�nica
		264390, -- Hechizo de vinculaci�n
		265346, -- Mirada p�lida
		264050, -- Espina infectada
		265761, -- Tromba espinosa
		264153, -- Flema
		265407, -- Campanilla para la cena
		271178, -- Salto devastador
		263943, -- Grabar
		264520, -- Serpiente mutiladora
		265881, -- Toque putrefacto
		264378, -- Fragmentar alma
		264407, -- Rostro horripilante
		265880, -- Marca p�rfida
		265882, -- Pavor persistente
		266035, -- Astilla de hueso
		263891, -- Espinas enredadoras
		264556, -- Golpe desgarrador
		278456, -- Infestar
		264040, -- Uprooted Thorns
		260569, -- Wildfire
		278444, -- Infest
		},
	},
	[1012] = {
		{ id = 1012, name = "The MOTHERLODE!!" },
		["Coin-Operated Crowd Pummeler"] = {
		order = 1, ejid = 2109,
		256137, -- Timed Detonation
		257333, -- Shocking Claw
		262347, -- Pulso est�tico
		270882, -- Azerita llameante
		},
		["Azerokk"] = {
		order = 2, ejid = 2114,
		257582, -- Raging Gaze
		258627, -- Resonant Quake
		257544, -- Corte dentado
		275907, -- Machaque tect�nico
		},
		["Rixxa Fluxflame"] = {
		order = 3, ejid = 2115,
		258971, -- Azerite Catalyst
		259940, -- Propellant Blast
		259853, -- Quemadura qu�mica
		},
		["Mogul Razdunk"] = {
		order = 4, ejid = 2116,
		260811, -- Homing Missile
		260829, -- Misil buscador
		260838, -- Misil buscador
		270277, -- Cohete rojo grande
		},
		["Trash"] = {
		order = 5, ejid = nil,
		280604, -- Chorro helado
		280605, -- Congelaci�n cerebral
		263637, -- Tendedero
		269298, -- Toxina de creaviudas
		263202, -- Lanza de roca
		268704, -- Temblor furioso
		268846, -- Hoja de eco
		263074, -- Mordedura degenerativa
		262270, -- Compuesto c�ustico
		262794, -- Latigazo de energ�a
		262811, -- Gl�bulo parasitario
		268797, -- Transmutar: enemigo en baba
		269429, -- Disparo cargado
		262377, -- Buscar y destruir
		262348, -- Deflagraci�n de mina
		269092, -- Tromba de artiller�a
		262515, -- Buscacorazones de azerita
		262513, -- Buscacorazones de azerita
		},
	},
	[1023] = {
		{ id = 1023, name = "Siege of Boralus" },
		["Sergeant Bainbridge"] = {
		order = 1, ejid = 2133,
		256867, --Heavy Hitter
		260954, --Iron Gaze
		257649, --Boiling Rage
		261428, --Hangman's Noose
		260924, --Steel Tempest
		257585, --Cannon Barrage
		273716, --Heavy Ordnance
		257292, --Heavy Slash
		257641, --Molten Slug
		},
		["Dread Captain Lockwood"] = {
		order = 2, ejid = 2173,
		463185, --Mass Bombardment
		272426, --Sighted Artillery
		463182, --Fiery Ricochet
		280389, --Shoot
		272471, --Evasive
		273470, --Gut Shot
		269029, --Clear the Deck
		268752, --Withdraw
		268443, --Dread Volley
		268230, --Crimson Swipe
		268260, --Broadside
		268976, --Unstable Ordnance
		},
		["Hadal Darkfathom"] = {
		order = 3, ejid = 2134,
		261563, --Crashing Tide
		257882, --Break Water
		276068, --Tidal Surge
		},
		["Viq'Goth"] = {
		order = 4, ejid = 2140,
		274991, --Putrid Waters
		279897, --Terror From Below
		270624, --Crushing Embrace
		270185, --Call of the Deep
		270590, --Hull Cracker
		269266, --Slam
		269416, --Blast
		269484, --Eradication
		},
		["Trash"] = {
		order = 5, ejid = nil,
		454437, -- Azerite Charge
		454439, -- Azerite Charge
		268230, -- Crimson Swipe
		257168, -- Cursed Slash
		257459, -- On the Hook
		272588, -- Rotting Wounds
		272421, -- Slighted Artillery
		256709, -- Singing Steel
		275836, -- Stinging Venom
		454440, -- Stinky Vomit
		256616, -- Tooth Breaker
		257069, -- Watertight Shell
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
	[1178] = {
		{ id = 1178, name = "Operation: Mechagon" },
		["King Gobbamak"] = {
		order = 1, ejid = 2357,
		297257, -- electrical-charge
		},
		["Gunker"] = {
		order = 2, ejid = 2358,
		298124, -- gooped
		297913, -- toxic-goop
		298229, -- toxic-fumes
		},
		["Trixie & Naeno"] = {
		order = 3, ejid = 2360,
		298669, -- taze
		298718, -- mega-taze
		},
		["HK-8 Aerial Oppression Unit"] = {
		order = 4, ejid = 2355,
		295445, -- wreck
		302274, -- fulminating-zap
		295939, -- annihilation-ray
		296150, -- vent-blast
		},
		["Tussle Tonks"] = {
		order = 5, ejid = 2336,
		285388, -- vent-jets
		},
		["K.U.-J.0."] = {
		order = 6, ejid = 2339,
		294929, -- blazing-chomp
		291946, -- venting-flames
		},
		["Machinist's Garden"] = {
		order = 7, ejid = 2348,
		285443, -- hidden-flame-cannon
		294860, -- blossom-blast
		285460, -- discom-bomb-ulator
		},
		["King Mechagon"] = {
		order = 8, ejid = 2331,
		291939, -- giga-zap
		},
		["Trash"] = {
		order = 9, ejid = nil,
		299438, -- sledgehammer
		300207, -- shock-coil
		299475, -- b-o-r-k
		301712, -- pounce
		299502, -- nanoslicer
		294290, -- process-waste
		294195, -- arcing-zap
		293986, -- sonic-pulse
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
        275189, -- Hardened Arteries
        275205, -- Enlarged Heart
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
        264210, -- Jagged Mandible
        270589, -- Void Wail
        270620, -- Psionic Blast
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
		273434, -- Pit of Despair
		274195, -- Corrupted Blood
		274271, -- Deathwish
        272018, -- Absorbed in Darkness
        276020, -- Fixate
        276299, -- Engorged Burst
		},
		["Mythrax the Unraveler"] = {
		order = 7, ejid = 2194,
		272336, -- Annihilation
		272536, -- Imminent Ruin
		274693, -- Essence Shear
		272407, -- Oblivion Sphere
        272146, -- Annihilation
        274019, -- Mind Flay
        274113, -- Obliteration Beam
        274761, -- Oblivion Veil
        279013, -- Essence Shatter
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
        263321, -- Undulating Mass
        267659, -- Unclean Contagion
        267700, -- Gaze of G'huun
        267813, -- Blood Host
        269691, -- Mind Thrall
        277007, -- Bursting Boil
        279575, -- Choking Miasma
		},
	},
	[1176] = {
		{ id = 1176, name = "Battle of Dazar'alor", raid = true },
		["Champion of the Light"] = {
		order = 1, ejid = 2344,
		283572, -- Sacred Blade
		283651, -- Blinding Faith
		283579, -- Consecration
		},
		["Jadefire Masters"] = {
		order = 2, ejid = 2323,
		286988, -- Searing Embers
		282037, -- Rising Flames
		288151, -- Tested
		285632, -- Stalking
		},
		["Grong, the Revenant"] = {
		order = 3, ejid = 2340,
		285875, -- Rending Bite
		283069, -- Megatomic Fire (Horde)
		286373, -- Chill of Death (Alliance)
		282215, -- Megatomic Seeker Missile
		282471, -- Voodoo Blast
		285659, -- Apetagonizer Core
		286434, -- Necrotic Core
		285671, -- Crushed
		282010, -- Shattered
		},
		["Opulence"] = {
		order = 4, ejid = 2342,
		283063, -- Flames of Punishment
		283507, -- Volatile Charge
		286501, -- Creeping Blaze
		287072, -- Liquid Gold
		284470, -- Hex of Lethargy
		},
		["Conclave of the Chosen"] = {
		order = 5, ejid = 2330,
		284663, -- Bwonsamdi's Wrath
		282135, -- Crawling Hex
		285878, -- Mind Wipe
		282592, -- Bleeding Wounds
		286060, -- Cry of the Fallen
		282444, -- Lacerating Claws
		286811, -- Akunda's Wrath
		282209, -- Mark of Prey
		},
		["King Rastakhan"] = {
		order = 6, ejid = 2335,
		285195, -- Deadly Withering
		285044, -- Toad Toxin
		284831, -- Scorching Detonation
		284781, -- Grevious Axe
		285213, -- Caress of Death
		288449, -- Death's Door
		284662, -- Seal of Purification
		285349, -- Plague of Fire
		},
		["High Tinker Mekkatorque"] = {
		order = 7, ejid = 2334,
		287167, -- Discombobulation
		283411, -- Gigavolt Blast
		286480, -- Anti Tampering Shock
		287757, -- Gigavolt Charge
		282182, -- Buster Cannon
		284168, -- Shrunk
		284214, -- Trample
		287891, -- Sheep Shrapnel
		289023, -- Enormous
		},
		["Stormwall Blockade"] = {
		order = 8, ejid = 2337,
		285000, -- Kelp Wrapping
		284405, -- Tempting Song
		285350, -- Storms Wail
		285075, -- Freezing Tidepool
		285382, -- Kelp Wrapping
		},
		["Lady Jaina Proudmoore"] = {
		order = 9, ejid = 2343,
		287626, -- Grasp of Frost
		287490,	-- Frozen Solid
		287365, -- Searing Pitch
		285212, -- Chilling Touch
		285253, -- Ice Shard
		287199, -- Ring of Ice
		288218, -- Broadside
		289220, -- Heart of Frost
		288038, -- Marked Target
		287565, -- Avalanche
		},
	},
	[1177] = {
		{ id = 1177, name = "Crucible of Storms", raid = true },
		["The Restless Cabal"] = {
		order = 1, ejid = 2328,
		282540, -- Agent of demise
		282432, -- Crushing Doubt
		282384, -- Shear Mind
		283524, -- Aphotic Blast
		282517, -- Terrifying Echo
		282562, -- Promises of Power
		282738, -- Embrace of the void
		293300, -- Storm essence
		293488, -- Oceanic Essence
		},
		["Uu'nat, Harbinger of the Void"] = {
		order = 2, ejid = 2332,
		285345, -- Maddening eyes of N'zoth
		285652, -- Insatiable torment
		284733, -- Embrace of the void
		285367  -- Piercing gaze
		},
	},
	[1179] = {
		{ id = 1179, name = "The Eternal Palace", raid = true },
		["Abyssal Commander Sivara"] = {
		order = 1, ejid = 2352,
		300882, -- Inversion Sickness
		295421, -- Over flowing Venom
		295348, -- Over flowing Chill
		294715, -- Toxic Brand
		294711, -- Frost Mark
		300705, -- Septic Taint
		300701, -- Rimefrost
		294847, -- Unstable Mixture
		300961, -- Frozen Ground
		300962, -- Septic Ground
		},
		["Blackwater Behemoth"] = {
		order = 2, ejid = 2347,
		292127, -- Darkest Depths
		292307, -- Gaze from Below
		292167, -- Toxic Spine
		301494, -- Piercing Barb
		298595, -- Glowing Stinger
		292138, -- Radiant Biomass
		292133, -- Bioluminescence
		},
		["Radiance of Azshara"] = {
		order = 3, ejid = 2353,
		296737, -- Arcane Bomb
		296566, -- Tide Fist
		},
		["Lady Ashvane"] = {
		order = 4, ejid = 2354,
		296693, -- Waterlogged
		297333, -- Briny Bubble
		296725, -- Barnacle Bash
		296752, -- Cutting Coral
		},
		["Orgozoa"] = {
		order = 5, ejid = 2351,
		298306, -- Incubation Fluid
		295779, -- Aqua Lance
		298156, -- Desensitizing Sting
		298306, -- Incubation Fluid
		},
		["The Queen's Court"] = {
		order = 6, ejid = 2359,
		297586, -- Suffering
		299914, -- Frenetic Charge
		296851, -- Fanatical Verdict
		300545, -- Mighty Rupture
		},
		["Za'qul, Harbinger of Ny'alotha"] = {
		order = 7, ejid = 2349,
		292971, -- Hysteria
		292963, -- Dread
		293509, -- Manifest Nightmares
		298192, -- Dark Beyond
		},
		["Queen Azshara"] = {
		order = 8, ejid = 2361,
		303825, -- Crushing Depths
		303657, -- Arcane Burst
		300492, -- Static Shock
		297907, -- Cursed Heart
		},
	},
	[1180] = {
		{ id = 1180, name = "Ny'alotha, the Waking City", raid = true },
		["Wrathion, the Black Emperor"] = {
		order = 1, ejid = 2368,
		306163, -- Incineration
		314347, -- Noxxious Choke
		307013, -- Burning Madness
		313250, -- Creeping Madness (mythic)
		},
		["Maut"] = {
		order = 2, ejid = 2365,
		307806, -- Devour Magic
		306301, -- Forbidden Mana
		307399, -- Shadow Wounds
		314992, -- Drain Essence
		314337, -- Ancient Curse (mythic)
		},
		["The Prophet Skitra"] = {
		order = 3, ejid = 2369,
		308059, -- Shadow Shock Applied
		307950, -- Shred Psyche
		},
		["Dark Inquisitor Xanesh"] = {
		order = 4, ejid = 2377,
		313198, -- Void Touched
		312406, -- Voidwoken
		},
		["The Hivemind"] = {
		order = 5, ejid = 2372,
		313461, -- Corrosion
		313129, -- Mindless
		313460, -- Nullification
		},
		["Shad'har the Insatiable"] = {
		order = 6, ejid = 2367,
		307358, -- Debilitating Spit
		307945, -- Umbral Eruption
		306929, -- Bubbling Breath
		307260, -- Fixate
		312332, -- Slimy Residue
		306930, -- Entropic Breath
		},
		["Drest'agath"] = {
		order = 7, ejid = 2373,
		310552, -- Mind Flay
		310358, -- Muttering Insanity
		},
		["Il'gynoth, Corruption Reborn"] = {
		order = 8, ejid = 2374,
		275269, -- Fixate
		311159, -- Cursed Blood
		},
		["Vexiona"] = {
		order = 9, ejid = 2370,
		307314, -- Encroaching Shadows
		307359, -- Despair
		310323, -- Desolation
		},
		["Ra-den the Despoiled"] = {
		order = 10, ejid = 2364,
		306819, -- Nullifying Strike
		306273, -- Unstable Vita
		306279, -- Instability Exposure
		309777, -- Void Defilement
		313227, -- Decaying Wound
		310019, -- Charged Bonds
		313077, -- Unstable Nightmare
		315252, -- Dread Inferno Fixate
		316065, -- Corrupted Existence
		},
		["Carapace of N'Zoth"] = {
		order = 11, ejid = 2366,
		307008, -- Breed Madness
		306973, -- Madness Bomb
		306984, -- Insanity Bomb
		307008, -- Breed Madness
		},
		["N'Zoth the Corruptor"] = {
		order = 12, ejid = 2375,
		308885, -- Mind Flay
		317112, -- Evoke Anguish
		309980, -- Paranoia
		},
	},
}
