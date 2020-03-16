--[[
	© 2015 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "5.7x28mm Rounds";
	ITEM.model = "models/items/ammorounds.mdl";
	ITEM.weight = 0.8;
	ITEM.uniqueID = "ammo_xbowbolt";
	ITEM.ammoClass = "xbowbolt";
	ITEM.ammoAmount = 24;
	ITEM.description = "An average sized blue container with 5.7x28mm on the side.";
Clockwork.item:Register(ITEM);