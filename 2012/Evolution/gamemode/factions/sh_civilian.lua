--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.models = {
	female = {
		"models/humans/group04/female_01.mdl",
		"models/humans/group04/female_02.mdl",
		"models/humans/group04/female_03.mdl",
		"models/humans/group04/female_04.mdl",
		"models/humans/group04/female_06.mdl",
		"models/humans/group04/female_07.mdl",
		"models/humans/group07/female_01.mdl",
		"models/humans/group07/female_02.mdl",
		"models/humans/group07/female_03.mdl",
		"models/humans/group07/female_04.mdl",
		"models/humans/group07/female_06.mdl",
		"models/humans/group07/female_07.mdl",
		"models/humans/group08/female_01.mdl",
		"models/humans/group08/female_02.mdl",
		"models/humans/group08/female_03.mdl",
		"models/humans/group08/female_04.mdl",
		"models/humans/group08/female_06.mdl",
		"models/humans/group08/female_07.mdl"
	},
	male = {
		"models/humans/group04/male_01.mdl",
		"models/humans/group04/male_02.mdl",
		"models/humans/group04/male_03.mdl",
		"models/humans/group04/male_04.mdl",
		"models/humans/group04/male_05.mdl",
		"models/humans/group04/male_06.mdl",
		"models/humans/group04/male_07.mdl",
		"models/humans/group04/male_08.mdl",
		"models/humans/group04/male_09.mdl",
		"models/humans/group07/male_01.mdl",
		"models/humans/group07/male_02.mdl",
		"models/humans/group07/male_03.mdl",
		"models/humans/group07/male_04.mdl",
		"models/humans/group07/male_05.mdl",
		"models/humans/group07/male_06.mdl",
		"models/humans/group07/male_07.mdl",
		"models/humans/group07/male_08.mdl",
		"models/humans/group07/male_09.mdl",
		"models/humans/group08/male_01.mdl",
		"models/humans/group08/male_02.mdl",
		"models/humans/group08/male_03.mdl",
		"models/humans/group08/male_04.mdl",
		"models/humans/group08/male_05.mdl",
		"models/humans/group08/male_06.mdl",
		"models/humans/group08/male_07.mdl",
		"models/humans/group08/male_08.mdl",
		"models/humans/group08/male_09.mdl"
	};
};

FACTION_CIVILIAN = Clockwork.faction:Register(FACTION, "Civilian");