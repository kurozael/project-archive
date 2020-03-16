--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("alcohol_base");
ITEM.cost = 4;
ITEM.name = "Whiskey";
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.25;
ITEM.access = "T";
ITEM.business = true;
ITEM.description = "A brown colored whiskey bottle, be careful!";

-- Called when a player drinks the item.
function ITEM:OnDrink(player)
	player:GiveItem("empty_whiskey_bottle", true);
end;

Clockwork.item:Register(ITEM);