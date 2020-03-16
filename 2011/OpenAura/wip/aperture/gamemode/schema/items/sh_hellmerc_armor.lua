--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 3500;
ITEM.name = "Hellmerc Armor";
ITEM.weight = 2;
ITEM.business = true;
ITEM.armorScale = 0.275;
ITEM.replacement = "models/salem/slow.mdl";
ITEM.description = "Some Hellmerc branded armor with a stylised mask.\nProvides you with 27.5% bullet resistance.\nProvides you with tear gas protection.";
ITEM.tearGasProtection = true;

openAura.schema:RegisterLeveledArmor(ITEM);