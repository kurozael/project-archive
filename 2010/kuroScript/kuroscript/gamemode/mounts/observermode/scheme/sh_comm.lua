--[[
Name: "sh_comm.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;
local COMMAND;

-- Set some information.
COMMAND = {};
COMMAND.tip = "Enter or exit observer mode.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if ( player:Alive() and !player:IsRagdolled() ) then
		if (player:GetMoveType(player) == MOVETYPE_NOCLIP) then
			MOUNT:MakePlayerExitObserverMode(player)
		else
			MOUNT:MakePlayerEnterObserverMode(player);
		end;
	end;
end;

-- Register the command.
kuroScript.command.Register(COMMAND, "observer");