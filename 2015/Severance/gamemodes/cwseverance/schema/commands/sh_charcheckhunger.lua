--[[
	© 2017 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New();
COMMAND.tip = "Check a player's Hunger Amount.";
COMMAND.text = "<string Name>";
COMMAND.access = "o";
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local hunger = Severance:CheckHunger(target);

	if (target) then
		Clockwork.player:Notify(player, target:Name() .. "'s hunger is currently " .. hunger);
	else
		Clockwork.player:Notify(player, arguments[1] .. " is not a valid player!");
	end;

end;
Clockwork.command:Register(COMMAND, "CharCheckHunger");