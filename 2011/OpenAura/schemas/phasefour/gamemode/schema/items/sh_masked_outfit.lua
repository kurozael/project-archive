--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 1500;
ITEM.name = "Masked Outfit";
ITEM.weight = 1;
ITEM.business = true;
ITEM.armorScale = 0.125;
ITEM.replacement = "models/humans/group03/male_experim.mdl";
ITEM.description = "A masked outfit with a scruffy clothing.\nProvides you with 12.5% bullet resistance.";

openAura.schema:RegisterLeveledArmor(ITEM);