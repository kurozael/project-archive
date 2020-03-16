--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set whether a door is false.";
COMMAND.text = "<bool IsFalse>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		if ( CloudScript:ToBool( arguments[1] ) ) then
			CloudScript.entity:SetDoorFalse(door, true);
			
			PLUGIN.doorData[data.entity] = {
				position = door:GetPos(),
				entity = door,
				text = "hidden",
				name = "hidden"
			};
			
			PLUGIN:SaveDoorData();
			
			CloudScript.player:Notify(player, "You have made this door false.");
		else
			CloudScript.entity:SetDoorFalse(door, false);
			
			PLUGIN.doorData[door] = nil;
			PLUGIN:SaveDoorData();
			
			CloudScript.player:Notify(player, "You have no longer made this door false.");
		end;
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorSetFalse");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set whether a door is hidden.";
COMMAND.text = "<bool IsHidden>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		if ( CloudScript:ToBool( arguments[1] ) ) then
			CloudScript.entity:SetDoorHidden(door, true);
			
			PLUGIN.doorData[data.entity] = {
				position = door:GetPos(),
				entity = door,
				text = "hidden",
				name = "hidden"
			};
			
			PLUGIN:SaveDoorData();
			
			CloudScript.player:Notify(player, "You have hidden this door.");
		else
			CloudScript.entity:SetDoorHidden(door, false);
			
			PLUGIN.doorData[door] = nil;
			PLUGIN:SaveDoorData();
			
			CloudScript.player:Notify(player, "You have unhidden this door.");
		end;
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorSetHidden");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set an unownable door.";
COMMAND.text = "<string Name> [string Text]";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;
COMMAND.optionalArguments = true;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		local data = {
			position = door:GetPos(),
			entity = door,
			text = arguments[2],
			name = arguments[1]
		};
		
		CloudScript.entity:SetDoorName(data.entity, data.name);
		CloudScript.entity:SetDoorText(data.entity, data.text);
		CloudScript.entity:SetDoorUnownable(data.entity, true);
		
		PLUGIN.doorData[data.entity] = data;
		PLUGIN:SaveDoorData();
		
		CloudScript.player:Notify(player, "You have set an unownable door.");
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorSetUnownable");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Lock a door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Lock", "", 0);
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorLock");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Unlock a door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		door:EmitSound("doors/door_latch3.wav");
		door:Fire("Unlock", "", 0);
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorUnlock");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set an ownable door.";
COMMAND.text = "<string Name>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		local data = {
			customName = true,
			position = door:GetPos(),
			entity = door,
			name = table.concat(arguments or {}, " ") or ""
		};
		
		CloudScript.entity:SetDoorUnownable(data.entity, false);
		CloudScript.entity:SetDoorText(data.entity, false);
		CloudScript.entity:SetDoorName(data.entity, data.name);
		
		PLUGIN.doorData[data.entity] = data;
		PLUGIN:SaveDoorData();
		
		CloudScript.player:Notify(player, "You have set an ownable door.");
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorSetOwnable");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Set the active parent door to your target.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		CloudScript.player:Notify(player, "You have set the active parent door to this.");
		
		player.parentDoor = door;
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorSetParent");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Add a child to the active parent door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		if ( IsValid(player.parentDoor) ) then
			PLUGIN.parentData[door] = player.parentDoor;
			PLUGIN:SaveParentData();
			
			CloudScript.entity:SetDoorParent(door, player.parentDoor);
			
			CloudScript.player:Notify(player, "You have added this as a child to the active parent door.");
		else
			CloudScript.player:Notify(player, "You have not selected a valid parent door!");
		end;
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorSetChild");

COMMAND = CloudScript.command:New();
COMMAND.tip = "Unparent the target door.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "a";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local door = player:GetEyeTraceNoCursor().Entity;
	
	if ( IsValid(door) and CloudScript.entity:IsDoor(door) ) then
		PLUGIN.parentData[door] = nil;
		PLUGIN:SaveParentData();
		
		CloudScript.entity:SetDoorParent(door, false);
		
		CloudScript.player:Notify(player, "You have unparented this door.");
	else
		CloudScript.player:Notify(player, "This is not a valid door!");
	end;
end;

CloudScript.command:Register(COMMAND, "DoorUnparent");