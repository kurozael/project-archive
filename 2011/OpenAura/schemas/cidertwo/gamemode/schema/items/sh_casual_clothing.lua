--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 30;
ITEM.name = "Casual Clothing";
ITEM.group = "group04";
ITEM.weight = 0.5;
ITEM.classes = {CLASS_MERCHANT};
ITEM.business = true;
ITEM.description = "Just some nice casual clothing.";

openAura.item:Register(ITEM);