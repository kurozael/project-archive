--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "junk_base";
ITEM.name = "Wrench";
ITEM.worth = 2;
ITEM.model = "models/props_c17/tools_wrench01a.mdl";
ITEM.weight = 0.2
ITEM.description = "A rusty wrench.";

openAura.item:Register(ITEM);