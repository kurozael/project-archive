--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("clothes_base", true);
	ITEM.name = "Custom Clothes";
	ITEM.batch = 1;
	ITEM.weight = 0.5;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.whitelist = {FACTION_WASTELANDER, FACTION_CARAVAN};
Clockwork.item:Register(ITEM);