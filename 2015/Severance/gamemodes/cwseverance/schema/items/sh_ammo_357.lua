--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "50AE Rounds";
	ITEM.model = "models/items/ammobox.mdl";
	ITEM.weight = 0.35;
	ITEM.uniqueID = "ammo_357";
	ITEM.ammoClass = "357";
	ITEM.ammoAmount = 8;
	ITEM.description = "An red box with '50AE' printed on the side.";
Clockwork.item:Register(ITEM);