--[[
	� 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "Pulse-Rifle Orb";
ITEM.cost = 80;
ITEM.classes = {CLASS_EOW};
ITEM.model = "models/items/combine_rifle_ammo01.mdl";
ITEM.weight = 1;
ITEM.uniqueID = "ammo_ar2altfire";
ITEM.business = true;
ITEM.ammoClass = "ar2altfire";
ITEM.ammoAmount = 1;
ITEM.description = "A strange item which an orange glow emitting from it.";

openAura.item:Register(ITEM);