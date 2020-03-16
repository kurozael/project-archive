--[[
Name: "sh_inventory.lua".
Product: "kuroScript".
--]]

kuroScript.inventory = {};

-- A function to get the default inventory.
function kuroScript.inventory.GetDefault(player, character)
	local inventory = {};
	local default = {};
	local k, v;
	
	-- Loop through each value in a table.
	for k, v in pairs(kuroScript.item.stored) do
		if (v.default) then inventory[k] = v.default; end;
	end;
	
	-- Check if a statement is true.
	if (player) then
		hook.Call("GetPlayerDefaultInventory", kuroScript.frame, player, character or player._Character, inventory);
	end;
	
	-- Loop for each value in a table.
	for k, v in pairs(inventory) do
		local itemTable = kuroScript.item.Get(k);
		
		-- Check if a statement is true.
		if (itemTable) then
			local item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if ( !default[item] ) then
				default[item] = v;
			else
				default[item] = default[item] + v;
			end;
		end;
	end;
	
	-- Return the default inventory.
	return default;
end;

-- Check if a statement is true.
if (SERVER) then
	function kuroScript.inventory.Update(player, item, amount, force, silent)
		local inventory = player:QueryCharacter("inventory");
		local itemTable = kuroScript.item.Get(item);
		
		-- Check if a statement is true.
		if (itemTable) then
			item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if (!amount or amount < 1 or kuroScript.inventory.CanHoldWeight(player, itemTable.weight * amount) or force) then
				inventory[item] = (inventory[item] or 0) + (amount or 0);
				
				-- Check if a statement is true.
				if (inventory[item] <= 0) then
					if (amount and amount > 0) then
						inventory[item] = amount;
					else
						inventory[item] = nil;
					end;
				end;
				
				-- Start a user message.
				umsg.Start("ks_InventoryItem", player);
					umsg.Long(itemTable.index);
					umsg.Long(inventory[item] or 0);
				umsg.End();
				
				-- Check if a statement is true.
				if (!silent and amount and amount > 0) then
					local name = itemTable.plural;
					
					-- Check if a statement is true.
					if (amount == -1 or amount == 1) then
						name = itemTable.name;
					end;
					
					-- Check if a statement is true.
					if (amount < 0) then
						kuroScript.player.Alert( player, "- "..math.abs(amount).." "..name, Color(100, 255, 200, 255) );
						
						-- Print a debug message.
						kuroScript.frame:PrintDebug(player:Name().." has lost "..math.abs(amount).." "..name..".");
					elseif (amount > 0) then
						kuroScript.player.Alert( player, "+ "..math.abs(amount).." "..name, Color(150, 100, 255, 255) );
						
						-- Print a debug message.
						kuroScript.frame:PrintDebug(player:Name().." has gained "..math.abs(amount).." "..name..".");
					end;
				end;
				
				-- Call a gamemode hook.
				hook.Call("PlayerInventoryItemUpdated", kuroScript.frame, player, itemTable, amount, force);
				
				-- Return true to break the function.
				return true;
			else
				return false, "You do not have enough inventory space!";
			end;
		else
			return false, "That is not a valid item!";
		end;
	end;
	
	-- A function to check if a player can have an item updated.
	function kuroScript.inventory.CanHaveItemUpdated(player, item, amount)
		local inventory = player:QueryCharacter("inventory");
		local itemTable = kuroScript.item.Get(item);
		
		-- Check if a statement is true.
		if (itemTable) then
			item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if ( !amount or amount < 1 or kuroScript.inventory.CanHoldWeight(player, itemTable.weight * amount) ) then
				return true;
			else
				return false, "You do not have enough inventory space!";
			end;
		else
			return false, "That is not a valid item!";
		end;
	end;
	
	-- A function to check if a player has an inventory item.
	function kuroScript.inventory.HasItem(player, item, anywhere)
		local inventory = player:QueryCharacter("inventory");
		local itemTable = kuroScript.item.Get(item);
		
		-- Check if a statement is true.
		if (itemTable) then item = itemTable.uniqueID; end;
		
		-- Check if a statement is true.
		if (!anywhere) then
			return inventory[item];
		else
			local elsewhere = hook.Call("PlayerDoesHaveItem", kuroScript.frame, player, itemTable);
			
			-- Check if a statement is true.
			if ( elsewhere or inventory[item] ) then
				return (elsewhere or 0) + (inventory[item] or 0);
			end;
		end;
	end;
	
	-- A function to get the maximum amount of weight a player can hold.
	function kuroScript.inventory.GetMaximumWeight(player)
		local weight = player:GetSharedVar("ks_InventoryWeight");
		
		-- Loop through each value in a table.
		for k, v in pairs( player:QueryCharacter("inventory") ) do
			local itemTable = kuroScript.item.Get(k);
			
			-- Check if a statement is true.
			if (itemTable) then
				if (itemTable.extraInventory) then
					weight = weight + (itemTable.extraInventory * v);
				end;
			end;
		end;
		
		-- Return the weight.
		return weight;
	end;
	
	-- A function to get the weight of a player's inventory.
	function kuroScript.inventory.GetWeight(player)
		local weight = 0;
		
		-- Loop through each value in a table.
		for k, v in pairs( player:QueryCharacter("inventory") ) do
			local itemTable = kuroScript.item.Get(k);
			
			-- Check if a statement is true.
			if (itemTable) then
				if (itemTable.weight > 0) then
					weight = weight + (itemTable.weight * v);
				end;
			end;
		end;
		
		-- Return the weight.
		return weight;
	end;
	
	-- A function to get whether a player's inventory can hold a weight..
	function kuroScript.inventory.CanHoldWeight(player, weight)
		if ( kuroScript.inventory.GetWeight(player) + weight > kuroScript.inventory.GetMaximumWeight(player) ) then
			return false;
		else
			return true;
		end;
	end;
	
	-- Add a hook.
	hook.Add("PlayerInitialized", "kuroScript.inventory.playerInitialized", function(player)
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs( player:QueryCharacter("inventory") ) do
			local itemTable = kuroScript.item.Get(k);
			
			-- Check if a statement is true.
			if (itemTable) then
				kuroScript.inventory.Update(player, itemTable.uniqueID, 0, true);
			end;
		end;
	end);
