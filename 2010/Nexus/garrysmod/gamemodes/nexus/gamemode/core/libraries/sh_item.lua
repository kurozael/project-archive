--[[
Name: "sh_item.lua".
Product: "nexus".
--]]

nexus.item = {};
nexus.item.stored = {};
nexus.item.buffer = {};

-- A function to get the item buffer.
function nexus.item.GetBuffer()
	return nexus.item.buffer;
end;

-- A function to get all items.
function nexus.item.GetAll()
	return nexus.item.stored;
end;

-- A function to register a new item.
function nexus.item.Register(item)
	if (!item.plural) then
		if ( string.sub(item.name, -1) != "s" ) then
			item.plural = item.name.."s";
		else
			item.plural = item.name;
		end;
	end;
	
	item.uniqueID = string.lower( string.gsub(item.uniqueID or string.gsub(item.name, "%s", "_"), "['%.]", "") );
	item.index = NEXUS:GetShortCRC(item.uniqueID);
	
	nexus.item.GetAll()[item.uniqueID] = item;
	nexus.item.GetBuffer()[item.index] = item;
end;

-- A function to get whether an item is a weapon.
function nexus.item.IsWeapon(itemTable)
	if (itemTable) then
		if ( nexus.item.IsBasedFrom(itemTable.uniqueID, "weapon_base") ) then
			return true;
		end;
	end;
	
	return false;
end;

-- A function to get whether an item is based from an item.
function nexus.item.IsBasedFrom(name, base)
	local itemTable = nexus.item.Get(name);
	
	while (itemTable and itemTable.base) do
		if (itemTable.base != base) then
			itemTable = nexus.item.Get(itemTable.base);
		else
			return true;
		end;
	end;
end;

-- A function to a weapon item by its object.
function nexus.item.GetWeapon(weapon, uniqueID)
	local class = weapon;
	
	if (type(class) != "string") then
		class = weapon:GetClass();
		uniqueID = weapon:GetNetworkedString("sh_UniqueID");
	end;
	
	local itemTable = nexus.item.GetAll()[class];
	
	if (uniqueID == "") then
		uniqueID = nil;
	end;
	
	if ( nexus.item.IsWeapon(itemTable) ) then
		if (itemTable.uniqueID == uniqueID) then
			return itemTable;
		end;
	end;
	
	for k, v in pairs( nexus.item.GetAll() ) do
		if (nexus.item.IsWeapon(v) and v.uniqueID == uniqueID) then
			if (v.weaponClass == class) then
				return v;
			end;
		end;
	end;
end;

-- A function to get an item by its name.
function nexus.item.Get(name)
	if (name and name != 0 and type(name) != "boolean") then
		if ( nexus.item.GetBuffer()[name] ) then
			return nexus.item.GetBuffer()[name];
		elseif ( nexus.item.GetAll()[name] ) then
			return nexus.item.GetAll()[name];
		else
			local lowerName = string.lower(name);
			local item;
			
			for k, v in pairs( nexus.item.GetAll() ) do
				if ( string.find(string.lower(v.name), lowerName) ) then
					if ( !item or string.len(v.name) < string.len(item.name) ) then
						item = v;
					end;
				end;
			end;
			
			return item;
		end;
	end;
end;

-- A function to merge an item with a base item.
function nexus.item.Merge(item, base, temporary)
	local baseTable = nexus.item.Get(base);
	local isBaseItem = item.isBaseItem;
	
	if (baseTable) then
		local baseTableCopy = table.Copy(baseTable);
		
		if (baseTableCopy.base) then
			baseTableCopy = nexus.item.Merge(baseTableCopy, baseTable.base, true);
			
			if (!baseTableCopy) then
				return;
			end;
		end;
		
		table.Merge(baseTableCopy, item);
		
		if (!temporary) then
			baseTableCopy.baseClass = baseTable;
			baseTableCopy.isBaseItem = isBaseItem;
			
			nexus.item.Register(baseTableCopy);
		end;
		
		return baseTableCopy;
	end;
end;

