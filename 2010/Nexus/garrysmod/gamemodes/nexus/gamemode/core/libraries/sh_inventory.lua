--[[
Name: "sh_inventory.lua".
Product: "nexus".
--]]

nexus.inventory = {};

-- A function to get the default inventory.
function nexus.inventory.GetDefault(player, character)
	local inventory = {};
	local default = {};
	
	for k, v in pairs( nexus.item.GetAll() ) do
		if (v.default) then
			inventory[k] = v.default;
		end;
	end;
	
	if (player) then
		if (!character) then
			character = player.character;
		end;
		
		nexus.mount.Call("GetPlayerDefaultInventory", player, character, inventory);
	end;
	
	for k, v in pairs(inventory) do
		local itemTable = nexus.item.Get(k);
		
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
	function nexus.inventory.Update(player, item, amount, force, noMessage)
		local inventory = nexus.player.GetInventory(player);
		local itemTable = nexus.item.Get(item);
		
		if (itemTable) then
			item = itemTable.uniqueID;
			
			if (!amount or amount < 1 or nexus.inventory.CanHoldWeight(player, itemTable.weight * amount) or force) then
				inventory[item] = (inventory[item] or 0) + (amount or 0);
				
				if (inventory[item] <= 0) then
					if (amount and amount > 0) then
						inventory[item] = amount;
					else
						inventory[item] = nil;
					end;
				end;
				
				umsg.Start("nx_InventoryItem", player);
					umsg.Long(itemTable.index);
					umsg.Long(inventory[item] or 0);
				umsg.End();
				
				if (!noMessage and amount and amount > 0) then
					local name = itemTable.plural;
					
					if (amount == -1 or amount == 1) then
						name = itemTable.name;
					end;
					
					if (amount < 0) then
						NEXUS:PrintDebug(player:Name().." has lost "..math.abs(amount).." "..name..".");
					elseif (amount > 0) then
						NEXUS:PrintDebug(player:Name().." has gained "..math.abs(amount).." "..name..".");
					end;
				end;
				
				nexus.mount.Call("PlayerInventoryItemUpdated", player, itemTable, amount, force);
				
				return true;
			else
				return false, "You do not have enough inventory space!";
			end;
		else
			return false, "That is not a valid item!";
		end;
	end;
	
	-- A function to rebuild a player's inventory.
	function nexus.inventory.Rebuild(player)
		NEXUS:CreateTimer("Rebuild Inventory: "..player:UniqueID(), 0.5, 1, function()
			if ( IsValid(player) ) then
				umsg.Start("nx_InventoryRebuild", player);
				umsg.End();
			end;
		end);
	end;
	
	-- A function to check if a player can have an item updated.
	function nexus.inventory.CanHaveItemUpdated(player, item, amount)
		local inventory = nexus.player.GetInventory(player);
		local itemTable = nexus.item.Get(item);
		
		if (itemTable) then
			item = itemTable.uniqueID;
			
			if ( !amount or amount < 1 or nexus.inventory.CanHoldWeight(player, itemTable.weight * amount) ) then
				return true;
			else
				return false, "You do not have enough inventory space!";
			end;
		else
			return false, "That is not a valid item!";
		end;
	end;
	
	-- A function to check if a player has an inventory item.
	function nexus.inventory.HasItem(player, item, anywhere)
		local inventory = nexus.player.GetInventory(player);
		local itemTable = nexus.item.Get(item);
		
		if (itemTable) then item = itemTable.uniqueID; end;
		
		if (!anywhere) then
			return inventory[item];
		else
			local elsewhere = nexus.mount.Call("PlayerDoesHaveItem", player, itemTable);
			
			if ( elsewhere or inventory[item] ) then
				return (elsewhere or 0) + (inventory[item] or 0);
			end;
		end;
	end;
	
	-- A function to get the maximum amount of weight a player can hold.
	function nexus.inventory.GetMaximumWeight(player)
		local weight = player:GetSharedVar("sh_InventoryWeight");
		
		for k, v in pairs( nexus.player.GetInventory(player) ) do
			local itemTable = nexus.item.Get(k);
			
			if (itemTable) then
				if (itemTable.extraInventory) then
					weight = weight + (itemTable.extraInventory * v);
				end;
			end;
		end;
		
		return weight;
	end;
	
	-- A function to get the weight of a player's inventory.
	function nexus.inventory.GetWeight(player)
		local weight = 0;
		
		for k, v in pairs( nexus.player.GetInventory(player) ) do
			local itemTable = nexus.item.Get(k);
			
			if (itemTable) then
				if (itemTable.weight > 0) then
					weight = weight + (itemTable.weight * v);
				end;
			end;
		end;
		
		return weight;
	end;
	
	-- A function to get whether a player's inventory can hold a weight..
	function nexus.inventory.CanHoldWeight(player, weight)
		if ( nexus.inventory.GetWeight(player) + weight > nexus.inventory.GetMaximumWeight(player) ) then
			return false;
		else
			return true;
		end;
	end;
