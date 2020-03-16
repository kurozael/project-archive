--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Zip Tie";
ITEM.cost = (150 * 0.5);
ITEM.batch = 3;
ITEM.model = "models/items/crossbowrounds.mdl";
ITEM.weight = 0.1;
ITEM.useText = "Tie";
ITEM.business = true;
ITEM.category = "Disposables";
ITEM.description = "An orange zip tie with Thomas and Betts printed on the side.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player.cwIsTyingChar) then
		Clockwork.player:Notify(player, "You are already tying a character!");
		return false;
	end;
	
	local traceLine = player:GetEyeTraceNoCursor();
	local target = Clockwork.entity:GetPlayer(traceLine.Entity);
	
	if (!target or !target:Alive()) then
		Clockwork.player:Notify(player, "That is not a valid character!");
		return false;
	end;
	
	if (Schema:IsInSafeZone(target)) then
		Clockwork.player:Notify(player, "This character is in a Safe Zone!");
		return false;
	end;
	
	if (target:GetSharedVar("IsTied")) then
		Clockwork.player:RunClockworkCommand(player, "CharSearch");
		return false;
	end;
	
	if (target:GetShootPos():Distance(player:GetShootPos()) > 192) then
		Clockwork.player:Notify(player, "That character is too far away!");
		return false;
	end;
	
	local canTie = (target:GetAimVector():DotProduct(player:GetAimVector()) > 0);
	local tieTime = Schema:GetDexterityTime(player);
	
	if (canTie or target:IsRagdolled()) then
		Clockwork.player:SetAction(player, "tie", tieTime);
		
		target:SetSharedVar("BeingTied", true);
		
		Clockwork.player:EntityConditionTimer(player, target, traceLine.Entity, tieTime, 192, function()
			local canTie = (target:GetAimVector():DotProduct(player:GetAimVector()) > 0);
			
			if ((canTie or target:IsRagdolled()) and player:Alive() and !player:IsRagdolled()
			and !target:GetSharedVar("IsTied")) then
				return true;
			end;
		end, function(success)
			if (success) then
				player.cwIsTyingChar = nil;
				
				Schema:TiePlayer(target, true);
					player:TakeItem(self);
				player:ProgressAttribute(ATB_DEXTERITY, 15, true);
			else
				player.cwIsTyingChar = nil;
			end;
			
			Clockwork.player:SetAction(player, "tie", false);
			
			if (IsValid(target)) then
				target:SetSharedVar("BeingTied", false);
			end;
		end);
	else
		Clockwork.player:Notify(player, "You cannot tie characters that are facing you!");
		return false;
	end;
	
	Clockwork.player:SetMenuOpen(player, false);
	player.cwIsTyingChar = true;
	
	return false;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player.cwIsTyingChar) then
		Clockwork.player:Notify(player, "You are currently tying a character!");
		return false;
	end;
end;

Clockwork.item:Register(ITEM);