--[[
Name: "sh_small_bag.lua".
Product: "HL2 RP".
--]]

local ITEM = {};

-- Set some information.
ITEM.rare = true;
ITEM.name = "Small Bag";
ITEM.model = "models/props_junk/garbage_bag001a.mdl";
ITEM.weight = 1;
ITEM.category = "Storage"
ITEM.description = "A small tattered bag, you would be lucky if it held anything.";
ITEM.extraInventory = 4;

-- Called when the item's drop entity should be created.
function ITEM:OnCreateDropEntity(player, position)
	return kuroScript.entity.CreateItem(player, "boxed_bag", position);
end;

-- Called when a player attempts to take the item from storage.
function ITEM:CanTakeStorage(player, storageTable)
	local target = kuroScript.entity.GetPlayer(storageTable.entity);
	
	-- Check if a statement is true.
	if (target) then
		if ( kuroScript.inventory.GetWeight(target) > (kuroScript.inventory.GetMaximumWeight(target) - self.extraInventory) ) then
			return false;
		end;
	end;
	
	-- Check if a statement is true.
	if (kuroScript.inventory.HasItem(player, self.uniqueID) and kuroScript.inventory.HasItem(player, self.uniqueID) >= 2) then
		return false;
	end;
end;

-- Called when a player attempts to pick up the item.
function ITEM:CanPickup(player, quickUse, itemEntity)
	return "boxed_backpack";
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if ( kuroScript.inventory.GetWeight(player) > (kuroScript.inventory.GetMaximumWeight(player) - self.extraInventory) ) then
		kuroScript.player.Notify(player, "You cannot drop this while you are carrying items in it!");
		
		-- Return false to break the function.
		return false;
	end;
end;

-- Register the item.
kuroScript.item.Register(ITEM);