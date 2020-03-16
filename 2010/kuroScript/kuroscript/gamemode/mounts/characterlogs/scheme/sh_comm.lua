--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Set some information.
COMMAND = {};
COMMAND.tip = "Write to your character's log.";
COMMAND.text = "<text>";
COMMAND.flags = CMD_DEFAULT | CMD_DEATHCODE;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	MOUNT:AddCharLog( player, table.concat(arguments, " ") );
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "charlog");