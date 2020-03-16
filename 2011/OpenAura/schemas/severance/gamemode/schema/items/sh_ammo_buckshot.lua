--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "Buckshot Rounds";
ITEM.model = "models/items/boxbuckshot.mdl";
ITEM.weight = 0.5;
ITEM.uniqueID = "ammo_buckshot";
ITEM.ammoClass = "buckshot";
ITEM.ammoAmount = 12;
ITEM.description = "A small red box filled with Buckshot on the side.";

openAura.item:Register(ITEM);