--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local FACTION = {};

FACTION.useFullName = true;
FACTION.material = "halfliferp/factions/citizen";

-- Called when a player is transferred to the faction.
function FACTION:OnTransferred(player, faction, name)
	if ( openAura.schema:PlayerIsCombine(player) ) then
		if (name) then
			local models = self.models[ string.lower( player:QueryCharacter("gender") ) ];
			
			if (models) then
				player:SetCharacterData("model", models[ math.random(#models) ], true);
				
				openAura.player:SetName(player, name, true);
			end;
		else
			return false, "You need to specify a name as the third argument!";
		end;
	end;
end;

FACTION_CITIZEN = openAura.faction:Register(FACTION, "Citizen");