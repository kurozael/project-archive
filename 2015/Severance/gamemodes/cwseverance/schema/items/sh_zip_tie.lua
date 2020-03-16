--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Zip Tie";
ITEM.model = "models/items/crossbowrounds.mdl";
ITEM.weight = 0.2;
ITEM.useText = "Tie";
ITEM.description = "An orange zip tie with Thomas and Betts printed on the side.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player.cwIsTyingChar) then
		Clockwork.player:Notify(player, "You are already tying a character!");
		
		return false;
	else
		local trace = player:GetEyeTraceNoCursor();
		local target = Clockwork.entity:GetPlayer(trace.Entity);
		
		if (target) then
			if (target:GetSharedVar("IsTied") == 0) then
				if (target:GetShootPos():Distance(player:GetShootPos()) <= 192) then
					local canTie = (target:GetAimVector():DotProduct(player:GetAimVector()) > 0);
					local tieTime = Severance:GetDexterityTime(player);
					
					if (canTie or target:IsRagdolled()) then
						Clockwork.player:SetAction(player, "tie", tieTime);
						
						Clockwork.player:EntityConditionTimer(player, target, trace.Entity, tieTime, 192, function()
							local canTie = (target:GetAimVector():DotProduct(player:GetAimVector()) > 0);
							
							if ((canTie or target:IsRagdolled()) and player:Alive() and !player:IsRagdolled()
							and target:GetSharedVar("IsTied") == 0) then
								return true;
							end;
						end, function(success)
							if (success) then
								player.cwIsTyingChar = nil;
								Severance:TiePlayer(target, true);
								
								player:TakeItem(self);
								player:ProgressAttribute(ATB_DEXTERITY, 15, true);
							else
								player.cwIsTyingChar = nil;
							end;
							
							Clockwork.player:SetAction(player, "tie", false);
						end);
					elseif (quickHands) then
						Clockwork.player:Notify(player, "This character has quick hands, and can only be tied from the front!");
						
						return false;
					else
						Clockwork.player:Notify(player, "You cannot tie characters that are facing you!");
						
						return false;
					end;
					
					player.cwIsTyingChar = true;
					
					Clockwork.player:SetMenuOpen(player, false);
					
					return false;
				else
					Clockwork.player:Notify(player, "This character is too far away!");
					
					return false;
				end;
			else
				Clockwork.player:Notify(player, "This character is already tied!");
				
				return false;
			end;
		else
			Clockwork.player:Notify(player, "That is not a valid character!");
			
			return false;
		end;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player.cwIsTyingChar) then
		Clockwork.player:Notify(player, "You are currently tying a character!");
		
		return false;
	end;
end;

Clockwork.item:Register(ITEM);