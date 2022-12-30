-- A collection of tools for viewing a Randomized Pokémon game log
RandomizerLog = {}

RandomizerLog.Patterns = {
	RandomizerVersion = "Randomizer Version:%s*([%d%.]+)%s*$", -- Note: log file line 1 does NOT start with "Rando..."
	RandomizerSeed = "^Random Seed:%s*(%d+)%s*$",
	RandomizerSettings = "^Settings String:%s*(.+)%s*$",
	RandomizerGame = "^Randomization of%s*(.+)%s+completed",
	PokemonName = "([%u%d%.]* ?[%u%d%.'%-♀♂]+)",
	-- MoveName = "([%u%d%.'%-]+)", -- might figure out later
	-- ItemName = "([%u%d%.'%-]+)", -- might figure out later
	getSectorHeaderPattern = function(sectorName)
		return "^%-?%-?" .. (sectorName or "") .. ":?%-?%-?$"
	end,
}

-- Each Sector has Pattern(s) to match on, and the Sector Start Header LineNumber
RandomizerLog.Sectors = {
	-- First three lines: Randomizer Version, Random Seed, Settings String

	Evolutions = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Randomized Evolutions"),
		-- Matches: pokemon, evos
		PokemonEvosPattern = "^" .. RandomizerLog.Patterns.PokemonName .. "%s*%->%s*(.*)",
	},
	BaseStatsItems = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pokemon Base Stats & Types"),
		-- Matches: pokemon, hp, atk, def, spatk, spdef, spd, helditems
		PokemonBSTPattern = "^.*|" .. RandomizerLog.Patterns.PokemonName .. "%s*|.*|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|%s*(%d*)|.*|.*|(.*)",
	},
	MoveSets = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pokemon Movesets"),
		-- Matches: pokemon
		NextMonPattern = "^%d+%s" .. RandomizerLog.Patterns.PokemonName .. "%s*%->",
		-- Matches: level, movename
		MovePattern = "^Level%s(%d+)%s?%s?:%s(.*)",
	},
	TMMoves = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("TM Moves"),
		-- Matches: tmNumber, movename
		TMPattern = "^TM(%d+)%s(.*)",
	},
	-- TODO: If TMs aren't randomized, then we don't store the original TM data, we probably need to do that
	TMCompatibility = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("TM Compatibility"),
		-- Matches: pokemon
		NextMonPattern = "^[%s%d]+%s" .. RandomizerLog.Patterns.PokemonName .. "%s*|(.*)",
		-- Matches: tmNumber
		TMPattern = "TM(%d+)",
	},
	Trainers = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Trainers Pokemon"),
		-- Matches: trainer_num, trainername, party
		NextTrainerPattern = "^#(%d+)%s%((.+)%s*=>.*%s%-%s(.*)",
		-- Matches: partypokemon (pokemon name with held item and level info)
		PartyPattern = "([^,]+)",
		-- Matches: pokemon, helditem[optional], level
		PartyPokemonPattern = RandomizerLog.Patterns.PokemonName .. "@?(.-)%sLv(%d+)",
	},
	-- Currently unused
	PickupItems = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pickup Items"),
		LevelPattern = "",
		PercentPattern = "",
		ItemsPattern = "",
	},
	GameInfo = {
		-- :(
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-%-"),
	},
}

-- A table of parsed data from the log file: Settings, Pokemon, TMs, Trainers, PickupItems
RandomizerLog.Data = {}

RandomizerLog.GymTMs = {
	[1] = { -- Game #: Ruby / Sapphire
		{ leader = "Roxanne", number = 39, },
		{ leader = "Brawly", number = 8, },
		{ leader = "Wattson", number = 34, },
		{ leader = "Flannery", number = 50, },
		{ leader = "Norman", number = 42, },
		{ leader = "Winona", number = 40, },
		{ leader = "Tate & Liza", number = 4, },
		{ leader = "Wallace", number = 3, },
	},
	[2] = { -- Game #: Emerald
		{ leader = "Roxanne", number = 39, },
		{ leader = "Brawly", number = 8, },
		{ leader = "Wattson", number = 34, },
		{ leader = "Flannery", number = 50, },
		{ leader = "Norman", number = 42, },
		{ leader = "Winona", number = 40, },
		{ leader = "Tate & Liza", number = 4, },
		{ leader = "Juan", number = 3, },
	},
	[3] = { -- Game #: Fire Red / Leaf Green
		{ leader = "Brock", number = 39, },
		{ leader = "Misty", number = 3, },
		{ leader = "Lt. Surge", number = 34, },
		{ leader = "Erika", number = 19, },
		{ leader = "Koga", number = 6, },
		{ leader = "Sabrina", number = 4, },
		{ leader = "Blaine", number = 38, },
		{ leader = "Giovanni", number = 26, },
	},
}

-- Parses the log file at 'filepath' into the data object RandomizerLog.Data
function RandomizerLog.parseLog(filepath)
	local logLines = FileManager.readLinesFromFile(filepath)
	if #logLines == 0 then
		return false
	end

	RandomizerLog.resetData()
	RandomizerLog.locateSectorLineStarts(logLines)

	RandomizerLog.setupMappings()
	RandomizerLog.parseRandomizerSettings(logLines)
	RandomizerLog.parseEvolutions(logLines)
	RandomizerLog.parseBaseStatsItems(logLines)
	RandomizerLog.parseMoveSets(logLines)
	RandomizerLog.parseTMMoves(logLines)
	RandomizerLog.parseTMCompatibility(logLines)
	RandomizerLog.parseTrainers(logLines)
	RandomizerLog.parsePickupItems(logLines)
	RandomizerLog.parseRandomizerGame(logLines)
	RandomizerLog.removeMappings()

	return true
end

-- Returns sanitized input from the log file to be compatible with the Tracker. Trims spacing.
function RandomizerLog.formatInput(str)
	if str == nil then return nil end
	str = str:gsub("♀", " F")
	str = str:gsub("♂", " M")
	str = str:gsub("’", "'")
	str = str:gsub("é", Constants.getC("é"))
	str = str:gsub("%[PK%]%[MN%]", "PKMN")
	str = str:match("^%s*(.*)%s*$") or str -- remove leading/trailing spaces
	return str:lower()
end

-- Clears out the parsed data and initializes it for each valid PokemonId
function RandomizerLog.resetData()
	RandomizerLog.Data = {
		Settings = {},
		Pokemon = {},
		TMs = {},
		Trainers = {},
		PickupItems = {}, -- Currently unused
	}

	for id = 1, PokemonData.totalPokemon, 1 do
		if id <= 251 or id >= 277 then -- celebi / treecko
			RandomizerLog.Data.Pokemon[id] = {}
		end
	end
end

