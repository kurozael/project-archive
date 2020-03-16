--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Sign Post";
ITEM.cost = (100 * 0.5);
ITEM.batch = 1;
ITEM.model = "models/props_trainstation/tracksign07.mdl";
ITEM.weight = 3;
ITEM.business = true;
ITEM.category = "Entities";
ITEM.description = "A sign that can have three dimensional text written to it.\nThis is not permanent and can be destroyed by others.\n<color=255,100,100>The sign cannot be written on twice, and can be destroyed!</color>";

-- Called when the item's shipment entity should be created.
function ITEM:OnCreateShipmentEntity(player, batch, position)
	local entity = ents.Create("cw_sign_post");
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

Clockwork.item:Register(ITEM);