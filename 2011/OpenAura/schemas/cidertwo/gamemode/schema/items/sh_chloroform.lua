--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Chloroform";
ITEM.cost = 8;
ITEM.model = "models/props_junk/garbage_newspaper001a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.1;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.useText = "Knock Out";
ITEM.business = true;
ITEM.description = "Using this on somebody will knock them out cold.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player.isChloroforming) then
		openAura.player:Notify(player, "You are already tying a character!");
		
		return false;
	else
		local trace = player:GetEyeTraceNoCursor();
		local target = openAura.entity:GetPlayer(trace.Entity);
		
		if ( target and target:Alive() ) then
			if (target:GetShootPos():Distance( player:GetShootPos() ) <= 192) then
				local canChloroform = (target:GetAimVector():DotProduct( player:GetAimVector() ) > 0);
				local chloroformTime = openAura.schema:GetDexterityTime(player);
				
				if ( canChloroform or target:IsRagdolled() ) then
					openAura.player:SetAction(player, "chloroform", chloroformTime);
					
					target:SetSharedVar("beingChloro", true);
					
					openAura.player:EntityConditionTimer(player, target, trace.Entity, chloroformTime, 192, function()
						local canChloroform = (target:GetAimVector():DotProduct( player:GetAimVector() ) > 0);
						
						if ( ( canChloroform or target:IsRagdolled() ) and player:Alive() and !player:IsRagdolled() ) then
							return true;
						end;
					end, function(success)
						if (success) then
							player.isChloroforming = nil;
							
							openAura.player:SetRagdollState(target, RAGDOLL_KNOCKEDOUT, 60);
							
							player:UpdateInventory("chloroform", -1);
							player:ProgressAttribute(ATB_DEXTERITY, 15, true);
						else
							player.isChloroforming = nil;
						end;
						
						openAura.player:SetAction(player, "chloroform", false);
						
						if ( IsValid(target) ) then
							target:SetSharedVar("beingChloro", false);
						end;
					end);
				else
					openAura.player:Notify(player, "You cannot use chloroform characters that are facing you!");
					
					return false;
				end;
				
				openAura.player:SetMenuOpen(player, false);
				
				player.isChloroforming = true;
				
				return false;
			else
				openAura.player:Notify(player, "This character is too far away!");
				
				return false;
			end;
		else
			openAura.player:Notify(player, "That is not a valid character!");
			
			return false;
		end;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);