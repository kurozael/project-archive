--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Prop Guarder";
ITEM.cost = 300;
ITEM.batch = 1;
ITEM.model = "models/props_combine/breenglobe.mdl";
ITEM.weight = 2;
ITEM.business = true;
ITEM.category = "Guarders";
ITEM.description = "When placed near props it will reduce the damage they take by half.\nThis is not permanent and can be destroyed by others.";

-- Called when the item's shipment entity should be created.
function ITEM:OnCreateShipmentEntity(player, batch, position)
	local entity = ents.Create("aura_propguarder");
	
	openAura.player:GiveProperty(player, entity, true);
	
	entity:SetAngles( Angle(0, 0, 0 ) );
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
	if (openAura.player:GetPropertyCount(player, "aura_propguarder") >= 1) then
		openAura.player:Notify(player, "You cannot create anymore of these!");
		
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (openAura.player:GetPropertyCount(player, "aura_propguarder") >= 1) then
		openAura.player:Notify(player, "You cannot create anymore of these!");
		
		return false;
	end;
end;

openAura.item:Register(ITEM);