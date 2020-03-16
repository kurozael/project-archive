--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};
	FACTION.useFullName = true;
	FACTION.whitelist = true;
	FACTION.material = "cwNewVegas/factions/legion";
	FACTION.models = {
		female = {
			"models/humans/group51/female_01.mdl",
			"models/humans/group51/female_02.mdl",
			"models/humans/group51/female_03.mdl",
			"models/humans/group51/female_04.mdl",
			"models/humans/group51/female_06.mdl",
			"models/humans/group51/female_07.mdl"
		},
		male = {
			"models/humans/group51/male_01.mdl",
			"models/humans/group51/male_02.mdl",
			"models/humans/group51/male_03.mdl",
			"models/humans/group51/male_04.mdl",
			"models/humans/group51/male_05.mdl",
			"models/humans/group51/male_06.mdl",
			"models/humans/group51/male_07.mdl",
			"models/humans/group51/male_08.mdl",
			"models/humans/group51/male_09.mdl"
		};
	};
FACTION_LEGION = Clockwork.faction:Register(FACTION, "Caesar's Legion");