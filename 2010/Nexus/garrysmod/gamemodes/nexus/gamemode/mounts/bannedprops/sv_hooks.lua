--[[
Name: "sv_hooks.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

-- Called when a player attempts to spawn a prop.
function MOUNT:PlayerSpawnProp(player, model)
	model = string.Replace(model, "\\", "/");
	model = string.Replace(model, "//", "/");
	model = string.lower(model);
	
	if ( !nexus.player.IsAdmin(player) ) then
		if ( string.find(model, "propane") ) then
			nexus.player.Notify(player, "You cannot spawn banned props!");
			
			return false;
		end;
		
		for k, v in pairs(self.bannedProps) do
			if (string.lower(v) == model) then
				nexus.player.Notify(player, "You cannot spawn banned props!");
				
				return false;
			end;
		end;
	end;
end;