--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 4500;
ITEM.name = "Spartan Exterior";
ITEM.weight = 3;
ITEM.business = true;
ITEM.armorScale = 0.325;
ITEM.replacement = "models/spex.mdl";
ITEM.description = "Some Spartan branded exterior armor.\nProvides you with 32.5% bullet resistance.";

openAura.schema:RegisterLeveledArmor(ITEM);