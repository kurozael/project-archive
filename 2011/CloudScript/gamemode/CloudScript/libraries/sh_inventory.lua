--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

CloudScript.inventory = {};

-- A function to get the default inventory.
function CloudScript.inventory:GetDefault(player, character)
	local inventory = {};
	local default = {};
	
	for k, v in pairs( CloudScript.item:GetAll() ) do
		if (v.default) then
			inventory[k] = v.default;
		end;
	end;
	
	if (player) then
		if (!character) then
			character = player.character;
		end;
		
		CloudScript.plugin:Call("GetPlayerDefaultInventory", player, character, inventory);
	end;
	
	for k, v in pairs(inventory) do
		local itemTable = CloudScript.item:Get(k);
		
		if (itemTable) then
			local item = itemTable.uniqueID;
			
			if ( !default[item] ) then
				default[item] = v;
			else
				default[item] = default[item] + v;
			end;
		end;
	end;
	
	return default;
end;

if (SERVER) then
	function CloudScript.inventory:Update(player, item, amount, force, noMessage)
		local inventory = CloudScript.player:GetInventory(player);
		local itemTable = CloudScript.item:Get(item);
		
		if (itemTable) then
			item = itemTable.uniqueID;
			
			if (!amount or amount < 1 or self:CanHoldWeight(player, itemTable.weight * amount) or force) then
				inventory[item] = (inventory[item] or 0) + (amount or 0);
				
				if (inventory[item] <= 0) then
					if (amount and amount > 0) then
						inventory[item] = amount;
					else
						inventory[item] = nil;
					end;
				end;
				
				umsg.Start("cloud_InventoryItem", player);
					umsg.Long(itemTable.index);
					umsg.Long(inventory[item] or 0);
				umsg.End();
				
				if (!noMessage and amount and amount > 0) then
					local name = itemTable.plural;
					
					if (amount == -1 or amount == 1) then
						name = itemTable.name;
					end;
					
					if (amount < 0) then
						CloudScript:PrintLog(LOGTYPE_GENERIC, player:Name().." has lost "..math.abs(amount).." "..name..".");
					elseif (amount > 0) then
						CloudScript:PrintLog(LOGTYPE_GENERIC, player:Name().." has gained "..math.abs(amount).." "..name..".");
					end;
				end;
				
				CloudScript.plugin:Call("PlayerInventoryItemUpdated", player, itemTable, amount, force);
				
				return true;
			else
				return false, "You do not have enough inventory space!";
			end;
		else
			return false, "That is not a valid item!";
		end;
	end;
	
	-- A function to rebuild a player's inventory.
	function CloudScript.inventory:Rebuild(player)
		CloudScript:CreateTimer("rebuild_inv_"..player:UniqueID(), 0.5, 1, function()
			if ( IsValid(player) ) then
				umsg.Start("cloud_InventoryRebuild", player);
				umsg.End();
			end;
		end);
	end;
	
	-- A function to check if a player can have an item updated.
	function CloudScript.inventory:CanHaveItemUpdated(player, item, amount)
		local inventory = CloudScript.player:GetInventory(player);
		local itemTable = CloudScript.item:Get(item);
		
		if (itemTable) then
			item = itemTable.uniqueID;
			
			if ( !amount or amount < 1 or self:CanHoldWeight(player, itemTable.weight * amount) ) then
				return true;
			else
				return false, "You do not have enough inventory space!";
			end;
		else
			return false, "That is not a valid item!";
		end;
	end;
	
	-- A function to check if a player has an inventory item.
	function CloudScript.inventory:HasItem(player, item, anywhere)
		local inventory = CloudScript.player:GetInventory(player);
		local itemTable = CloudScript.item:Get(item);
		
		if (itemTable) then item = itemTable.uniqueID; end;
		
		if (!anywhere) then
			return inventory[item];
		else
			local elsewhere = CloudScript.plugin:Call("PlayerDoesHaveItem", player, itemTable);
			
			if ( elsewhere or inventory[item] ) then
				return (elsewhere or 0) + (inventory[item] or 0);
			end;
		end;
	end;
	
	-- A function to get the maximum amount of weight a player can hold.
	function CloudScript.inventory:GetMaximumWeight(player)
		local weight = player:GetSharedVar("inventoryWeight");
		
		for k, v in pairs( CloudScript.player:GetInventory(player) ) do
			local itemTable = CloudScript.item:Get(k);
			
			if (itemTable) then
				if (itemTable.extraInventory) then
					weight = weight + (itemTable.extraInventory * v);
				end;
			end;
		end;
		
		return weight;
	end;
	
	-- A function to get the weight of a player's inventory.
	function CloudScript.inventory:GetWeight(player)
		local weight = 0;
		
		for k, v in pairs( CloudScript.player:GetInventory(player) ) do
			local itemTable = CloudScript.item:Get(k);
			
			if (itemTable) then
				if (itemTable.weight > 0) then
					weight = weight + (itemTable.weight * v);
				end;
			end;
		end;
		
		return weight;
	end;
	
	-- A function to get whether a player's inventory can hold a weight..
	function CloudScript.inventory:CanHoldWeight(player, weight)
		if ( self:GetWeight(player) + weight > self:GetMaximumWeight(player) ) then
			return false;
		else
			return true;
		end;
	end;
