--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "clothes_base";
ITEM.cost = 300;
ITEM.name = "Gasmask Armor";
ITEM.weight = 1.5;
ITEM.replacement = "models/tactical_rebel.mdl";
ITEM.description = "Some leather armor with a mandatory gasmask for protection.";

openAura.item:Register(ITEM);