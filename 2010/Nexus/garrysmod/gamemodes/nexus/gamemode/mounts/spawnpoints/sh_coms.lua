--[[
Name: "sh_coms.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;
local COMMAND;

COMMAND = {};
COMMAND.tip = "Add a spawn point at your target position.";
COMMAND.text = "<string Class|Faction|Default>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local faction = nexus.faction.Get( arguments[1] );
	local class = nexus.class.Get( arguments[1] );
	local name = nil;
	
	if (class or faction) then
		if (faction) then
			name = faction.name;
		else
			name = class.name;
		end;
		
		MOUNT.spawnPoints[name] = MOUNT.spawnPoints[name] or {};
		MOUNT.spawnPoints[name][#MOUNT.spawnPoints[name] + 1] = player:GetEyeTraceNoCursor().HitPos;
		
		MOUNT:SaveSpawnPoints();
		
		nexus.player.Notify(player, "You have added a spawn point for "..name..".");
	elseif (string.lower( arguments[1] ) == "default") then
		MOUNT.spawnPoints["default"] = MOUNT.spawnPoints["default"] or {};
		MOUNT.spawnPoints["default"][#MOUNT.spawnPoints["default"] + 1] = player:GetEyeTraceNoCursor().HitPos;
		
		MOUNT:SaveSpawnPoints();
		
		nexus.player.Notify(player, "You have added a default spawn point.");
	else
		nexus.player.Notify(player, "This is not a valid class or faction!");
	end;
end;

nexus.command.Register(COMMAND, "SpawnPointAdd");

COMMAND = {};
COMMAND.tip = "Remove spawn points at your target position.";
COMMAND.text = "<string Class|Faction|Default>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local faction = nexus.faction.Get( arguments[1] );
	local class = nexus.class.Get( arguments[1] );
	local name = nil;
	
	if (class or faction) then
		if (faction) then
			name = faction.name;
		else
			name = class.name;
		end;
		
		if ( MOUNT.spawnPoints[name] ) then
			local position = player:GetEyeTraceNoCursor().HitPos;
			local removed = 0;
			
			for k, v in pairs( MOUNT.spawnPoints[name] ) do
				if (v:Distance(position) <= 256) then
					MOUNT.spawnPoints[name][k] = nil;
					
					removed = removed + 1;
				end;
			end;
			
			if (removed > 0) then
				if (removed == 1) then
					nexus.player.Notify(player, "You have removed "..removed.." "..name.." spawn point.");
				else
					nexus.player.Notify(player, "You have removed "..removed.." "..name.." spawn points.");
				end;
			else
				nexus.player.Notify(player, "There were no "..name.." spawn points near this position.");
			end;
		else
			nexus.player.Notify(player, "There are no "..name.." spawn points.");
		end;
		
		MOUNT:SaveSpawnPoints();
	elseif (string.lower( arguments[1] ) == "default") then
		if ( MOUNT.spawnPoints["default"] ) then
			local position = player:GetEyeTraceNoCursor().HitPos;
			local removed = 0;
			
			for k, v in pairs( MOUNT.spawnPoints["default"] ) do
				if (v:Distance(position) <= 256) then
					MOUNT.spawnPoints["default"][k] = nil;
					
					removed = removed + 1;
				end;
			end;
			
			if (removed > 0) then
				if (removed == 1) then
					nexus.player.Notify(player, "You have removed "..removed.." default spawn point.");
				else
					nexus.player.Notify(player, "You have removed "..removed.." default spawn points.");
				end;
			else
				nexus.player.Notify(player, "There were no default spawn points near this position.");
			end;
		else
			nexus.player.Notify(player, "There are no default spawn points.");
		end;
		
		MOUNT:SaveSpawnPoints();
	else
		nexus.player.Notify(player, "This is not a valid class or faction!");
	end;
end;

nexus.command.Register(COMMAND, "SpawnPointRemove");