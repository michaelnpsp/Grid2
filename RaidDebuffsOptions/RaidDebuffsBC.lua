-- Wow TBC raid debuffs
-- Key&id = InstanceMapID (select(8,GetInstanceInfo())) + 100000
if not Grid2.isTBC then return end

local RDDB= Grid2Options:GetRaidDebuffsTable()

RDDB["The Burning Crusade"] = {
	[100532] = {
		{ id = 100532, name = "Karazhan", raid = true },
		["-"] = {
		37066, -- Garrote
		29522, -- Holy Fire
		29511, -- Repentance
		30753, -- Red Riding Hood
		30115, -- Sacrifice
		30843, -- Enfeeble
		},
	},
	[100568] = {
		{ id = 100568, name = "Zul'Aman", raid = true },
		["-"] = {
		43657, -- Electrical Storm
		43622, -- Static Disruption
		43299, -- Flame Buffet
		43303, -- Flame Shock
		43613, -- Cold State
		43501, -- Siphon Soul
		43093, -- Girievous Throw
		43095, -- Greeping Paralysis
		43150, -- Claw Range
		},
	},
	[100548] = {
		{ id = 100548, name = "Serpentshrine Cavern", raid = true },
		["-"] = {
		39042, -- Rampant Infection
		39044, -- Seprentshrine Parasite
		38235, -- Water Tomb
		38246, -- Vile Sludge
		37850, -- Watery Grave
		37676, -- Insidious Whisper
		37641, -- Whirlwind
		37749, -- Consuming Madness
		38280, -- Static Charge
		},
	},
	[100534] = {
		{ id = 100534, name = "The Battle for Mount Hyjal", raid = true },
		["-"] = {
		31249, -- Icebolt
		31306, -- Carrion Swarm
		31347, -- Doom
		31341, -- Unquenchable Flames
		31344, -- Howl of Azgalor
		31944, -- Doomfire
		31972, -- Grip of the Legion
		},
	},
	[100564] = {
		{ id = 100564, name = "Black Temple", raid = true },
		["-"] = {
		34654, -- Blind
		39674, -- Banish
		41150, -- Fear
		41168, -- Sonic Strike
		39837, -- Impaling Spine
		40239, -- Incinerate
		40251, -- Shadow of Death
		40604, -- Fel Rage
		40481, -- Acidic Wound
		40508, -- Fel-Acid Breath
		42005, -- Bloodboil
		41303, -- Sould Drain
		41410, -- Deaden
		41376, -- Spite
		40860, -- Vile Beam
		41001, -- Fatal Attraction
		41485, -- Deadly Poison
		41472, -- Divine Wrath
		41914, -- Parasitic Shadowfiend
		40585, -- Dark Barrage
		40932, -- Agonizing Flames
		},
	},
	[100580] = {
		{ id = 100580, name = "Sunwell Plateau", raid = true },
		["-"] = {
		46561, -- Fear
		46562, -- Mind Flay
		46266, -- Burn Mana
		46557, -- Slaying Shot
		46560, -- Shadow Word:Pain
		46543, -- Ignite Mana
		46427, -- Domination
		45032, -- Curse of Boundless Agony
		45018, -- Arcane Buffet
		45150, -- Meteor Slash
		45855, -- Gas Nova
		45662, -- Encapsulate
		45402, -- Demonic Vapor
		45717, -- Fog of Corruption
		45256, -- Confounding Blow
		45333, -- Conflagration
		46771, -- Flame Sear
		45270, -- Shadowfury
		45347, -- Dark Touched
		45348, -- Flame Touched
		45996, -- Darkness
		45442, -- Soul Flay
		45641, -- Fire Bloom
		45885, -- Shadow Spike
		45737, -- Flame Dart
		},
	},
}
