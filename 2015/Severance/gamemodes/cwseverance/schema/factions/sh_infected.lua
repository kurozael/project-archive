--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local FACTION = Clockwork.faction:New("Infected");

FACTION.useFullName = true;
FACTION.material = "severance/factions/infected";
FACTION.singleGender = GENDER_MALE;
FACTION.models = {
	male = {
		"models/zed/malezed_04.mdl",
		"models/zed/malezed_06.mdl",
		"models/zed/malezed_08.mdl"
	}
};

FACTION_INFECTED = FACTION:Register();