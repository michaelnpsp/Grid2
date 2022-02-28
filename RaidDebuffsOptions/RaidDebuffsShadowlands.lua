if Grid2.isClassic then return end

local RDDB = Grid2Options:GetRaidDebuffsTable()
RDDB["Shadowlands"] = {
	-- 5 man instances
	[1188] = {
		{ id = 1188, name = "De Other Side" },
		["Hakkar the Soulflayer"] = {
		order = 1, ejid = 2408,
		322746, -- Sangre corrupta
		323569, -- Esencia derramada
		},
		["The Manastorms"] = {
		order = 2, ejid = 2409,
		320147, -- Sangrado
		320008, -- Descarga de Escarcha
		320144, -- Sierra circular
		},
		["Dealer Xy'exa"] = {
		order = 3, ejid = 2398,
		321948, -- Artilugio explosivo localizado
		320232, -- Artilugio explosivo
		},
		["Mueh'zala"] = {
		order = 4, ejid = 2410,
		325725, -- Artificio cósmico
		327649, -- Alma aplastada
		334913, -- Maestro de la muerte
		},
		["Trash"] = {
		order = 5, ejid = nil,
		333250, -- Atracador
		333711, -- Mordedura decrépita
		331847, -- 6U4U
		331379, -- Lubricar
		331008, -- Muy pegajoso
		1604, -- Atontado
		328987, -- Ferviente
		332707, -- Palabra de las Sombras: dolor
		332332, -- Esencia derramada
		332605, -- Maleficio
		332678, -- Herida sangrante
		334493, -- Polvo de centella soporífero
		334535, -- Corte de pico
		},
	},
	[1185] = {
		{ id = 1185, name = "Halls of Atonement" },
		["Halkias, the Sin-Stained Goliath"] = {
		order = 1, ejid = 2406,
		323001, -- Fragmentos de cristal
		322977, -- Visiones de luz de pecado
		},
		["Echelon"] = {
		order = 2, ejid = 2387,
		319703, -- Torrente de sangre
		319603, -- Maldición de piedra
		344874, -- Destrozado
		},
		["High Adjudicator Aleez"] = {
		order = 3, ejid = 2411,
		323650, -- Fijación inquietante
		},
		["Lord Chamberlain"] = {
		order = 4, ejid = 2413,
		323437, -- Estigma de orgullo
		335338, -- Ritual de tragedia
		},
		["Trash"] = {
		order = 5, ejid = nil,
		325876, -- Maldición de desintegración
		344993, -- Barrido serrado
		326632, -- Venas pétreas
		326638, -- Tirar guja
		326617, -- Convertir en piedra
		325700, -- Recoger pecados
		325701, -- Succionar vida
		326891, -- Angustia
		326874, -- Mordiscos en el tobillo
		},
	},
	[1184] = {
		{ id = 1184, name = "Mists of Tirna Scithe" },
		["Ingra Maloch"] = {
		order = 1, ejid = 2400,
		323250, -- Charco de ánima
		},
		["Mistcaller"] = {
		order = 2, ejid = 2402,
		321828, -- Palmas palmitas
		},
		["Tred'ova"] = {
		order = 3, ejid = 2405,
		322648, -- Vínculo mental
		},
		["Trash"] = {
		order = 4, ejid = nil,
		322486, -- Sobrecrecimiento
		322939, -- Cosechar esencia
		323043, -- Flebotomía
		322487, -- Sobrecrecimiento
		322968, -- Aliento moribundo
		322557, -- División de alma
		321968, -- Polen desconcertante
		325027, -- Ráfaga de zarzas
		331721, -- Aluvión de lanzas
		325021, -- Desgarro de Velo de Niebla
		340208, -- Triturar armadura
		340160, -- Aliento radiante
		325418, -- Ácido volátil
		326092, -- Veneno debilitador
		},
	},
	[1183] = {
		{ id = 1183, name = "Plaguefall" },
		["Globgrog"] = {
		order = 1, ejid = 2419,
		324652, -- Peste debilitadora
		326242, -- Onda de baba
		},
		["Doctor Ickus"] = {
		order = 2, ejid = 2403,
		329110, -- Inyección de baba
		322358, -- Tensión ardiente
		},
		["Domina Venomblade"] = {
		order = 3, ejid = 2423,
		325552, -- Tajo citotóxico
		331818, -- Emboscada de las Sombras
		333406, -- Asesinato
		},
		["Margrave Stradama"] = {
		order = 4, ejid = 2404,
		322232, -- Lluvia infecciosa
		},
		["Trash"] = {
		order = 5, ejid = nil,
		327882, -- Picoañublo
		320072, -- Charco tóxico
		319120, -- Bilis pútrida
		334926, -- Flema desdichada
		319070, -- Mugre corrosiva
		328180, -- Infección atenazante
		328986, -- Detonación violenta
		320512, -- Garras corroídas
		328409, -- Telarañas envolventes
		328501, -- Bomba de peste
		319898, -- Flema vil
		320542, -- Añublo extenuante
		328395, -- Perforador venenoso
		},
	},
	[1189] = {
		{ id = 1189, name = "Sanguine Depths" },
		["Kryxis the Voracious"] = {
		order = 1, ejid = 2388,
		},
		["Executor Tarvold"] = {
		order = 2, ejid = 2415,
		322554, -- Reprender
		},
		["Grand Proctor Beryllia"] = {
		order = 3, ejid = 2421,
		328593, -- Agonizar
		325885, -- Llantos angustiados
		},
		["General Kaal"] = {
		order = 4, ejid = 2407,
		323845, -- Carga perversa
		322796, -- Cuchillada perversa
		},
		["Trash"] = {
		order = 5, ejid = nil,
		321038, -- Torturar alma
		322429, -- Tajo mutilador
		326827, -- Ataduras aterradoras
		322212, -- Desconfianza creciente
		326790, -- Recarga radiante
		327814, -- Cuchillada perversa
		},
	},
	[1186] = {
		{ id = 1186, name = "Spires of Ascension" },
		["Kin-Tara"] = {
		order = 1, ejid = 2399,
		324662, -- Plasma ionizado
		327481, -- Lanza oscura
		},
		["Ventunax"] = {
		order = 2, ejid = 2416,
		324154, -- Zancada oscura
		324205, -- Destello cegador
		},
		["Oryphrion"] = {
		order = 3, ejid = 2414,
		323195, -- Explosión purificadora
		323792, -- Campo de ánima
		338729, -- Ánima cargada
		},
		["Devos, Paragon of Doubt"] = {
		order = 4, ejid = 2412,
		322818, -- Confianza perdida
		322817, -- Duda persistente
		},
		["Trash"] = {
		order = 5, ejid = nil,
		328331, -- Confesión forzosa
		328453, -- Opresión
		328434, -- Intimidado
		323739, -- Impacto residual
		317963, -- Carga de conocimiento
		317661, -- Veneno insidioso
		27638, -- Arañazo
		327648, -- Conflicto interno
		},
	},
	[1182] = {
		{ id = 1182, name = "The Necrotic Wake" },
		["Blightbone"] = {
		order = 1, ejid = 2395,
		320596, -- Arcadas fulminantes
		320717, -- Hambre de sangre
		},
		["Amarth, The Harvester"] = {
		order = 2, ejid = 2391,
		320170, -- Descarga necrótica
		333633, -- Ecos torturados
		},
		["Surgeon Stitchflesh"] = {
		order = 3, ejid = 2392,
		320200, -- Coseaguja
		322548, -- Gancho de carnicero
		320366, -- Icor embalsamante
		},
		["Nalthor the Rimebinder"] = {
		order = 4, ejid = 2396,
		320784, -- Lluvia de cometas
		320788, -- Ataduras congeladas
		322274, -- Socavar
		},
		["Trash"] = {
		order = 5, ejid = nil,
		320573, -- Pozo de las Sombras
		324293, -- Chillido estridente
		324381, -- Guadaña gélida
		321807, -- Deshuesar
		328664, -- Enfriado
		327396, -- Destino lúgubre
		338357, -- Ablandar
		338353, -- Salpicasangre
		334748, -- Drenar fluidos
		338606, -- Fijación mórbida
		333485, -- Nube enfermiza
		321821, -- Tripas asquerosas
		345625, -- Ráfaga mortífera
		334610, -- Fijación descerebrada
		333477, -- Rebanar tripas
		323471, -- Lanzar cuchilla
		},
	},
	[1187] = {
		{ id = 1187, name = "Theater of Pain" },
		["An Affront of Challengers"] = {
		order = 1, ejid = 2397,
		320248, -- Alteración genética
		320180, -- Esporas nocivas
		333231, -- Muerte abrasadora
		320069, -- Golpe mortal
		326892, -- Fijar
		},
		["Gorechop"] = {
		order = 2, ejid = 2401,
		323406, -- jagged-gash
		318913, -- Gas inmundo
		323130, -- Moco coagulante
		},
		["Xav the Unfallen"] = {
		order = 3, ejid = 2390,
		331606, -- Estandarte opresivo
		320287, -- Sangre y gloria
		},
		["Kul'tharok"] = {
		order = 4, ejid = 2389,
		319626, -- Parásito fantasmal
		319521, -- Extraer alma
		319539, -- Desalmado
		319531, -- Extraer alma
		},
		["Mordretha, the Endless Empress"] = {
		order = 5, ejid = 2417,
		324449, -- Muerte manifiesta
		323825, -- Falla enredadora
		},
		["Trash"] = {
		order = 6, ejid = nil,
		330810, -- Vincular alma
		333708, -- Corrupción de alma
		330784, -- Descarga necrótica
		330868, -- Salva de descarga necrótica
		342675, -- Lanza ósea
		333299, -- Maldición de desolación
		341949, -- Añublo marchitador
		330700, -- Añublo putrefacto
		332836, -- Golpe cortante
		330592, -- Erupción vil
		332708, -- Golpe en el suelo
		331288, -- Machaque colosal
		330562, -- Grito desmoralizador
		330532, -- Virote dentado
		333845, -- Arremetida desequilibrante
		320679, -- Cargar
		333861, -- Hoja rebotadora
		330725, -- Vulnerabilidad a las Sombras
		341291, -- Oscuridad desatada
		},
	},
	[1194] = {
		{ id = 1194, name = "Tazavesh, the Veiled Market" },
		["Zo'phex the Sentinel"] = {
		order = 1, ejid = 2437,
		345598, --interrogation
		345770, --impound-contraband
		345990, --containment-cell
		},
		["The Grand Menagerie"] = {
		order = 2, ejid = 2454,
		349627, --gluttony
		349954, --purification-protocol
		350101, --chains-of-damnation
		},
		["Mailroom Mayhem"] = {
		order = 3, ejid = 2436,
		346844, --alchemical-residue
		346962, --money-order
		346297, --unstable-explosion
		},
		["Myza's Oasis"] = {
		order = 4, ejid = 2452,
		353835, --suppression
		350919, --crowd-control
		},
		["So'azmi"] = {
		order = 5, ejid = 2451,
		347481, --shuri
		347623, --quickblade
		},
		["Hylbrande"] = {
		order = 6, ejid = 2448,
		348437, --bypass-code-helvete
		348447, --bypass-code-lys
		348450, --bypass-code-fryse
		348451, --bypass-code-morke
		},
		["Timecap'n Hooktail"] = {
		order = 7, ejid = 2449,
		352345, --anchor-shot
		347149, --infinite-breath
		347422, --deadly-seas
		},
		["So'leah"] = {
		order = 8, ejid = 2455,
		351119, --shuriken-blitz
		350804, --collapsing-energy
		},
		["Trash"] = {
		order = 9, ejid = nil,
		356548, --radiant-pulse
		355888, --hard-light-baton
		356407, --ancient-dread
		356408, --ground-stomp
		355640, --phalanx-field
		355479, --lethal-force
		347716, --letter-opener
		347775, --spam-filter
		355641, --scintillate
		}
	},
	-- World bosses
	[102222] = { -- World Bosses
 		{ id = 1192, name = "Shadowlands", raid = true },
		["Valinor, the Light of Eons"] = {
		order = 1, ejid = 2430,
		327255, --mark-of-penitence
		339278, --lysonias-call
		},
		["Mortanis"] = {
		order = 2, ejid = 2431,
		338851, --screaming-skull
		},
		["Oranomonos the Everbranching"] = {
		order = 3, ejid = 2432,
		338853, --rapid-growth
		},
		["Nurgash Muckformed"] = {
		order = 4, ejid = 2433,
		},
	},
	-- Raid instances
	[1190] = {
		{ id = 1190, name = "Castle Nathria", raid = true },
		["Shriekwing"] = {
		order = 1, ejid = 2393,
		340324, --sanguine-ichor
		328897, --exsanguinated
		345397, --wave-of-blood
		328921, --blood-shroud
		341489, --bloodlight
		343365, --ravenous-horrors
		},
		["Huntsman Altimor"] = {
		order = 2, ejid = 2429,
		335114, --sinseeker
		334971, --jagged-claws
		334939, --vicious-lunge
		334708, --deathly-roar
		334852, --petrifying-howl
		334893, --stone-shards
		334960, --vicious-wound
		},
		["Sun King's Salvation"] = {
		order = 3, ejid = 2422,
		325442, --vanquished
		341473, --crimson-flurry
		333002, --vulgar-brand
		325665, --soul-infusion
		326456, --burning-remnants
		325877, --ember-blast
		339251, --drained-soul
		328579, --smoldering-remnants
		326430, --lingering-embers
		326078, --infusers-boon
		},
		["Artificer Xy'mox"] = {
		order = 4, ejid = 2418,
		328437, --dimensional-tear
		325361, --glyph-of-destruction
		340860, --withering-touch
		340870, --aura-of-dread
		340533, --arcane-vulnerability
		327414, --possession
		326271, --stasis-trap
		},
		["Hungering Destroyer"] = {
		order = 5, ejid = 2428,
		329298, --gluttonous-miasma
		332295, --growing-hunger
		334266, --volatile-ejection
		334522, --consume
		334755, --essence-sap
		},
		["Lady Inerva Darkvein"] = {
		order = 6, ejid = 2420,
		325184, --loose-anima
		325379, --expose-desires
		325382, --warped-desires
		325908, --shared-cognition
		63849 , --exposed-heart
		325769, --bottled-anima
		325718, --lingering-anima
		331527, --indemnification
		324983, --shared-suffering
		331573, --unconscionable-guilt
		342321, --concentrated-anima
		341746, --rooted-in-anima
		},
		["The Council of Blood"] = {
		order = 7, ejid = 2426,
		340612, --party-foul
		327773, --drain-essence
		346681, --soul-spikes
		346690, --duelists-riposte
		327619, --waltz-of-blood
		330848, --wrong-moves
		334909, --oppressive-atmosphere
		337110, --dreadbolt-volley
		327503, --evasive-lunge
		346945, --manifest-pain
		346932, --two-left-feet
		347350, --dancing-fever
		},
		["Sludgefist"] = {
		order = 8, ejid = 2394,
		335300, --chain-link
		331209, --hateful-gaze
		332572, --falling-rubble
		335295, --shattering-chain
		332197, --collapsing-foundation
		332443, --crumbling-foundation
		335354, --chain-slam
		339189, --chain-bleed
		},
		["Stone Legion Generals"] = {
		order = 9, ejid = 2425,
		343881, --serrated-tear
		334771, --heart-hemorrhage
		334765, --heart-rend
		342425, --stone-fist
		343063, --stone-spike
		333913, --wicked-laceration
		339693, --crystalline-burst
		339690, --crystalize
		343898, --soultaint-effigy
		},
		["Sire Denathrius"] = {
		order = 10, ejid = 2424,
		327992, --desolation
		326699, --burden-of-sin
		328276, --march-of-the-penitent
		330580, --bloodbound
		329875, --carnage
		329974, --impale
		329181, --wracking-pain
		332585, --scorn
		332797, --fatal-finesse
		327089, --feeding-time
		327796, --night-hunter
		327842, --touch-of-the-night
		335873, --rancor
		338683, --nathrian-hymn-sinsear
		338685, --nathrian-hymn-evershade
		338686, --nathrian-hymn-duskhollow
		338688, --nathrian-hymn-gloomveil
		341366, --hollow-grasp
		},
	},
	[1193] = {
		{ id = 1193, name = "Sanctum of Domination", raid = true },
		["The Tarragrue"] = {
		order = 1, ejid = 2435,
		347269, --chains-of-eternity
		347286, --unshakeable-dread
		347283, --predators-howl
		346985, --overpower
		346986, --crushed-armor
		},
		["The Eye of the Jailer"] = {
		order = 2, ejid = 2442,
		349979, --dragging-chains
		348969, --immediate-extermination
		351826, --suffering
		350713, --slothful-corruption
		},
		["The Nine"] = {
		order = 3, ejid = 2439,
		350542, --fragments-of-destiny
		350555, --shard-of-destiny
		350202, --unending-strike
		350039, --arthuras-crushing-gaze
		350287, --song-of-dissolution
		},
		["Remnant of Ner'zhul"] = {
		order = 4, ejid = 2444,
		349890, --suffering
		350469, --malevolence
		350073, --torment
		},
		["Soulrender Dormazain"] = {
		order = 5, ejid = 2445,
		350217, --torment
		348985, --warmonger-shackles
		350650, --defiance
		351946, --hellscream
		350422, --ruinblade
		},
		["Painsmith Raznal"] = {
		order = 6, ejid = 2443,
		355568, --cruciform-axe
		348508, --reverberating-hammer
		355778, --dualblade-scythe
		355786, --blackened-armor
		356870, --flameclasp-eruption
		348456, --flameclasp-trap
		356472, --lingering-flames
		},
		["Guardian of the First Ones"] = {
		order = 7, ejid = 2446,
		352538, --purging-protocol
		352394, --radiant-energy
		352385, --energizing-link
		350732, --sunder
		347359, --suppression-field
		},
		["Fatescribe Roh-Kalo"] = {
		order = 8, ejid = 2447,
		350568, --call-of-eternity
		350355, --fated-conjunction
		353122, --darkest-destiny
		353195, --extemporaneous-fate
		351680, --invoke-destiny
		353435, --overwhelming-burden
		354964, --runic-affinity
		354365, --grim-portent
		353432, --burden-of-destiny
		},
		["Kel'Thuzad"] = {
		order = 9, ejid = 2440,
		354289, --sinister-miasma
		348978, --soul-exhaustion
		357298, --frozen-binds
		355137, --shadow-pool
		352051, --necrotic-surge
		},
		["Sylvanas Windrunner"] = {
		order = 10, ejid = 2441,
		347504, --windrunner
		354147, --raze
		347807, --barbed-arrow
		349458, --domination-chains
		356651, --woe
		358704, --black-arrow
		358711, --rage
		351180, --lashing-wound
		351117, --crushing-dread
		351323, --detonation
		351452, --lethargic-focus
		351589, --filth
		351562, --expulsion
		353929, --banshees-bane
		353642, --invigorating-field
		},
		["Trash"] = {
		order = 11, ejid = nil,
		337938, --lumbering-form
		347988, --ten-of-towers
		338733, --ever-beating-heart
		},
	},
	[1195] = {
		{ id = 1195, name = "Sepulcher of the First Ones", raid = true },
		["Vigilant Guardian"] = {
		order = 1, ejid = 2458,
		364447, -- dissonance
		360202, -- spike-of-creation
		367571, -- sear
		360458, -- unstable-core
		364881, -- matter-dissolution
		364904, -- anti-matter
		360414, -- pneumatic-impact
		364843, -- fractured-core
		364962, -- core-overload
		},
		["Skolex, the Insatiable Ravener"] = {
		order = 2, ejid = 2465,
		359778, -- ephemera-dust
		360098, -- warp-sickness
		366070, -- volatile-residue
		364522, -- devouring-blood
		359976, -- riftmaw
		},
		["Artificer Xy'mox"] = {
		order = 3, ejid = 2470,
		363413, -- genesis-rings
		365752, -- ancient-exhaust
		365801, -- relic-collapse
		363114, -- genesis-supernova
		365682, -- massive-blast
		364030, -- debilitating-ray
		},
		["Dausegne, the Fallen Oracle"] = {
		order = 4, ejid = 2459,
		361966, -- infused-strikes
		361751, -- disintegration-halo
		},
		["Prototype Pantheon"] = {
		order = 5, ejid = 2460,
		360687, -- runecarvers-deathtouch
		360259, -- gloom-bolt
		365041, -- windswept-wings
		362352, -- pinned
		361784, -- touch-of-the-night
		362383, -- anima-bolt
		361689, -- wracking-pain
		361608, -- burden-of-sin
		364867, -- sinful-projection
		},
		["Lihuvim, Principal Architect"] = {
		order = 6, ejid = 2461,
		360159, -- unstable-mote
		363681, -- deconstructing-blast
		368024, -- kinetic-resonance
		368025, -- sundering-resonance
		364092, -- degenerate
		366012, -- terminal-mote
		362447, -- instability
		},
		["Halondrus the Reclaimer"] = {
		order = 7, ejid = 2463,
		368961, -- charge-exposure
		360114, -- ephemeral-fissure
		361597, -- ephemeral-eruption
		368529, -- eternity-overdrive
		},
		["Anduin Wrynn"] = {
		order = 8, ejid = 2469,
		368913, -- force-of-will
		362055, -- lost-soul
		365445, -- scarred-soul
		364031, -- gloom
		365293, -- befouled-barrier
		366849, -- domination-word-pain
		363024, -- necrotic-detonation
		363020, -- necrotic-claws
		364020, -- march-of-the-damned
		362543, -- remorseless-winter
		363028, -- unraveling-frenzy
		368428, -- purging-light
		},
		["Lords of Dread"] = {
		order = 9, ejid = 2457,
		360300, -- swarm-of-decay
		360304, -- swarm-of-darkness
		362158, -- decay-mastery
		364985, -- biting-wounds
		360008, -- cloud-of-carrion
		359963, -- opened-veins
		360418, -- paranoia
		360420, -- shatter-mind
		362152, -- shadow-mastery
		360148, -- bursting-dread
		360241, -- unsettling-dreams
		},
		["Rygelon"] = {
		order = 10, ejid = 2467,
		361548, -- dark-eclipse
		362273, -- quasar-radiation
		362206, -- event-horizon
		362081, -- cosmic-ejection
		362088, -- cosmic-irregularity
		366379, -- stellar-shroud
		362172, -- corrupted-wound
		363598, -- unstable-antimatter
		364386, -- gravitational-collapse
		},
		["The Jailer"] = {
		order = 11, ejid = 2464,
		366381, -- arcane-vulnerability
		366703, -- azerite-radiation
		362075, -- domination
		362631, -- chains-of-oppression
		363893, -- martyrdom
		363886, -- imprisonment
		362194, -- suffering
		362192, -- relentless-misery
		366665, -- unholy-eruption
		359868, -- shattering-blast
		366777, -- consumed-azerite
		360425, -- unholy-ground
		366285, -- rune-of-compulsion
		365153, -- dominating-will
		365219, -- chains-of-anguish
		365385, -- cry-of-loathing
		365174, -- defile
		},
	},
}