-- Locates the starting line number of each sector
function RandomizerLog.locateSectorLineStarts(logLines)
	if logLines == nil or #logLines == 0 then
		return
	end

	for i, line in ipairs(logLines) do
		-- If the sector hasn't been found yet, and its this line
		for _, sector in pairs(RandomizerLog.Sectors) do
			if sector.LineNumber == nil and string.find(line, sector.HeaderPattern) ~= nil then
				sector.LineNumber = i + 1 -- +1 to skip the header itself
				break -- and continue looking for other sectors
			end
		end
	end
end

function RandomizerLog.parseRandomizerSettings(logLines)
	if #logLines < 3 then return end
	local version = string.match(logLines[1], RandomizerLog.Patterns.RandomizerVersion)
	local randomSeed = string.match(logLines[2], RandomizerLog.Patterns.RandomizerSeed)
	local settingsString = string.match(logLines[3], RandomizerLog.Patterns.RandomizerSettings)
	RandomizerLog.Data.Settings.Version = version
	RandomizerLog.Data.Settings.RandomSeed = randomSeed
	RandomizerLog.Data.Settings.SettingsString = settingsString
end

-- This sector is near the end of the file
function RandomizerLog.parseRandomizerGame(logLines)
	if RandomizerLog.Sectors.GameInfo.LineNumber == nil then
		return
	end

	local game = string.match(logLines[RandomizerLog.Sectors.GameInfo.LineNumber] or "", RandomizerLog.Patterns.RandomizerGame)
	RandomizerLog.Data.Settings.Game = game
end

function RandomizerLog.parseEvolutions(logLines)
	if RandomizerLog.Sectors.Evolutions.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Evolutions.LineNumber
	while index <= #logLines do
		local pokemon, evos = string.match(logLines[index] or "", RandomizerLog.Sectors.Evolutions.PokemonEvosPattern)
		pokemon = RandomizerLog.formatInput(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or evos == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil then
			return
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		RandomizerLog.Data.Pokemon[pokemonId].Evolutions = {}

		for evo in string.gmatch(evos, RandomizerLog.Patterns.PokemonName) do
			evo = RandomizerLog.formatInput(evo)
			if RandomizerLog.PokemonNameToIdMap[evo] ~= nil then
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].Evolutions, RandomizerLog.PokemonNameToIdMap[evo])
			end
		end

		index = index + 1
	end
end

function RandomizerLog.parseBaseStatsItems(logLines)
	if RandomizerLog.Sectors.BaseStatsItems.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.BaseStatsItems.LineNumber + 1 -- remove the first line to skip the table header
	while index <= #logLines do
		local pokemon, hp, atk, def, spa, spd, spe, helditems = string.match(logLines[index] or "", RandomizerLog.Sectors.BaseStatsItems.PokemonBSTPattern)
		pokemon = RandomizerLog.formatInput(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or spe == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil then
			return
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		local pokemonData = RandomizerLog.Data.Pokemon[pokemonId]
		if pokemonData ~= nil then
			pokemonData.BaseStats = {
				hp = tonumber(hp) or 0,
				atk = tonumber(atk) or 0,
				def = tonumber(def) or 0,
				spa = tonumber(spa) or 0,
				spd = tonumber(spd) or 0,
				spe = tonumber(spe) or 0,
			}
			if helditems ~= nil and helditems ~= "" then
				pokemonData.BaseStats.helditems = RandomizerLog.formatInput(helditems)
			end
		end
		index = index + 1
	end
end

function RandomizerLog.parseMoveSets(logLines)
	if RandomizerLog.Sectors.MoveSets.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.MoveSets.LineNumber
	while index <= #logLines do
		local pokemon = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.NextMonPattern)
		pokemon = RandomizerLog.formatInput(pokemon)

		-- Search for the next Pokémon's name, or the end of sector
		-- I might fix this whole mess later when I'm awake
		while pokemon == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil do
			if string.find(logLines[index] or "", "^%-%-") ~= nil or index + 1 > #logLines then
				return
			end
			index = index + 1
			pokemon = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.NextMonPattern)
			pokemon = RandomizerLog.formatInput(pokemon)
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		local pokemonData = RandomizerLog.Data.Pokemon[pokemonId]
		if pokemonData ~= nil then
			pokemonData.MoveSet = {}
			 -- First six lines are redundant Base Sets (also don't trust these will exist), and skip current line
			 index = index + 7

			-- Search for each listed level-up move
			local level, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.MovePattern)
			while level ~= nil and movename ~= nil do
				local nextMove = {
					level = tonumber(RandomizerLog.formatInput(level)) or 0,
					moveId = RandomizerLog.MoveNameToIdMap[RandomizerLog.formatInput(movename)]
				}
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].MoveSet, nextMove)

				index = index + 1
				if index > #logLines then
					return
				end
				level, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.MovePattern)
			end
		else
			index = index + 1
		end
	end
end

function RandomizerLog.parseTMMoves(logLines)
	if RandomizerLog.Sectors.TMMoves.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.TMMoves.LineNumber
	while index <= #logLines do
		local tmNumber, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.TMMoves.TMPattern)
		tmNumber = tonumber(RandomizerLog.formatInput(tmNumber) or "") -- nil if not a number
		movename = RandomizerLog.formatInput(movename)

		-- If nothing matches, end of sector
		if tmNumber == nil or movename == nil or RandomizerLog.MoveNameToIdMap[movename] == nil then
			return
		end

		local moveId = RandomizerLog.MoveNameToIdMap[movename]
		RandomizerLog.Data.TMs[tmNumber] = moveId

		index = index + 1
	end
end

function RandomizerLog.parseTMCompatibility(logLines)
	if RandomizerLog.Sectors.TMCompatibility.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.TMCompatibility.LineNumber
	while index <= #logLines do
		local pokemon, tms = string.match(logLines[index] or "", RandomizerLog.Sectors.TMCompatibility.NextMonPattern)
		pokemon = RandomizerLog.formatInput(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or tms == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil then
			return
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		RandomizerLog.Data.Pokemon[pokemonId].TMMoves = {}

		for tmNumber in string.gmatch(tms, RandomizerLog.Sectors.TMCompatibility.TMPattern) do
			tmNumber = tonumber(RandomizerLog.formatInput(tmNumber) or "") -- nil if not a number
			if tmNumber ~= nil and RandomizerLog.Data.TMs[tmNumber] ~= nil then
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].TMMoves, tmNumber)
			end
		end
		index = index + 1
	end
end

