--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.name = "Boxed Jacket";
ITEM.cost = 20;
ITEM.model = "models/props_junk/cardboard_box004a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.2;
ITEM.access = "T";
ITEM.business = true;
ITEM.useText = "Open";
ITEM.business = true;
ITEM.category = "Storage"
ITEM.description = "A brown box, open it to reveal its contents.";

-- Called when a player uses the item.
function ITEM:OnUse(player, itemEntity)
	if (player:HasItem("jacket") and player:HasItem("jacket") >= 1) then
		openAura.player:Notify(player, "You can only carry one jacket!");
		
		return false;
	end;
	
	player:UpdateInventory("jacket", 1, true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

openAura.item:Register(ITEM);