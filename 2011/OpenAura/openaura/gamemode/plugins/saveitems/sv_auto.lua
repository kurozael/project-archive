--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

local PLUGIN = PLUGIN;

openAura:IncludePrefixed("sh_auto.lua");

-- A function to load the shipments.
function PLUGIN:LoadShipments()
	local shipments = openAura:RestoreSchemaData( "plugins/shipments/"..game.GetMap() );
	
	for k, v in pairs(shipments) do
		if ( openAura.item.stored[v.item] ) then
			local entity = openAura.entity:CreateShipment( {key = v.key, uniqueID = v.uniqueID}, v.item, v.amount, v.position, v.angles );
			
			if (IsValid(entity) and !v.moveable) then
				local physicsObject = entity:GetPhysicsObject();
				
				if ( IsValid(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
end;

-- A function to save the shipments.
function PLUGIN:SaveShipments()
	local shipments = {};
	
	for k, v in pairs( ents.FindByClass("aura_shipment") ) do
		local itemTable = v.itemTable;
		
		if (v.inventory and v.inventory[itemTable.uniqueID]
		and v.inventory[itemTable.uniqueID] > 0) then
			local physicsObject = v:GetPhysicsObject();
			local moveable;
			
			if ( IsValid(physicsObject) ) then
				moveable = physicsObject:IsMoveable();
			end;
			
			shipments[#shipments + 1] = {
				key = openAura.entity:QueryProperty(v, "key"),
				item = itemTable.uniqueID,
				amount = v.inventory[itemTable.uniqueID],
				angles = v:GetAngles(),
				moveable = moveable,
				uniqueID = openAura.entity:QueryProperty(v, "uniqueID"),
				position = v:GetPos()
			};
		end;
	end;
	
	openAura:SaveSchemaData("plugins/shipments/"..game.GetMap(), shipments);
end;

-- A function to load the items.
function PLUGIN:LoadItems()
	local items = openAura:RestoreSchemaData( "plugins/items/"..game.GetMap() );
	
	for k, v in pairs(items) do
		if ( openAura.item.stored[v.item] ) then
			local entity = openAura.entity:CreateItem( {key = v.key, uniqueID = v.uniqueID}, v.item, v.position, v.angles );
			
			if (type(v.data) == "table") then
				entity.data = v.data;
			end;
			
			if (IsValid(entity) and !v.moveable) then
				local physicsObject = entity:GetPhysicsObject();
				
				if ( IsValid(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
end;

-- A function to save the items.
function PLUGIN:SaveItems()
	local items = {};
	
	for k, v in pairs( ents.FindByClass("aura_item") ) do
		if (!v.temporary) then
			local physicsObject = v:GetPhysicsObject();
			local itemTable = v.itemTable;
			local moveable = false;
			
			if ( IsValid(physicsObject) ) then
				moveable = physicsObject:IsMoveable();
			end;
			
			items[#items + 1] = {
				key = openAura.entity:QueryProperty(v, "key"),
				item = itemTable.uniqueID,
				data = v.data,
				angles = v:GetAngles(),
				moveable = moveable,
				uniqueID = openAura.entity:QueryProperty(v, "uniqueID"),
				position = v:GetPos()
			};
		end;
	end;
	
	openAura:SaveSchemaData("plugins/items/"..game.GetMap(), items);
end;