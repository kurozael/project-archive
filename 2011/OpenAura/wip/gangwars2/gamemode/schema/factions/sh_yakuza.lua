--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.material = "gangwars2/gangs/yakuza";
FACTION.models = {
	female = {"models/napalm_atc/yaku.mdl"},
	male = {"models/napalm_atc/yaku.mdl"};
};

FACTION_YAKUZA = openAura.faction:Register(FACTION, "Yakuza");