function RandomizerLog.parseTrainers(logLines)
	if RandomizerLog.Sectors.Trainers.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Trainers.LineNumber
	while index <= #logLines do
		local trainer_num, trainername, party = string.match(logLines[index] or "", RandomizerLog.Sectors.Trainers.NextTrainerPattern)
		trainer_num = tonumber(RandomizerLog.formatInput(trainer_num) or "") -- nil if not a number
		trainername = RandomizerLog.formatInput(trainername)

		-- If nothing matches, end of sector
		if trainer_num == nil or trainername == nil or party == nil then
			return
		end

		RandomizerLog.Data.Trainers[trainer_num] = {
			name = trainername, -- likely in the form of TRAINER CLASS + TRAINER NAME
			party = {},
		}

		for partypokemon in string.gmatch(party, RandomizerLog.Sectors.Trainers.PartyPattern) do
			local pokemon, helditem, level = string.match(partypokemon, RandomizerLog.Sectors.Trainers.PartyPokemonPattern)
			pokemon = RandomizerLog.formatInput(pokemon)
			helditem = RandomizerLog.formatInput(helditem)
			level = tonumber(RandomizerLog.formatInput(level) or "") or 0 -- nil if not a number
			if helditem == "" then
				helditem = nil -- don't waste storage if empty
			end

			if pokemon ~= nil and RandomizerLog.PokemonNameToIdMap[pokemon] ~= nil then
				local partyPokemon = {
					pokemonID = RandomizerLog.PokemonNameToIdMap[pokemon],
					helditem = helditem,
					level = level,
				}
				table.insert(RandomizerLog.Data.Trainers[trainer_num].party, partyPokemon)
			end
		end
		index = index + 1
	end
end

-- Currently unused
function RandomizerLog.parsePickupItems(logLines)
	-- Utils.printDebug("#%s: %s >%s< %s", trainer_num, pokemon or "N/A", helditem or "N/A", level or 0)
end

-- DEBUG HELPER, will use later for foreign games
function RandomizerLog.printPokemonIds()
	local count = 0
	local mons = {}
	for id, pokemon in ipairs(PokemonData.Pokemon) do
		if PokemonData.isValid(id) then
			table.insert(mons, string.format('["%s"] = %s,', pokemon.name:lower(), id))
			count = count + 1
		end
		-- Print 20 lines at a time
		if count >= 20 then
			print(table.concat(mons, "\n"))
			mons = {}
			count = count - 20
		end
	end
	if count >= 1 then
		print(table.concat(mons, "\n"))
		mons = {}
	end
end

-- DEBUG HELPER, will use later for foreign games
function RandomizerLog.printMoveIds()
	local count = 0
	local moves = {}
	for id, move in ipairs(MoveData.Moves) do
		if MoveData.isValid(id) then
			table.insert(moves, string.format('["%s"] = %s,', move.name:lower(), id))
			count = count + 1
		end
		-- Print 20 lines at a time
		if count >= 20 then
			print(table.concat(moves, "\n"))
			moves = {}
			count = count - 20
		end
	end
	if count >= 1 then
		print(table.concat(moves, "\n"))
		moves = {}
	end
end

