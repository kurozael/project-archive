--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

local COMMAND = Clockwork.command:New();
COMMAND.tip = "Heal a character if you own a medical item.";
COMMAND.text = "<string Item>";
COMMAND.flags = CMD_DEFAULT;
COMMAND.arguments = 1;

-- Called when the command has been run.
function COMMAND:OnRun(player, arguments)
	if (player:GetSharedVar("IsTied") == 0) then
		local bIsHealed = false;
		local entity = player:GetEyeTraceNoCursor().Entity;
		local target = Clockwork.entity:GetPlayer(entity);
		
		if (target) then
			if (entity:GetPos():Distance(player:GetShootPos()) <= 192) then
				local itemTable = player:FindItemByID(arguments[1]);
				
				if (!itemTable) then
					Clockwork.player:Notify("You do not own this item!");
					return;
				end;
				
				if (arguments[1] == "health_vial") then
					target:SetHealth(math.Clamp(target:Health() + Severance:GetHealAmount(player, 1.5), 0, target:GetMaxHealth()));
					target:EmitSound("items/medshot4.wav");
					player:TakeItem(itemTable);
					bIsHealed = true;
				elseif (arguments[1] == "health_kit") then
					target:SetHealth(math.Clamp(target:Health() + Severance:GetHealAmount(player, 2), 0, target:GetMaxHealth()));
					target:EmitSound("items/medshot4.wav");
					player:TakeItem(itemTable);
					bIsHealed = true;
				elseif (arguments[1] == "bandage") then
					target:SetHealth(math.Clamp(target:Health() + Severance:GetHealAmount(player), 0, target:GetMaxHealth()));
					target:EmitSound("items/medshot4.wav");
					player:TakeItem(itemTable);
					bIsHealed = true;
				else
					Clockwork.player:Notify(player, "This is not a valid item!");
				end;
				
				if (bIsHealed) then
					Clockwork.plugin:Call("PlayerHealed", target, player, itemTable);
					
					if (Clockwork.player:GetAction(target) == "die") then
						Clockwork.player:SetRagdollState(target, RAGDOLL_NONE);
					end;
					
					player:FakePickup(target);
				end;
			else
				Clockwork.player:Notify(player, "This character is too far away!");
			end;
		else
			Clockwork.player:Notify(player, "You must look at a character!");
		end;
	else
		Clockwork.player:Notify(player, "You cannot do this action at the moment!");
	end;
end;

Clockwork.command:Register(COMMAND, "CharHeal");