--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New();
ITEM.name = "Boxed Backpack";
ITEM.cost = 30;
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
	if (player:HasItemByID("backpack") and player:HasItemByID("backpack") >= 1) then
		Clockwork.player:Notify(player, "You can only carry one backpack!");
		
		return false;
	end;
	
	player:GiveItem("backpack", true);
end;

-- Called when a player drops the item.
function ITEM:OnDrop(player, position) end;

Clockwork.item:Register(ITEM);