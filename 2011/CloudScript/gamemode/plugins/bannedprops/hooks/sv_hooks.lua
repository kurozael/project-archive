--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

-- Called when a player attempts to spawn a prop.
function PLUGIN:PlayerSpawnProp(player, model)
	model = CloudScript:Replace(model, "\\", "/");
	model = CloudScript:Replace(model, "//", "/");
	model = string.lower(model);
	
	if ( !CloudScript.player:IsAdmin(player) ) then
		if ( string.find(model, "propane") ) then
			CloudScript.player:Notify(player, "You cannot spawn banned props!");
			
			return false;
		end;
		
		for k, v in pairs(self.bannedProps) do
			if (string.lower(v) == model) then
				CloudScript.player:Notify(player, "You cannot spawn banned props!");
				
				return false;
			end;
		end;
	end;
end;