--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- A function to get whether a player has a flashlight.
function PLUGIN:PlayerHasFlashlight(player)
	local weapon = player:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		local itemTable = openAura.item:GetWeapon(weapon);
		
		if ( weapon:GetClass() == "aura_flashlight" or (itemTable and itemTable.hasFlashlight) ) then
			return true;
		end;
	end;
end;