--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.material = "gangwars2/gangs/qaeda";
FACTION.models = {
	female = {"models/napalm_atc/alqa.mdl"},
	male = {"models/napalm_atc/alqa.mdl"};
};

FACTION_QAEDA = openAura.faction:Register(FACTION, "Al'Qaeda");