function RandomizerLog.setupMappings()
	RandomizerLog.PokemonNameToIdMap = {
		["bulbasaur"] = 1,
		["ivysaur"] = 2,
		["venusaur"] = 3,
		["charmander"] = 4,
		["charmeleon"] = 5,
		["charizard"] = 6,
		["squirtle"] = 7,
		["wartortle"] = 8,
		["blastoise"] = 9,
		["caterpie"] = 10,
		["metapod"] = 11,
		["butterfree"] = 12,
		["weedle"] = 13,
		["kakuna"] = 14,
		["beedrill"] = 15,
		["pidgey"] = 16,
		["pidgeotto"] = 17,
		["pidgeot"] = 18,
		["rattata"] = 19,
		["raticate"] = 20,
		["spearow"] = 21,
		["fearow"] = 22,
		["ekans"] = 23,
		["arbok"] = 24,
		["pikachu"] = 25,
		["raichu"] = 26,
		["sandshrew"] = 27,
		["sandslash"] = 28,
		["nidoran f"] = 29,
		["nidorina"] = 30,
		["nidoqueen"] = 31,
		["nidoran m"] = 32,
		["nidorino"] = 33,
		["nidoking"] = 34,
		["clefairy"] = 35,
		["clefable"] = 36,
		["vulpix"] = 37,
		["ninetales"] = 38,
		["jigglypuff"] = 39,
		["wigglytuff"] = 40,
		["zubat"] = 41,
		["golbat"] = 42,
		["oddish"] = 43,
		["gloom"] = 44,
		["vileplume"] = 45,
		["paras"] = 46,
		["parasect"] = 47,
		["venonat"] = 48,
		["venomoth"] = 49,
		["diglett"] = 50,
		["dugtrio"] = 51,
		["meowth"] = 52,
		["persian"] = 53,
		["psyduck"] = 54,
		["golduck"] = 55,
		["mankey"] = 56,
		["primeape"] = 57,
		["growlithe"] = 58,
		["arcanine"] = 59,
		["poliwag"] = 60,
		["poliwhirl"] = 61,
		["poliwrath"] = 62,
		["abra"] = 63,
		["kadabra"] = 64,
		["alakazam"] = 65,
		["machop"] = 66,
		["machoke"] = 67,
		["machamp"] = 68,
		["bellsprout"] = 69,
		["weepinbell"] = 70,
		["victreebel"] = 71,
		["tentacool"] = 72,
		["tentacruel"] = 73,
		["geodude"] = 74,
		["graveler"] = 75,
		["golem"] = 76,
		["ponyta"] = 77,
		["rapidash"] = 78,
		["slowpoke"] = 79,
		["slowbro"] = 80,
		["magnemite"] = 81,
		["magneton"] = 82,
		["farfetch'd"] = 83,
		["doduo"] = 84,
		["dodrio"] = 85,
		["seel"] = 86,
		["dewgong"] = 87,
		["grimer"] = 88,
		["muk"] = 89,
		["shellder"] = 90,
		["cloyster"] = 91,
		["gastly"] = 92,
		["haunter"] = 93,
		["gengar"] = 94,
		["onix"] = 95,
		["drowzee"] = 96,
		["hypno"] = 97,
		["krabby"] = 98,
		["kingler"] = 99,
		["voltorb"] = 100,
		["electrode"] = 101,
		["exeggcute"] = 102,
		["exeggutor"] = 103,
		["cubone"] = 104,
		["marowak"] = 105,
		["hitmonlee"] = 106,
		["hitmonchan"] = 107,
		["lickitung"] = 108,
		["koffing"] = 109,
		["weezing"] = 110,
		["rhyhorn"] = 111,
		["rhydon"] = 112,
		["chansey"] = 113,
		["tangela"] = 114,
		["kangaskhan"] = 115,
		["horsea"] = 116,
		["seadra"] = 117,
		["goldeen"] = 118,
		["seaking"] = 119,
		["staryu"] = 120,
		["starmie"] = 121,
		["mr. mime"] = 122,
		["scyther"] = 123,
		["jynx"] = 124,
		["electabuzz"] = 125,
		["magmar"] = 126,
		["pinsir"] = 127,
		["tauros"] = 128,
		["magikarp"] = 129,
		["gyarados"] = 130,
		["lapras"] = 131,
		["ditto"] = 132,
		["eevee"] = 133,
		["vaporeon"] = 134,
		["jolteon"] = 135,
		["flareon"] = 136,
		["porygon"] = 137,
		["omanyte"] = 138,
		["omastar"] = 139,
		["kabuto"] = 140,
		["kabutops"] = 141,
		["aerodactyl"] = 142,
		["snorlax"] = 143,
		["articuno"] = 144,
		["zapdos"] = 145,
		["moltres"] = 146,
		["dratini"] = 147,
		["dragonair"] = 148,
		["dragonite"] = 149,
		["mewtwo"] = 150,
		["mew"] = 151,

		["chikorita"] = 152,
		["bayleef"] = 153,
		["meganium"] = 154,
		["cyndaquil"] = 155,
		["quilava"] = 156,
		["typhlosion"] = 157,
		["totodile"] = 158,
		["croconaw"] = 159,
		["feraligatr"] = 160,
		["sentret"] = 161,
		["furret"] = 162,
		["hoothoot"] = 163,
		["noctowl"] = 164,
		["ledyba"] = 165,
		["ledian"] = 166,
		["spinarak"] = 167,
		["ariados"] = 168,
		["crobat"] = 169,
		["chinchou"] = 170,
		["lanturn"] = 171,
		["pichu"] = 172,
		["cleffa"] = 173,
		["igglybuff"] = 174,
		["togepi"] = 175,
		["togetic"] = 176,
		["natu"] = 177,
		["xatu"] = 178,
		["mareep"] = 179,
		["flaaffy"] = 180,
		["ampharos"] = 181,
		["bellossom"] = 182,
		["marill"] = 183,
		["azumarill"] = 184,
		["sudowoodo"] = 185,
		["politoed"] = 186,
		["hoppip"] = 187,
		["skiploom"] = 188,
		["jumpluff"] = 189,
		["aipom"] = 190,
		["sunkern"] = 191,
		["sunflora"] = 192,
		["yanma"] = 193,
		["wooper"] = 194,
		["quagsire"] = 195,
		["espeon"] = 196,
		["umbreon"] = 197,
		["murkrow"] = 198,
		["slowking"] = 199,
		["misdreavus"] = 200,
		["unown"] = 201,
		["wobbuffet"] = 202,
		["girafarig"] = 203,
		["pineco"] = 204,
		["forretress"] = 205,
		["dunsparce"] = 206,
		["gligar"] = 207,
		["steelix"] = 208,
		["snubbull"] = 209,
		["granbull"] = 210,
		["qwilfish"] = 211,
		["scizor"] = 212,
		["shuckle"] = 213,
		["heracross"] = 214,
		["sneasel"] = 215,
		["teddiursa"] = 216,
		["ursaring"] = 217,
		["slugma"] = 218,
		["magcargo"] = 219,
		["swinub"] = 220,
		["piloswine"] = 221,
		["corsola"] = 222,
		["remoraid"] = 223,
		["octillery"] = 224,
		["delibird"] = 225,
		["mantine"] = 226,
		["skarmory"] = 227,
		["houndour"] = 228,
		["houndoom"] = 229,
		["kingdra"] = 230,
		["phanpy"] = 231,
		["donphan"] = 232,
		["porygon2"] = 233,
		["stantler"] = 234,
		["smeargle"] = 235,
		["tyrogue"] = 236,
		["hitmontop"] = 237,
		["smoochum"] = 238,
		["elekid"] = 239,
		["magby"] = 240,
		["miltank"] = 241,
		["blissey"] = 242,
		["raikou"] = 243,
		["entei"] = 244,
		["suicune"] = 245,
		["larvitar"] = 246,
		["pupitar"] = 247,
		["tyranitar"] = 248,
		["lugia"] = 249,
		["ho-oh"] = 250,
		["celebi"] = 251,

		["treecko"] = 277,
		["grovyle"] = 278,
		["sceptile"] = 279,
		["torchic"] = 280,
		["combusken"] = 281,
		["blaziken"] = 282,
		["mudkip"] = 283,
		["marshtomp"] = 284,
		["swampert"] = 285,
		["poochyena"] = 286,
		["mightyena"] = 287,
		["zigzagoon"] = 288,
		["linoone"] = 289,
		["wurmple"] = 290,
		["silcoon"] = 291,
		["beautifly"] = 292,
		["cascoon"] = 293,
		["dustox"] = 294,
		["lotad"] = 295,
		["lombre"] = 296,
		["ludicolo"] = 297,
		["seedot"] = 298,
		["nuzleaf"] = 299,
		["shiftry"] = 300,
		["nincada"] = 301,
		["ninjask"] = 302,
		["shedinja"] = 303,
		["taillow"] = 304,
		["swellow"] = 305,
		["shroomish"] = 306,
		["breloom"] = 307,
		["spinda"] = 308,
		["wingull"] = 309,
		["pelipper"] = 310,
		["surskit"] = 311,
		["masquerain"] = 312,
		["wailmer"] = 313,
		["wailord"] = 314,
		["skitty"] = 315,
		["delcatty"] = 316,
		["kecleon"] = 317,
		["baltoy"] = 318,
		["claydol"] = 319,
		["nosepass"] = 320,
		["torkoal"] = 321,
		["sableye"] = 322,
		["barboach"] = 323,
		["whiscash"] = 324,
		["luvdisc"] = 325,
		["corphish"] = 326,
		["crawdaunt"] = 327,
		["feebas"] = 328,
		["milotic"] = 329,
		["carvanha"] = 330,
		["sharpedo"] = 331,
		["trapinch"] = 332,
		["vibrava"] = 333,
		["flygon"] = 334,
		["makuhita"] = 335,
		["hariyama"] = 336,
		["electrike"] = 337,
		["manectric"] = 338,
		["numel"] = 339,
		["camerupt"] = 340,
		["spheal"] = 341,
		["sealeo"] = 342,
		["walrein"] = 343,
		["cacnea"] = 344,
		["cacturne"] = 345,
		["snorunt"] = 346,
		["glalie"] = 347,
		["lunatone"] = 348,
		["solrock"] = 349,
		["azurill"] = 350,
		["spoink"] = 351,
		["grumpig"] = 352,
		["plusle"] = 353,
		["minun"] = 354,
		["mawile"] = 355,
		["meditite"] = 356,
		["medicham"] = 357,
		["swablu"] = 358,
		["altaria"] = 359,
		["wynaut"] = 360,
		["duskull"] = 361,
		["dusclops"] = 362,
		["roselia"] = 363,
		["slakoth"] = 364,
		["vigoroth"] = 365,
		["slaking"] = 366,
		["gulpin"] = 367,
		["swalot"] = 368,
		["tropius"] = 369,
		["whismur"] = 370,
		["loudred"] = 371,
		["exploud"] = 372,
		["clamperl"] = 373,
		["huntail"] = 374,
		["gorebyss"] = 375,
		["absol"] = 376,
		["shuppet"] = 377,
		["banette"] = 378,
		["seviper"] = 379,
		["zangoose"] = 380,
		["relicanth"] = 381,
		["aron"] = 382,
		["lairon"] = 383,
		["aggron"] = 384,
		["castform"] = 385,
		["volbeat"] = 386,
		["illumise"] = 387,
		["lileep"] = 388,
		["cradily"] = 389,
		["anorith"] = 390,
		["armaldo"] = 391,
		["ralts"] = 392,
		["kirlia"] = 393,
		["gardevoir"] = 394,
		["bagon"] = 395,
		["shelgon"] = 396,
		["salamence"] = 397,
		["beldum"] = 398,
		["metang"] = 399,
		["metagross"] = 400,
		["regirock"] = 401,
		["regice"] = 402,
		["registeel"] = 403,
		["kyogre"] = 404,
		["groudon"] = 405,
		["rayquaza"] = 406,
		["latias"] = 407,
		["latios"] = 408,
		["jirachi"] = 409,
		["deoxys"] = 410,
		["chimecho"] = 411,
	}
	RandomizerLog.MoveNameToIdMap = {
		["pound"] = 1,
		["karate chop"] = 2,
		["doubleslap"] = 3,
		["comet punch"] = 4,
		["mega punch"] = 5,
		["pay day"] = 6,
		["fire punch"] = 7,
		["ice punch"] = 8,
		["thunderpunch"] = 9,
		["scratch"] = 10,
		["vicegrip"] = 11,
		["guillotine"] = 12,
		["razor wind"] = 13,
		["swords dance"] = 14,
		["cut"] = 15,
		["gust"] = 16,
		["wing attack"] = 17,
		["whirlwind"] = 18,
		["fly"] = 19,
		["bind"] = 20,
		["slam"] = 21,
		["vine whip"] = 22,
		["stomp"] = 23,
		["double kick"] = 24,
		["mega kick"] = 25,
		["jump kick"] = 26,
		["rolling kick"] = 27,
		["sand-attack"] = 28,
		["headbutt"] = 29,
		["horn attack"] = 30,
		["fury attack"] = 31,
		["horn drill"] = 32,
		["tackle"] = 33,
		["body slam"] = 34,
		["wrap"] = 35,
		["take down"] = 36,
		["thrash"] = 37,
		["double-edge"] = 38,
		["tail whip"] = 39,
		["poison sting"] = 40,
		["twineedle"] = 41,
		["pin missile"] = 42,
		["leer"] = 43,
		["bite"] = 44,
		["growl"] = 45,
		["roar"] = 46,
		["sing"] = 47,
		["supersonic"] = 48,
		["sonicboom"] = 49,
		["disable"] = 50,
		["acid"] = 51,
		["ember"] = 52,
		["flamethrower"] = 53,
		["mist"] = 54,
		["water gun"] = 55,
		["hydro pump"] = 56,
		["surf"] = 57,
		["ice beam"] = 58,
		["blizzard"] = 59,
		["psybeam"] = 60,
		["bubblebeam"] = 61,
		["aurora beam"] = 62,
		["hyper beam"] = 63,
		["peck"] = 64,
		["drill peck"] = 65,
		["submission"] = 66,
		["low kick"] = 67,
		["counter"] = 68,
		["seismic toss"] = 69,
		["strength"] = 70,
		["absorb"] = 71,
		["mega drain"] = 72,
		["leech seed"] = 73,
		["growth"] = 74,
		["razor leaf"] = 75,
		["solarbeam"] = 76,
		["poisonpowder"] = 77,
		["stun spore"] = 78,
		["sleep powder"] = 79,
		["petal dance"] = 80,
		["string shot"] = 81,
		["dragon rage"] = 82,
		["fire spin"] = 83,
		["thundershock"] = 84,
		["thunderbolt"] = 85,
		["thunder wave"] = 86,
		["thunder"] = 87,
		["rock throw"] = 88,
		["earthquake"] = 89,
		["fissure"] = 90,
		["dig"] = 91,
		["toxic"] = 92,
		["confusion"] = 93,
		["psychic"] = 94,
		["hypnosis"] = 95,
		["meditate"] = 96,
		["agility"] = 97,
		["quick attack"] = 98,
		["rage"] = 99,
		["teleport"] = 100,
		["night shade"] = 101,
		["mimic"] = 102,
		["screech"] = 103,
		["double team"] = 104,
		["recover"] = 105,
		["harden"] = 106,
		["minimize"] = 107,
		["smokescreen"] = 108,
		["confuse ray"] = 109,
		["withdraw"] = 110,
		["defense curl"] = 111,
		["barrier"] = 112,
		["light screen"] = 113,
		["haze"] = 114,
		["reflect"] = 115,
		["focus energy"] = 116,
		["bide"] = 117,
		["metronome"] = 118,
		["mirror move"] = 119,
		["selfdestruct"] = 120,
		["egg bomb"] = 121,
		["lick"] = 122,
		["smog"] = 123,
		["sludge"] = 124,
		["bone club"] = 125,
		["fire blast"] = 126,
		["waterfall"] = 127,
		["clamp"] = 128,
		["swift"] = 129,
		["skull bash"] = 130,
		["spike cannon"] = 131,
		["constrict"] = 132,
		["amnesia"] = 133,
		["kinesis"] = 134,
		["softboiled"] = 135,
		["hi jump kick"] = 136,
		["glare"] = 137,
		["dream eater"] = 138,
		["poison gas"] = 139,
		["barrage"] = 140,
		["leech life"] = 141,
		["lovely kiss"] = 142,
		["sky attack"] = 143,
		["transform"] = 144,
		["bubble"] = 145,
		["dizzy punch"] = 146,
		["spore"] = 147,
		["flash"] = 148,
		["psywave"] = 149,
		["splash"] = 150,
		["acid armor"] = 151,
		["crabhammer"] = 152,
		["explosion"] = 153,
		["fury swipes"] = 154,
		["bonemerang"] = 155,
		["rest"] = 156,
		["rock slide"] = 157,
		["hyper fang"] = 158,
		["sharpen"] = 159,
		["conversion"] = 160,
		["tri attack"] = 161,
		["super fang"] = 162,
		["slash"] = 163,
		["substitute"] = 164,
		["struggle"] = 165,
		["sketch"] = 166,
		["triple kick"] = 167,
		["thief"] = 168,
		["spider web"] = 169,
		["mind reader"] = 170,
		["nightmare"] = 171,
		["flame wheel"] = 172,
		["snore"] = 173,
		["curse"] = 174,
		["flail"] = 175,
		["conversion 2"] = 176,
		["aeroblast"] = 177,
		["cotton spore"] = 178,
		["reversal"] = 179,
		["spite"] = 180,
		["powder snow"] = 181,
		["protect"] = 182,
		["mach punch"] = 183,
		["scary face"] = 184,
		["faint attack"] = 185,
		["sweet kiss"] = 186,
		["belly drum"] = 187,
		["sludge bomb"] = 188,
		["mud-slap"] = 189,
		["octazooka"] = 190,
		["spikes"] = 191,
		["zap cannon"] = 192,
		["foresight"] = 193,
		["destiny bond"] = 194,
		["perish song"] = 195,
		["icy wind"] = 196,
		["detect"] = 197,
		["bone rush"] = 198,
		["lock-on"] = 199,
		["outrage"] = 200,
		["sandstorm"] = 201,
		["giga drain"] = 202,
		["endure"] = 203,
		["charm"] = 204,
		["rollout"] = 205,
		["false swipe"] = 206,
		["swagger"] = 207,
		["milk drink"] = 208,
		["spark"] = 209,
		["fury cutter"] = 210,
		["steel wing"] = 211,
		["mean look"] = 212,
		["attract"] = 213,
		["sleep talk"] = 214,
		["heal bell"] = 215,
		["return"] = 216,
		["present"] = 217,
		["frustration"] = 218,
		["safeguard"] = 219,
		["pain split"] = 220,
		["sacred fire"] = 221,
		["magnitude"] = 222,
		["dynamicpunch"] = 223,
		["megahorn"] = 224,
		["dragonbreath"] = 225,
		["baton pass"] = 226,
		["encore"] = 227,
		["pursuit"] = 228,
		["rapid spin"] = 229,
		["sweet scent"] = 230,
		["iron tail"] = 231,
		["metal claw"] = 232,
		["vital throw"] = 233,
		["morning sun"] = 234,
		["synthesis"] = 235,
		["moonlight"] = 236,
		["hidden power"] = 237,
		["cross chop"] = 238,
		["twister"] = 239,
		["rain dance"] = 240,
		["sunny day"] = 241,
		["crunch"] = 242,
		["mirror coat"] = 243,
		["psych up"] = 244,
		["extremespeed"] = 245,
		["ancientpower"] = 246,
		["shadow ball"] = 247,
		["future sight"] = 248,
		["rock smash"] = 249,
		["whirlpool"] = 250,
		["beat up"] = 251,
		["fake out"] = 252,
		["uproar"] = 253,
		["stockpile"] = 254,
		["spit up"] = 255,
		["swallow"] = 256,
		["heat wave"] = 257,
		["hail"] = 258,
		["torment"] = 259,
		["flatter"] = 260,
		["will-o-wisp"] = 261,
		["memento"] = 262,
		["facade"] = 263,
		["focus punch"] = 264,
		["smellingsalt"] = 265,
		["follow me"] = 266,
		["nature power"] = 267,
		["charge"] = 268,
		["taunt"] = 269,
		["helping hand"] = 270,
		["trick"] = 271,
		["role play"] = 272,
		["wish"] = 273,
		["assist"] = 274,
		["ingrain"] = 275,
		["superpower"] = 276,
		["magic coat"] = 277,
		["recycle"] = 278,
		["revenge"] = 279,
		["brick break"] = 280,
		["yawn"] = 281,
		["knock off"] = 282,
		["endeavor"] = 283,
		["eruption"] = 284,
		["skill swap"] = 285,
		["imprison"] = 286,
		["refresh"] = 287,
		["grudge"] = 288,
		["snatch"] = 289,
		["secret power"] = 290,
		["dive"] = 291,
		["arm thrust"] = 292,
		["camouflage"] = 293,
		["tail glow"] = 294,
		["luster purge"] = 295,
		["mist ball"] = 296,
		["featherdance"] = 297,
		["teeter dance"] = 298,
		["blaze kick"] = 299,
		["mud sport"] = 300,
		["ice ball"] = 301,
		["needle arm"] = 302,
		["slack off"] = 303,
		["hyper voice"] = 304,
		["poison fang"] = 305,
		["crush claw"] = 306,
		["blast burn"] = 307,
		["hydro cannon"] = 308,
		["meteor mash"] = 309,
		["astonish"] = 310,
		["weather ball"] = 311,
		["aromatherapy"] = 312,
		["fake tears"] = 313,
		["air cutter"] = 314,
		["overheat"] = 315,
		["odor sleuth"] = 316,
		["rock tomb"] = 317,
		["silver wind"] = 318,
		["metal sound"] = 319,
		["grasswhistle"] = 320,
		["tickle"] = 321,
		["cosmic power"] = 322,
		["water spout"] = 323,
		["signal beam"] = 324,
		["shadow punch"] = 325,
		["extrasensory"] = 326,
		["sky uppercut"] = 327,
		["sand tomb"] = 328,
		["sheer cold"] = 329,
		["muddy water"] = 330,
		["bullet seed"] = 331,
		["aerial ace"] = 332,
		["icicle spear"] = 333,
		["iron defense"] = 334,
		["block"] = 335,
		["howl"] = 336,
		["dragon claw"] = 337,
		["frenzy plant"] = 338,
		["bulk up"] = 339,
		["bounce"] = 340,
		["mud shot"] = 341,
		["poison tail"] = 342,
		["covet"] = 343,
		["volt tackle"] = 344,
		["magical leaf"] = 345,
		["water sport"] = 346,
		["calm mind"] = 347,
		["leaf blade"] = 348,
		["dragon dance"] = 349,
		["rock blast"] = 350,
		["shock wave"] = 351,
		["water pulse"] = 352,
		["doom desire"] = 353,
		["psycho boost"] = 354,
	}
