--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add or remove a spawn point for a vocation.";
COMMAND.text = "<vocation|class|default> <add|remove>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local vocation = kuroScript.vocation.Get( arguments[1] );
	local class = kuroScript.class.Get( arguments[1] );
	local name;
	
	-- Check if a statement is true.
	if (vocation or class) then
		if (class) then
			name = class.name;
		else
			name = vocation.name;
		end;
		
		-- Check if a statement is true.
		if (arguments[2] == "add") then
			MOUNT.spawnPoints[name] = MOUNT.spawnPoints[name] or {};
			MOUNT.spawnPoints[name][#MOUNT.spawnPoints[name] + 1] = player:GetEyeTraceNoCursor().HitPos;
			
			-- Save the spawn points.
			MOUNT:SaveSpawnPoints();
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have added a spawn point for "..name..".");
		elseif (arguments[2] == "remove") then
			if ( MOUNT.spawnPoints[name] ) then
				local position = player:GetEyeTraceNoCursor().HitPos;
				local removed = 0;
				
				-- Loop through each value in a table.
				for k, v in pairs( MOUNT.spawnPoints[name] ) do
					if (v:Distance(position) <= 256) then
						MOUNT.spawnPoints[name][k] = nil;
						
						-- Set some information.
						removed = removed + 1;
					end;
				end;
				
				-- Check if a statement is true.
				if (removed > 0) then
					if (removed == 1) then
						kuroScript.player.Notify(player, "You have removed "..removed.." "..name.." spawn point.");
					else
						kuroScript.player.Notify(player, "You have removed "..removed.." "..name.." spawn points.");
					end;
				else
					kuroScript.player.Notify(player, "There were no "..name.." spawn points near this position.");
				end;
			else
				kuroScript.player.Notify(player, "There are no "..name.." spawn points.");
			end;
			
			-- Save the player spawn points.
			MOUNT:SaveSpawnPoints();
		end;
	elseif (arguments[1] == "default") then
		if (arguments[2] == "add") then
			MOUNT.spawnPoints["default"] = MOUNT.spawnPoints["default"] or {};
			MOUNT.spawnPoints["default"][#MOUNT.spawnPoints["default"] + 1] = player:GetEyeTraceNoCursor().HitPos;
			
			-- Save the spawn points.
			MOUNT:SaveSpawnPoints();
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have added a default spawn point.");
		elseif (arguments[2] == "remove") then
			if ( MOUNT.spawnPoints["default"] ) then
				local position = player:GetEyeTraceNoCursor().HitPos;
				local removed = 0;
				
				-- Loop through each value in a table.
				for k, v in pairs( MOUNT.spawnPoints["default"] ) do
					if (v:Distance(position) <= 256) then
						MOUNT.spawnPoints["default"][k] = nil;
						
						-- Set some information.
						removed = removed + 1;
					end;
				end;
				
				-- Check if a statement is true.
				if (removed > 0) then
					if (removed == 1) then
						kuroScript.player.Notify(player, "You have removed "..removed.." default spawn point.");
					else
						kuroScript.player.Notify(player, "You have removed "..removed.." default spawn points.");
					end;
				else
					kuroScript.player.Notify(player, "There were no default spawn points near this position.");
				end;
			else
				kuroScript.player.Notify(player, "There are no default spawn points.");
			end;
			
			-- Save the player spawn points.
			MOUNT:SaveSpawnPoints();
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid vocation!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "spawnpoint");