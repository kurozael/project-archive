--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "9x19mm Rounds";
ITEM.model = "models/items/boxsrounds.mdl";
ITEM.weight = 0.8;
ITEM.uniqueID = "ammo_pistol";
ITEM.ammoClass = "pistol";
ITEM.ammoAmount = 24;
ITEM.description = "An average sized green container with 9mm on the side.";

openAura.item:Register(ITEM);