--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Door Guarder";
ITEM.cost = 200;
ITEM.batch = 1;
ITEM.model = "models/props_combine/breenglobe.mdl";
ITEM.weight = 2;
ITEM.business = true;
ITEM.category = "Entities";
ITEM.description = "When placed near doors it will prevent them from being shot open.\nThis is not permanent and can be destroyed by others.\n<color=255,100,100>You will also be notified when one has been shot or breached!</color>";

-- Called when the item's shipment entity should be created.
function ITEM:OnCreateShipmentEntity(player, batch, position)
	local entity = ents.Create("cw_door_guarder");
		Clockwork.player:GiveProperty(player, entity, true);
	entity:SetAngles(Angle(0, 0, 0));
	entity:SetPos(position);
	entity:Spawn();
	
	return entity;
end;

-- Called when the item's drop entity should be created.
function ITEM:OnCreateDropEntity(player, position)
	return self:OnCreateShipmentEntity(player, 1, position);
end;

-- Called when a player attempts to order the item.
function ITEM:CanOrder(player)
	if (Clockwork.player:GetPropertyCount(player, "cw_door_guarder") >= 1) then
		Clockwork.player:Notify(player, "You cannot create anymore of these!");
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (Clockwork.player:GetPropertyCount(player, "cw_door_guarder") >= 1) then
		Clockwork.player:Notify(player, "You cannot create anymore of these!");
		return false;
	end;
end;

Clockwork.item:Register(ITEM);