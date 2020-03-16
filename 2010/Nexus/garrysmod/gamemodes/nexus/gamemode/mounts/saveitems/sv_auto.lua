--[[
Name: "sv_auto.lua".
Product: "nexus".
--]]

local MOUNT = MOUNT;

NEXUS:IncludePrefixed("sh_auto.lua");

-- A function to load the shipments.
function MOUNT:LoadShipments()
	local shipments = NEXUS:RestoreSchemaData( "mounts/shipments/"..game.GetMap() );
	
	for k, v in pairs(shipments) do
		if ( nexus.item.GetAll()[v.item] ) then
			local entity = nexus.entity.CreateShipment( {key = v.key, uniqueID = v.uniqueID}, v.item, v.amount, v.position, v.angles );
			
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
function MOUNT:SaveShipments()
	local shipments = {};
	
	for k, v in pairs( ents.FindByClass("nx_shipment") ) do
		local item = v.item;
		
		if (v.inventory) then
			if (v.inventory[item.uniqueID] and v.inventory[item.uniqueID] > 0) then
				local physicsObject = v:GetPhysicsObject();
				local moveable;
				
				if ( IsValid(physicsObject) ) then
					moveable = physicsObject:IsMoveable();
				end;
				
				shipments[#shipments + 1] = {
					key = nexus.entity.QueryProperty(v, "key"),
					item = item.uniqueID,
					amount = v.inventory[item.uniqueID],
					angles = v:GetAngles(),
					moveable = moveable,
					uniqueID = nexus.entity.QueryProperty(v, "uniqueID"),
					position = v:GetPos()
				};
			end;
		end;
	end;
	
	NEXUS:SaveSchemaData("mounts/shipments/"..game.GetMap(), shipments);
end;

-- A function to load the items.
function MOUNT:LoadItems()
	local items = NEXUS:RestoreSchemaData( "mounts/items/"..game.GetMap() );
	
	for k, v in pairs(items) do
		if ( nexus.item.GetAll()[v.item] ) then
			local entity = nexus.entity.CreateItem( {key = v.key, uniqueID = v.uniqueID}, v.item, v.position, v.angles );
			
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
function MOUNT:SaveItems()
	local items = {};
	
	for k, v in pairs( ents.FindByClass("nx_item") ) do
		if (!v.temporary) then
			local physicsObject = v:GetPhysicsObject();
			local moveable;
			
			if ( IsValid(physicsObject) ) then
				moveable = physicsObject:IsMoveable();
			end;
			
			items[#items + 1] = {
				key = nexus.entity.QueryProperty(v, "key"),
				item = v.item.uniqueID,
				data = v.data,
				angles = v:GetAngles(),
				moveable = moveable,
				uniqueID = nexus.entity.QueryProperty(v, "uniqueID"),
				position = v:GetPos()
			};
		end;
	end;
	
	NEXUS:SaveSchemaData("mounts/items/"..game.GetMap(), items);
end;