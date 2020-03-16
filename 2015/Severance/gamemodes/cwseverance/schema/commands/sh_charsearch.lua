--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New();
COMMAND.tip = "Search a character if they are tied.";
COMMAND.flags = CMD_DEFAULT;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	local target = Clockwork.entity:GetPlayer(player:GetEyeTraceNoCursor().Entity);
	
	if (target) then
		if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
			if (player:GetSharedVar("IsTied") == 0) then
				if (target:GetSharedVar("IsTied") != 0) then
					if (target:GetVelocity():Length() == 0) then
						if (!player.cwIsSearchingChar) then
							target.cwIsBeingSearched = true;
							player.cwIsSearchingChar = target;
							
							Clockwork.storage:Open(player, {
								name = Clockwork.player:FormatRecognisedText(player, "%s", target),
								weight = target:GetMaxWeight(),
								entity = target,
								distance = 192,
								cash = target:GetCash(),
								inventory = target:GetInventory(),
								OnClose = function(player, storageTable, entity)
									player.cwIsSearchingChar = nil;
									
									if (IsValid(entity)) then
										entity.cwIsBeingSearched = nil;
									end;
								end
							});
						else
							Clockwork.player:Notify(player, "You are already searching a character!");
						end;
					else
						Clockwork.player:Notify(player, "You cannot search a moving character!");
					end;
				else
					Clockwork.player:Notify(player, "This character is not tied!");
				end;
			else
				Clockwork.player:Notify(player, "You cannot do this action at the moment!");
			end;
		else
			Clockwork.player:Notify(player, "This character is too far away!");
		end;
	else
		Clockwork.player:Notify(player, "You must look at a character!");
	end;
end;

Clockwork.command:Register(COMMAND, "CharSearch");