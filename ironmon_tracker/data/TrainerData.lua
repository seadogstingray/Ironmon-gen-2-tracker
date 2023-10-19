-- Currently, this is only used for connecting to trainer data parsed from a randomizer log file
TrainerData = {}

-- These are populated later after the game being played is determined
TrainerData.Trainers = {}
TrainerData.GymTMs = {}

TrainerData.TrainerGroups = {
	All = "All",
	Rival = "Rival",
	Gym = "Gym",
	Elite4 = "Elite 4",
	Boss = "Boss",
	Other = "Other",
}

-- Mapped by [GameNumber][TrainerId] = data table with filename
TrainerData.FileInfo = {
	-- Aim to have width at 42+ and height 63
	maxWidth = 58,
	maxHeight = 63,

	["frlg-rival-a"] =			{ width = 42, height = 57, offsetX = 1, offsetY = 3, },
	["frlg-rival-b"] =			{ width = 42, height = 60, offsetX = 0, offsetY = 2, },
	["frlg-rival-c"] =			{ width = 42, height = 60, offsetX = 0, offsetY = 3, },
	["frlg-blackbelt"] =		{ width = 52, height = 61, offsetX = 0, offsetY = 1, },
	["frlg-gymleader-1"] =		{ width = 43, height = 63, offsetX = 3, offsetY = 2, },
	["frlg-gymleader-2"] =		{ width = 43, height = 61, offsetX = 2, offsetY = 2, },
	["frlg-gymleader-3"] =		{ width = 43, height = 61, offsetX = 0, offsetY = 2, },
	["frlg-gymleader-4"] =		{ width = 43, height = 57, offsetX = 2, offsetY = 3, },
	["frlg-gymleader-5"] =		{ width = 46, height = 54, offsetX = 0, offsetY = 4, },
	["frlg-gymleader-6"] =		{ width = 43, height = 56, offsetX = 0, offsetY = 4, },
	["frlg-gymleader-7"] =		{ width = 44, height = 61, offsetX = 0, offsetY = 2, },
	["frlg-gymleader-8"] =		{ width = 42, height = 63, offsetX = 2, offsetY = 1, },
	["frlg-gymleader-9"] =		{ width = 43, height = 63, offsetX = 3, offsetY = 2, },
	["frlg-gymleader-10"] =		{ width = 43, height = 61, offsetX = 2, offsetY = 2, },
	["frlg-gymleader-11"] =		{ width = 43, height = 61, offsetX = 0, offsetY = 2, },
	["frlg-gymleader-12"] =		{ width = 43, height = 57, offsetX = 2, offsetY = 3, },
	["frlg-gymleader-13"] =		{ width = 46, height = 54, offsetX = 0, offsetY = 4, },
	["frlg-gymleader-14"] =		{ width = 43, height = 56, offsetX = 0, offsetY = 4, },
	["frlg-gymleader-15"] =		{ width = 44, height = 61, offsetX = 0, offsetY = 2, },
	["frlg-gymleader-16"] =		{ width = 42, height = 63, offsetX = 2, offsetY = 1, },
	["frlg-elitefour-1"] =		{ width = 38, height = 62, offsetX = 0, offsetY = 2, },
	["frlg-elitefour-2"] =		{ width = 53, height = 52, offsetX = 0, offsetY = 5, },
	["frlg-elitefour-3"] =		{ width = 30, height = 57, offsetX = 1, offsetY = 3, },
	["frlg-elitefour-4"] =		{ width = 58, height = 60, offsetX = 0, offsetY = 3, },
	["frlg-elitefour-5"] =		{ width = 53, height = 52, offsetX = 0, offsetY = 5, },
	["unknown-a"] =				{ width = 42, height = 55, offsetX = 0, offsetY = 8, },
	["unknown-b"] =				{ width = 42, height = 55, offsetX = 0, offsetY = 8, },
}

function TrainerData.initialize()
		TrainerData.setupTrainersAsGSC()
