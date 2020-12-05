-- Wow Classic raid debuffs
-- Key&id = InstanceMapID (select(8,GetInstanceInfo())) + 100000
if not Grid2.isClassic then return end

local RDDB = Grid2Options:GetRaidDebuffsTable()

RDDB["Classic"] = {
	[100509] = {
		{ id = 100509, name = "Ruins of Ahn'Qiraj (AQ20)", raid = true },
		["Ayamiss"] = {
		order = 1, ejid = nil,
		25725, -- Paralizar
		},
		["Buru"] = {
		order = 2, ejid = nil,
		96, -- Desmembramiento
		},
		["Kurinnaxx"] = {
		order = 3, ejid = nil,
		25646, -- Herida mortal
		25656, -- Trampa de arena
		},
		["Moam"] = {
		order = 4, ejid = nil,
		25685, -- Energizar
		},
		["Ossirian"] = {
		order = 5, ejid = nil,
		25176, -- Fuerza de Ossirian
		25189, -- Vientos envolventes
		25183, -- Debilidad a las Sombras
		},
		["Rajaxx"] = {
		order = 6, ejid = nil,
		25471, -- Orden de ataque
		},
	},
	[100531] = {
		{ id = 100531, name = "Temple of Ahn'Qiraj (AQ40)", raid = true },
		["CThun"] = {
		order = 1, ejid = nil,
		},
		["Fankriss"] = {
		order = 2, ejid = nil,
		25646, -- Herida mortal
		},
		["Huhuran"] = {
		order = 3, ejid = nil,
		26180, -- Aguijón de dracoleón
		26050, -- Gapo ácido
		},
		["Ouro"] = {
		order = 4, ejid = nil,
		26615, -- Rabia
		},
		["Sartura"] = {
		order = 5, ejid = nil,
		},
		["Skeram"] = {
		order = 6, ejid = nil,
		785, -- Consecucién veraz
		},
		["ThreeBugs"] = {
		order = 7, ejid = nil,
		26580, -- Miedo
		},
		["TwinEmps"] = {
		order = 8, ejid = nil,
		},
		["Viscidus"] = {
		order = 9, ejid = nil,
		26034, -- Víscido ralentizado
		26036, -- Víscida más ralentizado
		25937, -- Congelación víscida
		},
	},
	[100409] = {
		{ id = 100409, name = "Molten Core (MC)", raid = true },
		["Garr"] = {
		order = 1, ejid = nil,
		15732, -- Inmolar
		},
		["Geddon"] = {
		order = 2, ejid = nil,
		20475, -- Bomba viviente
		},
		["Gehennas"] = {
		order = 3, ejid = nil,
		20277, -- Puño de Ragnaros
		},
		["Golemagg"] = {
		order = 4, ejid = nil,
		20553, -- Confianza de Golemagg
		},
		["Lucifron"] = {
		order = 5, ejid = nil,
		20604, -- Dominar mente
		},
		["Magmadar"] = {
		order = 6, ejid = nil,
		19451, -- Frenesí
		},
		["Majordomo"] = {
		order = 7, ejid = nil,
		},
		["Ragnaros"] = {
		order = 8, ejid = nil,
		},
		["Shazzrah"] = {
		order = 9, ejid = nil,
		19714, -- Atenuar magia
		},
		["Sulfuron"] = {
		order = 10, ejid = nil,
		19779, -- Inspirar
		19780, -- Mano de Ragnaros
		19776, -- Palabra de las Sombras: Dolor
		20294, -- Inmolar
		},
	},
	[469] = {
		{ id = 469, name = "Blackwing Lair (BWL)", raid = true },
		["Broodlord"] = {
		order = 1, ejid = nil,
		24573, -- Golpe mortal
		},
		["Chromaggus"] = {
		order = 2, ejid = nil,
		23155, -- Aflicción del enjambre: rojo
		23169, -- Aflicción del enjambre: verde
		23153, -- Aflicción del enjambre: azul
		23154, -- Aflicción del enjambre: negro
		23170, -- Aflicción del enjambre: bronce
		23128, -- Frenesí
		23537, -- Enfurecer
		},
		["Ebonroc"] = {
		order = 3, ejid = nil,
		23340, -- Sombra de Ebanorroca
		},
		["Firemaw"] = {
		order = 4, ejid = nil,
		},
		["Flamegor"] = {
		order = 5, ejid = nil,
		},
		["Nefarian"] = {
		order = 6, ejid = nil,
		22687, -- Velo de Sombras
		22667, -- Orden de las Sombras
		},
		["Razorgore"] = {
		order = 7, ejid = nil,
		23023, -- Conflagración
		},
		["Vaelastrasz"] = {
		order = 8, ejid = nil,
		18173, -- Adrenalina ardiente
		},
	},
	[100249] = {
		{ id = 100249, name = "Onyxia's Lair", raid = true },
		["Onyxia"] = {
		order = 1,
		18431, -- clamor-bramante
		},
	},
	[100309] = {
		{ id = 100309, name = "Zul'gurub", raid = true },
		["Arlokk"] = {
		order = 1, ejid = nil,
		24210, -- Marca de Arlokk
		24212, -- Palabra de las Sombras: Dolor
		},
		["Bloodlord"] = {
		order = 2, ejid = nil,
		24314, -- Mirada amenazante
		24318, -- Enfurecer
		16856, -- Golpe mortal
		},
		["EdgeOfMadness"] = {
		order = 3, ejid = nil,
		24664, -- Dormir
		8269, -- Enfurecer
		},
		["Gahzranka"] = {
		order = 4, ejid = nil,
		},
		["Hakkar"] = {
		order = 5, ejid = nil,
		24327, -- Provocar locura
		24328, -- Sangre corrupta
		},
		["Jeklik"] = {
		order = 6, ejid = nil,
		23952, -- Palabra de las Sombras: Dolor
		},
		["Jindo"] = {
		order = 7, ejid = nil,
		24306, -- Ilusiones de Jin'do
		17172, -- Maleficio
		24261, -- Lavado de cerebro
		},
		["Marli"] = {
		order = 8, ejid = nil,
		24111, -- Veneno corrosivo
		24300, -- Drenar vida
		24109, -- Ensanchar
		},
		["Thekal"] = {
		order = 9, ejid = nil,
		21060, -- Ceguera
		12540, -- Incapacitación
		},
		["Venoxis"] = {
		order = 10, ejid = nil,
		23895, -- Renovar
		23860, -- Fuego Sagrado
		23865, -- Serpiente parasitaria
		},
	},
	[100533] = {
		{ id = 100533, name = "Naxxramas", raid = true },
		["Anub'Rekhan"] = {
		order = 1, ejid = nil,
		28786, --Locust Swarm
		28969, --acid-spit
		28783, --impale
		28991, --web
		},
		["Grand Widow Faerlina"] = {
		order = 2, ejid = nil,
		28796, --Poison Bolt Volley
		28794, --Rain of Fire
		},
		["Maexxna"] = {
		order = 3, ejid = nil,
		28622, --Web Wrap
		29484, --web-spray
		28776,--Necrotic Poison
		},
		["Noth the Plaguebringer"] = {
		order = 4, ejid = nil,
		29213, --Curse of the Plaguebringer
		29214, --Wrath of the Plaguebringer
		29212, --Cripple
		},
		["Heigan The Unclean"] = {
		order = 5, ejid = nil,
		29998,--Decrepit Fever (N, H)
		29310,--Spell Disruption
		},
		["Loatheb"] = {
		order = 6, ejid = nil,
		29232, --fungal-bloom
		29865, --poison-aura
		29185, --corrupted-mind
		},
		["Instructor Razuvious"] = {
		order = 7, ejid = nil,
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
		["Grobbulus"] = {
		order = 11, ejid = nil,
		28169,--Mutating Injection
		},
		["Gluth"] = {
		order = 12, ejid = nil,
		29685, --terrifying-roar
		25646, --mortal-wound
		29306, --infected-wound
		},
		["Thaddius"] = {
		order = 13, ejid = nil,
		28084, --Negative Charge (N, H)
		28059, --Positive Charge (N, H)
		},
		["Sapphiron"] = {
		order = 14, ejid = nil,
		28522, --Icebolt
		28542, --Life Drain
		},
		["Kel'Thuzad"] = {
		order = 15, ejid = nil,
		28410,--Chains of Kel'Thuzad (H)
		27819,--Detonate Mana (NH)
		27808,--Frost Blast (NH)
		},
		["Trash"] = {
		order = 16, ejid = nil,
		4283,  --stomp
		15579, --cleave
		13737, --mortal-strike
		16145, --sunder-armor
		},
	},
}
