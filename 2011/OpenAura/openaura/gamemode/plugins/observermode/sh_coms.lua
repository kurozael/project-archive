--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

COMMAND = openAura.command:New();
COMMAND.tip = "Enter or exit observer mode.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.access = "o";

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:Alive() and !player:IsRagdolled() and !player.observerResetting) then
		if (player:GetMoveType(player) == MOVETYPE_NOCLIP) then
			PLUGIN:MakePlayerExitObserverMode(player);
		else
			PLUGIN:MakePlayerEnterObserverMode(player);
		end;
	end;
end;

openAura.command:Register(COMMAND, "Observer");