--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "7.65x59mm Rounds";
	ITEM.model = "models/items/ammobox.mdl";
	ITEM.weight = 0.35;
	ITEM.uniqueID = "ammo_sniper";
	ITEM.ammoClass = "ar2";
	ITEM.ammoAmount = 8;
	ITEM.description = "A red container with 7.65x59mm on the side.";
Clockwork.item:Register(ITEM);