else
	nexus.inventory.stored = {};
	
	usermessage.Hook("nx_InventoryClear", function(msg)
		nexus.inventory.stored = {};
		nexus.inventory.Rebuild();
	end);
	
	usermessage.Hook("nx_InventoryRebuild", function(msg)
		nexus.inventory.Rebuild();
	end);
	
	usermessage.Hook("nx_InventoryItem", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local itemTable = nexus.item.Get(index);
		
		if (itemTable) then
			local panel = nexus.inventory.GetPanel();
			local item = itemTable.uniqueID;
			
			if (amount < 1) then
				nexus.inventory.stored[item] = nil;
			else
				nexus.inventory.stored[item] = amount;
			end;
			
			nexus.inventory.Rebuild();
		end;
	end);
	
	-- A function to rebuild the local player's inventory.
	function nexus.inventory.Rebuild()
		local panel = nexus.inventory.GetPanel();
		
		if ( nexus.menu.GetOpen() ) then
			if (panel and nexus.menu.GetActivePanel() == panel) then
				NEXUS:CreateTimer("Rebuild Inventory", 0.5, 1, function()
					if ( IsValid(panel) ) then
						panel:Rebuild();
					end;
				end);
			end;
		end;
	end;
	
	-- A function to get the maximum amount of space a player has.
	function nexus.inventory.GetMaximumWeight()
		local weight = g_LocalPlayer:GetSharedVar( "sh_InventoryWeight", nexus.config.Get("default_inv_weight"):Get() );
		
		for k, v in pairs(nexus.inventory.stored) do
			local itemTable = nexus.item.Get(k);
			
			if (itemTable) then
				if (itemTable.extraInventory) then
					weight = weight + (itemTable.extraInventory * v);
				end;
			end;
		end;
		
		return weight;
	end;
	
	-- A function to get the inventory panel.
	function nexus.inventory.GetPanel()
		return nexus.inventory.panel;
	end;
	
	-- A function to check if the local player has an inventory item.
	function nexus.inventory.HasItem(item)
		return nexus.inventory.stored[item];
	end;
	
	-- A function to get the weight of the local player's inventory.
	function nexus.inventory.GetWeight()
		local weight = 0;
		
		for k, v in pairs(nexus.inventory.stored) do
			local itemTable = nexus.item.Get(k);
			
			if (itemTable) then
				if (itemTable.weight > 0) then
					weight = weight + (itemTable.weight * v);
				end;
			end;
		end;
		
		return weight;
	end;
	
	-- A function to get the local player's inventory.
	function nexus.inventory.GetAll()
		return nexus.inventory.stored;
	end;
	
	-- A function to get whether the local player's inventory can hold a weight.
	function nexus.inventory.CanHoldWeight(weight)
		if ( nexus.inventory.GetWeight() + weight > nexus.inventory.GetMaximumWeight() ) then
			return false;
		else
			return true;
		end;
	end;
end;