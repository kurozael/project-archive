--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 80;
ITEM.name = "Medic Gear";
ITEM.group = "group03m";
ITEM.weight = 0.5;
ITEM.uniqueID = "medic_uniform";
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.business = true;
ITEM.description = "Medic gear with a yellow insignia.";

openAura.item:Register(ITEM);