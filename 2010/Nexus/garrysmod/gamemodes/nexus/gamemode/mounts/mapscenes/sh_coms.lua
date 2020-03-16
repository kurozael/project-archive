--[[
Name: "sh_coms.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;
local COMMAND;

COMMAND = {};
COMMAND.tip = "Add a map scene at your current position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local data = {
		position = player:EyePos(),
		angles = player:EyeAngles()
	};
	
	MOUNT.mapScenes[#MOUNT.mapScenes + 1] = data;
	MOUNT:SaveMapScenes();
	
	nexus.player.Notify(player, "You have added a map scene.");
end;

nexus.command.Register(COMMAND, "MapSceneAdd");

COMMAND = {};
COMMAND.tip = "Remove map scenes at your current position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (#MOUNT.mapScenes > 0) then
		local position = player:EyePos();
		local removed = 0;
		
		for k, v in pairs(MOUNT.mapScenes) do
			if (v.position:Distance(position) <= 256) then
				MOUNT.mapScenes[k] = nil;
				
				removed = removed + 1;
			end;
		end;
		
		if (removed > 0) then
			if (removed == 1) then
				nexus.player.Notify(player, "You have removed "..removed.." map scene.");
			else
				nexus.player.Notify(player, "You have removed "..removed.." map scenes.");
			end;
		else
			nexus.player.Notify(player, "There were no map scenes near this position.");
		end;
	else
		nexus.player.Notify(player, "There are no map scenes.");
	end;
end;

nexus.command.Register(COMMAND, "MapSceneRemove");