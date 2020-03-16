--[[
Name: "sh_coms.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;
local COMMAND;

COMMAND = {};
COMMAND.tip = "Enter or exit observer mode.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:Alive() and !player:IsRagdolled() and !player.observerResetting) then
		if (player:GetMoveType(player) == MOVETYPE_NOCLIP) then
			MOUNT:MakePlayerExitObserverMode(player);
		else
			MOUNT:MakePlayerEnterObserverMode(player);
		end;
	end;
end;

nexus.command.Register(COMMAND, "Observer");