--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 40;
ITEM.name = "Smart Clothing";
ITEM.group = "group07";
ITEM.weight = 0.5;
ITEM.classes = {CLASS_MERCHANT};
ITEM.business = true;
ITEM.description = "This is fairly smart clothing... considering the circumstances.";

openAura.item:Register(ITEM);