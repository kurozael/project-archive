--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player's character has unloaded.
function PLUGIN:PlayerCharacterUnloaded(player)
	if ( openAura.config:Get("spawn_where_left"):Get() and player:Alive() ) then
		local position = player:GetPos();
		local posTable = {
			x = position.x,
			y = position.y,
			z = position.z
		};
		
		player:SetCharacterData("spawnsave", posTable);
	end;
end;

-- Called just after a player spawns.
function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	if (!lightSpawn) then
		local spawnPos = player:GetCharacterData("spawnsave");
		
		if ( spawnPos and openAura.config:Get("spawn_where_left"):Get() ) then
			player:SetCharacterData("spawnsave", nil);
			player:SetPos( Vector(spawnPos.x, spawnPos.y, spawnPos.z) );
		end;
	end;
end;