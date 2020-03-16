--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 20;
ITEM.name = "Tracksuit Clothing";
ITEM.group = "group08";
ITEM.weight = 0.5;
ITEM.classes = {CLASS_MERCHANT};
ITEM.business = true;
ITEM.description = "Well... the hoodie looks like it's from a tracksuit.";

openAura.item:Register(ITEM);