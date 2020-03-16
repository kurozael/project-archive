--[[
Name: "sh_item.lua".
Product: "kuroScript".
--]]

kuroScript.item = {};
kuroScript.item.stored = {};
kuroScript.item.buffer = {};

-- A function to register a new item.
function kuroScript.item.Register(item)
	if (!item.plural) then
		if ( string.sub(item.name, -1) != "s" ) then
			item.plural = item.name.."s";
		else
			item.plural = item.name;
		end;
	end;
	
	-- Set some information.
	item.uniqueID = string.lower( string.gsub(item.uniqueID or string.gsub(item.name, "%s", "_"), "'", "") );
	item.index = kuroScript.frame:GetShortCRC(item.uniqueID);
	
	-- Set some information.
	kuroScript.item.stored[item.uniqueID] = item;
	kuroScript.item.buffer[item.index] = item;
end;

-- A function to get whether an item is based from an item.
function kuroScript.item.IsBasedFrom(name, base)
	local itemTable = kuroScript.item.Get(name);
	
	-- Loop while a statement is true.
	while (itemTable and itemTable.base) do
		if (itemTable.base != base) then
			itemTable = kuroScript.item.Get(itemTable.base);
		else
			return true;
		end;
	end;
end;

-- A function to a weapon item by its object.
function kuroScript.item.GetWeapon(weapon, uniqueID)
	local class = weapon;
	
	-- Check if a statement is true.
	if (type(weapon) != "string") then
		class = weapon:GetClass();
		uniqueID = weapon:GetNetworkedString("ks_UniqueID");
	end;
	
	-- Set some information.
	local itemTable = kuroScript.item.stored[class];
	
	-- Check if a statement is true.
	if (uniqueID == "") then
		uniqueID = nil;
	end;
	
	-- Check if a statement is true.
	if (itemTable and itemTable.weaponClass == class and itemTable.uniqueID == uniqueID) then
		return itemTable;
	else
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.item.stored) do
			if (v.weaponClass == class and v.uniqueID == uniqueID) then
				return v;
			end;
		end;
	end;
end;

-- A function to get an item by its name.
function kuroScript.item.Get(name)
	if (name and type(name) != "boolean") then
		if ( kuroScript.item.buffer[name] ) then
			return kuroScript.item.buffer[name];
		elseif ( kuroScript.item.stored[name] ) then
			return kuroScript.item.stored[name];
		else
			local lowerName = string.lower(name);
			local item;
			
			-- Loop through each value in a table.
			for k, v in pairs(kuroScript.item.stored) do
				if ( string.find(string.lower(v.name), lowerName) ) then
					if ( !item or string.len(v.name) < string.len(item.name) ) then
						item = v;
					end;
				end;
			end;
			
			-- Return the item.
			return item;
		end;
	end;
end;

-- A function to merge an item with a base item.
function kuroScript.item.Merge(item, base, temporary)
	local baseTable = kuroScript.item.Get(base);
	
	-- Check if a statement is true.
	if (baseTable) then
		local baseTableCopy = table.Copy(baseTable);
		
		-- Check if a statement is true.
		if (baseTableCopy.base) then
			baseTableCopy = kuroScript.item.Merge(baseTableCopy, baseTable.base, true);
			
			-- Check if a statement is true.
			if (!baseTableCopy) then
				return;
			end;
		end;
		
		-- Merge some information.
		table.Merge(baseTableCopy, item);
		
		-- Check if a statement is true.
		if (!temporary) then
			baseTableCopy.baseClass = baseTable;
			
			-- Register the item.
			kuroScript.item.Register(baseTableCopy);
		end;
		
		-- Return the base table copy.
		return baseTableCopy;
	end;
end;

