--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

-- A function to get whether a player has a flashlight.
function cwFlashlight:PlayerHasFlashlight(player)
	local weapon = player:GetActiveWeapon();
	
	if (IsValid(weapon)) then
		local itemTable = Clockwork.item:GetByWeapon(weapon);
		
		if (weapon:GetClass() == "cw_flashlight"
		or (itemTable and itemTable("hasFlashlight"))) then
			return true;
		end;
	end;
end;