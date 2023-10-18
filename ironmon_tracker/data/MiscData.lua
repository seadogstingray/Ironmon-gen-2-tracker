MiscData = {}

MiscData.TableData = {
	growth = { 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 3, 4, 2, 2, 3, 4, 3, 4, 2, 2, 3, 4, 3, 4 },
	attack = { 2, 2, 3, 4, 3, 4, 1, 1, 1, 1, 1, 1, 3, 4, 2, 2, 4, 3, 3, 4, 2, 2, 4, 3 },
	effort = { 3, 4, 2, 2, 4, 3, 3, 4, 2, 2, 4, 3, 1, 1, 1, 1, 1, 1, 4, 3, 4, 3, 2, 2 },
	misc   = { 4, 3, 4, 3, 2, 2, 4, 3, 4, 3, 2, 2, 4, 3, 4, 3, 2, 2, 1, 1, 1, 1, 1, 1 },
}

MiscData.BagPocket = {
	PC = 0,
	Items = 1,
	KeyItems = 2,
	Pokeballs = 3,
	TMHM = 4,
	Berries = 5,
}

MiscData.HealingType = {
	Constant = 0,
	Percentage = 1,
}

-- Currently unused data
MiscData.StatusType = {
	None = 0,
	Sleep = 1,
	Poison = 2,
	Burn = 3,
	Freeze = 4,
	Paralyze = 5,
	Toxic=6,

}

MiscData.StatusCodeMap = {
	[MiscData.StatusType.None] = "",
	[MiscData.StatusType.Burn] = "BRN",
	[MiscData.StatusType.Freeze] = "FRZ",
	[MiscData.StatusType.Paralyze] = "PAR",
	[MiscData.StatusType.Poison] = "PSN",

	[MiscData.StatusType.Sleep] = "SLP",

	[MiscData.StatusType.Toxic] = "Toxic",

}

-- Currently unused data
MiscData.Natures = {
	"Hardy", "Lonely", "Brave", "Adamant", "Naughty",
	"Bold", "Docile", "Relaxed", "Impish", "Lax",
	"Timid", "Hasty", "Serious", "Jolly", "Naive",
	"Modest", "Mild", "Quiet", "Bashful", "Rash",
	"Calm", "Gentle", "Sassy", "Careful", "Quirky"
}

MiscData.Items = {
	"MASTER BALL","ULTRA BALL","GREAT BALL","POKé BALL","TOWN MAP","BICYCLE","?????","SAFARI BALL","POKéDEX","MOON STONE",
	"ANTIDOTE","BURN HEAL","ICE HEAL","AWAKENING","PARLYZ HEAL","FULL RESTORE","MAX POTION","HYPER POTION","SUPER POTION","POTION",
	"BOULDERBADGE","CASCADEBADGE","THUNDERBADGE","RAINBOWBADGE","SOULBADGE","MARSHBADGE","VOLCANOBADGE","EARTHBADGE","ESCAPE ROPE",
	"REPEL","OLD AMBER","FIRE STONE","THUNDERSTONE","WATER STONE","HP UP","PROTEIN","IRON","CARBOS","CALCIUM","RARE CANDY","DOME FOSSIL",
	"HELIX FOSSIL","SECRET KEY","?????","BIKE VOUCHER","X ACCURACY","LEAF STONE","CARD KEY","NUGGET","PP UP (fake)","POKé DOLL","FULL HEAL",
	"REVIVE","MAX REVIVE","GUARD SPEC.","SUPER REPEL","MAX REPEL","DIRE HIT","COIN","FRESH WATER","SODA POP","LEMONADE","S.S.TICKET","GOLD TEETH",
	"X ATTACK","X DEFEND","X SPEED","X SPECIAL","COIN CASE","OAK‘s PARCEL",	"ITEMFINDER","SILPH SCOPE","POKé FLUTE","LIFT KEY","EXP.ALL",
	"OLD ROD","GOOD ROD","SUPER ROD","PP UP (real)","ETHER","MAX ETHER","ELIXER","MAX ELIXER","B2F","B1F","1F","2F","3F","4F","5F","6F","7F","8F","9F","10F","11F","B4F",
}

