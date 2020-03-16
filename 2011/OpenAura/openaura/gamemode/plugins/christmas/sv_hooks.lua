--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called just after a player spawns.
function PLUGIN:PostPlayerSpawn(player, lightSpawn, changeClass, firstSpawn)
	local dateInfo = os.date( "*t", os.time() );
	
	if (dateInfo.month == 12 and dateInfo.day == 25) then
		openAura.player:CreateGear( player, "Christmas", openAura.item:Get("christmas_hat") );
	end;
end;