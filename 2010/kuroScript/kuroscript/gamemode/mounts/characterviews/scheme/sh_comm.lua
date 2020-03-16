--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add or remove a character view.";
COMMAND.text = "<add|class|remove>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local class = arguments[1];
	
	-- Check if a statement is true.
	if (arguments[1] != "remove") then
		local data = {
			position = player:EyePos(),
			angles = player:EyeAngles()
		};
		
		-- Check if a statement is true.
		if ( kuroScript.class.stored[class] ) then data.class = class; end;
		
		-- Set some information.
		MOUNT.characterViews[#MOUNT.characterViews + 1] = data; MOUNT:SaveCharacterViews();
		
		-- Check if a statement is true.
		if (data.class) then
			kuroScript.player.Notify(player, "You have added a "..data.class.." character view.");
		else
			kuroScript.player.Notify(player, "You have added a character view.");
		end;
	elseif (#MOUNT.characterViews > 0) then
		local position = player:EyePos();
		local removed = 0;
		
		-- Loop through each value in a table.
		for k, v in pairs(MOUNT.characterViews) do
			if (v.position:Distance(position) <= 256) then
				MOUNT.characterViews[k] = nil;
				
				-- Set some information.
				removed = removed + 1;
			end;
		end;
		
		-- Check if a statement is true.
		if (removed > 0) then
			if (removed == 1) then
				kuroScript.player.Notify(player, "You have removed "..removed.." character view.");
			else
				kuroScript.player.Notify(player, "You have removed "..removed.." character views.");
			end;
		else
			kuroScript.player.Notify(player, "There were no character views near this position.");
		end;
	else
		kuroScript.player.Notify(player, "There are no character views.");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "charview");