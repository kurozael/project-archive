--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = (5500 * 0.5);
ITEM.name = "Hellfire Biosuit";
ITEM.weight = 2;
ITEM.business = true;
ITEM.armorScale = 0.225;
ITEM.replacement = "models/bio_suit/hell_bio_suit.mdl";
ITEM.description = "A Hellfire branded biological protection suit.";
ITEM.tearGasProtection = true;

Clockwork.item:Register(ITEM);