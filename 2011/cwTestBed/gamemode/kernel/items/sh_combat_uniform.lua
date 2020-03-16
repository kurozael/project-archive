--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = 1000;
ITEM.name = "Combat Uniform";
ITEM.group = "group03";
ITEM.weight = 1;
ITEM.business = true;
ITEM.armorScale = 0.1;
ITEM.description = "A combat uniform with a yellow insignia.";

Clockwork.item:Register(ITEM);