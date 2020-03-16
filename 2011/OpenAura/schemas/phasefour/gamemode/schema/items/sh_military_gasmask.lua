--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 2500;
ITEM.name = "Military Gasmask";
ITEM.weight = 2;
ITEM.business = true;
ITEM.armorScale = 0.2;
ITEM.replacement = "models/pmc/pmc_4/pmc__07.mdl";
ITEM.description = "A military suit with a mandatory gasmask.\nProvides you with 20% bullet resistance.\nProvides you with tear gas protection.";
ITEM.tearGasProtection = true;

openAura.schema:RegisterLeveledArmor(ITEM);