--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "ammo_base";
ITEM.name = "Energy Cell";
ITEM.cost = 100;
ITEM.model = "models/items/combine_rifle_ammo01.mdl";
ITEM.weight = 1;
ITEM.access = "T";
ITEM.business = true;
ITEM.ammoClass = "ar2altfire";
ITEM.ammoAmount = 90;
ITEM.description = "A small capsule that is used to charge weapons that use laser technology.";

openAura.item:Register(ITEM);