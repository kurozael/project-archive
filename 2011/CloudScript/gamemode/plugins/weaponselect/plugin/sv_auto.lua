--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.config:Add("weapon_selection_multi", false);

CloudScript:HookDataStream("SelectWeapon", function(player, data)
	if (type(data) == "string") then
		if ( player:HasWeapon(data) ) then
			player:SelectWeapon(data);
		end;
	end;
end);