--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "Shotgun Shells";
	ITEM.cost = (210 * 0.75);
	ITEM.model = "models/items/boxbuckshot.mdl";
	ITEM.weight = 1;
	ITEM.uniqueID = "ammo_buckshot";
	ITEM.business = true;
	ITEM.ammoClass = "buckshot";
	ITEM.ammoAmount = 36;
	ITEM.description = "A small red box filled with Buckshot on the side.";
Clockwork.item:Register(ITEM);