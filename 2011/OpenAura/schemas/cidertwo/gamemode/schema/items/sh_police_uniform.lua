--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 120;
ITEM.name = "Police Uniform";
ITEM.group = "group09";
ITEM.weight = 0.5;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.business = true;
ITEM.description = "A stolen police uniform on the blackmarket.";

openAura.item:Register(ITEM);