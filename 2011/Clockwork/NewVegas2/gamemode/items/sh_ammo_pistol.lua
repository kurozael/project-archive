--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.cost = 70;
	ITEM.name = "9x19mm Rounds";
	ITEM.batch = 1;
	ITEM.model = "models/items/boxsrounds.mdl";
	ITEM.weight = 0.8;
	ITEM.access = "T";
	ITEM.business = true;
	ITEM.uniqueID = "ammo_pistol";
	ITEM.ammoClass = "pistol";
	ITEM.ammoAmount = 24;
	ITEM.description = "An average sized green container with 9mm on the side.";
Clockwork.item:Register(ITEM);