MiscData.HealingItems = {
	[20] = {
		id = 20,
		name = "Potion",
		amount = 20,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[16] = {
		id = 16,
		name = "Full Restore",
		amount = 100,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Items,
	},
	[17] = {
		id = 20,
		name = "Max Potion",
		amount = 100,
		type = MiscData.HealingType.Percentage,
		pocket = MiscData.BagPocket.Items,
	},
	[18] = {
		id = 18,
		name = "Hyper Potion",
		amount = 200,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[19] = {
		id = 19,
		name = "Super Potion",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[60] = {
		id = 60,
		name = "Fresh Water",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[61] = {
		id = 61,
		name = "Soda Pop",
		amount = 60,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[62] = {
		id = 62,
		name = "Lemonade",
		amount = 80,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items,
	},
	[72] = {
		id = 72,
		name = "Moomoo Milk",
		amount = 100,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items
	},
	[114] = {
		id = 114,
		name = "Rage Candy Bar",
		amount = 20,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items
	},
	[121] = {
		id = 121,
		name = "Energy Powder",
		amount = 50,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items
	},
	[122] = {
		id = 122,
		name = "Energy Root",
		amount = 200,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items
	},
	[139] = {
		id = 139,
		name = "Berry Juice",
		amount = 20,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items
	},
	[173] = {
		id = 173,
		name = "Berry",
		amount = 10,
		type = MiscData.HealingType.Constant,
		pocket = MiscData.BagPocket.Items
	}
}

MiscData.StatusItems = {
	[11] = {
		id = 11,
		name = "Antidote",
		type = MiscData.StatusType.Poison,
		pocket = MiscData.BagPocket.Items,
	},
	[12] = {
		id = 12,
		name = "Burn Heal",
		type = MiscData.StatusType.Burn,
		pocket = MiscData.BagPocket.Items,
	},
	[13] = {
		id = 13,
		name = "Ice Heal",
		type = MiscData.StatusType.Freeze,
		pocket = MiscData.BagPocket.Items,
	},
	[14] = {
		id = 14,
		name = "Awakening",
		type = MiscData.StatusType.Sleep,
		pocket = MiscData.BagPocket.Items,
	},
	[15] = {
		id = 15,
		name = "Parlyz Heal",
		type = MiscData.StatusType.Paralyze,
		pocket = MiscData.BagPocket.Items,
	},
	[16] = {
		id = 16,
		name = "Full Restore",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	},
	[52] = {
		id = 52,
		name = "Full Heal",
		type = MiscData.StatusType.All,
		pocket = MiscData.BagPocket.Items,
	}
}

MiscData.EvolutionStones = {

	[10] = {
		id = 10,
		name = "Moon Stone",
		evolutions = {PokemonData.Evolutions.MOON, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[32] = {
		id = 32,
		name = "Fire Stone",
		evolutions = {PokemonData.Evolutions.FIRE, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[33] = {
		id = 33,
		name = "Thunder Stone",
		evolutions = {PokemonData.Evolutions.THUNDER, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[34] = {
		id = 34,
		name = "Water Stone",
		evolutions = {PokemonData.Evolutions.WATER, PokemonData.Evolutions.STONES},
		pocket = MiscData.BagPocket.Items,
	},
	[47] = {
		id = 47,
		name = "Leaf Stone",
		evolutions = {PokemonData.Evolutions.LEAF, PokemonData.Evolutions.LEAF_SUN},
		pocket = MiscData.BagPocket.Items,
	},
}


MiscData.InternalID={
	[0x1] = "RHYDON" ,
	[0x2] = "KANGASKHAN" ,
	[0x3] = "NIDORAN F" ,
	[0x4] = "CLEFAIRY" ,
	[0x5] = "SPEAROW" ,
	[0x6] = "VOLTORB" ,
	[0x7] = "NIDOKING" ,
	[0x8] = "SLOWBRO" ,
	[0x9] = "IVYSAUR" ,
	[0xa] = "EXEGGUTOR" ,
	[0xb] = "LICKITUNG" ,
	[0xc] = "EXEGGCUTE" ,
	[0xd] = "GRIMER" ,
	[0xe] = "GENGAR" ,
	[0xf] = "NIDORAN" ,
	[0x10] = "NIDOQUEEN" ,
	[0x11] = "CUBONE" ,
	[0x12] = "RHYHORN" ,
	[0x13] = "LAPRAS" ,
	[0x14] = "ARCANINE" ,
	[0x15] = "MEW" ,
	[0x16] = "GYARADOS" ,
	[0x17] = "SHELLDER" ,
	[0x18] = "TENTACOOL" ,
	[0x19] = "GASTLY" ,
	[0x1a] = "SCYTHER" ,
	[0x1b] = "STARYU" ,
	[0x1c] = "BLASTOISE" ,
	[0x1d] = "PINSIR" ,
	[0x1e] = "TANGELA" ,
	[0x1f] = "MISSINGNO." ,
	[0x20] = "MISSINGNO." ,
	[0x21] = "GROWLITHE" ,
	[0x22] = "ONIX" ,
	[0x23] = "FEAROW" ,
	[0x24] = "PIDGEY" ,
	[0x25] = "SLOWPOKE" ,
	[0x26] = "KADABRA" ,
	[0x27] = "GRAVELER" ,
	[0x28] = "CHANSEY" ,
	[0x29] = "MACHOKE" ,
	[0x2a] = "MR.MIME" ,
	[0x2b] = "HITMONLEE" ,
	[0x2c] = "HITMONCHAN" ,
	[0x2d] = "ARBOK" ,
	[0x2e] = "PARASECT" ,
	[0x2f] = "PSYDUCK" ,
	[0x30] = "DROWZEE" ,
	[0x31] = "GOLEM" ,
	[0x32] = "MISSINGNO." ,
	[0x33] = "MAGMAR" ,
	[0x34] = "MISSINGNO." ,
	[0x35] = "ELECTABUZZ" ,
	[0x36] = "MAGNETON" ,
	[0x37] = "KOFFING" ,
	[0x38] = "MISSINGNO." ,
	[0x39] = "MANKEY" ,
	[0x3a] = "SEEL" ,
	[0x3b] = "DIGLETT" ,
	[0x3c] = "TAUROS" ,
	[0x3d] = "MISSINGNO." ,
	[0x3e] = "MISSINGNO." ,
	[0x3f] = "MISSINGNO." ,
	[0x40] = "FARFETCH'D" ,
	[0x41] = "VENONAT" ,
	[0x42] = "DRAGONITE" ,
	[0x43] = "MISSINGNO." ,
	[0x44] = "MISSINGNO." ,
	[0x45] = "MISSINGNO." ,
	[0x46] = "DODUO" ,
	[0x47] = "POLIWAG" ,
	[0x48] = "JYNX" ,
	[0x49] = "MOLTRES" ,
	[0x4a] = "ARTICUNO" ,
	[0x4b] = "ZAPDOS" ,
	[0x4c] = "DITTO" ,
	[0x4d] = "MEOWTH" ,
	[0x4e] = "KRABBY" ,
	[0x4f] = "MISSINGNO." ,
	[0x50] = "MISSINGNO." ,
	[0x51] = "MISSINGNO." ,
	[0x52] = "VULPIX" ,
	[0x53] = "NINETALES" ,
	[0x54] = "PIKACHU" ,
	[0x55] = "RAICHU" ,
	[0x56] = "MISSINGNO." ,
	[0x57] = "MISSINGNO." ,
	[0x58] = "DRATINI" ,
	[0x59] = "DRAGONAIR" ,
	[0x5a] = "KABUTO" ,
	[0x5b] = "KABUTOPS" ,
	[0x5c] = "HORSEA" ,
	[0x5d] = "SEADRA" ,
	[0x5e] = "MISSINGNO." ,
	[0x5f] = "MISSINGNO." ,
	[0x60] = "SANDSHREW" ,
	[0x61] = "SANDSLASH" ,
	[0x62] = "OMANYTE" ,
	[0x63] = "OMASTAR" ,
	[0x64] = "JIGGLYPUFF" ,
	[0x65] = "WIGGLYTUFF" ,
	[0x66] = "EEVEE" ,
	[0x67] = "FLAREON" ,
	[0x68] = "JOLTEON" ,
	[0x69] = "VAPOREON" ,
	[0x6a] = "MACHOP" ,
	[0x6b] = "ZUBAT" ,
	[0x6c] = "EKANS" ,
	[0x6d] = "PARAS" ,
	[0x6e] = "POLIWHIRL" ,
	[0x6f] = "POLIWRATH" ,
	[0x70] = "WEEDLE" ,
	[0x71] = "KAKUNA" ,
	[0x72] = "BEEDRILL" ,
	[0x73] = "MISSINGNO." ,
	[0x74] = "DODRIO" ,
	[0x75] = "PRIMEAPE" ,
	[0x76] = "DUGTRIO" ,
	[0x77] = "VENOMOTH" ,
	[0x78] = "DEWGONG" ,
	[0x79] = "MISSINGNO." ,
	[0x7a] = "MISSINGNO." ,
	[0x7b] = "CATERPIE" ,
	[0x7c] = "METAPOD" ,
	[0x7d] = "BUTTERFREE" ,
	[0x7e] = "MACHAMP" ,
	[0x7f] = "MISSINGNO." ,
	[0x80] = "GOLDUCK" ,
	[0x81] = "HYPNO" ,
	[0x82] = "GOLBAT" ,
	[0x83] = "MEWTWO" ,
	[0x84] = "SNORLAX" ,
	[0x85] = "MAGIKARP" ,
	[0x86] = "MISSINGNO." ,
	[0x87] = "MISSINGNO." ,
	[0x88] = "MUK" ,
	[0x89] = "MISSINGNO." ,
	[0x8a] = "KINGLER" ,
	[0x8b] = "CLOYSTER" ,
	[0x8c] = "MISSINGNO." ,
	[0x8d] = "ELECTRODE" ,
	[0x8e] = "CLEFABLE" ,
	[0x8f] = "WEEZING" ,
	[0x90] = "PERSIAN" ,
	[0x91] = "MAROWAK" ,
	[0x92] = "MISSINGNO." ,
	[0x93] = "HAUNTER" ,
	[0x94] = "ABRA" ,
	[0x95] = "ALAKAZAM" ,
	[0x96] = "PIDGEOTTO" ,
	[0x97] = "PIDGEOT" ,
	[0x98] = "STARMIE" ,
	[0x99] = "BULBASAUR" ,
	[0x9a] = "VENUSAUR" ,
	[0x9b] = "TENTACRUEL" ,
	[0x9c] = "MISSINGNO." ,
	[0x9d] = "GOLDEEN" ,
	[0x9e] = "SEAKING" ,
	[0x9f] = "MISSINGNO." ,
	[0xa0] = "MISSINGNO." ,
	[0xa1] = "MISSINGNO." ,
	[0xa2] = "MISSINGNO." ,
	[0xa3] = "PONYTA" ,
	[0xa4] = "RAPIDASH" ,
	[0xa5] = "RATTATA" ,
	[0xa6] = "RATICATE" ,
	[0xa7] = "NIDORINO" ,
	[0xa8] = "NIDORINA" ,
	[0xa9] = "GEODUDE" ,
	[0xaa] = "PORYGON" ,
	[0xab] = "AERODACTYL" ,
	[0xac] = "MISSINGNO." ,
	[0xad] = "MAGNEMITE" ,
	[0xae] = "MISSINGNO." ,
	[0xaf] = "MISSINGNO." ,
	[0xb0] = "CHARMANDER" ,
	[0xb1] = "SQUIRTLE" ,
	[0xb2] = "CHARMELEON" ,
	[0xb3] = "WARTORTLE" ,
	[0xb4] = "CHARIZARD" ,
	[0xb5] = "MISSINGNO." ,
	[0xb6] = "MISSINGNO." ,
	[0xb7] = "MISSINGNO." ,
	[0xb8] = "MISSINGNO." ,
	[0xb9] = "ODDISH" ,
	[0xba] = "GLOOM" ,
	[0xbb] = "VILEPLUME" ,
	[0xbc] = "BELLSPROUT" ,
	[0xbd] = "WEEPINBELL" ,
	[0xbe] = "VICTREEBEL" ,



}