--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.cost = 70;
	ITEM.name = "5.7x28mm Rounds";
	ITEM.batch = 1;
	ITEM.model = "models/items/ammorounds.mdl";
	ITEM.weight = 0.8;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.uniqueID = "ammo_xbowbolt";
	ITEM.ammoClass = "xbowbolt";
	ITEM.ammoAmount = 24;
	ITEM.description = "An average sized blue container with 5.7x28mm on the side.";
Clockwork.item:Register(ITEM);