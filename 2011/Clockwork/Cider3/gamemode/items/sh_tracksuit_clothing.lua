--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
	ITEM.cost = 20;
	ITEM.name = "Tracksuit Clothing";
	ITEM.group = "group08";
	ITEM.weight = 0.5;
	ITEM.classes = {CLASS_MERCHANT};
	ITEM.business = true;
	ITEM.description = "Well... the hoodie looks like it's from a tracksuit.";
Clockwork.item:Register(ITEM);