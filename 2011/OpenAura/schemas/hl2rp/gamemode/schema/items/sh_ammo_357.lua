--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = ".357 Magnum Bullets";
ITEM.cost = 40;
ITEM.classes = {CLASS_EOW};
ITEM.model = "models/items/357ammo.mdl";
ITEM.weight = 1;
ITEM.access = "V";
ITEM.uniqueID = "ammo_357";
ITEM.business = true;
ITEM.ammoClass = "357";
ITEM.ammoAmount = 21;
ITEM.description = "A small box filled with bullets and Magnum printed on the side.";

openAura.item:Register(ITEM);