if (SERVER) then
	function nexus.item.Use(player, item, soundless)
		local itemTable = nexus.item.Get(item);
		local itemEntity = player:GetItemEntity();
		
		if (itemTable) then
			local uniqueID = itemTable.uniqueID;
			local hasItem = player:HasItem(uniqueID);
			
			if (hasItem and hasItem > 0) then
				if (itemTable.OnUse) then
					if (itemEntity and itemEntity.item) then
						if (uniqueID == itemEntity.item.uniqueID) then
							player:SetItemEntity(nil);
						end;
					end;
					
					local onUse = itemTable:OnUse(player, itemEntity);
					
					if (onUse == false) then
						return;
					elseif (onUse != true) then
						if (itemEntity) then
							player:UpdateInventory(uniqueID, -1, nil, true);
						else
							player:UpdateInventory(uniqueID, -1);
						end;
					end;
					
					if (!soundless) then
						if (itemTable.useSound) then
							if (type(itemTable.useSound) == "table") then
								player:EmitSound( itemTable.useSound[ math.random(1, #itemTable.useSound) ] );
							else
								player:EmitSound(itemTable.useSound);
							end;
						elseif (itemTable.useSound != false) then
							player:EmitSound("items/battery_pickup.wav");
						end;
					end;
					
					nexus.mount.Call("PlayerUseItem", player, itemTable, itemEntity);
					
					return true;
				end;
			end;
		end;
	end;
	
	-- A function to drop an item from a player.
	function nexus.item.Drop(player, item, position, soundless, noTake)
		local itemTable = nexus.item.Get(item);
		local entity = nil;
		local trace = nil;
		
		if (itemTable) then
			local uniqueID = itemTable.uniqueID;
			local hasItem = player:HasItem(uniqueID);
			
			if ( noTake or (hasItem and hasItem > 0) ) then
				if (!position) then
					trace = player:GetEyeTraceNoCursor();
					position = trace.HitPos
				end;
				
				if (itemTable.OnDrop) then
					if (itemTable:OnDrop(player, position) == false) then
						return;
					end;
					
					if (!noTake) then
						player:UpdateInventory(uniqueID, -1);
					end;
					
					if (itemTable.OnCreateDropEntity) then
						entity = itemTable:OnCreateDropEntity(player, position);
					end;
					
					if ( !IsValid(entity) ) then
						entity = nexus.entity.CreateItem(player, uniqueID, position);
					end;
					
					if ( IsValid(entity) ) then
						if (trace and trace.HitNormal) then
							nexus.entity.MakeFlushToGround(entity, position, trace.HitNormal);
						end;
					end;
					
					if (!soundless) then
						if (itemTable.dropSound) then
							player:EmitSound(itemTable.dropSound);
						elseif (itemTable.dropSound != false) then
							player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
						end;
					end;
					
					nexus.mount.Call("PlayerDropItem", player, itemTable, position, entity);
					
					return true;
				end;
			end;
		end;
	end;
	
	-- A function to destroy a player's item.
	function nexus.item.Destroy(player, item, soundless)
		local itemTable = nexus.item.Get(item);
		
		if (itemTable) then
			local uniqueID = itemTable.uniqueID;
			local hasItem = player:HasItem(uniqueID);
			
			if (hasItem and hasItem > 0) then
				if (itemTable.OnDestroy) then
					if ( itemTable:OnDestroy(player) == false ) then
						return;
					end;
					
					player:UpdateInventory(uniqueID, -1);
					
					if (!soundless) then
						if (itemTable.destroySound) then
							player:EmitSound(itemTable.destroySound);
						elseif (itemTable.destroySound != false) then
							player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
						end;
					end;
					
					nexus.mount.Call("PlayerDestroyItem", player, itemTable);
					
					return true;
				end;
			end;
		end;
	end;
else
	function nexus.item.GetIconInfo(itemTable)
		local model = itemTable.model;
		local skin = itemTable.skin;
		
		if (itemTable.iconModel) then
			model = itemTable.iconModel;
		end;
		
		if (itemTable.iconSkin) then
			skin = itemTable.iconSkin;
		end;
		
		if (itemTable.GetClientSideModel) then
			model = itemTable:GetClientSideModel();
		end;
		
		if (itemTable.GetClientSideSkin) then
			skin = itemTable:GetClientSideSkin();
		end;
		
		return model, skin;
	end;
end;