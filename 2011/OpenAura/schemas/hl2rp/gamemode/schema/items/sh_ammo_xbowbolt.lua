--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "Crossbow Bolts";
ITEM.cost = 50;
ITEM.model = "models/items/crossbowrounds.mdl";
ITEM.access = "V";
ITEM.weight = 2;
ITEM.uniqueID = "ammo_xbowbolt";
ITEM.business = true;
ITEM.ammoClass = "xbowbolt";
ITEM.ammoAmount = 4;
ITEM.description = "A set of iron bolts, the coating is rusting away.";

openAura.item:Register(ITEM);