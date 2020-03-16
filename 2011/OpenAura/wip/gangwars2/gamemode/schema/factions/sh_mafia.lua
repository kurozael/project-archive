--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.material = "gangwars2/gangs/mafia";
FACTION.models = {
	female = {"models/napalm_atc/mafi.mdl"},
	male = {"models/napalm_atc/mafi.mdl"};
};

FACTION_MAFIA = openAura.faction:Register(FACTION, "Mafia");