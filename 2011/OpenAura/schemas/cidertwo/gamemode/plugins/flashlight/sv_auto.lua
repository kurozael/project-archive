--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

openAura.hint:Add("Flashlight Item", "If it's dark outside and you can't see, invest in a flashlight.");
openAura.hint:Add("Flashlight Weapons", "Some weapons have a flashlight built into them.");

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