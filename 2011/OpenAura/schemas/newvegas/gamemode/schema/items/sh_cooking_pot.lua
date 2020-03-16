--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "junk_base";
ITEM.name = "Cooking Pot";
ITEM.worth = 2;
ITEM.model = "models/props_interiors/pot02a.mdl";
ITEM.weight = 0.2
ITEM.description = "A dirty pot used for cooking.";

openAura.item:Register(ITEM);