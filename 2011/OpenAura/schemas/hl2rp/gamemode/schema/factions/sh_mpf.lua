--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.isCombineFaction = true;
FACTION.whitelist = true;
FACTION.material = "halfliferp/factions/mpf";
FACTION.models = {
	female = {"models/police.mdl"},
	male = {"models/police.mdl"}
};

-- Called when a player's name should be assigned for the faction.
function FACTION:GetName(player, character)
	return "MPF-RCT."..openAura:ZeroNumberToDigits(math.random(1, 99999), 5);
end;

-- Called when a player's model should be assigned for the faction.
function FACTION:GetModel(player, character)
	if (character.gender == GENDER_MALE) then
		return self.models.male[1];
	else
		return self.models.female[1];
	end;
end;

-- Called when a player is transferred to the faction.
function FACTION:OnTransferred(player, faction, name)
	if (faction.name == FACTION_OTA) then
		if (name) then
			openAura.player:SetName(player, string.gsub(player:QueryCharacter("name"), ".+(%d%d%d%d%d)", "MPF-RCT.%1"), true);
		else
			return false, "You need to specify a name as the third argument!";
		end;
	else
		openAura.player:SetName( player, self:GetName( player, player:GetCharacter() ) );
	end;
	
	if (player:QueryCharacter("gender") == GENDER_MALE) then
		player:SetCharacterData("model", self.models.male[1], true);
	else
		player:SetCharacterData("model", self.models.female[1], true);
	end;
end;

FACTION_MPF = openAura.faction:Register(FACTION, "Metropolice Force");