end

-- Returns a table with trainer info { name, filterGroup, filename, }
function TrainerData.getTrainerInfo(trainerId)
	if trainerId == nil or TrainerData.Trainers[trainerId] == nil then
		local randomIcon = Utils.inlineIf(math.random(2) == 1, "a", "b") -- For now, random between female and male trainer
		return {
			name = "Unknown",
			group = "Other",
			filename = "unknown-" .. randomIcon,
		}
	end
	return TrainerData.Trainers[trainerId]
end


function TrainerData.setupTrainersAsGSC()
	TrainerData.GymTMs = {
		{ leader = "Falkner", number = 31, },
		{ leader = "Bugsy", number = 49, },
		{ leader = "Whitney", number = 45, },
		{ leader = "Morty", number = 30, },
		{ leader = "Chuck", number = 1, },
		{ leader = "Jasmine", number = 23, },
		{ leader = "Pryce", number = 16, },
		{ leader = "Claire", number = 24, },
		{ leader = "Lt. Surge", number = 0, },
		{ leader = "Sabrina", number = 0, },
		{ leader = "Erika", number = 19, },
		{ leader = "Jasmine", number = 6, },
		{ leader = "Brock", number = 0, },
		{ leader = "Blaine", number = 0, },
		{ leader = "Blue", number = 0, },
	}

	TrainerData.Trainers = {
		[24] = {
			name = "Will",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-1",
		},
		[30] = {
			name = "Koga",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-3",
		},
		[28] = {
			name = "Bruno",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-2",
		},
		[29] = {
			name = "Karen",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-3",
		},
		[31] = {
			name = "Lance",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "frlg-elitefour-4",
		},
		[1] = {
			name = "Falkner",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[3] = {
			name = "Bugsy",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[2] = {
			name = "Whitney",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[4] = {
			name = "Morty",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[7] = {
			name = "Chuck",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[6] = {
			name = "Jasmine",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[5] = {
			name = "Pryce",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[8] = {
			name = "Clair",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[32] = {
			name = "Brock",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-1",
		},
		[33] = {
			name = "Misty",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-2",
		},
		[34] = {
			name = "Lt. Surge",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-3",
		},
		[40] = {
			name = "Erika",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-4",
		},
		[115] = {
			name = "Janine",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-5",
		},
		[230] = {
			name = "Sabrina",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-6",
		},
		[381] = {
			name = "Blaine",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-7",
		},
		[533] = {
			name = "Blue",
			group = TrainerData.TrainerGroups.Gym,
			filename = "frlg-gymleader-8",
		},
		-- The follow rivals are shown three times each, in order of starter located in the Middle ball, then Left, then Right
		[250] = {
			name = "Rival 1", -- Rival chose the Middle Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[251] = {
			name = "Rival 1", -- Rival chose the Left Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[252] = {
			name = "Rival 1", -- Rival chose the Right Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[253] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Middle",
		},
		[254] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Left",
		},
		[255] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Right",
		},
		[256] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Middle",
		},
		[257] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Left",
		},
		[258] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Right",
		},
		[350] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[351] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[352] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[353] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Middle",
		},
		[354] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Left",
		},
		[355] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-b",
			whichRival = "Right",
		},
		[356] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Middle",
		},
		[357] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Left",
		},
		[358] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-c",
			whichRival = "Right",
		},
		[359] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Middle",
		},
		[360] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Left",
		},
		[361] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "frlg-rival-a",
			whichRival = "Right",
		},
		[275] = {
			name = "Giovanni 1",
			group = TrainerData.TrainerGroups.Boss,
			filename = "frlg-gymleader-8",
		},
		[276] = {
			name = "Giovanni 2",
			group = TrainerData.TrainerGroups.Boss,
			filename = "frlg-gymleader-8",
		},
		[532] = {
			name = "Pkmn Trainer Red",
			group = TrainerData.TrainerGroups.Boss,
			filename = "frlg-blackbelt",
		},
	}
end