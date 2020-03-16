--[[
Name: "sh_coms.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;
local COMMAND;

COMMAND = {};
COMMAND.tip = "Set whether a door is false.";
COMMAND.text = "<bool IsFalse>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		if ( NEXUS:ToBool( arguments[1] ) ) then
			nexus.entity.SetDoorFalse(door, true);
			
			MOUNT.doorData[data.entity] = {
				position = door:GetPos(),
				entity = door,
				text = "hidden",
				name = "hidden"
			};
			
			MOUNT:SaveDoorData();
			
			nexus.player.Notify(player, "You have made this door false.");
		else
			nexus.entity.SetDoorFalse(door, false);
			
			MOUNT.doorData[door] = nil;
			MOUNT:SaveDoorData();
			
			nexus.player.Notify(player, "You have no longer made this door false.");
		end;
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorSetFalse");

COMMAND = {};
COMMAND.tip = "Set whether a door is hidden.";
COMMAND.text = "<bool IsHidden>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		if ( NEXUS:ToBool( arguments[1] ) ) then
			nexus.entity.SetDoorHidden(door, true);
			
			MOUNT.doorData[data.entity] = {
				position = door:GetPos(),
				entity = door,
				text = "hidden",
				name = "hidden"
			};
			
			MOUNT:SaveDoorData();
			
			nexus.player.Notify(player, "You have hidden this door.");
		else
			nexus.entity.SetDoorHidden(door, false);
			
			MOUNT.doorData[door] = nil;
			MOUNT:SaveDoorData();
			
			nexus.player.Notify(player, "You have unhidden this door.");
		end;
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorSetHidden");

COMMAND = {};
COMMAND.tip = "Set an unownable door.";
COMMAND.text = "<string Name> [string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = true;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		local data = {
			position = door:GetPos(),
			entity = door,
			text = arguments[2],
			name = arguments[1]
		};
		
		nexus.entity.SetDoorName(data.entity, data.name);
		nexus.entity.SetDoorText(data.entity, data.text);
		nexus.entity.SetDoorUnownable(data.entity, true);
		
		MOUNT.doorData[data.entity] = data;
		MOUNT:SaveDoorData();
		
		nexus.player.Notify(player, "You have set an unownable door.");
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorSetUnownable");

COMMAND = {};
COMMAND.tip = "Lock a door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Lock", "", 0);
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorLock");

COMMAND = {};
COMMAND.tip = "Unlock a door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Unlock", "", 0);
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorUnlock");

COMMAND = {};
COMMAND.tip = "Set an ownable door.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		local data = {
			customName = true,
			position = door:GetPos(),
			entity = door,
			name = table.concat(arguments or {}, " ") or ""
		};
		
		nexus.entity.SetDoorUnownable(data.entity, false);
		nexus.entity.SetDoorText(data.entity, false);
		nexus.entity.SetDoorName(data.entity, data.name);
		
		MOUNT.doorData[data.entity] = data;
		MOUNT:SaveDoorData();
		
		nexus.player.Notify(player, "You have set an ownable door.");
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorSetOwnable");

COMMAND = {};
COMMAND.tip = "Set the active parent door to your target.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		nexus.player.Notify(player, "You have set the active parent door to this.");
		
		player.parentDoor = door;
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorSetParent");

COMMAND = {};
COMMAND.tip = "Add a child to the active parent door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		if ( IsValid(player.parentDoor) ) then
			MOUNT.parentData[door] = player.parentDoor;
			MOUNT:SaveParentData();
			
			nexus.entity.SetDoorParent(door, player.parentDoor);
			
			nexus.player.Notify(player, "You have added this as a child to the active parent door.");
		else
			nexus.player.Notify(player, "You have not selected a valid parent door!");
		end;
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorSetChild");

COMMAND = {};
COMMAND.tip = "Unparent the target door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and nexus.entity.IsDoor(door) ) then
		MOUNT.parentData[door] = nil;
		MOUNT:SaveParentData();
		
		nexus.entity.SetDoorParent(door, false);
		
		nexus.player.Notify(player, "You have unparented this door.");
	else
		nexus.player.Notify(player, "This is not a valid door!");
	end;
end;

nexus.command.Register(COMMAND, "DoorUnparent");