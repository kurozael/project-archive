--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 2000;
ITEM.name = "Tactical Gasmask";
ITEM.weight = 1.5;
ITEM.business = true;
ITEM.armorScale = 0.15;
ITEM.replacement = "models/tactical_rebel.mdl";
ITEM.description = "A tactical uniform with a mandatory gasmask.\nProvides you with 15% bullet resistance.\nProvides you with tear gas protection.";
ITEM.tearGasProtection = true;

openAura.schema:RegisterLeveledArmor(ITEM);