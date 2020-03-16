--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura.hint:AddHumanHint("Flashlight", "If it's dark outside and you can't see, invest in a flashlight.");

-- A function to get whether a player has a flashlight.
function PLUGIN:PlayerHasFlashlight(player)
	if ( openAura.schema:PlayerIsCombine(player) ) then
		return true;
	end;
	
	local weapon = player:GetActiveWeapon();
	
	if ( IsValid(weapon) ) then
		local itemTable = openAura.item:GetWeapon(weapon);
		
		if ( weapon:GetClass() == "aura_flashlight" or (itemTable and itemTable.hasFlashlight) ) then
			return true;
		end;
	end;
end;