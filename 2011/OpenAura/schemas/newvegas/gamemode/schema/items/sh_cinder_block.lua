--[[
	© 2011 CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).
--]]

ITEM = openAura.item:New();
ITEM.base = "junk_base";
ITEM.name = "Cinder Block";
ITEM.worth = 20;
ITEM.model = "models/props_junk/cinderblock01a.mdl";
ITEM.weight = 2;
ITEM.description = "A heavy block of concrete.";

openAura.item:Register(ITEM);