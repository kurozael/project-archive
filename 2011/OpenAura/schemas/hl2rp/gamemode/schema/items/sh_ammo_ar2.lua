--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "Pulse-Rifle Energy";
ITEM.cost = 30;
ITEM.classes = {CLASS_EOW};
ITEM.model = "models/items/combine_rifle_cartridge01.mdl";
ITEM.plural = "Pulse-Rifle Energy";
ITEM.weight = 1;
ITEM.uniqueID = "ammo_ar2";
ITEM.business = true;
ITEM.ammoClass = "ar2";
ITEM.ammoAmount = 30;
ITEM.description = "A cartridge with a blue glow emitting from it.";

openAura.item:Register(ITEM);