else
	kuroScript.inventory.stored = {};
	
	-- Hook a user message.
	usermessage.Hook("ks_InventoryItem", function(msg)
		local index = msg:ReadLong();
		local amount = msg:ReadLong();
		local itemTable = kuroScript.item.Get(index);
		
		-- Check if a statement is true.
		if (itemTable) then
			local panel = kuroScript.inventory.GetPanel();
			local item = itemTable.uniqueID;
			
			-- Check if a statement is true.
			if (amount < 1) then
				kuroScript.inventory.stored[item] = nil;
			else
				kuroScript.inventory.stored[item] = amount;
			end;
			
			-- Check if a statement is true.
			if ( kuroScript.menu.GetOpen() ) then
				if (panel and kuroScript.menu.GetActiveTab() == panel) then
					kuroScript.frame:CreateTimer("Rebuild Inventory", 0.1, 1, function()
						if ( panel and panel:IsValid() ) then
							panel:Rebuild();
						end;
					end);
				end;
			end;
		end;
	end);
	
	-- A function to get the maximum amount of space a player has.
	function kuroScript.inventory.GetMaximumWeight()
		local weight = g_LocalPlayer:GetSharedVar( "ks_InventoryWeight", kuroScript.config.Get("default_inv_weight"):Get() );
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.inventory.stored) do
			local itemTable = kuroScript.item.Get(k);
			
			-- Check if a statement is true.
			if (itemTable) then
				if (itemTable.extraInventory) then
					weight = weight + (itemTable.extraInventory * v);
				end;
			end;
		end;
		
		-- Return the weight.
		return weight;
	end;
	
	-- A function to get the inventory panel.
	function kuroScript.inventory.GetPanel()
		return kuroScript.inventory.panel;
	end;
	
	-- A function to check if the local player has an inventory item.
	function kuroScript.inventory.HasItem(item)
		return kuroScript.inventory.stored[item];
	end;
	
	-- A function to get the weight of the local player's inventory.
	function kuroScript.inventory.GetWeight()
		local weight = 0;
		local k, v;
		
		-- Loop through each value in a table.
		for k, v in pairs(kuroScript.inventory.stored) do
			local itemTable = kuroScript.item.Get(k);
			
			-- Check if a statement is true.
			if (itemTable) then
				if (itemTable.weight > 0) then
					weight = weight + (itemTable.weight * v);
				end;
			end;
		end;
		
		-- Return the weight.
		return weight;
	end;
	
	-- A function to get the local player's inventory.
	function kuroScript.inventory.GetAll()
		return kuroScript.inventory.stored;
	end;
	
	-- A function to get whether the local player's inventory can hold a weight.
	function kuroScript.inventory.CanHoldWeight(weight)
		if ( kuroScript.inventory.GetWeight() + weight > kuroScript.inventory.GetMaximumWeight() ) then
			return false;
		else
			return true;
		end;
	end;
end;