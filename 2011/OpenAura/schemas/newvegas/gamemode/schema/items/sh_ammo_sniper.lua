--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.cost = 100;
ITEM.name = "7.65x59mm Rounds";
ITEM.batch = 1;
ITEM.model = "models/items/redammo.mdl";
ITEM.weight = 0.35;
ITEM.access = "T";
ITEM.business = true;
ITEM.uniqueID = "ammo_sniper";
ITEM.ammoClass = "ar2";
ITEM.ammoAmount = 8;
ITEM.description = "A red container with 7.65x59mm on the side.";

openAura.item:Register(ITEM);