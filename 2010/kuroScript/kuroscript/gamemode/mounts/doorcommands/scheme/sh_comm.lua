--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add or remove an unownable door.";
COMMAND.text = "<name|hidden|remove> [text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;
COMMAND.optionalArguments = true;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(door) and kuroScript.entity.IsDoor(door) ) then
		if (arguments[1] != "remove") then
			local data = {
				position = door:GetPos(),
				entity = door,
				text = arguments[2],
				name = arguments[1]
			};
			
			-- Set some information.
			kuroScript.entity.SetDoorName(data.entity, data.name);
			kuroScript.entity.SetDoorText(data.entity, data.text);
			kuroScript.entity.SetDoorUnownable(data.entity, true);
			
			-- Set some information.
			MOUNT.doorData[data.entity] = data;
			MOUNT:SaveDoorData();
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have added an unownable door.");
		elseif (MOUNT.doorData[door] and !MOUNT.doorData[door].customName) then
			kuroScript.entity.SetDoorName(door, false);
			kuroScript.entity.SetDoorText(door, false);
			kuroScript.entity.SetDoorUnownable(door, false);
			
			-- Set some information.
			MOUNT.doorData[door] = nil;
			MOUNT:SaveDoorData();
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have removed an unownable door.");
		else
			kuroScript.player.Notify(player, "This is not an unownable door.");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid door!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "unownable");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add or remove a custom door name.";
COMMAND.text = "<name|remove>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "s";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(door) and kuroScript.entity.IsDoor(door) ) then
		if (arguments[1] != "remove") then
			local data = {
				customName = true,
				position = door:GetPos(),
				entity = door,
				name = table.concat(arguments or {}, " ") or ""
			};
			
			-- Set some information.
			kuroScript.entity.SetDoorUnownable(data.entity, false);
			kuroScript.entity.SetDoorText(data.entity, false);
			kuroScript.entity.SetDoorName(data.entity, data.name);
			
			-- Set some information.
			MOUNT.doorData[data.entity] = data;
			MOUNT:SaveDoorData();
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have added a custom door name.");
		elseif (MOUNT.doorData[door] and MOUNT.doorData[door].customName) then
			kuroScript.player.Notify(player, "You have removed a custom door name.");
			
			-- Set the door's name.
			kuroScript.entity.SetDoorName(door, false);
			
			-- Set some information.
			MOUNT.doorData[door] = nil;
			MOUNT:SaveDoorData();
		else
			kuroScript.player.Notify(player, "This door does not have a custom name.");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid door!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "customname");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Set the current parent door to your target.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(door) and kuroScript.entity.IsDoor(door) ) then
		kuroScript.player.Notify(player, "You have set the current parent door to this.");
		
		-- Set some information.
		player._ParentDoor = door;
	else
		kuroScript.player.Notify(player, "This is not a valid door!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "parentdoor");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Add a child to the current door parent.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(door) and kuroScript.entity.IsDoor(door) ) then
		if ( ValidEntity(player._ParentDoor) ) then
			MOUNT.parentData[door] = player._ParentDoor;
			MOUNT:SaveParentData();
			
			-- Set the door's parent.
			kuroScript.entity.SetDoorParent(door, player._ParentDoor);
			
			-- Notify the player.
			kuroScript.player.Notify(player, "You have added this door as a child to the parent door.");
		else
			kuroScript.player.Notify(player, "You have not selected a valid parent door!");
		end;
	else
		kuroScript.player.Notify(player, "This is not a valid door!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "childdoor");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Unparent the target door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	-- Check if a statement is true.
	if ( ValidEntity(door) and kuroScript.entity.IsDoor(door) ) then
		MOUNT.parentData[door] = nil;
		MOUNT:SaveParentData();
		
		-- Set the door's parent.
		kuroScript.entity.SetDoorParent(door, false);
		
		-- Notify the player.
		kuroScript.player.Notify(player, "You have unparented this door.");
	else
		kuroScript.player.Notify(player, "This is not a valid door!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "unparentdoor");