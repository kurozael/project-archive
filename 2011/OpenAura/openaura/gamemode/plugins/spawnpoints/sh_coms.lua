--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

COMMAND = openAura.command:New();
COMMAND.tip = "Add a spawn point at your target position.";
COMMAND.text = "<string Class|Faction|Default>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local faction = openAura.faction:Get( arguments[1] );
	local class = openAura.class:Get( arguments[1] );
	local name = nil;
	
	if (class or faction) then
		if (faction) then
			name = faction.name;
		else
			name = class.name;
		end;
		
		PLUGIN.spawnPoints[name] = PLUGIN.spawnPoints[name] or {};
		PLUGIN.spawnPoints[name][#PLUGIN.spawnPoints[name] + 1] = player:GetEyeTraceNoCursor().HitPos;
		
		PLUGIN:SaveSpawnPoints();
		
		openAura.player:Notify(player, "You have added a spawn point for "..name..".");
	elseif (string.lower( arguments[1] ) == "default") then
		PLUGIN.spawnPoints["default"] = PLUGIN.spawnPoints["default"] or {};
		PLUGIN.spawnPoints["default"][#PLUGIN.spawnPoints["default"] + 1] = player:GetEyeTraceNoCursor().HitPos;
		
		PLUGIN:SaveSpawnPoints();
		
		openAura.player:Notify(player, "You have added a default spawn point.");
	else
		openAura.player:Notify(player, "This is not a valid class or faction!");
	end;
end;

openAura.command:Register(COMMAND, "SpawnPointAdd");

COMMAND = openAura.command:New();
COMMAND.tip = "Remove spawn points at your target position.";
COMMAND.text = "<string Class|Faction|Default>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local faction = openAura.faction:Get( arguments[1] );
	local class = openAura.class:Get( arguments[1] );
	local name = nil;
	
	if (class or faction) then
		if (faction) then
			name = faction.name;
		else
			name = class.name;
		end;
		
		if ( PLUGIN.spawnPoints[name] ) then
			local position = player:GetEyeTraceNoCursor().HitPos;
			local removed = 0;
			
			for k, v in pairs( PLUGIN.spawnPoints[name] ) do
				if (v:Distance(position) <= 256) then
					PLUGIN.spawnPoints[name][k] = nil;
					
					removed = removed + 1;
				end;
			end;
			
			if (removed > 0) then
				if (removed == 1) then
					openAura.player:Notify(player, "You have removed "..removed.." "..name.." spawn point.");
				else
					openAura.player:Notify(player, "You have removed "..removed.." "..name.." spawn points.");
				end;
			else
				openAura.player:Notify(player, "There were no "..name.." spawn points near this position.");
			end;
		else
			openAura.player:Notify(player, "There are no "..name.." spawn points.");
		end;
		
		PLUGIN:SaveSpawnPoints();
	elseif (string.lower( arguments[1] ) == "default") then
		if ( PLUGIN.spawnPoints["default"] ) then
			local position = player:GetEyeTraceNoCursor().HitPos;
			local removed = 0;
			
			for k, v in pairs( PLUGIN.spawnPoints["default"] ) do
				if (v:Distance(position) <= 256) then
					PLUGIN.spawnPoints["default"][k] = nil;
					
					removed = removed + 1;
				end;
			end;
			
			if (removed > 0) then
				if (removed == 1) then
					openAura.player:Notify(player, "You have removed "..removed.." default spawn point.");
				else
					openAura.player:Notify(player, "You have removed "..removed.." default spawn points.");
				end;
			else
				openAura.player:Notify(player, "There were no default spawn points near this position.");
			end;
		else
			openAura.player:Notify(player, "There are no default spawn points.");
		end;
		
		PLUGIN:SaveSpawnPoints();
	else
		openAura.player:Notify(player, "This is not a valid class or faction!");
	end;
end;

openAura.command:Register(COMMAND, "SpawnPointRemove");