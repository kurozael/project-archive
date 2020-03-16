--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 4000;
ITEM.name = "Exterior Riotgear";
ITEM.weight = 2.5;
ITEM.business = true;
ITEM.armorScale = 0.3;
ITEM.replacement = "models/riot_ex2.mdl";
ITEM.description = "A dark gray outfit with a mandatory skull mask.\nProvides you with 30% bullet resistance.";

openAura.schema:RegisterLeveledArmor(ITEM);