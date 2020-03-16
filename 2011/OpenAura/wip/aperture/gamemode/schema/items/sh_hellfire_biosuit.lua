--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 2750;
ITEM.name = "Hellfire Biosuit";
ITEM.weight = 2;
ITEM.business = true;
ITEM.armorScale = 0.225;
ITEM.replacement = "models/bio_suit/hell_bio_suit.mdl";
ITEM.description = "A Hellfire branded biological protection suit.\nProvides you with 22.5% bullet resistance.\nProvides you with tear gas protection.";
ITEM.tearGasProtection = true;

openAura.schema:RegisterLeveledArmor(ITEM);