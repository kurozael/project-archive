--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.models = {
	female = {
		"models/humans/group60/female_01.mdl",
		"models/humans/group60/female_02.mdl",
		"models/humans/group60/female_03.mdl",
		"models/humans/group60/female_04.mdl",
		"models/humans/group60/female_06.mdl",
		"models/humans/group60/female_07.mdl",
		"models/humans/group61/female_01.mdl",
		"models/humans/group61/female_02.mdl",
		"models/humans/group61/female_03.mdl",
		"models/humans/group61/female_04.mdl",
		"models/humans/group61/female_06.mdl",
		"models/humans/group61/female_07.mdl",
		"models/humans/group62/female_01.mdl",
		"models/humans/group62/female_02.mdl",
		"models/humans/group62/female_03.mdl",
		"models/humans/group62/female_04.mdl",
		"models/humans/group62/female_06.mdl",
		"models/humans/group62/female_07.mdl"
	},
	male = {
		"models/humans/group60/male_01.mdl",
		"models/humans/group60/male_02.mdl",
		"models/humans/group60/male_03.mdl",
		"models/humans/group60/male_04.mdl",
		"models/humans/group60/male_05.mdl",
		"models/humans/group60/male_06.mdl",
		"models/humans/group60/male_07.mdl",
		"models/humans/group60/male_08.mdl",
		"models/humans/group60/male_09.mdl",
		"models/humans/group61/male_01.mdl",
		"models/humans/group61/male_02.mdl",
		"models/humans/group61/male_03.mdl",
		"models/humans/group61/male_04.mdl",
		"models/humans/group61/male_05.mdl",
		"models/humans/group61/male_06.mdl",
		"models/humans/group61/male_07.mdl",
		"models/humans/group61/male_08.mdl",
		"models/humans/group61/male_09.mdl",
		"models/humans/group62/male_01.mdl",
		"models/humans/group62/male_02.mdl",
		"models/humans/group62/male_03.mdl",
		"models/humans/group62/male_04.mdl",
		"models/humans/group62/male_05.mdl",
		"models/humans/group62/male_06.mdl",
		"models/humans/group62/male_07.mdl",
		"models/humans/group62/male_08.mdl",
		"models/humans/group62/male_09.mdl"
	};
};

FACTION_CIVILIAN = openAura.faction:Register(FACTION, "Civilian");