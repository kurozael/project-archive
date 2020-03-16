--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "5.7x28mm Rounds";
ITEM.cost = 175;
ITEM.model = "models/items/boxzrounds.mdl";
ITEM.weight = 1;
ITEM.uniqueID = "ammo_xbowbolt";
ITEM.business = true;
ITEM.ammoClass = "xbowbolt";
ITEM.ammoAmount = 60;
ITEM.description = "An average sized blue container with 5.7x28mm on the side.";

openAura.item:Register(ITEM);