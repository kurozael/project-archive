--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "junk_base";
ITEM.name = "Bleach";
ITEM.model = "models/props_junk/garbage_plasticbottle001a.mdl";
ITEM.plural = "Bleaches";
ITEM.worth = 1;
ITEM.weight = 0.1;
ITEM.description = "A bottle of bleach, this is dangerous stuff.";

openAura.item:Register(ITEM);