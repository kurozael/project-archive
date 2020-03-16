--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("alcohol_base");
ITEM.cost = 4;
ITEM.name = "Beer";
ITEM.model = "models/props_junk/garbage_glassbottle001a.mdl";
ITEM.batch = 1;
ITEM.weight = 0.25;
ITEM.access = "T";
ITEM.business = true;
ITEM.description = "A glass bottle filled with liquid, it has a funny smell.";

-- Called when a player drinks the item.
function ITEM:OnDrink(player)
	player:GiveItem("empty_beer_bottle", true);
end;

Clockwork.item:Register(ITEM);