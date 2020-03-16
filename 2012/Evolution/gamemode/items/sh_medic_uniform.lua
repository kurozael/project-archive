--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = (2000 * 0.5);
ITEM.name = "Medic Uniform";
ITEM.group = "group03m";
ITEM.weight = 1;
ITEM.business = true;
ITEM.armorScale = 0.1;
ITEM.description = "A medic uniform with a yellow insignia.";

Clockwork.item:Register(ITEM);