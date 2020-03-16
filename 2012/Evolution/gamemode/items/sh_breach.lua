--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Breach";
ITEM.batch = 3;
ITEM.cost = (200 * 0.5);
ITEM.model = "models/props_wasteland/prison_padlock001a.mdl";
ITEM.weight = 0.3;
ITEM.useText = "Place";
ITEM.business = true;
ITEM.category = "Disposables";
ITEM.description = "A small device which looks similiar to a padlock.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	local traceLine = player:GetEyeTraceNoCursor();
	local entity = traceLine.Entity;
	
	if (IsValid(entity)) then
		if (entity:GetPos():Distance(player:GetShootPos()) <= 192) then
			if (Clockwork.plugin:Call("PlayerCanBreachEntity", player, entity)) then
				local breach = ents.Create("cw_breach");
				breach:Spawn();
				
				if (IsValid(entity.cwBreachEnt)) then
					entity.cwBreachEnt:Explode();
					entity.cwBreachEnt:Remove();
				end;
				
				breach:SetBreachEntity(entity, traceLine);
			else
				Clockwork.player:Notify(player, "This entity cannot be breached!");
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