end

-- Returns a table with trainer info { name, filterGroup, filename, }
function RandomizerLog.getTrainerInfo(trainerId, game)
	if game == nil or trainerId == nil or RandomizerLog.GameAndTrainerMap[game] == nil or RandomizerLog.GameAndTrainerMap[game][trainerId] == nil then
		local randomIcon = Utils.inlineIf(math.random(2) == 1, "a", "b") -- For now, random between female and male trainer
		return {
			name = "Unknown",
			group = "Other",
			filename = "unknown-" .. randomIcon,
		}
	end
	return RandomizerLog.GameAndTrainerMap[game][trainerId]
end

-- Mapped by [GameNumber][TrainerId] = data table with filename
RandomizerLog.TrainerFileInfo = {
	-- Aim to have width at 42+ and height 63
	maxWidth = 58,
	maxHeight = 63,

	["e-rival-brendan"] =		{ width = 40, height = 55, offsetX = 0, offsetY = 6, },
	["e-rival-may"] =			{ width = 40, height = 55, offsetX = 0, offsetY = 6, },
	["rs-rival-brendan"] =		{ width = 40, height = 55, offsetX = 0, offsetY = 6, },
	["rs-rival-may"] =			{ width = 40, height = 55, offsetX = 0, offsetY = 6, },
	["rse-wally"] =				{ width = 38, height = 57, offsetX = 10, offsetY = 4, },
	["rse-gymleader-1"] =		{ width = 35, height = 54, offsetX = 4, offsetY = 6, },
	["rse-gymleader-2"] =		{ width = 51, height = 61, offsetX = 0, offsetY = 2, },
	["rse-gymleader-3"] =		{ width = 35, height = 60, offsetX = 0, offsetY = 2, },
	["rse-gymleader-4"] =		{ width = 45, height = 61, offsetX = 3, offsetY = 2, },
	["rse-gymleader-5"] =		{ width = 35, height = 63, offsetX = 0, offsetY = 0, },
	["rse-gymleader-6"] =		{ width = 45, height = 60, offsetX = 0, offsetY = 2, },
	["rse-gymleader-7"] =		{ width = 57, height = 54, offsetX = 0, offsetY = 4, },
	["rse-elitefour-1"] =		{ width = 40, height = 54, offsetX = 0, offsetY = 6, },
	["rse-elitefour-2"] =		{ width = 38, height = 57, offsetX = 5, offsetY = 4, },
	["rse-elitefour-3"] =		{ width = 40, height = 61, offsetX = 0, offsetY = 2, },
	["rse-elitefour-4"] =		{ width = 47, height = 63, offsetX = 3, offsetY = 1, },
	["e-gymleader-8"] =			{ width = 40, height = 63, offsetX = 0, offsetY = 3, },
	["rs-gymleader-8"] =		{ width = 48, height = 55, offsetX = 0, offsetY = 6, },
	["e-elitefour-champ"] =		{ width = 56, height = 59, offsetX = 0, offsetY = 2, },
	["rs-elitefour-champ"] =	{ width = 34, height = 63, offsetX = 0, offsetY = 0, },
	["e-final-steven"] =		{ width = 34, height = 63, offsetX = 0, offsetY = 2, },

	["frlg-rival-a"] =			{ width = 42, height = 57, offsetX = 1, offsetY = 3, },
	["frlg-rival-b"] =			{ width = 42, height = 60, offsetX = 0, offsetY = 2, },
	["frlg-rival-c"] =			{ width = 42, height = 57, offsetX = 0, offsetY = 3, },
	["frlg-blackbelt"] =		{ width = 52, height = 61, offsetX = 0, offsetY = 1, },
	["frlg-gymleader-1"] =		{ width = 43, height = 63, offsetX = 3, offsetY = 2, },
	["frlg-gymleader-2"] =		{ width = 43, height = 61, offsetX = 2, offsetY = 2, },
	["frlg-gymleader-3"] =		{ width = 43, height = 61, offsetX = 0, offsetY = 2, },
	["frlg-gymleader-4"] =		{ width = 43, height = 57, offsetX = 2, offsetY = 3, },
	["frlg-gymleader-5"] =		{ width = 46, height = 54, offsetX = 0, offsetY = 4, },
	["frlg-gymleader-6"] =		{ width = 43, height = 56, offsetX = 0, offsetY = 4, },
	["frlg-gymleader-7"] =		{ width = 44, height = 61, offsetX = 0, offsetY = 2, },
	["frlg-gymleader-8"] =		{ width = 42, height = 63, offsetX = 2, offsetY = 1, },
	["frlg-elitefour-1"] =		{ width = 38, height = 62, offsetX = 0, offsetY = 2, },
	["frlg-elitefour-2"] =		{ width = 53, height = 52, offsetX = 0, offsetY = 5, },
	["frlg-elitefour-3"] =		{ width = 30, height = 57, offsetX = 1, offsetY = 3, },
	["frlg-elitefour-4"] =		{ width = 58, height = 60, offsetX = 0, offsetY = 3, },
	["unknown-a"] =				{ width = 42, height = 55, offsetX = 0, offsetY = 8, },
	["unknown-b"] =				{ width = 42, height = 55, offsetX = 0, offsetY = 8, },
}

