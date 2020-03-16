--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 4750;
ITEM.name = "Armatan Exterior";
ITEM.weight = 3;
ITEM.business = true;
ITEM.armorScale = 0.35;
ITEM.replacement = "models/spx2.mdl";
ITEM.description = "Some Armatan branded exterior armor.\nProvides you with 35% bullet resistance.";

openAura.schema:RegisterLeveledArmor(ITEM);