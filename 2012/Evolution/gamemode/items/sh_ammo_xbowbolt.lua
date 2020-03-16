--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("ammo_base");
	ITEM.name = "5.7x28mm Rounds";
	ITEM.cost = (150 * 0.75);
	ITEM.model = "models/items/ammorounds.mdl";
	ITEM.weight = 1;
	ITEM.uniqueID = "ammo_xbowbolt";
	ITEM.business = true;
	ITEM.ammoClass = "xbowbolt";
	ITEM.ammoAmount = 60;
	ITEM.description = "An average sized blue container with 5.7x28mm on the side.";
Clockwork.item:Register(ITEM);