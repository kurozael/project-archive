--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.cost = 80;
ITEM.name = ".357 Rounds";
ITEM.batch = 1;
ITEM.model = "models/items/357ammo.mdl";
ITEM.weight = 0.35;
ITEM.access = "T";
ITEM.business = true;
ITEM.uniqueID = "ammo_357";
ITEM.ammoClass = "357";
ITEM.ammoAmount = 8;
ITEM.description = "An orange container with Magnum on the side.";

openAura.item:Register(ITEM);