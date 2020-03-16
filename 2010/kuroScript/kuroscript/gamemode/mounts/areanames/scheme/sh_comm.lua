--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add or remove an area name.";
COMMAND.text = "<add|remove> <name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (arguments[1] == "add") then
		local position = player:GetEyeTraceNoCursor().HitPos;
		
		-- Check if a statement is true.
		if ( !player._FirstAreaNamePoint or player._FirstAreaNamePoint[1] != arguments[2] ) then
			player._FirstAreaNamePoint = {arguments[2], position};
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have added the first point "..arguments[2]..".");
		else
			local data = {
				name = arguments[2],
				minimum = player._FirstAreaNamePoint[2],
				maximum = position
			};
			
			-- Start a user message.
			umsg.Start("ks_AreaAdd");
				umsg.String(data.name);
				umsg.Vector(data.minimum);
				umsg.Vector(data.maximum);
			umsg.End();
			
			-- Set some information.
			MOUNT.areaNames[#MOUNT.areaNames + 1] = data;
			MOUNT:SaveAreaNames();
			
			-- Set some information.
			player._FirstAreaNamePoint = nil;
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have added an area name.");
		end;
	elseif (arguments[1] == "remove") then
		local position = player:GetEyeTraceNoCursor().HitPos;
		local removed = 0;
		
		-- Loop through each value in a table.
		for k, v in pairs(MOUNT.areaNames) do
			if ( v.name == arguments[2] ) then
				if (v.minimum:Distance(position) <= 256 or v.maximum:Distance(position) <= 256) then
					umsg.Start("ks_AreaRemove");
						umsg.String(v.name);
						umsg.Vector(v.minimum);
						umsg.Vector(v.maximum);
					umsg.End();
					
					-- Set some information.
					MOUNT.areaNames[k] = nil;
					
					-- Set some information.
					removed = removed + 1;
				end;
			end;
		end;
		
		-- Check if a statement is true.
		if (removed > 0) then
			if (removed == 1) then
				kuroScript.player.Notify(player, "You have removed "..removed.." area name.");
			else
				kuroScript.player.Notify(player, "You have removed "..removed.." area names.");
			end;
		else
			kuroScript.player.Notify(player, "There were no area names near this position.");
		end;
		
		-- Save the area names.
		MOUNT:SaveAreaNames();
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "areaname");