RandomizerLog.TrainerGroups = {
	All = "All",
	Rival = "Rival",
	Gym = "Gym",
	Elite4 = "Elite 4",
	Boss = "Boss",
	Other = "Other",
}
RandomizerLog.GameAndTrainerMap = {
	[1] = { -- Game #: Ruby / Sapphire
		[261] = {
			name = "Sidney",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rse-elitefour-1",
		},
		[262] = {
			name = "Phoebe",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rse-elitefour-2",
		},
		[263] = {
			name = "Glacia",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rse-elitefour-3",
		},
		[264] = {
			name = "Drake",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rse-elitefour-4",
		},
		[265] = {
			name = "Roxanne",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-1",
		},
		[266] = {
			name = "Brawly",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-2",
		},
		[267] = {
			name = "Wattson",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-3",
		},
		[268] = {
			name = "Flannery",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-4",
		},
		[269] = {
			name = "Norman",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-5",
		},
		[270] = {
			name = "Winona",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-6",
		},
		[271] = {
			name = "Tate & Liza",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-7",
		},
		[272] = {
			name = "Wallace",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rs-gymleader-8",
		},
		[335] = {
			name = "Steven",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rs-elitefour-champ",
		},
		[520] = {
			name = "Brendan 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Left",
		},
		[523] = {
			name = "Brendan 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[526] = {
			name = "Brendan 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Right",
		},
		[521] = {
			name = "Brendan 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Left",
		},
		[524] = {
			name = "Brendan 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[527] = {
			name = "Brendan 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Right",
		},
		[522] = {
			name = "Brendan 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Left",
		},
		[525] = {
			name = "Brendan 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[528] = {
			name = "Brendan 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Right",
		},
		[661] = {
			name = "Brendan 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Left",
		},
		[662] = {
			name = "Brendan 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[663] = {
			name = "Brendan 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-brendan",
			whichRival = "Brendan Right",
		},
		[529] = {
			name = "May 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Left",
		},
		[532] = {
			name = "May 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Middle",
		},
		[535] = {
			name = "May 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Right",
		},
		[530] = {
			name = "May 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Left",
		},
		[533] = {
			name = "May 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Middle",
		},
		[536] = {
			name = "May 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Right",
		},
		[531] = {
			name = "May 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Left",
		},
		[534] = {
			name = "May 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Middle",
		},
		[537] = {
			name = "May 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Right",
		},
		[664] = {
			name = "May 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Left",
		},
		[665] = {
			name = "May 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Middle",
		},
		[666] = {
			name = "May 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "rs-rival-may",
			whichRival = "May Right",
		},
		[656] = {
			name = "Wally 1",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[519] = {
			name = "Wally 2",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[657] = {
			name = "Wally 3",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[658] = {
			name = "Wally 4",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[659] = {
			name = "Wally 5",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[660] = {
			name = "Wally 6",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
	},
	[2] = { -- Game #: Emerald
		[261] = {
			name = "Sidney",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rse-elitefour-1",
		},
		[262] = {
			name = "Phoebe",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rse-elitefour-2",
		},
		[263] = {
			name = "Glacia",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rse-elitefour-3",
		},
		[264] = {
			name = "Drake",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "rse-elitefour-4",
		},
		[265] = {
			name = "Roxanne",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-1",
		},
		[266] = {
			name = "Brawly",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-2",
		},
		[267] = {
			name = "Wattson",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-3",
		},
		[268] = {
			name = "Flannery",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-4",
		},
		[269] = {
			name = "Norman",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-5",
		},
		[270] = {
			name = "Winona",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-6",
		},
		[271] = {
			name = "Tate & Liza",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "rse-gymleader-7",
		},
		[272] = {
			name = "Juan",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "e-gymleader-8",
		},
		[335] = {
			name = "Wallace",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "e-elitefour-champ",
		},
		[520] = {
			name = "Brendan 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[523] = {
			name = "Brendan 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[526] = {
			name = "Brendan 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[592] = {
			name = "Brendan 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[593] = {
			name = "Brendan 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[599] = {
			name = "Brendan 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[521] = {
			name = "Brendan 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[524] = {
			name = "Brendan 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[527] = {
			name = "Brendan 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[522] = {
			name = "Brendan 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[525] = {
			name = "Brendan 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[528] = {
			name = "Brendan 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[661] = {
			name = "Brendan 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Left",
		},
		[662] = {
			name = "Brendan 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Middle",
		},
		[663] = {
			name = "Brendan 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-brendan",
			whichRival = "Brendan Right",
		},
		[529] = {
			name = "May 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[532] = {
			name = "May 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[535] = {
			name = "May 1",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[768] = {
			name = "May 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[769] = {
			name = "May 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[600] = {
			name = "May 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[530] = {
			name = "May 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[533] = {
			name = "May 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[536] = {
			name = "May 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[531] = {
			name = "May 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[534] = {
			name = "May 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[537] = {
			name = "May 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[664] = {
			name = "May 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Left",
		},
		[665] = {
			name = "May 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Middle",
		},
		[666] = {
			name = "May 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "e-rival-may",
			whichRival = "May Right",
		},
		[656] = {
			name = "Wally 1",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[519] = {
			name = "Wally 2",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[657] = {
			name = "Wally 3",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[658] = {
			name = "Wally 4",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[659] = {
			name = "Wally 5",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[660] = {
			name = "Wally 6",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "rse-wally",
		},
		[804] = {
			name = "Steven",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "e-final-steven",
		},
	},
	[3] = { -- Game #: Fire Red / Leaf Green
		[410] = {
			name = "Lorelei",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "frlg-elitefour-1",
		},
		[411] = {
			name = "Bruno",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "frlg-elitefour-2",
		},
		[412] = {
			name = "Agatha",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "frlg-elitefour-3",
		},
		[413] = {
			name = "Lance",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "frlg-elitefour-4",
		},
		[414] = {
			name = "Brock",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[415] = {
			name = "Misty",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "frlg-gymleader-2",
		},
		[416] = {
			name = "Lt. Surge",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "frlg-gymleader-3",
		},
		[417] = {
			name = "Erika",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "frlg-gymleader-4",
		},
		[418] = {
			name = "Koga",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "frlg-gymleader-5",
		},
		[420] = {
			name = "Sabrina",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "frlg-gymleader-6",
		},
		[419] = {
			name = "Blaine",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "frlg-gymleader-7",
		},
		[350] = {
			name = "Giovanni",
			group = RandomizerLog.TrainerGroups.Gym,
			filename = "frlg-gymleader-8",
		},
		-- The follow rivals are shown three times each, in order of starter located in the Middle ball, then Left, then Right
		[326] = {
			name = "Rival 1", -- Rival chose the Middle Ball
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[327] = {
			name = "Rival 1", -- Rival chose the Left Ball
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[328] = {
			name = "Rival 1", -- Rival chose the Right Ball
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[329] = {
			name = "Rival 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Middle",
		},
		[330] = {
			name = "Rival 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Left",
		},
		[331] = {
			name = "Rival 2",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Right",
		},
		[332] = {
			name = "Rival 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Middle",
		},
		[333] = {
			name = "Rival 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Left",
		},
		[334] = {
			name = "Rival 3",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Right",
		},
		[426] = {
			name = "Rival 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[427] = {
			name = "Rival 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[428] = {
			name = "Rival 4",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[429] = {
			name = "Rival 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Middle",
		},
		[430] = {
			name = "Rival 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Left",
		},
		[431] = {
			name = "Rival 5",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Right",
		},
		[432] = {
			name = "Rival 6",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Middle",
		},
		[433] = {
			name = "Rival 6",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Left",
		},
		[434] = {
			name = "Rival 6",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Right",
		},
		[435] = {
			name = "Rival 7",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[436] = {
			name = "Rival 7",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[437] = {
			name = "Rival 7",
			group = RandomizerLog.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[438] = {
			name = "Champion",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "frlg-rival-c",
			whichRival = "Middle",
		},
		[439] = {
			name = "Champion",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "frlg-rival-c",
			whichRival = "Left",
		},
		[440] = {
			name = "Champion",
			group = RandomizerLog.TrainerGroups.Elite4,
			filename = "frlg-rival-c",
			whichRival = "Right",
		},
		[348] = {
			name = "Giovanni 1",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "frlg-gymleader-8",
		},
		[349] = {
			name = "Giovanni 2",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "frlg-gymleader-8",
		},
		[317] = {
			name = "Dojo Leader",
			group = RandomizerLog.TrainerGroups.Boss,
			filename = "frlg-blackbelt",
		},
	},
}

function RandomizerLog.removeMappings()
	RandomizerLog.PokemonNameToIdMap = nil
	RandomizerLog.MoveNameToIdMap = nil
	collectgarbage()
end
