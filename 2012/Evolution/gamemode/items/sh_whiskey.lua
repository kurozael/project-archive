--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("alcohol_base");
ITEM.name = "Whiskey";
ITEM.cost = (35 * 0.5);
ITEM.batch = 3;
ITEM.model = "models/props_junk/garbage_glassbottle002a.mdl";
ITEM.weight = 1.2;
ITEM.business = true;
ITEM.attributes = {Stamina = 10};
ITEM.description = "A brown colored whiskey bottle, be careful!";

Clockwork.item:Register(ITEM);