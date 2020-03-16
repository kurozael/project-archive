
--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 5000;
ITEM.name = "Duplexan Exterior";
ITEM.weight = 3;
ITEM.business = true;
ITEM.armorScale = 0.375;
ITEM.replacement = "models/spx7.mdl";
ITEM.description = "Some Duplexan branded exterior armor.\nProvides you with 37.5% bullet resistance.";

openAura.schema:RegisterLeveledArmor(ITEM);