else
	CloudScript.inventory.stored = {};
	
	usermessage.Hook("cloud_InventoryClear", function(msg)
		CloudScript.inventory.stored = {};
		CloudScript.inventory:Rebuild();
	end);
	
	usermessage.Hook("cloud_InventoryRebuild", function(msg)
		CloudScript.inventory:Rebuild();
	end);
	
	usermessage.Hook("cloud_InventoryItem", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local itemTable = CloudScript.item:Get(index);
		
		if (itemTable) then
			local panel = CloudScript.inventory:GetPanel();
			local item = itemTable.uniqueID;
			
			if (amount < 1) then
				CloudScript.inventory.stored[item] = nil;
			else
				CloudScript.inventory.stored[item] = amount;
			end;
			
			CloudScript.inventory:Rebuild();
		end;
	end);
	
	-- A function to rebuild the local player's inventory.
	function CloudScript.inventory:Rebuild()
		local panel = self:GetPanel();
		
		if ( CloudScript.menu:GetOpen() ) then
			if (panel and CloudScript.menu:GetActivePanel() == panel) then
				CloudScript:CreateTimer("Rebuild Inventory", 0.5, 1, function()
					if ( IsValid(panel) ) then
						panel:Rebuild();
					end;
				end);
			end;
		end;
	end;
	
	-- A function to get the maximum amount of space a player has.
	function CloudScript.inventory:GetMaximumWeight()
		local weight = CloudScript.Client:GetSharedVar( "inventoryWeight", CloudScript.config:Get("default_inv_weight"):Get() );
		
		for k, v in pairs(self.stored) do
			local itemTable = CloudScript.item:Get(k);
			
			if (itemTable) then
				if (itemTable.extraInventory) then
					weight = weight + (itemTable.extraInventory * v);
				end;
			end;
		end;
		
		return weight;
	end;
	
	-- A function to get the inventory panel.
	function CloudScript.inventory:GetPanel()
		return self.panel;
	end;
	
	-- A function to check if the local player has an inventory item.
	function CloudScript.inventory:HasItem(item)
		return self.stored[item];
	end;
	
	-- A function to get the weight of the local player's inventory.
	function CloudScript.inventory:GetWeight()
		local weight = 0;
		
		for k, v in pairs(self.stored) do
			local itemTable = CloudScript.item:Get(k);
			
			if (itemTable) then
				if (itemTable.weight > 0) then
					weight = weight + (itemTable.weight * v);
				end;
			end;
		end;
		
		return weight;
	end;
	
	-- A function to get the local player's inventory.
	function CloudScript.inventory:GetAll()
		return self.stored;
	end;
	
	-- A function to get whether the local player's inventory can hold a weight.
	function CloudScript.inventory:CanHoldWeight(weight)
		if ( self:GetWeight() + weight > self:GetMaximumWeight() ) then
			return false;
		else
			return true;
		end;
	end;
end;