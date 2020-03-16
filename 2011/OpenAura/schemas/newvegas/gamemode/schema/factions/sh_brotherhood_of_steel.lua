--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.whitelist = true;
FACTION.material = "newvegas/factions/bos";
FACTION.models = {
	female = {"models/power_armor/slow.mdl"},
	male = {"models/power_armor/slow.mdl"}
};

-- Called when a player's model should be assigned for the faction.
function FACTION:GetModel(player, character)
	if (character.gender == GENDER_MALE) then
		return self.models.male[1];
	else
		return self.models.female[1];
	end;
end;

FACTION_BROTHERHOOD = openAura.faction:Register(FACTION, "Brotherhood of Steel");