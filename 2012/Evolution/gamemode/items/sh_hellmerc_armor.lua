--[[
	© 2012 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
ITEM.cost = (14000 * 0.5);
ITEM.name = "Hellmerc Armor";
ITEM.weight = 2;
ITEM.business = true;
ITEM.armorScale = 0.425;
ITEM.replacement = "models/salem/slow.mdl";
ITEM.description = "Some Hellmerc branded armor with a stylised mask.";

Clockwork.item:Register(ITEM);