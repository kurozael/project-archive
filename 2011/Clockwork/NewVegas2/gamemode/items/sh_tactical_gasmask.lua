--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = Clockwork.item:New("custom_clothes");
	ITEM.cost = 300;
	ITEM.name = "Gasmask Armor";
	ITEM.weight = 1.5;
	ITEM.replacement = "models/tactical_rebel.mdl";
	ITEM.description = "Some leather armor with a mandatory gasmask for protection.";
Clockwork.item:Register(ITEM);