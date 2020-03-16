--[[
Name: "sv_hooks.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Called when a player attempts to spawn a prop.
function MOUNT:PlayerSpawnProp(player, model)
	model = string.Replace(model, "\\", "/");
	model = string.Replace(model, "//", "/");
	model = string.lower(model);
	
	-- Check if a statement is true.
	if ( !player:IsAdmin() ) then
		local k, v;
		
		-- Check if a statement is true.
		if ( string.find(model, "propane") ) then
			kuroScript.player.Notify(player, "You cannot spawn banned props!");
			
			-- Return false to break the function.
			return false;
		end;
		
		-- Loop through each value in a table.
		for k, v in pairs(self.bannedProps) do
			if (string.lower(v) == model) then
				kuroScript.player.Notify(player, "You cannot spawn banned props!");
				
				-- Return false to break the function.
				return false;
			end;
		end;
	end;
end;