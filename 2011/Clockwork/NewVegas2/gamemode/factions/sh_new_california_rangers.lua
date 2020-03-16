--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.whitelist = true;
FACTION.material = "cwNewVegas/factions/california";
FACTION.models = {
	female = {"models/quake4pm/quakencr.mdl"},
	male = {"models/quake4pm/quakencr.mdl"}
};

-- Called when a player's model should be assigned for the faction.
function FACTION:GetModel(player, character)
	if (character.gender == GENDER_MALE) then
		return self.models.male[1];
	else
		return self.models.female[1];
	end;
end;

FACTION_NCR = Clockwork.faction:Register(FACTION, "New California Rangers");