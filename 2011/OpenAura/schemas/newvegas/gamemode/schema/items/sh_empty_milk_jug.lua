--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "junk_base";
ITEM.name = "Empty Milk Jug";
ITEM.worth = 1;
ITEM.model = "models/props_junk/garbage_milkcarton001a.mdl";
ITEM.weight = 0.1;
ITEM.description = "An empty milk jug, it smells like shit.";

openAura.item:Register(ITEM);