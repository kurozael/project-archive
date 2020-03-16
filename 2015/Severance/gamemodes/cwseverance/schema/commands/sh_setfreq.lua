--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New();
COMMAND.tip = "Set your radio frequency, or a stationary radio's frequency.";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local radioEntity = nil;
	local trace = player:GetEyeTraceNoCursor();
	
	if (IsValid(trace.Entity) and trace.Entity:GetClass() == "cw_radio") then
		if (trace.HitPos:Distance(player:GetShootPos()) > 192) then
			Clockwork.player:Notify(player, "This stationary radio is too far away!");
			return;
		else
			radioEntity = trace.Entity;
		end;
	end;
	
	local frequency = arguments[1];
	
	if (string.find(frequency, "^%d%d%d%.%d$")) then
		local start, finish, decimal = string.match(frequency, "(%d)%d(%d)%.(%d)");
		start = tonumber(start); finish = tonumber(finish); decimal = tonumber(decimal);
		
		if ( !player:HasItemByID("handheld_radio") ) then
			Clockwork.player:Notify(player, "You do not own a radio item!");
			return;
		end;
		
		if (start == 1 and finish > 0 and finish < 10 and decimal > 0 and decimal < 10) then
			if (radioEntity) then
				radioEntity:SetFrequency(frequency);
				Clockwork.player:Notify(player, "You have set this stationary radio's frequency to "..frequency..".");
			else
				player:SetCharacterData("Frequency", frequency);
				Clockwork.player:Notify(player, "You have set your radio frequency to "..frequency..".");
			end;
		else
			Clockwork.player:Notify(player, "The radio frequency must be between 101.1 and 199.9!");
		end;
	else
		Clockwork.player:Notify(player, "The radio frequency must look like xxx.x!");
	end;
end;

Clockwork.command:Register(COMMAND, "SetFreq");