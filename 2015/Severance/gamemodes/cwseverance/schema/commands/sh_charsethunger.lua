--[[
	© 2017 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New();
COMMAND.tip = "Set a player's Hunger Amount.";
COMMAND.text = "<string Name> <int Amount>";
COMMAND.access = "o";
COMMAND.arguments = 2;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.player:FindByID(arguments[1]);
	local amount = tonumber(arguments[2])

	if (type(amount) ~= "number") then
		Clockwork.player:Notify(player, "The entered Hunger Amount is not a number!");

		return false;
	end;

	if (target) then
		local hunger = Severance:CheckHunger(target);
		Clockwork.player:Notify(player, "You have set " .. target:Name() .. "'s hunger from " .. hunger .. " to " .. tostring(amount));
		Severance:SetHunger(target, amount);
	else
		Clockwork.player:Notify(player, arguments[1] .. " is not a valid player!");
		return false
	end;

end;
Clockwork.command:Register(COMMAND, "CharSetHunger");