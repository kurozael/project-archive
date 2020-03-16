--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 80;
ITEM.name = "Combat Gear";
ITEM.group = "group03";
ITEM.weight = 0.5;
ITEM.uniqueID = "combat_uniform";
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.business = true;
ITEM.description = "Combat gear uniform with a yellow insignia.";

openAura.item:Register(ITEM);