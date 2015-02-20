local RDDB = Grid2Options:GetRaidDebuffsTable()
RDDB["Warlords of Draenor"] = {
	[994] = { -- Highmaul
		["Kargath Bladefist"] = {
		order = 1, ejid = 1128,
		158986, -- Berserker Rush
		159947, -- Chain Hurl
		162497, -- On the Hunt	
		159178, -- Open Wounds
		159213, -- Monster's Brawl
		159410, -- Mauling Brew
		159413, -- Mauling Brew
		160521, -- Vile Breath
		159386, -- Iron Bomb
		159188, -- Grapple
		159202, -- Flame Jet
		159311, -- Flame Jet		
		159113, -- Impale
		},
		["The Butcher"] = {
		order = 2, ejid = 971,
		156147, -- The Cleaver
		156151, -- The Tenderizer
		156152, -- Gushing Wounds
		163046, -- Pale Vitriol
		},
		["Tectus"] = {
		order = 3, ejid = 1195,
		162346, -- Crystalline Barrage
		162892, -- Petrification
		},
		["Brackenspore"] = {
		order = 4, ejid = 1196,
		163241, -- Rot
		163242, -- Infesting Spores
		163590, -- Creeping Moss
		159220, -- Necrotic Breath
		160179, -- Mind Fungus
		159972, -- Flesh Eater
		},
		["Twin Ogron"] = {
		order = 5, ejid = 1148,
		167200, -- Arcane Wound
		158241, -- Blaze
		163372, -- Arcane Volatility
		158026, -- Enfeebling Roar
		155569, -- Injured
		159709, -- Weakened Defenses
		},
		["Ko'ragh"] = {
		order = 6, ejid = 1153,
		162186, -- Expel Magic: Arcane
		172813, -- Expel Magic: Frost
		162185, -- Expel Magic: Fire
		162184, -- Expel Magic: Shadow
		161345, -- Suppression Field
		161242, -- Caustic Energy
		163472, -- Dominating Power
		},
		["Imperator Mar'gok"] = {
		order = 7, ejid = 1197,
		16400,  -- Poison
		156225, -- Branded
		164005, -- Branded: Fortification
		164006, -- Branded: Replication
		164004, -- Branded: Displacement
		158605, -- Mark of Chaos
		164176, -- Mark of Chaos: Displacement
		164178, -- Mark of Chaos: Fortification
		164191, -- Mark of Chaos: Replication
		159200, -- Destructive Resonance
		157353, -- Force Nova
		158619, -- Fetter
		174106, -- Destructive Resonance
		157801, -- Slow
		157763, -- Fixate
		158553, -- Crush Armor
		},
		["Trash"] = {
		order = 50,
		175601, -- Tainted Claws
		172069, -- Radiating Poison
		56037,  -- Rune of Destruction
		175654, -- Rune of Disintegration
		174446, -- Pulverize
		166185, -- Rending Slash
		166171, -- Intimidating Roar
		166175, -- Earthdevastating Slam
		174404, -- Frozen Core
		173827, -- Wild Flames
		174500, -- Rending Throw
		166200, -- Arcane Volatility
		175599, -- Devour
		174961, -- Time Stop
		174452, -- Pulverized
		166779, -- Staggering Blow
		175614, -- Chaos Blast
		161635, -- Molten Bomb
		174473, -- Corrupted Blood
		174475, -- Corrupted Blood
		},
	},
	[988] = { -- Blackrock Foundry
		["Gruul"] = {
		order = 1, ejid = 1161,
		155078, -- Overwhelming Blows
		155323, -- Petrifying Slam
		155506, -- Petrified
		},
		["Oregorger"] = {
		order = 2, ejid = 1202,
		173471, -- Acid Maw
		},
		["Beastlord Darmac"] = {
		order = 3, ejid = 1122,
		154960, -- Pinned Down
		154981, -- Conflagration
		155061, -- Rend and Tear
		155030, -- Seared Flesh
		155236, -- Crush Armor
		},
		["Flamebender Ka'graz"] = {
		order = 4, ejid = 1123,
		154932, -- Molten Torrent
		163284, -- Rising Flames
		154952, -- Fixate
		},
		["Hans'gar and Franzok"] = {
		order = 5, ejid = 1155,
		157139, -- Shattered Vertebrae
		},
		["Operator Thogar"] = {
		order = 6, ejid = 1147,
		155921, -- Enkindle
		155864, -- Prototype Pulse Grenade
		159481, -- Delayed Siege Bomb
		164380, -- Burning
		},
		["The Blast Furnace"] = {
		order = 7, ejid = 1154,
		155196, -- Fixate (Slag Elemental)
		155192, -- Bomb
		176121, -- Volatile Fire
		175104, -- Melt Armor
		155242, -- Heat
		},
		["Kromog"] = {
		order = 8, ejid = 1162,
		156766, -- Warped Armor
		},
		["The Iron Maidens"] = {
		order = 9, ejid = 1203,
		156626, -- Rapid Fire
		164271, -- Penetrating Shot
		156214, -- Convulsive Shadows
		156007, -- Impale
		158315, -- Dark Hunt
		157950, -- Bloodsoaked Heartseeker
		},
		["Blackhand"] = {
		order = 10, ejid = 959,
		156096, -- Marked for Death
		157000, -- Attach Slag Bombs
		},
		["Trash"] = {
		order= 50,
		},
	},
	-- world bosses
	[949] = { -- Gorgrond
		["Drov the Ruiner"] = {
		ejid = 1291,
		175915, -- Acid Breath
		},
		["Tarlna the Ageless"] = {
		ejid = 1211,
		176004, -- Savage Vines
		}
	},
	[989] = { -- Spires of Arak
		["Rukhmar"] = {
		ejid = 1262,
		167615, -- Pierced Armor
		}
	},
	-- 5 man Instances
	[987] = { -- Puerto de Hierro 
		["Nok'Gar"] = {
		order = 1, ejid = 1235,
		164837, -- Vapuleo salvaje
		164504, -- Intimidado
		},
		["Makogg Hojascuas"] = {
		order = 2, ejid = 1236,
		163390, -- Trampas de ogro
		163740, -- Sangre corrupta
		163276, -- Tendones desgarrados
		},
		["Oshir"] = {
		order = 3, ejid = 1237,
		},
		["Skulloc"] = {
		order = 4, ejid = 1238,
		168398, -- Fijación de objetivo de Fuego rápido
		168227, -- Machaque gronn
		},
		["Trash"] = {
		order = 100, ejid = nil,
		172771, -- Proyectil incendiario
		169341, -- Rugido desmoralizador
		167240, -- Disparo en la pierna
		172889, -- Carga con tajo
		173113, -- Lanzamiento de hachuela
		173307, -- Lanza dentada
		158341, -- Heridas sangrantes
		},
	},
	[989] = { -- Trecho Celestial 
		["Ranjit"] = {
		order = 1, ejid = 965,
		153757, -- Abanico de hojas
		153759, -- Muro de viento
		154043, -- Destello luminoso
		153139, -- Cuatro vientos
		},
		["Araknath"] = {
		order = 2, ejid = 966,
		154150, -- Energizar
		},
		["Rukhran"] = {
		order = 3, ejid = 967,
		176544, -- Fijar
		160149, -- Débil
		},
		["Trash"] = {
		order = 100, ejid = nil,
		153123, -- Cuchilla giratoria
		156841, -- Tormenta
		153907, -- Derviche
		160288, -- Detonación solar
		152982, -- Exponer debilidad
		152838, -- Fijado
		153001, -- Quemar
		152999, -- Quemar
		160303, -- Detonación solar
		},
	},
	[1008] = { -- El Vergel Eterno 
		["Cortezamustia"] = {
		order = 1, ejid = 1214,
		164294, -- Crecimiento descontrolado
		},
		["Ancianos protectores"] = {
		order = 2, ejid = 1207,
		167977, -- Zona de zarzas
		169658, -- Heridas infectadas
		168187, -- Carga desgarradora
		},
		["Archimaga Sol"] = {
		order = 3, ejid = 1208,
		166492, -- Flor de fuego
		168894, -- Bola de Fuego
		170016, -- Polen Focoluz
		166726, -- Lluvia helada
		},
		["Xeri'tac"] = {
		order = 4, ejid = 1209,
		173080, -- Fijar
		169376, -- Picadura venenosa
		169223, -- Gas tóxico
		},
		["Yalnu"] = {
		order = 5, ejid = 1210,
		169179, -- Arremetida colosal
		170132, -- Enredo
		169879, -- Aliento nocivo
		169876, -- Desgarre de tendón
		},
		["Trash"] = {
		order = 100, ejid = nil,
		169823, -- Bola de Fuego
		169840, -- Descarga de Escarcha
		169844, -- Aliento de dragón
		169824, -- Descarga de Escarcha
		169850, -- Ola gélida
		169839, -- Bola de Fuego
		164886, -- Toxina de horripétalo
		164834, -- Tromba de hojas
		164965, -- Vides asfixiantes
		},
	},
	[995] = { -- Cumbre de Roca Negra Superior 
		["Gor'ashan"] = {
		order = 1, ejid = 1226,
		},
		["Kyrak"] = {
		order = 2, ejid = 1227,
		162600, -- Ungüento de emanaciones tóxicas
		},
		["Comandante Tharbek"] = {
		order = 3, ejid = 1228,
		161772, -- Aliento incinerador
		161765, -- Hacha de hierro
		155589, -- Nova de Escarcha
		},
		["Alaíra el Indomable"] = {
		order = 4, ejid = 1229,
		155056, -- Fuego envolvente
		155065, -- Garra destripadora
		},
		["Señora de la guerra Zaela"] = {
		order = 5, ejid = 1234,
		155721, -- Ciclón Hierro Umbrío
		},
		["Son of the Beast"] = {
		order = 50, ejid = nil,
		157428, -- Rugido aterrorizador
		},
		["Trash"] = {
		order = 100, ejid = nil,
		1604, -- Atontado
		153832, -- Devastar
		153897, -- Tajo desgarrador
		153981, -- Obús incendiario
		155037, -- Erupción
		155586, -- Velo de Sombras
		155581, -- Hender armadura
		167259, -- Grito intimidador
		155572, -- Machaque
		154827, -- Rugido intimidatorio
		163057, -- Choque de llamas
		165944, -- Machaque devastador
		165954, -- Ola de choque
		},
	},
	[984] = { -- Auchindoun 
		["Vigilante Kaathar"] = {
		order = 1, ejid = 1185,
		153430, -- Suelo santificado
		},
		["Vinculadora de almas Nyami"] = {
		order = 2, ejid = 1186,
		154477, -- Palabra de las Sombras: dolor
		154218, -- Martillo de mediador
		},
		["Azzakel"] = {
		order = 3, ejid = 1216,
		153234, -- Látigo vil
		153396, -- Cortina de llamas
		},
		["Teron'gor"] = {
		order = 4, ejid = 1225,
		156964, -- Inmolar
		156960, -- Conflagrar
		},
		["Trash"] = {
		order = 100, ejid = nil,
		157165, -- Cortar tendón
		157170, -- Abrasamiento mental
		176511, -- Escudo de vengador
		157797, -- Martillo de mediador
		154852, -- Martillo de celador
		154263, -- Cadena del celador
		157168, -- Fijar
		156954, -- Aflicción inestable
		157052, -- Corrupción
		156854, -- Drenar vida
		156856, -- Lluvia de Fuego
		},
	},
	[993] = { -- Terminal Malavía 
		["Chispahete y Borka"] = {
		order = 1, ejid = 1138,
		162507, -- Adquiriendo objetivos
		162491, -- Adquiriendo objetivos
		},
		["Nitrogg Torre del Trueno"] = {
		order = 2, ejid = 1163,
		166570, -- Carga de escoria
		160681, -- Fuego supresivo
		},
		["Señora del Cielo Tovra"] = {
		order = 3, ejid = 1133,
		162057, -- Lanza giratoria
		163447, -- Marca del cazador
		161588, -- Energía difusa
		162065, -- Cepo congelante
		},
		["Trash"] = {
		order = 100, ejid = nil,
		164192, -- 50 000 voltios
		176025, -- Espiral de lava
		176033, -- Lengua de Fuego
		164218, -- Tajo doble
		176147, -- Ignición
		164241, -- Heridas hemorrágicas
		166340, -- Zona de trueno
		},
	},
	[964] = { -- Minas Machacasangre 
		["Magmolatus"] = {
		order = 1, ejid = 893,
		150011, -- Tromba de magma
		149941, -- Machaque duro
		149975, -- Llamas bailarinas
		150032, -- Llamas fulminantes
		150023, -- Machaque de escoria
		},
		["Vigilante de esclavos Crushto"] = {
		order = 2, ejid = 888,
		153679, -- Aplastamiento terráqueo
		150751, -- Salto aplastante
		150807, -- Golpe traumático
		151092, -- Golpe traumático
		},
		["Roltall"] = {
		order = 3, ejid = 887,
		167739, -- Aura agostadora
		152897, -- Ola de calor
		153227, -- Escoria ardiente
		},
		["Gug'rokk"] = {
		order = 4, ejid = 889,
		163802, -- Sacudida de llamas
		164616, -- Canalizar llamas
		150784, -- Erupción de magma
		},
		["Trash"] = {
		order = 100, ejid = nil,
		151415, -- Aplastar
		151446, -- Machaque
		152089, -- Boleadora eléctrica
		151638, -- Campo de anulación
		151697, -- Subyugar
		152235, -- Rugido atemorizador
		151685, -- Abolladura de armadura
		151720, -- Arco de lava
		1604, -- Atontado
		151566, -- Vínculo de magma
		},
	},
	[969] = { -- Cementerio de Sombraluna 
		["Nhallish"] = {
		order = 2, ejid = 1168,
		153070, -- Devastación del vacío
		153501, -- Explosión del Vacío
		156776, -- Látigo del vacío sajador
		152819, -- Palabra de las Sombras: flaqueza
		},
		["Ner'zhul"] = {
		order = 4, ejid = 1160,
		154442, -- Malevolencia
		},
		["Trash"] = {
		order = 100, ejid = nil,
		1604, -- Atontado
		153524, -- Flema de peste
		},
	},
}
