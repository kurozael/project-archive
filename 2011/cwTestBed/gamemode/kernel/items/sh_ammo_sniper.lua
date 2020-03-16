--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "7.65x59mm Rounds";
	ITEM.cost = 250;
	ITEM.model = "models/items/ammobox.mdl";
	ITEM.weight = 2;
	ITEM.uniqueID = "ammo_sniper";
	ITEM.business = true;
	ITEM.ammoClass = "ar2";
	ITEM.ammoAmount = 30;
	ITEM.description = "A red container with 7.65x59mm on the side.";
Clockwork.item:Register(ITEM);