-- Check if a statement is true.
if (SERVER) then
	function kuroScript.item.Use(player, item, soundless)
		local itemTable = kuroScript.item.Get(item);
		local itemEntity = player:GetItemEntity();
		
		-- Check if a statement is true.
		if (itemTable) then
			item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if (kuroScript.inventory.HasItem(player, item) and kuroScript.inventory.HasItem(player, item) > 0) then
				if (itemTable.OnUse) then
					if (itemEntity) then
						player:SetItemEntity(nil);
					end;
					
					-- Set some information.
					local onUse = itemTable:OnUse(player, itemEntity);
					
					-- Check if a statement is true.
					if (onUse == false) then
						return;
					elseif (onUse != true) then
						if (itemEntity) then
							kuroScript.inventory.Update(player, item, -1, nil, true);
						else
							kuroScript.inventory.Update(player, item, -1);
						end;
					end;
					
					-- Check if a statement is true.
					if (!soundless) then
						if (itemTable.useSound) then
							player:EmitSound(itemTable.useSound);
						elseif (itemTable.useSound != false) then
							player:EmitSound("items/battery_pickup.wav");
						end;
					end;
					
					-- Call a gamemode hook.
					hook.Call("PlayerUseItem", kuroScript.frame, player, itemTable);
					
					-- Return true to break the function.
					return true;
				end;
			end;
		end;
		
		-- Return false to break the function.
		return false;
	end;
	
	-- A function to drop an item from a player.
	function kuroScript.item.Drop(player, item, position, soundless)
		local itemTable = kuroScript.item.Get(item);
		local entity;
		local trace;
		
		-- Check if a statement is true.
		if (itemTable) then
			item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if (kuroScript.inventory.HasItem(player, item) and kuroScript.inventory.HasItem(player, item) > 0) then
				if (!position) then
					trace = player:GetEyeTraceNoCursor(); position = trace.HitPos
				end;
				
				-- Check if a statement is true.
				if (itemTable.OnDrop) then
					if (itemTable:OnDrop(player, position) == false) then
						return false;
					end;
					
					-- Update the player's inventory.
					kuroScript.inventory.Update(player, item, -1);
					
					-- Check if a statement is true.
					if (itemTable.OnCreateDropEntity) then
						entity = itemTable:OnCreateDropEntity(player, position);
					end;
					
					-- Check if a statement is true.
					if ( !ValidEntity(entity) ) then
						entity = kuroScript.entity.CreateItem(player, item, position);
					end;
					
					-- Check if a statement is true.
					if ( ValidEntity(entity) ) then
						if (trace and trace.HitNormal) then
							kuroScript.entity.MakeFlushToGround(entity, position, trace.HitNormal);
						end;
					end;
					
					-- Check if a statement is true.
					if (!soundless) then
						if (itemTable.dropSound) then
							player:EmitSound(itemTable.dropSound);
						elseif (itemTable.dropSound != false) then
							player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
						end;
					end;
					
					-- Call a gamemode hook.
					hook.Call("PlayerDropItem", kuroScript.frame, player, itemTable, position);
					
					-- Return true to break the function.
					return true;
				end;
			end;
		end;
		
		-- Return false to break the function.
		return false;
	end;
	
	-- A function to destroy a player's item.
	function kuroScript.item.Destroy(player, item, soundless)
		local itemTable = kuroScript.item.Get(item);
		
		-- Check if a statement is true.
		if (itemTable) then
			item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if (kuroScript.inventory.HasItem(player, item) and kuroScript.inventory.HasItem(player, item) > 0) then
				if (itemTable.OnDestroy) then
					if ( itemTable:OnDestroy(player) == false ) then
						return false;
					end;
					
					-- Update the player's inventory.
					kuroScript.inventory.Update(player, item, -1);
					
					-- Check if a statement is true.
					if (!soundless) then
						if (itemTable.destroySound) then
							player:EmitSound(itemTable.destroySound);
						elseif (itemTable.destroySound != false) then
							player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
						end;
					end;
					
					-- Call a gamemode hook.
					hook.Call("PlayerDestroyItem", kuroScript.frame, player, itemTable);
					
					-- Return true to break the function.
					return true;
				end;
			end;
		end;
	end;
	
	-- Return false to break the function.
	return false;
end;