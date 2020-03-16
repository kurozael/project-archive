--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Set some information.
COMMAND = {};
COMMAND.tip = "Start a random fire.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local entities = kuroScript.frame:GetPhysicsEntities();
	local entity = entities[ math.random(1, #entities) ];
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		entity:Ignite(math.random(60, 600), 0);
		
		-- Set some information.
		MOUNT.entityFires[entity] = entity:BoundingRadius() * 3;
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "randomfire");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Start a fire at the target entity.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local entity = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(entity) ) then
		entity:Ignite(math.random(60, 600), 0);
		
		-- Set some information.
		MOUNT.entityFires[entity] = entity:BoundingRadius() * 3;
	else
		kuroScript.player.Notify(player, "This is not a valid entity!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "startfire");