--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

openAura.item = {};
openAura.item.stored = {};
openAura.item.buffer = {};
openAura.item.weapons = {};

-- A function to get the item buffer.
function openAura.item:GetBuffer()
	return self.buffer;
end;

-- A function to get all items.
function openAura.item:GetAll()
	return self.stored;
end;

-- A function to get a new item.
function openAura.item:New()
	return {};
end;

-- A function to register a new item.
function openAura.item:Register(itemTable)
	if (!itemTable.plural) then
		if ( string.sub(itemTable.name, -1) != "s" ) then
			itemTable.plural = itemTable.name.."s";
		else
			itemTable.plural = itemTable.name;
		end;
	end;
	
	itemTable.uniqueID = string.lower( string.gsub(itemTable.uniqueID or string.gsub(itemTable.name, "%s", "_"), "['%.]", "") );
	itemTable.index = openAura:GetShortCRC(itemTable.uniqueID);
	
	self.stored[itemTable.uniqueID] = itemTable;
	self.buffer[itemTable.index] = itemTable;
end;

-- A function to get whether an item is a weapon.
function openAura.item:IsWeapon(itemTable)
	if ( self:IsBasedFrom(itemTable, "weapon_base") ) then
		return true;
	end;
	
	return false;
end;

-- A function to get whether an item is based from an item.
function openAura.item:IsBasedFrom(name, base)
	if (name) then
		local itemTable = name;
		
		if (type(name) != "table") then
			itemTable = self:Get(name);
		end;
		
		while (itemTable and itemTable.base) do
			if (itemTable.base != base) then
				itemTable = self:Get(itemTable.base);
			else
				return true;
			end;
		end;
	end;
end;

-- A function to a weapon item by its object.
function openAura.item:GetWeapon(weapon, uniqueID)
	local itemTable = nil;
	local class = weapon;
	
	if (type(class) != "string") then
		class = weapon:GetClass();
		uniqueID = weapon:GetNetworkedString("uniqueID");
	end;
	
	if (uniqueID == "") then uniqueID = nil; end;
	
	itemTable = self.stored[class];
	
	if ( self:IsWeapon(itemTable) ) then
		if (itemTable.uniqueID == uniqueID) then
			return itemTable;
		end;
	end;
	
	itemTable = self.weapons[class];
	
	if ( self:IsWeapon(itemTable) ) then
		if (itemTable.uniqueID == uniqueID) then
			return itemTable;
		end;
	end;
	
	for k, v in pairs(self.stored) do
		if (v.uniqueID == uniqueID and v.weaponClass == class) then
			return v;
		end;
	end;
end;

-- A function to get an item by its name.
function openAura.item:Get(name)
	if (name and name != 0 and type(name) != "boolean") then
		if ( self.buffer[name] ) then
			return self.buffer[name];
		elseif ( self.stored[name] ) then
			return self.stored[name];
		elseif ( self.weapons[name] ) then
			return self.weapons[name];
		else
			local lowerName = string.lower(name);
			local item = nil;
			
			for k, v in pairs(self.stored) do
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
function openAura.item:Merge(item, base, temporary)
	local baseTable = self:Get(base);
	local isBaseItem = item.isBaseItem;
	
	if (baseTable) then
		local baseTableCopy = table.Copy(baseTable);
		
		if (baseTableCopy.base) then
			baseTableCopy = self:Merge(baseTableCopy, baseTable.base, true);
			
			if (!baseTableCopy) then
				return;
			end;
		end;
		
		table.Merge(baseTableCopy, item);
		
		if (!temporary) then
			baseTableCopy.baseClass = baseTable;
			baseTableCopy.isBaseItem = isBaseItem;
			
			self:Register(baseTableCopy);
		end;
		
		return baseTableCopy;
	end;
end;

if (SERVER) then
	function openAura.item:Use(player, item, soundless)
		local itemTable = self:Get(item);
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
					
					openAura.plugin:Call("PlayerUseItem", player, itemTable, itemEntity);
					
					return true;
				end;
			end;
		end;
	end;
	
	-- A function to drop an item from a player.
	function openAura.item:Drop(player, item, position, soundless, noTake)
		local itemTable = self:Get(item);
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
						entity = openAura.entity:CreateItem(player, uniqueID, position);
					end;
					
					if ( IsValid(entity) ) then
						if (trace and trace.HitNormal) then
							openAura.entity:MakeFlushToGround(entity, position, trace.HitNormal);
						end;
					end;
					
					if (!soundless) then
						if (itemTable.dropSound) then
							player:EmitSound(itemTable.dropSound);
						elseif (itemTable.dropSound != false) then
							player:EmitSound("physics/body/body_medium_impact_soft"..math.random(1, 7)..".wav");
						end;
					end;
					
					openAura.plugin:Call("PlayerDropItem", player, itemTable, position, entity);
					
					return true;
				end;
			end;
		end;
	end;
	
	-- A function to destroy a player's item.
	function openAura.item:Destroy(player, item, soundless)
		local itemTable = self:Get(item);
		
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
					
					openAura.plugin:Call("PlayerDestroyItem", player, itemTable);
					
					return true;
				end;
			end;
		end;
	end;
else
	function openAura.item:GetIconInfo(itemTable)
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