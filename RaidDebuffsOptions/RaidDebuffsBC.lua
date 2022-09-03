-- Wow TBC raid debuffs
-- Key&id = InstanceMapID (select(8,GetInstanceInfo())) + 100000
if Grid2.versionCli<20000 then return end

local RDDB= Grid2Options:GetRaidDebuffsTable()

RDDB["The Burning Crusade"] = {
	[100532] = {
		{ id = 100532, name = "Karazhan", raid = true },
		["Attumen the Huntsman"] = {
		order = 1, ejid = nil,
		29833, -- intangible-presence
		},
		["Moroes"] = {
		order = 2, ejid = nil,
		29425, -- gouge
		37066, -- garrote
		34694, -- blind
		},
		["Maiden of Virtue"] = {
		order = 3, ejid = nil,
		29522, -- Holy Fire
		29511, -- Repentance
		30115, -- Sacrifice
		},
		["The Big Bad Wolf, Opera"] = {
		order = 4, ejid = nil,
		30753, -- red-riding-hood
		},
		["Wizard of Oz, Opera"] = {
		order = 5, ejid = nil,
		31046, -- brain-bash
		31069, -- brain-wipe
		31041, -- mangle
		29538, -- cyclone
		},
		["Romulo and Julianne, Opera"] = {
		order = 6, ejid = nil,
		30822, -- poisoned-thrust
		30890, -- blinding-passion
		30889, -- powerful-attraction
		},
		["The Curator"] = {
		order = 7, ejid = nil,
		},
		["Terestian Illhoof"] = {
		order = 8, ejid = nil,
		30115, -- sacrifice
		30053, -- amplify-flames
		},
		["Shade of Aran"] = {
		order = 9, ejid = nil,
		29991, -- chains-of-ice
		29946, -- flame-wreath
		29954, -- frostbolt
		29951, -- blizzard
		},
		["Prince Malchezaar"] = {
		order = 10, ejid = nil,
		30843, -- Enfeeble
		},
		["Netherspite"] = {
		order = 11, ejid = nil,
		37014, --void-zone
		30522, --nether-burn
		},
		["Nightbane"] = {
		order = 12, ejid = nil,
		37098, -- rain-of-bones
		30130, -- distracting-ash
		30129, -- charred-earth
		25653, -- tail-sweep
		30210, -- smoldering-breath
		},
	},
	[100548] = {
		{ id = 100548, name = "Serpentshrine Cavern", raid = true },
		["Hydross the Unstable"] = {
		order = 1, ejid = nil,
		38235, -- water bomb
		38246, -- vlie sludge
		},
		["The Lurker Below"] = {
		order = 2, ejid = nil,
		},
		["Leotheras the Blind"] = {
		order = 3, ejid = nil,
		37676, -- insidious whisper
		37640, -- whirlwind
		37749, -- consuming madness
		},
		["Fathom-Lord Karathress"] = {
		order = 4, ejid = nil,
		38234, -- frost-shock
		39261, -- gusting-winds
		38358, -- tidal-surge
		},
		["Morogrim Tidewalker"] = {
		order = 5, ejid = nil,
		38049, -- watery grave
		},
		["Lady Vashj"] = {
		order = 6, ejid = nil,
		38280, -- static charge
		},
		["Trash"] = {
		order = 7, ejid = nil,
		39042, -- Rampant Infection
		39044, -- serpenthrine parasite
		},
	},
	[100550] = {-- Tempest Keep, The Eye
		{ id = 100550, name = "Tempest Keep, The Eye", raid = true },
		["Al'ar"] = {
		order = 1, ejid = nil,
		35410, --melt-armor
		35383, --flame-patch
		},
		["Void Reaver"] = {
		order = 2, ejid = nil,
		},
		["High Astromancer Solarian"] = {
		order = 3, ejid = nil,
		42783, -- "Wrath of the Astromancer
		},
		["Kael'thas Sunstrider"] = {
		order = 4, ejid = nil,
		37027, -- Remote Toy
		36798, -- Mind Control
		},
		["Trash"] = {
		order = 5, ejid = nil,
		35318, -- Sha Blade
		37120, -- Fragmentation Bomb
		37118, -- Shell Shock
		},
	},
	[100534] = { -- Hyjal Summit
		{ id = 100534, name = "The Battle for Mount Hyjal ", raid = true },
		["Rage Winterchill"] = {
		order = 1, ejid = nil,
		31249, -- icebolt
		},
		["Anetheron"] = {
		order = 2, ejid = nil,
		31306, -- carrion swarm
		31298, -- sleep
		},
		["Azgalor"] = {
		order = 3, ejid = nil,
		31347, -- doom
		31344, --howl of azgalor
		31341, -- unquenchable flames
		},
		["Archimonde"] = {
		order = 4, ejid = nil,
		31944, -- Doomfire
		31972, -- Grip of the Legion
		},
	},
	[100568] = { -- Zul'Aman
		{ id = 100568, name = "Zul'Aman", raid = true },
		["Nalorakk"] = {
		order = 1, ejid = nil,
		44955, -- mangle
		},
		["Akil'zon"] = {
		order = 2, ejid = nil,
		43657, -- electrical storm
		43622, -- static distruption
		},
		["Jan'alai"] = {
		order = 3, ejid = nil,
		43299, -- Flame Buffet
		},
		["Halazzi"] = {
		order = 4, ejid = nil,
		43303, -- Flame Shock
		},
		["Hex Lord Malacrass"] = {
		order = 5, ejid = nil,
		43613, -- Cold Stare
		43501, -- Siphon soul
		},
		["Zul'jin"] = {
		order = 6, ejid = nil,
		43093, -- Girievous  Throw
		43095, -- Greeping Paralyze
		43150, -- Claw Rage
		},
	},
	[100564] = {
		{ id = 100564, name = "Black Temple", raid = true },
		["High Warlord Naj'entus"] = {
		order = 1, ejid = nil,
		39837, --Impaling Spine
		},
		["Supremus"] = {
		order = 2, ejid = nil,
		40253, -- molten-flame
		},
		["Shade of Akama"] = {
		order = 3, ejid = nil,
		41179, -- debilitating strike
		41978, -- veneno-debilitador
		42023, -- lluvia-de-fuego
		},
		["Teron Gorefiend"] = {
		order = 4, ejid = nil,
		40239, --Incinerate
		40251, --Shadow of death
		},
		["Gurtogg Bloodboil"] = {
		order = 5, ejid = nil,
		40604, --FelRage
		40481, --Acidic Wound
		40508, --Fel-Acid Breath
		42005, --bloodboil
		},
		["Reliquary of Souls"] = {
		order = 6, ejid = nil,
		41303, --soulDrain
		41410, --Deaden
		41376, --Spite
		},
		["Mother Shahraz"] = {
		order = 7, ejid = nil,
		40860, --Vile Beam
		41001, --Attraction
		},
		["The Illidari Council"] = {
		order = 8, ejid = nil,
		41485, --Deadly Poison
		41472, --Divine Wrath
		},
		["Illidan Stormrage"] = {
		order = 9, ejid = nil,
		41914, --Parasitic Shadowfiend
		41917,
		40585, --Dark Barrage
		41032, --Shear
		40932, --Agonizing Flames
		},
		["Trash"] = {
		order = 10, ejid = nil,
		34654, --Blind
		39674, --Banish
		41150, --Fear
		41168, --Sonic Strike
		},
	},
	[100580] = {
		{ id = 100580, name = "Sunwell Plateau", raid = true },
		["Kalecgos"] = {
		order = 1, ejid = nil,
		45032, -- Curse of Boundless Agony
		45018, -- Arcane Buffet
		23410, -- wild-magic
		},
		["Brutallus"] = {
		order = 2, ejid = nil,
		46394, -- Burn
		45185, -- Stomp
		45150, -- Meteor Slash
		},
		["Felmyst"] = {
		order = 3, ejid = nil,
		45855, -- Gas Nova
		45662, -- Encapsulate
		45402, -- Demonic Vapor
		45717, -- Fog of Corruption
		},
		["Eredar Twins"] = {
		order = 4, ejid = nil,
		45230, -- Pyrogenics
		45256, -- Confounding Blow
		45333, -- Conflagration
		46771, -- Flame Sear
		45270, -- Shadowfury
		45347, -- Dark Touched
		45348, -- Flame Touched
		},
		["M'uru"] = {
		order = 5, ejid = nil,
		45996, -- Darkness
		},
		["Kil'Jaeden"] = {
		order = 6, ejid = nil,
		45442, -- Soul Flay
		45641, -- Fire Bloom
		45885, -- Shadow Spike
		45737, -- Flame Dart
		},
		["Trash"] = {
		order = 7, ejid = nil,
		46561, -- Fear
		46562, -- Mind Flay
		46266, -- Burn Mana
		46557, -- Slaying Shot
		46560, -- Shadow Word:Pain
		46543, -- Ignite Mana
		46427, -- Domination
		},
	},
}
