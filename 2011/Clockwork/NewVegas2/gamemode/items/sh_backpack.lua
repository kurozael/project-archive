--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Backpack";
ITEM.model = "models/props_junk/garbage_bag001a.mdl";
ITEM.weight = 0.1;
ITEM.category = "Storage";
ITEM.isRareItem = true;
ITEM.description = "A tattered backpack, it doesn't look like it will hold much.";
ITEM.addInvSpace = 2;

-- Called when the item's drop entity should be created.
function ITEM:OnCreateDropEntity(player, position)
	return Clockwork.entity:CreateItem(
		player, Clockwork.item:CreateInstance("boxed_backpack"), position
	);
end;

-- Called when a player attempts to take the item from storage.
function ITEM:CanTakeStorage(player, storageTable)
	local target = Clockwork.entity:GetPlayer(storageTable.entity);
	
	if (target and target:GetInventoryWeight() > (target:GetMaxWeight() - self("addInvSpace"))) then
		return false;
	end;
	
	local itemTables = player:GetItemsByID(self("uniqueID"));
	
	if (itemTables and table.Count(itemTables) >= 1) then
		return false;
	end;
end;

-- Called when a player attempts to pick up the item.
function ITEM:CanPickup(player, quickUse, itemEntity)
	return "boxed_backpack";
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position)
	if (player:GetInventoryWeight() > (player:GetMaxWeight() - self("addInvSpace"))) then
		Clockwork.player:Notify(player, "You cannot drop this while you are carrying items in it!");
		
		return false;
	end;
end;

Clockwork.item:Register(ITEM);