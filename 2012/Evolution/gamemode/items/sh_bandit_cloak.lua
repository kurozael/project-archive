--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = (1000 * 0.5);
ITEM.name = "Bandit Cloak";
ITEM.weight = 1;
ITEM.business = true;
ITEM.armorScale = 0.05;
ITEM.replacement = "models/srp/stalker_bandit_veteran2.mdl";
ITEM.description = "A bandit cloak, usually used for comitting bad deeds.";

Clockwork.item:Register(ITEM);