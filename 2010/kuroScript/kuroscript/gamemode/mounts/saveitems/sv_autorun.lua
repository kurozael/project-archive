--[[
Name: "sv_autorun.lua".
Product: "kuroScript".
--]]

local MOUNT = MOUNT;

-- Include some prefixed files.
kuroScript.frame:IncludePrefixed("sh_autorun.lua");

-- A function to load the shipments.
function MOUNT:LoadShipments()
	local shipments = kuroScript.frame:RestoreGameData( "mounts/shipments/"..game.GetMap() );
	
	-- Loop through each value in a table.
	for k, v in pairs(shipments) do
		if ( kuroScript.item.stored[v.item] ) then
			local entity = kuroScript.entity.CreateShipment( {key = v.key, uniqueID = v.uniqueID}, v.item, v.amount, v.position, v.angles );
			
			-- Check if a statement is true.
			if (ValidEntity(entity) and !v.moveable) then
				local physicsObject = entity:GetPhysicsObject();
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
end;

-- A function to save the shipments.
function MOUNT:SaveShipments()
	local shipments = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_shipment") ) do
		local item = v._Item;
		
		-- Check if a statement is true.
		if (v._Inventory) then
			if (v._Inventory[item.uniqueID] and v._Inventory[item.uniqueID] > 0) then
				local physicsObject = v:GetPhysicsObject();
				local moveable;
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					moveable = physicsObject:IsMoveable();
				end;
				
				-- Set some information.
				shipments[#shipments + 1] = {
					key = kuroScript.entity.QueryProperty(v, "key"),
					item = item.uniqueID,
					amount = v._Inventory[item.uniqueID],
					angles = v:GetAngles(),
					moveable = moveable,
					uniqueID = kuroScript.entity.QueryProperty(v, "uniqueID"),
					position = v:GetPos()
				};
			end;
		end;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/shipments/"..game.GetMap(), shipments);
end;

-- A function to load the items.
function MOUNT:LoadItems()
	local items = kuroScript.frame:RestoreGameData( "mounts/items/"..game.GetMap() );
	
	-- Loop through each value in a table.
	for k, v in pairs(items) do
		if ( kuroScript.item.stored[v.item] ) then
			local entity = kuroScript.entity.CreateItem( {key = v.key, uniqueID = v.uniqueID}, v.item, v.position, v.angles );
			
			-- Check if a statement is true.
			if (ValidEntity(entity) and !v.moveable) then
				local physicsObject = entity:GetPhysicsObject();
				
				-- Check if a statement is true.
				if ( ValidEntity(physicsObject) ) then
					physicsObject:EnableMotion(false);
				end;
			end;
		end;
	end;
end;

-- A function to save the items.
function MOUNT:SaveItems()
	local items = {};
	
	-- Loop through each value in a table.
	for k, v in pairs( ents.FindByClass("ks_item") ) do
		if (!v._Temporary) then
			local physicsObject = v:GetPhysicsObject();
			local moveable;
			
			-- Check if a statement is true.
			if ( ValidEntity(physicsObject) ) then
				moveable = physicsObject:IsMoveable();
			end;
			
			-- Set some information.
			items[#items + 1] = {
				key = kuroScript.entity.QueryProperty(v, "key"),
				item = v._Item.uniqueID,
				angles = v:GetAngles(),
				moveable = moveable,
				uniqueID = kuroScript.entity.QueryProperty(v, "uniqueID"),
				position = v:GetPos()
			};
		end;
	end;
	
	-- Save some game data.
	kuroScript.frame:SaveGameData("mounts/items/"..game.GetMap(), items);
end;