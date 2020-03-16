--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Explomine";
ITEM.cost = 100;
ITEM.batch = 1;
ITEM.model = "models/props_combine/combine_mine01.mdl";
ITEM.weight = 2;
ITEM.business = true;
ITEM.category = "Landmines";
ITEM.description = "When another character touches it, it will deal explosion damage to them.\nThis is not permanent and can be destroyed by others.";
ITEM.requiresExplosives = true;

-- Called when the item's shipment entity should be created.
function ITEM:OnCreateShipmentEntity(player, batch, position)
	local entity = ents.Create("aura_explomine");
	
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
	local trace = player:GetEyeTraceNoCursor();
	
	for k, v in ipairs( ents.FindInSphere(trace.HitPos, 128) ) do
		if (v:IsPlayer() and player != v) then
			openAura.player:Notify(player, "You cannot order a landmine near another character!");
			
			return false;
		end;
	end;
	
	local totalMines = 0;
	
	totalMines = totalMines + openAura.player:GetPropertyCount(player, "aura_freezemine");
	totalMines = totalMines + openAura.player:GetPropertyCount(player, "aura_explomine");
	totalMines = totalMines + openAura.player:GetPropertyCount(player, "aura_firemine");
	
	if (totalMines >= 3) then
		openAura.player:Notify(player, "You have reached the maximum amount of landmines!");
		
		return false;
	end;
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	local totalMines = 0;
	
	totalMines = totalMines + openAura.player:GetPropertyCount(player, "aura_freezemine");
	totalMines = totalMines + openAura.player:GetPropertyCount(player, "aura_explomine");
	totalMines = totalMines + openAura.player:GetPropertyCount(player, "aura_firemine");
	
	if (totalMines >= 3) then
		openAura.player:Notify(player, "You have reached the maximum amount of landmines!");
		
		return false;
	end;
end;

openAura.item:Register(ITEM);