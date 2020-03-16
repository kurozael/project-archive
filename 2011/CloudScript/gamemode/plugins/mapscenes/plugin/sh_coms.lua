--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

COMMAND = CloudScript.command:New();
COMMAND.tip = "Add a map scene at your current position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local data = {
		position = player:EyePos(),
		angles = player:EyeAngles()
	};
	
	PLUGIN.mapScenes[#PLUGIN.mapScenes + 1] = data;
	PLUGIN:SaveMapScenes();
	
	CloudScript.player:Notify(player, "You have added a map scene.");
end;

CloudScript.command:Register(COMMAND, "MapSceneAdd");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Remove map scenes at your current position.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (#PLUGIN.mapScenes > 0) then
		local position = player:EyePos();
		local removed = 0;
		
		for k, v in pairs(PLUGIN.mapScenes) do
			if (v.position:Distance(position) <= 256) then
				PLUGIN.mapScenes[k] = nil;
				
				removed = removed + 1;
			end;
		end;
		
		if (removed > 0) then
			if (removed == 1) then
				CloudScript.player:Notify(player, "You have removed "..removed.." map scene.");
			else
				CloudScript.player:Notify(player, "You have removed "..removed.." map scenes.");
			end;
		else
			CloudScript.player:Notify(player, "There were no map scenes near this position.");
		end;
	else
		CloudScript.player:Notify(player, "There are no map scenes.");
	end;
end;

CloudScript.command:Register(COMMAND, "MapSceneRemove");