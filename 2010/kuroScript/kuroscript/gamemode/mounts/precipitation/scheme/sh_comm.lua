--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make it rain.";
COMMAND.text = "<1-5>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local force = tonumber( arguments[1] );
	
	-- Check if a statement is true.
	if (force and force > 0 and force < 6) then
		kuroScript.frame:SetSharedVar("ks_Precipitation", force);
	else
		kuroScript.player.Notify(player, "This is not a valid force!");
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "rain");

-- Set some information.
COMMAND = {};
COMMAND.tip = "Make it stop raining.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	kuroScript.frame:SetSharedVar("ks_Precipitation", 0);
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "stoprain");