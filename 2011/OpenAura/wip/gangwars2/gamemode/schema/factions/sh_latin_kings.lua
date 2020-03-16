--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.material = "gangwars2/gangs/latinkings";
FACTION.models = {
	female = {"models/napalm_atc/king.mdl"},
	male = {"models/napalm_atc/king.mdl"};
};

FACTION_KINGS = openAura.faction:Register(FACTION, "Latin Kings");