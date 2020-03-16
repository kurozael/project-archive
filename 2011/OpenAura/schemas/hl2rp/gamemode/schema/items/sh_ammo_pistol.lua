--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "9mm Pistol Bullets";
ITEM.cost = 20;
ITEM.classes = {CLASS_EMP, CLASS_EOW};
ITEM.model = "models/items/boxsrounds.mdl";
ITEM.weight = 1;
ITEM.access = "V";
ITEM.uniqueID = "ammo_pistol";
ITEM.business = true;
ITEM.ammoClass = "pistol";
ITEM.ammoAmount = 20;
ITEM.description = "A container filled with bullets and 9mm printed on the side.";

openAura.item:Register(ITEM);