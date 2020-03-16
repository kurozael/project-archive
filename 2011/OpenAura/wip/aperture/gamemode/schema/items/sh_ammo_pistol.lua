--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "9x19mm Rounds";
ITEM.cost = 150;
ITEM.model = "models/items/boxsrounds.mdl";
ITEM.weight = 1;
ITEM.uniqueID = "ammo_pistol";
ITEM.business = true;
ITEM.ammoClass = "pistol";
ITEM.ammoAmount = 60;
ITEM.description = "An average sized green container with 9mm on the side.";

openAura.item:Register(ITEM);