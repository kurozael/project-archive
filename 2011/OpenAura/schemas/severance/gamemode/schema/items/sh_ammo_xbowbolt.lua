--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "5.7x28mm Rounds";
ITEM.model = "models/items/boxzrounds.mdl";
ITEM.weight = 0.8;
ITEM.uniqueID = "ammo_xbowbolt";
ITEM.ammoClass = "xbowbolt";
ITEM.ammoAmount = 24;
ITEM.description = "An average sized blue container with 5.7x28mm on the side.";

openAura.item:Register(ITEM);