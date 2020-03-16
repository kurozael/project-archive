--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "Shotgun Shells";
ITEM.cost = 125;
ITEM.model = "models/items/boxbuckshot.mdl";
ITEM.weight = 1;
ITEM.classes = {CLASS_BLACKMARKET};
ITEM.uniqueID = "ammo_buckshot";
ITEM.business = true;
ITEM.ammoClass = "buckshot";
ITEM.ammoAmount = 16;
ITEM.description = "A small red box filled with Buckshot on the side.";

openAura.item:Register(ITEM);