--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Breach";
ITEM.cost = 5;
ITEM.model = "models/props_wasteland/prison_padlock001a.mdl";
ITEM.weight = 0.3;
ITEM.classes = {CLASS_BLACKMARKET, CLASS_DISPENSER};
ITEM.useText = "Place";
ITEM.business = true;
ITEM.description = "A small device which looks similiar to a padlock.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local trace = player:GetEyeTraceNoCursor();
	local entity = trace.Entity;
	
	if (IsValid(entity)) then
		if (entity:GetPos():Distance(player:GetShootPos()) <= 192) then
			if (!IsValid(entity.cwBreachEnt)) then
				if (Clockwork.plugin:Call("PlayerCanBreachEntity", player, entity)) then
					local breach = ents.Create("cw_breach"); breach:Spawn();
					
					breach:SetBreachEntity(entity, trace);
				else
					Clockwork.player:Notify(player, "This entity cannot be breached!");
					
					return false;
				end;
			else
				Clockwork.player:Notify(player, "This entity already has a breach!");
				
				return false;
			end;
		else
			Clockwork.player:Notify(player, "You are not close enough to the entity!");
			
			return false;
		end;
	else
		Clockwork.player:Notify(player, "That is not a valid entity!");
		
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);