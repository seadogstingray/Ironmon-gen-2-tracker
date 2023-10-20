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

	["gsc-rival-a"] =			{ width = 42, height = 57, offsetX = 1, offsetY = 3, },
	["gsc-rival-b"] =			{ width = 42, height = 60, offsetX = 0, offsetY = 2, },
	["gsc-gymleader-01"] =		{ width = 43, height = 63, offsetX = 3, offsetY = 2, },
	["gsc-gymleader-02"] =		{ width = 43, height = 61, offsetX = 2, offsetY = 2, },
	["gsc-gymleader-03"] =		{ width = 43, height = 61, offsetX = 0, offsetY = 2, },
	["gsc-gymleader-04"] =		{ width = 43, height = 57, offsetX = 2, offsetY = 3, },
	["gsc-gymleader-05"] =		{ width = 46, height = 54, offsetX = 0, offsetY = 4, },
	["gsc-gymleader-06"] =		{ width = 43, height = 56, offsetX = 0, offsetY = 4, },
	["gsc-gymleader-07"] =		{ width = 44, height = 61, offsetX = 0, offsetY = 2, },
	["gsc-gymleader-08"] =		{ width = 42, height = 63, offsetX = 2, offsetY = 1, },
	["gsc-gymleader-09"] =		{ width = 43, height = 63, offsetX = 3, offsetY = 2, },
	["gsc-gymleader-10"] =		{ width = 43, height = 61, offsetX = 2, offsetY = 2, },
	["gsc-gymleader-11"] =		{ width = 43, height = 61, offsetX = 0, offsetY = 2, },
	["gsc-gymleader-12"] =		{ width = 43, height = 57, offsetX = 2, offsetY = 3, },
	["gsc-gymleader-13"] =		{ width = 46, height = 54, offsetX = 0, offsetY = 4, },
	["gsc-gymleader-14"] =		{ width = 43, height = 56, offsetX = 0, offsetY = 4, },
	["gsc-gymleader-15"] =		{ width = 44, height = 61, offsetX = 0, offsetY = 2, },
	["gsc-gymleader-16"] =		{ width = 42, height = 63, offsetX = 2, offsetY = 1, },
	["gsc-elitefour-1"] =		{ width = 38, height = 62, offsetX = 0, offsetY = 2, },
	["gsc-elitefour-2"] =		{ width = 53, height = 52, offsetX = 0, offsetY = 5, },
	["gsc-elitefour-3"] =		{ width = 30, height = 57, offsetX = 1, offsetY = 3, },
	["gsc-elitefour-4"] =		{ width = 58, height = 60, offsetX = 0, offsetY = 3, },
	["gsc-elitefour-5"] =		{ width = 53, height = 52, offsetX = 0, offsetY = 5, },
	["gsc-red"] =				{ width = 42, height = 55, offsetX = 7, offsetY = 8, }
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
		{ leader = "Brock", number = 0, },
		{ leader = "Misty", number = 0, },
		{ leader = "Lt. Surge", number = 0, },
		{ leader = "Sabrina", number = 0, },
		{ leader = "Erika", number = 19, },
		{ leader = "Janine", number = 6, },
		{ leader = "Blaine", number = 0, },
		{ leader = "Blue", number = 0, },
	}

	TrainerData.Trainers = {
		[24] = {
			name = "Will",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "gsc-elitefour-1",
		},
		[30] = {
			name = "Koga",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "gsc-elitefour-2",
		},
		[28] = {
			name = "Bruno",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "gsc-elitefour-3",
		},
		[29] = {
			name = "Karen",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "gsc-elitefour-4",
		},
		[31] = {
			name = "Lance",
			group = TrainerData.TrainerGroups.Elite4,
			filename = "gsc-elitefour-5",
		},
		[1] = {
			name = "Falkner",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-01",
		},
		[3] = {
			name = "Bugsy",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-02",
		},
		[2] = {
			name = "Whitney",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-03",
		},
		[4] = {
			name = "Morty",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-04",
		},
		[7] = {
			name = "Chuck",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-05",
		},
		[6] = {
			name = "Jasmine",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-06",
		},
		[5] = {
			name = "Pryce",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-07",
		},
		[8] = {
			name = "Clair",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-08",
		},
		[32] = {
			name = "Brock",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-09",
		},
		[33] = {
			name = "Misty",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-10",
		},
		[34] = {
			name = "Lt. Surge",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-11",
		},
		[40] = {
			name = "Erika",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-12",
		},
		[115] = {
			name = "Janine",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-13",
		},
		[230] = {
			name = "Sabrina",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-14",
		},
		[381] = {
			name = "Blaine",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-15",
		},
		[533] = {
			name = "Blue",
			group = TrainerData.TrainerGroups.Gym,
			filename = "gsc-gymleader-16",
		},
		-- The follow rivals are shown three times each, in order of starter located in the Middle ball, then Left, then Right
		[9] = {
			name = "Rival 1", -- Rival chose the Middle Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Middle",
		},
		[10] = {
			name = "Rival 1", -- Rival chose the Left Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Left",
		},
		[11] = {
			name = "Rival 1", -- Rival chose the Right Ball
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Right",
		},
		[12] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Middle",
		},
		[13] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Left",
		},
		[14] = {
			name = "Rival 2",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Right",
		},
		[15] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Middle",
		},
		[16] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Left",
		},
		[17] = {
			name = "Rival 3",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-a",
			whichRival = "Right",
		},
		[18] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Middle",
		},
		[19] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Left",
		},
		[20] = {
			name = "Rival 4",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Right",
		},
		[21] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Middle",
		},
		[22] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Left",
		},
		[23] = {
			name = "Rival 5",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Right",
		},
		[342] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Middle",
		},
		[343] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Left",
		},
		[344] = {
			name = "Rival 6",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Right",
		},
		[345] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Middle",
		},
		[346] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Left",
		},
		[347] = {
			name = "Rival 7",
			group = TrainerData.TrainerGroups.Rival,
			filename = "gsc-rival-b",
			whichRival = "Right",
		},
		[532] = {
			name = "Red",
			group = TrainerData.TrainerGroups.Boss,
			filename = "gsc-red",
		},
	}
end